import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';

class StallionVideoPlayer extends StatefulWidget {
  final String fileUrl;
  final String documentName;

  const StallionVideoPlayer({
    Key? key,
    required this.fileUrl,
    required this.documentName,
  }) : super(key: key);

  @override
  State<StallionVideoPlayer> createState() => _StallionVideoPlayerState();
}

class _StallionVideoPlayerState extends State<StallionVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _showControls = true;
  bool _isFullscreen = false;
  bool _isActionLoading = false;
  String _actionLoadingMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final uri = Uri.parse(widget.fileUrl);
      _controller = VideoPlayerController.networkUrl(uri);
      
      _controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
        _hideControlsDelayed();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _hideControlsDelayed() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying && _showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  @override
  void dispose() {
    if (_isFullscreen) {
      _exitFullscreen();
    }
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _showControls = true;
      } else {
        _controller.play();
        _hideControlsDelayed();
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _controller.setVolume(_controller.value.volume == 0 ? 1.0 : 0.0);
    });
  }

  Future<void> _toggleFullscreen() async {
    if (_isFullscreen) {
      await _exitFullscreen();
    } else {
      await _enterFullscreen();
    }
  }

  Future<void> _enterFullscreen() async {
    setState(() {
      _isFullscreen = true;
    });
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _exitFullscreen() async {
    setState(() {
      _isFullscreen = false;
    });
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  void _seekRelative(int seconds) {
    final currentPosition = _controller.value.position;
    final newPosition = currentPosition + Duration(seconds: seconds);
    _controller.seekTo(newPosition);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Rect? _getSharePositionOrigin([BuildContext? btnContext]) {
    try {
      final box = (btnContext ?? context).findRenderObject() as RenderBox?;
      if (box != null && box.hasSize && box.size.width > 0 && box.size.height > 0) {
        return box.localToGlobal(Offset.zero) & box.size;
      }
    } catch (_) {}
    final size = MediaQuery.of(context).size;
    return Rect.fromLTWH(size.width - 60, 40, 50, 50);
  }

  Future<void> _shareVideo([BuildContext? btnContext]) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() {
      _isActionLoading = true;
      _actionLoadingMessage = "Preparing video for sharing...";
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('projectToken') ?? prefs.getString('masterToken') ?? prefs.getString('token');
      
      final Map<String, String> headers = {};
      final bool isS3 = widget.fileUrl.contains('amazonaws.com') || widget.fileUrl.contains('X-Amz-Signature');
      if (token != null && !isS3) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(Uri.parse(widget.fileUrl), headers: headers);
      
      if (response.statusCode == 200) {
        final Directory tempDir = await getTemporaryDirectory();
        final String cleanFileName = widget.documentName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
        final File tempFile = File('${tempDir.path}/$cleanFileName');
        await tempFile.writeAsBytes(response.bodyBytes, flush: true);

        await Share.shareXFiles(
          [XFile(tempFile.path)],
          subject: widget.documentName,
          sharePositionOrigin: _getSharePositionOrigin(btnContext),
        );
      } else {
        throw Exception("Failed to download video. Status code: ${response.statusCode}");
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Failed to share video: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isActionLoading = false;
        });
      }
    }
  }

  String _getFileExtension(String url, String defaultExt) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final dotIndex = path.lastIndexOf('.');
      if (dotIndex != -1) {
        final ext = path.substring(dotIndex).toLowerCase();
        final regExp = RegExp(r'^\.[a-zA-Z0-9]{2,5}$');
        if (regExp.hasMatch(ext)) {
          return ext;
        }
      }
    } catch (_) {}
    return defaultExt;
  }

  Future<void> _downloadAndSaveVideo() async {
    if (widget.fileUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File URL is missing or empty.")),
      );
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() {
      _isActionLoading = true;
      _actionLoadingMessage = "Downloading video...";
    });

    Uint8List? videoBytes;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('projectToken') ?? prefs.getString('masterToken') ?? prefs.getString('token');
    
    final Map<String, String> headers = {};
    final bool isS3 = widget.fileUrl.contains('amazonaws.com') || widget.fileUrl.contains('X-Amz-Signature');
    if (token != null && !isS3) {
      headers['Authorization'] = 'Bearer $token';
    }
    final client = http.Client();

    try {
      var request = http.Request('GET', Uri.parse(widget.fileUrl));
      request.headers.addAll(headers);
      request.followRedirects = false; // Manually handle redirects to avoid S3 redirect auth leakage

      var response = await client.send(request);
      int redirectCount = 0;

      while ((response.statusCode == 301 ||
              response.statusCode == 302 ||
              response.statusCode == 303 ||
              response.statusCode == 307 ||
              response.statusCode == 308) &&
             redirectCount < 5) {
        redirectCount++;
        final location = response.headers['location'];
        if (location == null) break;

        // Strip Authorization header on cross-domain redirect to S3
        request = http.Request('GET', Uri.parse(location));
        response = await client.send(request);
      }

      if (response.statusCode == 200) {
        videoBytes = await response.stream.toBytes();
      } else {
        throw Exception("Server returned status: ${response.statusCode}");
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("Failed to download video: $e")),
      );
      client.close();
      if (mounted) {
        setState(() {
          _isActionLoading = false;
        });
      }
      return;
    } finally {
      client.close();
    }

    if (mounted) {
      setState(() {
        _isActionLoading = false;
      });
    }

    if (videoBytes == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("Failed to load file content.")),
      );
      return;
    }

    try {
      String? outputPath;
      
      String cleanFileName = widget.documentName;
      final String ext = _getFileExtension(widget.fileUrl, '.mp4');
      if (!cleanFileName.toLowerCase().endsWith(ext.toLowerCase())) {
        cleanFileName = '$cleanFileName$ext';
      }
      cleanFileName = cleanFileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

      // 1. Try using FilePicker saveFile dialog
      try {
        outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Video',
          fileName: cleanFileName,
          type: FileType.any,
          bytes: videoBytes,
        );
      } catch (e) {
        debugPrint('FilePicker saveFile failed: $e');
      }

      // 2. Fallback to writing file directly if outputPath is null
      if (outputPath == null) {
        Directory? dir;
        if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
          dir = await getDownloadsDirectory();
        }
        dir ??= await getApplicationDocumentsDirectory();

        final File file = File('${dir.path}/$cleanFileName');
        await file.writeAsBytes(videoBytes);
        outputPath = file.path;
      }

      if (outputPath != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Video saved successfully to: $outputPath'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("Failed to save video: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.shortestSide < 600;
    final bool isDesktop = !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullscreen
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: Text(
                widget.documentName,
                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                if (isDesktop) ...[
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: _downloadAndSaveVideo,
                  ),
                ] else ...[
                  Builder(
                    builder: (btnContext) => IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => _shareVideo(btnContext),
                    ),
                  ),
                ],
              ],
            ),
      body: SafeArea(
        top: !_isFullscreen,
        bottom: !_isFullscreen,
        child: Center(
          child: _hasError
              ? _buildErrorWidget()
              : !_isInitialized
                  ? _buildLoadingWidget()
                  : _buildVideoPlayerWidget(isMobile),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Colors.white),
        SizedBox(height: 16.0),
        Text(
          "Loading Video...",
          style: TextStyle(color: Colors.white70, fontSize: 14.0),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 64.0),
          const SizedBox(height: 16.0),
          const Text(
            "Failed to load video",
            style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 12.0),
          ),
          const SizedBox(height: 24.0),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade900,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _hasError = false;
                _isInitialized = false;
              });
              _initializePlayer();
            },
            icon: const Icon(Icons.replay),
            label: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayerWidget(bool isMobile) {
    final value = _controller.value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
          if (_showControls && value.isPlaying) {
            _hideControlsDelayed();
          }
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The actual video
          AspectRatio(
            aspectRatio: value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          
          // Buffering overlay
          if (value.isBuffering)
            const Positioned(
              child: CircularProgressIndicator(color: Colors.white70),
            ),

          // Control Overlays
          if (_showControls) _buildControlsOverlay(isMobile),

          // Action Loading Overlay
          if (_isActionLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16.0),
                      Text(
                        _actionLoadingMessage,
                        style: const TextStyle(color: Colors.white, fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay(bool isMobile) {
    final value = _controller.value;
    final position = value.position;
    final duration = value.duration;
    final bool isDesktop = !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Bar (Fullscreen Only Title / Back Button)
          if (_isFullscreen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _toggleFullscreen,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      widget.documentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isDesktop) ...[
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.white),
                      onPressed: _downloadAndSaveVideo,
                    ),
                  ] else ...[
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: _shareVideo,
                    ),
                  ],
                ],
              ),
            )
          else
            const SizedBox.shrink(),

          // Middle controls (Skip back / Play & Pause / Skip forward)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 42.0,
                icon: const Icon(Icons.replay_10, color: Colors.white),
                onPressed: () => _seekRelative(-10),
              ),
              const SizedBox(width: 24.0),
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    value.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 48.0,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 24.0),
              IconButton(
                iconSize: 42.0,
                icon: const Icon(Icons.forward_10, color: Colors.white),
                onPressed: () => _seekRelative(10),
              ),
            ],
          ),

          // Bottom Bar Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Slider timeline
                Row(
                  children: [
                    Text(
                      _formatDuration(position),
                      style: const TextStyle(color: Colors.white, fontSize: 12.0),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3.0,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          min: 0.0,
                          max: duration.inMilliseconds.toDouble(),
                          value: position.inMilliseconds.toDouble().clamp(
                                0.0,
                                duration.inMilliseconds.toDouble(),
                              ),
                          onChanged: (val) {
                            _controller.seekTo(Duration(milliseconds: val.toInt()));
                          },
                        ),
                      ),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: const TextStyle(color: Colors.white, fontSize: 12.0),
                    ),
                  ],
                ),
                
                // Mute and Fullscreen buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        value.volume == 0 ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                      ),
                      onPressed: _toggleMute,
                    ),
                    IconButton(
                      icon: Icon(
                        _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                        color: Colors.white,
                      ),
                      onPressed: _toggleFullscreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
