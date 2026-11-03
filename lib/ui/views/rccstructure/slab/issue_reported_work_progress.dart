import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_rcc_slab_issues.dart';
import 'package:stallion/models/get_rccissuereport_data.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/widgets/stallion_video_player.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:url_launcher/url_launcher.dart';

enum IssueMediaType { image, video, pdf }

class IssueReportedWorkProgress extends StatefulWidget {
  IssueReportedWorkProgress({
    Key? key,
    this.projectName,
    required this.towarName,
    required this.slabIssueReportData,
    this.projectId,
    this.towarId,
  }) : super(key: key);

  final String? projectName;
  final String towarName;
  final String? projectId;
  final String? towarId;
  List<SlabIssueReport> slabIssueReportData;

  @override
  State<IssueReportedWorkProgress> createState() =>
      _IssueReportedWorkProgressState();
}

class _IssueReportedWorkProgressState extends State<IssueReportedWorkProgress> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final NetworkHandler apiNetworkHandler = NetworkHandler();

  Future<void> _fetchPendingIssues() async {
    final tId = widget.towarId;
    if (tId == null || tId.isEmpty) return;
    try {
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        await apiNetworkHandler.ensureProjectContext(widget.projectId!);
      }
      String url = "${AppUrl.getRccSlabIssues}?tower_id=$tId&status=pending";
      var response = await apiNetworkHandler.get(url);
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final parsed = getRccSlabIssuesResponseFromJson(response.body);
        if (parsed.success && parsed.data != null) {
          final mapped = parsed.data!.issues
              .map((item) => item.toSlabIssueReport())
              .toList();
          if (mounted) {
            setState(() {
              widget.slabIssueReportData = mapped;
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print("Error refreshing pending issues: $e");
    }
  }

  String formatMediaUrl(String? raw, {String? imagePath}) {
    if (raw == null || raw.trim().isEmpty) return '';
    final cleaned = raw.trim();
    if (cleaned.startsWith('http://') || cleaned.startsWith('https://')) {
      return cleaned;
    }
    if (imagePath != null && imagePath.isNotEmpty) {
      return '$imagePath/$cleaned';
    }
    return '${AppUrl.globalProfileImgURLThumbs}$cleaned';
  }

  IssueMediaType getMediaType(String raw) {
    final lower = raw.toLowerCase().split('?').first;
    if (lower.endsWith('.pdf')) {
      return IssueMediaType.pdf;
    }
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm')) {
      return IssueMediaType.video;
    }
    return IssueMediaType.image;
  }

  void openMediaViewer(BuildContext context, String rawUrl, {String? imagePath}) {
    final formattedUrl = formatMediaUrl(rawUrl, imagePath: imagePath);
    if (formattedUrl.isEmpty) return;

    final type = getMediaType(formattedUrl);
    final fileName = rawUrl.startsWith('http')
        ? Uri.parse(rawUrl).path.split('/').last
        : rawUrl.split('/').last;

    if (type == IssueMediaType.pdf) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewer(
            fileName: fileName,
            fileUrl: formattedUrl,
          ),
        ),
      );
    } else if (type == IssueMediaType.video) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StallionVideoPlayer(
            fileUrl: formattedUrl,
            documentName: fileName,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImagePreviewViewer(
            fileName: fileName,
            fileUrl: formattedUrl,
          ),
        ),
      );
    }
  }

  Future<bool> setIssueResolved({
    required String issueId,
    required String remarks,
    List<PlatformFile>? attachedFiles,
    required SlabIssueReport plistData,
  }) async {
    try {
      final token = await apiNetworkHandler.getToken();
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse(AppUrl.updateIssueStatus),
      );

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['issue_id'] = issueId;
      request.fields['status'] = 'resolved';
      request.fields['remarks'] = remarks;

      if (attachedFiles != null && attachedFiles.isNotEmpty) {
        for (var file in attachedFiles) {
          if (file.path != null) {
            final ext = (file.extension ?? '').toLowerCase();
            MediaType mediaType;
            if (ext == 'mp4' || ext == 'mov' || ext == 'avi' || ext == 'mkv') {
              mediaType = MediaType('video', ext.isEmpty ? 'mp4' : ext);
            } else if (ext == 'pdf') {
              mediaType = MediaType('application', 'pdf');
            } else {
              mediaType = MediaType('image', ext.isEmpty ? 'jpeg' : ext);
            }
            request.files.add(await http.MultipartFile.fromPath(
              'files',
              file.path!,
              contentType: mediaType,
            ));
          }
        }
      }

      if (kDebugMode) {
        print("Resolving Issue #$issueId: fields=${request.fields}, filesCount=${request.files.length}");
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print("Resolve Issue response [${response.statusCode}]: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          final now = DateTime.now();
          final formattedNow =
              "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
          final index = widget.slabIssueReportData.indexOf(plistData);
          if (index != -1) {
            widget.slabIssueReportData[index] = SlabIssueReport(
              mstSlabIssuerReportId: plistData.mstSlabIssuerReportId,
              issueIn: plistData.issueIn,
              reports: remarks.isNotEmpty ? remarks : plistData.reports,
              extracomment: plistData.extracomment,
              submitdate: plistData.submitdate,
              resolvedate: formattedNow,
              userIdFk: plistData.userIdFk,
              issueResolve: "1",
              issusInName: plistData.issusInName,
              reportBy: plistData.reportBy,
              reportedBy: plistData.reportedBy,
              reportToName: plistData.reportToName,
              reportTo: plistData.reportTo,
              issueResolveBtn: "1",
              resolvedDate: formattedNow,
              slabVedio: plistData.slabVedio,
              image: plistData.image,
              imagePath: plistData.imagePath,
              resolutionImages: plistData.resolutionImages,
              resolutionVideos: plistData.resolutionVideos,
              empname: plistData.empname,
            );
          }
        });
        return true;
      }
    } catch (e) {
      if (kDebugMode) print("Error setIssueResolved: $e");
    }
    return false;
  }

  Future<String?> _showMediaSourcePickerSheet(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext sheetContext) {
        final isMobile = context.isMobile;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  "Attach Media / Document",
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.black87),
                  ),
                  title: const Text(
                    "Take Photo (Camera)",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    "Capture a new photo using your camera",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop('camera'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: Colors.black87),
                  ),
                  title: const Text(
                    "Choose from Gallery",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    "Select photos from your device gallery",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop('gallery'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.folder_open_rounded, color: Colors.black87),
                  ),
                  title: const Text(
                    "Browse Files (PDFs / Videos / Files)",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    "Pick documents, PDF reports, or video recordings",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop('files'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNoticeDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showResolveConfirmationDialog(SlabIssueReport plist) {
    final parentContext = context;
    final isMobile = context.isMobile;
    final TextEditingController resolveRemarksController = TextEditingController();
    List<PlatformFile> resolveFiles = [];

    showDialog<void>(
      barrierDismissible: false,
      context: parentContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              titlePadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
              actionsPadding: const EdgeInsets.all(12),
              actionsAlignment: MainAxisAlignment.center,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  "RESOLVE ISSUE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              content: SizedBox(
                width: isMobile ? 290 : 420,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Enter Resolution Remarks / Comments:",
                        style: TextStyle(fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: resolveRemarksController,
                        minLines: 2,
                        maxLines: 4,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                        style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.black),
                        decoration: InputDecoration(
                          hintText: "Enter resolution remarks...",
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Attach Resolution Photos / Videos / PDFs:",
                        style: TextStyle(fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final bool isMobileDevice = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
                          if (isMobileDevice) {
                            final source = await _showMediaSourcePickerSheet(context);
                            if (source == 'camera') {
                              try {
                                final ImagePicker picker = ImagePicker();
                                final XFile? photo = await picker.pickImage(
                                  source: ImageSource.camera,
                                  imageQuality: 85,
                                );
                                if (photo != null) {
                                  final bytes = await photo.readAsBytes();
                                  final length = await photo.length();
                                  final file = PlatformFile(
                                    name: photo.name,
                                    path: photo.path,
                                    size: length,
                                    bytes: bytes,
                                  );
                                  setDialogState(() {
                                    resolveFiles.add(file);
                                  });
                                }
                              } catch (e) {
                                if (kDebugMode) print("Camera error in resolve dialog: $e");
                              }
                              return;
                            } else if (source == 'gallery') {
                              try {
                                final ImagePicker picker = ImagePicker();
                                final List<XFile> photos = await picker.pickMultiImage(imageQuality: 85);
                                if (photos.isNotEmpty) {
                                  for (var p in photos) {
                                    final bytes = await p.readAsBytes();
                                    final length = await p.length();
                                    resolveFiles.add(PlatformFile(
                                      name: p.name,
                                      path: p.path,
                                      size: length,
                                      bytes: bytes,
                                    ));
                                  }
                                  setDialogState(() {});
                                }
                              } catch (e) {
                                if (kDebugMode) print("Gallery error in resolve dialog: $e");
                              }
                              return;
                            } else if (source == 'files') {
                              final result = await FilePicker.platform.pickFiles(
                                allowMultiple: true,
                                type: FileType.custom,
                                allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi', 'mkv', 'pdf'],
                              );
                              if (result != null && result.files.isNotEmpty) {
                                setDialogState(() {
                                  resolveFiles.addAll(result.files);
                                });
                              }
                            }
                          } else {
                            final result = await FilePicker.platform.pickFiles(
                              allowMultiple: true,
                              type: FileType.custom,
                              allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi', 'mkv', 'pdf'],
                            );
                            if (result != null && result.files.isNotEmpty) {
                              setDialogState(() {
                                resolveFiles.addAll(result.files);
                              });
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.attach_file, size: 18, color: Colors.black87),
                              SizedBox(width: 6),
                              Text("Pick Files (Images / Videos / PDFs)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      if (resolveFiles.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: resolveFiles.map((f) {
                            return Chip(
                              label: Text(f.name, style: const TextStyle(fontSize: 11)),
                              onDeleted: () {
                                setDialogState(() {
                                  resolveFiles.remove(f);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                InkWell(
                  onTap: () => Navigator.of(dialogContext).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(20)),
                    child: Text("CANCEL", style: TextStyle(fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () async {
                    final remarks = resolveRemarksController.text.trim();
                    if (remarks.isEmpty) {
                      _showNoticeDialog(parentContext, "Please enter resolution remarks.");
                      return;
                    }

                    Navigator.of(dialogContext).pop();
                    CustomLoading.progressDialog(isLoading: true, context: parentContext);
                    bool success = false;
                    try {
                      success = await setIssueResolved(
                        issueId: plist.mstSlabIssuerReportId.toString(),
                        remarks: remarks,
                        attachedFiles: resolveFiles,
                        plistData: plist,
                      );
                    } catch (e) {
                      if (kDebugMode) print("Error in setIssueResolved: $e");
                    } finally {
                      if (mounted) {
                        try {
                          CustomLoading.progressDialog(isLoading: false, context: parentContext);
                        } catch (_) {}
                        if (success) {
                          _showNoticeDialog(parentContext, "Issue resolved successfully!");
                        } else {
                          _showNoticeDialog(parentContext, "Failed to update issue status. Please try again.");
                        }
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                    child: Text("RESOLVE", style: TextStyle(fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showViewDocsModal(SlabIssueReport plist) {
    final isMobile = context.isMobile;

    List<Widget> gridItems = [];

    final resImgs = (plist.resolutionImages != null && plist.resolutionImages!.isNotEmpty)
        ? plist.resolutionImages!
        : (plist.image ?? []);
    final resVids = (plist.resolutionVideos != null && plist.resolutionVideos!.isNotEmpty)
        ? plist.resolutionVideos!
        : (plist.slabVedio ?? []);

    final List<String> allProofs = [...resImgs, ...resVids];

    for (var rawItem in allProofs) {
      final formattedUrl = formatMediaUrl(rawItem, imagePath: plist.imagePath);
      final mediaType = getMediaType(formattedUrl);
      final fileName = rawItem.startsWith('http')
          ? Uri.parse(rawItem).path.split('/').last
          : rawItem.split('/').last;

      if (mediaType == IssueMediaType.pdf) {
        gridItems.add(
          InkWell(
            onTap: () => openMediaViewer(context, rawItem, imagePath: plist.imagePath),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf, size: isMobile ? 32 : 40, color: Colors.red.shade700),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: isMobile ? 9 : 11, color: Colors.red.shade800, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else if (mediaType == IssueMediaType.video) {
        gridItems.add(
          InkWell(
            onTap: () => openMediaViewer(context, rawItem, imagePath: plist.imagePath),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_fill, size: isMobile ? 36 : 44, color: Colors.indigo),
                  const SizedBox(height: 4),
                  Text(
                    "Play Video",
                    style: TextStyle(fontSize: isMobile ? 10 : 11, color: Colors.indigo, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        gridItems.add(
          InkWell(
            onTap: () => openMediaViewer(context, rawItem, imagePath: plist.imagePath),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  formattedUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade100,
                    child: Center(
                      child: Icon(Icons.broken_image_outlined, size: isMobile ? 28 : 36, color: Colors.grey.shade500),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
          actionsPadding: const EdgeInsets.all(12),
          actionsAlignment: MainAxisAlignment.center,
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              "RESOLUTION PROOFS",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 13 : 15,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: SizedBox(
            width: isMobile ? 290 : 420,
            child: gridItems.isNotEmpty
                ? GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    physics: const NeverScrollableScrollPhysics(),
                    children: gridItems,
                  )
                : const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        "No proofs attached for this issue.",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),
                  ),
          ),
          actions: [
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                child: Text("CLOSE", style: TextStyle(fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildIssueReportCard({
    required SlabIssueReport plist,
    required bool isMobile,
  }) {
    final bool isResolved = plist.issueResolve == "1";
    final baseStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

    Widget buildMediaWidget() {
      final List<String> allMedia = [];
      if (plist.image != null) {
        allMedia.addAll(plist.image!);
      }
      if (plist.slabVedio != null) {
        allMedia.addAll(plist.slabVedio!);
      }

      if (allMedia.isNotEmpty) {
        final rawItem = allMedia.first;
        final formattedUrl = formatMediaUrl(rawItem, imagePath: plist.imagePath);
        final mediaType = getMediaType(formattedUrl);
        final fileName = rawItem.startsWith('http')
            ? Uri.parse(rawItem).path.split('/').last
            : rawItem.split('/').last;

        if (mediaType == IssueMediaType.pdf) {
          return InkWell(
            onTap: () => openMediaViewer(context, rawItem, imagePath: plist.imagePath),
            child: Container(
              width: isMobile ? 90 : 130,
              height: isMobile ? 90 : 130,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf, size: isMobile ? 32 : 44, color: Colors.red.shade700),
                        const SizedBox(height: 4),
                        Text(
                          "VIEW PDF",
                          style: TextStyle(
                            fontSize: isMobile ? 9 : 11,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (allMedia.length > 1)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "+${allMedia.length - 1}",
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        } else if (mediaType == IssueMediaType.video) {
          return InkWell(
            onTap: () => openMediaViewer(context, rawItem, imagePath: plist.imagePath),
            child: Container(
              width: isMobile ? 90 : 130,
              height: isMobile ? 90 : 130,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_fill, size: isMobile ? 32 : 44, color: Colors.indigo),
                        const SizedBox(height: 4),
                        Text(
                          "PLAY VIDEO",
                          style: TextStyle(fontSize: isMobile ? 9 : 11, color: Colors.indigo, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  if (allMedia.length > 1)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "+${allMedia.length - 1}",
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        } else {
          return InkWell(
            onTap: () => openMediaViewer(context, rawItem, imagePath: plist.imagePath),
            child: Container(
              width: isMobile ? 90 : 130,
              height: isMobile ? 90 : 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      formattedUrl,
                      width: isMobile ? 90 : 130,
                      height: isMobile ? 90 : 130,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade500, size: isMobile ? 24 : 32),
                              const SizedBox(height: 4),
                              Text(
                                "NO IMAGE",
                                style: TextStyle(fontSize: isMobile ? 9 : 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (allMedia.length > 1)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "+${allMedia.length - 1}",
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }
      } else {
        return Container(
          width: isMobile ? 90 : 130,
          height: isMobile ? 90 : 130,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400, size: isMobile ? 24 : 32),
              const SizedBox(height: 4),
              Text(
                "NO MEDIA\nAVAILABLE",
                style: TextStyle(fontSize: isMobile ? 9 : 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
    }

    Widget buildInfoRow(String label, String? value) {
      if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
      final String cleanLabel = label.endsWith(':') ? label.substring(0, label.length - 1).trim() : label;
      final double labelWidth = isMobile ? 95.0 : 115.0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: labelWidth,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      cleanLabel,
                      style: baseStyle.copyWith(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.3,
                      ),
                    ),
                  ),
                  Text(
                    ":",
                    style: baseStyle.copyWith(
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                value,
                style: baseStyle.copyWith(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey.shade800,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final double capsuleWidth = isMobile ? 125.0 : 145.0;

    Widget buildStatusBadge() {
      return Container(
        width: capsuleWidth,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 10, vertical: isMobile ? 5 : 7),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isResolved ? Colors.green : Colors.red, width: 1.2),
        ),
        child: Text(
          isResolved ? "Issue Resolved" : "Issue Pending",
          style: TextStyle(
            fontSize: isMobile ? 11 : 13,
            fontWeight: FontWeight.bold,
            color: isResolved ? Colors.green : Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    Widget buildActionButton() {
      if (!isResolved) {
        return InkWell(
          onTap: () => _showResolveConfirmationDialog(plist),
          child: Container(
            width: capsuleWidth,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 10, vertical: isMobile ? 5 : 7),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.black, size: isMobile ? 13 : 16),
                const SizedBox(width: 4),
                Text(
                  "Mark as Resolved",
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return InkWell(
          onTap: () => _showViewDocsModal(plist),
          child: Container(
            width: capsuleWidth,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 10, vertical: isMobile ? 5 : 7),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.description_outlined, color: Colors.black, size: isMobile ? 13 : 16),
                const SizedBox(width: 4),
                Text(
                  "View Docs",
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 10.0 : 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe9ecef)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildMediaWidget(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          buildStatusBadge(),
                          const SizedBox(height: 8),
                          buildActionButton(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xffe9ecef)),
                const SizedBox(height: 10),
                buildInfoRow("Reported By", plist.reportBy ?? plist.reportedBy),
                buildInfoRow("Reported On", plist.submitdate),
                buildInfoRow("Issue In", plist.issusInName),
                buildInfoRow("Reported To", plist.reportToName),
                if (isResolved) ...[
                  buildInfoRow("Resolved On", plist.resolvedDate),
                  buildInfoRow("Resolved By", plist.empname),
                ],
                buildInfoRow("Remarks", plist.reports),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildMediaWidget(),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildInfoRow("Reported By", plist.reportBy ?? plist.reportedBy),
                      buildInfoRow("Issue In", plist.issusInName),
                      buildInfoRow("Reported To", plist.reportToName),
                      buildInfoRow("Reported On", plist.submitdate),
                      if (isResolved) ...[
                        buildInfoRow("Resolved On", plist.resolvedDate),
                        buildInfoRow("Resolved By", plist.empname),
                      ],
                      buildInfoRow("Remarks", plist.reports),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    buildStatusBadge(),
                    const SizedBox(height: 8),
                    buildActionButton(),
                  ],
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final titleString = widget.towarName.isNotEmpty
        ? '${(widget.projectName ?? '').toUpperCase()} - ${widget.towarName.toUpperCase()}'
        : (widget.projectName ?? '').toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          titleString,
          style: const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 10.0 : 12.0,
              horizontal: 16.0,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xffe9ecef),
                  width: 1.0,
                ),
              ),
            ),
            child: Text(
              "ISSUE REPORTED",
              style: TextStyle(
                fontSize: isMobile ? 13 : 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchPendingIssues,
              child: widget.slabIssueReportData.isNotEmpty
                  ? ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12.0 : 24.0,
                        vertical: isMobile ? 10.0 : 16.0,
                      ),
                      itemCount: widget.slabIssueReportData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return buildIssueReportCard(
                          plist: widget.slabIssueReportData[index],
                          isMobile: isMobile,
                        );
                      },
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_outline,
                                    size: 50, color: Colors.green.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  "No pending issues reported for this tower.",
                                  style: TextStyle(
                                    fontSize: isMobile ? 13 : 15,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
