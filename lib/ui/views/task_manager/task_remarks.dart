import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_user_task_by_id.dart';
import 'package:stallion/models/task_extend_details.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/views/task_manager/task_details.dart';
import 'package:stallion/ui/views/task_manager/task_manager_mock_data.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/ui/widgets/row_three_text.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskRemarks extends StatefulWidget {
  const TaskRemarks({
    super.key,
    this.towarId,
    this.projectId,
    this.projectName,
    this.towarName,
    required this.userTask,
    this.isFromMyTask = false,
    required this.taskTaskId,
    this.taskExtendedHistory,
  });
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? taskTaskId;

  final UserTask userTask;
  final bool? isFromMyTask;
  final List<TaskExtendedHistoryItem>? taskExtendedHistory;

  @override
  State<TaskRemarks> createState() => _TaskRemarksState();
}

class _TaskRemarksState extends State<TaskRemarks> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<ExtendTaskDetail>? extendTaskDetails = [];

  String? filePath = '';

  String _formatDisplayDate(dynamic raw) {
    if (raw == null) return '';
    String s = raw.toString().trim();
    try {
      DateTime? dt = DateTime.tryParse(s);
      if (dt != null) return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {}
    if (s.contains('-')) {
      List<String> p = s.split('T')[0].split('-');
      if (p.length == 3 && p[0].length == 4) return '${p[2]}/${p[1]}/${p[0]}';
    }
    return s;
  }

  Future<List<dynamic>?> gettaskExtendDetails() async {
    if (AppUrl.useNewBackend) return null;
    if (TaskManagerMockData.useMockData) {
      setState(() {
        extendTaskDetails = TaskManagerMockData.getMockTaskRemarks(widget.taskTaskId);
        filePath = "https://example.com/documents/";
      });
      return null;
    }
    try {
      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "towar_id": widget.towarId ?? '',
        "project_id": widget.projectId ?? '',
        "task_id": widget.taskTaskId ?? ''
      };

      if (kDebugMode) {
        print(data);
      }

      var response =
          await apiNetworkHandler.post(AppUrl.taskExtendDetails, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = taskExtendDetailsFromJson(response.body);
        if (dataModel.response?.errorCode == "0") {
          setState(() {
            extendTaskDetails = dataModel.response?.extendTaskDetails;
            filePath = dataModel.response?.filePath;
          });
        }
      } else {}
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
    } finally {}
    return null;
  }

  @override
  void initState() {
    super.initState();
    gettaskExtendDetails();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return Scaffold(
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
                fontSize: isMobile ? 14.0 : 17.0)),
      ),
      body: _buildBodyContent(context, isMobile),
    );
  }

  Widget _buildBodyContent(BuildContext context, bool isMobile) {
    final hasNewHistory = widget.taskExtendedHistory != null &&
        widget.taskExtendedHistory!.isNotEmpty;

    return Column(
      children: [
        const SizedBox(height: 8),
        SizedBox(
          width: double.maxFinite,
          child: AppText(
            title: "Extension History",
            fontSize: isMobile ? 15 : 17,
            fontWeight: FontWeight.w700,
            titleTextAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: hasNewHistory
              ? ListView.separated(
                  itemBuilder: (context, index) {
                    final temp = widget.taskExtendedHistory![index];
                    return Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 24,
                          vertical: isMobile ? 2 : 3),
                      padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: isMobile ? 10 : 14),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          rowThreeText(
                            context: context,
                            title: "New Deadline",
                            titleValue: _formatDisplayDate(temp.newDeadline),
                            buttonText:
                                (temp.files.isNotEmpty) ? "View Docs" : null,
                            onTapButton: () {
                              if (temp.files.isNotEmpty) {
                                viewTaskDetailFilesModal(temp.files);
                              }
                            },
                          ),
                          if (temp.oldDeadline != null &&
                              temp.oldDeadline!.isNotEmpty)
                            rowThreeText(
                              context: context,
                              title: "Old Deadline",
                              titleValue:
                                  _formatDisplayDate(temp.oldDeadline),
                            ),
                          rowThreeText(
                            context: context,
                            title: "Extended By",
                            titleValue: temp.extendedByName,
                          ),
                          rowThreeText(
                            context: context,
                            title: "Remarks",
                            titleValue: temp.remarks ?? '',
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 2),
                  itemCount: widget.taskExtendedHistory!.length,
                  shrinkWrap: true,
                )
              : ListView.separated(
                  itemBuilder: (context, index) {
                    ExtendTaskDetail? temp = extendTaskDetails != null &&
                            extendTaskDetails!.isNotEmpty
                        ? extendTaskDetails![index]
                        : null;
                    return Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 24,
                          vertical: isMobile ? 2 : 3),
                      padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: isMobile ? 10 : 14),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          rowThreeText(
                            context: context,
                            title: "Extended Date",
                            titleValue:
                                _formatDisplayDate(temp?.taskExtendDate),
                            buttonText: (temp?.documents != null &&
                                    temp!.documents!.isNotEmpty)
                                ? "View Docs"
                                : null,
                            onTapButton: () {
                              if (temp?.documents != null &&
                                  temp!.documents!.isNotEmpty) {
                                viewDocumentsModal(
                                    documents: temp!.documents,
                                    filePath: filePath);
                              }
                            },
                          ),
                          rowThreeText(
                            context: context,
                            title: "Extended By",
                            titleValue: temp?.extendedBy ?? '',
                          ),
                          rowThreeText(
                            context: context,
                            title: "Remarks",
                            titleValue: temp?.taskExtendRemak ?? '',
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 2),
                  itemCount: extendTaskDetails?.length ?? 0,
                  shrinkWrap: true,
                ),
        ),
      ],
    );
  }

  viewTaskDetailFilesModal(List<TaskDetailFile> files) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            titlePadding: EdgeInsets.zero,
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            contentPadding: const EdgeInsets.all(16),
            actionsAlignment: MainAxisAlignment.center,
            title: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: const Text(
                "ATTACHED DOCUMENTS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            actions: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    "CLOSE",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
            content: SizedBox(
              height: 280,
              width: 440,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (int i = 0; i < files.length; i++)
                      InkWell(
                        onTap: () async {
                          final file = files[i];
                          if (file.viewUrl.isEmpty) return;
                          final isPdf =
                              file.fileName.toLowerCase().endsWith('.pdf');
                          final isImage =
                              file.fileName.toLowerCase().endsWith('.png') ||
                                  file.fileName.toLowerCase().endsWith('.jpg') ||
                                  file.fileName.toLowerCase().endsWith('.jpeg');
                          if (isPdf) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PdfViewer(
                                  isLocalFileUpload: false,
                                  fileName: file.fileName,
                                  fileUrl: file.viewUrl,
                                ),
                              ),
                            );
                          } else if (isImage) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ImagePreviewViewer(
                                  fileName: file.fileName,
                                  fileUrl: file.viewUrl,
                                ),
                              ),
                            );
                          } else {
                            final uri = Uri.parse(file.viewUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          }
                        },
                        child: Container(
                          width: 120,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                files[i]
                                        .fileName
                                        .toLowerCase()
                                        .endsWith('.pdf')
                                    ? Icons.picture_as_pdf
                                    : Icons.insert_drive_file,
                                color: files[i]
                                        .fileName
                                        .toLowerCase()
                                        .endsWith('.pdf')
                                    ? Colors.red
                                    : Colors.blue,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                files[i].fileName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  viewDocumentsModal(
      {required List<Document>? documents, required String? filePath}) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: EdgeInsets.zero,
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              contentPadding: const EdgeInsets.all(16),
              actionsAlignment: MainAxisAlignment.center,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: const Text(
                  "ATTACHED DOCUMENTS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: [
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Text(
                      "CLOSE",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
              content: SizedBox(
                height: 280,
                width: 440,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (int i = 0; i < (documents?.length ?? 0); i++)
                        InkWell(
                          onTap: () async {
                            final docName = documents![i].documentName ?? '';
                            if (docName.contains('.pdf')) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PdfViewer(
                                    fileName: '$filePath/$docName',
                                    fileUrl: '$filePath/$docName',
                                  ),
                                ),
                              );
                            } else if (docName.contains('.mp4')) {
                              final uri = Uri.parse('$filePath/$docName');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ImagePreviewViewer(
                                    fileName: docName,
                                    fileUrl: '$filePath/$docName',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 120,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 70,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: (documents![i].documentName ?? '').contains('.pdf')
                                      ? Image.asset(
                                          'images/projectmanagement/pdf.png',
                                          height: 55,
                                          fit: BoxFit.contain,
                                        )
                                      : (documents![i].documentName ?? '').contains('.mp4')
                                          ? const Icon(
                                              Icons.video_camera_back,
                                              size: 50,
                                              color: Colors.black87,
                                            )
                                          : Image.network(
                                              '$filePath/${documents![i].documentName}',
                                              height: 65,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(Icons.insert_drive_file, size: 45, color: Colors.grey),
                                            ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  documents![i].documentName ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
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
            );
          });
        });
  }
}
