// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_all_members_by_project.dart';
import 'package:stallion/models/get_meeting_id.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/task_manager/task_manager_mock_data.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';

class AssignMeeting extends StatefulWidget {
  AssignMeeting({
    super.key,
    this.towarId,
    this.projectId,
    this.projectName,
    this.towarName,
    required this.memberDetailsRes,
    required this.mettingTilte,
    required this.isFromCreateNewMeeting,
    this.dataa,
  });
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? mettingTilte;
  final MettingDatum? dataa;
  final bool isFromCreateNewMeeting;
  List<MemberDetail>? memberDetailsRes = [];

  @override
  State<AssignMeeting> createState() => _AssignMeetingState();
}

class _AssignMeetingState extends State<AssignMeeting> {
  // List<MemberDetail>? memberDetailsRes = [];
  List<MemberDetail>? selectedMember = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _deadlineDateController = TextEditingController();
  DateTime? deadlineDateSelect;
  final TextEditingController _participantsController = TextEditingController();
  List<PlatformFile>? arrayFiles = [];
  List<Uint8List?>? arrayFilesBytes = [];
  String participantsNumberSelected = '';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  assignAddTask() async {
    if (TaskManagerMockData.useMockData) {
      showDialog<void>(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Task Assigned Successfully.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("Okay", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            );
          });
      return null;
    }

    CustomLoading.progressDialog(isLoading: true, context: context);

    try {
      if (AppUrl.useNewBackend) {
        if (widget.projectId != null && widget.projectId!.isNotEmpty) {
          await apiNetworkHandler.ensureProjectContext(widget.projectId);
        }

        final prefs = await _prefs;
        final projectToken = prefs.getString('projectToken') ??
            prefs.getString('masterToken') ??
            prefs.getString('token');

        String targetMeetingId = widget.dataa?.mettingId ?? '';

        if (widget.isFromCreateNewMeeting) {
          final towerId = widget.towarId;
          if (towerId == null || towerId.isEmpty) {
            CustomLoading.progressDialog(isLoading: false, context: context);
            return null;
          }

          var createMeetingReq = http.MultipartRequest(
            'POST',
            Uri.parse(AppUrl.createTowerMeeting(towerId)),
          );

          if (projectToken != null && projectToken.isNotEmpty) {
            createMeetingReq.headers['Authorization'] = 'Bearer $projectToken';
          }

          createMeetingReq.fields['title'] = widget.mettingTilte ?? '';

          List<dynamic> meetingParticipantIds = [];
          if (widget.memberDetailsRes != null && widget.memberDetailsRes!.isNotEmpty) {
            for (var m in widget.memberDetailsRes!) {
              if (m.memberId != null && m.memberId!.isNotEmpty) {
                final parsedInt = int.tryParse(m.memberId!);
                if (parsedInt != null) {
                  meetingParticipantIds.add(parsedInt);
                } else {
                  meetingParticipantIds.add(m.memberId!);
                }
              }
            }
          }
          createMeetingReq.fields['participants'] = jsonEncode(meetingParticipantIds);

          if (kDebugMode) {
            print("🚀 [AssignMeeting] Sending POST createTowerMeeting:");
            print("   URL: ${AppUrl.createTowerMeeting(towerId)}");
            print("   Fields: ${createMeetingReq.fields}");
          }

          var meetingRes = await createMeetingReq.send();
          var meetingResBody = await http.Response.fromStream(meetingRes);
          if (kDebugMode) {
            print("📥 [AssignMeeting] createMeeting Status: ${meetingRes.statusCode}");
            print("   Body: ${meetingResBody.body}");
          }

          if (meetingRes.statusCode == 200 || meetingRes.statusCode == 201) {
            final decodedMeeting = json.decode(meetingResBody.body);
            if (decodedMeeting is Map<String, dynamic> && decodedMeeting['data'] != null) {
              final data = decodedMeeting['data'];
              if (data is Map<String, dynamic>) {
                targetMeetingId = data['id']?.toString() ?? '';
              } else {
                targetMeetingId = data.toString();
              }
            }
          } else {
            CustomLoading.progressDialog(isLoading: false, context: context);
            if (kDebugMode) {
              print("❌ [AssignMeeting] Failed to create meeting before adding task.");
            }
            return null;
          }
        }

        if (targetMeetingId.isEmpty) {
          CustomLoading.progressDialog(isLoading: false, context: context);
          if (kDebugMode) {
            print("❌ [AssignMeeting] Empty targetMeetingId, aborting task creation.");
          }
          return null;
        }

        var addTaskReq = http.MultipartRequest(
          'POST',
          Uri.parse(AppUrl.addTaskToMeeting(targetMeetingId)),
        );

        if (projectToken != null && projectToken.isNotEmpty) {
          addTaskReq.headers['Authorization'] = 'Bearer $projectToken';
        }

        String formattedDeadline = '';
        if (deadlineDateSelect != null) {
          formattedDeadline = DateFormat('yyyy-MM-dd').format(deadlineDateSelect!);
        } else if (_deadlineDateController.text.contains('/')) {
          List<String> parts = _deadlineDateController.text.split('/');
          if (parts.length == 3) {
            formattedDeadline = '${parts[2]}-${parts[1]}-${parts[0]}';
          }
        } else {
          formattedDeadline = _deadlineDateController.text;
        }

        addTaskReq.fields['description'] = _taskController.text;
        addTaskReq.fields['deadline'] = formattedDeadline;

        List<dynamic> taskParticipantIds = [];
        if (selectedMember != null && selectedMember!.isNotEmpty) {
          for (var m in selectedMember!) {
            if (m.memberId != null && m.memberId!.isNotEmpty) {
              final parsedInt = int.tryParse(m.memberId!);
              if (parsedInt != null) {
                taskParticipantIds.add(parsedInt);
              } else {
                taskParticipantIds.add(m.memberId!);
              }
            }
          }
        }
        addTaskReq.fields['participants'] = jsonEncode(taskParticipantIds);

        if (arrayFiles != null && arrayFiles!.isNotEmpty) {
          for (int i = 0; i < arrayFiles!.length; i++) {
            PlatformFile file = arrayFiles![i];
            if (file.path != null && file.path!.isNotEmpty) {
              addTaskReq.files.add(
                await http.MultipartFile.fromPath(
                  'files',
                  file.path!,
                  contentType: MediaType(
                      'application', file.extension == 'pdf' ? 'pdf' : 'octet-stream'),
                ),
              );
            }
          }
        }

        if (kDebugMode) {
          print("🚀 [AssignMeeting] Sending POST addTaskToMeeting:");
          print("   URL: ${AppUrl.addTaskToMeeting(targetMeetingId)}");
          print("   Fields: ${addTaskReq.fields}");
        }

        var taskRes = await addTaskReq.send();
        var taskResBody = await http.Response.fromStream(taskRes);
        if (kDebugMode) {
          print("📥 [AssignMeeting] addTaskToMeeting Status: ${taskRes.statusCode}");
          print("   Body: ${taskResBody.body}");
        }

        CustomLoading.progressDialog(isLoading: false, context: context);

        if (taskRes.statusCode == 200 || taskRes.statusCode == 201) {
          showDialog<void>(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  titlePadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  actionsPadding:
                      const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  actionsAlignment: MainAxisAlignment.center,
                  title: Text(
                    widget.isFromCreateNewMeeting
                        ? "Meeting & Task Created Successfully."
                        : "Assigned Task Successfully.",
                    style: const TextStyle(
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
                        if (widget.isFromCreateNewMeeting) {
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
        }
      }
    } catch (e) {
      CustomLoading.progressDialog(isLoading: false, context: context);
      if (kDebugMode) {
        print("❌ [AssignMeeting] Error assigning meeting/task: $e");
      }
    }
  }

  assignTask() async {
    //
    CustomLoading.progressDialog(isLoading: true, context: context);

    String formatDate(DateTime dateTime) {
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    }

    var request =
        // http.MultipartRequest('POST', Uri.parse(AppUrl.addNewTaskByMeeting));
        http.MultipartRequest('POST', Uri.parse(AppUrl.createNewMetting));

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
    });

    String tempid = "";
    for (int k = 0; k < widget.memberDetailsRes!.length; k++) {
      if (tempid == "") {
        tempid = widget.memberDetailsRes?[k].memberId ?? '';
      } else {
        tempid = '$tempid,${widget.memberDetailsRes?[k].memberId}';
      }
    }
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    List dataa = [];
    String temppp = widget.dataa?.mettingId.toString() ?? '0';
    var trmp = {
      "assign_name": _participantsController.text,
      "deadline": formatDate(deadlineDateSelect!),
      "assign_to": participantsNumberSelected,
      "task_name": _taskController.text,
      "towar_id": widget.towarId,
      "project_id": widget.projectId,
    };
    dataa.add(trmp);
    if (kDebugMode) {
      print(jsonEncode(dataa));
    }
    print('${widget.dataa?.mettingId} ------------===');
    request.fields['user_id'] = userId ?? '';
    request.fields['project_id'] = widget.projectId ?? '';
    request.fields['towar_id'] = widget.towarId ?? '';
    request.fields['metting_tilte'] = widget.mettingTilte ?? '';
    request.fields['task_details_json'] = jsonEncode(dataa);
    request.fields['partician_details'] = tempid;
    request.fields['metting_create'] = formatDate(DateTime.now());
    request.fields['metting_id'] = temppp;
    for (int i = 0; i < arrayFiles!.length; i++) {
      PlatformFile file = arrayFiles![i];
      request.files.add(
        await http.MultipartFile.fromPath(
          "task_image[$i][]",
          file.path.toString(),
          contentType: MediaType('application/pdf', file.extension ?? ""),
        ),
      );
    }
    print(request.fields);
    var response = await request.send();
    var responsed = await http.Response.fromStream(response);
    final responseData = json.decode(responsed.body);
    CustomLoading.progressDialog(isLoading: false, context: context);
    // if (response.statusCode == 200 || responsed.body.isNotEmpty) {
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
              "Assigned Task Successfully.",
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
    return null;
    // } else {
    //   if (kDebugMode) {
    //     print("ERROR");
    //   }
    // }
  }

  @override
  void initState() {
    for (int k = 0; k < widget.memberDetailsRes!.length; k++) {
      setState(() {
        widget.memberDetailsRes?[k].isSelected = false;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return Scaffold(
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 24, vertical: 8),
        child: InkWell(
          onTap: () async {
            if (_formKey.currentState!.validate()) {
              showDialog<void>(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      titlePadding:
                          const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      actionsPadding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      actionsAlignment: MainAxisAlignment.center,
                      title: const Text(
                        "Are you sure you want to assign this task?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black54),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: const Text(
                                    "No",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  assignAddTask();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: const Text(
                                    'Yes',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  });
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
              "ASSIGN",
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
            widget.towarName!.isNotEmpty
                ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                : widget.projectName!.toUpperCase(),
            style: TextStyle(
                fontStyle: FontStyle.normal,
                fontSize: isMobile ? 14.0 : 17.0)),
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
              title: "ADD TASK",
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
                  // Deadline Date Row
                  Row(
                    children: [
                      SizedBox(
                        width: labelWidth,
                        child: Text(
                          'Deadline',
                          style: TextStyle(fontSize: fontSize, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Center(child: Icon(Icons.remove, size: isMobile ? 12 : 16, color: Colors.black54)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            DateTime? newDateTime = await showDatePicker(
                              context: context,
                              initialDate:
                                  deadlineDateSelect ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(DateTime.now().year + 20),
                            );
                            if (newDateTime != null) {
                              setState(() {
                                deadlineDateSelect = newDateTime;
                                _deadlineDateController.text =
                                    DateFormat('dd MM yyyy')
                                        .format(newDateTime);
                              });
                            }
                          },
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "(Deadline Cannot be Empty)";
                              }
                              return null;
                            },
                            enabled: false,
                            readOnly: true,
                            controller: _deadlineDateController,
                            style: TextStyle(color: Colors.black, fontSize: fontSize),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.black54),
                              ),
                              hintText: 'Select Deadline Date',
                              hintStyle: TextStyle(fontSize: fontSize, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Assign To Row
                  Row(
                    children: [
                      SizedBox(
                        width: labelWidth,
                        child: Text(
                          'Assign To',
                          style: TextStyle(fontSize: fontSize, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Center(child: Icon(Icons.remove, size: isMobile ? 12 : 16, color: Colors.black54)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            customShowUpdateDialog();
                          },
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "(Please Select Participants)";
                              }
                              return null;
                            },
                            enabled: false,
                            readOnly: true,
                            controller: _participantsController,
                            style: TextStyle(color: Colors.black, fontSize: fontSize),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.black54),
                              ),
                              hintText: 'Select Participants',
                              hintStyle: TextStyle(fontSize: fontSize, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Task Name Row
                  Row(
                    children: [
                      SizedBox(
                        width: labelWidth,
                        child: Text(
                          'Task',
                          style: TextStyle(fontSize: fontSize, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Center(child: Icon(Icons.remove, size: isMobile ? 12 : 16, color: Colors.black54)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "(Please Enter Task)";
                            }
                            return null;
                          },
                          controller: _taskController,
                          style: TextStyle(color: Colors.black, fontSize: fontSize),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.black54),
                            ),
                            hintText: 'Write Task Here...',
                            hintStyle: TextStyle(fontSize: fontSize, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Add Files Section
                  Text(
                    "Add Files",
                    style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: Colors.black),
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
                                'txt'
                              ],
                            );
                            if (result != null) {
                              PlatformFile file = result.files.first;
                              Uint8List? fileBytes = result.files.first.bytes;
                              setState(() {
                                arrayFilesBytes?.add(fileBytes);
                                arrayFiles?.add(file);
                              });
                            }
                          },
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300, width: 1.5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline, size: 28, color: Colors.grey.shade700),
                                const SizedBox(height: 4),
                                Text(
                                  "Add File",
                                  style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        for (int j = 0; j < (arrayFiles?.length ?? 0); j++) ...[
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
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: (arrayFiles?[j].extension == 'jpg' ||
                                          arrayFiles?[j].extension == 'jpeg' ||
                                          arrayFiles?[j].extension == 'png')
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.file(
                                            File(arrayFiles?[j].path ?? ''),
                                            height: 80,
                                            width: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              arrayFiles?[j].extension == 'pdf'
                                                  ? Icons.picture_as_pdf
                                                  : Icons.insert_drive_file,
                                              size: 30,
                                              color: arrayFiles?[j].extension == 'pdf'
                                                  ? Colors.red
                                                  : Colors.blue,
                                            ),
                                            const SizedBox(height: 4),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                              child: Text(
                                                arrayFiles?[j].name ?? '',
                                                style: const TextStyle(fontSize: 10, color: Colors.black87),
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
                                        arrayFiles?.removeAt(j);
                                        if (arrayFilesBytes != null && arrayFilesBytes!.length > j) {
                                          arrayFilesBytes?.removeAt(j);
                                        }
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: const Icon(Icons.close, size: 14, color: Colors.white),
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

  customShowUpdateDialog() {
    TextEditingController searchController = TextEditingController();
    String searchQuery = '';

    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState1) {
          final filteredList = (widget.memberDetailsRes ?? [])
              .where((member) => (member.memberName ?? '')
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
              .toList();

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            titlePadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.zero,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            actionsAlignment: MainAxisAlignment.center,
            title: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              width: double.infinity,
              child: const Text(
                "Select Participants",
                style: TextStyle(
                  fontFamily: 'HelveticaNeue',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            content: SizedBox(
              height: 340,
              width: 400,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      onChanged: (value) {
                        setState1(() {
                          searchQuery = value;
                        });
                      },
                      style: const TextStyle(fontSize: 13),
                      controller: searchController,
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          labelText: "Search by Name",
                          hintText: "Search by Name",
                          prefixIcon: Icon(Icons.search, size: 18),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0)))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredList.length,
                      itemBuilder: (context, i) {
                        final item = filteredList[i];
                        final bool isSelected = item.isSelected == true;
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.15),
                              ),
                            ),
                          ),
                          margin: const EdgeInsets.only(bottom: 4),
                          child: InkWell(
                            onTap: () {
                              setState1(() {
                                item.isSelected = !isSelected;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xfff8f9fa)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.memberName ?? '',
                                    style: TextStyle(
                                      fontFamily: 'HelveticaNeue',
                                      fontSize: 15,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.black87,
                                    ),
                                  ),
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.circle_outlined,
                                    color: isSelected ? Colors.green : Colors.grey,
                                    size: 20,
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _participantsController.clear();
                          setState1(() {
                            participantsNumberSelected = '';
                            selectedMember?.clear();
                          });
                          for (int i = 0; i < (widget.memberDetailsRes?.length ?? 0); i++) {
                            if (widget.memberDetailsRes?[i].isSelected == true) {
                              setState1(() {
                                participantsNumberSelected =
                                    participantsNumberSelected.trim() == ''
                                        ? '${widget.memberDetailsRes?[i].memberId}'
                                        : "$participantsNumberSelected,${widget.memberDetailsRes?[i].memberId ?? ''}";
                                selectedMember?.add(widget.memberDetailsRes![i]);
                              });
                              _participantsController.text =
                                  _participantsController.text.trim() == ''
                                      ? '${widget.memberDetailsRes?[i].memberName}'
                                      : "${_participantsController.text},${widget.memberDetailsRes?[i].memberName ?? ''}";
                            }
                          }
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20)),
                          child: const Text(
                            "OK",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
      },
    );
  }
}
