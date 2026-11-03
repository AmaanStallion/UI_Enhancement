// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
// import 'package:url_launcher/url_launcher.dart';

// /// Represents Homepage for Navigation
// class ImagePreviewViewer extends StatefulWidget {
//   ImagePreviewViewer({Key? key, this.fileName, this.fileUrl});

//   final String? fileName;
//   final String? fileUrl;

//   @override
//   _ImagePreviewViewer createState() => _ImagePreviewViewer();
// }

// class _ImagePreviewViewer extends State<ImagePreviewViewer> {
//   final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: Text(widget.fileName!,
//             style:
//                 const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.maybePop(context);
//           },
//         ),
//         actions: <Widget>[
//           IconButton(
//             icon: const Icon(Icons.download, color: Colors.white),
//             onPressed: () {
//               //shareFile(widget.fileName);
//               //Save single pdf file
//               _launchURL();
//             },
//           ),
//           SizedBox(
//             width: 20,
//           )
//         ],
//       ),
//       body: Center(
//         child: widget.fileUrl == null || widget.fileUrl!.isEmpty
//             ? const Text(
//                 "No Record Found",
//                 style: TextStyle(fontSize: 16),
//               )
//             : Image.network(
//                 widget.fileUrl! ?? '',
//                 fit: BoxFit.fitWidth,
//                 alignment: Alignment.center,
//               ),
//       ),
//     );
//   }

//   _launchURL() async {
//     if (widget.fileUrl! != "") {
//       print(widget.fileUrl!);
//       final uri = Uri.parse(widget.fileUrl!);
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri);
//       } else {
//         throw 'Could not launch';
//       }
//     }
//   }
// }

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

class ImagePreviewViewer extends StatefulWidget {
  const ImagePreviewViewer({Key? key, this.fileName, this.fileUrl})
      : super(key: key);

  final String? fileName;
  final String? fileUrl;

  @override
  State<ImagePreviewViewer> createState() => _ImagePreviewViewerState();
}

class _ImagePreviewViewerState extends State<ImagePreviewViewer> {
  String? token;
  bool isTokenLoaded = false;
  final TransformationController _transformationController = TransformationController();
  double _zoomScale = 1.0;

  void _zoomIn() {
    setState(() {
      _zoomScale = (_zoomScale + 0.25).clamp(1.0, 4.0);
      _transformationController.value = Matrix4.identity()..scale(_zoomScale);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomScale = (_zoomScale - 0.25).clamp(1.0, 4.0);
      _transformationController.value = Matrix4.identity()..scale(_zoomScale);
    });
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

  Future<void> _shareImage([BuildContext? btnContext]) async {
    if (widget.fileUrl == null || widget.fileUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File URL is missing or empty.")),
      );
      return;
    }

    // Show custom loading dialog
    bool dialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Card(
            color: Colors.black87,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16.0),
                  Text(
                    "Preparing image for sharing...",
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) => dialogOpen = false);

    final headers = _buildHeaders();
    final client = http.Client();

    try {
      var request = http.Request('GET', Uri.parse(widget.fileUrl!));
      if (headers != null) {
        request.headers.addAll(headers);
      }
      var response = await client.send(request);
      var responseData = await http.Response.fromStream(response);

      if (dialogOpen && mounted) {
        Navigator.of(context).pop();
      }

      if (responseData.statusCode == 200) {
        final Directory tempDir = await getTemporaryDirectory();
        final String cleanFileName = (widget.fileName ?? 'image.jpg')
            .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
        final File tempFile = File('${tempDir.path}/$cleanFileName');
        await tempFile.writeAsBytes(responseData.bodyBytes, flush: true);

        await Share.shareXFiles(
          [XFile(tempFile.path)],
          subject: widget.fileName ?? 'Image',
          sharePositionOrigin: _getSharePositionOrigin(btnContext),
        );
      } else {
        throw Exception("Failed to load image. Status: ${responseData.statusCode}");
      }
    } catch (e) {
      if (dialogOpen && mounted) {
        Navigator.of(context).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to share image: $e")),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  _loadToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        token = prefs.getString('projectToken') ?? prefs.getString('masterToken') ?? prefs.getString('token');
        isTokenLoaded = true;
      });
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

  Map<String, String>? _buildHeaders() {
    if (widget.fileUrl != null &&
        (widget.fileUrl!.contains('amazonaws.com') ||
         widget.fileUrl!.contains('X-Amz-Signature'))) {
      return null;
    }
    if (token == null) return null;
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    if (widget.fileUrl != null) {
      try {
        final uri = Uri.parse(widget.fileUrl!);
        String? projectId = uri.queryParameters['project_id'];
        if (projectId == null || projectId.isEmpty) {
          if (widget.fileUrl!.contains('/projects/')) {
            var parts = widget.fileUrl!.split('/projects/');
            if (parts.length > 1) {
              var subParts = parts[1].split('/');
              if (subParts.isNotEmpty && subParts[0].isNotEmpty) {
                projectId = subParts[0];
              }
            }
          }
        }
        if (projectId != null && projectId.isNotEmpty) {
          headers['x-project-id'] = projectId;
        }
      } catch (_) {}
    }
    return headers;
  }

  @override
  Widget build(BuildContext context) {
    final isImageAvailable =
        widget.fileUrl != null && widget.fileUrl!.isNotEmpty;
    final bool isDesktop = !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.fileName ?? '',
          style: const TextStyle(fontSize: 17),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isDesktop) ...[
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadAndSaveImage,
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: _zoomIn,
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(Icons.zoom_out),
              onPressed: _zoomOut,
            ),
          ] else ...[
            // On mobile, only show share button on the top right
            Builder(
              builder: (btnContext) => IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareImage(btnContext),
              ),
            ),
          ],
          const SizedBox(width: 20),
        ],
      ),
      body: !isTokenLoaded
          ? const Center(child: CircularProgressIndicator())
          : isImageAvailable
              ? Center(
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    child: CachedNetworkImage(
                      imageUrl: widget.fileUrl!,
                      httpHeaders: _buildHeaders(),
                      placeholder: (context, url) => _shimmerLoader(),
                      errorWidget: (context, url, error) => Image.network(
                        widget.fileUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => _errorWidget(),
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : const Center(
                  child: Text("No Record Found", style: TextStyle(fontSize: 16))),
    );
  }

  Widget _shimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: double.infinity,
        height: 300,
        color: Colors.white,
      ),
    );
  }

  Widget _errorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 40),
        const SizedBox(height: 10),
        const Text("Failed to load image"),
        ElevatedButton(
          onPressed: () => setState(() {}), // retry loading
          child: const Text("Retry"),
        )
      ],
    );
  }

  Future<void> _downloadAndSaveImage() async {
    if (widget.fileUrl == null || widget.fileUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File URL is missing or empty.")),
      );
      return;
    }

    // Show custom loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    Uint8List? imageBytes;
    final headers = _buildHeaders();
    final client = http.Client();

    try {
      var request = http.Request('GET', Uri.parse(widget.fileUrl!));
      if (headers != null) {
        request.headers.addAll(headers);
      }
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
        imageBytes = await response.stream.toBytes();
      } else {
        throw Exception("Server returned status: ${response.statusCode}");
      }
    } catch (e) {
      // Dismiss loading dialog first
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to download image: $e")),
      );
      client.close();
      return;
    } finally {
      client.close();
    }

    // Dismiss loading dialog
    Navigator.pop(context);

    if (imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load file content.")),
      );
      return;
    }

    try {
      String? outputPath;
      
      String cleanFileName = widget.fileName ?? 'image.jpg';
      final String ext = _getFileExtension(widget.fileUrl ?? '', '.jpg');
      if (!cleanFileName.toLowerCase().endsWith(ext.toLowerCase())) {
        cleanFileName = '$cleanFileName$ext';
      }
      cleanFileName = cleanFileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

      // 1. Try using FilePicker saveFile dialog (native Save As on macOS/desktop)
      try {
        outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Image',
          fileName: cleanFileName,
          type: FileType.any,
          bytes: imageBytes,
        );
      } catch (e) {
        debugPrint('FilePicker saveFile failed: $e');
      }

      // 2. Fallback to writing file directly if outputPath is null (e.g. cancelled dialog or not supported on mobile)
      if (outputPath == null) {
        Directory? dir;
        if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
          dir = await getDownloadsDirectory();
        }
        dir ??= await getApplicationDocumentsDirectory();

        final File file = File('${dir.path}/$cleanFileName');
        await file.writeAsBytes(imageBytes);
        outputPath = file.path;
      }

      if (outputPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image saved successfully to: $outputPath'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () async {
                final Uri fileUri = Uri.file(outputPath!);
                if (await canLaunchUrl(fileUri)) {
                  await launchUrl(fileUri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open file automatically.')),
                  );
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: $e')),
      );
    }
  }
}
