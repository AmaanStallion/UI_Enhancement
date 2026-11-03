import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_project_account_management.dart';
import 'package:stallion/models/get_project_wo_request.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/models/notification_filter.dart';
import 'package:stallion/models/notification_response.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/accountmanagement/accountmanagement.dart';
import 'package:stallion/ui/views/accountmanagement/worequested.dart';
import 'package:stallion/ui/views/mycontracts/mycontractdetailview.dart';
import 'package:stallion/ui/views/permission/permissions.dart';
import 'package:stallion/ui/views/rccstructure/dpr/daily_progress_report.dart';
import 'package:stallion/ui/views/salesmanagement/salesmainview.dart';
import 'package:stallion/ui/views/task_manager/task_details.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:stallion/ui/views/sopModule/sop_docs.dart';
import 'package:stallion/websocket/socket_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    this.userType,
    this.onBack,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? userType;
  final String? towarName;
  final VoidCallback? onBack;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NetworkHandler apiNetworkHandler = NetworkHandler();
  TextEditingController searchController = TextEditingController();
  String searchText = '';
  List<NotificationFillter>? filterListData = [];
  List<NotificationFillter>? leftDrawerData = [];
  List<NotificationFillter>? rightDrawerData = [];
  List<NotificationFillter>? filterDataSend = [];
  bool isFilterSelected = false;
  bool _isLoading = true;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isFetchingMore = false;
  int _autoFetchCount = 0;

  String searchTermValue = '';
  List<WoOrderList>? woOrderList = [];
  int filterListSelected = 0;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<NotificationList>? notificationListResponse = [];

  List<NotificationFillter> projectFilterList = [];
  List<NotificationFillter> towerFilterList = [];
  List<NotificationFillter> moduleFilterList = [];
  List<NotificationFillter> subModuleFilterList = [];

  /// List of modules that are project-specific (not tower-specific).
  /// Expand this list as new project-level modules are added.
  List<String> projectSpecificModules = [
    'legal',
    'permission',
  ];

  void _rebuildFilterCategories() {
    leftDrawerData = [];

    // 1. Projects
    leftDrawerData!.add(NotificationFillter(
      id: "0",
      name: "Projects",
      details: projectFilterList,
      type: "project",
      ct: projectFilterList.where((e) => e.isSelected == true && e.name != "All").length,
    ));

    // 2. Towers
    leftDrawerData!.add(NotificationFillter(
      id: "1",
      name: "Towers",
      details: towerFilterList,
      type: "tower",
      ct: towerFilterList.where((e) => e.isSelected == true && e.name != "All").length,
    ));

    // 3. Modules
    leftDrawerData!.add(NotificationFillter(
      id: "2",
      name: "Modules",
      details: moduleFilterList,
      type: "module",
      ct: moduleFilterList.where((e) => e.isSelected == true && e.name != "All").length,
    ));

    // 4. Sub Modules (dynamically shown if available)
    if (subModuleFilterList.isNotEmpty) {
      leftDrawerData!.add(NotificationFillter(
        id: "3",
        name: "Sub Modules",
        details: subModuleFilterList,
        type: "sub_module",
        ct: subModuleFilterList.where((e) => e.isSelected == true && e.name != "All").length,
      ));
    } else {
      if (filterListSelected >= 3) {
        filterListSelected = 0;
      }
    }

    if (leftDrawerData!.isNotEmpty) {
      if (filterListSelected < leftDrawerData!.length) {
        rightDrawerData = leftDrawerData![filterListSelected].details;
      } else {
        filterListSelected = 0;
        rightDrawerData = leftDrawerData![0].details;
      }
    }
  }

  Future<void> _updateDynamicTowers() async {
    List<String> selectedProjIds = projectFilterList
        .where((p) => p.isSelected == true && p.id != null && p.id!.isNotEmpty && p.name != "All")
        .map((p) => p.id!)
        .toList();

    List<NotificationFillter> newTowers = [
      NotificationFillter(id: "", name: "All", isSelected: false, ct: 0, details: []),
    ];

    List<String> targetProjIds = selectedProjIds.isNotEmpty
        ? selectedProjIds
        : projectFilterList
            .where((p) => p.id != null && p.id!.isNotEmpty && p.name != "All")
            .map((p) => p.id!)
            .toList();

    for (var projId in targetProjIds) {
      try {
        var towerResp = await apiNetworkHandler.get("${AppUrl.baseURL}towers?project_id=$projId");
        if (towerResp != null && (towerResp.statusCode == 200 || towerResp.statusCode == 201)) {
          final decoded = json.decode(towerResp.body);
          if (decoded['success'] == true && decoded['data'] is List) {
            for (var t in decoded['data']) {
              final tId = t['id']?.toString() ?? "";
              final tName = t['name']?.toString() ?? "";
              if (tName.isNotEmpty && !newTowers.any((existing) => existing.id == tId)) {
                bool wasSelected = towerFilterList.any((oldT) => oldT.id == tId && oldT.isSelected == true);
                newTowers.add(NotificationFillter(
                  id: tId,
                  name: tName,
                  isSelected: wasSelected,
                  ct: 0,
                  details: [],
                ));
              }
            }
          }
        }
      } catch (_) {}
    }

    towerFilterList = newTowers;
  }

  void _updateDynamicSubModules() {
    List<NotificationFillter> selectedModuleObjects = moduleFilterList
        .where((m) => m.isSelected == true && m.name != "All")
        .toList();

    List<NotificationFillter> targetModuleObjects = selectedModuleObjects.isNotEmpty
        ? selectedModuleObjects
        : moduleFilterList.where((m) => m.name != "All").toList();

    List<NotificationFillter> newSubModules = [];

    for (var mod in targetModuleObjects) {
      if (mod.details != null && mod.details!.isNotEmpty) {
        for (var sub in mod.details!) {
          if (sub.name != null && sub.name!.isNotEmpty && !newSubModules.any((item) => item.id == sub.id && item.name == sub.name)) {
            bool wasSelected = subModuleFilterList.any((oldSub) => oldSub.id == sub.id && oldSub.isSelected == true);
            newSubModules.add(NotificationFillter(
              id: sub.id,
              name: sub.name,
              isSelected: wasSelected,
              ct: 0,
              details: [],
            ));
          }
        }
      }
    }

    if (newSubModules.isNotEmpty) {
      newSubModules.insert(0, NotificationFillter(id: "", name: "All", isSelected: false, ct: 0, details: []));
    }

    subModuleFilterList = newSubModules;
  }
  Future<ResponseGetProjectAccountManagement?> fetchNotifications({
    List<NotificationFillter>? dataa,
    bool isLoadMore = false,
  }) async {
    if (isLoadMore) {
      if (_isFetchingMore || !_hasNextPage) return null;
      _isFetchingMore = true;
    } else {
      _currentPage = 1;
      _hasNextPage = true;
    }

    try {
      final int limit = (mounted && context.isMobile) ? 10 : 15;
      final url = "${AppUrl.baseURL}notifications?page=$_currentPage&limit=$limit";
      var response = await apiNetworkHandler.getWithMasterToken(url);
      if (kDebugMode) {
        print("=================== NOTIFICATIONS API RAW RESPONSE ===================");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("=======================================================================");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final dataObj = decoded['data'];
          List listData = [];

          if (dataObj is Map<String, dynamic>) {
            if (dataObj['notifications'] is List) {
              listData = dataObj['notifications'];
            }
            if (dataObj['meta'] is Map<String, dynamic>) {
              final meta = dataObj['meta'];
              _hasNextPage = meta['has_next_page'] ?? false;
            }
          } else if (dataObj is List) {
            listData = dataObj;
          }

          List<NotificationList> mappedList = listData.map((item) {
            var rawResp = item['response'];
            ResponseClass? respObj;
            if (rawResp != null) {
              if (rawResp is String) {
                try {
                  respObj = ResponseClass.fromJson(json.decode(rawResp));
                } catch (_) {}
              } else if (rawResp is Map<String, dynamic>) {
                respObj = ResponseClass.fromJson(rawResp);
              }
            }

            // Fallback: If response is null but reference_id is present, populate ResponseClass fields
            if (respObj == null && item['reference_id'] != null) {
              final refId = item['reference_id']?.toString();
              respObj = ResponseClass(
                projectId: refId,
                permissionId: refId,
                slabId: refId,
                towarId: refId,
                woOrderId: refId,
                woOrderNo: refId,
              );
            }

            String loc = item['project_location'] ?? item['location'] ?? item['tower_name'] ?? item['tower'] ?? item['building_name'] ?? "";
            if (loc.isEmpty && respObj != null) {
              loc = respObj.towarId ?? "";
            }

            return NotificationList(
              mstNotificationId: item['id']?.toString() ?? item['mst_notification_id']?.toString() ?? "",
              msg: item['body'] ?? item['msg'] ?? item['message'] ?? "",
              notificationType: item['type'] ?? item['notification_type'] ?? "",
              projectName: (item['project_name'] != null && item['project_name'].toString().isNotEmpty)
                  ? item['project_name'].toString()
                  : "",
              projectLocation: loc,
              projectId: (item['project_id'] != null && item['project_id'].toString().isNotEmpty)
                  ? item['project_id'].toString()
                  : (item['reference_id']?.toString() ?? ""),
              showStatus: item['show_status']?.toString() ?? "",
              createdAt: item['created_at'] != null ? DateTime.tryParse(item['created_at']) : null,
              response: respObj,
            );
          }).toList();

          // Local filtering logic based on selected projects, towers, modules, and sub_modules
          if (dataa != null && dataa.isNotEmpty) {
            List<String> selectedProjectNames = [];
            List<String> selectedTowerNames = [];
            List<String> selectedModuleIds = [];
            List<String> selectedModuleNames = [];
            List<String> selectedSubModules = [];

            for (var filter in dataa) {
              if (filter.type == "project" && filter.details != null) {
                for (var detail in filter.details!) {
                  if (detail.name != null && detail.name!.isNotEmpty && detail.name!.toLowerCase() != "all") {
                    selectedProjectNames.add(detail.name!.toLowerCase());
                  }
                }
              } else if (filter.type == "tower" && filter.details != null) {
                for (var detail in filter.details!) {
                  if (detail.name != null && detail.name!.isNotEmpty && detail.name!.toLowerCase() != "all") {
                    selectedTowerNames.add(detail.name!.toLowerCase());
                  }
                }
              } else if (filter.type == "module" && filter.details != null) {
                for (var detail in filter.details!) {
                  if (detail.name != null && detail.name!.isNotEmpty && detail.name!.toLowerCase() != "all") {
                    if (detail.id != null && detail.id!.isNotEmpty) {
                      selectedModuleIds.add(detail.id!.toLowerCase());
                    }
                    selectedModuleNames.add(detail.name!.toLowerCase());
                  }
                }
              } else if (filter.type == "sub_module" && filter.details != null) {
                for (var detail in filter.details!) {
                  if (detail.name != null && detail.name!.isNotEmpty && detail.name!.toLowerCase() != "all") {
                    if (detail.id != null && detail.id!.isNotEmpty) {
                      selectedSubModules.add(detail.id!.toLowerCase());
                    }
                    selectedSubModules.add(detail.name!.toLowerCase());
                  }
                }
              }
            }

            if (selectedProjectNames.isNotEmpty) {
              mappedList = mappedList.where((notification) {
                final projName = notification.projectName?.toLowerCase() ?? '';
                final msgText = notification.msg?.toLowerCase() ?? '';
                if (projName.isNotEmpty && selectedProjectNames.any((name) => projName.contains(name) || name.contains(projName))) {
                  return true;
                }
                if (selectedProjectNames.any((name) => msgText.contains(name))) {
                  return true;
                }
                return false;
              }).toList();
            }

            if (selectedTowerNames.isNotEmpty) {
              mappedList = mappedList.where((notification) {
                final type = notification.notificationType?.toLowerCase() ?? '';
                final msgText = notification.msg?.toLowerCase() ?? '';
                final locText = notification.projectLocation?.toLowerCase() ?? '';
                final respTower = notification.response?.towarId?.toLowerCase() ?? '';

                // Check if notification belongs to a project-specific module (e.g. legal, permission)
                bool isProjectSpecificNotification = projectSpecificModules.any((modKey) {
                  final key = modKey.toLowerCase();
                  return type.contains(key) || msgText.contains(key);
                });

                // Check if any of the selected modules are project-specific
                bool isSelectedModuleProjectSpecific = selectedModuleNames.any((modName) {
                  final n = modName.toLowerCase();
                  return projectSpecificModules.any((key) => n.contains(key.toLowerCase()));
                });

                if (isProjectSpecificNotification || isSelectedModuleProjectSpecific) {
                  // Project-level modules bypass tower filtering completely
                  return true;
                }

                final hasTowerInfo = locText.isNotEmpty || respTower.isNotEmpty;

                if (hasTowerInfo) {
                  return selectedTowerNames.any((tName) =>
                      msgText.contains(tName) || locText.contains(tName) || respTower.contains(tName));
                }

                // If notification has no explicit tower attached (project-level notification), keep it
                return true;
              }).toList();
            }

            if (selectedModuleNames.isNotEmpty || selectedModuleIds.isNotEmpty) {
              mappedList = mappedList.where((notification) {
                final type = notification.notificationType?.toLowerCase() ?? '';
                final msg = notification.msg?.toLowerCase() ?? '';

                for (var id in selectedModuleIds) {
                  if (id.isNotEmpty && (type.contains(id) || msg.contains(id))) {
                    return true;
                  }
                }

                for (var name in selectedModuleNames) {
                  if (type.contains(name) || msg.contains(name)) {
                    return true;
                  }

                  // Handle specific module aliases & keywords
                  if (name.contains("permission")) {
                    if (type.contains("permission") || type.contains("permisson") || type == "file_uploaded" || msg.contains("permission")) {
                      return true;
                    }
                  } else if (name.contains("work order") || name.contains("contract") || name.contains("wo") || name.contains("po")) {
                    if (type.contains("wo") || type.contains("work_order") || msg.contains("work order") || msg.contains("po") || msg.contains("contract")) {
                      return true;
                    }
                  } else if (name.contains("dpr") || name.contains("daily progress") || name.contains("progress")) {
                    if (type.contains("dpr") || type == "generatedpr" || msg.contains("dpr") || msg.contains("daily progress")) {
                      return true;
                    }
                  } else if (name.contains("task")) {
                    if (type.contains("task") || msg.contains("task")) {
                      return true;
                    }
                  } else if (name.contains("legal")) {
                    if (type.contains("legal") || msg.contains("legal")) {
                      return true;
                    }
                  }

                  // Match core non-generic words (e.g. "legal", "permission", "tower", "tenant")
                  final words = name.split(RegExp(r'\s+')).where((w) => w.length > 3 && w != "management").toList();
                  for (var word in words) {
                    final cleanWord = word.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
                    if (cleanWord.length > 3) {
                      if (type.contains(cleanWord) || msg.contains(cleanWord)) {
                        return true;
                      }
                      String singular = cleanWord.endsWith('s') ? cleanWord.substring(0, cleanWord.length - 1) : cleanWord;
                      if (singular.length > 3 && (type.contains(singular) || msg.contains(singular))) {
                        return true;
                      }
                    }
                  }
                }

                return false;
              }).toList();
            }

            if (selectedSubModules.isNotEmpty) {
              mappedList = mappedList.where((notification) {
                final type = notification.notificationType?.toLowerCase() ?? '';
                final msg = notification.msg?.toLowerCase() ?? '';
                for (var sub in selectedSubModules) {
                  if (sub.isNotEmpty && (type.contains(sub) || msg.contains(sub))) {
                    return true;
                  }
                  final words = sub.split(RegExp(r'\s+')).where((w) => w.length > 2).toList();
                  for (var w in words) {
                    if (w.isNotEmpty && (type.contains(w) || msg.contains(w))) {
                      return true;
                    }
                  }
                }
                return false;
              }).toList();
            }
          }

          if (mounted) {
            setState(() {
              if (isLoadMore) {
                notificationListResponse = [
                  ...?notificationListResponse,
                  ...mappedList,
                ];
              } else {
                notificationListResponse = mappedList;
              }
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching notifications: $e");
      }
    } finally {
      _isFetchingMore = false;
      if (mounted) {
        setState(() { _isLoading = false; });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkAutoFill();
        });
      }
    }
    return null;
  }

  void _checkAutoFill() {
    if (mounted && _hasNextPage && !_isFetchingMore && !_isLoading && _autoFetchCount < 2) {
      if (_scrollController.hasClients) {
        if (_scrollController.position.maxScrollExtent <= 100) {
          _autoFetchCount++;
          _onLoading();
        }
      }
    }
  }

  Future<ResponseGetProjectAccountManagement?> getNotificationFillter() async {
    try {
      var response = await apiNetworkHandler.getWithMasterToken(AppUrl.getMobileProjectList);
      List<NotificationFillter> projectDetailsList = [
        NotificationFillter(id: "", name: "All", isSelected: false, ct: 0, details: []),
      ];

      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final data = decoded['data'];
          final list = (data is Map ? data['projects'] : data) as List? ?? [];
          for (var item in list) {
            projectDetailsList.add(NotificationFillter(
              id: item['id']?.toString() ?? "",
              name: item['name'] ?? "",
              isSelected: false,
              ct: 0,
              details: [],
            ));
          }
        }
      }
      projectFilterList = projectDetailsList;

      // Fetch towers initially for projects
      await _updateDynamicTowers();

      // Fetch assigned modules and submodules from API
      try {
        var modulesResp = await apiNetworkHandler.get("${AppUrl.baseURL}modules/assignable");
        if (modulesResp == null || (modulesResp.statusCode != 200 && modulesResp.statusCode != 201)) {
          modulesResp = await apiNetworkHandler.get("${AppUrl.baseURL}modules");
        }
        if (modulesResp != null && (modulesResp.statusCode == 200 || modulesResp.statusCode == 201)) {
          final decoded = json.decode(modulesResp.body);
          final List list = (decoded is Map && decoded['data'] is List)
              ? decoded['data']
              : (decoded is List ? decoded : []);
          
          if (list.isNotEmpty) {
            List<NotificationFillter> fetchedModules = [
              NotificationFillter(id: "", name: "All", isSelected: false, ct: 0, details: []),
            ];
            for (var m in list) {
              final mId = m['id']?.toString() ?? m['code']?.toString() ?? "";
              final mName = m['name']?.toString() ?? "";
              
              List<NotificationFillter> subMods = [];
              var rawSubs = m['sub_modules'] ?? m['submodules'] ?? m['details'] ?? m['children'];
              if (rawSubs is List) {
                for (var sub in rawSubs) {
                  subMods.add(NotificationFillter(
                    id: sub['id']?.toString() ?? sub['code']?.toString() ?? "",
                    name: sub['name']?.toString() ?? "",
                    isSelected: false,
                    ct: 0,
                    details: [],
                  ));
                }
              }

              fetchedModules.add(NotificationFillter(
                id: mId,
                name: mName,
                isSelected: false,
                ct: 0,
                details: subMods,
              ));
            }
            moduleFilterList = fetchedModules;
          }
        }
      } catch (_) {}

      if (moduleFilterList.isEmpty) {
        moduleFilterList = [
          NotificationFillter(id: "", name: "All", isSelected: false, ct: 0, details: []),
          NotificationFillter(id: "permission", name: "Permissions", isSelected: false, ct: 0, details: []),
          NotificationFillter(id: "wo", name: "Work Orders / Contracts", isSelected: false, ct: 0, details: []),
          NotificationFillter(id: "dpr", name: "Daily Progress (DPR)", isSelected: false, ct: 0, details: []),
          NotificationFillter(id: "task", name: "Task Manager", isSelected: false, ct: 0, details: []),
        ];
      }

      // Setup Sub Modules
      _updateDynamicSubModules();

      if (mounted) {
        setState(() {
          _rebuildFilterCategories();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting notification filters: $e");
      }
    }
    return null;
  }

  List<NotificationFillter> filterSelectedItems(
      List<NotificationFillter>? items) {
    if (items == null) {
      return [];
    }

    return items
        .where(
            (item) => item.isSelected == true) // Filter for isSelected == true
        .map((item) => NotificationFillter(
              type: item.type,
              id: item.id,
              name: item.name,
              isSelected: item.isSelected,
              details: filterSelectedItems(
                  item.details), // Recursively filter nested details
            ))
        .toList(); // Convert back to a list
  }

  void _onRefresh() async {
    _currentPage = 1;
    _hasNextPage = true;
    _autoFetchCount = 0;
    _refreshController.resetNoData();
    await fetchNotifications(dataa: filterDataSend, isLoadMore: false);
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    if (_hasNextPage) {
      _currentPage++;
      await fetchNotifications(dataa: filterDataSend, isLoadMore: true);
      _refreshController.loadComplete();
    } else {
      _refreshController.loadNoData();
    }
  }

  void _onScrollListener() {
    if (_scrollController.hasClients) {
      final maxExtent = _scrollController.position.maxScrollExtent;
      final currentPixels = _scrollController.position.pixels;
      if (currentPixels >= maxExtent - 250) {
        if (_hasNextPage && !_isFetchingMore && !_isLoading) {
          _onLoading();
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollListener);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _currentPage = 1;
      _hasNextPage = true;
      _autoFetchCount = 0;
      notificationListResponse = [];
      if (mounted) {
        setState(() { _isLoading = true; });
      }
      fetchNotifications(dataa: filterDataSend, isLoadMore: false);
      getNotificationFillter();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildNotificationSkeletonLoader() {
    final bool isMobile = context.isMobile;
    return CustomLoading.wrapWithHorseLoader(
      Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        period: const Duration(milliseconds: 1500),
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 8,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 16.0 : 40.0,
                vertical: 6.0,
              ),
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: const Color(0xfff0f0f0), width: 1.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circular icon placeholder
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Middle text section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title placeholder — wider, thicker
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.6,
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Description placeholder — full width, narrower
                        Container(
                          width: double.infinity,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Timestamp placeholder — small, right-aligned
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            width: 80,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;

    IconData _getIconForType(String? type) {
      if (type == null) return Icons.notifications_active_outlined;
      final t = type.toLowerCase();
      if (t.contains('permission')) {
        return Icons.assignment_turned_in_outlined;
      }
      if (t.contains('wo') || t.contains('work_order') || t.contains('order')) {
        return Icons.construction_outlined;
      }
      if (t.contains('meeting') || t.contains('sop')) {
        return Icons.groups_outlined;
      }
      if (t.contains('tenant')) {
        return Icons.real_estate_agent_outlined;
      }
      if (t.contains('budget')) {
        return Icons.account_balance_wallet_outlined;
      }
      return Icons.notifications_active_outlined;
    }

    String calDateTime({required DateTime dateTime}) {
      // DateTime dateTime = DateTime.parse(dateTimeString);

      DateTime currentTime = DateTime.now();
      Duration difference = currentTime.difference(dateTime);
      if (difference.inHours < 24) {
        if (difference.inHours < 1) {
          if (difference.inMinutes < 1) {
            return 'Less than 1 minute ago';
          } else {
            int minutesAgo = difference.inMinutes;
            return '$minutesAgo minutes ago';
          }
        } else {
          int hoursAgo = difference.inHours;
          return '$hoursAgo hours ago';
        }
      } else {
        int daysAgo = difference.inDays;
        return '$daysAgo days ago';
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xfff0f0f0),
            height: 1.0,
          ),
        ),
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.0),
                onPressed: widget.onBack,
              )
            : null,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'HelveticaNeue',
            fontWeight: FontWeight.w700,
            fontSize: 18.0,
            color: Colors.white,
          ),
        ),
        actions: [
          // if (widget.flagRedirect! != 'Verified' &&
          //     widget.flagRedirect! != 'Assigned')
          // if (widget.flagRedirect! != 'Verified')
          InkWell(
            onTap: () async {
              searchController.clear();
              
              if (leftDrawerData == null || leftDrawerData!.isEmpty) {
                CustomLoading.progressDialog(isLoading: true, context: context, skeletonType: CustomLoading.skeletonPermissionList);
                await getNotificationFillter();
                CustomLoading.progressDialog(isLoading: false, context: context);
              }
              
              setState(() {
                searchText = '';
                filterListSelected = 0;
                if (leftDrawerData != null && leftDrawerData!.isNotEmpty) {
                  rightDrawerData = leftDrawerData![0].details;
                }
              });
              
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState1) {
                        final double screenWidth = MediaQuery.of(context).size.width;
                        final bool isMobileScreen = context.isMobile;
                        final double dialogWidth = isMobileScreen ? screenWidth * 0.95 : screenWidth * 0.6;
                        final double leftColumnWidth = isMobileScreen ? screenWidth * 0.32 : screenWidth * 0.2;
                        final double buttonWidth = isMobileScreen ? screenWidth * 0.475 : screenWidth * 0.3;
                        return AlertDialog(
                            insetPadding: EdgeInsets.symmetric(
                              horizontal: isMobileScreen ? 12.0 : 40.0,
                              vertical: 24.0,
                            ),
                            elevation: 0,
                            shadowColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8), // Set radius to zero
                            ),
                            titlePadding:
                                const EdgeInsets.symmetric(vertical: 0),
                            actionsPadding: const EdgeInsets.only(bottom: 0),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 0),
                            actionsAlignment: MainAxisAlignment.center,
                            title: Container(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8))),
                              child: const Text(
                                "FILTER",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            actions: <Widget>[
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        if (AppUrl.useNewBackend) {
                                          setState1(() {
                                            for (var list in [projectFilterList, towerFilterList, moduleFilterList, subModuleFilterList]) {
                                              for (var item in list) {
                                                item.isSelected = false;
                                                item.ct = 0;
                                              }
                                            }
                                            _updateDynamicSubModules();
                                            filterListSelected = 0;
                                            _rebuildFilterCategories();
                                          });
                                          setState(() {
                                            isFilterSelected = false;
                                          });
                                        } else {
                                          setState1(() {
                                            if (filterListData != null && filterListData!.isNotEmpty) {
                                              leftDrawerData = [];
                                              NotificationFillter temp =
                                                  NotificationFillter(
                                                      id: "0",
                                                      name: "Projects",
                                                      details: filterListData,
                                                      type: '',
                                                      ct: 0);
                                              leftDrawerData?.add(temp);
                                              
                                              if (filterListData![0].details != null) {
                                                List<NotificationFillter>? temp2 =
                                                    filterListData![0].details;
                                                for (int i = 0; i < temp2!.length; i++) {
                                                  leftDrawerData?.add(temp2[i]);
                                                }
                                              }

                                              rightDrawerData = filterListData;

                                              for (int h = 0;
                                                  h < leftDrawerData!.length;
                                                  h++) {
                                                leftDrawerData![h].ct = 0;
                                                if (leftDrawerData![h].details != null) {
                                                  for (int y = 0;
                                                      y <
                                                          leftDrawerData![h]
                                                              .details!
                                                              .length;
                                                      y++) {
                                                    leftDrawerData![h]
                                                        .details?[y]
                                                        .isSelected = false;
                                                  }
                                                }
                                              }
                                            }
                                          });

                                          setState(() {
                                            isFilterSelected = false;
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        decoration: const BoxDecoration(
                                            color: Colors.black,
                                            border: Border(
                                                right: BorderSide(
                                                    color: Colors.white)),
                                            borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(8))),
                                        child: const Text(
                                          "RESET",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        // Navigator.of(context).pop();

                                        List<NotificationFillter>? temp = [];

                                        for (int i = 0;
                                            i < leftDrawerData!.length;
                                            i++) {
                                          final selectedItems =
                                              filterSelectedItems(
                                                  leftDrawerData?[i].details);

                                          if (selectedItems.isNotEmpty) {
                                            temp.add(
                                              NotificationFillter(
                                                id: leftDrawerData?[i].id,
                                                name: leftDrawerData?[i].name,
                                                details: selectedItems,
                                                type: leftDrawerData?[i].type,
                                              ),
                                            );
                                          }
                                        }
                                        filterDataSend = temp;
                                        if (temp.isNotEmpty) {
                                          isFilterSelected = true;
                                        }
                                        _currentPage = 1;
                                        _hasNextPage = true;
                                        _autoFetchCount = 0;
                                        _refreshController.resetNoData();
                                        notificationListResponse = [];
                                        fetchNotifications(dataa: temp, isLoadMore: false)
                                            .then((value) => {
                                                  Navigator.of(context).pop(),
                                                });
                                      },
                                      // onTap: () {},
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        decoration: const BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.only(
                                                bottomRight: Radius.circular(8))),
                                        child: const Text(
                                          "APPLY FILTER",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                            content: StatefulBuilder(builder:
                                (BuildContext context1, StateSetter setState) {
                              final double contentHeight = MediaQuery.of(context).size.height * 0.6;
                              
                              // Build the left column inner content (shared between desktop & mobile)
                              final Widget leftColumnChild = SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (int i = 0; i < leftDrawerData!.length; i++)
                                      InkWell(
                                        onTap: () {
                                          rightDrawerData = leftDrawerData?[i].details;
                                          setState1(() {
                                            filterListSelected = i;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: i == filterListSelected
                                                ? Colors.white
                                                : Colors.transparent,
                                          ),
                                          padding: EdgeInsets.only(
                                            top: 14,
                                            bottom: 14,
                                            left: isMobileScreen ? 8 : 40,
                                          ),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  '${leftDrawerData?[i].name}',
                                                  style: TextStyle(
                                                    fontSize: isMobileScreen ? 13 : 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (leftDrawerData?[i].ct != 0)
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 7.0),
                                                  child: Container(
                                                    height: 5,
                                                    width: 5,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(100),
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                )
                                            ],
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              );

                              // Build the right column inner content (shared between desktop & mobile)
                              final Widget rightColumnChild = Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          for (int k = 0; k < (rightDrawerData?.length ?? 0); k++)
                                            InkWell(
                                              onTap: () async {
                                                if (rightDrawerData?[k].isSelected == true) {
                                                  rightDrawerData?[k].isSelected = false;
                                                } else {
                                                  rightDrawerData?[k].isSelected = true;
                                                  if (k == 0) {
                                                    for (int y = 1; y < rightDrawerData!.length; y++) {
                                                      rightDrawerData?[y].isSelected = false;
                                                    }
                                                  } else {
                                                    rightDrawerData?[0].isSelected = false;
                                                  }
                                                }
                                                if (AppUrl.useNewBackend) {
                                                  final activeType = (leftDrawerData != null && filterListSelected < leftDrawerData!.length)
                                                      ? leftDrawerData![filterListSelected].type
                                                      : null;
                                                  if (activeType == "project") {
                                                    await _updateDynamicTowers();
                                                  } else if (activeType == "module") {
                                                    _updateDynamicSubModules();
                                                  }
                                                  setState1(() {
                                                    _rebuildFilterCategories();
                                                  });
                                                } else {
                                                  if (filterListSelected == 0 && leftDrawerData != null && leftDrawerData!.isNotEmpty) {
                                                    leftDrawerData = [leftDrawerData![0]];
                                                  }
                                                  if (leftDrawerData != null && filterListSelected < leftDrawerData!.length) {
                                                    leftDrawerData?[filterListSelected].ct = 0;
                                                    for (int t = 0; t < rightDrawerData!.length; t++) {
                                                      if (rightDrawerData?[t].isSelected == true) {
                                                        leftDrawerData?[filterListSelected].ct++;
                                                      }
                                                    }
                                                  }
                                                  setState1(() {});
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: isMobileScreen ? 8 : 40,
                                                  vertical: 5,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(rightDrawerData?[k].isSelected == true
                                                        ? Icons.check_box_rounded
                                                        : Icons.check_box_outline_blank_outlined),
                                                    const SizedBox(width: 10),
                                                    Flexible(
                                                      child: Text(
                                                        rightDrawerData?[k].name ?? '',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );

                              // Desktop: original fixed-width layout
                              // Mobile: Expanded flex layout
                              return SizedBox(
                                height: contentHeight,
                                width: isMobileScreen ? null : MediaQuery.of(context).size.width * 0.6,
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: isMobileScreen
                                          ? [
                                              Expanded(
                                                flex: 35,
                                                child: Container(
                                                  height: contentHeight,
                                                  color: Colors.grey.shade300,
                                                  child: leftColumnChild,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 65,
                                                child: SizedBox(
                                                  height: contentHeight,
                                                  child: rightColumnChild,
                                                ),
                                              ),
                                            ]
                                          : [
                                              Container(
                                                height: contentHeight,
                                                width: MediaQuery.of(context1).size.width * 0.2,
                                                color: Colors.grey.shade300,
                                                child: leftColumnChild,
                                              ),
                                              SizedBox(
                                                height: contentHeight,
                                                width: MediaQuery.of(context1).size.width * 0.4,
                                                child: rightColumnChild,
                                              ),
                                            ],
                                    )
                                  ],
                                ),
                              );
                            }));
                      },
                    );
                  });
            },
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.all(4),
              child: isFilterSelected == true
                  ? Image.asset(
                      'images/projectmanagement/filter-sort-icon.png',
                      height: 20,
                      color: Colors.white,
                    )
                  : Image.asset(
                      'images/projectmanagement/filter_black.png',
                      height: 20,
                      color: Colors.white,
                    ),
            ),
          ),

          const SizedBox(width: 40)
        ],
      ),
      body: _isLoading
          ? _buildNotificationSkeletonLoader()
          : notificationListResponse!.isNotEmpty
              ? SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: true,
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  footer: const ClassicFooter(loadStyle: LoadStyle.ShowWhenLoading),
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: (notificationListResponse?.length ?? 0) + (_isFetchingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == notificationListResponse!.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          ),
                        );
                      }
                      NotificationList tempp =
                          notificationListResponse![index];

                            return InkWell(
                              onTap: () async {
                                String? targetProjectId = tempp.projectId ?? tempp.response?.projectId;
                                if (targetProjectId != null && targetProjectId.isNotEmpty) {
                                  try {
                                    var response = await apiNetworkHandler.postWithMasterToken(
                                      AppUrl.switchByProject,
                                      {"project_id": targetProjectId},
                                    );
                                    if (response.statusCode == 200 || response.statusCode == 201) {
                                      final decodedSwitch = json.decode(response.body);
                                      final String? newToken = decodedSwitch['data']?['token']?.toString();
                                      if (newToken != null && newToken.isNotEmpty) {
                                        final prefs = await _prefs;
                                        await prefs.setString('projectToken', newToken);
                                      }
                                    }
                                  } catch (_) {}
                                }

                                  if (tempp.notificationType == 'sop_submitted' ||
                                      tempp.notificationType == 'sop-submitted' ||
                                      tempp.notificationType == 'sop_submit' ||
                                      tempp.notificationType == 'sop_docs' ||
                                      tempp.notificationType == 'ws-sop-submitted') {
                                    String projId = tempp.projectId ?? tempp.response?.projectId ?? widget.projectId ?? '';
                                    String towerId = tempp.response?.towarId ?? tempp.towarIdFk ?? widget.towarId ?? '';
                                    String categoryId = tempp.response?.categoryId ?? tempp.categoryId ?? '';

                                    final parsedBody = parseSopNotificationBody(tempp.msg);
                                    String resolvedProjName = (tempp.projectName != null && !isInvalidProjName(tempp.projectName))
                                        ? tempp.projectName!
                                        : (parsedBody['projectName'] != null && !isInvalidProjName(parsedBody['projectName']))
                                            ? parsedBody['projectName']!
                                            : (widget.projectName != null && !isInvalidProjName(widget.projectName))
                                                ? widget.projectName!
                                                : '';

                                    String resolvedTowarName = (tempp.projectLocation != null && !isInvalidTowerName(tempp.projectLocation))
                                        ? tempp.projectLocation!
                                        : (parsedBody['towerName'] != null && !isInvalidTowerName(parsedBody['towerName']))
                                            ? parsedBody['towerName']!
                                            : (widget.towarName != null && !isInvalidTowerName(widget.towarName))
                                                ? widget.towarName!
                                                : '';

                                    String resolvedCategoryTitle = parsedBody['categoryName']?.isNotEmpty == true
                                        ? parsedBody['categoryName']!
                                        : tempp.msg ?? '';

                                    if (projId.isNotEmpty) {
                                      await apiNetworkHandler.ensureProjectContext(projId);
                                    }
                                    if (!mounted) return;
                                    Navigator.of(context).pushNamed(
                                      '/sopDocsScreen',
                                      arguments: NotificationArgs(
                                        msg: resolvedCategoryTitle,
                                        projectId: projId,
                                        projectName: resolvedProjName,
                                        towarName: resolvedTowarName,
                                        response: NotificationResponseData(
                                          projectId: projId,
                                          towarId: towerId,
                                          categoryId: categoryId,
                                        ),
                                      ),
                                    );
                                  } else if (tempp.notificationType == 'task_assigned' ||
                                             tempp.notificationType == 'meeting_task_assigned' ||
                                             tempp.notificationType == 'meeting-task-assigned' ||
                                             tempp.notificationType == 'meeting_task_assign' ||
                                             tempp.notificationType == 'meeting_task') {
                                   String projId = tempp.projectId ?? tempp.response?.projectId ?? widget.projectId ?? '';
                                   String towerId = tempp.response?.towarId ?? tempp.towarIdFk ?? widget.towarId ?? '';
                                   if (projId.isNotEmpty) {
                                     await apiNetworkHandler.ensureProjectContext(projId);
                                   }
                                   if (!mounted) return;
                                   Navigator.of(context).pushNamed(
                                     '/taskManagerScreen',
                                     arguments: NotificationArgs(
                                       projectId: projId,
                                       projectName: tempp.projectName ?? widget.projectName,
                                       towarName: tempp.projectLocation ?? widget.towarName,
                                       response: NotificationResponseData(
                                         towarId: towerId,
                                       ),
                                     ),
                                   );
                                 } else if (tempp.notificationType == 'generatedpr') {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (_) {
                                  //       return DailyProgressReport(
                                  //         projectId: tempp.projectId,
                                  //         towarId: tempp.response?.towarId,
                                  //         projectName: tempp.projectName,
                                  //         towarName: tempp.projectLocation,
                                  //         title: tempp.response?.slabNo,
                                  //         slabId: tempp.response?.slabId,
                                  //       );
                                  //     },
                                  //   ),
                                  // );
                                  Navigator.of(context).pushNamed(
                                    '/dailyProgressReportScreen',
                                    arguments: NotificationArgs(
                                      projectId: tempp.projectId,
                                      projectName: tempp.projectName,
                                      towarName: tempp.projectLocation,
                                      response: NotificationResponseData(
                                        towarId: tempp.response?.towarId,
                                        slabNo: tempp.response?.slabNo,
                                        slabId: tempp.response?.slabId,
                                      ),
                                    ),
                                  );
                                } else if (tempp.notificationType ==
                                        'rccpoassign' ||
                                    tempp.notificationType == 'rccverifyorder' ||
                                    tempp.notificationType == 'work_order_list') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return AccountManagementView(
                                            projectId: tempp.projectId,
                                            towarId: tempp.response?.towarId ?? '',
                                            projectName: tempp.projectName,
                                            towarName: tempp.projectLocation ?? '',
                                            navigationFlag: 'Project');
                                      },
                                    ),
                                  );
                                } else if (tempp.notificationType ==
                                        'salemanagement' ||
                                    tempp.notificationType == 'Payment-type') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return SalesManagementView(
                                            projectId: tempp.projectId,
                                            towarId: tempp.response?.towarId,
                                            projectName: tempp.projectName,
                                            towarName: tempp.projectLocation!,
                                            navigationFlag: 'Project');
                                      },
                                    ),
                                  );
                                } else if (tempp.notificationType ==
                                    'createdmetting') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return TaskDetailsScreen(
                                          userTask: tempp.response!.userTask![0],
                                          projectId: tempp.projectId,
                                          towarId: tempp.response?.towarId,
                                          projectName: tempp.projectName,
                                          towarName: tempp.projectLocation!,
                                        );
                                      },
                                    ),
                                  );
                                } else if ((tempp.notificationType != null &&
                                     (tempp.notificationType!.toLowerCase().contains('legal') ||
                                      tempp.notificationType == 'legal_file_uploaded' ||
                                      tempp.notificationType == 'ws-upload-legal-diagram' ||
                                      tempp.notificationType == 'ws-upload-sublegal-diagram' ||
                                      tempp.notificationType == 'ws-update-legal-status' ||
                                      tempp.notificationType == 'ws-set-legal-remark')) ||
                                    (tempp.msg != null && tempp.msg!.toLowerCase().contains('legal'))) {
                                  String projId = tempp.projectId ?? widget.projectId ?? '';
                                  String projName = tempp.projectName ?? widget.projectName ?? '';
                                  final String refId = tempp.response?.permissionId ?? tempp.mstNotificationId ?? '';

                                  if (projId.isEmpty || projId == refId || projName.isEmpty) {
                                    final resolved = await SocketService.resolveProjectByBody(
                                      "${projName} ${tempp.msg ?? ''}",
                                      referenceId: refId.isNotEmpty ? refId : tempp.projectId,
                                    );
                                    if (resolved != null && resolved['id'] != null && resolved['id']!.isNotEmpty) {
                                      projId = resolved['id']!;
                                      if (resolved['name'] != null && resolved['name']!.isNotEmpty) {
                                        projName = resolved['name']!;
                                      }
                                    }
                                  }

                                  if (projId.isNotEmpty) {
                                    await apiNetworkHandler.ensureProjectContext(projId);
                                  }

                                  Navigator.of(context).pushNamed(
                                    '/legal',
                                    arguments: NotificationArgs(
                                      msg: tempp.msg,
                                      projectId: projId,
                                      projectName: projName,
                                      towarName: null,
                                      response: NotificationResponseData(
                                        towarId: null,
                                        permissionId: refId.isNotEmpty ? refId : tempp.projectId,
                                      ),
                                    ),
                                  );
                                } else if ((tempp.notificationType != null &&
                                     (tempp.notificationType!.toLowerCase().contains('permission') ||
                                      tempp.notificationType!.toLowerCase().contains('permisson') ||
                                      tempp.notificationType == 'file_uploaded' ||
                                      tempp.notificationType == 'permission_file_uploaded' ||
                                      tempp.notificationType == 'permission_status_update')) ||
                                    (tempp.msg != null && (tempp.msg!.toLowerCase().contains('permission') || tempp.msg!.toLowerCase().contains('permisson')))) {
                                  String projId = tempp.projectId ?? widget.projectId ?? '';
                                  String projName = tempp.projectName ?? widget.projectName ?? '';
                                  final String refId = tempp.response?.permissionId ?? tempp.mstNotificationId ?? '';

                                  if (projId.isEmpty || projId == refId || projName.isEmpty) {
                                    final resolved = await SocketService.resolveProjectByBody(
                                      "${projName} ${tempp.msg ?? ''}",
                                      referenceId: refId.isNotEmpty ? refId : tempp.projectId,
                                    );
                                    if (resolved != null && resolved['id'] != null && resolved['id']!.isNotEmpty) {
                                      projId = resolved['id']!;
                                      if (resolved['name'] != null && resolved['name']!.isNotEmpty) {
                                        projName = resolved['name']!;
                                      }
                                    }
                                  }

                                  String? realTower;
                                  if (tempp.response?.towarId != null &&
                                      tempp.response!.towarId!.isNotEmpty &&
                                      tempp.response!.towarId != refId &&
                                      int.tryParse(tempp.response!.towarId!) == null) {
                                    realTower = tempp.response!.towarId;
                                  }

                                  if (projId.isNotEmpty) {
                                    await apiNetworkHandler.ensureProjectContext(projId);
                                  }

                                  Navigator.of(context).pushNamed(
                                    '/permissions',
                                    arguments: NotificationArgs(
                                      msg: tempp.msg,
                                      projectId: projId,
                                      projectName: projName,
                                      towarName: realTower,
                                      response: NotificationResponseData(
                                        towarId: tempp.response?.towarId,
                                        permissionId: refId.isNotEmpty ? refId : tempp.projectId,
                                      ),
                                    ),
                                  );
                                } else if (tempp.notificationType == 'wo-ceritify-work' ||
                                    tempp.notificationType == 'wo-certify-work' ||
                                    tempp.notificationType == 'wo_certify_work') {
                                  Navigator.of(context).pushNamed(
                                    '/myContractsDetailViewScreen',
                                    arguments: NotificationArgs(
                                      projectId: tempp.projectId ?? widget.projectId,
                                      projectName: tempp.projectName ?? widget.projectName,
                                      towarName: tempp.projectLocation ?? widget.towarName,
                                      response: NotificationResponseData(
                                        towarId: tempp.response?.towarId ?? widget.towarId,
                                        woOrderId: tempp.response?.woOrderId,
                                        woOrderNo: tempp.response?.woOrderNo,
                                      ),
                                    ),
                                  );
                                } else if (tempp.notificationType == 'wo_issued' ||
                                    tempp.notificationType == 'wo-issued') {
                                  Navigator.of(context).pushNamed(
                                    '/woRequestedViewScreen',
                                    arguments: NotificationArgs(
                                      projectId: tempp.projectId ?? widget.projectId,
                                      projectName: tempp.projectName ?? widget.projectName,
                                      towarName: tempp.projectLocation ?? widget.towarName,
                                      response: NotificationResponseData(
                                        assignToId: '',
                                        flagRedirect: 'Issued',
                                        towarId: tempp.response?.towarId ?? widget.towarId,
                                      ),
                                    ),
                                  );
                                } else if (tempp.notificationType == 'wo_authenticate' ||
                                    tempp.notificationType == 'wo-authenticate') {
                                  Navigator.of(context).pushNamed(
                                    '/woRequestedViewScreen',
                                    arguments: NotificationArgs(
                                      projectId: tempp.projectId ?? widget.projectId,
                                      projectName: tempp.projectName ?? widget.projectName,
                                      towarName: tempp.projectLocation ?? widget.towarName,
                                      response: NotificationResponseData(
                                        assignToId: '',
                                        flagRedirect: 'Requested',
                                        towarId: tempp.response?.towarId ?? widget.towarId,
                                      ),
                                    ),
                                  );
                                } else if (tempp.notificationType == 'wo_assigned' ||
                                    tempp.notificationType == 'wo-assigned') {
                                  Navigator.of(context).pushNamed(
                                    '/woRequestedViewScreen',
                                    arguments: NotificationArgs(
                                      projectId: tempp.projectId ?? widget.projectId,
                                      projectName: tempp.projectName ?? widget.projectName,
                                      towarName: tempp.projectLocation ?? widget.towarName,
                                      response: NotificationResponseData(
                                        assignToId: '',
                                        flagRedirect: 'Assigned',
                                        towarId: tempp.response?.towarId ?? widget.towarId,
                                      ),
                                    ),
                                  );
                                  //           projectName: tempp.projectName,
                                  //           flagRedirect: 'Assigned'); //Assigned
                                  //     },
                                  //   ),
                                  // );
                                  Navigator.of(context).pushNamed(
                                    '/woRequestedViewScreen',
                                    arguments: NotificationArgs(
                                      projectId: widget.projectId,
                                      projectName: widget.projectName,
                                      towarName: widget.towarName,
                                      response: NotificationResponseData(
                                        assignToId: '',
                                        flagRedirect: 'Assigned',
                                        towarId: widget.towarId,
                                      ),
                                    ),
                                  );
                                } else {
                                  String targetRoute = SocketService.routeFromNotificationType(tempp.notificationType);
                                  if (targetRoute.isNotEmpty && targetRoute != '/') {
                                    String projId = tempp.projectId ?? tempp.response?.projectId ?? widget.projectId ?? '';
                                    String towerId = tempp.response?.towarId ?? tempp.towarIdFk ?? widget.towarId ?? '';
                                    if (projId.isNotEmpty) {
                                      await apiNetworkHandler.ensureProjectContext(projId);
                                    }
                                    if (!mounted) return;
                                    Navigator.of(context).pushNamed(
                                      targetRoute,
                                      arguments: NotificationArgs(
                                        msg: tempp.msg,
                                        projectId: projId,
                                        projectName: tempp.projectName ?? widget.projectName,
                                        towarName: tempp.projectLocation ?? widget.towarName,
                                        response: NotificationResponseData(
                                          projectId: projId,
                                          towarId: towerId,
                                          categoryId: tempp.response?.categoryId ?? tempp.categoryId,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 16.0 : 40.0,
                                  vertical: 2.0,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14.0),
                                  border: Border.all(color: const Color(0xfff0f0f0), width: 1.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.015),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                          Text(
                                            tempp.msg ?? '',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              calDateTime(
                                                dateTime: tempp.createdAt ?? DateTime.now(),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => const SizedBox.shrink(),
                        ))
              : Center(
                  child: Text(
                    "No Record Found",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
    );
  }
}
