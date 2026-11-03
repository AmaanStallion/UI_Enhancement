// ignore_for_file: depend_on_referenced_packages
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_all_members_by_project.dart';
import 'package:stallion/models/get_meeting_id.dart';
import 'package:stallion/models/tenant_payment_list.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/task_manager/task_manager_mock_data.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({
    super.key,
    this.towarId,
    this.projectId,
    this.projectName,
    this.towarName,
  });
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  TextEditingController _participantsController = TextEditingController();
  List<MemberDetail>? memberDetailsRes = [];
  List<MemberDetail>? selectedMember = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<PlatformFile>? arrayFiles = [];
  List<Uint8List?>? arrayFilesBytes = [];
  TextEditingController _deadlineDateController = TextEditingController();
  TextEditingController _taskController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String participantsNumberSelected = '';

  DateTime? deadlineDateSelect;

  Future<List<TenantPaymentListElement>?> addTaskWebService() async {
    // String formatDate(DateTime dateTime) {
    //   return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    // }

    try {
      // CustomLoading.progressDialog(isLoading: true, context: context);

      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "project_id": widget.projectId ?? '',
        "towar_id": widget.towarId ?? '',
      };

      if (kDebugMode) {
        print(data);
      }

      var response =
          await apiNetworkHandler.post(AppUrl.createNewMetting, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = getUserMeetingByIdFromJson(response.body);

        if (kDebugMode) {
          print(dataModel.response?.errorCode);
        }

        if (dataModel.response?.errorCode == "0") {
          setState(() {});
        } else {
          // Handle error when errorCode is not "0"
        }
      } else {
        // Handle error for non-200/201 status codes
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
      // Handle exceptions here if needed
      // throw SomeCustomException('Exception occurred: $e');
    } finally {
      // ignore: use_build_context_synchronously
      // CustomLoading.progressDialog(isLoading: false, context: context);
    }
    return null;
  }

  assignTask() async {
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
                "Task Added Successfully.",
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
                    child: const Text("Okay",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            );
          });
      return null;
    }

    final towerId = widget.towarId;
    if (towerId == null || towerId.isEmpty) return;

    try {
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        await apiNetworkHandler.ensureProjectContext(widget.projectId);
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppUrl.createTowerTask(towerId)),
      );

      final prefs = await _prefs;
      final projectToken = prefs.getString('projectToken') ??
          prefs.getString('masterToken') ??
          prefs.getString('token');
      if (projectToken != null && projectToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $projectToken';
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

      final participantIds =
          (selectedMember != null && selectedMember!.isNotEmpty)
              ? selectedMember!
                  .map((m) => int.tryParse(m.memberId ?? '0') ?? m.memberId ?? '')
                  .toList()
              : [];

      request.fields['deadline'] = formattedDeadline;
      request.fields['title'] = _taskController.text;
      request.fields['participants'] = jsonEncode(participantIds);

      if (arrayFiles != null && arrayFiles!.isNotEmpty) {
        for (int i = 0; i < arrayFiles!.length; i++) {
          PlatformFile file = arrayFiles![i];
          if (file.path != null && file.path!.isNotEmpty) {
            request.files.add(
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

      var response = await request.send();
      var responsed = await http.Response.fromStream(response);
      if (kDebugMode) {
        print("createTowerTask response status: ${response.statusCode}");
        print("createTowerTask response body: ${responsed.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
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
                title: const Text(
                  "Task Added Successfully.",
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
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
    } catch (e) {
      if (kDebugMode) {
        print('AddTaskScreen: Error creating custom task: $e');
      }
    }
  }

  Future<List<TenantPaymentListElement>?> getMembersByProject() async {
    if (TaskManagerMockData.useMockData) {
      setState(() {
        memberDetailsRes = TaskManagerMockData.getMockMembers();
      });
      return null;
    }
    try {
      final projectId = widget.projectId;
      if (projectId != null && projectId.isNotEmpty) {
        await apiNetworkHandler.ensureProjectContext(projectId);
        var response =
            await apiNetworkHandler.get(AppUrl.getProjectUsers(projectId));

        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic> && decoded['success'] == true) {
            final data = decoded['data'];
            final List list = (data is List
                ? data
                : (data is Map ? data['users'] : [])) as List? ?? [];
            final List<MemberDetail> members = list
                .map((x) => MemberDetail.fromJson(x as Map<String, dynamic>))
                .toList();

            setState(() {
              memberDetailsRes = members;
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('AddTaskScreen: Error fetching project users: $e');
      }
    }
    return null;
  }

  @override
  void initState() {
    getMembersByProject();
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
                                assignTask();
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
              style: TextStyle(
                  fontSize: isMobile ? 13 : 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
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
                            initialDate: deadlineDateSelect ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(DateTime.now().year + 20),
                          );
                          if (newDateTime != null) {
                            setState(() {
                              deadlineDateSelect = newDateTime;
                              _deadlineDateController.text =
                                  "${newDateTime.day.toString().padLeft(2, '0')}/${newDateTime.month.toString().padLeft(2, '0')}/${newDateTime.year}";
                            });
                          }
                        },
                        child: TextFormField(
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
                        controller: _taskController,
                        style: TextStyle(color: Colors.black, fontSize: fontSize),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black54),
                          ),
                          hintText: 'Write Task Here..',
                          hintStyle: TextStyle(fontSize: fontSize, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Participants Row
                Row(
                  children: [
                    SizedBox(
                      width: labelWidth,
                      child: Text(
                        'Participants',
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
        ],
      ),
    );
  }

  customShowUpdateDialog() {
    return showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState1) {
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
                height: 300,
                width: 400,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: memberDetailsRes?.length ?? 0,
                  itemBuilder: (context, i) {
                    final item = memberDetailsRes?[i];
                    final bool isSelected = item?.isSelected == true;
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
                            item?.isSelected = !isSelected;
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
                                item?.memberName ?? '',
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
                            for (int i = 0; i < (memberDetailsRes?.length ?? 0); i++) {
                              if (memberDetailsRes?[i].isSelected == true) {
                                setState1(() {
                                  participantsNumberSelected =
                                      participantsNumberSelected.trim() == ''
                                          ? '${memberDetailsRes?[i].memberId}'
                                          : "$participantsNumberSelected,${memberDetailsRes?[i].memberId ?? ''}";
                                  selectedMember?.add(memberDetailsRes![i]);
                                });
                                _participantsController.text =
                                    _participantsController.text.trim() == ''
                                        ? '${memberDetailsRes?[i].memberName}'
                                        : "${_participantsController.text},${memberDetailsRes?[i].memberName ?? ''}";
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
        });
  }
}
