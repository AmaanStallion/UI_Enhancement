import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_project_management.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/ui/chat_section/chat_ui.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/budget/ui/budget_screen.dart';
import 'package:stallion/ui/views/finishing/new_finishing/finishing_management.dart';
import 'package:stallion/ui/views/legal/legal_screen.dart';
import 'package:stallion/ui/views/masonry/masonrystructurescreen.dart';
import 'package:stallion/ui/views/mycontracts/mycontract_list_view.dart';
import 'package:stallion/ui/views/overview_module/overview.dart';
import 'package:stallion/ui/views/permission/permissions.dart';
import 'package:stallion/ui/views/planselevation/planelevation.dart';
import 'package:stallion/ui/views/profitLossModel/profit_loss_model.dart';
import 'package:stallion/ui/views/rccstructure/slab/issue_reported_work_progress.dart';
import 'package:stallion/models/get_rcc_slab_issues.dart';
import 'package:stallion/models/get_rccissuereport_data.dart';
import 'package:stallion/models/developer_rcc_count_response.dart';
import 'package:stallion/ui/views/rccstructure/rccstructurescreen.dart';
import 'package:stallion/ui/views/sopModule/sop_screen.dart';
import 'package:stallion/ui/views/task_manager/task_count_screen.dart';
import 'package:stallion/ui/views/task_manager/task_manager_screen.dart';
import 'package:stallion/ui/views/tenantManagement/tenantManagementList.dart';
import 'package:stallion/ui/views/workprogess/pdfViewPage.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:stallion/websocket/socket_service.dart';
import '../PurchaseOrder/purchase_order_form.dart';
import '../accountmanagement/accountmanagement.dart';
import '../accountmanagement/account_management_preview.dart';
import '../constructionmanagementschedule/fancynode/schedule.dart';
import '../constructionmanagementschedule/provider/provider_registration.dart';
import '../mycontracts/mycontracts.dart';
import '../salesmanagement/salesmainview.dart';
import '../statusofsupply/statussupplyview.dart';
import '../teamlist/teamlistview.dart';
import '../workorder/workordermain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class WorkProgressList extends ConsumerStatefulWidget {
  const WorkProgressList({
    Key? key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    this.consultantMagicLink,
    this.contractorMagicLink,
    this.vendMagicLink,
    this.preloadedModules,
  }) : super(key: key);
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? contractorMagicLink;
  final String? vendMagicLink;
  final String? consultantMagicLink;
  // Modules pre-loaded from GET /projects/mobile — skips /modules/assignable when set
  final List<dynamic>? preloadedModules;

  @override
  //_WorkProgressListState createState() => _WorkProgressListState();
  ConsumerState<WorkProgressList> createState() => _WorkProgressListState();
}

class _WorkProgressListState extends ConsumerState<WorkProgressList> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  bool circular = false;
  ProjectManagementResponse? responseData;
  List<dynamic>? assignedModules;
  bool _modulesLoaded = false;
  String? _resolvedTowerId;
  String? _resolvedTowerName;

  List<ProjectStructure> sortProjectStructures(List<ProjectStructure> list) {
    ProjectStructure? taskManager;
    ProjectStructure? plansElevation;
    ProjectStructure? sop;
    ProjectStructure? legal;
    ProjectStructure? cms;
    ProjectStructure? permissions;

    List<ProjectStructure> normalModules = [];

    for (var item in list) {
      final title = item.title?.trim();
      if (title == "Task Manager") {
        taskManager = item;
      } else if (title == "Plans and Elevation") {
        plansElevation = item;
      } else if (title == "S.O.P") {
        sop = item;
      } else if (title == "Legal") {
        legal = item;
      } else if (title == "CMS") {
        cms = item;
      } else if (title == "Permissions") {
        permissions = item;
      } else {
        normalModules.add(item);
      }
    }

    List<ProjectStructure> sortedList = [...normalModules];

    if (permissions != null) {
      sortedList.add(permissions);
    }
    if (cms != null) {
      sortedList.add(cms);
    }
    if (legal != null) {
      sortedList.add(legal);
    }
    // Last three modules are always fixed in order: SOP, Task Manager, Plans and Elevation
    if (sop != null) {
      sortedList.add(sop);
    }
    if (taskManager != null) {
      sortedList.add(taskManager);
    }
    if (plansElevation != null) {
      sortedList.add(plansElevation);
    }

    return sortedList;
  }

  Future<Map<String, dynamic>> fetchPermissionsProgress() async {
    try {
      if (AppUrl.useNewBackend) {
        String url =
            "${AppUrl.baseURL}permissions/projects/${widget.projectId}";
        var response = await apiNetworkHandler
            .get(url)
            .timeout(const Duration(seconds: 4));
        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          final decoded = json.decode(response.body);
          if (decoded['success'] == true) {
            var data = decoded['data'];
            List list = [];
            if (data is List) {
              list = data;
            } else if (data is Map && data['permissions'] is List) {
              list = data['permissions'];
            }
            int total = list.length;
            int issued = 0;
            int expiredCount = 0;
            for (var item in list) {
              if (item is Map) {
                String status = (item['permission_status'] ?? '').toString();
                if (status == "Issued" || status == "3") {
                  issued++;
                }
                String expDateStr = item['exp_date'] ?? "";
                if (expDateStr.isNotEmpty) {
                  try {
                    String cleanDate = expDateStr.contains('T') ? expDateStr.split('T')[0] : expDateStr;
                    DateTime parsed = DateTime.parse(cleanDate.trim());
                    DateTime now = DateTime.now();
                    DateTime today = DateTime(now.year, now.month, now.day);
                    DateTime exp = DateTime(parsed.year, parsed.month, parsed.day);
                    if (exp.isBefore(today)) {
                      expiredCount++;
                    }
                  } catch (_) {}
                }
              }
            }
            double percentage = total > 0 ? (issued / total) * 100 : 0.0;
            return {
              'hasPermissions': total > 0,
              'percentage': percentage,
              'expiredCount': expiredCount,
            };
          }
        }
      } else {
        final SharedPreferences prefs = await _prefs;
        String? userId = prefs.getString('mobileNo');
        Map<String, String> data = {
          "user_id": userId ?? '',
          "project_id": widget.projectId ?? '',
          "towar_id": widget.towarId ?? '',
          "assign_to_id": "",
          "filter": "",
        };
        var response = await apiNetworkHandler
            .post(AppUrl.webGetProjectPermission, data)
            .timeout(const Duration(seconds: 4));
        if (response.statusCode == 200 || response.statusCode == 201) {
          final decoded = json.decode(response.body);
          if (decoded != null && decoded['Response'] != null) {
            final respData = decoded['Response'];
            if (respData['error_code'] == "0") {
              final details = respData['permission_details'];
              if (details is List) {
                int total = details.length;
                int issued = 0;
                int expiredCount = 0;
                for (var item in details) {
                  if (item is Map) {
                    String status = (item['status'] ?? '').toString();
                    if (status == "3" || status == "Issued") {
                      issued++;
                    }
                    String expDateStr = item['exp_date'] ?? "";
                    if (expDateStr.isNotEmpty) {
                      try {
                        String cleanDate = expDateStr.contains('T') ? expDateStr.split('T')[0] : expDateStr;
                        DateTime parsed = DateTime.parse(cleanDate.trim());
                        DateTime now = DateTime.now();
                        DateTime today = DateTime(now.year, now.month, now.day);
                        DateTime exp = DateTime(parsed.year, parsed.month, parsed.day);
                        if (exp.isBefore(today)) {
                          expiredCount++;
                        }
                      } catch (_) {}
                    }
                  }
                }
                double percentage = total > 0 ? (issued / total) * 100 : 0.0;
                return {
                  'hasPermissions': total > 0,
                  'percentage': percentage,
                  'expiredCount': expiredCount,
                };
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in fetchPermissionsProgress: $e");
      }
    }
    return {
      'hasPermissions': false,
      'percentage': 0.0,
      'expiredCount': 0,
    };
  }

  Future<Map<String, dynamic>> fetchLegalProgress() async {
    try {
      if (AppUrl.useNewBackend) {
        String url =
            "${AppUrl.baseURL}legal-permissions/projects/${widget.projectId}";
        var response = await apiNetworkHandler
            .get(url)
            .timeout(const Duration(seconds: 4));
        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          final decoded = json.decode(response.body);
          if (decoded['success'] == true && decoded['data'] != null) {
            var permissions = decoded['data']['permissions'];
            List list = [];
            if (permissions is List) {
              list = permissions;
            }
            int total = list.length;
            int issued = 0;
            for (var item in list) {
              if (item is Map) {
                String status = (item['permission_status'] ?? '').toString().toLowerCase().trim();
                if (status == "issued" || status == "3") {
                  issued++;
                }
              }
            }
            double percentage = total > 0 ? (issued / total) * 100 : 0.0;
            return {
              'hasLegal': total > 0,
              'percentage': percentage,
            };
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in fetchLegalProgress: $e");
      }
    }
    return {
      'hasLegal': false,
      'percentage': 0.0,
    };
  }

  /// Resolves towerId from widget.towarId, or falls back to GET {{baseURL}}/towers?project_id={projectId}
  Future<String?> _resolveTowerId() async {
    if (widget.towarId != null && widget.towarId!.isNotEmpty) {
      return widget.towarId;
    }
    if (_resolvedTowerId != null && _resolvedTowerId!.isNotEmpty) {
      return _resolvedTowerId;
    }
    if (widget.projectId == null || widget.projectId!.isEmpty) {
      return null;
    }
    try {
      await apiNetworkHandler.ensureProjectContext(widget.projectId);
      var response = await apiNetworkHandler
          .get("${AppUrl.baseURL}towers?project_id=${widget.projectId}")
          .timeout(const Duration(seconds: 4));
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true &&
            decoded['data'] is List &&
            (decoded['data'] as List).isNotEmpty) {
          final list = decoded['data'] as List;
          // 1. If widget.towarId is provided, verify it actually exists in this project's towers
          if (widget.towarId != null && widget.towarId!.trim().isNotEmpty && widget.towarId != '0') {
            final matched = list.firstWhere(
              (item) => item is Map && item['id']?.toString() == widget.towarId!.trim(),
              orElse: () => null,
            );
            if (matched != null && matched['id'] != null) {
              _resolvedTowerId = matched['id'].toString();
              _resolvedTowerName = matched['name']?.toString() ?? widget.towarName;
              SocketService.currentActiveTowerId = _resolvedTowerId;
              return _resolvedTowerId;
            }
          }
          // 2. Match by widget.towarName if available
          if (widget.towarName != null && widget.towarName!.trim().isNotEmpty) {
            final targetName = widget.towarName!.trim().toLowerCase();
            final matched = list.firstWhere(
              (item) => item is Map && (item['name'] ?? '').toString().trim().toLowerCase() == targetName,
              orElse: () => null,
            );
            if (matched != null && matched['id'] != null) {
              _resolvedTowerId = matched['id'].toString();
              _resolvedTowerName = matched['name']?.toString();
              SocketService.currentActiveTowerId = _resolvedTowerId;
              return _resolvedTowerId;
            }
          }
          // 3. Fallback to the first tower of this project
          final firstItem = list.first;
          if (firstItem is Map && firstItem['id'] != null) {
            _resolvedTowerId = firstItem['id'].toString();
            _resolvedTowerName = firstItem['name']?.toString();
            SocketService.currentActiveTowerId = _resolvedTowerId;
            return _resolvedTowerId;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error resolving fallback tower ID: $e");
      }
    }
    return _resolvedTowerId ?? widget.towarId;
  }

  /// Fetches pending RCC issues count and list for new backend
  Future<Map<String, dynamic>> fetchRccPendingIssues([String? resolvedTowerId]) async {
    try {
      final towerId = resolvedTowerId ?? await _resolveTowerId();
      if (towerId == null || towerId.isEmpty) {
        return {'count': 0, 'issues': <SlabIssueReport>[]};
      }

      await apiNetworkHandler.ensureProjectContext(widget.projectId);

      String url = "${AppUrl.getRccSlabIssues}?tower_id=$towerId&status=pending";
      var response = await apiNetworkHandler
          .get(url)
          .timeout(const Duration(seconds: 4));

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final parsed = getRccSlabIssuesResponseFromJson(response.body);
        if (parsed.success && parsed.data != null) {
          final mappedIssues = parsed.data!.issues
              .map((item) => item.toSlabIssueReport())
              .toList();
          return {
            'count': parsed.data!.totalRecords,
            'issues': mappedIssues,
          };
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in fetchRccPendingIssues: $e");
      }
    }
    return {
      'count': 0,
      'issues': <SlabIssueReport>[],
    };
  }

  /// Fetches RCC completed slabs progress count and percentage for new backend
  Future<Map<String, dynamic>> fetchRccProgress([String? resolvedTowerId]) async {
    try {
      final towerId = resolvedTowerId ?? await _resolveTowerId();
      if (towerId == null || towerId.isEmpty) {
        return {
          'percentage': 0.0,
          'totalSlabs': 0,
          'completedSlabs': 0,
        };
      }

      await apiNetworkHandler.ensureProjectContext(widget.projectId);

      String url = AppUrl.getTowerDeveloperRccCount(towerId);
      var response = await apiNetworkHandler
          .get(url)
          .timeout(const Duration(seconds: 4));

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final parsed = developerRccCountResponseFromJson(response.body);
        if (parsed.success && parsed.data != null) {
          return {
            'percentage': parsed.data!.percentage,
            'totalSlabs': parsed.data!.totalSlabs,
            'completedSlabs': parsed.data!.developerAndRccCheckedCount,
          };
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in fetchRccProgress: $e");
      }
    }
    return {
      'percentage': 0.0,
      'totalSlabs': 0,
      'completedSlabs': 0,
    };
  }

  /// Primary source: Fetches project list from GET /projects/mobile using master token,
  /// and extracts the assigned modules for widget.projectId and current role.
  Future<bool> fetchModulesFromProjectsMobile() async {
    try {
      final SharedPreferences prefs = await _prefs;
      String? loginTypePref = prefs.getString('loginType');
      String targetRole = 'user';
      if (loginTypePref == 'contractor') {
        targetRole = 'contractor_emp';
      } else if (loginTypePref == 'consultant') {
        targetRole = 'consultant_emp';
      }

      if (kDebugMode) {
        print(
            "WorkProgressList: Primary source — fetching assigned modules from GET /projects/mobile for role $targetRole using master token");
      }
      var response =
          await apiNetworkHandler.getWithMasterToken(AppUrl.getMobileProjectList);
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          final data = decoded['data'];
          final List list =
              (data is Map ? data['projects'] : data) as List? ?? [];

          // First try matching BOTH projectId and targetRole
          for (var item in list) {
            if (item is Map &&
                item['id']?.toString() == widget.projectId?.toString()) {
              final String itemRole = item['role']?.toString() ??
                  item['role in this project']?.toString() ??
                  'user';
              if (itemRole == targetRole && item['modules'] is List) {
                if (kDebugMode) {
                  print(
                      "WorkProgressList: Found project ${widget.projectId} (role $itemRole) modules (${(item['modules'] as List).length}) from GET /projects/mobile");
                }
                setState(() {
                  assignedModules = item['modules'];
                  _modulesLoaded = true;
                });
                return true;
              }
            }
          }

          // Fallback: match by projectId alone if targetRole didn't match
          for (var item in list) {
            if (item is Map &&
                item['id']?.toString() == widget.projectId?.toString()) {
              if (item['modules'] is List) {
                if (kDebugMode) {
                  print(
                      "WorkProgressList: Found project ${widget.projectId} modules (${(item['modules'] as List).length}) from GET /projects/mobile");
                }
                setState(() {
                  assignedModules = item['modules'];
                  _modulesLoaded = true;
                });
                return true;
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching modules from GET /projects/mobile: $e");
      }
    }
    return false;
  }

  /// Loads assigned modules strictly from GET /projects/mobile.
  /// First checks preloadedModules, then attempts fetchModulesFromProjectsMobile().
  Future<void> loadAssignedModules() async {
    if (widget.preloadedModules != null &&
        widget.preloadedModules!.isNotEmpty) {
      if (kDebugMode) {
        print(
            "WorkProgressList: Using pre-loaded modules (${widget.preloadedModules!.length}) from GET /projects/mobile");
      }
      setState(() {
        assignedModules = widget.preloadedModules;
        _modulesLoaded = true;
      });
      return;
    }

    bool success = await fetchModulesFromProjectsMobile();
    if (success) {
      return;
    }

    if (kDebugMode) {
      print(
          "WorkProgressList: GET /projects/mobile returned no modules for project ${widget.projectId}");
    }
    setState(() {
      assignedModules = [];
      _modulesLoaded = true;
    });
  }

  bool isModuleAssigned(String moduleKey) {
    if (!AppUrl.useNewBackend) {
      return true; // old backend shows all active structures
    }

    // Explicitly ignore templates module
    if (moduleKey == 'templates') {
      return false;
    }

    if (assignedModules == null) return false;

    for (var item in assignedModules!) {
      if (item is Map) {
        final String type = (item['type'] ?? '').toString().toLowerCase().trim();
        final dynamic parentId = item['parent_module_id'];
        final bool isTopLevel = type == 'module' || (parentId == null && type != 'submodule');

        final String name = (item['name'] ?? '').toString().toLowerCase().trim();
        final String id = (item['id'] ?? '').toString().trim();

        if (moduleKey == 'rcc') {
          if (isTopLevel && (name.contains('rcc') || name.contains('r.c.c') || id == '8' || id == '47')) {
            return true;
          }
        }
        if (moduleKey == 'masonry') {
          if (isTopLevel && (name.contains('masonry') || id == '48')) {
            return true;
          }
        }
        if (moduleKey == 'permission') {
          if (isTopLevel && (name.contains('permission') || id == '19' || id == '58')) {
            return true;
          }
        }
        if (moduleKey == 'sales') {
          if (isTopLevel && (name.contains('sales') || id == '15')) {
            return true;
          }
        }
        if (moduleKey == 'account_management') {
          if (isTopLevel && id == '50') {
            return true;
          }
        }
        if (moduleKey == 'po') {
          // Top-level module: Request Purchase Order / PO
          if (isTopLevel &&
              (name.contains('purchase order') ||
                  name.contains('payment order') ||
                  name.contains('request po') ||
                  name.contains('request purchase order') ||
                  name == 'po' ||
                  id == '10' ||
                  id == '68')) {
            return true;
          }
          // Submodule under Accounts Management (id 50)
          if (!isTopLevel && parentId?.toString() == '50') {
            if (name.contains('purchase order') ||
                name.contains('payment order') ||
                name.contains('request po') ||
                name == 'po' ||
                id == '13') {
              return true;
            }
          }
        }
        if (moduleKey == 'wo') {
          // Top-level module: Request Work Order / WO
          if (isTopLevel &&
              (name.contains('work order') ||
                  name.contains('request wo') ||
                  name.contains('request work order') ||
                  name == 'wo' ||
                  id == '11' ||
                  id == '69')) {
            return true;
          }
          // Submodule under Accounts Management (id 50)
          if (!isTopLevel && parentId?.toString() == '50') {
            if (name.contains('work order') ||
                name.contains('request wo') ||
                name == 'wo' ||
                id == '14') {
              return true;
            }
          }
        }
        if (moduleKey == 'budget') {
          if (isTopLevel && (name.contains('budget') || id == '17')) {
            return true;
          }
        }
        if (moduleKey == 'tenant') {
          if (isTopLevel && (name.contains('tenant') || id == '16')) {
            return true;
          }
        }
        if (moduleKey == 'legal') {
          if (isTopLevel && (name.contains('legal') || id == '20' || id == '59')) {
            return true;
          }
        }
        if (moduleKey == 'contracts') {
          if (isTopLevel && (name.contains('contract') || id == '14')) {
            return true;
          }
        }
        if (moduleKey == 'profit_loss') {
          if (isTopLevel && (name.contains('profit') || id == '18')) {
            return true;
          }
        }
        if (moduleKey == 'cms') {
          if (isTopLevel && name.contains('cms')) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Future<List<ProjectStructure>?> fetchProjectWorkProgressList() async {
    setState(() {
      circular = true;
    });

    if (AppUrl.useNewBackend) {
      await loadAssignedModules();

      Map<String, dynamic> permInfo = {
        'hasPermissions': false,
        'percentage': 0.0,
        'expiredCount': 0,
      };
      if (isModuleAssigned('permission')) {
        permInfo = await fetchPermissionsProgress();
      }

      Map<String, dynamic> legalInfo = {
        'hasLegal': false,
        'percentage': 0.0,
      };
      if (isModuleAssigned('legal')) {
        legalInfo = await fetchLegalProgress();
      }

      Map<String, dynamic> rccInfo = {
        'count': 0,
        'issues': <SlabIssueReport>[],
      };
      Map<String, dynamic> rccProgress = {
        'percentage': 0.0,
        'totalSlabs': 0,
        'completedSlabs': 0,
      };
      if (isModuleAssigned('rcc')) {
        final towerId = await _resolveTowerId();
        final results = await Future.wait([
          fetchRccPendingIssues(towerId),
          fetchRccProgress(towerId),
        ]);
        rccInfo = results[0];
        rccProgress = results[1];
      }

      List<ProjectStructure> activeStructures = [];

      if (isModuleAssigned('permission')) {
        activeStructures.add(ProjectStructure(
          title: "Permissions",
          discription: "Status of Various Permissions",
          complete: permInfo['percentage'].toStringAsFixed(0),
          issuse: permInfo['expiredCount']?.toString() ?? "0",
          isActive: "1",
          isSetupDone: permInfo['hasPermissions'] ? "1" : "0",
          groupFlag: "0",
        ));
      }
      if (isModuleAssigned('rcc')) {
        activeStructures.add(ProjectStructure(
          title: "R.C.C Structure",
          discription: "On Site Progress of R.C.C Structure.",
          complete: ((rccProgress['percentage'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(0),
          issuse: rccInfo['count']?.toString() ?? "0",
          isActive: "1",
          isSetupDone: "1",
          issueDetails: rccInfo['issues'] as List<SlabIssueReport>?,
          groupFlag: "0",
        ));
      }
      if (isModuleAssigned('masonry')) {
        activeStructures.add(ProjectStructure(
          title: "Masonry",
          discription: "Masonry module",
          complete: "0",
          issuse: "0",
          isActive: "1",
          isSetupDone: "1",
          groupFlag: "0",
        ));
      }
      if (useAccountManagementTestData || isModuleAssigned('account_management')) {
        activeStructures.add(ProjectStructure(
          title: "Account Management",
          discription: "Manage Purchase Orders, Work Orders & Payments.",
          complete: "0",
          issuse: "0",
          isActive: "1",
          isSetupDone: "1",
          groupFlag: "0",
        ));
      }
      if (isModuleAssigned('po')) {
        activeStructures.add(ProjectStructure(
          title: "Request Purchase Order",
          discription: "Payment Orders & Bills",
          complete: "0",
          issuse: "0",
          isActive: "1",
          isSetupDone: "1",
          groupFlag: "0",
        ));
      }
      if (isModuleAssigned('wo')) {
        activeStructures.add(ProjectStructure(
          title: "Request Work Order",
          discription: "Work Orders & Contracts",
          complete: "0",
          issuse: "0",
          isActive: "1",
          isSetupDone: "1",
          groupFlag: "0",
        ));
      }
      if (isModuleAssigned('profit_loss')) {
        activeStructures.add(ProjectStructure(
          title: "Profit & Loss",
          discription: "Profit & Loss",
          complete: "0",
          issuse: "0",
          isActive: "1",
          isSetupDone: "1",
          groupFlag: "0",
        ));
      }
      if (isModuleAssigned('legal')) {
        activeStructures.add(ProjectStructure(
          title: "Legal",
          discription: "Pre-Acquisition & Legal Documents.",
          complete: legalInfo['percentage'].toStringAsFixed(0),
          issuse: "0",
          isActive: "1",
          isSetupDone: legalInfo['hasLegal'] ? "1" : "0",
          groupFlag: "0",
        ));
      }
      if (isModuleAssigned('contracts')) {
        activeStructures.add(ProjectStructure(
          title: "My Contracts",
          discription: "Monitor Contract Progress with Bills, Payments etc.",
          complete: "0",
          issuse: "0",
          isActive: "1",
          isSetupDone: "1",
          groupFlag: "0",
        ));
      }
      if (isModuleAssigned('tenant')) {
        activeStructures.add(ProjectStructure(
          title: "Tenant Management",
          discription: "Manage Tenant Details & Payments.",
          complete: "0",
          issuse: "0",
          isActive: "1",
          isSetupDone: "1",
          groupFlag: "0",
        ));
      }

      // ALWAYS FIXED LAST THREE MODULES:
      // 1. S.O.P
      activeStructures.add(ProjectStructure(
        title: "S.O.P",
        discription:
            "Document each step to execute & maintain for streamlined operations.",
        complete: "0",
        issuse: "0",
        isActive: "1",
        isSetupDone: "1",
        groupFlag: "0",
      ));

      // 2. Task Manager
      activeStructures.add(ProjectStructure(
        title: "Task Manager",
        discription: "Task Manager module",
        complete: "0",
        issuse: "0",
        isActive: "1",
        isSetupDone: "1",
        groupFlag: "0",
      ));

      // 3. Plans and Elevation
      activeStructures.add(ProjectStructure(
        title: "Plans and Elevation",
        discription: "Plans & Elevation drawings",
        complete: "0",
        issuse: "0",
        isActive: "1",
        isSetupDone: "1",
        groupFlag: "0",
      ));

      final sortedStructures = sortProjectStructures(activeStructures);

      final mockResponse = ProjectManagementResponse(
        errorCode: "0",
        msg: "Success",
        projectOverView: "1", // always 1 since we always have some structures
        projectStructure: sortedStructures,
        temaDetails: [],
        slabIssueDetails: [],
      );
      setState(() {
        responseData = mockResponse;
        circular = false;
      });
      return mockResponse.projectStructure;
    }

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    String? loginType = prefs.getString('loginType');

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "login_type": loginType ?? '',
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(
        AppUrl.getProjectWorkProgressListRequest, data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = ProjectManagementFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          responseData = dataModel.response;
        });

        List<ProjectStructure>? structurelist =
            dataModel.response?.projectStructure!;
        List<ProjectStructure>? newstructurelist = [];

        bool hasPermissionModule = false;
        bool hasLegalModule = false;
        bool hasRccModule = false;
        for (ProjectStructure list in structurelist!) {
          if (list.title == "Permissions") {
            hasPermissionModule = true;
          }
          if (list.title == "Legal") {
            hasLegalModule = true;
          }
          if (list.title == "R.C.C Structure") {
            hasRccModule = true;
          }
        }

        Map<String, dynamic> permInfo = {
          'hasPermissions': false,
          'percentage': 0.0,
          'expiredCount': 0,
        };
        if (hasPermissionModule) {
          permInfo = await fetchPermissionsProgress();
        }

        Map<String, dynamic> legalInfo = {
          'hasLegal': false,
          'percentage': 0.0,
        };
        if (hasLegalModule) {
          legalInfo = await fetchLegalProgress();
        }

        Map<String, dynamic> rccProgress = {
          'percentage': 0.0,
        };
        if (hasRccModule) {
          rccProgress = await fetchRccProgress();
        }

        for (ProjectStructure list in structurelist) {
          if (list.title == "Permissions") {
            list.isSetupDone = permInfo['hasPermissions'] ? "1" : "0";
            list.complete = permInfo['percentage'].toStringAsFixed(0);
            list.issuse = permInfo['expiredCount']?.toString() ?? "0";
          }
          if (list.title == "Legal") {
            list.isSetupDone = legalInfo['hasLegal'] ? "1" : "0";
            list.complete = legalInfo['percentage'].toStringAsFixed(0);
          }
          if (list.title == "R.C.C Structure") {
            list.complete = ((rccProgress['percentage'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(0);
          }
          if (list.isActive! == "1") {
            newstructurelist.add(list);
          }
        }

        bool hasSop = false;
        bool hasTask = false;
        bool hasPlansElevation = false;
        for (ProjectStructure list in newstructurelist) {
          if (list.title == "S.O.P") hasSop = true;
          if (list.title == "Task Manager") hasTask = true;
          if (list.title == "Plans and Elevation") hasPlansElevation = true;
        }

        if (!hasPlansElevation) {
          newstructurelist.add(ProjectStructure(
            title: "Plans and Elevation",
            discription: "Plans & Elevation drawings",
            complete: "0",
            issuse: "0",
            isActive: "1",
            isSetupDone: "1",
            groupFlag: "0",
          ));
        }
        if (!hasSop) {
          newstructurelist.add(ProjectStructure(
            title: "S.O.P",
            discription:
                "Document each step to execute & maintain for streamlined operations.",
            complete: "0",
            issuse: "0",
            isActive: "1",
            isSetupDone: "1",
            groupFlag: "0",
          ));
        }
        if (!hasTask) {
          newstructurelist.add(ProjectStructure(
            title: "Task Manager",
            discription: "Task Manager module",
            complete: "0",
            issuse: "0",
            isActive: "1",
            isSetupDone: "1",
            groupFlag: "0",
          ));
        }

        final sortedList = sortProjectStructures(newstructurelist);
        setState(() {
          responseData = dataModel.response;
          if (responseData != null) {
            responseData!.projectStructure = sortedList;
          }
          circular = false;
        });

        return sortedList;
      } else {
        setState(() {
          circular = false;
        });
        List<ProjectStructure>? list = [];
        return list;
      }
    } else {
      setState(() {
        circular = false;
      });
      List<ProjectStructure>? list = [];
      return list;
    }
  }

  @override
  void initState() {
    super.initState();
    SocketService.currentActiveTowerId = widget.towarId;
    _resolveTowerId();
    fetchProjectWorkProgressList();
    
    // Check initial state
    final bool currentlyActive = SocketService.isTowerActive(widget.towarId ?? "");
    if (!currentlyActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).popUntil((route) {
            return route.settings.name == '/dashboard' || route.isFirst;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    if (SocketService.currentActiveTowerId == widget.towarId) {
      SocketService.currentActiveTowerId = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;
    final double itemWidth;
    if (isMobile) {
      final mediaQuery = MediaQuery.of(context);
      final double screenWidth = mediaQuery.size.width;
      int columnCount = 2;
      if (mediaQuery.size.shortestSide < 600) {
        columnCount = mediaQuery.orientation == Orientation.portrait ? 2 : 4;
      } else {
        columnCount = mediaQuery.orientation == Orientation.portrait ? 4 : 5;
      }
      final double sidePadding = 12.0;
      final double innerSpacing = 6.0;
      itemWidth = (screenWidth - (sidePadding * 2) - (columnCount - 1) * innerSpacing) / columnCount;
    } else {
      itemWidth = 210.0;
    }
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
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () {
        //     Navigator.maybePop(context);
        //     //Navigator.of(context).pushReplacementNamed('/dashboard');
        //   },
        // ),
        actions: [
          // TODO: Re-enable Chat and Overview buttons when features are built
          // InkWell(
          //   onTap: () {
          //     var projectId = widget.projectId!;
          //     var projectName = widget.projectName!;
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) {
          //           return ChatUI(
          //               // projectId: projectId,
          //               // projectName: projectName,
          //               // towarId: widget.towarId,
          //               // towarName: widget.towarName!,
          //               );
          //         },
          //       ),
          //     );
          //   },
          //   child: Container(
          //     margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          //     padding: const EdgeInsets.symmetric(horizontal: 25),
          //     decoration: BoxDecoration(
          //       border: Border.all(color: Colors.white, width: 2),
          //       borderRadius: BorderRadius.circular(6),
          //     ),
          //     child: const Center(
          //       child: Text(
          //         "CHAT",
          //         style: TextStyle(
          //             color: Colors.white,
          //             fontSize: 16,
          //             fontWeight: FontWeight.w600),
          //       ),
          //     ),
          //   ),
          // ),
          // if (responseData?.projectOverView == '1')
          //   InkWell(
          //     onTap: () {
          //       var projectId = widget.projectId!;
          //       var projectName = widget.projectName!;
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (_) {
          //             return OverviewScreen(
          //               projectId: projectId,
          //               projectName: projectName,
          //               towarId: widget.towarId,
          //               towarName: widget.towarName!,
          //             );
          //           },
          //         ),
          //       );
          //     },
          //     child: Container(
          //       margin:
          //           const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          //       padding: const EdgeInsets.symmetric(horizontal: 25),
          //       decoration: BoxDecoration(
          //         border: Border.all(color: Colors.white, width: 2),
          //         borderRadius: BorderRadius.circular(6),
          //       ),
          //       child: const Center(
          //         child: Text(
          //           "Overview",
          //           style: TextStyle(
          //               color: Colors.white,
          //               fontSize: 16,
          //               fontWeight: FontWeight.w600),
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
      body: responseData != null
          ? SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 50),
                        const Expanded(
                          child: Text('WORK PROGRESS',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 30.0),
                          child: InkWell(
                            onTap: () {
                              var projectId = widget.projectId!;
                              var projectName = widget.projectName!;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) {
                                    return TeamListView(
                                      projectId: projectId,
                                      projectName: projectName,
                                      towarId: widget.towarId,
                                      towarName: widget.towarName!,
                                    );
                                  },
                                ),
                              );
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (_) {
                              //       return
                              //           // PlansAndElevation
                              //           LegalScreen(
                              //         projectId: projectId,
                              //         towarId: widget.towarId!,
                              //         projectName: projectName,
                              //         towarName: widget.towarName!,
                              //       );
                              //     },
                              //   ),
                              // );
                            },
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.people_sharp,
                                size: 33.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 1,
                    child: Divider(color: Colors.black),
                  ),
                  Padding(
                    padding: EdgeInsets.all(isMobile ? 12.0 : 20.0),
                    child: (responseData!.projectStructure == null ||
                            responseData!.projectStructure!
                                .where((m) => m.isActive == '1')
                                .isEmpty)
                        ? Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 60.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.info_outline,
                                      size: 70.4,
                                      color: Color.lerp(Colors.grey, Colors.black, 0.10)),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "No module is assigned.",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Wrap(
                            spacing: isMobile ? 6.0 : 12.0,
                            runSpacing: isMobile ? 7.0 : 14.0,
                            children: [
                              for (int index = 0;
                                  index <
                                      responseData!.projectStructure!.length;
                                  index++)
                                if (responseData!
                                        .projectStructure![index].isActive ==
                                    '1')
                                  SizedBox(
                                    width: itemWidth,
                                    height: isMobile ? 185 : 215,
                                    child: GestureDetector(
                                        onTap: () {
                                          if (responseData!.projectStructure?[index].title! ==
                                                  "R.C.C Structure"
                                              // &&
                                              //     responseData!.projectStructure?[index].isSetupDone ==
                                              //         "1"
                                              ) {
                                            RequestPurchaseOrderNavigate();
                                            var projectId = widget.projectId!;
                                            var projectName =
                                                widget.projectName!;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) {
                                                  return RccStructure(
                                                    projectId: projectId,
                                                    towarId: widget.towarId!,
                                                    projectName: projectName,
                                                    towarName:
                                                        widget.towarName!,
                                                  );
                                                },
                                              ),
                                            ).then((value) {
                                              fetchProjectWorkProgressList();
                                            });
                                          } else if (responseData!
                                                      .projectStructure?[index]
                                                      .title! ==
                                                  "Masonry"
                                              // &&
                                              //     responseData!.projectStructure?[index].isSetupDone ==
                                              //         "1"
                                              ) {
                                            // RequestPurchaseOrderNavigate();
                                            var projectId = widget.projectId!;
                                            var projectName =
                                                widget.projectName!;
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                              builder: (_) {
                                                return MasonryStructure(
                                                  projectId: projectId,
                                                  towarId: widget.towarId!,
                                                  projectName: projectName,
                                                  towarName: widget.towarName!,
                                                );
                                              },
                                            )).then((value) {
                                              fetchProjectWorkProgressList();
                                            });
                                          } else if (responseData!
                                                  .projectStructure?[index]
                                                  .title! ==
                                              "Profit & Loss") {
                                            var projectId = widget.projectId!;
                                            var projectName =
                                                widget.projectName!;

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) {
                                                  return ProfitAndLoss(
                                                    projectId: projectId,
                                                    towarId: widget.towarId!,
                                                    projectName: projectName,
                                                    towarName:
                                                        widget.towarName!,
                                                  );
                                                },
                                              ),
                                            );
                                          } else if (responseData!
                                                      .projectStructure?[index]
                                                      .title! ==
                                                  "Request Purchase Order" &&
                                              responseData!.projectStructure?[index].isSetupDone ==
                                                  "1") {
                                            RequestPurchaseOrderNavigate();
                                            var projectId = widget.projectId!;
                                            var projectName =
                                                widget.projectName!;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) {
                                                  return RequestPurchaseOrderView(
                                                    projectId: projectId,
                                                    towarId: (_resolvedTowerId != null &&
                                                            _resolvedTowerId!.isNotEmpty)
                                                        ? _resolvedTowerId!
                                                        : ((widget.towarId != null &&
                                                                widget.towarId!.isNotEmpty)
                                                            ? widget.towarId!
                                                            : ''),
                                                    projectName: projectName,
                                                    towarName: (_resolvedTowerName != null &&
                                                            _resolvedTowerName!.isNotEmpty)
                                                        ? _resolvedTowerName!
                                                        : ((widget.towarName != null &&
                                                                widget.towarName!.isNotEmpty)
                                                            ? widget.towarName!
                                                            : ''),
                                                    consultantMagicLink: widget
                                                        .consultantMagicLink,
                                                    contractorMagicLink: widget
                                                        .contractorMagicLink,
                                                    vendMagicLink:
                                                        widget.vendMagicLink,
                                                  );
                                                },
                                              ),
                                            );
                                          } else if (responseData!
                                                      .projectStructure?[index]
                                                      .title! ==
                                                  "Request Work Order" &&
                                              responseData!.projectStructure?[index].isSetupDone ==
                                                  "1") {
                                            RequestPurchaseOrderNavigate();
                                            var projectId = widget.projectId!;
                                            var projectName =
                                                widget.projectName!;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) {
                                                  return WorkOrderWidget(
                                                    projectId: projectId,
                                                    towarId: widget.towarId!,
                                                    projectName: projectName,
                                                    towarName:
                                                        widget.towarName!,
                                                    consultantMagicLink: widget
                                                        .consultantMagicLink,
                                                    contractorMagicLink: widget
                                                        .contractorMagicLink,
                                                    vendMagicLink:
                                                        widget.vendMagicLink,
                                                  );
                                                },
                                              ),
                                            );
                                          } else if (responseData!
                                                      .projectStructure?[index]
                                                      .title! ==
                                                  "Account Management"
                                              // &&
                                              //     responseData!.projectStructure?[index].isSetupDone ==
                                              //         "1"
                                              ) {
                                            RequestPurchaseOrderNavigate();
                                            var projectId = widget.projectId!;
                                            var projectName =
                                                widget.projectName!;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) {
                                                  return AccountManagementView(
                                                      projectId: projectId,
                                                      towarId:
                                                          widget.towarId ?? '',
                                                      projectName: projectName,
                                                      towarName:
                                                          widget.towarName ??
                                                              '',
                                                      navigationFlag:
                                                          'Project');
                                                },
                                              ),
                                            );
                                          } else if (responseData!
                                                      .projectStructure?[index]
                                                      .title! ==
                                                  "My Contracts"
                                              // &&
                                              //     responseData!.projectStructure?[index].isSetupDone ==
                                              //         "1"
                                              ) {
                                            RequestPurchaseOrderNavigate();
                                            var projectId =
                                                widget.projectId ?? '';
                                            var projectName =
                                                widget.projectName ?? '';
                                            if (responseData!
                                                    .projectStructure?[index]
                                                    .groupFlag ==
                                                '1') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) {
                                                    return MycontractListView(
                                                        projectId: projectId,
                                                        towarId:
                                                            widget.towarId!,
                                                        projectName:
                                                            projectName,
                                                        towarName:
                                                            widget.towarName!,
                                                        navigationFlag:
                                                            'Project');
                                                  },
                                                ),
                                              );
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) {
                                                    return MyContractsView(
                                                        categoryId: '',
                                                        developerId: '',
                                                        projectId: projectId,
                                                        towarId:
                                                            widget.towarId!,
                                                        projectName:
                                                            projectName,
                                                        towarName:
                                                            widget.towarName!,
                                                        navigationFlag:
                                                            'Project');
                                                  },
                                                ),
                                              );
                                            }
                                          } else if (responseData!
                                                      .projectStructure?[index]
                                                      .title! ==
                                                  "Status of Supplies"
                                              // &&
                                              // responseData!.projectStructure?[index].isSetupDone ==
                                              //     "1"
                                              ) {
                                            RequestPurchaseOrderNavigate();
                                            var projectId = widget.projectId!;
                                            var projectName =
                                                widget.projectName!;
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (_) {
                                            //       return StatusOfSupplyView(
                                            //           projectId: projectId,
                                            //           towarId: widget.towarId ?? '',
                                            //           projectName: projectName,
                                            //           towarName: widget.towarName ?? '',
                                            //           navigationFlag: 'Project');
                                            //     },
                                            //   ),
                                            // );
                                            Navigator.of(context).pushNamed(
                                              '/statusOfSupplyViewScreen',
                                              arguments: NotificationArgs(
                                                projectId: projectId,
                                                projectName: projectName,
                                                towarName: widget.towarName,
                                                response:
                                                    NotificationResponseData(
                                                  navigationFlag: 'Project',
                                                  towarId: widget.towarId,
                                                  // assignToId: assignToId ?? '',
                                                ),
                                              ),
                                            );
                                          } else if (responseData!.projectStructure?[index].title! == "Permissions" &&
                                              responseData!.projectStructure?[index].isSetupDone ==
                                                  "1") {
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (_) {
                                            //       return Permissions(
                                            //         projectId: widget.projectId,
                                            //         towarId: widget.towarId,
                                            //         projectName: widget.projectName,
                                            //         towarName: widget.towarName,
                                            //       );
                                            //     },
                                            //   ),
                                            // );
                                            Navigator.of(context)
                                                .pushNamed(
                                              '/permissions',
                                              arguments: NotificationArgs(
                                                projectId: widget.projectId,
                                                // towarId: widget.towarId,
                                                projectName: widget.projectName,
                                                towarName: widget.towarName,

                                                // towarName: widget.towarName,
                                                response:
                                                    NotificationResponseData(
                                                  towarId: widget.towarId,
                                                ),
                                              ),
                                            )
                                                .then((_) {
                                              fetchProjectWorkProgressList();
                                            });
                                          } else if (responseData!.projectStructure?[index].title! == "Permissions" &&
                                              responseData!.projectStructure?[index].isSetupDone != "1") {
                                            showDialog<void>(
                                                barrierDismissible: true,
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    titlePadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 10,
                                                            horizontal: 20),
                                                    actionsPadding:
                                                        const EdgeInsets.only(
                                                            bottom: 10,
                                                            left: 10,
                                                            right: 10),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 16),
                                                    actionsAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    title: const Text(
                                                      "Please setup Permissions section in backend.",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    actions: [
                                                      InkWell(
                                                        onTap: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Container(
                                                          width: 250,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 4),
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.black,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          7)),
                                                          child: const Text(
                                                            "OK",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                });
                                          } else if (responseData!.projectStructure?[index].title! == "Budget"
                                              // &&
                                              //     responseData!.projectStructure?[index].isActive ==
                                              //         '1'
                                              ) {
                                            RequestPurchaseOrderNavigate();
                                            var projectId = widget.projectId!;
                                            var projectName =
                                                widget.projectName!;
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (_) {
                                            //       return BudgetScreen(
                                            //         projectId: projectId,
                                            //         projectName: projectName,
                                            //         towarId: widget.towarId,
                                            //         towarName: widget.towarName!,
                                            //       );
                                            //     },
                                            //   ),
                                            // );
                                            Navigator.of(context).pushNamed(
                                              '/budgetScreen',
                                              arguments: NotificationArgs(
                                                projectId: widget.projectId,
                                                // towarId: widget.towarId,
                                                projectName: widget.projectName,
                                                towarName: widget.towarName,

                                                // towarName: widget.towarName,
                                                response:
                                                    NotificationResponseData(
                                                  towarId: widget.towarId,
                                                ),
                                              ),
                                            );
                                          } else if (responseData!.projectStructure?[index].title! == "Plans and Elevation"
                                              //     &&
                                              // responseData!.projectStructure?[index].isSetupDone ==
                                              //     "1"
                                              ) {
                                            RequestPurchaseOrderNavigate();
                                            var projectId = widget.projectId!;
                                            var projectName =
                                                widget.projectName!;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) {
                                                  return PlansAndElevation(
                                                      projectId: projectId,
                                                      towarId: widget.towarId!,
                                                      towarName:
                                                          widget.towarName!,
                                                      projectName: projectName);
                                                },
                                              ),
                                            );
                                          } else if (responseData!.projectStructure?[index].title! == "Sales Management" && responseData!.projectStructure?[index].isSetupDone == "1") {
                                            RequestPurchaseOrderNavigate();
                                            var projectId = widget.projectId!;
                                            var projectName =
                                                widget.projectName!;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) {
                                                  return SalesManagementView(
                                                      projectId: projectId,
                                                      towarId: widget.towarId!,
                                                      projectName: projectName,
                                                      towarName:
                                                          widget.towarName!,
                                                      navigationFlag:
                                                          'Project');
                                                },
                                              ),
                                            );
                                          } else if (responseData!.projectStructure?[index].title! == "Permissions" && responseData!.projectStructure?[index].isSetupDone == "1") {
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (_) {
                                            //       return Permissions(
                                            //         projectId: widget.projectId,
                                            //         towarId: widget.towarId,
                                            //         projectName: widget.projectName,
                                            //         towarName: widget.towarName,
                                            //       );
                                            //     },
                                            //   ),
                                            // );
                                            Navigator.of(context)
                                                .pushNamed(
                                              '/permissions',
                                              arguments: NotificationArgs(
                                                projectId: widget.projectId,
                                                // towarId: widget.towarId,
                                                projectName: widget.projectName,
                                                towarName: widget.towarName,

                                                // towarName: widget.towarName,
                                                response:
                                                    NotificationResponseData(
                                                  towarId: widget.towarId,
                                                ),
                                              ),
                                            )
                                                .then((_) {
                                              fetchProjectWorkProgressList();
                                            });
                                          } else if (responseData!.projectStructure?[index].title! == "Legal" && responseData!.projectStructure?[index].isSetupDone == "1") {
                                            var projectId = widget.projectId!;
                                            var projectName =
                                                widget.projectName!;
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (_) {
                                            //       return LegalScreen(
                                            //         projectId: projectId,
                                            //         towarId: widget.towarId!,
                                            //         projectName: projectName,
                                            //         towarName: widget.towarName!,
                                            //       );
                                            //     },
                                            //   ),
                                            // );
                                            Navigator.of(context).pushNamed(
                                              '/legal',
                                              arguments: NotificationArgs(
                                                projectId: widget.projectId,
                                                // towarId: widget.towarId,
                                                projectName: widget.projectName,
                                                towarName: widget.towarName,

                                                // towarName: widget.towarName,
                                                response:
                                                    NotificationResponseData(
                                                  towarId: widget.towarId,
                                                ),
                                              ),
                                            );
                                          } else if (responseData!.projectStructure?[index].title! == "S.O.P"
                                              // &&
                                              // responseData!.projectStructure?[index].isSetupDone == "1"
                                              ) {
                                            var projectId = widget.projectId!;
                                            var projectName =
                                                widget.projectName!;
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (_) {
                                            //       return SopScreen(
                                            //         projectId: projectId,
                                            //         towarId: widget.towarId!,
                                            //         projectName: projectName,
                                            //         towarName: widget.towarName!,
                                            //       );
                                            //     },
                                            //   ),
                                            // );
                                            Navigator.of(context).pushNamed(
                                              '/sopScreen',
                                              arguments: NotificationArgs(
                                                projectId: widget.projectId,
                                                // towarId: widget.towarId,
                                                projectName: widget.projectName,
                                                // towarName: widget.towarName,
                                                towarName: widget.towarName,

                                                response:
                                                    NotificationResponseData(
                                                  towarId: widget.towarId,
                                                  // assignToId: assignToId ?? '',
                                                ),
                                              ),
                                            );
                                          } else if (responseData!.projectStructure?[index].title! == "Tenant Management"
                                              // &&
                                              //     responseData!.projectStructure?[index].isSetupDone ==
                                              //         "1"
                                              ) {
                                            var projectId = widget.projectId!;
                                            var projectName =
                                                widget.projectName!;
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (_) {
                                            //       return TenantManagementList(
                                            //         projectId: projectId,
                                            //         towarId: widget.towarId!,
                                            //         projectName: projectName,
                                            //         towarName: widget.towarName!,
                                            //       );
                                            //     },
                                            //   ),
                                            // );
                                            Navigator.of(context).pushNamed(
                                              '/tenantManagementScreen',
                                              arguments: NotificationArgs(
                                                projectId: projectId,
                                                projectName: widget.projectName,
                                                towarName: widget.towarName,
                                                response:
                                                    NotificationResponseData(
                                                  towarId: widget.towarId,
                                                ),
                                              ),
                                            );
                                          } else if (responseData!.projectStructure?[index].title! == "Task Manager"
                                              //  &&
                                              //     responseData!.projectStructure?[index].isSetupDone == "1"
                                              ) {
                                            var projectId = widget.projectId!;
                                            var projectName =
                                                widget.projectName!;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) {
                                                  return TaskCountScreen(
                                                    projectId: projectId,
                                                    towarId: widget.towarId!,
                                                    projectName: projectName,
                                                    towarName:
                                                        widget.towarName!,
                                                  );
                                                  // return TaskManagerScreen(
                                                  //   projectId: projectId,
                                                  //   towarId: widget.towarId!,
                                                  //   projectName: projectName,
                                                  //   towarName: widget.towarName!,
                                                  // );
                                                },
                                              ),
                                            );
                                          } else if (responseData!.projectStructure?[index].title! == "CMS"
                                              // &&
                                              //     responseData!.projectStructure?[index].isSetupDone == "1"
                                              ) {
                                            /*var projectId = widget.projectId!;
                                        var projectName = widget.projectName!;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) {
                                              return TenantManagementList(
                                                projectId: projectId,
                                                towarId: widget.towarId!,
                                                projectName: projectName,
                                                towarName: widget.towarName!,
                                              );
                                            },
                                          ),
                                        );*/
                                            ref.read(homeProvider).clearData();
                                            var projectId = widget.projectId!;
                                            var towarId = widget.towarId!;
                                            ref
                                                .read(fetchApiProvider)
                                                .openDropDown
                                                .clear();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) {
                                                  return ScheduleView(
                                                    projectName:
                                                        widget.projectName ??
                                                            '',
                                                    projectId: projectId,
                                                    towarId: towarId,
                                                    towarName: widget.towarName,
                                                    isSetupDone: responseData!
                                                                .projectStructure?[
                                                                    index]
                                                                .isSetupDone ==
                                                            "0"
                                                        ? true
                                                        : false,
                                                  );
                                                },
                                              ),
                                            ).then((value) {
                                              ref
                                                  .read(fetchApiProvider)
                                                  .arrWidget
                                                  .clear();
                                              ref
                                                  .read(fetchApiProvider)
                                                  .openDropDown
                                                  .clear();
                                              fetchProjectWorkProgressList();
                                            });
                                          } else if (responseData!.projectStructure?[index].title! == "Finishings" && responseData!.projectStructure?[index].isSetupDone == "1") {
                                            var projectId = widget.projectId!;
                                            var projectName =
                                                widget.projectName!;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) {
                                                  return
                                                      //  FinishingInteriorNew
                                                      FinishingManagement(
                                                    projectId: projectId,
                                                    towarId: widget.towarId!,
                                                    projectName: projectName,
                                                    towarName:
                                                        widget.towarName!,
                                                  );
                                                },
                                              ),
                                            );
                                          } else {
                                            showDialog<void>(
                                                barrierDismissible: true,
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8), // Set radius to zero
                                                    ),
                                                    titlePadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 10,
                                                            horizontal: 20),
                                                    actionsPadding:
                                                        const EdgeInsets.only(
                                                            bottom: 10,
                                                            left: 10,
                                                            right: 10),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 16),
                                                    actionsAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    title: Text(
                                                      responseData!
                                                                  .projectStructure?[
                                                                      index]
                                                                  .title ==
                                                              'Finishings'
                                                          ? "Please Setup Sales Inventory In Backend"
                                                          : "Please Setup ${responseData!.projectStructure?[index].title} In Backend",
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    actions: [
                                                      InkWell(
                                                        onTap: () {
                                                          // Navigator.of(context).pop();

                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Container(
                                                          width: 250,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 4),
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.black,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          7)),
                                                          child: const Text(
                                                            "Okay",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                });
                                          }
                                        },
                                        child: GridList(
                                          plist: responseData!
                                              .projectStructure![index],
                                          projectName: widget.projectName ?? '',
                                          towarName: (widget.towarName != null && widget.towarName!.isNotEmpty)
                                              ? widget.towarName!
                                              : (_resolvedTowerName ?? ''),
                                          projectId: widget.projectId,
                                          towarId: widget.towarId ?? _resolvedTowerId,
                                          callFun: () {
                                            fetchProjectWorkProgressList();
                                          },
                                        )),
                                  ),
                            ],
                          ),
                  ),

                  // FutureBuilder<List<ProjectStructure>?>(
                  //     future: fetchProjectWorkProgressList(),
                  //     builder: (BuildContext context, AsyncSnapshot snapshot) {
                  //       if (snapshot.hasData) {
                  //         if (kDebugMode) {
                  //           print("has data");
                  //         }
                  //         // setState(() {
                  //         //   responseData = snapshot;
                  //         // });
                  //         return Wrap(
                  //           direction: Axis.horizontal, // default
                  //           alignment: WrapAlignment.start, // default
                  //           children: List.generate(snapshot.data.length, (index) {
                  //             return Padding(
                  //               padding: const EdgeInsets.all(8.0),
                  //               child: Container(
                  //                 margin: const EdgeInsets.all(10),
                  //                 width: 180,
                  //                 height: 230,
                  //                 child: GestureDetector(
                  //                     onTap: () {
                  //                       if (snapshot.data[index].title! ==
                  //                           "R.C.C Structure") {
                  //                         RequestPurchaseOrderNavigate();
                  //                         var projectId = widget.projectId!;
                  //                         var projectName = widget.projectName!;
                  //                         Navigator.push(
                  //                           context,
                  //                           MaterialPageRoute(
                  //                             builder: (_) {
                  //                               return RccStructure(
                  //                                 projectId: projectId,
                  //                                 towarId: widget.towarId!,
                  //                                 projectName: projectName,
                  //                                 towarName: widget.towarName!,
                  //                               );
                  //                             },
                  //                           ),
                  //                         ).then((value) {
                  //                           fetchProjectWorkProgressList();
                  //                         });
                  //                       } else if (snapshot.data[index].title! ==
                  //                           "Masonry") {
                  //                         // RequestPurchaseOrderNavigate();
                  //                         var projectId = widget.projectId!;
                  //                         var projectName = widget.projectName!;
                  //                         Navigator.push(context, MaterialPageRoute(
                  //                           builder: (_) {
                  //                             return MasonryStructure(
                  //                               projectId: projectId,
                  //                               towarId: widget.towarId!,
                  //                               projectName: projectName,
                  //                               towarName: widget.towarName!,
                  //                             );
                  //                           },
                  //                         )).then((value) {
                  //                           fetchProjectWorkProgressList();
                  //                         });
                  //                       } else if (snapshot.data[index].title! ==
                  //                           "Request Purchase Order") {
                  //                         RequestPurchaseOrderNavigate();
                  //                         var projectId = widget.projectId!;
                  //                         var projectName = widget.projectName!;
                  //                         Navigator.push(
                  //                           context,
                  //                           MaterialPageRoute(
                  //                             builder: (_) {
                  //                               return RequestPurchaseOrderView(
                  //                                 projectId: projectId,
                  //                                 towarId: widget.towarId!,
                  //                                 projectName: projectName,
                  //                                 towarName: widget.towarName!,
                  //                               );
                  //                             },
                  //                           ),
                  //                         );
                  //                       } else if (snapshot.data[index].title! ==
                  //                           "Request Work Order") {
                  //                         RequestPurchaseOrderNavigate();
                  //                         var projectId = widget.projectId!;
                  //                         var projectName = widget.projectName!;
                  //                         Navigator.push(
                  //                           context,
                  //                           MaterialPageRoute(
                  //                             builder: (_) {
                  //                               return WorkOrderWidget(
                  //                                 projectId: projectId,
                  //                                 towarId: widget.towarId!,
                  //                                 projectName: projectName,
                  //                                 towarName: widget.towarName!,
                  //                               );
                  //                             },
                  //                           ),
                  //                         );
                  //                       } else if (snapshot.data[index].title! ==
                  //                           "Account Management") {
                  //                         RequestPurchaseOrderNavigate();
                  //                         var projectId = widget.projectId!;
                  //                         var projectName = widget.projectName!;
                  //                         Navigator.push(
                  //                           context,
                  //                           MaterialPageRoute(
                  //                             builder: (_) {
                  //                               return AccountManagementView(
                  //                                   projectId: projectId,
                  //                                   towarId: widget.towarId!,
                  //                                   projectName: projectName,
                  //                                   towarName: widget.towarName!,
                  //                                   navigationFlag: 'Project');
                  //                             },
                  //                           ),
                  //                         );
                  //                       } else if (snapshot.data[index].title! ==
                  //                           "My Contracts") {
                  //                         RequestPurchaseOrderNavigate();
                  //                         var projectId = widget.projectId!;
                  //                         var projectName = widget.projectName!;
                  //                         Navigator.push(
                  //                           context,
                  //                           MaterialPageRoute(
                  //                             builder: (_) {
                  //                               return MyContractsView(
                  //                                   projectId: projectId,
                  //                                   towarId: widget.towarId!,
                  //                                   projectName: projectName,
                  //                                   towarName: widget.towarName!,
                  //                                   navigationFlag: 'Project');
                  //                             },
                  //                           ),
                  //                         );
                  //                       } else if (snapshot.data[index].title! ==
                  //                           "Status of Supplies") {
                  //                         RequestPurchaseOrderNavigate();
                  //                         var projectId = widget.projectId!;
                  //                         var projectName = widget.projectName!;
                  //                         Navigator.push(
                  //                           context,
                  //                           MaterialPageRoute(
                  //                             builder: (_) {
                  //                               return StatusOfSupplyView(
                  //                                   projectId: projectId,
                  //                                   towarId: widget.towarId!,
                  //                                   projectName: projectName,
                  //                                   towarName: widget.towarName!,
                  //                                   navigationFlag: 'Project');
                  //                             },
                  //                           ),
                  //                         );
                  //                       } else if (snapshot.data[index].title! ==
                  //                           "Budget") {
                  //                         RequestPurchaseOrderNavigate();
                  //                         var projectId = widget.projectId!;
                  //                         var projectName = widget.projectName!;
                  //                         Navigator.push(
                  //                           context,
                  //                           MaterialPageRoute(
                  //                             builder: (_) {
                  //                               return BudgetScreen(
                  //                                 projectId: projectId,
                  //                                 projectName: projectName,
                  //                                 towarId: widget.towarId,
                  //                                 towarName: widget.towarName!,
                  //                               );
                  //                             },
                  //                           ),
                  //                         );
                  //                       } else if (snapshot.data[index].title! ==
                  //                           "Plans and Elevation") {
                  //                         RequestPurchaseOrderNavigate();
                  //                         var projectId = widget.projectId!;
                  //                         var projectName = widget.projectName!;
                  //                         Navigator.push(
                  //                           context,
                  //                           MaterialPageRoute(
                  //                             builder: (_) {
                  //                               return PlansAndElevation(
                  //                                   projectId: projectId,
                  //                                   towarId: widget.towarId!,
                  //                                   towarName: widget.towarName!,
                  //                                   projectName: projectName);
                  //                             },
                  //                           ),
                  //                         );
                  //                       } else if (snapshot.data[index].title! ==
                  //                           "Sales Management") {
                  //                         RequestPurchaseOrderNavigate();
                  //                         var projectId = widget.projectId!;
                  //                         var projectName = widget.projectName!;
                  //                         Navigator.push(
                  //                           context,
                  //                           MaterialPageRoute(
                  //                             builder: (_) {
                  //                               return SalesManagementView(
                  //                                   projectId: projectId,
                  //                                   towarId: widget.towarId!,
                  //                                   projectName: projectName,
                  //                                   towarName: widget.towarName!,
                  //                                   navigationFlag: 'Project');
                  //                             },
                  //                           ),
                  //                         );
                  //                       } else if (snapshot.data[index].title! ==
                  //                           "Permissions") {
                  //                         var projectId = widget.projectId!;
                  //                         var projectName = widget.projectName!;
                  //                         Navigator.push(
                  //                           context,
                  //                           MaterialPageRoute(
                  //                             builder: (_) {
                  //                               return Permissions(
                  //                                 projectId: widget.projectId,
                  //                                 towarId: widget.towarId,
                  //                                 projectName: widget.projectName,
                  //                                 towarName: widget.towarName,
                  //                               );
                  //                             },
                  //                           ),
                  //                         );
                  //                       } else if (snapshot.data[index].title! ==
                  //                           "Legal") {
                  //                         var projectId = widget.projectId!;
                  //                         var projectName = widget.projectName!;
                  //                         Navigator.push(
                  //                           context,
                  //                           MaterialPageRoute(
                  //                             builder: (_) {
                  //                               return LegalScreen(
                  //                                 projectId: projectId,
                  //                                 towarId: widget.towarId!,
                  //                                 projectName: projectName,
                  //                                 towarName: widget.towarName!,
                  //                               );
                  //                             },
                  //                           ),
                  //                         );
                  //                       } else if (snapshot.data[index].title! ==
                  //                           "Tenant Management") {
                  //                         var projectId = widget.projectId!;
                  //                         var projectName = widget.projectName!;
                  //                         Navigator.push(
                  //                           context,
                  //                           MaterialPageRoute(
                  //                             builder: (_) {
                  //                               return TenantManagementList(
                  //                                 projectId: projectId,
                  //                                 towarId: widget.towarId!,
                  //                                 projectName: projectName,
                  //                                 towarName: widget.towarName!,
                  //                               );
                  //                             },
                  //                           ),
                  //                         );
                  //                       } else if (snapshot.data[index].title! ==
                  //                           "CMS") {
                  //                         /*var projectId = widget.projectId!;
                  //                         var projectName = widget.projectName!;
                  //                         Navigator.push(
                  //                           context,
                  //                           MaterialPageRoute(
                  //                             builder: (_) {
                  //                               return TenantManagementList(
                  //                                 projectId: projectId,
                  //                                 towarId: widget.towarId!,
                  //                                 projectName: projectName,
                  //                                 towarName: widget.towarName!,
                  //                               );
                  //                             },
                  //                           ),
                  //                         );*/
                  //                         ref.read(homeProvider).clearData();
                  //                         print(
                  //                             "isSetupDone *********** ${snapshot.data[index].isSetupDone}");

                  //                         var projectId = widget.projectId!;
                  //                         var towarId = widget.towarId!;
                  //                         ref
                  //                             .read(fetchApiProvider)
                  //                             .openDropDown
                  //                             .clear();
                  //                         Navigator.push(
                  //                           context,
                  //                           MaterialPageRoute(
                  //                             builder: (_) {
                  //                               return ScheduleView(
                  //                                 projectName:
                  //                                     widget.projectName ?? '',
                  //                                 projectId: projectId,
                  //                                 towarId: towarId,
                  //                                 towarName: widget.towarName,
                  //                                 isSetupDone: snapshot.data[index]
                  //                                             .isSetupDone ==
                  //                                         "0"
                  //                                     ? true
                  //                                     : false,
                  //                               );
                  //                             },
                  //                           ),
                  //                         ).then((value) {
                  //                           ref
                  //                               .read(fetchApiProvider)
                  //                               .arrWidget
                  //                               .clear();
                  //                           ref
                  //                               .read(fetchApiProvider)
                  //                               .openDropDown
                  //                               .clear();
                  //                           fetchProjectWorkProgressList();
                  //                         });
                  //                       }
                  //                     },
                  //                     child: GridList(
                  //                       plist: snapshot.data[index],
                  //                       projectName: widget.projectName ?? '',
                  //                       towarName: widget.towarName ?? '',
                  //                       callFun: () {
                  //                         fetchProjectWorkProgressList();
                  //                       },
                  //                     )),
                  //               ),
                  //             );
                  //           }),
                  //         );
                  //       } else {
                  //         return SizedBox(
                  //             height: MediaQuery.of(context).size.height -
                  //                 AppBar().preferredSize.height -
                  //                 MediaQuery.of(context).padding.top -
                  //                 MediaQuery.of(context).padding.bottom -
                  //                 40,
                  //             width: MediaQuery.of(context).size.width,
                  //             child:
                  //                 const Center(child: CircularProgressIndicator()));
                  //       }
                  //     }),
                ],
              ),
            )
          : _buildModuleListSkeleton(isMobile, itemWidth),
    );
  }

  /// Skeleton loader matching the module grid card layout
  Widget _buildModuleListSkeleton(bool isMobile, double itemWidth) {
    return CustomLoading.wrapWithHorseLoader(
      SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            // "WORK PROGRESS" header skeleton
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 50),
                  const Expanded(
                    child: Text('WORK PROGRESS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 30.0),
                    child: Shimmer.fromColors(
                      baseColor: const Color(0xFFF0F0F0),
                      highlightColor: const Color(0xFFF9F9F9),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 1,
              child: Divider(color: Colors.black),
            ),
            // Module cards skeleton
            Shimmer.fromColors(
              baseColor: const Color(0xFFF0F0F0),
              highlightColor: const Color(0xFFF9F9F9),
              period: const Duration(milliseconds: 1500),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: itemWidth,
                      height: isMobile ? 185 : 215,
                      child: Card(
                        color: Colors.transparent,
                        elevation: 0.0,
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 2.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Icon placeholder (circle)
                                Container(
                                  width: isMobile ? 80 : 100,
                                  height: isMobile ? 80 : 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Title placeholder
                                Container(
                                  width: itemWidth * 0.6,
                                  height: 13,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Description placeholder
                                Container(
                                  width: itemWidth * 0.8,
                                  height: 11,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Status placeholder
                                Container(
                                  width: itemWidth * 0.5,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void RequestPurchaseOrderNavigate() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('flagRedirectToWorkProgress', 'false');
  }
}

class GridList extends StatefulWidget {
  const GridList({
    Key? key,
    required this.plist,
    required this.projectName,
    required this.callFun,
    required this.towarName,
    this.projectId,
    this.towarId,
  }) : super(key: key);
  final ProjectStructure plist;
  final String projectName;
  final String towarName;
  final Function callFun;
  final String? projectId;
  final String? towarId;
  @override
  _GridListState createState() => _GridListState();
}

class _GridListState extends State<GridList> {
  Color getProgressColor(String? title, String? completeStr) {
    if (title == 'Permissions' || title == 'R.C.C Structure') {
      final double percent = double.tryParse(completeStr ?? '0') ?? 0.0;
      if (percent == 0.0) return Colors.grey;
      if (percent < 30.0) return Colors.red;
      if (percent < 75.0) return Colors.yellow;
      if (percent <= 100.0) return Colors.green;
      return Colors.green;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;
    return Card(
        color: Colors.transparent,
        elevation: 0.0,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Stack(
                  children: [
                    Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                            width: isMobile ? 76.0 : 98.0,
                            height: isMobile ? 76.0 : 98.0,
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                Colors.black.withAlpha(26),
                                BlendMode.srcATop,
                              ),
                              child: getWidget(),
                            ))),
                    if (widget.plist.title == 'R.C.C Structure' ||
                        widget.plist.title == 'Masonry' ||
                        widget.plist.title == 'Permissions')
                      Align(
                        alignment: Alignment.topRight,
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              backgroundColor: Colors.grey,
                              color: getProgressColor(
                                  widget.plist.title, widget.plist.complete),
                              strokeWidth: 4,
                              value:
                                  ((double.tryParse(widget.plist.complete ?? '0') ?? 0.0) /
                                      100).clamp(0.0, 1.0)),
                        ),
                      ),
                    if (widget.plist.title == 'R.C.C Structure' ||
                        widget.plist.title == 'Masonry' ||
                        widget.plist.title == 'Permissions')
                      Align(
                        alignment: Alignment.topRight,
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: Center(
                            child: Text(
                                (double.tryParse(widget.plist.complete ?? '0') ?? 0.0)
                                    .toStringAsFixed(0),
                                style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3.0),
                SizedBox(
                  height: 20.0,
                  child: Center(child: getTitle()),
                ),
                const SizedBox(height: 3.0),
                SizedBox(
                  height: 38.0,
                  child: Center(
                    child: Text(
                        widget.plist.title == "Task Manager"
                            ? "Track & Update Daily Task & Create Meetings"
                            : (widget.plist.title == "Plans and Elevation"
                                ? "Design Plan for Project or Appartment"
                                : (widget.plist.discription ?? '')),
                        style: normalText12.copyWith(height: 1.25),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center),
                  ),
                ),
                const SizedBox(height: 4.0),
                SizedBox(
                  height: 22.0,
                  child: Center(child: issueWidget()),
                ),
              ]),
        ));
  }

  Widget getTitle() {
    if (widget.plist.isSetupDone != "") {
      if (widget.plist.isSetupDone == "1") {
        return Center(
            child: Text(
          widget.plist.title ?? '',
          style: boldText13,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ));
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                widget.plist.title ?? '',
                style: boldText13,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              (widget.plist.title == "Permissions" || widget.plist.title == "Legal") ? Icons.error : Icons.info,
              color: Color.lerp(Colors.orange, Colors.black, 0.10),
              size: 18.7,
            ),
          ],
        );
      }
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              widget.plist.title ?? '',
              style: boldText13,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            (widget.plist.title == "Permissions" || widget.plist.title == "Legal") ? Icons.error : Icons.info,
            color: Color.lerp(Colors.orange, Colors.black, 0.10),
            size: 18.7,
          ),
        ],
      );
    }
  }

  Widget issueWidget() {
    if (widget.plist.issuse != null && widget.plist.issuse!.isNotEmpty) {
      if ((int.tryParse(widget.plist.issuse!) ?? 0) >= 1) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // var projectId = widget.projectId!;
            // var projectName = widget.projectName!;
            if (widget.plist.title != "Permissions") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return IssueReportedWorkProgress(
                      projectName: widget.projectName,
                      towarName: widget.towarName,
                      projectId: widget.projectId,
                      towarId: widget.towarId,
                      slabIssueReportData: widget.plist.issueDetails ?? [],
                    );
                  },
                ),
              ).then((value) => widget.callFun());
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 3.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.plist.title == "Permissions"
                    ? SizedBox(
                        width: 16.5,
                        height: 16.5,
                        child: CustomPaint(
                          painter: WarningTrianglePainter(),
                        ),
                      )
                    : Icon(
                        Icons.warning,
                        color: Color.lerp(Colors.red, Colors.black, 0.10),
                        size: 16.5,
                      ),
                const SizedBox(width: 4),
                Text(
                  '${widget.plist.issuse!} ${widget.plist.title == "Permissions" ? "Permissions Expired" : "Issues Reported"}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget getWidget() {
    if (widget.plist.title! == "R.C.C Structure") {
      return const Image(
          image: AssetImage('images/projectmanagement/icon1.png'));
    } else if (widget.plist.title! == "Masonry") {
      return const Image(
          image: AssetImage('images/projectmanagement/icon8.png'));
    } else if (widget.plist.title! == "Permissions") {
      return const Image(
          image: AssetImage('images/projectmanagement/icon2.png'));
    } else if (widget.plist.title! == "Plans and Elevation") {
      return const Image(
          image: AssetImage('images/projectmanagement/icon6.png'),
          color: Colors.black,
          colorBlendMode: BlendMode.srcIn);
    } else if (widget.plist.title! == "Status of Supplies") {
      return const Image(
          image: AssetImage('images/projectmanagement/icon25.png'));
    } else if (widget.plist.title! == "Account Management") {
      return const Image(
          image: AssetImage('images/projectmanagement/icon12.png'));
    } else if (widget.plist.title! == "Task Manager") {
      return const Image(
          image: AssetImage('images/projectmanagement/icon27.png'),
          color: Colors.black,
          colorBlendMode: BlendMode.srcIn);
    } else if (widget.plist.title! == "My Contracts") {
      return const Image(
          image: AssetImage('images/projectmanagement/icon32.png'));
    } else if (widget.plist.title! == "Request Purchase Order") {
      return const Image(
          image: AssetImage('images/projectmanagement/icon33.png'));
    } else if (widget.plist.title! == "Request Work Order") {
      return const Image(
          image: AssetImage('images/projectmanagement/icon35.png'));
    } else if (widget.plist.title! == "Sales Management") {
      return const Image(
          image: AssetImage('images/projectmanagement/icon38.png'));
    } else if (widget.plist.title! == "Accounts") {
      return const Image(
          image: AssetImage('images/projectmanagement/icon37.png')); //
    } else if (widget.plist.title! == "Budget") {
      return const Image(
          image: AssetImage('images/projectmanagement/scale.png'));
    } else if (widget.plist.title! == "Tenant Management") {
      return const Image(
          image: AssetImage('images/projectmanagement/tenant_icon.png'));
    } else if (widget.plist.title! == "CMS") {
      return const Image(
          image: AssetImage('images/projectmanagement/iconcms.png'));
    } else if (widget.plist.title! == "Legal") {
      return const Image(
          image: AssetImage('images/projectmanagement/legal_icon.png'));
    } else if (widget.plist.title! == "Profit & Loss") {
      return const Image(
          image: AssetImage('images/projectmanagement/legal_icon.png'));
    } else if (widget.plist.title! == "Finishings") {
      return const Image(
          image: AssetImage('images/projectmanagement/finishing_icon.png'));
    } else if (widget.plist.title! == "S.O.P") {
      return const Image(
          image: AssetImage('images/projectmanagement/sop_icon.png'));
    } else {
      return const Image(
          image: AssetImage('images/projectmanagement/icon4.png'));
    }
  }
}

class WarningTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Draw the outline triangle in red
    final paint = Paint()
      ..color = Color.lerp(Colors.red, Colors.black, 0.10)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(w / 2, 2.0)
      ..lineTo(w - 2.0, h - 2.0)
      ..lineTo(2.0, h - 2.0)
      ..close();

    canvas.drawPath(path, paint);

    // Draw the exclamation mark in black
    final excPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Exclamation line
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          w / 2 - 0.7,
          h * 0.35,
          w / 2 + 0.7,
          h * 0.65,
        ),
        const Radius.circular(0.5),
      ),
      excPaint,
    );

    // Exclamation dot
    canvas.drawCircle(Offset(w / 2, h * 0.78), 0.75, excPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
