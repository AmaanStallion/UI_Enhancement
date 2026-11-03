import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/models/sop_document_response_model.dart';
import 'package:stallion/models/sop_user_list_modal.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';

import 'package:stallion/models/sop_history_model.dart';

bool isInvalidProjName(String? name) {
  if (name == null || name.trim().isEmpty) return true;
  final n = name.trim().toLowerCase();
  return n == 'all' ||
      n.contains('all project') ||
      n.contains('all projects') ||
      n.contains('sop submitted');
}

bool isInvalidTowerName(String? name) {
  if (name == null || name.trim().isEmpty) return true;
  final n = name.trim().toLowerCase();
  return n == 'all' ||
      n.contains('all tower') ||
      n.contains('all towers') ||
      int.tryParse(n) != null;
}

Map<String, String> parseSopNotificationBody(String? body) {
  if (body == null || body.isEmpty) {
    return {'categoryName': '', 'towerName': '', 'projectName': ''};
  }

  String categoryName = '';
  String towerName = '';
  String projectName = '';

  final lower = body.toLowerCase();
  int submitIndex = lower.indexOf(' has been submitted');
  if (submitIndex == -1) {
    submitIndex = lower.indexOf(' submitted by');
  }
  if (submitIndex != -1) {
    categoryName = body.substring(0, submitIndex).trim();
  }

  int forIndex = lower.indexOf(' for ');
  int atIndex = lower.lastIndexOf(' at ');
  if (forIndex != -1 && atIndex != -1 && atIndex > forIndex + 5) {
    towerName = body.substring(forIndex + 5, atIndex).trim();
  }

  if (atIndex != -1) {
    String afterAt = body.substring(atIndex + 4).trim();
    if (afterAt.endsWith('.')) {
      afterAt = afterAt.substring(0, afterAt.length - 1).trim();
    }
    projectName = afterAt;
  }

  return {
    'categoryName': categoryName,
    'towerName': towerName,
    'projectName': projectName,
  };
}

class SopDocsScreen extends StatefulWidget {
  const SopDocsScreen({
    Key? key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    this.title,
    this.sopId,
    this.historyList,
  }) : super(key: key);
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? title;
  final String? sopId;
  final List<SopHistoryItem>? historyList;

  @override
  State<SopDocsScreen> createState() => _SopDocsScreenState();
}

class _SopDocsScreenState extends State<SopDocsScreen> {
  bool get isMobile => context.isMobile;
  final NetworkHandler apiNetworkHandler = NetworkHandler();
  static const bool testWithMockData = false;
  bool _isLoading = true;
  NotificationArgs? _routeArgs;

  List<SopListDetail>? sopListDetails = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalArgs = ModalRoute.of(context)?.settings.arguments;
    if (modalArgs is NotificationArgs) {
      _routeArgs = modalArgs;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  Future<List<dynamic>?> fetchSopDetails() async {
    setState(() {
      _isLoading = true;
    });

    final String resolvedSopId = widget.sopId ?? _routeArgs?.response?.categoryId ?? '';

    if (widget.historyList != null && widget.historyList!.isNotEmpty) {
      List<SopListDetail> resultDocs = [];
      for (var item in widget.historyList!) {
        resultDocs.add(SopListDetail(
          id: item.id,
          sopId: resolvedSopId,
          userIdFk: item.id,
          userName: item.submittedBy ?? 'User',
          sopFileName: item.fileName,
          filePath: item.viewUrl,
          createdAt: _formatDate(item.date),
        ));
      }
      setState(() {
        sopListDetails = resultDocs;
        _isLoading = false;
      });
      return sopListDetails;
    }

    if (testWithMockData) {
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        sopListDetails = [
          SopListDetail(
            id: "1",
            sopId: resolvedSopId,
            userIdFk: "11",
            userName: "John Doe",
            sopFileName: "excavation_safety_audit.pdf",
            filePath: "dummy.pdf",
            createdAt: "10-07-2026",
          ),
          SopListDetail(
            id: "2",
            sopId: resolvedSopId,
            userIdFk: "12",
            userName: "Jane Smith",
            sopFileName: "concreting_checklist.pdf",
            filePath: "dummy.pdf",
            createdAt: "12-07-2026",
          ),
        ];
        _isLoading = false;
      });
      return sopListDetails;
    }

    try {
      List<SopListDetail> resultDocs = [];
      String towerId = widget.towarId ?? _routeArgs?.response?.towarId ?? _routeArgs?.towarIdFk ?? '';
      String categoryId = resolvedSopId;

      if (towerId.isNotEmpty && categoryId.isNotEmpty) {
        String historyUrl = AppUrl.devSopHistory(towerId, categoryId);
        var response = await apiNetworkHandler.get(historyUrl);

        if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
          final historyModel = devSopHistoryResponseFromJson(response.body);
          for (var doc in historyModel.data ?? []) {
            resultDocs.add(SopListDetail(
              id: doc.id,
              sopId: categoryId,
              userIdFk: doc.id,
              userName: doc.submittedBy ?? 'User',
              sopFileName: doc.fileName,
              filePath: doc.viewUrl,
              createdAt: _formatDate(doc.date),
            ));
          }
        }
      }

      // Fallback to devSopDocuments if history list was empty
      if (resultDocs.isEmpty && towerId.isNotEmpty) {
        String docUrl = categoryId.isNotEmpty
            ? "${AppUrl.devSopDocuments}?tower_id=$towerId&sub_heading_id=$categoryId"
            : "${AppUrl.devSopDocuments}?tower_id=$towerId";

        var response = await apiNetworkHandler.get(docUrl);
        if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
          final docModel = devSopDocResponseFromJson(response.body);
          for (var doc in docModel.documentList) {
            String formattedDate = doc.createdAt != null
                ? DateFormat('dd-MM-yyyy').format(doc.createdAt!)
                : '';

            resultDocs.add(SopListDetail(
              id: doc.id,
              sopId: categoryId,
              userIdFk: doc.uploader?.id ?? doc.uploadedBy,
              userName: doc.uploader?.name ?? 'User',
              sopFileName: doc.fileName,
              filePath: doc.fileUrl ?? doc.fileKey ?? '',
              createdAt: formattedDate,
            ));
          }
        }
      }

      setState(() {
        sopListDetails = resultDocs;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching SOP docs: $e");
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    return null;
  }

  String? _resolvedProjectName;
  String? _resolvedTowerName;
  String? _resolvedCategoryName;

  Future<void> _resolveProjectAndTowerNames() async {
    String projId = widget.projectId ?? _routeArgs?.projectId ?? _routeArgs?.response?.projectId ?? '';
    String towerId = widget.towarId ?? _routeArgs?.response?.towarId ?? _routeArgs?.towarIdFk ?? '';
    String categoryId = widget.sopId ?? _routeArgs?.response?.categoryId ?? '';

    String currentProjName = (widget.projectName != null && !isInvalidProjName(widget.projectName))
        ? widget.projectName!
        : (_routeArgs?.projectName != null && !isInvalidProjName(_routeArgs?.projectName))
            ? _routeArgs!.projectName!
            : '';

    if (isInvalidProjName(currentProjName)) {
      final parsed = parseSopNotificationBody(_routeArgs?.msg ?? widget.title);
      if (parsed['projectName']?.isNotEmpty == true && !isInvalidProjName(parsed['projectName'])) {
        currentProjName = parsed['projectName']!;
      }
    }

    if (isInvalidProjName(currentProjName) && projId.isNotEmpty) {
      try {
        var response = await apiNetworkHandler.getWithMasterToken(AppUrl.getMobileProjectList);
        if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
          final decoded = json.decode(response.body);
          final List list = (decoded['data'] is Map ? decoded['data']['projects'] : decoded['data']) as List? ?? [];
          for (var item in list) {
            if (item['id']?.toString() == projId) {
              currentProjName = item['name']?.toString() ?? currentProjName;
              break;
            }
          }
        }
      } catch (_) {}
    }

    String currentTowerName = (widget.towarName != null && !isInvalidTowerName(widget.towarName))
        ? widget.towarName!
        : (_routeArgs?.towarName != null && !isInvalidTowerName(_routeArgs?.towarName))
            ? _routeArgs!.towarName!
            : (_routeArgs?.projectLocation != null && !isInvalidTowerName(_routeArgs?.projectLocation))
                ? _routeArgs!.projectLocation!
                : '';

    if (isInvalidTowerName(currentTowerName)) {
      final parsed = parseSopNotificationBody(_routeArgs?.msg ?? widget.title);
      if (parsed['towerName']?.isNotEmpty == true && !isInvalidTowerName(parsed['towerName'])) {
        currentTowerName = parsed['towerName']!;
      }
    }

    if (isInvalidTowerName(currentTowerName) && projId.isNotEmpty && towerId.isNotEmpty) {
      try {
        var towerResp = await apiNetworkHandler.get("${AppUrl.baseURL}towers?project_id=$projId");
        if (towerResp != null && (towerResp.statusCode == 200 || towerResp.statusCode == 201)) {
          final decoded = json.decode(towerResp.body);
          if (decoded['success'] == true && decoded['data'] is List) {
            for (var t in decoded['data']) {
              if (t['id']?.toString() == towerId) {
                currentTowerName = t['name']?.toString() ?? currentTowerName;
                break;
              }
            }
          }
        }
      } catch (_) {}
    }

    String currentCategoryName = '';
    final parsed = parseSopNotificationBody(_routeArgs?.msg ?? widget.title);
    if (parsed['categoryName']?.isNotEmpty == true) {
      currentCategoryName = parsed['categoryName']!;
    } else if (_routeArgs?.msg != null && _routeArgs!.msg!.isNotEmpty) {
      final parsedFromMsg = parseSopNotificationBody(_routeArgs!.msg);
      if (parsedFromMsg['categoryName']?.isNotEmpty == true) {
        currentCategoryName = parsedFromMsg['categoryName']!;
      }
    }

    if (currentCategoryName.isEmpty && towerId.isNotEmpty && categoryId.isNotEmpty) {
      try {
        var subHeadResp = await apiNetworkHandler.get("${AppUrl.baseURL}devsop/tower-sop-sub-heading?tower_id=$towerId");
        if (subHeadResp != null && (subHeadResp.statusCode == 200 || subHeadResp.statusCode == 201)) {
          final decoded = json.decode(subHeadResp.body);
          final List list = (decoded['data'] is List) ? decoded['data'] : [];
          for (var item in list) {
            if (item['id']?.toString() == categoryId || item['sub_heading_id']?.toString() == categoryId) {
              currentCategoryName = item['name']?.toString() ?? item['sub_heading_name']?.toString() ?? '';
              if (currentCategoryName.isNotEmpty) break;
            }
          }
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _resolvedProjectName = currentProjName;
        _resolvedTowerName = currentTowerName;
        if (currentCategoryName.isNotEmpty) {
          _resolvedCategoryName = currentCategoryName;
        }
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchSopDetails();
      _resolveProjectAndTowerNames();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final parsedMap = parseSopNotificationBody(_routeArgs?.msg ?? widget.title);

    String resolvedProjName = _resolvedProjectName ?? '';
    if (isInvalidProjName(resolvedProjName)) {
      resolvedProjName = (widget.projectName != null && !isInvalidProjName(widget.projectName))
          ? widget.projectName!
          : (_routeArgs?.projectName != null && !isInvalidProjName(_routeArgs?.projectName))
              ? _routeArgs!.projectName!
              : (parsedMap['projectName'] != null && !isInvalidProjName(parsedMap['projectName']))
                  ? parsedMap['projectName']!
                  : '';
    }

    String resolvedTowarName = _resolvedTowerName ?? '';
    if (isInvalidTowerName(resolvedTowarName)) {
      resolvedTowarName = (widget.towarName != null && !isInvalidTowerName(widget.towarName))
          ? widget.towarName!
          : (_routeArgs?.towarName != null && !isInvalidTowerName(_routeArgs?.towarName))
              ? _routeArgs!.towarName!
              : (_routeArgs?.projectLocation != null && !isInvalidTowerName(_routeArgs?.projectLocation))
                  ? _routeArgs!.projectLocation!
                  : (parsedMap['towerName'] != null && !isInvalidTowerName(parsedMap['towerName']))
                      ? parsedMap['towerName']!
                      : '';
    }

    String resolvedTitle = _resolvedCategoryName ?? widget.title ?? '';
    if (resolvedTitle.isEmpty ||
        resolvedTitle.toLowerCase().contains('submitted by') ||
        resolvedTitle.toLowerCase() == 'sop submitted' ||
        resolvedTitle.toLowerCase() == 'documents') {
      if (parsedMap['categoryName']?.isNotEmpty == true) {
        resolvedTitle = parsedMap['categoryName']!;
      } else if (_routeArgs?.msg != null && _routeArgs!.msg!.isNotEmpty) {
        final parsedFromMsg = parseSopNotificationBody(_routeArgs!.msg);
        if (parsedFromMsg['categoryName']?.isNotEmpty == true) {
          resolvedTitle = parsedFromMsg['categoryName']!;
        } else if (!_routeArgs!.msg!.toLowerCase().contains('submitted by') &&
                   !_routeArgs!.msg!.toLowerCase().contains('sop submitted')) {
          resolvedTitle = _routeArgs!.msg!;
        }
      }
    }

    String headerTitle = '';
    if (resolvedTowarName.isNotEmpty && resolvedProjName.isNotEmpty) {
      headerTitle = '${resolvedProjName.toUpperCase()} - ${resolvedTowarName.toUpperCase()}';
    } else if (resolvedProjName.isNotEmpty) {
      headerTitle = resolvedProjName.toUpperCase();
    } else if (resolvedTowarName.isNotEmpty) {
      headerTitle = resolvedTowarName.toUpperCase();
    } else {
      headerTitle = 'SOP DOCUMENTS';
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          headerTitle,
          style: const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: _isLoading
          ? CustomLoading.buildSopDocsSkeletonInline(context)
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                    child: Center(
                      child: Text(
                        resolvedTitle.isNotEmpty ? resolvedTitle : 'Documents',
                        style: TextStyle(
                          fontFamily: 'HelveticaNeue',
                          fontSize: isMobile ? 14 : 15,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const Divider(
                    height: 1.0,
                    color: Colors.black,
                  ),
                  for (int i = 0; i < sopListDetails!.length; i++)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 60, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: const Color(0xffe9ecef), width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.015),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: isMobile ? 75 : 130,
                                child: Text('Submitted By',
                                    style: TextStyle(
                                        fontFamily: 'HelveticaNeue',
                                        fontSize: isMobile ? 12 : 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87)),
                              ),
                              horizontalSpaceSmall,
                              Expanded(
                                child: Text(
                                  sopListDetails?[i].userName ?? '',
                                  style: TextStyle(
                                    fontFamily: 'HelveticaNeue',
                                    fontSize: isMobile ? 12 : 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: isMobile ? 75 : 130,
                                child: Text('File Name',
                                    style: TextStyle(
                                        fontFamily: 'HelveticaNeue',
                                        fontSize: isMobile ? 12 : 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87)),
                              ),
                              horizontalSpaceSmall,
                              Expanded(
                                child: Text(
                                  sopListDetails?[i].sopFileName ?? '',
                                  style: TextStyle(
                                    fontFamily: 'HelveticaNeue',
                                    fontSize: isMobile ? 12 : 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: isMobile ? 75 : 130,
                                child: Text('Date',
                                    style: TextStyle(
                                        fontFamily: 'HelveticaNeue',
                                        fontSize: isMobile ? 12 : 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87)),
                              ),
                              horizontalSpaceSmall,
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      sopListDetails?[i].createdAt ?? '',
                                      style: TextStyle(
                                        fontFamily: 'HelveticaNeue',
                                        fontSize: isMobile ? 12 : 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) {
                                              return PdfViewer(
                                                fileName: sopListDetails?[i].sopFileName,
                                                fileUrl: testWithMockData
                                                    ? "dummy.pdf"
                                                    : sopListDetails?[i].filePath,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 6),
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Colors.black54),
                                            borderRadius: BorderRadius.circular(8)),
                                        child: Text(
                                          "View",
                                          style: TextStyle(
                                            fontFamily: 'HelveticaNeue',
                                            fontSize: isMobile ? 11 : 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
