import 'dart:convert';
import 'dart:ui';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_all_legal_response.dart';
import 'package:stallion/models/get_project_masonry.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/legal/legal_docs_screen.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:http/http.dart' as http;
import 'package:stallion/websocket/socket_service.dart';

// class LegalScreen extends StatefulWidget {
//   const LegalScreen(
//       {Key? key,
//       this.projectId,
//       this.towarId,
//       this.projectName,
//       this.towarName})
//       : super(key: key);
//   final String? projectId;
//   final String? towarId;
//   final String? projectName;
//   final String? towarName;

//   @override
//   State<LegalScreen> createState() => _LegalScreenState();
// }

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  late NotificationArgs args;
  bool _isLoading = true;
  int _selectedCardIndex = -1;
  static const bool testWithMockData = false; // Enabled by default for direct offline visual testing

  List<MainCategoryList> _mockCategories = [
    MainCategoryList(id: "0", name: "All", newName: "All", count: "4"),
    MainCategoryList(id: "1", name: "Land", newName: "Land", count: "2"),
    MainCategoryList(id: "2", name: "Premium Deposits", newName: "Premium Deposits", count: "1"),
    MainCategoryList(id: "3", name: "Society Letters", newName: "Society Letters", count: "1"),
  ];

  late List<LegalDetail> _allMockLegalDetails;

  void _initMockData() {
    _allMockLegalDetails = [
      LegalDetail(
        isExpring: "0",
        legalName: "Charity Commissioner",
        legalId: "1",
        projectLegalId: "101",
        execDate: "07/07/2026",
        expDate: "21/07/2026",
        legalRemark: "whszjhgwjzhw",
        lastUpdateDate: "2026-07-07",
        uploadFlag: "1",
        projectIdFk: "1",
        legalFlag: "0",
        legalStatus: "2", // Applied
        transLegalNote: "Notes on Charity Commissioner",
        selectTypeId: "3", // Society Letters
        selectTypeName: "Society Letters",
        documentPdf: ["Charity_Certificate.pdf"],
      ),
      LegalDetail(
        isExpring: "0",
        legalName: "Assessment Bills",
        legalId: "2",
        projectLegalId: "102",
        execDate: "",
        expDate: "",
        legalRemark: "",
        lastUpdateDate: "",
        uploadFlag: "0",
        projectIdFk: "1",
        legalFlag: "0",
        legalStatus: "0", // Pending
        transLegalNote: "",
        selectTypeId: "2", // Premium Deposits
        selectTypeName: "Premium Deposits",
        documentPdf: [],
      ),
      LegalDetail(
        isExpring: "0",
        legalName: "Best CIS Report",
        legalId: "3",
        projectLegalId: "103",
        execDate: "",
        expDate: "",
        legalRemark: "",
        lastUpdateDate: "",
        uploadFlag: "0",
        projectIdFk: "1",
        legalFlag: "1", // Flagged!
        legalStatus: "0", // Pending
        transLegalNote: "",
        selectTypeId: "1", // Land
        selectTypeName: "Land",
        documentPdf: [],
      ),
      LegalDetail(
        isExpring: "0",
        legalName: "BMC Bills",
        legalId: "4",
        projectLegalId: "104",
        execDate: "",
        expDate: "",
        legalRemark: "",
        lastUpdateDate: "",
        uploadFlag: "0",
        projectIdFk: "1",
        legalFlag: "0",
        legalStatus: "0", // Pending
        transLegalNote: "",
        selectTypeId: "1", // Land
        selectTypeName: "Land",
        documentPdf: [],
      ),
    ];
  }

  bool get isMobile => context.isMobile;

  bool _hasFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context)!.settings.arguments as NotificationArgs;
    if (!_hasFetched) {
      _hasFetched = true;
      fetchGetAllLegal();
    }
  }

  PlatformFile? arrayFiles;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  Uint8List? arrayFilesBytes;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController initiatedDateControler = TextEditingController();
  TextEditingController notifyDateControler = TextEditingController();
  TextEditingController addRemarkControler = TextEditingController();
  DateTime? _selectedInitiatedDate;
  DateTime? _selectedNotifyDate;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  String? offsetResponse;
  List<MainCategoryList>? mainCategoryListResponse = [];
  List<LegalDetail>? legalDetailsResponse = [];
  List<String>? legalStatusResponse = [];
  List<BottomBar>? bottomBarResponse = [];
  MainCategoryList? mainCategoryListSelected;
  String offset = "0";
  TextEditingController editingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToTarget = false;

  void _scrollToTargetItem() {
    if (_hasScrolledToTarget || legalDetailsResponse == null || legalDetailsResponse!.isEmpty) return;

    final String targetRefId = (args.response?.permissionId ?? '').trim();
    final String targetName = (args.towarName ?? '').trim().toLowerCase();
    final String msgText = (args.msg ?? '').trim().toLowerCase();

    int targetIndex = -1;

    if (targetRefId.isNotEmpty) {
      targetIndex = legalDetailsResponse!.indexWhere((item) =>
          item.legalId == targetRefId || item.projectLegalId == targetRefId);
    }

    if (targetIndex == -1 && targetName.isNotEmpty && int.tryParse(targetName) == null) {
      targetIndex = legalDetailsResponse!.indexWhere((item) =>
          (item.legalName ?? '').trim().toLowerCase() == targetName ||
          (item.legalName ?? '').trim().toLowerCase().contains(targetName) ||
          targetName.contains((item.legalName ?? '').trim().toLowerCase()));
    }

    if (targetIndex == -1 && msgText.isNotEmpty) {
      targetIndex = legalDetailsResponse!.indexWhere((item) =>
          item.legalName != null &&
          item.legalName!.isNotEmpty &&
          msgText.contains(item.legalName!.toLowerCase()));
    }

    if (targetIndex != -1) {
      _hasScrolledToTarget = true;
      setState(() {
        _selectedCardIndex = targetIndex;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 350), () {
          if (_scrollController.hasClients) {
            double targetOffset = (targetIndex * 135.0).clamp(0.0, _scrollController.position.maxScrollExtent);
            _scrollController.animateTo(
              targetOffset,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
            );
          }
        });
      });
    }
  }
  List state = [
    'Pending',
    'In Process',
    'Applied',
    'Issued',
  ];
  List<Color> stateColor = [
    Colors.grey,
    const Color.fromRGBO(224, 159, 29, 1.0),
    const Color.fromRGBO(224, 159, 29, 1.0),
    const Color.fromRGBO(54, 128, 25, 1.0),
    const Color.fromRGBO(54, 128, 25, 1.0),
  ];

  List<LegalDetail> _sortLegalDetailsWithPriority(List<LegalDetail> list) {
    if (list.isEmpty) return list;

    int compareNames(LegalDetail a, LegalDetail b) {
      final nameA = (a.legalName ?? '').trim().toLowerCase();
      final nameB = (b.legalName ?? '').trim().toLowerCase();
      return nameA.compareTo(nameB);
    }

    final flagged = list.where((e) => e.legalFlag == '1').toList();
    final unflagged = list.where((e) => e.legalFlag != '1').toList();

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

  Future<List<MasonryDetail>?> fetchGetAllLegal({bool isRefresh = false}) async {
    if (testWithMockData) {
      if (!isRefresh) {
        setState(() {
          _isLoading = true;
        });
      }
      await Future.delayed(const Duration(milliseconds: 800));

      final String filterCatId = mainCategoryListSelected?.id ?? "0";
      List<LegalDetail> filtered = _allMockLegalDetails;
      if (filterCatId != "0") {
        filtered = _allMockLegalDetails.where((e) => e.selectTypeId == filterCatId).toList();
      }
      final String query = editingController.text.trim().toLowerCase();
      if (query.isNotEmpty) {
        filtered = filtered.where((e) => (e.legalName ?? '').toLowerCase().contains(query)).toList();
      }

      filtered = _sortLegalDetailsWithPriority(filtered);

      setState(() {
        mainCategoryListResponse = _mockCategories;
        legalDetailsResponse = filtered;
        legalStatusResponse = ['Pending', 'In Process', 'Applied', 'Issued'];
        bottomBarResponse = [];
        offsetResponse = "0";
        if (mainCategoryListSelected == null) {
          mainCategoryListSelected = _mockCategories[0];
        }
        _isLoading = false;
      });
      return null;
    }

    try {
      String actualProjId = args.projectId ?? '';

      if (actualProjId.isEmpty && args.projectName != null && args.projectName!.isNotEmpty) {
        final resolved = await SocketService.resolveProjectByBody(args.projectName!);
        if (resolved != null && resolved['id'] != null && resolved['id']!.isNotEmpty) {
          actualProjId = resolved['id']!;
        }
      }

      if (actualProjId.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return null;
      }

      await apiNetworkHandler.ensureProjectContext(actualProjId);

      if (!isRefresh) {
        setState(() {
          _isLoading = true;
        });
      }

      String requestUrl = "${AppUrl.baseURL}legal-permissions/projects/$actualProjId";
      var response = await apiNetworkHandler.get(requestUrl);

      bool isSuccess = (response.statusCode == 200 || response.statusCode == 201);
      Map<String, dynamic>? decoded;
      if (isSuccess && response.body.isNotEmpty) {
        try {
          decoded = json.decode(response.body);
          if (decoded?['success'] != true) {
            isSuccess = false;
          }
        } catch (_) {
          isSuccess = false;
        }
      }

      // If initial fetch failed and we have a projectName, try resolving the real project ID
      if (!isSuccess && args.projectName != null && args.projectName!.isNotEmpty) {
        final resolved = await SocketService.resolveProjectByBody(args.projectName!);
        if (resolved != null && resolved['id'] != null && resolved['id']!.isNotEmpty && resolved['id'] != actualProjId) {
          actualProjId = resolved['id']!;
          requestUrl = "${AppUrl.baseURL}legal-permissions/projects/$actualProjId";
          response = await apiNetworkHandler.get(requestUrl);
          if (response.statusCode == 200 || response.statusCode == 201) {
            try {
              decoded = json.decode(response.body);
              if (decoded?['success'] == true) {
                isSuccess = true;
              }
            } catch (_) {}
          }
        }
      }

      if (isSuccess && decoded != null && decoded['success'] == true && decoded['data'] != null) {
        var rawPermissions = decoded['data']['permissions'] ?? [];
          
          List<LegalDetail> allLegalDetails = [];
          List<MainCategoryList> allCategories = [];
          
          allCategories.add(MainCategoryList(id: "0", name: "All", newName: "All", count: ""));

          String mapNewStatusToLegacy(String? status) {
            if (status == null) return "0";
            switch (status.trim().toLowerCase()) {
              case "pending":
                return "0";
              case "in process":
              case "in_process":
              case "in progress":
              case "in_progress":
                return "1";
              case "applied":
                return "2";
              case "issued":
                return "3";
              default:
                return "0";
            }
          }

          Map<String, String> categoryNames = {};

          for (var item in rawPermissions) {
            List<dynamic> itemCats = [];
            if (item['categories'] is List) {
              itemCats = item['categories'];
            }
            String selectTypeId = "0";
            String selectTypeName = "";
            if (itemCats.isNotEmpty) {
              var firstCat = itemCats.first;
              selectTypeId = firstCat['id']?.toString() ?? "0";
              selectTypeName = firstCat['name'] ?? "";
              
              for (var cat in itemCats) {
                String catId = cat['id']?.toString() ?? "";
                String catName = cat['name'] ?? "";
                if (catId.isNotEmpty && !categoryNames.containsKey(catId)) {
                  categoryNames[catId] = catName;
                  allCategories.add(MainCategoryList(id: catId, name: catName, newName: catName, count: ""));
                }
              }
            }

            List<dynamic> attachments = [];
            if (item['attachments'] is List) {
              attachments = item['attachments'];
            }
            List<String> docPdfs = [];
            for (var att in attachments) {
              if (att is Map) {
                String fileName = att['file_name'] ?? att['name'] ?? 'Document.pdf';
                String fileUrl = att['view_url'] ?? att['url'] ?? att['file_url'] ?? att['path'] ?? '';
                if (fileUrl.isEmpty && att['file_id'] != null) {
                  fileUrl = "${AppUrl.baseURL}legal-permissions/projects/$actualProjId/${item['id']}/files/${att['file_id']}/view";
                }
                docPdfs.add("$fileName|$fileUrl");
              } else if (att != null) {
                docPdfs.add("Document.pdf|${att.toString()}");
              }
            }

            allLegalDetails.add(LegalDetail(
              isExpring: "0",
              legalName: item['name'] ?? '',
              legalId: item['id']?.toString() ?? '',
              projectLegalId: item['id']?.toString() ?? '',
              execDate: item['initiated_date'] ?? '',
              expDate: item['notify_on'] ?? '',
              legalRemark: item['remark'] ?? '',
              lastUpdateDate: item['updated_at'] ?? '',
              uploadFlag: attachments.isNotEmpty ? "1" : "0",
              projectIdFk: actualProjId,
              legalFlag: (item['permission_flag'] == 'Flag' || item['permission_flag'] == '1') ? '1' : '0',
              legalStatus: mapNewStatusToLegacy(item['permission_status']),
              transLegalNote: item['remark'] ?? '',
              selectTypeId: selectTypeId,
              selectTypeName: selectTypeName,
              documentPdf: docPdfs,
            ));
          }

          for (var cat in allCategories) {
            List<LegalDetail> matchingDetails;
            if (cat.id == "0") {
              matchingDetails = allLegalDetails;
            } else {
              matchingDetails = allLegalDetails.where((e) => e.selectTypeId == cat.id).toList();
            }
            int total = matchingDetails.length;
            int issued = matchingDetails.where((e) => e.legalStatus == "3").length;
            cat.count = "$issued/$total";
          }

          final String filterCatId = mainCategoryListSelected?.id ?? "0";
          List<LegalDetail> filtered = allLegalDetails;
          if (filterCatId != "0") {
            filtered = allLegalDetails.where((e) => e.selectTypeId == filterCatId).toList();
          }

          final String query = editingController.text.trim().toLowerCase();
          if (query.isNotEmpty) {
            filtered = filtered.where((e) => (e.legalName ?? '').toLowerCase().contains(query)).toList();
          }

          filtered = _sortLegalDetailsWithPriority(filtered);

          setState(() {
            mainCategoryListResponse = allCategories;
            legalDetailsResponse = filtered;
            legalStatusResponse = ['Pending', 'In Process', 'Applied', 'Issued'];
            bottomBarResponse = [];
            offsetResponse = "0";
            if (mainCategoryListSelected == null) {
              mainCategoryListSelected = allCategories[0];
            } else {
              mainCategoryListSelected = allCategories.firstWhere(
                (c) => c.id == mainCategoryListSelected?.id,
                orElse: () => allCategories[0],
              );
            }
          });
          _scrollToTargetItem();
        }
    } catch (e, stackTrace) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    return null;
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));

    // setState(() {
    //   offset = '0';
    // });

    fetchGetAllLegal(isRefresh: true);
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));

    fetchGetAllLegal(isRefresh: true);
    _refreshController.loadComplete();
  }

  Future<List<MasonryDetail>?> setNotifyDatelLegal(
      {required String projectLegalId}) async {
    if (testWithMockData) {
      String formatDate(DateTime dateTime) {
        return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
      }
      final target = _allMockLegalDetails.firstWhere(
        (e) => e.projectLegalId == projectLegalId,
        orElse: () => _allMockLegalDetails[0],
      );
      target.execDate = formatDate(_selectedInitiatedDate!);
      target.expDate = formatDate(_selectedNotifyDate!);
      target.legalRemark = addRemarkControler.text;
      
      setState(() {
        offset = "0";
      });
      fetchGetAllLegal();
      return null;
    }

    final String projectId = args.projectId!;
    String formatDate(DateTime dateTime) {
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    }

    Map<String, dynamic> body = {
      "initiated_date": formatDate(_selectedInitiatedDate!),
      "notify_on": formatDate(_selectedNotifyDate!),
      "remark": addRemarkControler.text,
    };

    var response = await apiNetworkHandler.put(
      "${AppUrl.baseURL}legal-permissions/projects/$projectId/$projectLegalId",
      body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        offset = "0";
      });
      fetchGetAllLegal();
    } else {}
    return null;
  }

  Future<List<MasonryDetail>?> updateLegalStatus(
      {required String projectLegalId, required String legalStatus}) async {
    if (testWithMockData) {
      final target = _allMockLegalDetails.firstWhere(
        (e) => e.projectLegalId == projectLegalId,
        orElse: () => _allMockLegalDetails[0],
      );
      target.legalStatus = legalStatus;
      
      setState(() {
        offset = "0";
      });
      fetchGetAllLegal();

      return null;
    }

    final String projectId = args.projectId!;
    
    String mapLegacyStatusToNew(String legacy) {
      switch (legacy) {
        case "0": return "pending";
        case "1": return "in_process";
        case "2": return "applied";
        case "3": return "issued";
        default: return "pending";
      }
    }

    String statusName = mapLegacyStatusToNew(legalStatus);
    Map<String, dynamic> body = {
      "staus": statusName,
      "status": statusName,
      "legal_status": statusName,
      "permission_status": statusName,
    };

    var response = await apiNetworkHandler.put(
      "${AppUrl.baseURL}legal-permissions/projects/$projectId/$projectLegalId",
      body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        offset = "0";
      });
      fetchGetAllLegal();


    } else {}
    return null;
  }

  setuploadLegalDoc(
      {required String transProjectLegalId,
      required BuildContext popContetx,
      required LegalDetail tempp}) async {
    if (testWithMockData) {
      CustomLoading.progressDialog(isLoading: true, context: context);
      await Future.delayed(const Duration(milliseconds: 600));
      CustomLoading.progressDialog(isLoading: false, context: popContetx);

      final target = _allMockLegalDetails.firstWhere(
        (e) => e.projectLegalId == transProjectLegalId,
        orElse: () => _allMockLegalDetails[0],
      );
      target.uploadFlag = "1";
      if (arrayFiles != null) {
        target.documentPdf = [...?target.documentPdf, arrayFiles!.name];
      }

      setState(() {
        offset = "0";
        arrayFiles = null;
        arrayFilesBytes = null;
      });

      changeStatusModal(
          legalStatus: int.parse(tempp.legalStatus ?? '0'),
          data: tempp);
      fetchGetAllLegal();
      return null;
    }

    final SharedPreferences prefs = await _prefs;
    // All uploads inside a project MUST use the project token
    String? token = prefs.getString('projectToken') ?? prefs.getString('masterToken') ?? prefs.getString('token');
    final String projectId = args.projectId!;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${AppUrl.baseURL}legal-permissions/projects/$projectId/$transProjectLegalId/upload-pdf"),
    );

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      if (token != null) 'Authorization': 'Bearer $token',
      'x-project-id': projectId,
    });

    PlatformFile file = arrayFiles!;
    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        file.path.toString(),
      ),
    );

    var response = await request.send();
    var responsed = await http.Response.fromStream(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      CustomLoading.progressDialog(isLoading: false, context: popContetx);
      
      changeStatusModal(
          legalStatus: int.parse(tempp.legalStatus ?? '0'),
          data: tempp);
      fetchGetAllLegal();
      setState(() {
        arrayFiles = null;
        arrayFilesBytes = null;
      });
      return null;
    } else {
      CustomLoading.progressDialog(isLoading: false, context: popContetx);
      return null;
    }
  }

  @override
  void initState() {
    if (testWithMockData) {
      _initMockData();
    }
    setState(() {
      offset = "0";
    });
    super.initState();
  }

  String formatDisplayDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "";
    try {
      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(rawDate)) {
        return rawDate;
      }
      DateTime parsed;
      if (rawDate.contains('-')) {
        parsed = DateTime.parse(rawDate);
      } else {
        var cleanDate = rawDate
            .replaceAll('st', '')
            .replaceAll('nd', '')
            .replaceAll('rd', '')
            .replaceAll('th', '');
        var parts = cleanDate.split('/');
        if (parts.length == 3) {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          parsed = DateTime(year, month, day);
        } else {
          parsed = DateFormat("d MMM yyyy").parse(cleanDate.trim());
        }
      }
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) {
      return rawDate;
    }
  }

  bool isDatePassed(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return false;
    try {
      DateTime parsed;
      if (dateStr.contains('-')) {
        parsed = DateTime.parse(dateStr);
      } else {
        var cleanDate = dateStr
            .replaceAll('st', '')
            .replaceAll('nd', '')
            .replaceAll('rd', '')
            .replaceAll('th', '');
        var parts = cleanDate.split('/');
        if (parts.length == 3) {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          parsed = DateTime(year, month, day);
        } else {
          parsed = DateFormat("d MMM yyyy").parse(cleanDate.trim());
        }
      }
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final compareDate = DateTime(parsed.year, parsed.month, parsed.day);
      return today.isAfter(compareDate);
    } catch (_) {
      return false;
    }
  }

  String getCategoryCount(String categoryId, String? defaultCount) {
    if (testWithMockData) {
      final list = _allMockLegalDetails.where((e) => e.selectTypeId == categoryId).toList();
      final total = list.length;
      final issued = list.where((e) => e.legalStatus == "3").length;
      return "$issued/$total";
    }
    
    if (mainCategoryListSelected?.id == categoryId && legalDetailsResponse != null) {
      final total = legalDetailsResponse!.length;
      final issued = legalDetailsResponse!.where((e) => e.legalStatus == "3" || e.legalStatus == "Issued").length;
      return "$issued/$total";
    }
    
    if (defaultCount != null && !defaultCount.contains('/')) {
      return "0/$defaultCount";
    }
    
    return defaultCount ?? "0/0";
  }


  Widget buildRightArrow(LegalDetail tempp, double arrowSize) {
    return InkWell(
      onTap: () {
        var projectId = args.projectId!;
        var projectName = args.projectName!;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return LegalDocsScreen(
                projectId: projectId,
                towarId: args.response?.towarId ?? '',
                projectName: projectName,
                legalId: tempp.legalId ?? '',
                towarName: args.towarName ?? '',
              );
            },
          ),
        );
      },
      child: Icon(Icons.keyboard_arrow_right, color: Colors.black54, size: arrowSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            (args.projectName != null && args.projectName!.isNotEmpty)
                ? args.projectName!.toUpperCase()
                : 'LEGAL PERMISSIONS',
            style: const TextStyle(
              fontFamily: 'HelveticaNeue',
              fontWeight: FontWeight.w700,
              fontSize: 16.0,
              letterSpacing: 0.2,
            )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.0),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 3),
          // Category selector tabs (Pill Segmented Control)
          Container(
            height: 50.0,
            margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xfff8f9fa),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xffe9ecef), width: 1.0),
            ),
            child: _isLoading
                ? CustomLoading.buildCategorySkeletonInline(context)
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 0; i < mainCategoryListResponse!.length; i++) ...[
                          if (i > 0)
                            Container(
                              height: 20,
                              width: 1.0,
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                             child: InkWell(
                               onTap: () {
                                 setState(() {
                                   mainCategoryListSelected = mainCategoryListResponse?[i];
                                   offset = "0";
                                 });
                                 fetchGetAllLegal();
                               },
                               child: AnimatedContainer(
                                 duration: const Duration(milliseconds: 200),
                                 width: (mainCategoryListResponse?[i].id == "0" ||
                                         mainCategoryListResponse?[i].name?.toLowerCase() == 'all' ||
                                         mainCategoryListResponse?[i].newName?.toLowerCase() == 'all')
                                     ? (isMobile ? 75.0 : 90.0)
                                     : null,
                                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                 decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(12.0),
                                   color: mainCategoryListSelected?.id == mainCategoryListResponse?[i].id
                                       ? Colors.black
                                       : Colors.transparent,
                                 ),
                                 alignment: Alignment.center,
                                 child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      mainCategoryListResponse?[i].newName ?? '',
                                      style: TextStyle(
                                          fontFamily: 'HelveticaNeue',
                                          fontWeight: FontWeight.w700,
                                          fontSize: isMobile ? 11 : 13,
                                          color: mainCategoryListSelected?.id == mainCategoryListResponse?[i].id
                                              ? Colors.white
                                              : Colors.black87),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      getCategoryCount(mainCategoryListResponse?[i].id ?? '', mainCategoryListResponse?[i].count),
                                      style: TextStyle(
                                          fontFamily: 'HelveticaNeue',
                                          fontWeight: FontWeight.w600,
                                          fontSize: isMobile ? 10 : 12,
                                          color: mainCategoryListSelected?.id == mainCategoryListResponse?[i].id
                                              ? Colors.white54
                                              : Colors.black54),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
          // Search box (Pill Input)
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 2),
            child: SizedBox(
              height: 38,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xfff8f9fa),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffe0e0e0)),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      offset = '0';
                    });
                    fetchGetAllLegal();
                  },
                  style: const TextStyle(
                    fontFamily: 'HelveticaNeue',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  controller: editingController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                    hintText: "Search by Name",
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                    suffixIcon: editingController.text.isNotEmpty
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                offset = '0';
                              });
                              editingController.clear();
                              fetchGetAllLegal();
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
          const SizedBox(height: 3),
          const Divider(color: Color(0xfff0f0f0), height: 1.0),
          Expanded(
            child: _isLoading
                ? CustomLoading.buildLegalListSkeletonInline(context)
                : SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: true,
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    footer: const ClassicFooter(loadStyle: LoadStyle.ShowWhenLoading),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        shrinkWrap: true,
                        itemCount: legalDetailsResponse!.length,
                        itemBuilder: (context, index) {
                          LegalDetail tempp = legalDetailsResponse![index];
                          final double rightWidth = isMobile ? 80.0 : 100.0;
                           return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCardIndex = index;
                              });
                              if (testWithMockData) {
                                viewDocumentsModal(
                                    documentPdf: tempp.documentPdf,
                                    titlehead: tempp.legalName ?? '',
                                    legalId: tempp.projectLegalId ?? '');
                              } else {
                                fetchAndShowAttachments(
                                    projectLegalId: tempp.projectLegalId ?? '',
                                    title: tempp.legalName ?? '',
                                    fileNames: tempp.documentPdf);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                              decoration: BoxDecoration(
                                color: tempp.uploadFlag == "1" ? Colors.white : const Color(0xfff8f9fa),
                                borderRadius: BorderRadius.circular(14.0),
                                border: Border.all(color: _selectedCardIndex == index ? const Color(0xffd6d6d6) : const Color(0xfff0f0f0), width: 1.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.015),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 8 : 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row 1: Title & Status
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
                                                  title: tempp.legalName ?? '',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  overflow: TextOverflow.visible,
                                                ),
                                              ),
                                              if (tempp.uploadFlag == "1") ...[
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
                                        // Dynamic Capsule Status Badge wrapped for alignment
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            if (tempp.legalFlag == "1") ...[
                                              Image.asset(
                                                'images/projectmanagement/red_flagI_icon.png',
                                                height: 18,
                                                width: 18,
                                                fit: BoxFit.cover,
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                            SizedBox(
                                              width: rightWidth,
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: InkWell(
                                                  onTap: () {
                                                    changeStatusModal(
                                                        legalStatus: int.parse(
                                                            tempp.legalStatus ?? '0'),
                                                        data: tempp);
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
                                                      color: stateColor[int.parse(tempp.legalStatus ?? '0')],
                                                    ),
                                                    child: Text(
                                                      state[int.parse(tempp.legalStatus ?? '0')],
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
                                              ),
                                            ),
                                            if (!isMobile) ...[
                                              const SizedBox(width: 36),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Row 2: Set Notify Date & Upload Button
                                    Row(
                                      children: [
                                        // Set Notify Date Pill
                                        InkWell(
                                          onTap: () {
                                            initiatedDateControler.text = formatDisplayDate(tempp.execDate);
                                            notifyDateControler.text = formatDisplayDate(tempp.expDate);
                                            addRemarkControler.text = tempp.legalRemark ?? "";

                                            DateTime? parseDateHelper(String? dateStr) {
                                              if (dateStr == null || dateStr.isEmpty) return null;
                                              try {
                                                if (dateStr.contains('-')) {
                                                  return DateTime.parse(dateStr);
                                                }
                                                var cleanDate = dateStr
                                                    .replaceAll('st', '')
                                                    .replaceAll('nd', '')
                                                    .replaceAll('rd', '')
                                                    .replaceAll('th', '');
                                                var parts = cleanDate.split('/');
                                                if (parts.length == 3) {
                                                  int day = int.parse(parts[0]);
                                                  int month = int.parse(parts[1]);
                                                  int year = int.parse(parts[2]);
                                                  return DateTime(year, month, day);
                                                }
                                                return DateFormat("d MMM yyyy").parse(cleanDate.trim());
                                              } catch (_) {
                                                return null;
                                              }
                                            }
                                            _selectedInitiatedDate = parseDateHelper(tempp.execDate);
                                            _selectedNotifyDate = parseDateHelper(tempp.expDate);

                                            setNotifyDateRemarkModal(data: tempp);
                                          },
                                          child: Container(
                                            padding: isMobile
                                                ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0)
                                                : const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: isDatePassed(tempp.expDate)
                                                    ? Colors.red
                                                    : Colors.black,
                                              ),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.calendar_month_outlined,
                                                  size: isMobile ? 12 : 14,
                                                  color: isDatePassed(tempp.expDate)
                                                      ? Colors.red
                                                      : Colors.black,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  tempp.expDate == ""
                                                      ? "Set Notify Date"
                                                      : "Notify On - ${formatDisplayDate(tempp.expDate)}",
                                                  style: TextStyle(
                                                    fontFamily: 'HelveticaNeue',
                                                    color: isDatePassed(tempp.expDate)
                                                        ? Colors.red
                                                        : Colors.black,
                                                    fontSize: isMobile ? 11.0 : 12.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        // Upload button wrapped for alignment
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: rightWidth,
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: InkWell(
                                                  onTap: () async {
                                                    FilePickerResult? result =
                                                        await FilePicker.platform.pickFiles(
                                                      type: FileType.custom,
                                                      allowedExtensions: ['pdf'],
                                                    );
                                                    if (result != null) {
                                                      PlatformFile file = result.files.first;
                                                      if (!file.name.toLowerCase().endsWith('.pdf')) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
                                                            content: Text("Only PDF files are allowed"),
                                                            backgroundColor: Colors.red,
                                                          ),
                                                        );
                                                        return;
                                                      }
                                                      Uint8List? fileBytes =
                                                          result.files.first.bytes;
                                                      setState(() {
                                                        arrayFiles = file;
                                                        arrayFilesBytes = fileBytes;
                                                        CustomLoading.progressDialog(
                                                            isLoading: true,
                                                            context: context);
                                                        setuploadLegalDoc(
                                                            tempp: tempp,
                                                            transProjectLegalId:
                                                                tempp.projectLegalId ?? '',
                                                            popContetx: context);
                                                      });
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
                                              ),
                                            ),
                                            if (!isMobile) ...[
                                              const SizedBox(width: 10),
                                              buildRightArrow(tempp, 26),
                                            ] else ...[
                                              const SizedBox.shrink(),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Row 3: Initiated On (left) & Category text (right)
                                    Row(
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              const TextSpan(
                                                text: 'Initiated On - ',
                                                style: TextStyle(
                                                  fontFamily: 'HelveticaNeue',
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              TextSpan(
                                                text: formatDisplayDate(tempp.execDate),
                                                style: const TextStyle(
                                                  fontFamily: 'HelveticaNeue',
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          style: TextStyle(
                                            fontSize: isMobile ? 11.0 : 13.0,
                                          ),
                                        ),
                                        const Spacer(),
                                        // Category text wrapped for alignment
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: rightWidth,
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: (tempp.selectTypeName?.isNotEmpty == true &&
                                                        (mainCategoryListSelected == null ||
                                                         mainCategoryListSelected!.id == "0"))
                                                    ? Text(
                                                        tempp.selectTypeName ?? '',
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                          fontFamily: 'HelveticaNeue',
                                                          fontSize: isMobile ? 11 : 13,
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.black87,
                                                        ),
                                                      )
                                                    : const SizedBox.shrink(),
                                              ),
                                            ),
                                            if (!isMobile) const SizedBox(width: 36),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (isMobile || tempp.legalRemark?.isNotEmpty == true) ...[
                                      const SizedBox(height: 8),
                                      // Row 4: Remarks Section (left) & Navigation Arrow (right)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: (tempp.legalRemark?.isNotEmpty == true)
                                                ? Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'Remark: ',
                                                          style: TextStyle(
                                                            fontFamily: 'HelveticaNeue',
                                                            fontSize: isMobile ? 11.0 : 13.0,
                                                            color: Colors.black,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: tempp.legalRemark ?? '',
                                                          style: TextStyle(
                                                            fontFamily: 'HelveticaNeue',
                                                            fontSize: isMobile ? 11.0 : 13.0,
                                                            color: Colors.black,
                                                            fontWeight: FontWeight.normal,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  )
                                                : const SizedBox.shrink(),
                                          ),
                                          if (isMobile) ...[
                                            const SizedBox(width: 10),
                                            InkWell(
                                              onTap: () {
                                                var projectId = args.projectId!;
                                                var projectName = args.projectName!;
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) {
                                                      return LegalDocsScreen(
                                                        projectId: projectId,
                                                        towarId: args.response?.towarId ?? '',
                                                        projectName: projectName,
                                                        legalId: tempp.legalId ?? '',
                                                        towarName: args.towarName ?? '',
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                              child: Icon(Icons.keyboard_arrow_right, color: Colors.black54, size: 22),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchAndShowAttachments({required String projectLegalId, required String title, List<String>? fileNames}) async {
    CustomLoading.progressDialog(isLoading: true, context: context);
    try {
      final String projectId = args.projectId!;
      var response = await apiNetworkHandler.get(
        "${AppUrl.baseURL}legal-permissions/projects/$projectId/$projectLegalId/files"
      );
      CustomLoading.progressDialog(isLoading: false, context: context);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          var attachments = decoded['data']['Attachments'] ?? decoded['data']['attachments'] ?? decoded['data']['files'] ?? [];
          List<String> docPdfs = [];
          for (int idx = 0; idx < attachments.length; idx++) {
            var att = attachments[idx];
            String fileUrl = '';
            String fileName = '';

            if (att is Map) {
              fileUrl = att['view_url'] ?? att['url'] ?? att['file_url'] ?? att['path'] ?? '';
              fileName = att['file_name'] ?? att['name'] ?? att['filename'] ?? '';
              if (fileUrl.isEmpty && att['file_id'] != null) {
                fileUrl = "${AppUrl.baseURL}legal-permissions/projects/$projectId/$projectLegalId/files/${att['file_id']}/view";
              }
            } else if (att is String) {
              fileUrl = att;
            }

            if (fileName.isEmpty && fileNames != null && idx < fileNames.length) {
              var entry = fileNames[idx];
              if (entry.contains('|')) {
                var parts = entry.split('|');
                fileName = parts[0].isNotEmpty ? parts[0] : parts.last;
              } else {
                fileName = entry;
              }
            }

            if (fileName.isEmpty && fileUrl.isNotEmpty && !fileUrl.startsWith('{')) {
              try {
                Uri uri = Uri.parse(fileUrl);
                String path = uri.path;
                fileName = path.split('/').last;
                fileName = Uri.decodeFull(fileName);
                final regex = RegExp(r'^\d{13}-');
                if (regex.hasMatch(fileName)) {
                  fileName = fileName.replaceFirst(regex, '');
                }
              } catch (_) {}
            }

            if (fileName.isEmpty) {
              fileName = "Document.pdf";
            }

            if (fileUrl.isNotEmpty) {
              docPdfs.add("$fileName|$fileUrl");
            }
          }
          viewDocumentsModal(documentPdf: docPdfs, titlehead: title);
        } else {
          viewDocumentsModal(documentPdf: [], titlehead: title);
        }
      } else {
        viewDocumentsModal(documentPdf: [], titlehead: title);
      }
    } catch (e, stack) {
      CustomLoading.progressDialog(isLoading: false, context: context);
      viewDocumentsModal(documentPdf: [], titlehead: title);
    }
  }

  viewDocumentsModal(
      {required List<String>? documentPdf, required String titlehead, String legalId = ''}) {
    final bool isMobile = context.isMobile;
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                  titlehead,
                  style: const TextStyle(
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
                      Navigator.pop(dialogContext);
                    },
                  ),
                ),
              ],
              content: Container(
                height: 300,
                width: 500,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Expanded(
                      child: (documentPdf != null && documentPdf.isNotEmpty)
                          ? SingleChildScrollView(
                              child: Wrap(
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.start,
                                spacing: isMobile ? 12 : 24,
                                runSpacing: isMobile ? 12 : 24,
                                children: [
                                  for (int i = 0; i < documentPdf.length; i++)
                                    InkWell(
                                      onTap: () async {
                                        String fileName = documentPdf[i];
                                        String fileUrl = documentPdf[i];
                                        if (documentPdf[i].contains('|')) {
                                          var parts = documentPdf[i].split('|');
                                          fileName = parts[0];
                                          fileUrl = parts[1];
                                        }
                                        if (fileUrl.startsWith('/')) {
                                          String base = AppUrl.baseURL.endsWith('/')
                                              ? AppUrl.baseURL.substring(0, AppUrl.baseURL.length - 1)
                                              : AppUrl.baseURL;
                                          fileUrl = "$base$fileUrl";
                                        }
                                        Navigator.pop(dialogContext);
                                        await Navigator.push(
                                          this.context,
                                          MaterialPageRoute(
                                            builder: (_) {
                                              return PdfViewer(
                                                fileName: fileName,
                                                fileUrl: fileUrl,
                                              );
                                            },
                                          ),
                                        );
                                        viewDocumentsModal(
                                          documentPdf: documentPdf,
                                          titlehead: titlehead,
                                          legalId: legalId,
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.withOpacity(0.4),
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        width: isMobile ? 100 : 140,
                                        child: Column(
                                          children: [
                                            Image.asset(
                                              'images/projectmanagement/pdf.png',
                                              width: isMobile ? 80 : 150,
                                              height: isMobile ? 80 : 150,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                                              child: AppText(
                                                title: documentPdf[i].contains('|') ? documentPdf[i].split('|')[0] : documentPdf[i],
                                                fontSize: isMobile ? 11 : 14,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : const Center(
                              child: Text(
                                "No Record Found",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  changeStatusModal({required int legalStatus, required LegalDetail data}) {
    final bool isMobile = context.isMobile;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
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
                      Navigator.pop(dialogContext);
                    },
                  ),
                ),
              ],
              content: SizedBox(
                height: 280,
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.length,
                        itemBuilder: (context, i) {
                          final bool isSelected = legalStatus.toString() == i.toString();
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
                              child: InkWell(
                                onTap: () {
                                  updateLegalStatus(
                                      projectLegalId: data.projectLegalId ?? '',
                                      legalStatus: i.toString());
                                  Navigator.pop(dialogContext);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  child: Row(
                                    children: [
                                      Text(
                                        state[i] ?? '',
                                        style: TextStyle(
                                          fontFamily: 'HelveticaNeue',
                                          fontSize: 15,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          color: isSelected ? Colors.black : Colors.black87,
                                        ),
                                      ),
                                      const Spacer(),
                                      isSelected
                                          ? const Icon(Icons.check_circle, color: Colors.black, size: 20)
                                          : const Icon(Icons.circle_outlined, color: Colors.black45, size: 20),
                                    ],
                                  ),
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
            );
          });
        });
  }

  setNotifyDateRemarkModal({required LegalDetail data}) {
    final bool isMobile = context.isMobile;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (context1, setState) {
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
                  "Set Notify Date & Remark",
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
                            Navigator.pop(dialogContext);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ModernDialogButton(
                          text: 'Submit',
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              setNotifyDatelLegal(
                                  projectLegalId: data.projectLegalId ?? '');
                              Navigator.pop(dialogContext);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              content: Container(
                height: 320,
                width: 400,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const Text("Initiated Date"),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final now = DateTime.now();
                            final today = DateTime(now.year, now.month, now.day);
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedInitiatedDate != null && !_selectedInitiatedDate!.isAfter(today)
                                  ? _selectedInitiatedDate!
                                  : today,
                              firstDate: DateTime(2000),
                              lastDate: today,
                            );
                            if (picked != null &&
                                picked != _selectedInitiatedDate) {
                              _selectedInitiatedDate = picked;
                              initiatedDateControler.text =
                                  DateFormat('dd/MM/yyyy')
                                      .format(_selectedInitiatedDate!);
                            }
                          },
                          child: TextFormField(
                            enabled: false,
                            readOnly: true,
                            validator: (value) {
                              if (value!.isEmpty) {
                                  return "(Initiated Date Cannot Be Empty)";
                              }
                              return null;
                            },
                            controller: initiatedDateControler,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 13.0),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(12.0),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              hintText: 'Select Initiated Date',
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 116, 116, 116),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'HelveticaNeue',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text("Notify Date"),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final now = DateTime.now();
                            final today = DateTime(now.year, now.month, now.day);
                            final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedNotifyDate != null && !_selectedNotifyDate!.isBefore(today)
                                    ? _selectedNotifyDate!
                                    : today,
                                firstDate: today,
                                lastDate: DateTime(2101));
                            if (picked != null &&
                                picked != _selectedNotifyDate) {
                              _selectedNotifyDate = picked;
                              notifyDateControler.text =
                                  DateFormat('dd/MM/yyyy')
                                      .format(_selectedNotifyDate!);
                            }
                          },
                          child: TextFormField(
                            enabled: false,
                            readOnly: true,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "(Notify Date Cannot Be Empty)";
                              }
                              return null;
                            },
                            controller: notifyDateControler,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 13.0),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(12.0),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              hintText: 'Select Notify Date',
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 116, 116, 116),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'HelveticaNeue',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text("Add Remark"),
                        const SizedBox(height: 6),
                        TextFormField(
                          maxLines: 4,
                          controller: addRemarkControler,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 13.0),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(12.0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            hintText: 'Add Remark',
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 116, 116, 116),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'HelveticaNeue',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }
}

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
            alignment: Alignment.center,
            child: Text(
              widget.text,
              style: TextStyle(
                fontFamily: 'HelveticaNeue',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: widget.textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
