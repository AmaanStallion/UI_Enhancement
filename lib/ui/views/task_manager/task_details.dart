import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_user_task_by_id.dart';
import 'package:stallion/models/tenant_payment_list.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/views/task_manager/complete_task_page.dart';
import 'package:stallion/ui/views/task_manager/extend_deadline_page.dart';
import 'package:stallion/ui/views/task_manager/task_remarks.dart';
import 'package:stallion/ui/views/task_manager/task_manager_mock_data.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:stallion/models/task_extend_details.dart';
import 'package:stallion/ui/widgets/row_three_text.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({
    super.key,
    this.towarId,
    this.projectId,
    this.projectName,
    this.towarName,
    required this.userTask,
    this.isFromMyTask = false,
  });
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final UserTask userTask;
  final bool? isFromMyTask;
  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class TaskDetailFile {
  final String id;
  final String fileName;
  final String viewUrl;

  TaskDetailFile({
    required this.id,
    required this.fileName,
    required this.viewUrl,
  });

  factory TaskDetailFile.fromJson(Map<String, dynamic> json) => TaskDetailFile(
        id: json['id']?.toString() ?? '',
        fileName: json['file_name']?.toString() ?? '',
        viewUrl: json['view_url']?.toString() ?? '',
      );
}

class TaskLogItem {
  final String id;
  final String action;
  final String? remarks;
  final String createdByName;
  final String createdAt;

  TaskLogItem({
    required this.id,
    required this.action,
    this.remarks,
    required this.createdByName,
    required this.createdAt,
  });

  factory TaskLogItem.fromJson(Map<String, dynamic> json) => TaskLogItem(
        id: json['id']?.toString() ?? '',
        action: json['action']?.toString() ?? '',
        remarks: json['remarks']?.toString(),
        createdByName: json['created_by_name']?.toString() ?? '',
        createdAt: json['created_at']?.toString() ?? '',
      );
}

class TaskExtendedHistoryItem {
  final String id;
  final String? oldDeadline;
  final String newDeadline;
  final String? remarks;
  final String extendedByName;
  final String createdAt;
  final List<TaskDetailFile> files;

  TaskExtendedHistoryItem({
    required this.id,
    this.oldDeadline,
    required this.newDeadline,
    this.remarks,
    required this.extendedByName,
    required this.createdAt,
    required this.files,
  });

  factory TaskExtendedHistoryItem.fromJson(Map<String, dynamic> json) =>
      TaskExtendedHistoryItem(
        id: json['id']?.toString() ?? '',
        oldDeadline: json['old_deadline']?.toString(),
        newDeadline: json['new_deadline']?.toString() ?? '',
        remarks: json['remarks']?.toString(),
        extendedByName: json['extended_by_name']?.toString() ?? '',
        createdAt: json['created_at']?.toString() ?? '',
        files: (json['files'] as List? ?? [])
            .map((f) => TaskDetailFile.fromJson(f as Map<String, dynamic>))
            .toList(),
      );
}

class TaskCompletionDetails {
  final String? remarks;
  final String completedByName;
  final String completedAt;
  final List<TaskDetailFile> files;

  TaskCompletionDetails({
    this.remarks,
    required this.completedByName,
    required this.completedAt,
    required this.files,
  });

  factory TaskCompletionDetails.fromJson(Map<String, dynamic> json) =>
      TaskCompletionDetails(
        remarks: json['remarks']?.toString(),
        completedByName: json['completed_by_name']?.toString() ?? '',
        completedAt: json['completed_at']?.toString() ?? '',
        files: (json['files'] as List? ?? [])
            .map((f) => TaskDetailFile.fromJson(f as Map<String, dynamic>))
            .toList(),
      );
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  List<PlatformFile> arrayFiles = [];
  List<Uint8List?> arrayFilesBytes = [];
  List<ExtendTaskDetail>? extendTaskDetails = [];
  List<TaskDetailFile> attachedFiles = [];
  List<TaskLogItem> taskLogs = [];
  List<TaskExtendedHistoryItem> taskExtendedHistory = [];
  TaskCompletionDetails? completionDetails;
  bool _isLoadingDetails = false;
  String? filePath = '';

  final TextEditingController _remarkController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  DateTime? extendDate;

  @override
  void initState() {
    super.initState();
    fetchTaskDetails();
    gettaskExtendDetails();
  }

  Future<void> fetchTaskDetails() async {
    final taskId = widget.userTask.taskId;
    if (taskId == null || taskId.isEmpty) return;

    if (TaskManagerMockData.useMockData) return;

    setState(() {
      _isLoadingDetails = true;
    });

    try {
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        await apiNetworkHandler.ensureProjectContext(widget.projectId);
      }

      var response =
          await apiNetworkHandler.get(AppUrl.getTaskDetails(taskId));
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          final data = decoded['data'];
          if (data is Map<String, dynamic>) {
            final rawFiles = data['files'] as List? ?? [];
            final List<TaskDetailFile> files = rawFiles
                .map((x) =>
                    TaskDetailFile.fromJson(x as Map<String, dynamic>))
                .toList();

            if (data['title'] != null) {
              widget.userTask.taskTitle = data['title'].toString();
            }
            if (data['assignor_name'] != null) {
              widget.userTask.assignBy = data['assignor_name'].toString();
            }
            if (data['assigned_to'] != null) {
              widget.userTask.assignTo = data['assigned_to'].toString();
            }
            String formatDisplayDate(dynamic raw) {
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

            if (data['deadline'] != null) {
              widget.userTask.taskDeadline = formatDisplayDate(data['deadline']);
            }
            if (data['assigned_on'] != null) {
              widget.userTask.taskCreateAt = formatDisplayDate(data['assigned_on']);
            }
            if (data['status'] != null) {
              String st = data['status'].toString().toLowerCase();
              widget.userTask.taskCompleteStatus =
                  (st == 'completed' || st == '1') ? '1' : '0';
            }

            final rawLogs = data['logs'] as List? ?? [];
            final List<TaskLogItem> parsedLogs = rawLogs
                .map((x) => TaskLogItem.fromJson(x as Map<String, dynamic>))
                .toList();

            final rawExtHistory = data['extended_history'] as List? ?? [];
            final List<TaskExtendedHistoryItem> parsedExtHistory = rawExtHistory
                .map((x) =>
                    TaskExtendedHistoryItem.fromJson(x as Map<String, dynamic>))
                .toList();

            TaskCompletionDetails? parsedCompletion;
            if (data['completion_details'] != null &&
                data['completion_details'] is Map<String, dynamic>) {
              parsedCompletion = TaskCompletionDetails.fromJson(
                  data['completion_details'] as Map<String, dynamic>);
            }

            setState(() {
              attachedFiles = files;
              taskLogs = parsedLogs;
              taskExtendedHistory = parsedExtHistory;
              completionDetails = parsedCompletion;
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("TaskDetailsScreen: Error fetching task details: $e");
      }
    } finally {
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }

  Future<List<dynamic>?> gettaskExtendDetails() async {
    if (AppUrl.useNewBackend) return null;
    if (TaskManagerMockData.useMockData) {
      setState(() {
        extendTaskDetails = TaskManagerMockData.getMockTaskRemarks(widget.userTask.taskId);
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
        "task_id": widget.userTask.taskId ?? ''
      };

      var response =
          await apiNetworkHandler.post(AppUrl.taskExtendDetails, data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = taskExtendDetailsFromJson(response.body);
        if (dataModel.response?.errorCode == "0") {
          setState(() {
            extendTaskDetails = dataModel.response?.extendTaskDetails;
            filePath = dataModel.response?.filePath;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
    }
    return null;
  }

  viewDocumentsModal(
      {required List<Document>? documents, required String? filePath}) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              titlePadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: const Text(
                  "SELECT DOCUMENT",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              content: SizedBox(
                height: 300,
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.start,
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          for (int i = 0; i < documents!.length; i++)
                            InkWell(
                              onTap: () async {
                                if (documents[i]
                                    .documentName!
                                    .contains('.pdf')) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return PdfViewer(
                                          isLocalFileUpload: false,
                                          fileName: documents[i].documentName,
                                          fileUrl:
                                              "$filePath${documents[i].documentName}",
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return ImagePreviewViewer(
                                          fileName: documents[i].documentName,
                                          fileUrl:
                                              "$filePath${documents[i].documentName}",
                                        );
                                      },
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Image.asset(
                                  documents[i]
                                          .documentName!
                                          .contains('.pdf')
                                      ? 'images/projectmanagement/pdf.png'
                                      : 'images/projectmanagement/img.png',
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Text(
                      "Okay",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          });
        });
  }

  Future<List<TenantPaymentListElement>?> extendDeadLine(
      {required DateTime dataa}) async {
    if (TaskManagerMockData.useMockData) {
      widget.userTask.taskDeadline = DateFormat('dd-MM-yyyy').format(dataa);
      Navigator.of(context).pop();
      if (widget.isFromMyTask == false) {
        Navigator.of(context).pop();
      }
      return null;
    }
    String formatDate(DateTime dateTime) {
      return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
    }

    try {
      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "extend_date": formatDate(dataa),
        "task_id": widget.userTask.taskId ?? '',
      };

      var response = await apiNetworkHandler.post(AppUrl.taskExtendDate, data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.of(context).pop();

        if (widget.isFromMyTask == false) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
    } finally {}
    return null;
  }

  Future<List<TenantPaymentListElement>?> markTaskComplete() async {
    if (TaskManagerMockData.useMockData) {
      setState(() {
        widget.userTask.taskCompleteStatus = '1';
      });
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text(
                      "Okay",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          });
      return null;
    }
    CustomLoading.progressDialog(isLoading: true, context: context);
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    var request =
        http.MultipartRequest('POST', Uri.parse(AppUrl.taskCompletedByUser));

    request.headers.addAll({'Content-Type': 'multipart/form-data'});
    request.fields['user_id'] = userId ?? '';
    request.fields['task_id'] = widget.userTask.taskId ?? '';
    request.fields['task_remark'] = _remarkController.text;
    request.fields['task_status'] = '1';

    for (int i = 0; i < arrayFiles.length; i++) {
      PlatformFile file = arrayFiles[i];
      request.files.add(await http.MultipartFile.fromPath(
        "task_document[]",
        file.path.toString(),
        contentType: MediaType('application/pdf', file.extension ?? ""),
      ));
    }

    var response = await request.send();
    var responsed = await http.Response.fromStream(response);
    final responseData = json.decode(responsed.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      CustomLoading.progressDialog(isLoading: false, context: context);
      showDialog<void>(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              actionsPadding:
                  const EdgeInsets.only(bottom: 10, left: 10, right: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: const Text(
                "Task Completed Successfully.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    if (widget.isFromMyTask == false) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Text(
                      "Okay",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          });
      return null;
    } else {
      return null;
    }

    //   String formatDate(DateTime dateTime) {
    //     return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    //   }

    //   try {
    //     // CustomLoading.progressDialog(isLoading: true, context: context);

    //     final SharedPreferences prefs = await _prefs;
    //     String? userId = prefs.getString('mobileNo');

    //     Map<String, String> data = {
    //       "user_id": userId ?? '',
    //       "task_id": widget.userTask.taskId ?? '',
    //       'task_remark': _remarkController.text,
    //       "task_status": '1',
    //       // "project_id": widget.projectId ?? '',
    //       // "towar_id": widget.towarId ?? '',
    //     };

    //     if (kDebugMode) {
    //       print(data);
    //     }

    //     var response =
    //         await apiNetworkHandler.post(AppUrl.taskCompletedByUser, data);

    //     if (kDebugMode) {
    //       print(response.statusCode);
    //     }

    //     if (response.statusCode == 200 || response.statusCode == 201) {
    //       // ignore: use_build_context_synchronously
    //       showDialog<void>(
    //           barrierDismissible: true,
    //           context: context,
    //           builder: (context) {
    //             return AlertDialog(
    //               shape: RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(8), // Set radius to zero
    //               ),
    //               titlePadding:
    //                   const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    //               actionsPadding:
    //                   const EdgeInsets.only(bottom: 10, left: 10, right: 10),
    //               contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    //               actionsAlignment: MainAxisAlignment.center,
    //               title: const Text(
    //                 "Task Completed Successfully.",
    //                 style: TextStyle(
    //                   fontSize: 16,
    //                   fontWeight: FontWeight.w600,
    //                 ),
    //                 textAlign: TextAlign.center,
    //               ),
    //               actions: [
    //                 InkWell(
    //                   onTap: () {
    //                     Navigator.of(context).pop();

    //                     Navigator.of(context).pop();
    //                   },
    //                   child: Container(
    //                     width: 250,
    //                     padding: const EdgeInsets.symmetric(vertical: 4),
    //                     decoration: BoxDecoration(
    //                         color: Colors.black,
    //                         borderRadius: BorderRadius.circular(7)),
    //                     child: const Text(
    //                       "Okay",
    //                       style: TextStyle(
    //                         fontSize: 16,
    //                         fontWeight: FontWeight.w600,
    //                         color: Colors.white,
    //                       ),
    //                       textAlign: TextAlign.center,
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             );
    //           });
    //     } else {
    //       // Handle error for non-200/201 status codes
    //     }
    //   } catch (e) {
    //     if (kDebugMode) {
    //       print('Exception occurred: $e');
    //     }
    //     // Handle exceptions here if needed
    //     // throw SomeCustomException('Exception occurred: $e');
    //   } finally {
    //     // ignore: use_build_context_synchronously
    //     // CustomLoading.progressDialog(isLoading: false, context: context);
    //   }
    //   return null;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return Scaffold(
      bottomNavigationBar: Container(
        child: widget.userTask.taskCompleteStatus != '1'
            ? Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CompleteTaskPage(
                              userTask: widget.userTask,
                              projectId: widget.projectId,
                              towarId: widget.towarId ?? '',
                              projectName: widget.projectName,
                              towarName: widget.towarName ?? '',
                              isFromMyTask: widget.isFromMyTask ?? false,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12),
                        margin: EdgeInsets.symmetric(
                            horizontal: isMobile ? 6 : 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          "COMPLETE TASK",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 13 : 15,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExtendDeadlinePage(
                              userTask: widget.userTask,
                              projectId: widget.projectId,
                              towarId: widget.towarId ?? '',
                              projectName: widget.projectName,
                              towarName: widget.towarName!,
                              isFromMyTask: widget.isFromMyTask ?? false,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12),
                        margin: EdgeInsets.symmetric(
                            horizontal: isMobile ? 6 : 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          "EXTEND DEADLINE",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 13 : 15,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
                margin: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 24, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  "TASK COMPLETED",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: isMobile ? 13 : 15,
                      fontWeight: FontWeight.w600),
                ),
              ),
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            widget.towarName!.isNotEmpty
                ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                : widget.projectName!.toUpperCase(),
            style: TextStyle(
                fontStyle: FontStyle.normal,
                fontSize: isMobile ? 14.0 : 17.0)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.maxFinite,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: AppText(
              title: "TASK DETAILS",
              fontSize: isMobile ? 15 : 17,
              fontWeight: FontWeight.w700,
              titleTextAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
            // 1. Assignor & Deadline Top Card
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 24, vertical: 6),
              padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 12 : 16, horizontal: isMobile ? 12 : 16),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        'Assignor',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: isMobile ? 13 : 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.userTask.assignBy ?? '',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: isMobile ? 15 : 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.userTask.taskCreateAt ?? '',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 50,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  Column(
                    children: [
                      Text(
                        'Deadline',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: isMobile ? 13 : 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.userTask.taskDeadline ?? '',
                        style: TextStyle(
                          color: widget.userTask.taskDeadlineStatus == '1'
                              ? Colors.red
                              : Colors.black,
                          fontSize: isMobile ? 15 : 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 2. Task Assigned Label
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16.0 : 24.0),
              child: Text(
                'Task Assigned',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // 3. Task Name Card (below Task Assigned label)
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 24, vertical: 4),
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 14),
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
              child: Text(
                widget.userTask.taskTitle ?? '',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (_isLoadingDetails)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                    child: CircularProgressIndicator(color: Colors.black)),
              )
            else if (attachedFiles.isNotEmpty)
              _buildAttachedFilesSection(isMobile),
            const SizedBox(height: 12),

            // 4. Task Completed Label + View Remarks Button (in the SAME line)
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16.0 : 24.0),
              child: Row(
                children: [
                  Text(
                    widget.userTask.taskCompleteStatus == '1'
                        ? 'Task Completed'
                        : 'Task Completed',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskRemarks(
                            userTask: widget.userTask,
                            projectId: widget.projectId,
                            towarId: widget.towarId ?? '',
                            projectName: widget.projectName,
                            towarName: widget.towarName!,
                            isFromMyTask: widget.isFromMyTask ?? false,
                            taskTaskId: widget.userTask.taskId,
                            taskExtendedHistory: taskExtendedHistory,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16, vertical: 4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black54)),
                      child: Text(
                        'View Remarks',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: isMobile ? 12 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 5. Vertical History Graph (below Task Completed header & View Remarks)
            _buildTimelineGraph(isMobile),
            if (completionDetails != null)
              _buildCompletionDetailsSection(isMobile),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  ],
),
    );
  }

  Widget _buildTimelineGraph(bool isMobile) {
    List<Map<String, String>> timelineItems = [];

    String formatDisplayDate(dynamic raw) {
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

    if (taskExtendedHistory.isNotEmpty) {
      final firstItem = taskExtendedHistory.first;
      String origDate = formatDisplayDate(firstItem.oldDeadline ?? widget.userTask.taskDeadline);
      timelineItems.add({
        "date": origDate,
        "info": "Original Deadline by ${widget.userTask.assignBy ?? ''}",
      });

      for (final item in taskExtendedHistory) {
        String extDate = formatDisplayDate(item.newDeadline);
        String info = "Extended Deadline by ${item.extendedByName}";
        timelineItems.add({
          "date": extDate,
          "info": info,
        });
      }
    } else if (extendTaskDetails != null && extendTaskDetails!.isNotEmpty) {
      for (int i = 0; i < extendTaskDetails!.length; i++) {
        final item = extendTaskDetails![i];
        final isOriginal = (i == 0);
        final labelType = isOriginal ? "Original Deadline by" : "Extended Deadline by";
        final dateStr = formatDisplayDate(item.taskExtendDate ?? item.createdDate);
        final person = (item.extendedBy ?? '').isNotEmpty
            ? item.extendedBy!
            : (widget.userTask.assignBy ?? '');
        timelineItems.add({
          "date": dateStr,
          "info": "$labelType $person",
        });
      }
    } else {
      timelineItems.add({
        "date": widget.userTask.taskDeadline ?? '',
        "info": "Original Deadline by ${widget.userTask.assignBy ?? ''}",
      });
    }

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 24, vertical: 8),
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16, vertical: isMobile ? 8 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < timelineItems.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                  child: Column(
                    children: [
                      Container(
                        width: 2,
                        height: i == 0 ? 0 : 4,
                        color: i == 0 ? Colors.transparent : Colors.grey.shade500,
                      ),
                      Container(
                        height: 20,
                        width: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: const Icon(
                          Icons.clear,
                          color: Colors.white,
                          size: 13,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: i == timelineItems.length - 1 ? 0 : 28,
                        color: i == timelineItems.length - 1 ? Colors.transparent : Colors.grey.shade500,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      '${timelineItems[i]["date"]}  -  ${timelineItems[i]["info"]}',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachedFilesSection(bool isMobile) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 24, vertical: 4),
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 12),
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
          Row(
            children: [
              Icon(Icons.attach_file,
                  size: isMobile ? 16 : 18, color: Colors.grey.shade700),
              const SizedBox(width: 6),
              Text(
                'Attached Files',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: attachedFiles.length,
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final file = attachedFiles[index];
              final isPdf = file.fileName.toLowerCase().endsWith('.pdf');
              final isImage = file.fileName.toLowerCase().endsWith('.png') ||
                  file.fileName.toLowerCase().endsWith('.jpg') ||
                  file.fileName.toLowerCase().endsWith('.jpeg');

              return InkWell(
                onTap: () async {
                  if (file.viewUrl.isEmpty) return;
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
                    final Uri uri = Uri.parse(file.viewUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xfff8f9fa),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xffe9ecef)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPdf
                            ? Icons.picture_as_pdf
                            : (isImage
                                ? Icons.image
                                : Icons.insert_drive_file),
                        color: isPdf
                            ? Colors.red
                            : (isImage ? Colors.blue : Colors.grey.shade700),
                        size: isMobile ? 18 : 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          file.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.visibility_outlined,
                        size: isMobile ? 16 : 18,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionDetailsSection(bool isMobile) {
    if (completionDetails == null) return const SizedBox.shrink();

    String formatDisplayDate(dynamic raw) {
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

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 24, vertical: 8),
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16, vertical: isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: const Color(0xfff8f9fa),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
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
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Task Completion Details',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          rowThreeText(
            context: context,
            title: "Completed By",
            titleValue: completionDetails!.completedByName,
            titleWidth: isMobile ? 115.0 : 130.0,
          ),
          rowThreeText(
            context: context,
            title: "Completed Date",
            titleValue: formatDisplayDate(completionDetails!.completedAt),
            titleWidth: isMobile ? 115.0 : 130.0,
          ),
          if (completionDetails!.remarks != null &&
              completionDetails!.remarks!.isNotEmpty)
            rowThreeText(
              context: context,
              title: "Remarks",
              titleValue: completionDetails!.remarks!,
              titleWidth: isMobile ? 115.0 : 130.0,
            ),
          if (completionDetails!.files.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Completion Attached Documents',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: completionDetails!.files.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final file = completionDetails!.files[index];
                final isPdf = file.fileName.toLowerCase().endsWith('.pdf');
                final isImage = file.fileName.toLowerCase().endsWith('.png') ||
                    file.fileName.toLowerCase().endsWith('.jpg') ||
                    file.fileName.toLowerCase().endsWith('.jpeg');

                return InkWell(
                  onTap: () async {
                    if (file.viewUrl.isEmpty) return;
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
                      final Uri uri = Uri.parse(file.viewUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xffe9ecef)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPdf
                              ? Icons.picture_as_pdf
                              : (isImage
                                  ? Icons.image
                                  : Icons.insert_drive_file),
                          color: isPdf
                              ? Colors.red
                              : (isImage ? Colors.blue : Colors.grey.shade700),
                          size: isMobile ? 18 : 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            file.fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.visibility_outlined,
                          size: isMobile ? 16 : 18,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
