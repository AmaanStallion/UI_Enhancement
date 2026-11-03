import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:stallion/utils/app_url.dart';

/// Represents Homepage for Navigation
class PdfViewer extends StatefulWidget {
  PdfViewer(
      {Key? key,
      this.fileName,
      this.fileUrl,
      this.isLocalFileUpload = false,
      this.localFiles});

  final String? fileName;
  final String? fileUrl;
  bool? isLocalFileUpload;
  String? localFiles;

  @override
  _PdfViewer createState() => _PdfViewer();
}

class _PdfViewer extends State<PdfViewer> {
  bool isZoomed = false;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  late PdfViewerController _pdfViewerController;
  String? token;
  bool isTokenLoaded = false;

  Uint8List? _fileBytes;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _loadToken();
  }

  _loadToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        token = prefs.getString('projectToken') ?? prefs.getString('masterToken') ?? prefs.getString('token');
        isTokenLoaded = true;
      });
      if (widget.isLocalFileUpload != true) {
        _downloadFileBytes();
      }
    }
  }

  Future<void> _downloadFileBytes() async {
    if (widget.fileUrl == null || widget.fileUrl!.isEmpty) {
      if (mounted) {
        setState(() {
          _errorMessage = "File URL is missing or empty.";
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final headers = _buildHeaders();
    final client = http.Client();
    try {
      String targetUrl = widget.fileUrl!;
      if (targetUrl.startsWith('/')) {
        String base = AppUrl.baseURL;
        if (base.endsWith('/')) {
          base = base.substring(0, base.length - 1);
        }
        targetUrl = "$base$targetUrl";
      }
      var request = http.Request('GET', Uri.parse(targetUrl));
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

        // S3 presigned URL requires stripping the Authorization header
        request = http.Request('GET', Uri.parse(location));
        response = await client.send(request);
      }

      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        if (mounted) {
          setState(() {
            _fileBytes = bytes;
            _isLoading = false;
          });
        }
      } else {
        String msg = "Failed to load document (Status: ${response.statusCode})";
        try {
          final resString = await response.stream.bytesToString();
          final decoded = json.decode(resString);
          if (decoded != null &&
              decoded['message'] != null &&
              decoded['message'].toString().trim().isNotEmpty) {
            msg = decoded['message'].toString().trim();
          }
        } catch (_) {}
        if (mounted) {
          setState(() {
            _errorMessage = msg;
            _isLoading = false;
          });
        }
      }
    } catch (e, stack) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error loading document: $e";
          _isLoading = false;
        });
      }
    } finally {
      client.close();
    }
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
    final bool isDwg = widget.fileName?.toLowerCase().contains('.dwg') ?? false;
    final bool isDesktop = !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.fileName ?? '',
          style: TextStyle(fontStyle: FontStyle.normal, fontSize: isDesktop ? 17.0 : 15.0),
          maxLines: isDesktop ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        actions: <Widget>[
          if (isDesktop) ...[
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: _downloadAndSaveFile,
            ),
            if (!isDwg) ...[
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.zoom_in, color: Colors.white, size: 30),
                onPressed: () => setState(() => isZoomed = !isZoomed),
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.zoom_out, color: Colors.white, size: 30),
                onPressed: () => setState(() => isZoomed = !isZoomed),
              ),
            ],
          ] else ...[
            // On mobile, only show share button on the top right
            Builder(
              builder: (btnContext) => IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () => _shareFile(btnContext),
              ),
            ),
          ],
          const SizedBox(width: 20)
        ],
      ),
      bottomNavigationBar: null,
      body: widget.isLocalFileUpload == true
          ? SfPdfViewer.file(
              initialZoomLevel: 1,
              enableDoubleTapZooming: true,
              File(widget.localFiles ?? ''),
              key: _pdfViewerKey,
              controller: _pdfViewerController,
              pageLayoutMode: PdfPageLayoutMode.single,
            )
          : !isTokenLoaded || _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _errorMessage!.toLowerCase().contains('not found') ||
                                      _errorMessage!.toLowerCase().contains('no slab')
                                  ? Icons.info_outline_rounded
                                  : Icons.error_outline_rounded,
                              color: _errorMessage!.toLowerCase().contains('not found') ||
                                      _errorMessage!.toLowerCase().contains('no slab')
                                  ? Colors.orange.shade700
                                  : Colors.redAccent,
                              size: 60,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.maybePop(context);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    side: const BorderSide(color: Colors.black),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text('Go Back'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: _downloadFileBytes,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : isDwg
                      ? Center(
                          child: Container(
                            margin: const EdgeInsets.all(24),
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.insert_drive_file_outlined,
                                  color: Colors.blueAccent,
                                  size: 80,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  widget.fileName ?? 'CAD Document.dwg',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Preview not available for DWG files.\nPlease download the file to view it on your device.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: _downloadAndSaveFile,
                                  icon: const Icon(Icons.download, color: Colors.white),
                                  label: const Text('Download DWG'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Center(
                          child: Container(
                            width: isDesktop ? (isZoomed ? 940 : 700) : null,
                            child: _fileBytes != null
                                ? SfPdfViewer.memory(
                                    _fileBytes!,
                                    key: _pdfViewerKey,
                                    controller: _pdfViewerController,
                                    enableDoubleTapZooming: true,
                                    initialZoomLevel: isDesktop ? 0.75 : 1.0,
                                  )
                                : (widget.fileUrl != null &&
                                        widget.fileUrl!.startsWith('http')
                                    ? SfPdfViewer.network(
                                        widget.fileUrl!,
                                        key: _pdfViewerKey,
                                        controller: _pdfViewerController,
                                        enableDoubleTapZooming: true,
                                        initialZoomLevel:
                                            isDesktop ? 0.75 : 1.0,
                                      )
                                    : const Center(
                                        child: Text("Unable to display PDF"),
                                      )),
                          ),
                        ),
    );
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

  Future<void> _downloadAndSaveFile() async {
    Uint8List? bytesToSave = _fileBytes;
    if (widget.isLocalFileUpload == true && widget.localFiles != null) {
      try {
        final localFile = File(widget.localFiles!);
        if (await localFile.exists()) {
          bytesToSave = await localFile.readAsBytes();
        }
      } catch (e) {
        debugPrint("Error reading local file: $e");
      }
    }

    if (bytesToSave == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File content is not loaded yet or failed to load.')),
      );
      return;
    }

    try {
      String? outputPath;
      
      String cleanFileName = widget.fileName ?? 'document.pdf';
      final String ext = _getFileExtension(widget.fileUrl ?? '', '.pdf');
      if (!cleanFileName.toLowerCase().endsWith(ext.toLowerCase())) {
        cleanFileName = '$cleanFileName$ext';
      }
      cleanFileName = cleanFileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

      // 1. Try using FilePicker saveFile dialog (native Save As on macOS/desktop)
      try {
        outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save File',
          fileName: cleanFileName,
          type: FileType.any,
          bytes: bytesToSave,
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
        await file.writeAsBytes(bytesToSave);
        outputPath = file.path;
      }

      if (outputPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File saved successfully to: $outputPath'),
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
        SnackBar(content: Text('Failed to save file: $e')),
      );
    }
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

  /// Saves the PDF to a temp file and triggers the native OS share sheet.
  /// Uses share_plus which correctly handles Android content URIs (avoids
  /// FileUriExposedException) and iOS UIActivityViewController.
  Future<void> _shareFile([BuildContext? btnContext]) async {
    Uint8List? bytesToShare = _fileBytes;
    if (widget.isLocalFileUpload == true && widget.localFiles != null) {
      try {
        final localFile = File(widget.localFiles!);
        if (await localFile.exists()) {
          bytesToShare = await localFile.readAsBytes();
        }
      } catch (e) {
        debugPrint('Error reading local file for share: $e');
      }
    }

    if (bytesToShare == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File is not loaded yet. Please wait and try again.')),
        );
      }
      return;
    }

    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String cleanFileName = (widget.fileName ?? 'document.pdf')
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final File tempFile = File('${tempDir.path}/$cleanFileName');
      await tempFile.writeAsBytes(bytesToShare, flush: true);

      // share_plus handles FileProvider on Android and UIActivityViewController on iOS
      final result = await Share.shareXFiles(
        [XFile(tempFile.path, mimeType: 'application/pdf')],
        subject: widget.fileName ?? 'Document',
        sharePositionOrigin: _getSharePositionOrigin(btnContext),
      );

      if (result.status == ShareResultStatus.dismissed && mounted) {
        // User dismissed the share sheet — no need to show an error
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share file: $e')),
        );
      }
    }
  }
}

/// A small labeled icon-button used in the mobile bottom action bar.
class _MobileActionButton extends StatelessWidget {
  const _MobileActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
