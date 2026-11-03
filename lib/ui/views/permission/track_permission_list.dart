import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'package:stallion/websocket/socket_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_sale_buyer_request.dart';
import 'package:stallion/models/project_permission.dart';
import 'package:stallion/models/upload_permission_res.dart';
import 'package:stallion/models/upload_permission_response.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/permission/track_permission.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:http/http.dart' as http;

/// Screen to view the detailed tracked permission items of an employee.
/// It shows a search bar, filter tabs at the bottom, and an expandable list of permission details.
class TrackPermissionList extends StatefulWidget {
  const TrackPermissionList({
    super.key,
    required this.projectId,
    required this.towarId,
    required this.projectName,
    required this.towarName,
    required this.assignToId,
    required this.transEmpName,
  });
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? assignToId;
  final String? transEmpName;

  @override
  State<TrackPermissionList> createState() => _PermissionsState();
}

class _PermissionsState extends State<TrackPermissionList> {
  // Check if screen is mobile-sized (< 600px width)
  bool get isMobile => context.isMobile;
  StreamSubscription? _permissionSubscription;
  
  String cnt = '';
  NetworkHandler apiNetworkHandler = NetworkHandler();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  
  List<PermissionDetail>? permissionDetailsReponse = [];
  TextEditingController expiryDateControler = TextEditingController();
  DateTime? _selectedExpiryDate;
  TextEditingController remarkControler = TextEditingController();
  TextEditingController editingController = TextEditingController();
  String? permissionLodFlag = '0';
  String? resolvedEmpName;
  
  List<PermissionDetail>? permissionDetailsAllReponse;
  List<PermissionDetail>? permissionDetailsIodReponse;
  List<PermissionDetail>? permissionDetailsCcReponse;
  List<PermissionDetail>? permissionDetailsOcReponse;
  List<PlatformFile> arrayFiles = [];
  List<Uint8List?> arrayFilesBytes = [];
  List<SelectDetail>? selectDetailsReponse = [];
  List<AssingToList>? assingToList = [];
  int isSelectedOpen = -1;
  String transEmpId = '0';
  String isFilterArray = '';
  bool _applyDwg = false;
  bool _showLod = false;

  // Order sorting items mapping for filters
  List<OrderShort>? orderShort = [
    OrderShort(id: "", name: "All"),
    OrderShort(id: "0", name: "Pending"),
    OrderShort(id: "1", name: "Applied"),
    OrderShort(id: "2", name: "In Process"),
    OrderShort(id: "3", name: "Issued"),
    OrderShort(id: "4", name: "Payment Due"),
    OrderShort(id: "5", name: "Rejected"),
    OrderShort(id: "6", name: "Document Missing"),
    OrderShort(id: "7", name: "Not Applied"),
    OrderShort(id: "8", name: "Paid"),
    OrderShort(id: "9", name: "Expired"),
  ];

  List<PermissionDetail> _sortPermissionsWithPriority(List<PermissionDetail> list) {
    if (list.isEmpty) return list;

    int compareNames(PermissionDetail a, PermissionDetail b) {
      final nameA = (a.permissionName ?? '').trim().toLowerCase();
      final nameB = (b.permissionName ?? '').trim().toLowerCase();
      return nameA.compareTo(nameB);
    }

    final flagged = list.where((e) =>
        e.permissionFlag?.toLowerCase() == "flag" || e.permissionFlag == "1").toList();
    final unflagged = list.where((e) =>
        !(e.permissionFlag?.toLowerCase() == "flag" || e.permissionFlag == "1")).toList();

    final flaggedWithTick = flagged.where((e) => e.uploadFlag == "1").toList()..sort(compareNames);
    final flaggedWithoutTick = flagged.where((e) => e.uploadFlag != "1").toList()..sort(compareNames);

    final unflaggedWithTick = unflagged.where((e) => e.uploadFlag == "1").toList()..sort(compareNames);
    final unflaggedWithoutTick = unflagged.where((e) => e.uploadFlag != "1").toList()..sort(compareNames);

    return [
      ...flaggedWithTick,
      ...flaggedWithoutTick,
      ...unflaggedWithTick,
      ...unflaggedWithoutTick,
    ];
  }

  void _updateDisplayedPermissions() {
    if (permissionDetailsAllReponse == null) {
      permissionDetailsReponse = [];
      return;
    }

    permissionDetailsIodReponse = permissionDetailsAllReponse!
        .where((e) => e.selectType == "1")
        .toList();
    permissionDetailsCcReponse = permissionDetailsAllReponse!
        .where((e) => e.selectType == "2")
        .toList();
    permissionDetailsOcReponse = permissionDetailsAllReponse!
        .where((e) => e.selectType == "3")
        .toList();

    List<PermissionDetail> list;
    if (check == "1") {
      list = List.from(permissionDetailsIodReponse!);
    } else if (check == "2") {
      list = List.from(permissionDetailsCcReponse!);
    } else if (check == "3") {
      list = List.from(permissionDetailsOcReponse!);
    } else {
      list = List.from(permissionDetailsAllReponse!);
    }

    String searchTerm = editingController.text.trim();
    if (searchTerm.isNotEmpty) {
      list = list
          .where((person) => (person.permissionName ?? '')
              .toLowerCase()
              .contains(searchTerm.toLowerCase()))
          .toList();
    }

    permissionDetailsReponse = list;
  }

  /// Segregates permission list into respective tabs (IOD, CC, OC)
  filterData({required List<PermissionDetail>? dataa}) {
    permissionDetailsIodReponse = [];
    permissionDetailsCcReponse = [];
    permissionDetailsOcReponse = [];
    if (dataa == null) return;
    for (PermissionDetail item in dataa) {
      if (item.selectType == "1") {
        permissionDetailsIodReponse!.add(item);
      } else if (item.selectType == "2") {
        permissionDetailsCcReponse!.add(item);
      } else if (item.selectType == "3") {
        permissionDetailsOcReponse!.add(item);
      }
    }
  }

  String mapNewStatusToLegacy(String? newStatus) {
    if (newStatus == null) return "0";
    switch (newStatus.trim()) {
      case "Pending":
        return "0";
      case "Applied":
        return "1";
      case "In Process":
        return "2";
      case "Issued":
        return "3";
      case "Payment Due":
        return "4";
      case "Rejected":
        return "5";
      case "Document Missing":
        return "6";
      case "Not Applied":
        return "7";
      case "Paid":
        return "8";
      default:
        return "0";
    }
  }

  String mapLegacyStatusToNew(String? legacyStatus) {
    if (legacyStatus == null) return "Pending";
    switch (legacyStatus.trim()) {
      case "0":
        return "Pending";
      case "1":
        return "Applied";
      case "2":
        return "In Process";
      case "3":
        return "Issued";
      case "4":
        return "Payment Due";
      case "5":
        return "Rejected";
      case "6":
        return "Document Missing";
      case "7":
        return "Not Applied";
      case "8":
        return "Paid";
      default:
        return "Pending";
    }
  }

  String formatExpiryDateDisplay(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "";
    try {
      String datePart = dateStr.contains('T') ? dateStr.split('T')[0] : dateStr;
      DateTime parsed = DateTime.parse(datePart.trim());
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  String formatLastUpdatedDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "";
    try {
      String datePart = dateStr.contains('T') ? dateStr.split('T')[0] : dateStr;
      DateTime parsed = DateTime.parse(datePart.trim());
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  String _pickLatestDate(String date1, String date2) {
    if (date1.isEmpty) return date2;
    if (date2.isEmpty) return date1;

    DateTime? dt1 = _parseAnyDate(date1);
    DateTime? dt2 = _parseAnyDate(date2);

    if (dt1 != null && dt2 != null) {
      return dt2.isAfter(dt1) ? date2 : date1;
    }
    if (dt2 != null && dt1 == null) return date2;
    if (dt1 != null && dt2 == null) return date1;

    return date2.compareTo(date1) > 0 ? date2 : date1;
  }

  DateTime? _parseAnyDate(String str) {
    if (str.isEmpty) return null;
    String clean = str.contains('T') ? str.split('T')[0] : str.trim();
    try {
      return DateTime.parse(clean);
    } catch (_) {}
    try {
      return DateTime.parse(str.trim());
    } catch (_) {}
    try {
      return DateFormat("d MMM yyyy").parse(clean);
    } catch (_) {}
    try {
      return DateFormat("dd/MM/yyyy").parse(clean);
    } catch (_) {}
    return null;
  }

  /// REST call to fetch all permissions mapped to this project/employee
  Future<ProjectPermissionResponse?> getAllPermission() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    if (AppUrl.useNewBackend) {
      String userRole = prefs.getString('userProfile') ?? "";
      String parentDevId = prefs.getString('parentDeveloperId') ?? "";

      // If we don't have userRole or parentDevId cached, let's fetch from /auth/me
      if (userRole.isEmpty || (userRole == "user" && parentDevId.isEmpty)) {
        try {
          var meResponse = await apiNetworkHandler.get("${AppUrl.baseURL}auth/me");
          if (meResponse != null && (meResponse.statusCode == 200 || meResponse.statusCode == 201)) {
            final decodedMe = json.decode(meResponse.body);
            if (decodedMe['success'] == true && decodedMe['data'] != null) {
              userRole = decodedMe['data']['role'] ?? "";
              parentDevId = decodedMe['data']['parent_developer_id']?.toString() ?? "";
              prefs.setString('userProfile', userRole);
              prefs.setString('parentDeveloperId', parentDevId);
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error fetching me details: $e");
          }
        }
      }

      String targetProfileId = (widget.assignToId != null &&
              widget.assignToId!.isNotEmpty &&
              widget.assignToId != '0')
          ? widget.assignToId!
          : "";

      if (targetProfileId.isEmpty && widget.projectId != null && widget.projectId!.isNotEmpty) {
        try {
          var projResp = await apiNetworkHandler.getWithMasterToken(AppUrl.getMobileProjectList);
          if (projResp != null && (projResp.statusCode == 200 || projResp.statusCode == 201)) {
            final decodedProjs = json.decode(projResp.body);
            if (decodedProjs['success'] == true && decodedProjs['data'] != null) {
              final List pList = (decodedProjs['data'] is Map ? decodedProjs['data']['projects'] : decodedProjs['data']) as List? ?? [];
              for (var p in pList) {
                if (p is Map && p['id']?.toString() == widget.projectId?.toString()) {
                  targetProfileId = p['profile_id']?.toString() ??
                      p['user_profile_id']?.toString() ??
                      p['profileId']?.toString() ??
                      "";
                  break;
                }
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error fetching profile_id from GET /projects/mobile: $e");
          }
        }
      }

      // Fetch users for assignment list asynchronously (GET /users/project/:projectId)
      List<AssingToList> tempUsers = [];
      try {
        String usersUrl = "${AppUrl.baseURL}users/project/${widget.projectId}";
        var usersResponse = await apiNetworkHandler.get(usersUrl);
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
              String uId = u['id']?.toString() ?? u['user_id']?.toString() ?? u['user']?['id']?.toString() ?? "";
              String uName = u['name'] ?? u['user_name'] ?? u['full_name'] ?? u['username'] ?? u['user']?['name'] ?? "";
              if (uId.isNotEmpty) {
                tempUsers.add(AssingToList(
                  transEmpId: uId,
                  transEmpName: uName.isNotEmpty ? uName : uId,
                ));
              }
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching users list: $e");
        }
      }

      String userDisplayName = widget.transEmpName ?? "";
      if (userDisplayName.isEmpty && tempUsers.isNotEmpty) {
        final match = tempUsers.firstWhere(
          (u) => u.transEmpId == targetProfileId,
          orElse: () => AssingToList(transEmpId: "", transEmpName: ""),
        );
        if (match.transEmpName != null && match.transEmpName!.isNotEmpty) {
          userDisplayName = match.transEmpName!;
        }
      }
      if (userDisplayName.isEmpty) {
        userDisplayName = prefs.getString('userName') ?? "";
      }
      if (mounted && userDisplayName.isNotEmpty) {
        setState(() {
          resolvedEmpName = userDisplayName;
        });
      }

      // Ensure active projectToken matches target projectId
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        await apiNetworkHandler.ensureProjectContext(widget.projectId);
      }

      bool showLod = false;
      bool applyDwg = false;
      try {
        if (widget.projectId != null && widget.projectId!.isNotEmpty && widget.projectId != '0') {
          await apiNetworkHandler.ensureProjectContext(widget.projectId);
          var projectResponse = await apiNetworkHandler.get("${AppUrl.baseURL}projects/${widget.projectId}").timeout(const Duration(seconds: 4));
          if (projectResponse != null && (projectResponse.statusCode == 200 || projectResponse.statusCode == 201)) {
            final decodedProject = json.decode(projectResponse.body);
            if (decodedProject['success'] == true && decodedProject['data'] != null) {
              final lodStatus = decodedProject['data']['lod_status']?.toString();
              showLod = lodStatus?.toLowerCase() == 'active' || lodStatus == '1' || lodStatus?.toLowerCase() == 'true';

              final dwgStatus = decodedProject['data']['apply_dwg'];
              applyDwg = dwgStatus == true || dwgStatus?.toString() == 'true' || dwgStatus?.toString() == '1';
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching project settings (lod_status & apply_dwg): $e");
        }
      }
      setState(() {
        _applyDwg = applyDwg;
        _showLod = showLod;
      });

      String url = "${AppUrl.baseURL}permissions/projects/${widget.projectId}";
      if (isFilterArray.isNotEmpty && isFilterArray != "9") {
        String newStatus = mapLegacyStatusToNew(isFilterArray);
        url += "?status=${Uri.encodeComponent(newStatus)}";
      }
      final String? projToken = prefs.getString('projectToken') ?? prefs.getString('masterToken') ?? prefs.getString('token');
      Map<String, String> permHeaders = {
        "Content-type": "application/json",
      };
      if (projToken != null && projToken.isNotEmpty) {
        permHeaders["Authorization"] = "Bearer $projToken";
        permHeaders["projectToken"] = projToken;
        permHeaders["project-token"] = projToken;
        permHeaders["x-project-token"] = projToken;
      }
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        permHeaders["x-project-id"] = widget.projectId!;
      }
      var response = await http.get(Uri.parse(url), headers: permHeaders);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          List<PermissionDetail> tempDetails = [];
          var data = decoded['data'];
          if (data is Map) {
            if (data['lod_status'] != null) {
              final lodStatus = data['lod_status']?.toString();
              _showLod = lodStatus?.toLowerCase() == 'active' || lodStatus == '1' || lodStatus?.toLowerCase() == 'true';
            }
            if (data['apply_dwg'] != null) {
              final dwgStatus = data['apply_dwg'];
              _applyDwg = dwgStatus == true || dwgStatus?.toString() == 'true' || dwgStatus?.toString() == '1';
            }
          }
          List list = [];
          if (data is List) {
            list = data;
          } else if (data is Map && data['permissions'] is List) {
            list = data['permissions'];
          }
          for (var item in list) {
            String selectType = "1";
            dynamic rawType = item['type'] ?? item['permission_type'] ?? item['select_type'] ?? item['stage'];
            if (rawType != null && rawType.toString().trim().isNotEmpty) {
              String str = rawType.toString().trim().toUpperCase();
              if (str == "2" || str == "CC" || str.startsWith("CC") || str.contains("COMMENCEMENT")) {
                selectType = "2";
              } else if (str == "3" || str == "OC" || str.startsWith("OC") || str.contains("OCCUPANCY")) {
                selectType = "3";
              } else {
                selectType = "1";
              }
            } else {
              String name = (item['name'] ?? item['permission_name'] ?? '').toString().toUpperCase();
              if (name.contains("COMMENCEMENT") || name.startsWith("CC ") || name.contains(" CC ") || name.contains("(CC)") || name.endsWith(" CC")) {
                selectType = "2";
              } else if (name.contains("OCCUPANCY") || name.startsWith("OC ") || name.contains(" OC ") || name.contains("(OC)") || name.endsWith(" OC")) {
                selectType = "3";
              } else if (name.contains("DISAPPROVAL") || name.startsWith("IOD ") || name.contains(" IOD ") || name.contains("(IOD)") || name.endsWith(" IOD")) {
                selectType = "1";
              } else {
                selectType = "1";
              }
            }

            List<SubPermission> subPerms = [];
            bool hasFiles = false;
            var docSections = item['document_sections'];
            if (docSections is Map) {
              final sectionNames = ["permission", "demand_note", "receipt_note"];
              final sectionDisplayNames = {
                "permission": "Permission",
                "demand_note": "Demand Note",
                "receipt_note": "Receipt Note"
              };

              for (var secKey in sectionNames) {
                var secData = docSections[secKey];
                if (secData is Map) {
                  List<String> pdfList = [];
                  String latestUpdate = "";
                  var files = secData['files'];
                  if (files is List && files.isNotEmpty) {
                    hasFiles = true;
                    for (var f in files) {
                      String fId = "";
                      String fName = "";
                      String fUpdatedAt = "";
                      String fViewUrl = "";
                      if (f is Map) {
                        fId = f['file_id']?.toString() ?? f['id']?.toString() ?? f['fileId']?.toString() ?? "";
                        fName = f['file_name'] ?? f['filename'] ?? f['name'] ?? "Document.pdf";
                        fUpdatedAt = f['uploaded_at']?.toString() ??
                            f['updatedAt']?.toString() ??
                            f['updated_at']?.toString() ??
                            f['created_at']?.toString() ??
                            f['createdAt']?.toString() ??
                            f['created_on']?.toString() ??
                            f['uploaded_on']?.toString() ??
                            "";
                        fViewUrl = f['view_url'] ?? "";
                      } else {
                        fName = f.toString();
                      }
                      if (fUpdatedAt.isNotEmpty) {
                        latestUpdate = _pickLatestDate(latestUpdate, fUpdatedAt);
                      }
                      pdfList.add(fViewUrl.isNotEmpty ? "$fId|$fName|$fViewUrl" : (fId.isNotEmpty ? "$fId|$fName" : fName));
                    }
                  }

                  var dwgFiles = secData['dwg_files'];
                  if (dwgFiles is List && dwgFiles.isNotEmpty) {
                    hasFiles = true;
                    for (var f in dwgFiles) {
                      String fId = "";
                      String fName = "";
                      String fUpdatedAt = "";
                      String fViewUrl = "";
                      if (f is Map) {
                        fId = f['file_id']?.toString() ?? f['id']?.toString() ?? f['fileId']?.toString() ?? "";
                        fName = f['file_name'] ?? f['filename'] ?? f['name'] ?? "Document.dwg";
                        fUpdatedAt = f['uploaded_at']?.toString() ??
                            f['updatedAt']?.toString() ??
                            f['updated_at']?.toString() ??
                            f['created_at']?.toString() ??
                            f['createdAt']?.toString() ??
                            f['created_on']?.toString() ??
                            f['uploaded_on']?.toString() ??
                            "";
                        fViewUrl = f['view_url'] ?? "";
                      } else {
                        fName = f.toString();
                      }
                      if (fUpdatedAt.isNotEmpty) {
                        latestUpdate = _pickLatestDate(latestUpdate, fUpdatedAt);
                      }
                      pdfList.add(fViewUrl.isNotEmpty ? "$fId|$fName|$fViewUrl" : (fId.isNotEmpty ? "$fId|$fName" : fName));
                    }
                  }

                  String secUpdatedAt = secData['updated_at']?.toString() ??
                      secData['updatedAt']?.toString() ??
                      secData['last_update_date']?.toString() ??
                      secData['last_updated']?.toString() ??
                      secData['created_at']?.toString() ??
                      secData['createdAt']?.toString() ??
                      "";
                  if (secUpdatedAt.isNotEmpty) {
                    latestUpdate = _pickLatestDate(latestUpdate, secUpdatedAt);
                  }

                  subPerms.add(SubPermission(
                    id: secData['id']?.toString() ?? secData['document_id']?.toString() ?? secData['document_section_id']?.toString() ?? "",
                    subPermissionName: sectionDisplayNames[secKey] ?? secKey,
                    subPermissionPdf: pdfList,
                    lastUpdateDate: latestUpdate.contains('T') ? latestUpdate.split('T')[0] : latestUpdate,
                    supportedTypes: secData['supported_types'] is List
                        ? List<String>.from(secData['supported_types'].map((x) => x.toString()))
                        : [],
                    isDisabled: false,
                  ));
                } else {
                  subPerms.add(SubPermission(
                    id: "",
                    subPermissionName: sectionDisplayNames[secKey] ?? secKey,
                    subPermissionPdf: [],
                    lastUpdateDate: "",
                    supportedTypes: [],
                    isDisabled: true,
                  ));
                }
              }
            } else {
              var filesList = item['files'] ?? 
                  item['documents'] ?? 
                  item['sub_permissions'];
              if (filesList is List && filesList.isNotEmpty) {
                hasFiles = true;
                for (var file in filesList) {
                  String fileId = "";
                  String fileName = "";
                  String updatedAt = "";
                  if (file is Map) {
                    fileId = file['file_id']?.toString() ?? file['id']?.toString() ?? file['fileId']?.toString() ?? "";
                    fileName = file['file_name'] ?? file['filename'] ?? file['name'] ?? "Document.pdf";
                    updatedAt = file['uploaded_at'] ?? file['updatedAt'] ?? file['updated_at'] ?? "";
                  } else {
                    fileName = file.toString();
                  }
                  subPerms.add(SubPermission(
                    id: fileId,
                    subPermissionName: fileName,
                    subPermissionPdf: [fileId.isNotEmpty ? "$fileId|$fileName" : fileName],
                    lastUpdateDate: updatedAt.contains('T') ? updatedAt.split('T')[0] : updatedAt,
                  ));
                }
              } else {
                subPerms.add(SubPermission(
                  id: "",
                  subPermissionName: item['name'] ?? "Drawing",
                  subPermissionPdf: [],
                  lastUpdateDate: "",
                ));
              }
            }

            var lods = item['lod_list'] ?? item['lod_documents'] ?? item['document_sections']?['lod_files'] ?? [];
            List<LodList> tempLods = [];
            if (lods is List) {
              for (var lod in lods) {
                if (lod is Map) {
                  // Skip if the document itself is explicitly marked inactive
                  if (lod.containsKey('isActive') && (lod['isActive'] == false || lod['isActive']?.toString() == 'false')) {
                    continue;
                  }

                  String docId = lod['document_id']?.toString() ?? lod['id']?.toString() ?? lod['trans_lod_document_id']?.toString() ?? "";
                  String docName = lod['name'] ?? lod['document_name'] ?? "";

                  List<LodAttachment> tempAttachments = [];
                  Set<String> seenFileIds = {};

                  void processFiles(dynamic filesList) {
                    if (filesList is List) {
                      for (var f in filesList) {
                        if (f is Map) {
                          // Check isActive for individual file
                          if (f.containsKey('isActive') && (f['isActive'] == false || f['isActive']?.toString() == 'false')) {
                            continue; // Skip inactive file
                          }
                          String fileId = f['file_id']?.toString() ?? f['id']?.toString() ?? f['fileId']?.toString() ?? "";
                          String fileName = f['file_name'] ?? f['filename'] ?? f['name'] ?? "";
                          String viewUrl = f['view_url'] ?? f['ai_view_url'] ?? "";

                          String key = fileId.isNotEmpty ? fileId : fileName;
                          if (key.isNotEmpty && !seenFileIds.contains(key)) {
                            seenFileIds.add(key);
                            tempAttachments.add(LodAttachment(
                              fileId: fileId,
                              fileName: fileName,
                              viewUrl: viewUrl,
                            ));
                          }
                        }
                      }
                    }
                  }

                  processFiles(lod['attachments']);
                  processFiles(lod['files']);
                  processFiles(lod['dwg_files']);

                  tempLods.add(LodList(
                    transLodDocumentId: docId,
                    fileName: tempAttachments.isNotEmpty ? tempAttachments.first.fileName : "",
                    documentName: docName,
                    status: lod['status']?.toString() ?? "",
                    attachments: tempAttachments,
                  ));
                }
              }
            }

            String expDateStr = item['exp_date'] ?? "";
            bool isExpired = false;
            if (expDateStr.isNotEmpty) {
              try {
                String cleanDate = expDateStr.contains('T') ? expDateStr.split('T')[0] : expDateStr;
                DateTime parsed = DateTime.parse(cleanDate.trim());
                DateTime now = DateTime.now();
                DateTime today = DateTime(now.year, now.month, now.day);
                DateTime exp = DateTime(parsed.year, parsed.month, parsed.day);
                if (exp.isBefore(today)) {
                  isExpired = true;
                }
              } catch (_) {}
            }

            String assignId = "";
            String assignName = "";

            if (item['assigned_to'] is Map) {
              assignId = item['assigned_to']['id']?.toString() ?? item['assigned_to']['user_id']?.toString() ?? "";
              assignName = item['assigned_to']['name']?.toString() ?? item['assigned_to']['user_name']?.toString() ?? item['assigned_to']['full_name']?.toString() ?? "";
            } else if (item['assigned_user'] is Map) {
              assignId = item['assigned_user']['id']?.toString() ?? item['assigned_user']['user_id']?.toString() ?? "";
              assignName = item['assigned_user']['name']?.toString() ?? item['assigned_user']['user_name']?.toString() ?? item['assigned_user']['full_name']?.toString() ?? "";
            } else if (item['assigned_user_details'] is Map) {
              assignId = item['assigned_user_details']['id']?.toString() ?? item['assigned_user_details']['user_id']?.toString() ?? "";
              assignName = item['assigned_user_details']['name']?.toString() ?? item['assigned_user_details']['user_name']?.toString() ?? item['assigned_user_details']['full_name']?.toString() ?? "";
            } else if (item['user'] is Map) {
              assignId = item['user']['id']?.toString() ?? item['user']['user_id']?.toString() ?? "";
              assignName = item['user']['name']?.toString() ?? item['user']['user_name']?.toString() ?? item['user']['full_name']?.toString() ?? "";
            }

            if (assignId.isEmpty) {
              if (item['assigned_user_id'] != null) {
                assignId = item['assigned_user_id'].toString();
              } else if (item['assigned_to'] != null && item['assigned_to'] is! Map) {
                assignId = item['assigned_to'].toString();
              } else if (item['user_id'] != null) {
                assignId = item['user_id'].toString();
              }
            }

            if (assignName.isEmpty) {
              assignName = item['assigned_user_name']?.toString() ??
                  item['assigned_to_name']?.toString() ??
                  item['user_name']?.toString() ??
                  "";
            }

            if (assignName.isEmpty && assignId.isNotEmpty) {
              final user = tempUsers.firstWhere(
                (u) => u.transEmpId == assignId,
                orElse: () => AssingToList(transEmpId: "", transEmpName: ""),
              );
              if (user.transEmpName != null && user.transEmpName!.isNotEmpty) {
                assignName = user.transEmpName!;
              }
            }

            tempDetails.add(PermissionDetail(
              assignToName: assignName,
              assingToId: assignId,
              permissionName: item['name'] ?? "",
              permissionRemark: item['remark'] ?? "",
              transProjectPerId: item['id']?.toString() ?? "",
              expDate: item['exp_date'] ?? "",
              status: mapNewStatusToLegacy(item['permission_status']),
              selectType: selectType,
              permissionFlag: item['permission_flag'] ?? "",
              subPermission: subPerms,
              lodList: tempLods,
              expDateActual: item['exp_date'] ?? "",
              uploadFlag: hasFiles ? "1" : "0",
              isExpring: isExpired ? "1" : "0",
            ));
          }

          tempDetails = _sortPermissionsWithPriority(tempDetails);

          if (isFilterArray.isNotEmpty) {
            if (isFilterArray == "9") {
              tempDetails = tempDetails.where((e) => e.isExpring == "1").toList();
            } else {
              tempDetails = tempDetails.where((e) => e.status == isFilterArray).toList();
            }
          }

          // Filter client-side strictly by matching profile_id from GET /projects/mobile
          if (targetProfileId.isNotEmpty && targetProfileId != '0') {
            tempDetails = tempDetails.where((e) {
              final String itemAssignId = e.assingToId?.toString() ?? "";
              return itemAssignId == targetProfileId;
            }).toList();
          }

          permissionDetailsAllReponse = tempDetails;
          filterData(dataa: tempDetails);

          int iodCount = permissionDetailsIodReponse?.length ?? 0;
          int ccCount = permissionDetailsCcReponse?.length ?? 0;
          int ocCount = permissionDetailsOcReponse?.length ?? 0;
          int allCount = tempDetails.length;

          setState(() {
            assingToList = tempUsers;
            selectDetailsReponse = [
              SelectDetail(name: "All", selectType: "0", totalCount: allCount.toString()),
              SelectDetail(name: "IOD", selectType: "1", totalCount: iodCount.toString()),
              SelectDetail(name: "CC", selectType: "2", totalCount: ccCount.toString()),
              SelectDetail(name: "OC", selectType: "3", totalCount: ocCount.toString()),
            ];

            permissionLodFlag = _showLod ? "1" : "0";
            permissionDetailsAllReponse = tempDetails;
            _updateDisplayedPermissions();
          });
        }
      }
      return null;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId!,
      "assign_to_id": widget.assignToId ?? '0',
      "filter": isFilterArray,
    };
    var response =
        await apiNetworkHandler.post(AppUrl.webGetProjectPermission, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = projectPermissionFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        List<PermissionDetail> detailsList = dataModel.response?.permissionDetails ?? [];
        for (var d in detailsList) {
          if (d.selectType == null || d.selectType!.isEmpty) {
            d.selectType = "1";
          } else {
            String str = d.selectType!.trim().toUpperCase();
            if (str == "2" || str == "CC" || str.startsWith("CC")) {
              d.selectType = "2";
            } else if (str == "3" || str == "OC" || str.startsWith("OC")) {
              d.selectType = "3";
            } else {
              d.selectType = "1";
            }
          }
        }
        detailsList = _sortPermissionsWithPriority(detailsList);
        permissionDetailsAllReponse = detailsList;
        filterData(dataa: detailsList);
        setState(() {
          selectDetailsReponse = dataModel.response?.selectDetails;
          permissionDetailsAllReponse = detailsList;
          _updateDisplayedPermissions();
        });
      }
    }
    return null;
  }

  /// REST call to update status of a selected permission item
  Future<ProjectPermissionResponse?> changetatusWebervice(
      {required String transProjectPerId,
      required final PermissionDetail? details}) async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    if (AppUrl.useNewBackend) {
      String newStatus = mapLegacyStatusToNew(selectedSortBy);
      Map<String, dynamic> body = {
        "permission_status": newStatus,
      };
      await apiNetworkHandler.put(
        "${AppUrl.baseURL}permissions/projects/${widget.projectId}/$transProjectPerId",
        body,
      );
      return null;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "trans_project_per_id": transProjectPerId,
      "permission_status": selectedSortBy,
    };
    await apiNetworkHandler.post(AppUrl.webUpdatePermissionStatus, data);
    return null;
  }

  /// REST call to assign permission tracking to another employee
  Future<ProjectPermissionResponse?> changeProjectPermissionAssign(
      {required String transProjectPerId, required String assignTo}) async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    if (AppUrl.useNewBackend) {
      Map<String, dynamic> body = {
        "assign_to": assignTo == "0" ? null : assignTo,
        "assigned_to": assignTo == "0" ? null : assignTo,
        "assigned_user_id": assignTo == "0" ? null : assignTo,
        "assign_to_id": assignTo == "0" ? null : assignTo,
        "assignTo": assignTo == "0" ? null : assignTo,
        "assignedTo": assignTo == "0" ? null : assignTo,
      };
      var response = await apiNetworkHandler.put(
        "${AppUrl.baseURL}permissions/projects/${widget.projectId}/$transProjectPerId",
        body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await getAllPermission();
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${response.statusCode}"),
            ),
          );
        }
      }
      return null;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "trans_project_per_id": transProjectPerId,
      "assign_to_id": assignTo,
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
    };
    var response =
        await apiNetworkHandler.post(AppUrl.webProjectPermissionAssign, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      getAllPermission();
      if (mounted) {
        Navigator.pop(context);
      }
    }
    return null;
  }

  /// REST Multipart upload call to upload permission drawings (PDFs/Images)
  uploadPermissionDoc({
    required String transProjectId,
    required PermissionDetail details,
    int? k,
  }) async {
    if (AppUrl.useNewBackend) {
      final String uploadUrl = "${AppUrl.baseURL}permissions/projects/${widget.projectId}/${details.transProjectPerId}/documents/upload";
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      final SharedPreferences prefs = await _prefs;
      // All uploads inside a project MUST use the project token
      String? token = prefs.getString('projectToken') ?? prefs.getString('masterToken') ?? prefs.getString('token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['x-project-id'] = widget.projectId.toString();

      request.fields['document_id'] = transProjectId;
      String subDocType = "permission";
      if (k != null && details.subPermission != null && k < details.subPermission!.length) {
        final String? subName = details.subPermission![k].subPermissionName?.toLowerCase();
        if (subName == "demand note" || subName == "demand_note") {
          subDocType = "demand_note";
        } else if (subName == "receipt note" || subName == "receipt_note") {
          subDocType = "receipt_note";
        }
      }
      request.fields['sub_document_type'] = subDocType;

      PlatformFile file = arrayFiles[0];
      String mainType = 'application';
      String subType = 'pdf';
      if (file.extension?.toLowerCase() == 'dwg') {
        mainType = 'application';
        subType = 'octet-stream';
      } else if (file.extension?.toLowerCase() == 'png') {
        mainType = 'image';
        subType = 'png';
      } else if (file.extension?.toLowerCase() == 'jpg' || file.extension?.toLowerCase() == 'jpeg') {
        mainType = 'image';
        subType = 'jpeg';
      }

      request.files.add(await http.MultipartFile.fromPath(
        "file",
        file.path.toString(),
        contentType: MediaType(mainType, subType),
      ));

      var response = request.send();
      var responsed = await http.Response.fromStream(await response);

      if (responsed.statusCode == 200 || responsed.statusCode == 201) {
        if (k != null && details.subPermission != null && k < details.subPermission!.length) {
          String todayStr = DateFormat("d MMM yyyy").format(DateTime.now());
          details.subPermission![k].lastUpdateDate = todayStr;
        }
        await getAllPermission();
        setState(() {
          arrayFiles = [];
          arrayFilesBytes = [];
        });
      }
      return;
    }

    var request = http.MultipartRequest(
        'POST', Uri.parse(AppUrl.wsUploadPermisionDiagram));

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
    });

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    request.fields['user_id'] = userId!;
    request.fields['trans_project_per_id'] = transProjectId;
    request.fields['drawing_is_pdf'] = "1";

    PlatformFile file = arrayFiles[0];
    request.files.add(await http.MultipartFile.fromPath(
      "permisionimg",
      file.path.toString(),
      contentType: MediaType('application/pdf', file.extension ?? ""),
    ));

    var response = await request.send();
    var responsed = await http.Response.fromStream(response);
    final responseData = json.decode(responsed.body);

    if (response.statusCode == 200) {
      final dataModel = uploadPermissionDiagraMResponseFromJson(responsed.body);
      setState(() {
        arrayFiles = [];
        arrayFilesBytes = [];
        int idx = k ?? 0;
        if (details.subPermission != null && idx < details.subPermission!.length) {
          details.subPermission![idx].subPermissionPdf ??= [];
          details.subPermission![idx].subPermissionPdf!.add(dataModel.response?.documentName ?? '');
          details.subPermission![idx].lastUpdateDate =
              DateFormat("d MMM yyyy").format(DateTime.now());
        }
        details.uploadFlag = "1";
      });

      if (kDebugMode) {
        print(responseData);
      }
    }
  }

  /// REST call to set the expiry date and comments for permission
  Future<ProjectPermissionResponse?> setPermisionRemarkWebervice({
    required PermissionDetail details,
    required String transProjectPerId,
  }) async {
    String formatDate(DateTime dateTime) {
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    }

    if (AppUrl.useNewBackend) {
      String formattedDate = _selectedExpiryDate == null ? "" : formatDate(_selectedExpiryDate!);
      Map<String, dynamic> body = {
        "exp_date": formattedDate,
        "remark": remarkControler.text,
      };
      var response = await apiNetworkHandler.put(
        "${AppUrl.baseURL}permissions/projects/${widget.projectId}/$transProjectPerId",
        body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        bool isExpired = false;
        if (_selectedExpiryDate != null) {
          DateTime now = DateTime.now();
          DateTime today = DateTime(now.year, now.month, now.day);
          DateTime exp = DateTime(_selectedExpiryDate!.year, _selectedExpiryDate!.month, _selectedExpiryDate!.day);
          if (exp.isBefore(today)) {
            isExpired = true;
          }
        }
        setState(() {
          details.expDate = formattedDate;
          details.permissionRemark = remarkControler.text;
          details.isExpring = isExpired ? "1" : "0";
        });
      }
      return null;
    }

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "trans_project_per_id": transProjectPerId,
      "exp_date": formatDate(_selectedExpiryDate!),
      "permission_remark": remarkControler.text,
    };

    var response =
        await apiNetworkHandler.post(AppUrl.webSetPermissionRemark, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = permissionPersionResponseFromJson(response.body);
      if (dataModel.response?.remarkData?.expDate != "") {
        setState(() {
          details.expDate = dataModel.response?.remarkData?.expDate;
          details.permissionRemark = dataModel.response?.remarkData?.remark;
        });
      }
    }
    return null;
  }

  // Permission statuses tracking list
  List state = [
    'Pending',
    'Applied',
    'In Process',
    'Issued',
    'Payment Due',
    'Rejected',
    "Doc Missing",
    'Not Applied',
    'Paid',
  ];

  // Specific color theme mapping for each status
  List<Color> stateColor = [
    Colors.grey,
    const Color.fromRGBO(224, 159, 29, 1.0),
    const Color.fromRGBO(224, 159, 29, 1.0),
    const Color.fromRGBO(54, 128, 25, 1.0),
    const Color.fromRGBO(189, 9, 9, 1.0),
    const Color.fromRGBO(189, 9, 9, 1.0),
    const Color.fromRGBO(189, 9, 9, 1.0),
    const Color.fromRGBO(189, 9, 9, 1.0),
    const Color.fromRGBO(54, 128, 25, 1.0),
  ];

  String check = "0";
  int status = 0;
  String selectedSortBy = "";

  /// Redesigned premium dialog for changing permission status
  changeStatusModal({required final PermissionDetail? details}) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context1, setState2) {
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                child: const Text(
                  "Change Status",
                  style: TextStyle(
                    fontFamily: 'HelveticaNeue',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ModernDialogButton(
                    text: 'Close',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
              content: SizedBox(
                height: 300,
                width: 400,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.length,
                  itemBuilder: (context, i) {
                    final bool isSelected = selectedSortBy == i.toString();
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.15))),
                      ),
                      margin: const EdgeInsets.only(bottom: 6),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xfff8f9fa) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: RadioListTile<String>(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          activeColor: Colors.black,
                          title: Text(
                            state[i],
                            style: TextStyle(
                              fontFamily: 'HelveticaNeue',
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.black : Colors.black87,
                            ),
                          ),
                          value: i.toString(),
                          groupValue: selectedSortBy,
                          onChanged: (value) {
                            setState2(() {
                              selectedSortBy = value ?? '';
                            });
                            changetatusWebervice(
                                    transProjectPerId: details?.transProjectPerId ?? '',
                                    details: details)
                                .then((value) {
                              setState2(() {
                                details?.status = selectedSortBy;
                              });
                              getAllPermission();
                              Navigator.pop(context1);
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          });
        });
  }

  /// Redesigned premium dialog for assigning tracking to a different user
  changeAssignToModal({required String transProjectPerId}) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context1, setState2) {
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
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
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
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
                          onTap: () {
                            changeProjectPermissionAssign(
                                transProjectPerId: transProjectPerId,
                                assignTo: transEmpId);
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
              content: SizedBox(
                height: 300,
                width: 400,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: assingToList?.length ?? 0,
                  itemBuilder: (context, i) {
                    final item = assingToList?[i];
                    final bool isAssigned = transEmpId == item?.transEmpId;
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.15))),
                      ),
                      margin: const EdgeInsets.only(bottom: 6),
                      child: InkWell(
                        onTap: () {
                          setState2(() {
                            if (isAssigned) {
                              transEmpId = "0";
                            } else {
                              transEmpId = item?.transEmpId ?? '0';
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isAssigned ? const Color(0xfff8f9fa) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item?.transEmpName ?? '',
                                style: TextStyle(
                                  fontFamily: 'HelveticaNeue',
                                  fontSize: 15,
                                  fontWeight: isAssigned ? FontWeight.w700 : FontWeight.w500,
                                  color: isAssigned ? Colors.black : Colors.black87,
                                ),
                              ),
                              Icon(
                                isAssigned
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.circle_outlined,
                                color: isAssigned ? Colors.green : Colors.grey,
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
            );
          });
        });
  }

  showAttachmentSelectionModal({required LodList item, required PermissionDetail details}) {
    final attachments = item.attachments ?? [];
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          title: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            width: double.infinity,
            child: Text(
              item.documentName ?? "Select Document",
              style: const TextStyle(
                fontFamily: 'HelveticaNeue',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ModernDialogButton(
                text: "Back",
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
          content: SizedBox(
            height: 300,
            width: 500,
            child: attachments.isEmpty
                ? const Center(
                    child: Text(
                      "No Documents Uploaded",
                      style: TextStyle(
                        fontFamily: 'HelveticaNeue',
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  )
                : SingleChildScrollView(
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
                            for (var att in attachments)
                              Builder(
                                builder: (context) {
                                  final displayFileName = att.fileName ?? "Document";
                                  return InkWell(
                                    onTap: () async {
                                      Navigator.pop(context);
                                      if (AppUrl.useNewBackend) {
                                        String fileUrl = "";
                                        if (att.viewUrl != null && att.viewUrl!.isNotEmpty) {
                                          fileUrl = att.viewUrl!.startsWith('http')
                                              ? att.viewUrl!
                                              : "${AppUrl.baseURL.replaceAll(RegExp(r'/+$'), '')}/${att.viewUrl!.replaceAll(RegExp(r'^/+'), '')}";
                                        } else {
                                          String fileId = att.fileId ?? "";
                                          if (fileId.isEmpty && displayFileName.contains('|')) {
                                            fileId = displayFileName.split('|')[0];
                                          }
                                          fileUrl = "${AppUrl.baseURL.replaceAll(RegExp(r'/+$'), '')}/permissions/projects/${widget.projectId}/${details.transProjectPerId}/documents/${item.transLodDocumentId}/files/$fileId";
                                        }
                                        if (displayFileName.toLowerCase().contains('.pdf') || displayFileName.toLowerCase().contains('.dwg')) {
                                          await Navigator.push(
                                            this.context,
                                            MaterialPageRoute(
                                              builder: (_) => PdfViewer(
                                                fileName: displayFileName,
                                                fileUrl: fileUrl,
                                              ),
                                            ),
                                          );
                                        } else {
                                          await Navigator.push(
                                            this.context,
                                            MaterialPageRoute(
                                              builder: (_) => ImagePreviewViewer(
                                                fileName: displayFileName,
                                                fileUrl: fileUrl,
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        (displayFileName.toLowerCase().contains('.pdf') || displayFileName.toLowerCase().contains('.dwg'))
                                            ? await Navigator.push(
                                                this.context,
                                                MaterialPageRoute(
                                                  builder: (_) => PdfViewer(
                                                    fileName: displayFileName,
                                                    fileUrl: AppUrl.permissionLodPath + displayFileName,
                                                  ),
                                                ),
                                              )
                                            : await Navigator.push(
                                                this.context,
                                                MaterialPageRoute(
                                                  builder: (_) => ImagePreviewViewer(
                                                    fileName: displayFileName,
                                                    fileUrl: '${AppUrl.globalPoinvoicePath}$displayFileName',
                                                  ),
                                                ),
                                              );
                                      }
                                      showAttachmentSelectionModal(
                                        item: item,
                                        details: details,
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
                                      width: isMobile ? 100 : 140,
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            displayFileName.toLowerCase().endsWith('.dwg')
                                                ? 'images/projectmanagement/dwg.png'
                                                : 'images/projectmanagement/pdf.png',
                                            width: isMobile ? 60 : 100,
                                            height: isMobile ? 60 : 100,
                                          ),
                                          const SizedBox(height: 6),
                                          AppText(
                                            title: displayFileName,
                                            fontSize: isMobile ? 9 : 12,
                                            titleTextAlign: TextAlign.center,
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  /// Redesigned premium dialog showing sub-document list details
  listOfDocumnetsModal({required List<LodList>? lodListt, required PermissionDetail details}) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              title: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                child: const Text(
                  "List Of Documents",
                  style: TextStyle(
                    fontFamily: 'HelveticaNeue',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ModernDialogButton(
                    text: "Close",
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
              content: SizedBox(
                height: 300,
                width: 400,
                child: lodListt == null || lodListt.isEmpty
                    ? const Center(
                        child: Text(
                          "No Record Found",
                          style: TextStyle(
                            fontFamily: 'HelveticaNeue',
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: lodListt.length,
                        itemBuilder: (context, i) {
                          final item = lodListt[i];
                          final bool hasUploaded = (item.attachments != null && item.attachments!.isNotEmpty) ||
                              (item.fileName != null && item.fileName!.isNotEmpty);
                          return InkWell(
                            onTap: () async {
                              showAttachmentSelectionModal(item: item, details: details);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.15))),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.documentName ?? '',
                                      style: const TextStyle(
                                        fontFamily: 'HelveticaNeue',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  if (hasUploaded)
                                    const Icon(
                                        Icons.check_circle_outline_sharp,
                                        color: Colors.green,
                                        size: 20)
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            );
          });
        });
  }

  /// Redesigned premium dialog picker for setting remark and dates
  setExpiryAndDateModal({required PermissionDetail details}) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              title: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                child: const Text(
                  "Set Expiry Date & Remark",
                  style: TextStyle(
                    fontFamily: 'HelveticaNeue',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ModernDialogButton(
                          text: "Close",
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
                          text: "Submit",
                          onTap: () {
                            setPermisionRemarkWebervice(
                                    transProjectPerId: details.transProjectPerId ?? '',
                                    details: details)
                                .then((value) {
                              getAllPermission();
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              content: SizedBox(
                height: 240,
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        title: "Expiry Date:",
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          _selectStartDate(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xfff8f9fa),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xffe0e0e0)),
                          ),
                          child: TextFormField(
                            enabled: false,
                            readOnly: true,
                            controller: expiryDateControler,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontFamily: 'HelveticaNeue',
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: InputBorder.none,
                              hintText: 'Select Start Date',
                              hintStyle: TextStyle(
                                color: Color(0xff888888),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w400,
                              ),
                              suffixIcon: Icon(
                                Icons.calendar_month_outlined,
                                color: Colors.black87,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const AppText(
                        title: "Add Remark:",
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xfff8f9fa),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xffe0e0e0)),
                        ),
                        child: TextFormField(
                          maxLines: 4,
                          controller: remarkControler,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            fontFamily: 'HelveticaNeue',
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: InputBorder.none,
                            hintText: 'Please Enter Remark',
                            hintStyle: TextStyle(
                              color: Color(0xff888888),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w400,
                            ),
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

  /// Redesigned premium dialog showing PDF documents wrapper
  viewDocumentsModal({required PermissionDetail details, required int index}) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              title: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                child: Text(
                  details.permissionName ?? '',
                  style: const TextStyle(
                    fontFamily: 'HelveticaNeue',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ModernDialogButton(
                    text: 'Close',
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
              content: SizedBox(
                height: 300,
                width: 500,
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
                          for (int i = 0;
                              i < details.subPermission![index].subPermissionPdf!.length;
                              i++)
                            Builder(
                              builder: (context) {
                                String rawPdf = details.subPermission![index].subPermissionPdf![i];
                                String fileId = "";
                                String displayFileName = rawPdf;
                                String fileUrl = "";
                                if (AppUrl.useNewBackend) {
                                  if (rawPdf.contains('|')) {
                                    var parts = rawPdf.split('|');
                                    fileId = parts[0];
                                    displayFileName = parts[1];
                                  }
                                  fileUrl = "${AppUrl.baseURL}permissions/projects/${widget.projectId}/${details.transProjectPerId}/documents/$fileId/view";
                                } else {
                                  fileUrl = '${AppUrl.globalPermissionDocsPath}${rawPdf}';
                                }
                                return InkWell(
                                  onTap: () async {
                                    Navigator.pop(context);
                                    if (displayFileName.toLowerCase().contains('.pdf') || displayFileName.toLowerCase().contains('.dwg')) {
                                      await Navigator.push(
                                        this.context,
                                        MaterialPageRoute(
                                          builder: (_) {
                                            return PdfViewer(
                                              fileName: displayFileName,
                                              fileUrl: fileUrl,
                                            );
                                          },
                                        ),
                                      );
                                    } else {
                                      await Navigator.push(
                                        this.context,
                                        MaterialPageRoute(
                                          builder: (_) {
                                            return ImagePreviewViewer(
                                              fileName: displayFileName,
                                              fileUrl: fileUrl,
                                            );
                                          },
                                        ),
                                      );
                                    }
                                    viewDocumentsModal(
                                      details: details,
                                      index: index,
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
                                    width: isMobile ? 100 : 140,
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          displayFileName.toLowerCase().endsWith('.dwg')
                                              ? 'images/projectmanagement/dwg.png'
                                              : 'images/projectmanagement/pdf.png',
                                          width: isMobile ? 60 : 100,
                                          height: isMobile ? 60 : 100,
                                        ),
                                        const SizedBox(height: 6),
                                        AppText(
                                          title: displayFileName,
                                          fontSize: isMobile ? 9 : 12,
                                          titleTextAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  /// Searches the list locally based on matching term
  searchFunction({required String searchTerm}) {
    _updateDisplayedPermissions();
  }

  @override
  void dispose() {
    _permissionSubscription?.cancel();
    super.dispose();
  }

  void _updateSubPermissionStatus(String permissionId, String field, bool value) {
    String? targetSubName;
    if (field == "permission_note" || field == "permission") {
      targetSubName = "Permission";
    } else if (field == "demand_note") {
      targetSubName = "Demand Note";
    } else if (field == "receipt_note") {
      targetSubName = "Receipt Note";
    }

    if (targetSubName == null) return;

    bool updated = false;
    void updateList(List<PermissionDetail>? list) {
      if (list == null) return;
      for (var detail in list) {
        if (detail.transProjectPerId == permissionId) {
          if (detail.subPermission != null) {
            for (var sub in detail.subPermission!) {
              if (sub.subPermissionName == targetSubName) {
                if (sub.isDisabled != !value) {
                  sub.isDisabled = !value;
                  updated = true;
                }
              }
            }
          }
        }
      }
    }

    updateList(permissionDetailsReponse);
    updateList(permissionDetailsAllReponse);
    updateList(permissionDetailsIodReponse);
    updateList(permissionDetailsCcReponse);
    updateList(permissionDetailsOcReponse);

    if (updated && mounted) {
      setState(() {});
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    getAllPermission();
  }

  @override
  void initState() {
    _permissionSubscription = SocketService.permissionStatusStream.listen((event) {
      final String? projId = event['projectId']?.toString();
      if (projId == widget.projectId) {
        final String? permId = event['permissionId']?.toString();
        final String? field = event['field']?.toString();
        final bool? value = event['value'] as bool?;
        if (permId != null && field != null && value != null) {
          _updateSubPermissionStatus(permId, field, value);
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      CustomLoading.progressDialog(isLoading: true, context: context, skeletonType: CustomLoading.skeletonPermissionList);
      getAllPermission().then((value) =>
          CustomLoading.progressDialog(isLoading: false, context: context));
    });
    super.initState();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    DateTime initialDate = _selectedExpiryDate ?? today;
    // Ensure initial date is not before today
    if (initialDate.isBefore(today)) {
      initialDate = today;
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedExpiryDate) {
      setState(() {
        _selectedExpiryDate = picked;
        expiryDateControler.text =
            DateFormat('dd/MM/yyyy').format(_selectedExpiryDate!);
      });
    }
  }

  String _getCategoryCountDisplay(String? selectType) {
    if (permissionDetailsAllReponse == null) return "0/0";
    List<PermissionDetail> list;
    if (selectType == "0") {
      list = permissionDetailsAllReponse!;
    } else if (selectType == "1") {
      list = permissionDetailsIodReponse ??
          permissionDetailsAllReponse!.where((e) => e.selectType == "1").toList();
    } else if (selectType == "2") {
      list = permissionDetailsCcReponse ??
          permissionDetailsAllReponse!.where((e) => e.selectType == "2").toList();
    } else if (selectType == "3") {
      list = permissionDetailsOcReponse ??
          permissionDetailsAllReponse!.where((e) => e.selectType == "3").toList();
    } else {
      return "0/0";
    }

    final int total = list.length;
    final int issued = list.where((e) => e.status == "3" || e.status.trim().toLowerCase() == "issued").length;
    return "$issued/$total";
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = isMobile ? 16.0 : 40.0;

    Widget scaffoldContent = Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.towarName != null && widget.towarName!.isNotEmpty
              ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
              : widget.projectName!.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'HelveticaNeue',
            fontWeight: FontWeight.w700,
            fontSize: 16.0,
            letterSpacing: 0.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.0),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Column(
          children: [
            const SizedBox(height: 3),
            // Header Row (Toolbar: filter & title)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      selectFilterModal();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xfff8f9fa),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xffe0e0e0)),
                      ),
                      child: Image.asset(
                        'images/projectmanagement/filter-sort-icon.png',
                        height: 18,
                        width: 18,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Builder(
                    builder: (context) {
                      String nameStr = (widget.transEmpName != null && widget.transEmpName!.isNotEmpty)
                          ? widget.transEmpName!
                          : (resolvedEmpName ?? '');
                      String titleText = nameStr.isNotEmpty
                          ? 'PERMISSIONS - ${nameStr.toUpperCase()}'
                          : 'PERMISSIONS';
                      return Text(
                        titleText,
                        style: const TextStyle(
                          fontFamily: 'HelveticaNeue',
                          fontWeight: FontWeight.w700,
                          fontSize: 15.0,
                          letterSpacing: 0.2,
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            const SizedBox(height: 3),
            const Divider(color: Color(0xfff0f0f0), height: 1.0),
            
            // Redesigned Search input
            Container(
              padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: 3,
                top: 3,
              ),
              child: SizedBox(
                height: 44,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xfff8f9fa),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffe0e0e0)),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      searchFunction(searchTerm: editingController.text);
                      setState(() {});
                    },
                    style: const TextStyle(
                      fontFamily: 'HelveticaNeue',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    controller: editingController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                      labelText: "Search by Name",
                      labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                      hintText: "Search by Name",
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                      suffixIcon: editingController.text.isNotEmpty
                          ? InkWell(
                              onTap: () {
                                setState(() {});
                                editingController.clear();
                                searchFunction(searchTerm: editingController.text);
                              },
                              child: const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
                            )
                          : const SizedBox.shrink(),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            
            // Expandable ListView for permission entries
            Expanded(
              child: permissionDetailsReponse != null && permissionDetailsReponse!.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                      itemCount: permissionDetailsReponse?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        return myExpandableWidgetList(
                          ind: index,
                          details: permissionDetailsReponse?[index],
                          projectName: widget.projectName!,
                          projectId: widget.projectId!,
                          workId: permissionDetailsReponse?[index].permissionId,
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        "No Record Found",
                        style: TextStyle(
                          fontFamily: 'HelveticaNeue',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      
      // Bottom segmented layout navigation bar
      bottomNavigationBar: selectDetailsReponse != null && selectDetailsReponse!.isNotEmpty
          ? Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xfff0f0f0), width: 1.0),
                ),
              ),
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 10.0,
                bottom: isMobile ? 2.0 : 10.0,
              ),
              child: SafeArea(
                child: Container(
                  height: 57.0,
                  decoration: BoxDecoration(
                    color: const Color(0xfff8f9fa),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: const Color(0xffe9ecef), width: 1.0),
                  ),
                  child: Row(
                    children: [
                      for (int j = 0; j < selectDetailsReponse!.length; j++) ...[
                        if (j > 0)
                          Container(
                            height: 20,
                            width: 1.0,
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  isSelectedOpen = -1;
                                  check = selectDetailsReponse?[j].selectType ?? '';
                                  editingController.clear();
                                  _updateDisplayedPermissions();
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  color: check == selectDetailsReponse?[j].selectType
                                      ? Colors.black
                                      : Colors.transparent,
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      selectDetailsReponse?[j].name ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontFamily: 'HelveticaNeue',
                                          fontWeight: FontWeight.w700,
                                          fontSize: isMobile ? 11 : 13,
                                          color: check == selectDetailsReponse?[j].selectType
                                              ? Colors.white
                                              : Colors.black87),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                       _getCategoryCountDisplay(selectDetailsReponse?[j].selectType),
                                       maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontFamily: 'HelveticaNeue',
                                          fontWeight: FontWeight.w600,
                                          fontSize: isMobile ? 10 : 12,
                                          color: check == selectDetailsReponse?[j].selectType
                                              ? Colors.white54
                                              : Colors.black54),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );

    return scaffoldContent;
  }

  /// Builds a modern permission expandable card component
  Widget myExpandableWidgetList({
    final PermissionDetail? details,
    final String? projectId,
    final String? projectName,
    final String? workId,
    required final int ind,
  }) {
    final statusColor = stateColor[int.parse(details?.status ?? '0')];
    final bool isOpened = isSelectedOpen == ind;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: details?.uploadFlag == "1" ? Colors.white : const Color(0xfff8f9fa),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: isOpened ? const Color(0xffd6d6d6) : const Color(0xfff0f0f0), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isOpened ? 0.08 : 0.015),
              blurRadius: isOpened ? 12 : 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.0),
          onTap: () {
            if (AppUrl.useNewBackend || (ind != 0 && ind != 1)) {
              setState(() {
                if (isSelectedOpen == ind) {
                  isSelectedOpen = -1;
                } else {
                  isSelectedOpen = ind;
                }
              });
            } else {
              if (check == "0" || check == "1") {
                viewDocumentsModal(details: details!, index: 0);
              } else {
                setState(() {
                  if (isSelectedOpen == ind) {
                    isSelectedOpen = -1;
                  } else {
                    isSelectedOpen = ind;
                  }
                });
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: AppText(
                              title: details?.permissionName ?? '',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          if (details?.uploadFlag == "1") ...[
                            const SizedBox(width: 8),
                            SvgPicture.asset(
                              'images/projectmanagement/check_icon.svg',
                              height: 18,
                              width: 18,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    
                    // Flag and Premium Status Dropdown Badge
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (details?.permissionFlag?.toLowerCase() == "flag" || details?.permissionFlag == "1") ...[
                          Image.asset(
                            'images/projectmanagement/red_flagI_icon.png',
                            height: 18,
                            width: 18,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 8),
                        ],
                        InkWell(
                          onTap: () {
                            setState(() {
                              selectedSortBy = details?.status ?? '';
                            });
                            changeStatusModal(details: details).then((val) {
                              setState(() {
                                selectedSortBy = details?.status ?? '';
                              });
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            constraints: BoxConstraints(
                              minWidth: isMobile ? 76.0 : 90.0,
                            ),
                            padding: isMobile
                                ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
                                : const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: statusColor,
                            ),
                            child: Text(
                              state[int.parse(details?.status ?? '0')],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'HelveticaNeue',
                                fontSize: 11.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
            const SizedBox(height: 6),
            
            // Form actions row (Expiry and LOD links)
            Row(
              children: [
                InkWell(
                  onTap: () {
                    // Pre-fill with existing data if available
                    setState(() {
                      if (details?.expDate != null && details!.expDate!.isNotEmpty) {
                        try {
                          String datePart = details!.expDate!.contains('T')
                              ? details!.expDate!.split('T')[0]
                              : details!.expDate!;
                          _selectedExpiryDate = DateTime.parse(datePart.trim());
                          expiryDateControler.text =
                              DateFormat('dd/MM/yyyy').format(_selectedExpiryDate!);
                        } catch (_) {
                          expiryDateControler.clear();
                          _selectedExpiryDate = null;
                        }
                      } else {
                        expiryDateControler.clear();
                        _selectedExpiryDate = null;
                      }
                      if (details?.permissionRemark != null && details!.permissionRemark!.isNotEmpty) {
                        remarkControler.text = details!.permissionRemark!;
                      } else {
                        remarkControler.clear();
                      }
                    });
                    setExpiryAndDateModal(details: details!);
                  },
                  child: Container(
                    padding: isMobile
                        ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.2)
                        : const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: details?.isExpring == "1" ? Colors.red : Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: isMobile ? 11.5 : 13.0,
                          color: details?.isExpring == "1" ? Colors.red : Colors.black,
                        ),
                        SizedBox(width: isMobile ? 4.0 : 5.0),
                         Text(
                          details?.expDate?.isNotEmpty == true
                              ? '${details?.isExpring == "1" ? "Expired" : "Expiring"} - ${formatExpiryDateDisplay(details?.expDate)}'
                              : "Set Expiry Date",
                          style: TextStyle(
                            fontFamily: 'HelveticaNeue',
                            color: details?.isExpring == "1" ? Colors.red : Colors.black,
                            fontSize: isMobile ? 12.0 : 12.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (!AppUrl.useNewBackend && (ind == 0 || ind == 1) && (check == '0' || check == '1')) ...[
                  InkWell(
                    onTap: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: _applyDwg ? ['pdf', 'dwg'] : ['pdf'],
                      );
                      if (result != null) {
                        PlatformFile file = result.files.first;
                        Uint8List? fileBytes = result.files.first.bytes;
                        setState(() {
                          arrayFilesBytes.clear();
                          arrayFiles.clear();
                          arrayFilesBytes.add(fileBytes);
                          arrayFiles.add(file);
                        });
                        CustomLoading.progressDialog(isLoading: true, context: context);
                        uploadPermissionDoc(
                          details: details!,
                          transProjectId: details.subPermission?[0].id ?? '',
                          k: 0,
                        ).then((val) {
                          CustomLoading.progressDialog(isLoading: false, context: context);
                          getAllPermission();
                          changeStatusModal(details: details).then((value) {
                            setState(() {
                              cnt = "";
                              selectedSortBy = details.status ?? '';
                            });
                            getAllPermission();
                          });
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.upload_file_rounded, size: 12, color: Colors.black),
                          SizedBox(width: 4),
                          Text(
                            "Upload",
                            style: TextStyle(
                              fontFamily: 'HelveticaNeue',
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (permissionLodFlag == '1' && _showLod) const SizedBox(width: 8),
                ],
                if (permissionLodFlag == '1' && _showLod)
                  InkWell(
                    onTap: () {
                      listOfDocumnetsModal(lodListt: details?.lodList, details: details!);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      child: const Text(
                        "LOD",
                        style: TextStyle(
                          fontFamily: 'HelveticaNeue',
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Comments & Remark Section
            if (details?.permissionRemark?.isNotEmpty == true)
              Container(
                padding: const EdgeInsets.only(top: 6),
                margin: const EdgeInsets.only(top: 2),
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Remark: ',
                        style: TextStyle(
                          fontFamily: 'HelveticaNeue',
                          fontSize: 13,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: details?.permissionRemark ?? '',
                        style: const TextStyle(
                          fontFamily: 'HelveticaNeue',
                          fontSize: 13,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
            // Animated Expansion Panel for Sub-permissions lists
            if (isOpened)
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.only(top: 14),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xfff0f0f0), width: 1.0),
                    ),
                  ),
                  child: Column(
                    children: [
                       for (int k = 0; k < details!.subPermission!.length; k++)
                        (details.subPermission![k].subPermissionPdf != null && details.subPermission![k].subPermissionPdf!.isNotEmpty)
                            ? subPermissionItem(
                                details: details,
                                k: k,
                                isMobile: isMobile,
                                allowedExtensions: _applyDwg
                                    ? ['pdf', 'dwg']
                                    : ['pdf'],
                              )
                            : subPermissionPendingItem(
                                details: details,
                                k: k,
                                isMobile: isMobile,
                                allowedExtensions: _applyDwg
                                    ? ['pdf', 'dwg']
                                    : ['pdf'],
                              )
                    ],
                  ),
                ),
                crossFadeState: isOpened ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              )
          ],
        ),
      ),
    ),
  ),
);
}

  /// Builds a sub-permission detail row
  Widget subPermissionItem({
    required PermissionDetail details,
    required int k,
    required bool isMobile,
    required List<String> allowedExtensions,
  }) {
    final hasPdf = details.subPermission?[k].subPermissionPdf?.length != 0;
    final bool isDisabled = details.subPermission?[k].isDisabled == true;

    final uploadButton = InkWell(
      onTap: isDisabled ? null : () async {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: allowedExtensions,
        );
        if (result != null) {
          PlatformFile file = result.files.first;
          final String? fileExt = file.extension?.toLowerCase();
          if (fileExt != null && !allowedExtensions.contains(fileExt)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Only ${allowedExtensions.join(', ').toUpperCase()} files are allowed.",
                  style: const TextStyle(fontFamily: 'HelveticaNeue'),
                ),
              ),
            );
            return;
          }
          Uint8List? fileBytes = result.files.first.bytes;
          setState(() {
            arrayFilesBytes.clear();
            arrayFiles.clear();
            arrayFilesBytes.add(fileBytes);
            arrayFiles.add(file);
          });

          CustomLoading.progressDialog(isLoading: true, context: context);
          uploadPermissionDoc(
            details: details,
            transProjectId: details.subPermission?[k].id ?? '',
            k: k,
          ).then((val) {
            CustomLoading.progressDialog(isLoading: false, context: context);
            getAllPermission();
            changeStatusModal(details: details).then((value) {
              setState(() {
                cnt = "";
                selectedSortBy = details.status ?? '';
              });
              getAllPermission();
            });
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[200] : Colors.white,
          border: Border.all(color: isDisabled ? Colors.grey : Colors.black),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.upload_file_rounded, size: 12, color: isDisabled ? Colors.grey : Colors.black),
            const SizedBox(width: 4),
            Text(
              "Upload",
              style: TextStyle(
                fontFamily: 'HelveticaNeue',
                color: isDisabled ? Colors.grey : Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    return InkWell(
      onTap: () {
        if (hasPdf) {
          viewDocumentsModal(details: details, index: k);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          details.subPermission?[k].subPermissionName ?? '',
                          style: TextStyle(
                            fontFamily: 'HelveticaNeue',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: hasPdf ? Colors.black87 : Colors.grey,
                          ),
                        ),
                      ),
                      if (hasPdf) ...[
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          'images/projectmanagement/check_icon.svg',
                          height: 18,
                          width: 18,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ],
                  ),
                  if (hasPdf && isMobile) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Last Updated - ${formatLastUpdatedDate(details.subPermission?[k].lastUpdateDate)}',
                      style: TextStyle(
                        fontFamily: 'HelveticaNeue',
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hasPdf && !isMobile) ...[
              const SizedBox(width: 10),
              Text(
                'Last Updated - ${formatLastUpdatedDate(details.subPermission?[k].lastUpdateDate)}',
                style: const TextStyle(
                  fontFamily: 'HelveticaNeue',
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 10),
            ],
            const SizedBox(width: 10),
            uploadButton,
          ],
        ),
      ),
    );
  }

  /// Builds a pending/incomplete sub-permission detail row
  Widget subPermissionPendingItem({
    required PermissionDetail details,
    required int k,
    required bool isMobile,
    required List<String> allowedExtensions,
  }) {
    final bool isDisabled = details.subPermission?[k].isDisabled == true;

    final uploadButton = InkWell(
      onTap: isDisabled ? null : () async {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: allowedExtensions,
        );
        if (result != null) {
          PlatformFile file = result.files.first;
          final String? fileExt = file.extension?.toLowerCase();
          if (fileExt != null && !allowedExtensions.contains(fileExt)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Only ${allowedExtensions.join(', ').toUpperCase()} files are allowed.",
                  style: const TextStyle(fontFamily: 'HelveticaNeue'),
                ),
              ),
            );
            return;
          }
          Uint8List? fileBytes = result.files.first.bytes;
          setState(() {
            arrayFilesBytes.clear();
            arrayFiles.clear();
            arrayFilesBytes.add(fileBytes);
            arrayFiles.add(file);
          });

          CustomLoading.progressDialog(isLoading: true, context: context);
          uploadPermissionDoc(
            details: details,
            transProjectId: details.subPermission?[k].id ?? '',
            k: k,
          ).then((val) {
            CustomLoading.progressDialog(isLoading: false, context: context);
            getAllPermission();
            changeStatusModal(details: details).then((value) {
              setState(() {
                cnt = "";
                selectedSortBy = details.status ?? '';
              });
              getAllPermission();
            });
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[200] : Colors.white,
          border: Border.all(color: isDisabled ? Colors.grey : Colors.black),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.upload_file_rounded, size: 12, color: isDisabled ? Colors.grey : Colors.black),
            const SizedBox(width: 4),
            Text(
              "Upload",
              style: TextStyle(
                fontFamily: 'HelveticaNeue',
                color: isDisabled ? Colors.grey : Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              details.subPermission?[k].subPermissionName ?? '',
              style: const TextStyle(
                fontFamily: 'HelveticaNeue',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 10),
          uploadButton,
        ],
      ),
    );
  }

  /// Redesigned premium dialog for selecting sort order filter
  selectFilterModal() {
    return showDialog<void>(
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                child: const Text(
                  'FILTER',
                  style: TextStyle(
                    fontFamily: 'HelveticaNeue',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ModernDialogButton(
                    text: "Close",
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
              content: SizedBox(
                width: 400,
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: orderShort!.length,
                  itemBuilder: (context, index) {
                    final item = orderShort?[index];
                    final bool isSelected = isFilterArray == item?.id;
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.15))),
                      ),
                      margin: const EdgeInsets.only(bottom: 6),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isFilterArray = item?.id ?? '';
                          });
                          Navigator.of(context).pop();
                          getAllPermission();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xfff8f9fa) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        child: Row(
                          children: [
                            Text(
                              item?.name ?? '',
                              style: TextStyle(
                                fontFamily: 'HelveticaNeue',
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.black : Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              isSelected
                                  ? Icons.check_circle_outline_sharp
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
