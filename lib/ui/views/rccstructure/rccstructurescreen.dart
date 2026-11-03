import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_project_masonry.dart' as masonry1;
import 'package:stallion/models/get_project_masonry.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/rccstructure/checklist/checklist_screen.dart';
import 'package:stallion/ui/views/rccstructure/dpr/daily_progress_report.dart';
import 'package:stallion/ui/views/rccstructure/excavation/excavation_screen.dart';
import 'package:stallion/ui/views/rccstructure/supplies/order_supplies_screen.dart';
import 'package:stallion/ui/views/rccstructure/common/rcc_mock_data.dart';
import 'package:stallion/ui/views/rccstructure/slab/revisionrccstructure.dart';
import 'package:stallion/ui/views/rccstructure/task_rcc/task_list_screen.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:stallion/models/developer_rcc_count_response.dart';
import '../../../models/get_rccstructure.dart' as drawing1;
import '../../../models/get_rccstructure.dart';
import 'slab/issuerccreport_screen.dart';
import 'rcc_skeleton_loader.dart';
import 'slab/slab_status_screen.dart';

class RccStructure extends StatefulWidget {
  const RccStructure(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.towarName})
      : super(key: key);
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  @override
  _RccStructureState createState() => _RccStructureState();
}

class _RccStructureState extends State<RccStructure> {
  bool isLoading = false;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 100));
    offset = '0';
    slabDetails = [];
    checkedSlabIds.clear();
    fetchRccStructureDetails();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    if (isLoading) return;
    await fetchRccStructureDetails();
    _refreshController.loadComplete();
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  bool circular = false;
  List<masonry1.TowarList>? towarListRes = [];
  masonry1.TowarList? towarListSelected;
  String? strRccTitle;
  String? strSlabIssueCount;
  int? indexOfSlab = -1;
  String? slabId;
  String averagedata = '';
  String? blockFlag = '';
  String errorCode = '';
  List<TowarList>? towarList = [];
  List<SlabDetail> slabDetails = [];
  Set<String> checkedSlabIds = {};
  String? offset = '0';
  Map<String, String> towerAuthorityMap = {};
  bool restrictChecklistCategory = false;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _slabItemKeys = {};
  final Map<String, GlobalKey> _checklistKeys = {};
  String? highlightedChecklistId;

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _scrollToSlab(
    String targetSlabId, {
    String? targetChecklistId,
    bool wasSubmitted = false,
  }) {
    if (!mounted) return;
    final targetIndex = slabDetails.indexWhere((s) => s.slabId == targetSlabId);
    if (targetIndex == -1) return;

    setState(() {
      indexOfSlab = targetIndex;
      slabId = slabDetails[targetIndex].slabId;
      strRccTitle = slabDetails[targetIndex].slabNo;
      strSlabIssueCount = slabDetails[targetIndex].issueSlabReport;
      if (wasSubmitted &&
          targetChecklistId != null &&
          targetChecklistId.isNotEmpty) {
        highlightedChecklistId = targetChecklistId;
      }
    });

    if (wasSubmitted && highlightedChecklistId != null) {
      Future.delayed(const Duration(milliseconds: 3000), () {
        if (mounted) {
          setState(() {
            highlightedChecklistId = null;
          });
        }
      });
    }

    final isMobile = context.isMobile;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (!mounted) return;

        // Try direct ensureVisible on checklist item if already laid out
        if (targetChecklistId != null &&
            targetChecklistId.isNotEmpty &&
            _checklistKeys[targetChecklistId]?.currentContext != null) {
          Scrollable.ensureVisible(
            _checklistKeys[targetChecklistId]!.currentContext!,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            alignment: 0.25,
          );
        } else if (_slabItemKeys[targetSlabId]?.currentContext != null) {
          Scrollable.ensureVisible(
            _slabItemKeys[targetSlabId]!.currentContext!,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            alignment: 0.05,
          );
        } else if (_scrollController.hasClients) {
          // Offscreen: scroll close to the estimated index first so ListView mounts it
          final double estimatedCardHeight = isMobile ? 120.0 : 150.0;
          final double targetOffset = (targetIndex * estimatedCardHeight)
              .clamp(0.0, _scrollController.position.maxScrollExtent);

          _scrollController
              .animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
          )
              .then((_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 150), () {
                if (!mounted) return;
                if (targetChecklistId != null &&
                    targetChecklistId.isNotEmpty &&
                    _checklistKeys[targetChecklistId]?.currentContext != null) {
                  Scrollable.ensureVisible(
                    _checklistKeys[targetChecklistId]!.currentContext!,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    alignment: 0.25,
                  );
                } else if (_slabItemKeys[targetSlabId]?.currentContext != null) {
                  Scrollable.ensureVisible(
                    _slabItemKeys[targetSlabId]!.currentContext!,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    alignment: 0.05,
                  );
                }
              });
            });
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    strSlabIssueCount = '0';
    strRccTitle = '';
    towarListSelected = masonry1.TowarList(
        towarId: widget.towarId, towarName: widget.towarName);
    fetchTowers();
    fetchRccStructureDetails();
  }

  Future<void> fetchTowers() async {
    if (widget.projectId == null || widget.projectId!.isEmpty) return;

    try {
      if (AppUrl.useNewBackend) {
        await apiNetworkHandler.ensureProjectContext(widget.projectId);
      }

      dynamic response;
      if (AppUrl.useNewBackend) {
        response = await apiNetworkHandler.get(
            "${AppUrl.baseURL}towers?project_id=${widget.projectId}");
      } else {
        Map<String, String> towerData = {
          "project_id": widget.projectId!,
        };
        response = await apiNetworkHandler.post(
            AppUrl.getTowerListByProjectiId, towerData);
      }

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final decoded = json.decode(response.body);
        List rawList = [];
        if (decoded is Map) {
          if (decoded['success'] == true && decoded['data'] is List) {
            rawList = decoded['data'];
          } else if (decoded['data'] is List) {
            rawList = decoded['data'];
          } else if (decoded['Response']?['tower_list'] is List) {
            rawList = decoded['Response']['tower_list'];
          } else if (decoded['tower_list'] is List) {
            rawList = decoded['tower_list'];
          }
        }

        List<masonry1.TowarList> parsedTowers = [];
        for (var item in rawList) {
          if (item is Map) {
            String tId = item['id']?.toString() ??
                item['towar_id']?.toString() ??
                item['tower_id']?.toString() ??
                '';
            String tName = item['name']?.toString() ??
                item['towar_name']?.toString() ??
                item['tower_name']?.toString() ??
                '';
            if (tId.isNotEmpty) {
              parsedTowers.add(masonry1.TowarList(towarId: tId, towarName: tName));
            }
          }
        }

        if (parsedTowers.isNotEmpty && mounted) {
          setState(() {
            towarListRes = parsedTowers;
            final matched = parsedTowers.firstWhere(
              (t) =>
                  t.towarId ==
                  (towarListSelected?.towarId ?? widget.towarId),
              orElse: () => parsedTowers.first,
            );
            towarListSelected = matched;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching towers in RccStructure: $e");
      }
    }
  }

  List<SlabDetail> _parseRccProgressData(Map<String, dynamic> data) {
    List<SlabDetail> slabList = [];
    var towerSlabs = data['tower_slabs'];
    if (towerSlabs is! List) return slabList;

    for (var slabItem in towerSlabs) {
      if (slabItem is! Map) continue;

      String sId = slabItem['id']?.toString() ?? '';
      String sName = slabItem['name']?.toString() ??
          slabItem['slab_number']?.toString() ??
          '';

      String estDate = formatDateToDdMmYyyy(slabItem['estimated_on']?.toString());

      String compDate = formatDateToDdMmYyyy(slabItem['completed_on']?.toString());
      bool hasCompletionDate = compDate.trim().isNotEmpty &&
          compDate.trim() != '-' &&
          compDate.trim().toLowerCase() != 'null';

      String completStatus =
          (checkedSlabIds.contains(sId) || hasCompletionDate) ? "1" : "0";

      // Count of pending issues (both slab and drawing) from tower_slabs.issues
      var issuesObj = slabItem['issues'];
      int totalPendingCount = 0;
      int slabPendingCount = 0;
      int drawingPendingCount = 0;

      if (issuesObj is Map) {
        if (issuesObj['slab'] is Map) {
          slabPendingCount = int.tryParse((issuesObj['slab']['pending'] ?? 0).toString()) ?? 0;
        } else if (issuesObj['slab'] != null) {
          slabPendingCount = int.tryParse(issuesObj['slab'].toString()) ?? 0;
        }

        if (issuesObj['drawing'] is Map) {
          drawingPendingCount = int.tryParse((issuesObj['drawing']['pending'] ?? 0).toString()) ?? 0;
        } else if (issuesObj['drawing'] != null) {
          drawingPendingCount = int.tryParse(issuesObj['drawing'].toString()) ?? 0;
        }

        if (issuesObj['pending'] != null) {
          totalPendingCount = int.tryParse(issuesObj['pending'].toString()) ?? (slabPendingCount + drawingPendingCount);
        } else if (issuesObj['total_pending'] != null) {
          totalPendingCount = int.tryParse(issuesObj['total_pending'].toString()) ?? (slabPendingCount + drawingPendingCount);
        } else {
          totalPendingCount = slabPendingCount + drawingPendingCount;
        }
      } else if (issuesObj is List) {
        totalPendingCount = issuesObj.length;
      } else if (issuesObj != null) {
        totalPendingCount = int.tryParse(issuesObj.toString()) ?? 0;
      }

      if (totalPendingCount == 0 && slabItem['pending'] != null) {
        totalPendingCount = int.tryParse(slabItem['pending'].toString()) ?? 0;
      }

      // Parse Drawings from drawing_sections -> drawing_types
      List<drawing1.Drawing> parsedDrawings = [];
      var sections = slabItem['drawing_sections'];
      if (sections is List) {
        for (var sec in sections) {
          if (sec is! Map) continue;
          var dTypes = sec['drawing_types'];
          if (dTypes is! List) continue;

          for (var dType in dTypes) {
            if (dType is! Map) continue;
            String dTypeId = dType['id']?.toString() ?? '';
            String dTitle =
                dType['drawing_type']?['name']?.toString() ?? 'Drawing';
            bool isVerified = dType['isVerified'] == true ||
                dType['isVerified']?.toString() == 'true';

            List<String> pdfList = [];
            List<String> dwgList = [];
            List<DrawingVersion> versionsList = [];
            int totalDocsCount = 0;

            var fileFormats = dType['file_formats'];
            Map<String, DrawingVersion> versionMap = {};

            if (fileFormats is List) {
              for (var ff in fileFormats) {
                if (ff is! Map) continue;
                String format =
                    ff['file_format']?.toString().toLowerCase() ?? '';
                var versions = ff['versions'];
                if (versions is List) {
                  for (var ver in versions) {
                    if (ver is! Map) continue;
                    String verName =
                        ver['version_name']?.toString() ?? 'Version 0';
                    String remarks = ver['remarks']?.toString() ?? '';
                    var docs = ver['documents'];

                    DrawingVersion targetVersion = versionMap.putIfAbsent(
                      verName,
                      () => DrawingVersion(
                        name: verName,
                        pdfRemark: null,
                        dwgRemark: null,
                        pdf: [],
                        dwg: [],
                      ),
                    );

                    if (format == 'pdf' && remarks.isNotEmpty) {
                      targetVersion.pdfRemark = remarks;
                    } else if (format == 'dwg' && remarks.isNotEmpty) {
                      targetVersion.dwgRemark = remarks;
                    }

                    if (docs is List) {
                      totalDocsCount += docs.length;
                      for (var doc in docs) {
                        if (doc is! Map) continue;
                        String docName = doc['document_name']?.toString() ??
                            doc['file_name']?.toString() ??
                            doc['name']?.toString() ??
                            'document';
                        String fUrl = doc['file_url']?.toString() ??
                            doc['url']?.toString() ??
                            '';
                        String fDate = formatDateToDdMmYyyy(
                            doc['created_at']?.toString() ??
                                doc['updated_at']?.toString());

                        PdfElement elem = PdfElement(
                          slabDrawingImgName: docName,
                          fileUrl: fUrl,
                          documentName: docName,
                          drawingDate: fDate,
                        );

                        if (format == 'pdf') {
                          targetVersion.pdf ??= [];
                          targetVersion.pdf!.add(elem);
                          pdfList.add(fUrl.isNotEmpty ? fUrl : docName);
                        } else if (format == 'dwg') {
                          targetVersion.dwg ??= [];
                          targetVersion.dwg!.add(elem);
                          dwgList.add(fUrl.isNotEmpty ? fUrl : docName);
                        }
                      }
                    }
                  }
                }
              }
            }

            versionsList = versionMap.values.toList();

            bool isDisabled = totalDocsCount == 0;

            parsedDrawings.add(drawing1.Drawing(
              drawingTitle: dTitle,
              drawingId: dTypeId,
              pdf: pdfList,
              dwg: dwgList,
              drawingVersion: versionsList,
              slabCheckId: "",
              submitReport: "0",
              issuse: isDisabled ? "0" : "1",
              verify: isVerified ? "1" : "0",
              isSelected: false,
              isDisabled: isDisabled,
            ));
          }
        }
      }

      towerAuthorityMap = {};
      var towerAuths = data['tower_authorities'];
      if (towerAuths is List) {
        for (var ta in towerAuths) {
          if (ta is Map && ta['id'] != null && ta['type'] != null) {
            towerAuthorityMap[ta['type'].toString().toLowerCase()] =
                ta['id'].toString();
          }
        }
      }

      List<SlabCheck> slabChecks = [
        SlabCheck(
          slabCheckTitle: "Structural Consultant",
          slabCheckId: towerAuthorityMap['structural_consultant'] ?? "1",
          towerAuthorityId: towerAuthorityMap['structural_consultant'] ?? "1",
          isSetupDone: "0",
          slabCheckStatusOk: "0",
          slabCheckStatusIssue: "0",
          clickActive: "0",
        ),
        SlabCheck(
          slabCheckTitle: "Developer",
          slabCheckId: towerAuthorityMap['developer'] ?? "2",
          towerAuthorityId: towerAuthorityMap['developer'] ?? "2",
          isSetupDone: "0",
          slabCheckStatusOk: "0",
          slabCheckStatusIssue: "0",
          clickActive: "0",
        ),
        SlabCheck(
          slabCheckTitle: "Municipal Architect",
          slabCheckId: towerAuthorityMap['municipal_architect'] ?? "3",
          towerAuthorityId: towerAuthorityMap['municipal_architect'] ?? "3",
          isSetupDone: "0",
          slabCheckStatusOk: "0",
          slabCheckStatusIssue: "0",
          clickActive: "0",
        ),
        SlabCheck(
          slabCheckTitle: "RCC Contractor",
          slabCheckId: towerAuthorityMap['rcc_contractor'] ?? "4",
          towerAuthorityId: towerAuthorityMap['rcc_contractor'] ?? "4",
          isSetupDone: "0",
          slabCheckStatusOk: "0",
          slabCheckStatusIssue: "0",
          clickActive: "0",
        ),
      ];

      List<String> disabledDrawingNames = [];
      for (var d in parsedDrawings) {
        if (d.isDisabled == true) {
          disabledDrawingNames.add(d.drawingTitle);
        }
      }
      String generatedErrorTitle = disabledDrawingNames.isNotEmpty
          ? "${disabledDrawingNames.join(' & ')} Pending"
          : "";

      bool isChecklistSubmitted = slabItem['checklist'] == true ||
          slabItem['checklist']?.toString().toLowerCase() == 'true' ||
          slabItem['check_list_flag'] == '1' ||
          slabItem['check_list_flag'] == 1;
      String checkListFlag = isChecklistSubmitted ? "1" : "0";

      SlabDetail slabItemDetail = SlabDetail(
        slabId: sId,
        slabNo: sName,
        estCompletDate: estDate,
        completedDate: compDate,
        completTitile: "",
        errorTitle: generatedErrorTitle,
        completStatus: completStatus,
        issueReport: totalPendingCount.toString(),
        issueSlabReport: slabPendingCount.toString(),
        orderSupplies: "1",
        drawings: parsedDrawings,
        slabCheck: slabChecks,
        checkListFlag: checkListFlag,
      );

      var directAuths = slabItem['authorities'] ?? slabItem['slab_authorities'];
      if (directAuths is List && directAuths.isNotEmpty) {
        _updateSlabAuthorityStatus(slabItemDetail, directAuths);
      }

      slabList.add(slabItemDetail);
    }

    return slabList;
  }

  void _updateSlabAuthorityStatus(SlabDetail slab, List authList) {
    for (var auth in authList) {
      if (auth is! Map) continue;
      String towerAuthId = auth['tower_authority_id']?.toString() ?? '';
      String authType = auth['tower_authority']?['type']?.toString().toLowerCase() ?? '';
      String completedOn = formatDateToDdMmYyyy(auth['completed_on']?.toString());
      bool isCompleted = completedOn.isNotEmpty || auth['is_active'] == true;

      for (int i = 0; i < slab.slabCheck.length; i++) {
        var sc = slab.slabCheck[i];
        bool matches = false;
        if (towerAuthId.isNotEmpty && sc.towerAuthorityId == towerAuthId) {
          matches = true;
        } else if (authType.isNotEmpty) {
          String checkTitle = sc.slabCheckTitle.toLowerCase().replaceAll(' ', '_');
          if (authType == checkTitle || authType.contains(checkTitle)) {
            matches = true;
          }
        }

        if (matches && isCompleted) {
          List<String> images = [];
          var docs = auth['documents'];
          if (docs is List) {
            for (var doc in docs) {
              if (doc is Map && doc['file_url'] != null) {
                images.add(doc['file_url'].toString());
              }
            }
          }

          slab.slabCheck[i] = SlabCheck(
            slabCheckTitle: sc.slabCheckTitle,
            slabCheckId: sc.slabCheckId,
            isSetupDone: sc.isSetupDone,
            slabCheckStatusOk: "1",
            slabCheckStatusIssue: sc.slabCheckStatusIssue,
            clickActive: sc.clickActive,
            towerAuthorityId: sc.towerAuthorityId,
            remarks: auth['remarks']?.toString(),
            completedOn: completedOn,
            documents: images,
            createdByName: auth['created_by_user']?['name']?.toString() ??
                auth['updated_by_user']?['name']?.toString(),
          );
        }
      }
    }
  }

  Future<void> _fetchAuthoritiesForSlabs(List<SlabDetail> slabs) async {
    if (slabs.isEmpty) return;
    try {
      await Future.wait(slabs.map((slab) async {
        if (slab.slabId.isEmpty) return;
        try {
          var response = await apiNetworkHandler.get(
            AppUrl.getSlabAuthorities(slab.slabId),
          );
          if (response != null &&
              (response.statusCode == 200 || response.statusCode == 201)) {
            final decoded = json.decode(response.body);
            if (decoded['success'] == true && decoded['data'] != null) {
              var authList = decoded['data']['authorities'];
              if (authList is List && authList.isNotEmpty) {
                _updateSlabAuthorityStatus(slab, authList);
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error fetching authority for slab ${slab.slabId}: $e");
          }
        }
      }));

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching slab authorities: $e");
    }
  }

  Future<Set<String>> fetchDeveloperRccCheckedSlabs(String towerId) async {
    try {
      if (towerId.isEmpty) return checkedSlabIds;
      await apiNetworkHandler.ensureProjectContext(widget.projectId);
      String url = AppUrl.getTowerDeveloperRccCount(towerId);
      var response = await apiNetworkHandler
          .get(url)
          .timeout(const Duration(seconds: 4));
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final parsed = developerRccCountResponseFromJson(response.body);
        if (parsed.success && parsed.data != null) {
          final ids = parsed.data!.developerAndRccCheckedSlabIds
              .map((e) => e.toString())
              .toSet();
          checkedSlabIds = ids;
          return ids;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching developer-rcc checked slabs: $e");
      }
    }
    return checkedSlabIds;
  }

  Future<List<SlabDetail>?> fetchRccStructureDetails() async {
    if (isLoading) return null;
    setState(() {
      isLoading = true;
      circular = true;
    });

    final selectedTowarId =
        towarListSelected?.towarId ?? widget.towarId ?? '';

    if (AppUrl.useNewBackend && selectedTowarId.isNotEmpty) {
      try {
        await apiNetworkHandler.ensureProjectContext(widget.projectId);
        final results = await Future.wait([
          apiNetworkHandler.get(
              "${AppUrl.baseURL}rcc/$selectedTowarId/progress"),
          fetchDeveloperRccCheckedSlabs(selectedTowarId),
        ]);
        var response = results[0];

        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          final decoded = json.decode(response.body);
          if (decoded['success'] == true && decoded['data'] != null) {
            List<SlabDetail> structureList =
                _parseRccProgressData(decoded['data']);
            if (mounted) {
              setState(() {
                restrictChecklistCategory = decoded['data']['restrict_checklist_category'] == true ||
                    decoded['data']['restrict_checklist_category']?.toString() == 'true';
                if (offset == '0') {
                  slabDetails = structureList;
                } else {
                  slabDetails.addAll(structureList);
                }
                errorCode = "0";
                isLoading = false;
                circular = false;
              });
              _fetchAuthoritiesForSlabs(structureList);
            }
            return slabDetails;
          }
        }
      } catch (e) {
        if (kDebugMode) print("Error fetching RCC progress API: $e");
      }
    }

    if (useRccMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final responseData =
          getMockRccStructureData(towerId: selectedTowarId, offset: offset);
      List<SlabDetail>? structureList = responseData.slabDetails;

      if (mounted) {
        setState(() {
          if (offset == '0') {
            slabDetails = structureList;
          } else {
            slabDetails.addAll(structureList);
          }
          averagedata = responseData.averagedata;
          towarList = responseData.towarList;
          if ((towarListRes == null || towarListRes!.isEmpty) &&
              responseData.towarList != null &&
              responseData.towarList!.isNotEmpty) {
            towarListRes = responseData.towarList!
                .map((t) => masonry1.TowarList(
                    towarId: t.towarId, towarName: t.towarName))
                .toList();
          }
          blockFlag = responseData.blockFlag;
          errorCode = responseData.errorCode;
          offset = responseData.offset;
          isLoading = false;
          circular = false;
        });
      }
      return slabDetails;
    }

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "offset": offset ?? '0',
      "limit": "10",
      "user_id": userId ?? '',
      "project_id": widget.projectId ?? '',
      "towar_id": selectedTowarId,
    };

    if (kDebugMode) print("Fetching Data: $data");

    try {
      var response = await apiNetworkHandler.post(
          AppUrl.getRccStructureDetailsRequest, data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = rccStructureDataFromJson(response.body);

        if (dataModel.response.errorCode == "0") {
          List<SlabDetail>? structureList = dataModel.response.slabDetails;

          if (structureList != null && structureList.isNotEmpty) {
            if (mounted) {
              setState(() {
                if (offset == '0') {
                  slabDetails = structureList;
                } else {
                  slabDetails.addAll(structureList);
                }
                averagedata = dataModel.response.averagedata;
                towarList = dataModel.response.towarList;
                blockFlag = dataModel.response.blockFlag;
                errorCode = dataModel.response.errorCode;
                offset = dataModel.response.offset;
              });
            }
          } else {
            _refreshController.loadNoData();
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print("API Fetch Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }

    return slabDetails;
  }

  Future<List<SlabDetail>?> printDrawings(
      {required String slabId, required String drawingId}) async {
    if (useRccMockData) {
      _showHardCopyDeliveryDialog();
      return null;
    }

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId ?? '',
      "slab_id": slabId,
      "drawing_id": drawingId,
    };

    var response =
        await apiNetworkHandler.post(AppUrl.setDiagramRequest, data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      _showHardCopyDeliveryDialog();
    }
    return null;
  }

  void _showHardCopyDeliveryDialog() {
    showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        final isMobile = context.isMobile;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          titlePadding:
              EdgeInsets.symmetric(vertical: 10, horizontal: isMobile ? 12 : 20),
          actionsPadding:
              const EdgeInsets.only(bottom: 10, left: 10, right: 10),
          contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
          actionsAlignment: MainAxisAlignment.center,
          title: Text(
            "Hard copy will be delivered at site in 3 working days.",
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: isMobile ? 180 : 250,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(7)),
                child: Text(
                  "Okay",
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          ((towarListSelected?.towarName ?? widget.towarName) != null &&
                  (towarListSelected?.towarName ?? widget.towarName)!.isNotEmpty)
              ? '${widget.projectName!.toUpperCase()} - ${(towarListSelected?.towarName ?? widget.towarName)!.toUpperCase()}'
              : (widget.projectName?.toUpperCase() ?? 'R.C.C STRUCTURE'),
          style: TextStyle(
            fontStyle: FontStyle.normal,
            fontSize: isMobile ? 14.0 : 17.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskListScreen(
                    projectId: widget.projectId,
                    towarId: widget.towarId ?? '',
                    projectName: widget.projectName,
                    towarName: widget.towarName ?? '',
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10 : 18, vertical: isMobile ? 4 : 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "DPR Task's",
                style: TextStyle(
                  fontSize: isMobile ? 12 : 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 12 : 50)
        ],
      ),
      bottomNavigationBar: averagedata.trim().isNotEmpty
          ? InkWell(
              onTap: () {
                showDialog<void>(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      titlePadding: EdgeInsets.symmetric(
                          vertical: 10, horizontal: isMobile ? 12 : 20),
                      actionsPadding: const EdgeInsets.only(
                          bottom: 10, left: 10, right: 10),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
                      actionsAlignment: MainAxisAlignment.center,
                      title: Text(
                        "Average Slab speed is based on a algorithm calculated on the last 3 slabs.",
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: isMobile ? 180 : 250,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(7)),
                            child: Text(
                              "Okay",
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                color: Colors.black,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Average Slab Speed : $averagedata days",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 13 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.info_rounded,
                        color: Colors.white, size: isMobile ? 16 : 20),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
      body: Container(
        color: const Color(0xfff8f9fa),
        child: Column(
          children: [
            // Header title bar
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 50, vertical: 4),
              color: Colors.white,
              child: SizedBox(
                height: isMobile ? 28 : 38,
                child: Center(
                  child: Text(
                    'R.C.C STRUCTURE',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const Divider(height: 1.0, color: Colors.black),

            // Tower Dropdown selector - only show if project has more than 1 tower
            if (towarListRes != null && towarListRes!.length > 1)
              InkWell(
                onTap: () {
                  if (towarListRes!.isNotEmpty) {
                    selectTowerModal();
                  }
                },
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: Colors.black))),
                  height: 38,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        towarListSelected?.towarName ?? '',
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 15,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Icon(Icons.arrow_drop_down)
                    ],
                  ),
                ),
              ),

            // Main List Content - Card layout for every slab item
            Expanded(
              child: errorCode == '' && slabDetails.isEmpty
                  ? RccSkeletonScreen(isMobile: isMobile)
                  : slabDetails.isNotEmpty
                      ? SmartRefresher(
                          enablePullDown: true,
                          enablePullUp: true,
                          controller: _refreshController,
                          onRefresh: _onRefresh,
                          onLoading: _onLoading,
                          footer: const ClassicFooter(
                            loadStyle: LoadStyle.ShowWhenLoading,
                          ),
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: slabDetails.length,
                            itemBuilder: (BuildContext context, int index) {
                              final isSelected = indexOfSlab == index;
                              final currentSlab = slabDetails[index];
                              final slabItemKey = _slabItemKeys.putIfAbsent(
                                currentSlab.slabId,
                                () => GlobalKey(),
                              );
                              return Container(
                                key: slabItemKey,
                                margin: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 8 : 24,
                                  vertical: isMobile ? 3 : 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black
                                        : const Color(0xffe9ecef),
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (indexOfSlab == index) {
                                            indexOfSlab = -1;
                                          } else {
                                            indexOfSlab = index;
                                            SlabDetail dict =
                                                slabDetails[indexOfSlab!];
                                            strSlabIssueCount =
                                                dict.issueSlabReport;
                                            strRccTitle =
                                                dict.slabNo.toUpperCase();
                                          }
                                          slabId = slabDetails[index].slabId;
                                          strRccTitle =
                                              slabDetails[index].slabNo;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: isMobile ? 12.0 : 16.0,
                                            vertical: isMobile ? 10.0 : 16.0),
                                        child: MyExpandableWidget(
                                          plist: slabDetails[index],
                                          ind: index,
                                          isMobile: isMobile,
                                        ),
                                      ),
                                    ),
                                    if (indexOfSlab == index)
                                      Container(
                                        padding: EdgeInsets.all(
                                            isMobile ? 8 : 16),
                                        decoration: const BoxDecoration(
                                          color: Color(0xfff8f9fa),
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(12),
                                            bottomRight: Radius.circular(12),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(height: isMobile ? 2 : 4),
                                            _drawingHeaderTitle(
                                              draw: slabDetails[indexOfSlab!]
                                                  .drawings,
                                              dataa: slabDetails[indexOfSlab!],
                                              isMobile: isMobile,
                                            ),
                                            SizedBox(height: isMobile ? 4 : 8),
                                            const Divider(
                                                height: 1.0, color: Colors.black),
                                            SizedBox(height: isMobile ? 4 : 8),
                                            Column(
                                              children: List.generate(
                                                slabDetails[indexOfSlab!]
                                                    .drawings
                                                    .length,
                                                (dIdx) {
                                                    return DrawingsList(
                                                      plist:
                                                          slabDetails[indexOfSlab!]
                                                              .drawings[dIdx],
                                                      projectId:
                                                          widget.projectId ?? '',
                                                      towarId:
                                                          widget.towarId ?? '',
                                                      projectName:
                                                          widget.projectName ?? '',
                                                      towarName:
                                                          towarListSelected?.towarName ?? widget.towarName ?? '',
                                                      slabNo: strRccTitle,
                                                      afterPopFun: () {
                                                        errorCode = '';
                                                        offset = '0';
                                                        slabDetails = [];
                                                        fetchRccStructureDetails();
                                                      },
                                                      isMobile: isMobile,
                                                      slabId: slabId,
                                                      towerAuthorityMap: towerAuthorityMap,
                                                    );
                                                },
                                              ),
                                            ),
                                            SizedBox(height: isMobile ? 4 : 8),
                                            const Divider(
                                                height: 1.0, color: Colors.black),
                                            SizedBox(height: isMobile ? 4 : 8),
                                            _slabHeaderTitle(
                                              plist: slabDetails[index],
                                              titlee: slabDetails[index].slabNo,
                                              isMobile: isMobile,
                                            ),
                                            SizedBox(height: isMobile ? 4 : 8),
                                            const Divider(
                                                height: 1.0, color: Colors.black),
                                            SizedBox(height: isMobile ? 4 : 8),
                                            Column(
                                              children: List.generate(
                                                slabDetails[indexOfSlab!]
                                                    .slabCheck
                                                    .length,
                                                (cIdx) {
                                                  return SlabCheckList(
                                                    plist:
                                                        slabDetails[indexOfSlab!]
                                                            .slabCheck[cIdx],
                                                    isMobile: isMobile,
                                                    estCompletDate:
                                                        slabDetails[indexOfSlab!]
                                                            .estCompletDate,
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
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
  }

  void selectTowerModal() {
    showDialog<void>(
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
                "Select Tower",
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
              height: 300,
              width: 400,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: towarListRes?.length ?? 0,
                itemBuilder: (context, i) {
                  final item = towarListRes?[i];
                  final bool isSelected =
                      towarListSelected?.towarId == item?.towarId;
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.15),
                        ),
                      ),
                    ),
                    margin: const EdgeInsets.only(bottom: 6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xfff8f9fa)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: RadioListTile<String>(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        activeColor: Colors.black,
                        title: Text(
                          item?.towarName ?? '',
                          style: TextStyle(
                            fontFamily: 'HelveticaNeue',
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected ? Colors.black : Colors.black87,
                          ),
                        ),
                        value: item?.towarId ?? i.toString(),
                        groupValue: towarListSelected?.towarId ?? '',
                        onChanged: (value) {
                          setState2(() {
                            towarListSelected = item;
                          });
                          errorCode = '';
                          offset = '0';
                          slabDetails = [];
                          checkedSlabIds.clear();
                          fetchRccStructureDetails();
                          setState(() {});
                          Navigator.pop(dialogContext);
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
      },
    );
  }

  Widget _drawingHeaderTitle(
      {required List<drawing1.Drawing> draw,
      required SlabDetail dataa,
      required bool isMobile}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8.0 : 12.0,
        vertical: isMobile ? 6.0 : 8.0,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Row(
        children: [
          SizedBox(
            width: isMobile ? 60.0 : 80.0,
            child: Text(
              'VERIFIED',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'DRAWINGS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () => setReportingToModal(draw: draw, dataa: dataa),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(width: 1.0, color: Colors.black45),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              fixedSize: Size(
                isMobile ? 65.0 : 88.0,
                isMobile ? 20.0 : 25.0,
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.print_outlined,
                    color: const Color.fromRGBO(0, 128, 43, 1.0),
                    size: isMobile ? 12 : 15),
                SizedBox(width: isMobile ? 3 : 5),
                Text(
                  'Print',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: isMobile ? 11.0 : 12.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _slabHeaderTitle(
      {required String titlee,
      required SlabDetail plist,
      required bool isMobile}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8.0 : 12.0,
        vertical: isMobile ? 6.0 : 8.0,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Row(
        children: [
          SizedBox(width: isMobile ? 60.0 : 80.0),
          Expanded(
            child: Text(
              'SLAB STATUS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _slabIssueReported(plist, isMobile),
              if (int.tryParse(plist.issueSlabReport) != null &&
                  int.parse(plist.issueSlabReport) > 0)
                const SizedBox(width: 6),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(
                    '/issueRccReportScreen',
                    arguments: NotificationArgs(
                      projectId: widget.projectId,
                      projectName: widget.projectName,
                      towarName: towarListSelected?.towarName ?? widget.towarName,
                      response: NotificationResponseData(
                        slabCheckId: slabId,
                        slabCheckType: '1',
                        slabId: slabId,
                        slabNo: plist.slabNo,
                        drawingTitle: 'SLAB STATUS',
                        towarId: widget.towarId,
                        drawingId: '',
                        targetType: 'slab',
                        towerAuthorityMap: towerAuthorityMap,
                      ),
                    ),

                  )
                      .then((value) {
                    errorCode = '';
                    offset = '0';
                    slabDetails = [];
                    fetchRccStructureDetails();
                  });
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.black,
                  side: const BorderSide(width: 1.0, color: Colors.black45),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  fixedSize: Size(
                    isMobile ? 92.0 : 120.0,
                    isMobile ? 20.0 : 25.0,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'Report Issues',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: isMobile ? 11.0 : 12.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _slabIssueReported(SlabDetail plist, bool isMobile) {
    if (int.tryParse(plist.issueSlabReport) != null &&
        int.parse(plist.issueSlabReport) > 0) {
      return OutlinedButton(
        onPressed: () {
          Navigator.of(context)
              .pushNamed(
            '/issueRccReportScreen',
            arguments: NotificationArgs(
              projectId: widget.projectId,
              projectName: widget.projectName,
              towarName: towarListSelected?.towarName ?? widget.towarName,
              response: NotificationResponseData(
                slabCheckId: slabId,
                slabCheckType: '1',
                slabId: slabId,
                slabNo: plist.slabNo,
                drawingTitle: 'SLAB STATUS',
                towarId: widget.towarId,
                drawingId: '',
                targetType: 'slab',
                towerAuthorityMap: towerAuthorityMap,
              ),
            ),

          )
              .then((value) {
            errorCode = '';
            offset = '0';
            slabDetails = [];
            fetchRccStructureDetails();
          });
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(width: 1.0, color: Colors.red),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          fixedSize: Size(
            isMobile ? 112.0 : 140.0,
            isMobile ? 20.0 : 25.0,
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.report_problem_outlined,
                color: Colors.red, size: isMobile ? 12 : 15),
            SizedBox(width: isMobile ? 2 : 4),
            _issueReportedText(plist, isMobile),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _issueReportedText(SlabDetail plist, bool isMobile) {
    final textStyle = TextStyle(
      color: Colors.red,
      fontSize: isMobile ? 11.0 : 13.0,
      fontWeight: FontWeight.normal,
    );
    if (plist.issueSlabReport != '0') {
      return Text(
        '${plist.issueSlabReport} Issue Reported',
        style: textStyle,
      );
    } else {
      return Text(
        'Issues Reported',
        style: textStyle,
      );
    }
  }

  Widget MyExpandableWidget(
      {required SlabDetail plist,
      required int ind,
      required bool isMobile}) {
    String getDelayText(String estDateStr, String completedDateStr) {
      if (estDateStr.trim().isEmpty || completedDateStr.trim().isEmpty) return '';

      DateTime? parseDate(String dateStr) {
        if (dateStr.trim().isEmpty) return null;
        final cleaned = dateStr.trim().replaceAll(RegExp(r'(st|nd|rd|th)'), '');

        DateTime? parsed = DateTime.tryParse(cleaned);
        if (parsed != null) return DateTime(parsed.year, parsed.month, parsed.day);

        try {
          final parts = cleaned.split('/');
          if (parts.length == 3) {
            final d = int.parse(parts[0]);
            final m = int.parse(parts[1]);
            final y = int.parse(parts[2]);
            return DateTime(y, m, d);
          }
        } catch (_) {}

        try {
          final parts = cleaned.split('-');
          if (parts.length == 3) {
            if (parts[0].length == 4) {
              return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
            } else if (parts[2].length == 4) {
              return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
            }
          }
        } catch (_) {}

        try {
          return DateFormat("d MMM yyyy").parse(cleaned);
        } catch (_) {}
        try {
          return DateFormat("dd MMM yyyy").parse(cleaned);
        } catch (_) {}

        return null;
      }

      try {
        final estDate = parseDate(estDateStr);
        final completedDate = parseDate(completedDateStr);

        if (estDate == null || completedDate == null) return '';

        final diff = completedDate.difference(estDate).inDays;

        if (diff > 0) {
          return 'Delayed ($diff ${diff == 1 ? 'Day' : 'Days'})';
        } else if (diff < 0) {
          return 'Advance (${diff.abs()} ${diff.abs() == 1 ? 'Day' : 'Days'})';
        } else {
          return '';
        }
      } catch (e) {
        return '';
      }
    }

    final delayText = getDelayText(plist.estCompletDate, plist.completedDate);
    final bool hasCompletedDate = plist.completedDate.trim().isNotEmpty &&
        plist.completedDate.trim() != '-' &&
        plist.completedDate.trim().toLowerCase() != 'null';
    final bool isSlabCompleted = AppUrl.useNewBackend
        ? (checkedSlabIds.contains(plist.slabId.trim()) || hasCompletedDate)
        : (plist.completStatus == "1" || hasCompletedDate);
    final boldTitleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: isMobile ? 14.0 : 16.0,
      color: Colors.black,
    );
    final normalBodyStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: isMobile ? 12.0 : 16.0,
      color: Colors.black,
    );
    final normalRedStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: isMobile ? 12.0 : 15.0,
      color: Colors.red,
    );
    final buttonTextStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: isMobile ? 11.5 : 16.0,
      color: Colors.black,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column Details
        Expanded(
          flex: isMobile ? 5 : 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Slab Title
              Text(plist.slabNo, style: boldTitleStyle),
              const SizedBox(height: 4),

              // Error / Pending drawings text (clickable red label)
              if (plist.errorTitle.isNotEmpty) ...[
                InkWell(
                  onTap: () => _showDrawingsWithoutAttachmentsModal(context, plist),
                  child: Text(
                    "Drawings Without Attachments",
                    style: normalRedStyle,
                  ),
                ),
                const SizedBox(height: 4),
              ],

              // Est Deadline
              Text('Est Deadline - ${formatDateToDdMmYyyy(plist.estCompletDate)}', style: normalBodyStyle),
              const SizedBox(height: 4),

              // Completed On
              if (plist.completedDate.isNotEmpty) ...[
                Text('Completed on - ${formatDateToDdMmYyyy(plist.completedDate)}', style: normalBodyStyle),
                const SizedBox(height: 2),
                if (delayText.isNotEmpty)
                  Text(
                    delayText,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 11.5 : 14.0,
                      color: delayText.startsWith('Delayed')
                          ? Colors.grey.shade600
                          : (delayText.startsWith('Advance') ? Colors.green : Colors.grey),
                    ),
                  ),
                const SizedBox(height: 6),
              ],

              // Issue report text (target_type slab and drawing both)
              if (plist.issueReport != '0' && plist.issueReport.isNotEmpty) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.report_problem_outlined,
                        color: Colors.red, size: isMobile ? 16 : 18),
                    SizedBox(width: isMobile ? 4 : 10),
                    Flexible(
                      child: Text(
                        plist.issueReport == '1'
                            ? '1 Issue Reported'
                            : '${plist.issueReport} Issues Reported',
                        style: normalRedStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Excavation/Debris Button
              if (ind == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExcavationScreen(
                            slabId: plist.slabId,
                            title: plist.slabNo,
                            projectId: widget.projectId,
                            towarId: widget.towarId!,
                            projectName: widget.projectName,
                            towarName: widget.towarName!,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(width: 1.0, color: Colors.black45),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      fixedSize: Size(
                        isMobile ? 120.0 : 148.0,
                        isMobile ? 25.0 : 31.0,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      'Excavation/Debris',
                      style: TextStyle(
                        fontSize: isMobile ? 10.5 : 12.5,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        SizedBox(width: isMobile ? 8 : 16),

        // Right Column Actions & Checkmark Icon
        Expanded(
          flex: isMobile ? 5 : 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Top Right Checkmark Icon
              isSlabCompleted
                  ? buildFilledGreenTickIcon(size: isMobile ? 18.0 : 22.0)
                  : Icon(Icons.circle_outlined,
                      color: Colors.black45, size: isMobile ? 20 : 24),
              SizedBox(height: isMobile ? 4 : 8),

              // Daily Progress Report Button
              OutlinedButton(
                onPressed: () {
                  setState(() => slabId = plist.slabId);
                  Navigator.of(context)
                      .pushNamed(
                    '/dailyProgressReportScreen',
                    arguments: NotificationArgs(
                      projectId: widget.projectId!,
                      projectName: widget.projectName!,
                      towarName: widget.towarName,
                      response: NotificationResponseData(
                        towarId: widget.towarId,
                        slabNo: plist.slabNo,
                        slabId: slabId,
                      ),
                    ),
                  )
                      .then((value) {
                    errorCode = '';
                    offset = '0';
                    slabDetails = [];
                    fetchRccStructureDetails();
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 1.0, color: Colors.black45),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  fixedSize: Size(
                    isMobile ? 136.0 : 175.0,
                    isMobile ? 25.0 : 31.0,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'Daily Progress Report',
                  style: TextStyle(
                    fontSize: isMobile ? 11.0 : 12.5,
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 3 : 6),

              // Order Supplies Button
              if (blockFlag == '1' || plist.orderSupplies == '1') ...[
                OutlinedButton(
                  onPressed: () {
                    setState(() => slabId = plist.slabId);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderSuppliesScreen(
                          projectId: widget.projectId!,
                          towarId: widget.towarId!,
                          projectName: widget.projectName!,
                          towarName: widget.towarName!,
                          title: plist.slabNo,
                          slabId: slabId,
                        ),
                      ),
                    ).then((value) {
                      errorCode = '';
                      offset = '0';
                      slabDetails = [];
                      fetchRccStructureDetails();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(width: 1.0, color: Colors.black45),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    fixedSize: Size(
                      isMobile ? 136.0 : 175.0,
                      isMobile ? 25.0 : 31.0,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'Order Supplies',
                    style: TextStyle(
                      fontSize: isMobile ? 11.0 : 12.5,
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 3 : 6),
              ],

              // Checklist Button with optional left checkmark icon
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (plist.checkListFlag == "1") ...[
                    buildGreenTickIcon(size: isMobile ? 16.0 : 20.0),
                    SizedBox(width: isMobile ? 4 : 8),
                  ],
                  OutlinedButton(
                    onPressed: () {
                      setState(() => slabId = plist.slabId);
                      Navigator.of(context)
                          .pushNamed(
                        '/checklistScreen',
                        arguments: NotificationArgs(
                          projectId: widget.projectId!,
                          projectName: widget.projectName!,
                          towarName: widget.towarName,
                          response: NotificationResponseData(
                            towarId: widget.towarId,
                            slabNo: plist.slabNo,
                            slabId: slabId,
                            restrictChecklistCategory: restrictChecklistCategory,
                          ),
                        ),
                      )
                          .then((value) {
                        errorCode = '';
                        offset = '0';
                        slabDetails = [];
                        fetchRccStructureDetails();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(width: 1.0, color: Colors.black45),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      fixedSize: Size(
                        isMobile ? 136.0 : 175.0,
                        isMobile ? 25.0 : 31.0,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      'Checklist',
                      style: TextStyle(
                        fontSize: isMobile ? 11.0 : 12.5,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget SlabCheckList(
      {required SlabCheck plist,
      required bool isMobile,
      String? estCompletDate,
      String? slabIdParam}) {
    final effectiveSlabId = (slabIdParam != null && slabIdParam.isNotEmpty)
        ? slabIdParam
        : slabId;
    final isHighlighted =
        highlightedChecklistId == plist.slabCheckId;
    final checkKey = plist.slabCheckId.isNotEmpty
        ? _checklistKeys.putIfAbsent(
            plist.slabCheckId,
            () => GlobalKey(),
          )
        : null;

    return Container(
      key: checkKey,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SlabStatusScreen(
                projectId: widget.projectId!,
                towarId: widget.towarId,
                projectName: widget.projectName!,
                towarName: widget.towarName,
                title: strRccTitle,
                plist: plist,
                slabId: effectiveSlabId,
                estCompletDate: estCompletDate,
                isSlabExist: plist.slabCheckStatusOk == "1",
                towerAuthorityMap: towerAuthorityMap,
              ),
            ),
          ).then((value) async {
            final targetSlabId = (value is Map && value['slabId'] != null)
                ? value['slabId'].toString()
                : effectiveSlabId;
            final targetChecklistId =
                (value is Map && value['checklistId'] != null)
                    ? value['checklistId'].toString()
                    : plist.slabCheckId;
            final bool wasSubmitted =
                value is Map && value['submitted'] == true;

            errorCode = '';
            offset = '0';
            slabDetails = [];
            _slabItemKeys.clear();
            _checklistKeys.clear();
            await fetchRccStructureDetails();

            if (targetSlabId != null && targetSlabId.isNotEmpty) {
              _scrollToSlab(
                targetSlabId,
                targetChecklistId: targetChecklistId,
                wasSubmitted: wasSubmitted,
              );
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: EdgeInsets.symmetric(
              vertical: isMobile ? 3.0 : 5.0, horizontal: 4.0),
          decoration: BoxDecoration(
            color: isHighlighted
                ? Colors.green.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: isMobile ? 26.0 : 28.0,
                ),
                child: Row(
                  children: [
                    SizedBox(width: isMobile ? 60.0 : 80.0),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          plist.slabCheckTitle,
                          style: TextStyle(
                            fontSize: isMobile ? 12.0 : 14.0,
                            fontWeight: isHighlighted
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isHighlighted
                                ? Colors.green.shade800
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 46.0 : 60.0),
                    SizedBox(width: isMobile ? 4.0 : 8.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        plist.slabCheckStatusOk == "1"
                            ? buildGreenTickIcon(size: isMobile ? 16.0 : 20.0)
                            : Icon(Icons.circle_outlined,
                                color: Colors.black45, size: isMobile ? 16 : 20),
                        Icon(Icons.keyboard_arrow_right,
                            color: Colors.black, size: isMobile ? 16 : 20),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 3.0 : 5.0),
              const Divider(height: 1.0, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }

  void _showDrawingsWithoutAttachmentsModal(BuildContext context, SlabDetail plist) {
    final isMobile = context.isMobile;

    List<String> missingDrawingNames = plist.drawings
        .where((d) => d.isDisabled == true)
        .map((d) => d.drawingTitle)
        .toList();

    if (missingDrawingNames.isEmpty && plist.errorTitle.isNotEmpty) {
      missingDrawingNames = plist.errorTitle
          .replaceAll(" Pending", "")
          .split(" & ")
          .where((s) => s.trim().isNotEmpty)
          .toList();
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.only(
            left: isMobile ? 12 : 16,
            right: isMobile ? 12 : 16,
            top: isMobile ? 14 : 18,
            bottom: isMobile ? 8 : 12,
          ),
          actionsPadding: EdgeInsets.only(
            bottom: isMobile ? 12 : 16,
            top: 0,
            left: 12,
            right: 12,
          ),
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
              "DRAWINGS WITHOUT ATTACHMENTS",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 13 : 15,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: Container(
            width: isMobile ? 280 : 380,
            constraints: BoxConstraints(
              maxHeight: isMobile ? 240 : 300,
            ),
            child: missingDrawingNames.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        "No Drawings Without Attachments",
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: missingDrawingNames.map((name) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: isMobile ? 16 : 22,
                            right: isMobile ? 8 : 12,
                            top: 6.0,
                            bottom: 6.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: isMobile ? 5 : 6),
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.black87,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: isMobile ? 10 : 12),
                              Expanded(
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: isMobile ? 13 : 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
          actions: [
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "CLOSE",
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void setReportingToModal(
      {required List<drawing1.Drawing> draw, required SlabDetail dataa}) {
    final isMobile = context.isMobile;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                  "PRINT DRAWINGS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setStateInner) {
                  return SizedBox(
                    height: 220,
                    width: isMobile ? 280 : 380,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < draw.length; i++)
                            InkWell(
                              onTap: () {
                                setStateInner(() {
                                  draw[i].isSelected =
                                      !(draw[i].isSelected ?? false);
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey.shade200),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        draw[i].drawingTitle,
                                        style: TextStyle(
                                          fontSize: isMobile ? 13 : 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (draw[i].isSelected == true)
                                      const Icon(Icons.check_circle,
                                          color: Colors.green)
                                    else
                                      const Icon(Icons.circle_outlined,
                                          color: Colors.black45),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              actions: <Widget>[
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: isMobile ? 100 : 130,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "CLOSE",
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    String temp = "";
                    for (int i = 0; i < draw.length; i++) {
                      if (draw[i].isSelected == true) {
                        temp += (temp.isNotEmpty ? "," : "") +
                            draw[i].drawingId;
                      }
                    }
                    Navigator.of(context).pop();
                    printDrawings(
                      drawingId: temp,
                      slabId: dataa.slabId,
                    );
                  },
                  child: Container(
                    width: isMobile ? 100 : 130,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "SUBMIT",
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class DrawingsList extends StatelessWidget {
  const DrawingsList(
      {Key? key,
      required this.plist,
      this.projectId,
      this.towarId,
      this.projectName,
      this.towarName,
      this.slabNo,
      required this.afterPopFun,
      required this.isMobile,
      this.slabId,
      this.towerAuthorityMap})
      : super(key: key);

  final drawing1.Drawing plist;
  final String? slabNo;
  final String? slabId;
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final Function afterPopFun;
  final bool isMobile;
  final Map<String, String>? towerAuthorityMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 3.0 : 5.0, horizontal: 4.0),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              if (plist.issuse != "0" && plist.isDisabled != true) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RevisionRccStructerView(
                      drawingId: plist.drawingId,
                      projectId: projectId!,
                      towarId: towarId!,
                      projectName: projectName!,
                      towarName: towarName,
                      projectSubTitle:
                          '${slabNo!} - ${plist.drawingTitle.toUpperCase()}',
                      drawingVersion: plist.drawingVersion,
                      documentPath: "RCC",
                      slabId: slabId,
                    ),
                  ),
                );
              }
            },
            child: _drawingTitle(context),
          ),
          SizedBox(height: isMobile ? 3.0 : 5.0),
          const Divider(height: 1.0, color: Colors.black38),
        ],
      ),
    );
  }

  Widget _drawingTitle(BuildContext context) {
    final bool isInactive = plist.issuse == "0" || plist.isDisabled == true;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: isMobile ? 26.0 : 28.0,
      ),
      child: Row(
        children: [
          SizedBox(
            width: isMobile ? 60.0 : 80.0,
            child: Align(
              alignment: Alignment.center,
              child: _drawingIssueCompleteIcon(context: context),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                plist.drawingTitle,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: isMobile ? 12.0 : 14.0,
                  color: isInactive ? Colors.grey : Colors.black87,
                ),
              ),
            ),
          ),
          if (plist.issuse == "1")
            InkWell(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(
                  '/issueRccReportScreen',
                  arguments: NotificationArgs(
                    projectId: projectId,
                    projectName: projectName,
                    towarName: towarName,
                    response: NotificationResponseData(
                      slabCheckId: plist.slabCheckId,
                      slabCheckType: '0',
                      slabId: slabId,
                      slabNo: slabNo,
                      drawingTitle: plist.drawingTitle,
                      towarId: towarId,
                      drawingId: plist.drawingId,
                      targetType: 'drawing',
                      slabDrawingTypeId: plist.drawingId,
                      towerAuthorityMap: towerAuthorityMap,
                    ),
                  ),
                )
                    .then((value) => afterPopFun());
              },
              child: Container(
                width: isMobile ? 60.0 : 75.0,
                height: isMobile ? 25.0 : 30.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(width: 1.0, color: Colors.black45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Issues',
                  style: TextStyle(
                    fontSize: isMobile ? 11.0 : 12.5,
                    color: Colors.black87,
                    height: 1.0,
                  ),
                ),
              ),
            )
          else
            SizedBox(width: isMobile ? 60 : 75),
          SizedBox(width: isMobile ? 4 : 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _drawingCheckCompleteStatus(),
              Icon(Icons.keyboard_arrow_right,
                  color: Colors.black, size: isMobile ? 16 : 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _drawingIssueCompleteIcon({required BuildContext context}) {
    if (plist.submitReport == "1") {
      return InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed(
            '/issueRccReportScreen',
            arguments: NotificationArgs(
              projectId: projectId,
              projectName: projectName,
              response: NotificationResponseData(
                slabCheckId: plist.slabCheckId,
                slabCheckType: '0',
                slabId: slabId,
                drawingTitle: plist.drawingTitle,
                towarId: towarId,
                drawingId: plist.drawingId,
              ),
            ),
          )
              .then((value) => afterPopFun());
        },
        child: Icon(Icons.report_problem_outlined,
            color: Colors.red, size: isMobile ? 16 : 20),
      );
    } else {
      if (plist.verify == "1") {
        return buildBlueTickIcon(size: isMobile ? 16.0 : 20.0);
      } else {
        return Icon(Icons.circle_outlined,
            color: Colors.black45, size: isMobile ? 16 : 20);
      }
    }
  }

  Widget _drawingCheckCompleteStatus() {
    if (plist.issuse == "1") {
      return buildGreenTickIcon(size: isMobile ? 16.0 : 20.0);
    } else {
      return Icon(Icons.circle_outlined,
          color: Colors.black45, size: isMobile ? 16 : 20);
    }
  }
}

Widget buildBlueTickIcon({double size = 16.0}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.blueAccent, width: 1.5),
    ),
    child: Center(
      child: Icon(
        Icons.check,
        color: Colors.blueAccent,
        size: size * 0.7,
      ),
    ),
  );
}

Widget buildGreenTickIcon({double size = 16.0}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.green, width: 1.5),
    ),
    child: Center(
      child: Icon(
        Icons.check,
        color: Colors.green,
        size: size * 0.7,
      ),
    ),
  );
}

Widget buildFilledGreenTickIcon({double size = 16.0}) {
  return Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: Colors.green,
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: size * 0.7,
      ),
    ),
  );
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
            padding:
                const EdgeInsets.symmetric(vertical: 11.0, horizontal: 24.0),
            decoration: BoxDecoration(
              color: _isHovered
                  ? (widget.backgroundColor == Colors.black
                      ? const Color(0xff222222)
                      : widget.backgroundColor.withOpacity(0.9))
                  : widget.backgroundColor,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: widget.backgroundColor == Colors.white
                    ? const Color(0xffcccccc)
                    : Colors.transparent,
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

String formatDateToDdMmYyyy(String? dateStr) {
  if (dateStr == null || dateStr.trim().isEmpty) return '';
  final cleaned = dateStr.trim();
  if (cleaned.toLowerCase() == 'null' || cleaned == '-') return '';
  try {
    final dt = DateTime.parse(cleaned);
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month/${dt.year}';
  } catch (_) {}

  try {
    final rawDate = cleaned.contains('T') ? cleaned.split('T')[0] : cleaned;
    final parts = rawDate.split('-');
    if (parts.length == 3 && parts[0].length == 4) {
      return '${parts[2].padLeft(2, '0')}/${parts[1].padLeft(2, '0')}/${parts[0]}';
    }
  } catch (_) {}

  return cleaned;
}
