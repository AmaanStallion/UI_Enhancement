import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/sop_category_model.dart';
import 'package:stallion/models/sop_details_modal.dart';
import 'package:stallion/models/sop_heading_model.dart';
import 'package:stallion/models/sop_sub_heading_model.dart';
import 'package:stallion/models/sop_document_response_model.dart';
import 'package:stallion/models/sop_tower_task_model.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/views/sopModule/sop_track_screen.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stallion/utils/responsive.dart';

class SopDetails extends StatefulWidget {
  const SopDetails({
    Key? key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    this.sopId,
    this.title,
    this.assingToId,
  }) : super(key: key);
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? sopId;
  final String? title;
  final String? assingToId;

  @override
  State<SopDetails> createState() => _SopDetailsState();
}

class _SopDetailsState extends State<SopDetails> {
  final NetworkHandler apiNetworkHandler = NetworkHandler();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  DateTime? selectedEndDatePopup;
  TextEditingController endDateControlerPopup = TextEditingController();

  DateTime? selectedStartDatePopup;
  TextEditingController startDateControlerPopup = TextEditingController();

  static const bool testWithMockData = false;
  bool _isLoading = true;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<SopDetailsStructure>? sopDetailsStructure = [];
  List<AssingToList>? assingToList = [];
  Map<String, TowerSopTask> taskMapBySubHeading = {};
  String transEmpId = "";
  String transEmpName = "";

  List<PlatformFile> arrayFiles = [];
  List<Uint8List?> arrayFilesBytes = [];

  // Auto-save subheading fields (start_date, end_date, remarks) directly to backend
  Future<void> autoSaveTowerSubHeading({
    required String subHeadingId,
    required Detail? detail,
  }) async {
    if (testWithMockData || detail == null) return;
    try {
      String formatDate(DateTime? dt) {
        if (dt == null) return '';
        return DateFormat('yyyy-MM-dd').format(dt);
      }

      Map<String, dynamic> body = {
        "tower_id": int.tryParse(widget.towarId ?? '') ?? widget.towarId ?? '',
        "sub_heading_id": int.tryParse(subHeadingId) ?? subHeadingId,
        "remarks": detail.remark ?? '',
        "start_date": formatDate(detail.startDate),
      };

      var response = await apiNetworkHandler.put(AppUrl.devSopTowerSubHeading, body);
      if (kDebugMode) {
        print("Auto-save subheading response: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in autoSaveTowerSubHeading: $e");
      }
    }
  }

  uploadPermissionDoc({
    required String transSopId,
    required int index,
    required int i,
  }) async {
    if (arrayFiles.isEmpty) return;

    if (testWithMockData) {
      setState(() {
        sopDetailsStructure![index].details?[i].uploadImg?.add(
          UploadImg(
            docName: arrayFiles[0].name,
            docId: DateTime.now().millisecondsSinceEpoch.toString(),
          ),
        );
        arrayFiles.clear();
        arrayFilesBytes.clear();
      });
      Future.delayed(Duration.zero).then((_) {
        Alert(
            closeIcon: const SizedBox(),
            padding: const EdgeInsets.only(top: 0.0),
            image: Image.asset('images/Icon-512.png',
                height: 80, fit: BoxFit.fitWidth),
            style: const AlertStyle(
                titleTextAlign: TextAlign.center,
                descTextAlign: TextAlign.center,
                descStyle:
                    TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                isCloseButton: true),
            context: context,
            desc: 'Document Uploaded Successfully.',
            alertAnimation: fadeAlertAnimation,
            buttons: [
              DialogButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.black,
                child: const Text(
                  "CLOSE",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ]).show();
      });
      return;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(AppUrl.devSopDocuments));
      final prefs = await _prefs;
      final projectToken = prefs.getString('projectToken');
      final token = (projectToken != null && projectToken.isNotEmpty)
          ? projectToken
          : prefs.getString('masterToken') ?? prefs.getString('token');

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['tower_id'] = widget.towarId ?? '';
      request.fields['sub_heading_id'] = transSopId;

      PlatformFile file = arrayFiles[0];
      final ext = (file.extension ?? '').toLowerCase();
      String mainType = 'image';
      if (ext == 'pdf') {
        mainType = 'application';
      } else if (ext == 'mp4' || ext == 'mov' || ext == 'avi' || ext == 'mkv') {
        mainType = 'video';
      }

      request.files.add(await http.MultipartFile.fromPath(
        "files",
        file.path.toString(),
        contentType: MediaType(
          mainType,
          ext,
        ),
      ));

      var response = await request.send();
      var responsed = await http.Response.fromStream(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = devSopDocResponseFromJson(responsed.body);
        final uploadedDocs = dataModel.documentList;
        arrayFiles.clear();
        arrayFilesBytes.clear();
        setState(() {
          if (uploadedDocs.isNotEmpty) {
            final currentImgs = sopDetailsStructure![index].details?[i].uploadImg ?? [];
            for (var doc in uploadedDocs) {
              bool exists = currentImgs.any((img) => img.docId == doc.id || (doc.fileUrl != null && img.fileUrl == doc.fileUrl));
              if (!exists) {
                currentImgs.add(
                  UploadImg(
                    docId: doc.id,
                    docName: doc.fileName ?? file.name,
                    fileUrl: doc.fileUrl,
                  ),
                );
              }
            }
            sopDetailsStructure![index].details?[i].uploadImg = currentImgs;
          } else {
            sopDetailsStructure![index].details?[i].uploadImg?.add(
                  UploadImg(
                    docId: '1',
                    docName: file.name,
                    fileUrl: null,
                  ),
                );
          }
        });
        Future.delayed(Duration.zero).then((_) {
          Alert(
              closeIcon: const SizedBox(),
              padding: const EdgeInsets.only(top: 0.0),
              image: Image.asset('images/Icon-512.png',
                  height: 80, fit: BoxFit.fitWidth),
              style: const AlertStyle(
                  titleTextAlign: TextAlign.center,
                  descTextAlign: TextAlign.center,
                  descStyle:
                      TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                  isCloseButton: true),
              context: context,
              desc: 'Document Uploaded Successfully.',
              alertAnimation: fadeAlertAnimation,
              buttons: [
                DialogButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.black,
                  child: const Text(
                    "CLOSE",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ]).show();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading document: $e");
      }
    }
  }

  Future setSopDate({required String transSopId}) async {
    if (testWithMockData) {
      Navigator.of(context).pop();
      return null;
    }
    Navigator.of(context).pop();
    return null;
  }

  Future<dynamic?> changeProjectPermissionAssign(
      {required String transSopId,
      required String assignTo,
      required int index,
      required int i,
      required String assingName}) async {
    setState(() {
      sopDetailsStructure![index].details?[i].assingName = assingName;
      sopDetailsStructure![index].details?[i].assingToId = assignTo;
    });

    if (testWithMockData) {
      Future.delayed(Duration.zero).then((_) {
        Alert(
            closeIcon: const SizedBox(),
            padding: const EdgeInsets.only(top: 0.0),
            image: Image.asset('images/Icon-512.png',
                height: 80, fit: BoxFit.fitWidth),
            style: const AlertStyle(
                titleTextAlign: TextAlign.center,
                descTextAlign: TextAlign.center,
                descStyle:
                    TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                isCloseButton: true),
            context: context,
            desc: 'Assigned Successfully.',
            alertAnimation: fadeAlertAnimation,
            buttons: [
              DialogButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.black,
                child: const Text(
                  "CLOSE",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ]).show();
      });
      return null;
    }

    try {
      Map<String, dynamic> body = {
        "tower_id": int.tryParse(widget.towarId ?? '') ?? widget.towarId ?? '',
        "sub_heading_id": int.tryParse(transSopId) ?? transSopId,
        "assigned_user_id": int.tryParse(assignTo) ?? assignTo,
      };

      var response = await apiNetworkHandler.put(AppUrl.devSopAssignSubHeading, body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Future.delayed(Duration.zero).then((_) {
          Alert(
              closeIcon: const SizedBox(),
              padding: const EdgeInsets.only(top: 0.0),
              image: Image.asset('images/Icon-512.png',
                  height: 80, fit: BoxFit.fitWidth),
              style: const AlertStyle(
                  titleTextAlign: TextAlign.center,
                  descTextAlign: TextAlign.center,
                  descStyle:
                      TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                  isCloseButton: true),
              context: context,
              desc: 'Assigned Successfully.',
              alertAnimation: fadeAlertAnimation,
              buttons: [
                DialogButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.black,
                  child: const Text(
                    "CLOSE",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ]).show();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error assigning sub heading: $e");
      }
    }
    return null;
  }

  Future<dynamic?> setSopDetails() async {
    if (testWithMockData) {
      Navigator.pop(context);
      return null;
    }

    CustomLoading.progressDialog(isLoading: true, context: context);

    try {
      final prefs = await _prefs;
      final projectToken = prefs.getString('projectToken');

      if (projectToken == null || projectToken.isEmpty) {
        CustomLoading.progressDialog(isLoading: false, context: context);
        if (kDebugMode) {
          print("Error: projectToken is null or empty in SharedPreferences");
        }
        Future.delayed(Duration.zero).then((_) {
          Alert(
              closeIcon: const SizedBox(),
              padding: const EdgeInsets.only(top: 0.0),
              style: const AlertStyle(
                  titleTextAlign: TextAlign.center,
                  descTextAlign: TextAlign.center,
                  descStyle:
                      TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                  isCloseButton: true),
              context: context,
              desc: 'Authorization Token (projectToken) missing.',
              alertAnimation: fadeAlertAnimation,
              buttons: [
                DialogButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.black,
                  child: const Text(
                    "CLOSE",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ]).show();
        });
        return null;
      }

      String formatDate(DateTime? dt) {
        if (dt == null) return '';
        return DateFormat('yyyy-MM-dd').format(dt);
      }

      List<Map<String, dynamic>> headingsList = [];

      for (var heading in (sopDetailsStructure ?? [])) {
        List<Map<String, dynamic>> subheadingsList = [];

        for (var detail in (heading.details ?? [])) {
          String? statusVal;
          if (detail.checkFlag == '1') {
            statusVal = 'yes';
          } else if (detail.checkFlag == '2') {
            statusVal = 'no';
          } else {
            statusVal = null;
          }

          Map<String, dynamic> subMap = {
            "subheading_id": int.tryParse(detail.id ?? '') ?? detail.id ?? '',
            "title": detail.name ?? '',
            "remarks": detail.remark ?? '',
            "end_date": formatDate(detail.endDate),
          };
          if (statusVal != null) {
            subMap["status"] = statusVal;
          }

          subheadingsList.add(subMap);
        }

        headingsList.add({
          "heading_id": int.tryParse(heading.id ?? '') ?? heading.id ?? '',
          "title": heading.name ?? '',
          "subheadings": subheadingsList,
        });
      }

      Map<String, dynamic> body = {
        "category_id": int.tryParse(widget.sopId ?? '') ?? widget.sopId ?? '',
        "tower_id": int.tryParse(widget.towarId ?? '') ?? widget.towarId ?? '',
        "headings": headingsList,
      };

      Map<String, String> requestHeaders = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $projectToken",
      };
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        requestHeaders["x-project-id"] = widget.projectId!;
      }

      if (kDebugMode) {
        print("🚀 PUT URL: ${AppUrl.devSopSaveAllSubHeadings}");
        print("🔑 Headers: $requestHeaders");
        String jsonPayload = jsonEncode(body);
        print("📦 PUT Body (Length: ${jsonPayload.length}):");
        for (int i = 0; i < jsonPayload.length; i += 800) {
          print(jsonPayload.substring(
              i, i + 800 < jsonPayload.length ? i + 800 : jsonPayload.length));
        }
      }

      var response = await http.put(
        Uri.parse(AppUrl.devSopSaveAllSubHeadings),
        headers: requestHeaders,
        body: jsonEncode(body),
      );

      if (kDebugMode) {
        print("📩 Response Status: ${response.statusCode}");
        print("📩 Response Body: ${response.body}");
      }

      if (!mounted) return null;
      CustomLoading.progressDialog(isLoading: false, context: context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Future.delayed(Duration.zero).then((_) {
          Alert(
              closeIcon: const SizedBox(),
              padding: const EdgeInsets.only(top: 0.0),
              image: Image.asset('images/Icon-512.png',
                  height: 80, fit: BoxFit.fitWidth),
              style: const AlertStyle(
                  titleTextAlign: TextAlign.center,
                  descTextAlign: TextAlign.center,
                  descStyle:
                      TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                  isCloseButton: true),
              context: context,
              desc: 'S.O.P Submitted Successfully.',
              alertAnimation: fadeAlertAnimation,
              buttons: [
                DialogButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  color: Colors.black,
                  child: const Text(
                    "CLOSE",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ]).show();
        });
      } else {
        Future.delayed(Duration.zero).then((_) {
          Alert(
              closeIcon: const SizedBox(),
              padding: const EdgeInsets.only(top: 0.0),
              style: const AlertStyle(
                  titleTextAlign: TextAlign.center,
                  descTextAlign: TextAlign.center,
                  descStyle:
                      TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                  isCloseButton: true),
              context: context,
              desc: 'Failed to submit S.O.P (${response.statusCode}).',
              alertAnimation: fadeAlertAnimation,
              buttons: [
                DialogButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.black,
                  child: const Text(
                    "CLOSE",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ]).show();
        });
      }
    } catch (e) {
      CustomLoading.progressDialog(isLoading: false, context: context);
      if (kDebugMode) {
        print("Error submitting SOP details: $e");
      }
    }
    return null;
  }

  Future<List<SopDetailsStructure>?> fetchSopDetails() async {
    setState(() {
      _isLoading = true;
    });

    if (testWithMockData) {
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        assingToList = [
          AssingToList(
            transEmpId: "11",
            transEmpName: "John Doe",
          ),
          AssingToList(
            transEmpId: "12",
            transEmpName: "Jane Smith",
          ),
          AssingToList(
            transEmpId: "13",
            transEmpName: "Robert Johnson",
          ),
        ];

        sopDetailsStructure = [
          SopDetailsStructure(
            id: "1",
            name: "Initial Site Setup",
            tickFlag: "0",
            isOpen: true,
            details: [
              Detail(
                id: "101",
                subCatId: "1",
                name: "Clear obstacles and level ground",
                checkFlag: "1", // Yes
                remark: "Done for Zone A and B",
                assingToId: "11",
                assingName: "John Doe",
                startDate: DateTime.now().subtract(const Duration(days: 5)),
                endDate: DateTime.now().subtract(const Duration(days: 2)),
                uploadImg: [
                  UploadImg(docName: "site_clear_1.jpg", docId: "1"),
                ],
              ),
              Detail(
                id: "102",
                subCatId: "1",
                name: "Install temporary fence & safety signs",
                checkFlag: "2", // No
                remark: "Awaiting fence post delivery",
                assingToId: "12",
                assingName: "Jane Smith",
                startDate: DateTime.now().subtract(const Duration(days: 1)),
                endDate: null,
                uploadImg: [],
              ),
            ],
          ),
        ];

        _isLoading = false;
      });
      return sopDetailsStructure;
    }

    try {
      // 1. Fetch tower tasks to map user assignments
      taskMapBySubHeading = {};
      try {
        String taskUrl = "${AppUrl.devSopTowerTaskList}?tower_id=${widget.towarId ?? ''}";
        var taskResp = await apiNetworkHandler.get(taskUrl);
        if (taskResp != null && (taskResp.statusCode == 200 || taskResp.statusCode == 201)) {
          final taskDataModel = towerSopTaskListResponseFromJson(taskResp.body);
          for (var t in taskDataModel.data?.tasks ?? []) {
            String shId = t.subHeading?.id ?? t.subHeadingId ?? "";
            if (shId.isNotEmpty) {
              taskMapBySubHeading[shId] = t;
            }
          }
        }
      } catch (e) {
        if (kDebugMode) print("Error loading tower tasks: $e");
      }

      // 2. Fetch project users for assignment dropdown
      String usersUrl = "${AppUrl.baseURL}users/project/${widget.projectId}";
      var usersResponse = await apiNetworkHandler.get(usersUrl);
      List<AssingToList> userAssignList = [];
      if (usersResponse != null && (usersResponse.statusCode == 200 || usersResponse.statusCode == 201)) {
        final decodedUsers = json.decode(usersResponse.body);
        List uList = [];
        if (decodedUsers is List) {
          uList = decodedUsers;
        } else if (decodedUsers is Map) {
          if (decodedUsers['data'] is List) {
            uList = decodedUsers['data'];
          } else if (decodedUsers['data'] is Map && decodedUsers['data']['users'] is List) {
            uList = decodedUsers['data']['users'];
          } else if (decodedUsers['users'] is List) {
            uList = decodedUsers['users'];
          }
        }
        for (var u in uList) {
          if (u is Map) {
            String uId = u['id']?.toString() ?? u['user_id']?.toString() ?? "";
            String uName = u['name'] ?? u['user_name'] ?? u['full_name'] ?? "";
            if (uId.isNotEmpty) {
              userAssignList.add(AssingToList(
                transEmpId: uId,
                transEmpName: uName,
              ));
            }
          }
        }
      }

      // 3. Determine category IDs to fetch
      List<String> categoryIds = [];
      if (widget.sopId != null && widget.sopId!.isNotEmpty) {
        categoryIds.add(widget.sopId!);
      } else {
        try {
          String catUrl = AppUrl.devSopCategories;
          if (widget.towarId != null && widget.towarId!.isNotEmpty) {
            catUrl = "$catUrl?tower_id=${widget.towarId}";
          }
          var catResp = await apiNetworkHandler.get(catUrl);
          if (catResp != null && (catResp.statusCode == 200 || catResp.statusCode == 201)) {
            final catData = devSopCategoryResponseFromJson(catResp.body);
            for (var c in catData.data ?? []) {
              if (c.id != null && c.id!.isNotEmpty) {
                categoryIds.add(c.id!);
              }
            }
          }
        } catch (_) {}
      }

      List<SopDetailsStructure> structures = [];

      for (var catId in categoryIds) {
        Map<String, List<Detail>> subHeadingsByHeadingId = {};
        try {
          String subHeadingsUrl = "${AppUrl.devSopSubHeadings}?category_id=$catId";
          if (widget.towarId != null && widget.towarId!.isNotEmpty) {
            subHeadingsUrl = "$subHeadingsUrl&tower_id=${widget.towarId}";
          }
          var subResp = await apiNetworkHandler.get(subHeadingsUrl);
          if (subResp != null && (subResp.statusCode == 200 || subResp.statusCode == 201)) {
            final subData = devSopSubHeadingResponseFromJson(subResp.body);
            List<DevSopSubHeading> allSubHeadings = subData.data ?? [];

            for (var sh in allSubHeadings) {
              String hId = sh.headingId ?? sh.heading?.id ?? "";
              if (hId.isEmpty) continue;

              TowerAssignment? currentTowerAssign;
              if (sh.towerAssignments != null && sh.towerAssignments!.isNotEmpty) {
                try {
                  currentTowerAssign = sh.towerAssignments!.firstWhere(
                    (ta) =>
                        ta.towerId == widget.towarId ||
                        ta.tower?.id == widget.towarId,
                    orElse: () => sh.towerAssignments!.first,
                  );
                } catch (_) {
                  currentTowerAssign = sh.towerAssignments!.first;
                }
              }

              TowerSopTask? assignedTask = taskMapBySubHeading[sh.id];

              // Skip disabled subheadings
              if (sh.isEnabled == false ||
                  currentTowerAssign?.isEnabled == false ||
                  assignedTask?.isEnabled == false) {
                continue;
              }

              String assignedUserId = assignedTask?.assignedUser?.id ??
                  assignedTask?.assignedUserId ??
                  sh.assignedToId ??
                  "";
              String assignedUserName = assignedTask?.assignedUser?.name ??
                  sh.assignedToName ??
                  "";

              List<UploadImg> docImgs = [];
              if (assignedTask?.towerDocuments != null &&
                  assignedTask!.towerDocuments!.isNotEmpty) {
                for (var td in assignedTask.towerDocuments!) {
                  docImgs.add(UploadImg(
                    docId: td.id,
                    docName: td.fileName,
                    fileUrl: td.fileUrl,
                  ));
                }
              }

              String computedCheckFlag = "0";
              if (currentTowerAssign?.status == "yes") {
                computedCheckFlag = "1";
              } else if (currentTowerAssign?.status == "no") {
                computedCheckFlag = "2";
              } else if (sh.checkFlag != null && sh.checkFlag != "0") {
                computedCheckFlag = sh.checkFlag!;
              }

              subHeadingsByHeadingId.putIfAbsent(hId, () => []).add(Detail(
                id: sh.id,
                subCatId: hId,
                name: sh.name,
                checkFlag: computedCheckFlag,
                remark: currentTowerAssign?.remarks ??
                    assignedTask?.remarks ??
                    sh.description ??
                    "",
                assingToId: assignedUserId,
                assingName: assignedUserName,
                startDate: currentTowerAssign?.startDate ?? assignedTask?.startDate,
                endDate: currentTowerAssign?.endDate ?? assignedTask?.endDate,
                uploadImg: docImgs,
              ));
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error loading category subheadings: $e");
          }
        }

        String headingsUrl = "${AppUrl.devSopHeadings}?category_id=$catId";
        if (widget.towarId != null && widget.towarId!.isNotEmpty) {
          headingsUrl = "$headingsUrl&tower_id=${widget.towarId}";
        }
        var headingsResponse = await apiNetworkHandler.get(headingsUrl);

        if (headingsResponse != null && (headingsResponse.statusCode == 200 || headingsResponse.statusCode == 201)) {
          final headingData = devSopHeadingResponseFromJson(headingsResponse.body);
          List<DevSopHeading> headings = headingData.data ?? [];

          for (var h in headings) {
            if (h.isEnabled == false) continue;

            List<Detail> headingDetails = subHeadingsByHeadingId[h.id] ?? [];

            bool isHeadingDone = h.isHeadingComplete == true;
            if (headingDetails.isNotEmpty &&
                headingDetails.every((d) => d.checkFlag == '1' || d.checkFlag == '2')) {
              isHeadingDone = true;
            }

            structures.add(SopDetailsStructure(
              id: h.id,
              categoryId: catId,
              name: h.name,
              isOpen: false,
              tickFlag: isHeadingDone ? "1" : "0",
              details: headingDetails,
              isSubHeadingsLoaded: true,
              isLoadingSubHeadings: false,
            ));
          }
        }
      }

      setState(() {
        assingToList = userAssignList;
        sopDetailsStructure = structures;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching DevSOP details: $e");
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    return null;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchSopDetails();
    });
    // TODO: implement initState
    super.initState();
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
            widget.towarName!.isNotEmpty
                ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                : widget.projectName!.toUpperCase(),
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        actions: [
          if (widget.assingToId == "")
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) {
                    return SopTrackScreen(
                      projectId: widget.projectId,
                      projectName: widget.projectName,
                      towarId: widget.towarId,
                      towarName: widget.towarName,
                      sopId: widget.sopId,
                      assingIoId: '',
                      title: widget.title,
                    );
                  },
                )).then((value) => fetchSopDetails());
              },
              child: Container(
                margin:
                    EdgeInsets.symmetric(horizontal: isMobile ? 16 : 50, vertical: isMobile ? 13 : 10),
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 25),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: isMobile ? 1.5 : 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    "Track",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 13 : 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 60,
            vertical: 10,
          ),
          child: InkWell(
            onTap: () {
              showDialog<void>(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      titlePadding: const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0),
                      actionsPadding: const EdgeInsets.all(16.0),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      actionsAlignment: MainAxisAlignment.center,
                      title: const Text(
                        "Submit S.O.P",
                        style: TextStyle(
                          fontFamily: 'HelveticaNeue',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      content: const Text(
                        "Are you sure you want to submit S.O.P?",
                        style: TextStyle(
                          fontFamily: 'HelveticaNeue',
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        Row(
                          children: [
                            Expanded(
                              child: ModernDialogButton(
                                text: "No",
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ModernDialogButton(
                                text: "Yes",
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                                onTap: () {
                                  Navigator.of(context).pop();
                                  setSopDetails();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  });
            },
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                "SUBMIT",
                style: TextStyle(
                  fontFamily: 'HelveticaNeue',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? CustomLoading.buildSopDetailsSkeletonInline(context)
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: Center(
                      child: Text(widget.title ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center),
                    ),
                  ),
                  const Divider(
                    height: 1.0,
                    color: Colors.black,
                  ),
                  ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: sopDetailsStructure!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final bool hasAssignedDetails = widget.assingToId == null ||
                            widget.assingToId!.isEmpty ||
                            !sopDetailsStructure![index].isSubHeadingsLoaded ||
                            (sopDetailsStructure![index].details != null &&
                                sopDetailsStructure![index].details!.any((detail) =>
                                    detail.assingToId?.toString().trim() == widget.assingToId?.toString().trim()));

                        if (!hasAssignedDetails) {
                          return const SizedBox.shrink();
                        }

                        final bool isCardOpened = sopDetailsStructure![index].isOpen == true;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: isCardOpened ? const Color(0xffd6d6d6) : const Color(0xfff0f0f0),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isCardOpened ? 0.08 : 0.015),
                                blurRadius: isCardOpened ? 12 : 8,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 60, vertical: 4),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  final bool isCurrentlyOpen = sopDetailsStructure![index].isOpen == true;
                                  setState(() {
                                    for (int k = 0; k < sopDetailsStructure!.length; k++) {
                                      sopDetailsStructure![k].isOpen = false;
                                    }
                                    if (!isCurrentlyOpen) {
                                      sopDetailsStructure![index].isOpen = true;
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: isCardOpened ? const Color(0xffe9ecef) : Colors.transparent,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          sopDetailsStructure?[index].name ?? '',
                                          style: TextStyle(
                                              fontFamily: 'HelveticaNeue',
                                              fontSize: isMobile ? 14 : 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (sopDetailsStructure?[index].tickFlag == '1')
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.green, width: 2.0),
                                            color: Colors.green.withOpacity(0.12),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.green,
                                              size: 13,
                                            ),
                                          ),
                                        )
                                      else
                                        const Icon(
                                          Icons.circle_outlined,
                                          color: Colors.black38,
                                          size: 20,
                                        ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        isCardOpened ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                        color: Colors.black,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                        if (sopDetailsStructure![index].isOpen == true) ...[
                          if (sopDetailsStructure![index].details != null)
                            for (int i = 0;
                                i < sopDetailsStructure![index].details!.length;
                                i++) ...[
                            if (widget.assingToId == null ||
                                widget.assingToId!.isEmpty ||
                                sopDetailsStructure![index].details?[i].assingToId?.toString().trim() ==
                                    widget.assingToId?.toString().trim())
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 16, vertical: 4),
                                padding: EdgeInsets.symmetric(vertical: 6, horizontal: isMobile ? 6 : 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xfffafafa),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: const Color(0xffe2e8f0), width: 1.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              sopDetailsStructure![index]
                                                      .details?[i]
                                                      .name ??
                                                  '',
                                              style: TextStyle(
                                                fontFamily: 'HelveticaNeue',
                                                fontSize: isMobile ? 14 : 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: isMobile ? 6 : 12),
                                   Container(
                                     decoration: BoxDecoration(
                                       color: const Color(0xfff0f0f0),
                                       borderRadius: BorderRadius.circular(20),
                                       border: Border.all(color: Colors.black38, width: 1.0),
                                     ),
                                     child: Row(
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                sopDetailsStructure![index].details?[i].checkFlag = '1';
                                                sopDetailsStructure![index].details?[i].endDate = DateTime.now();

                                                final details = sopDetailsStructure![index].details;
                                                bool isComplete = details != null &&
                                                    details.isNotEmpty &&
                                                    details.every((d) => d.checkFlag == '1' || d.checkFlag == '2');
                                                sopDetailsStructure![index].tickFlag = isComplete ? '1' : '0';
                                              });
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 150),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: isMobile ? 12 : 20,
                                                  vertical: isMobile ? 3 : 5),
                                              decoration: BoxDecoration(
                                                color: sopDetailsStructure![index].details?[i].checkFlag == "1"
                                                    ? Colors.black
                                                    : Colors.transparent,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                "Yes",
                                                style: TextStyle(
                                                  fontFamily: 'HelveticaNeue',
                                                  fontSize: isMobile ? 12 : 15,
                                                  fontWeight: sopDetailsStructure![index].details?[i].checkFlag == "1"
                                                      ? FontWeight.w600
                                                      : FontWeight.w400,
                                                  color: sopDetailsStructure![index].details?[i].checkFlag == "1"
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                sopDetailsStructure![index].details?[i].checkFlag = '2';
                                                sopDetailsStructure![index].details?[i].endDate = DateTime.now();

                                                final details = sopDetailsStructure![index].details;
                                                bool isComplete = details != null &&
                                                    details.isNotEmpty &&
                                                    details.every((d) => d.checkFlag == '1' || d.checkFlag == '2');
                                                sopDetailsStructure![index].tickFlag = isComplete ? '1' : '0';
                                              });
                                            },
                                           child: AnimatedContainer(
                                             duration: const Duration(milliseconds: 150),
                                             padding: EdgeInsets.symmetric(
                                                 horizontal: isMobile ? 12 : 20,
                                                 vertical: isMobile ? 3 : 5),
                                             decoration: BoxDecoration(
                                               color: sopDetailsStructure![index].details?[i].checkFlag == "2"
                                                   ? Colors.black
                                                   : Colors.transparent,
                                               borderRadius: BorderRadius.circular(20),
                                             ),
                                             child: Text(
                                               "No",
                                               style: TextStyle(
                                                 fontFamily: 'HelveticaNeue',
                                                 fontSize: isMobile ? 12 : 15,
                                                 fontWeight: sopDetailsStructure![index].details?[i].checkFlag == "2"
                                                     ? FontWeight.w600
                                                     : FontWeight.w400,
                                                 color: sopDetailsStructure![index].details?[i].checkFlag == "2"
                                                     ? Colors.white
                                                     : Colors.black,
                                               ),
                                             ),
                                           ),
                                         ),
                                       ],
                                     ),
                                   )                                ],
                              ),
                            ),
                            SizedBox(height: isMobile ? 8 : 16),
                            Container(
                              padding:
                                  EdgeInsets.symmetric(horizontal: isMobile ? 0 : 10),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (assingToList!.length != 0) {
                                        setState(() {
                                          transEmpId =
                                              sopDetailsStructure![index]
                                                      .details?[i]
                                                      .assingToId ??
                                                  '';
                                          transEmpName =
                                              sopDetailsStructure![index]
                                                      .details?[i]
                                                      .assingName ??
                                                  '';
                                        });
                                        changeAssignToModal(
                                            index: index,
                                            i: i,
                                            transSopId:
                                                sopDetailsStructure![index]
                                                        .details?[i]
                                                        .id ??
                                                    '');
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              color: assingToList!.length != 0
                                                  ? Colors.blue
                                                  : Colors.transparent),
                                        ),
                                      ),
                                      child: Text(
                                        "Assign To : ${sopDetailsStructure![index].details?[i].assingName} ",
                                        style: TextStyle(
                                          fontFamily: 'HelveticaNeue',
                                          fontSize: isMobile ? 12 : 14,
                                          color: assingToList!.length != 0
                                              ? Colors.blue
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  InkWell(
                                    onTap: () async {
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: [
                                          'pdf',
                                          'jpg', 'jpeg', 'png',
                                          'mp4', 'mov', 'avi', 'mkv',
                                        ],
                                      );
                                      if (result != null) {
                                        PlatformFile file = result.files.first;
                                        Uint8List? fileBytes =
                                            result.files.first.bytes;
                                        setState(() {
                                          arrayFilesBytes.add(fileBytes);
                                          arrayFiles.add(file);
                                        });
                                        CustomLoading.progressDialog(
                                            isLoading: true, context: context);
                                        uploadPermissionDoc(
                                          transSopId:
                                              sopDetailsStructure![index]
                                                      .details?[i]
                                                      .id ??
                                                  '',
                                          index: index,
                                          i: i,
                                        ).then((val) {
                                          CustomLoading.progressDialog(
                                              isLoading: false,
                                              context: context);
                                        });
                                      } else {
                                      }
                                    },
                                    child: Container(
                                      padding: isMobile
                                          ? const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0)
                                          : const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.upload_file_rounded, size: isMobile ? 12 : 14, color: Colors.black),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Upload",
                                            style: TextStyle(
                                              fontFamily: 'HelveticaNeue',
                                              fontSize: isMobile ? 11.0 : 12.0,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 10),
                              child: Row(
                                children: [
                                  Text(
                                    "Start Date : ",
                                    style: TextStyle(
                                      fontFamily: 'HelveticaNeue',
                                      fontSize: isMobile ? 12 : 14,
                                    ),
                                  ),
                                  if (sopDetailsStructure![index]
                                          .details?[i]
                                          .startDate !=
                                      null)
                                    Text(
                                        DateFormat('dd-MM-yyyy').format(
                                            sopDetailsStructure![index]
                                                    .details![i]
                                                    .startDate ??
                                                DateTime.now()),
                                        style: TextStyle(
                                          fontFamily: 'HelveticaNeue',
                                          fontSize: isMobile ? 12 : 14,
                                        )),
                                  const SizedBox(width: 4),
                                  InkWell(
                                    onTap: () async {
                                      final DateTime? picked =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: sopDetailsStructure![index]
                                                .details![i]
                                                .startDate ??
                                            DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2101),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          sopDetailsStructure![index]
                                              .details?[i]
                                              .startDate = picked;
                                        });
                                        autoSaveTowerSubHeading(
                                          subHeadingId: sopDetailsStructure![index]
                                                  .details?[i]
                                                  .id ??
                                              '',
                                          detail: sopDetailsStructure![index]
                                              .details?[i],
                                        );
                                      }
                                    },
                                    child: const Icon(
                                      Icons.calendar_month_outlined,
                                      size: 15.0,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (sopDetailsStructure![index]
                                          .details?[i]
                                          .uploadImg
                                          ?.length !=
                                      0)
                                    InkWell(
                                      onTap: () {
                                        viewDocumentsModal(
                                          details: sopDetailsStructure![index]
                                              .details?[i]
                                              .uploadImg,
                                          index: index,
                                          detailIndex: i,
                                          subHeadingId: sopDetailsStructure![index]
                                              .details?[i]
                                              .id,
                                        );
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(),
                                        child: Text(
                                          "View Doc",
                                          style: TextStyle(
                                            fontFamily: 'HelveticaNeue',
                                            fontSize: isMobile ? 12 : 14,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding:
                                  EdgeInsets.symmetric(horizontal: isMobile ? 0 : 10),
                              child: Row(
                                children: [
                                  Text(
                                    "End Date : ",
                                    style: TextStyle(
                                      fontFamily: 'HelveticaNeue',
                                      fontSize: isMobile ? 12 : 14,
                                    ),
                                  ),
                                  if (sopDetailsStructure![index]
                                          .details?[i]
                                          .endDate !=
                                      null)
                                    Text(
                                        DateFormat('dd-MM-yyyy').format(
                                            sopDetailsStructure![index]
                                                .details![i]
                                                .endDate!),
                                        style: TextStyle(
                                          fontFamily: 'HelveticaNeue',
                                          fontSize: isMobile ? 12 : 14,
                                        )),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding:
                                  EdgeInsets.symmetric(horizontal: isMobile ? 0 : 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      "Remarks",
                                      style: TextStyle(
                                        fontFamily: 'HelveticaNeue',
                                        fontSize: isMobile ? 12 : 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: isMobile ? 8 : 18),
                                   Flexible(
                                     child: TextFormField(
                                       minLines: 1,
                                       maxLines: 3,
                                      onChanged: (value) {
                                        sopDetailsStructure![index]
                                            .details?[i]
                                            .remark = value;
                                        if (_debounceTimer?.isActive ?? false) {
                                          _debounceTimer!.cancel();
                                        }
                                        _debounceTimer = Timer(
                                          const Duration(milliseconds: 750),
                                          () {
                                            autoSaveTowerSubHeading(
                                              subHeadingId:
                                                  sopDetailsStructure![index]
                                                          .details?[i]
                                                          .id ??
                                                      '',
                                              detail: sopDetailsStructure![index]
                                                  .details?[i],
                                            );
                                          },
                                        );
                                      },
                                      controller: TextEditingController(
                                          text: sopDetailsStructure![index]
                                              .details?[i]
                                              .remark),
                                      style: TextStyle(
                                          fontFamily: 'HelveticaNeue',
                                          color: Colors.black,
                                          fontSize: isMobile ? 12 : 14.0,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                        disabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black38),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: (Colors.black38),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: (Colors.black38),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: (Colors.red),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: (Colors.black38),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                         contentPadding:
                                             const EdgeInsets.symmetric(horizontal: 10, vertical: 6.0),
                                        border: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black54),
                                        ),
                                        hintText: 'Enter Remark',
                                        hintStyle: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 116, 116, 116),
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w200,
                                          fontFamily: 'HelveticaNeue',
                                        ),
                                        // suffixIcon: Icon(
                                        //   Icons.keyboard_arrow_down_rounded,
                                          // ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            );
          },
        ),
      ],
    ),
  ),
);
  }

  changeAssignToModal(
      {required String transSopId, required int index, required int i}) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context1, setState2) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              titlePadding: EdgeInsets.zero,
              actionsPadding: const EdgeInsets.all(16.0),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  "Assign To",
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
                height: 240,
                width: 320,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: assingToList!.length,
                  itemBuilder: (context, idx) {
                    final employee = assingToList![idx];
                    final isSelected = transEmpId == employee.transEmpId;
                    return InkWell(
                      onTap: () {
                        setState2(() {
                          transEmpId = employee.transEmpId ?? '';
                          transEmpName = employee.transEmpName ?? '';
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black12 : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.black12,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              employee.transEmpName ?? '',
                              style: TextStyle(
                                fontFamily: 'HelveticaNeue',
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.check_circle_outline_outlined : Icons.circle_outlined,
                              color: isSelected ? Colors.green : Colors.grey,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: ModernDialogButton(
                        text: 'Close',
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ModernDialogButton(
                        text: 'Submit',
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        onTap: () {
                          changeProjectPermissionAssign(
                              transSopId: transSopId,
                              assignTo: transEmpId,
                              assingName: transEmpName,
                              i: i,
                              index: index);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          });
        });
  }

  viewDocumentsModal({
    required List<UploadImg>? details,
    required int index,
    int? detailIndex,
    String? subHeadingId,
  }) {
    List<UploadImg> currentDocs = List<UploadImg>.from(details ?? []);
    bool isFetching = false;

    return showDialog(
        context: context,
        builder: (context) {
          final isMobile = context.isMobile;
          return StatefulBuilder(builder: (modalContext, setModalState) {
            if (!isFetching &&
                subHeadingId != null &&
                subHeadingId.isNotEmpty &&
                widget.towarId != null &&
                widget.towarId!.isNotEmpty) {
              isFetching = true;
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                try {
                  String docUrl =
                      "${AppUrl.devSopDocuments}?tower_id=${widget.towarId}&sub_heading_id=$subHeadingId";
                  var docResp = await apiNetworkHandler.get(docUrl);
                  if (docResp != null &&
                      (docResp.statusCode == 200 || docResp.statusCode == 201)) {
                    final docModel = devSopDocResponseFromJson(docResp.body);
                    List<SopDocumentItem> fetchedItems = docModel.documentList;
                    if (fetchedItems.isNotEmpty) {
                      List<UploadImg> updatedDocs = fetchedItems
                          .map((d) => UploadImg(
                                docId: d.id,
                                docName: d.fileName,
                                fileUrl: d.fileUrl,
                              ))
                          .toList();

                      setModalState(() {
                        currentDocs = updatedDocs;
                      });

                      if (detailIndex != null &&
                          sopDetailsStructure != null &&
                          index < sopDetailsStructure!.length &&
                          sopDetailsStructure![index].details != null &&
                          detailIndex <
                              sopDetailsStructure![index].details!.length) {
                        setState(() {
                          sopDetailsStructure![index]
                              .details![detailIndex]
                              .uploadImg = updatedDocs;
                        });
                      }
                    }
                  }
                } catch (_) {}
              });
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              titlePadding: EdgeInsets.zero,
              actionsPadding: const EdgeInsets.all(16.0),
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
                  'View Documents',
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
                height: 320,
                width: isMobile ? double.maxFinite : 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.center,
                        spacing: isMobile ? 12 : 24,
                        runSpacing: isMobile ? 12 : 24,
                        children: [
                          for (int i = 0; i < currentDocs.length; i++) ...[
                            () {
                              final String displayName = (currentDocs[i].docName != null && currentDocs[i].docName!.isNotEmpty)
                                  ? currentDocs[i].docName!
                                  : (currentDocs[i].fileUrl != null && currentDocs[i].fileUrl!.contains('/'))
                                      ? currentDocs[i].fileUrl!.split('/').last
                                      : 'Document';

                              final String rawUrl = (currentDocs[i].fileUrl != null && currentDocs[i].fileUrl!.isNotEmpty)
                                  ? currentDocs[i].fileUrl!
                                  : currentDocs[i].docName ?? '';

                              final bool isHttpUrl = rawUrl.startsWith('http://') || rawUrl.startsWith('https://');
                              final String fullDocUrl = isHttpUrl
                                  ? rawUrl
                                  : '${AppUrl.baseURL}media/backend/images/sop-document/$rawUrl';

                              final String lowerDocName = displayName.toLowerCase();
                              final String lowerUrl = rawUrl.toLowerCase();

                              final double iconSize = isMobile ? 60 : 100;
                              final double cardWidth = isMobile ? 100 : 140;
                              final double fontSize = isMobile ? 9 : 12;

                              if (lowerDocName.endsWith('.mp4') || lowerUrl.contains('.mp4')) {
                                return InkWell(
                                  onTap: () async {
                                    final uri = Uri.parse(fullDocUrl);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    } else {
                                      throw 'Could not launch';
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xffe0e0e0),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    width: cardWidth,
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.video_camera_back,
                                          size: iconSize,
                                        ),
                                        const SizedBox(height: 6),
                                        AppText(
                                          title: displayName,
                                          fontSize: fontSize,
                                          titleTextAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              } else if (lowerDocName.endsWith('.pdf') || lowerUrl.contains('.pdf')) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return PdfViewer(
                                            fileName: displayName,
                                            fileUrl: testWithMockData
                                                ? "dummy.pdf"
                                                : fullDocUrl,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xffe0e0e0),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    width: cardWidth,
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'images/projectmanagement/pdf.png',
                                          width: iconSize,
                                          height: iconSize,
                                        ),
                                        const SizedBox(height: 6),
                                        AppText(
                                          title: displayName,
                                          fontSize: fontSize,
                                          titleTextAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return ImagePreviewViewer(
                                            fileName: displayName,
                                            fileUrl: testWithMockData
                                                ? "noimage"
                                                : fullDocUrl,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xffe0e0e0),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    width: cardWidth,
                                    child: Column(
                                      children: [
                                        Image(
                                          width: iconSize,
                                          height: iconSize,
                                          fit: BoxFit.cover,
                                          image: testWithMockData
                                              ? const AssetImage('images/projectmanagement/noimage.png') as ImageProvider
                                              : NetworkImage(fullDocUrl),
                                        ),
                                        const SizedBox(height: 6),
                                        AppText(
                                          title: displayName,
                                          fontSize: fontSize,
                                          titleTextAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }
                            }()
                          ],
                        ],
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                ModernDialogButton(
                  text: "Close",
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
        });
  }
}

/// Custom Modern Dialog button with click and hover states
class ModernDialogButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  const ModernDialogButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  _ModernDialogButtonState createState() => _ModernDialogButtonState();
}

class _ModernDialogButtonState extends State<ModernDialogButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 24.0),
            decoration: BoxDecoration(
              color: _isHovered
                  ? (widget.backgroundColor == Colors.black ? const Color(0xff222222) : widget.backgroundColor.withOpacity(0.9))
                  : widget.backgroundColor,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: widget.backgroundColor == Colors.white ? const Color(0xffcccccc) : Colors.transparent,
                width: widget.backgroundColor == Colors.white ? 1.0 : 0.0,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                widget.text,
                style: TextStyle(
                  fontFamily: 'HelveticaNeue',
                  color: widget.textColor,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
