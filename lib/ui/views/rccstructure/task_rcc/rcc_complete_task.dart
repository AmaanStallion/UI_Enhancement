import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:stallion/models/rcc_dpr_activity_model.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';

class RccCompleteTaskPage extends StatefulWidget {
  const RccCompleteTaskPage({
    super.key,
    this.towarId,
    this.projectId,
    this.projectName,
    this.towarName,
    required this.dprTaskId,
    this.activity,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String dprTaskId;
  final RccDprActivity? activity;

  @override
  State<RccCompleteTaskPage> createState() => _RccCompleteTaskPageState();
}

class _RccCompleteTaskPageState extends State<RccCompleteTaskPage> {
  List<PlatformFile> arrayFiles = [];
  List<Uint8List?> arrayFilesBytes = [];
  final TextEditingController _remarkController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> markTaskComplete() async {
    final activityId = widget.activity?.id ?? widget.dprTaskId;
    if (activityId.isEmpty) return;

    CustomLoading.progressDialog(isLoading: true, context: context);

    try {
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        await apiNetworkHandler.ensureProjectContext(widget.projectId);
      }

      final token = await apiNetworkHandler.getToken();
      final url = AppUrl.completeDprActivity(activityId);
      final request = http.MultipartRequest('POST', Uri.parse(url));

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['remarks'] = _remarkController.text.trim();

      if (arrayFiles.isNotEmpty) {
        for (int i = 0; i < arrayFiles.length; i++) {
          PlatformFile file = arrayFiles[i];
          if (file.path != null && file.path!.isNotEmpty) {
            String mimeType = 'application';
            String subType = file.extension ?? 'octet-stream';
            if (file.extension == 'pdf') {
              mimeType = 'application';
              subType = 'pdf';
            } else if (file.extension == 'jpg' ||
                file.extension == 'jpeg' ||
                file.extension == 'png') {
              mimeType = 'image';
              subType = file.extension ?? 'jpeg';
            } else if (file.extension == 'mp4') {
              mimeType = 'video';
              subType = 'mp4';
            }

            request.files.add(
              await http.MultipartFile.fromPath(
                'documents',
                file.path!,
                contentType: MediaType(mimeType, subType),
              ),
            );
          }
        }
      }

      final streamedRes = await request.send();
      final response = await http.Response.fromStream(streamedRes);

      if (kDebugMode) {
        print("completeDprActivity response status: ${response.statusCode}");
        print("completeDprActivity response body: ${response.body}");
      }

      CustomLoading.progressDialog(isLoading: false, context: context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (widget.activity != null) {
          widget.activity!.isCompleted = true;
          widget.activity!.completedAt = DateTime.now();
        }

        if (!mounted) return;
        showDialog<void>(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Task Completed Successfully.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(true);
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Okay",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        String errMsg = 'Failed to complete task';
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            errMsg = decoded['message'].toString();
          }
        } catch (_) {}
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errMsg)),
        );
      }
    } catch (e) {
      CustomLoading.progressDialog(isLoading: false, context: context);
      if (kDebugMode) {
        print("RccCompleteTaskPage: Error completing task: $e");
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return Scaffold(
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 24, vertical: 8),
        child: InkWell(
          onTap: () {
            if (_formKey.currentState!.validate()) {
              markTaskComplete();
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(25),
            ),
            width: double.maxFinite,
            child: Text(
              "SUBMIT",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          (widget.towarName ?? '').isNotEmpty
              ? '${(widget.projectName ?? '').toUpperCase()} - ${(widget.towarName ?? '').toUpperCase()}'
              : (widget.projectName ?? '').toUpperCase(),
          style: TextStyle(
              fontStyle: FontStyle.normal,
              fontSize: isMobile ? 14.0 : 17.0),
        ),
      ),
      body: _buildBodyContent(isMobile),
    );
  }

  Widget _buildBodyContent(bool isMobile) {
    final labelWidth = isMobile ? 75.0 : 130.0;
    final fontSize = isMobile ? 13.0 : 15.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          SizedBox(
            width: double.maxFinite,
            child: AppText(
              title: "COMPLETE TASK",
              fontSize: isMobile ? 15 : 17,
              fontWeight: FontWeight.w700,
              titleTextAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 24, vertical: 6),
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16, vertical: isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Remark Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: labelWidth,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            'Remark',
                            style: TextStyle(
                                fontSize: fontSize, color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Icon(Icons.remove,
                            size: isMobile ? 12 : 16, color: Colors.black54),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "(Remark Cannot be Empty)";
                            }
                            return null;
                          },
                          controller: _remarkController,
                          style: TextStyle(
                              color: Colors.black, fontSize: fontSize),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Colors.black54),
                            ),
                            hintText: 'Write Your Remarks...',
                            hintStyle: TextStyle(
                                fontSize: fontSize, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Add Files Section
                  Text(
                    "Add Files",
                    style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: [
                                'jpg',
                                'jpeg',
                                'png',
                                'pdf',
                                'doc',
                                'docx',
                                'xls',
                                'xlsx',
                                'txt',
                                'mp4'
                              ],
                            );
                            if (result != null) {
                              PlatformFile file = result.files.first;
                              Uint8List? fileBytes = result.files.first.bytes;
                              setState(() {
                                arrayFilesBytes.add(fileBytes);
                                arrayFiles.add(file);
                              });
                            }
                          },
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 1.5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline,
                                    size: 28, color: Colors.grey.shade700),
                                const SizedBox(height: 4),
                                Text(
                                  "Add File",
                                  style: TextStyle(
                                      fontSize: isMobile ? 11 : 12,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        for (int j = 0; j < arrayFiles.length; j++) ...[
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: (arrayFiles[j].extension == 'jpg' ||
                                          arrayFiles[j].extension == 'jpeg' ||
                                          arrayFiles[j].extension == 'png')
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.file(
                                            File(arrayFiles[j].path ?? ''),
                                            height: 80,
                                            width: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              arrayFiles[j].extension == 'pdf'
                                                  ? Icons.picture_as_pdf
                                                  : arrayFiles[j].extension ==
                                                          'mp4'
                                                      ? Icons.video_camera_back
                                                      : Icons.insert_drive_file,
                                              size: 30,
                                              color: arrayFiles[j].extension ==
                                                      'pdf'
                                                  ? Colors.red
                                                  : arrayFiles[j].extension ==
                                                          'mp4'
                                                      ? Colors.purple
                                                      : Colors.blue,
                                            ),
                                            const SizedBox(height: 4),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4),
                                              child: Text(
                                                arrayFiles[j].name,
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.black87),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                                Positioned(
                                  right: -6,
                                  top: -6,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        arrayFiles.removeAt(j);
                                        if (arrayFilesBytes.length > j) {
                                          arrayFilesBytes.removeAt(j);
                                        }
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: const Icon(Icons.close,
                                          size: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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
