import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_meeting_id.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/models/task_count_modal.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/permission/track_permission_list.dart';
import 'package:stallion/ui/views/rccstructure/task_rcc/task_list_screen.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/salesleadPage.dart';
import 'package:stallion/ui/views/task_manager/create_new_meeting.dart';
import 'package:stallion/ui/views/task_manager/meeting_detail_screen.dart';
import 'package:stallion/ui/views/task_manager/task_manager_mock_data.dart';
import 'package:stallion/ui/views/task_manager/task_manager_screen.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';

// Model for task items to replace the Map-based approach
class TaskItem {
  final String title;
  final String score;

  const TaskItem({required this.title, required this.score});
}

// TaskCountScreen Widget
class TaskCountScreen extends StatefulWidget {
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;

  const TaskCountScreen({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
  });

  @override
  State<TaskCountScreen> createState() => _TaskCountScreenState();
}

class _TaskCountScreenState extends State<TaskCountScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<TaskArr>? taskArr = [];
  String? assignToId = '';
  String? currentUserId = '';
  bool isMyTasks = true;
  int totalTasks = 0;
  int completedTasks = 0;
  int pendingTasks = 0;
  int extendedTasks = 0;
  List<MettingDatum>? mettingDataResponse = [];
  List<String>? filterData = [];
  bool _isLoading = false;

  String? currentUserName = '';

  String _formatDisplayDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    try {
      DateTime? dt = DateTime.tryParse(raw);
      if (dt != null) return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {}
    if (raw.contains('-')) {
      List<String> parts = raw.split('T')[0].split('-');
      if (parts.length == 3 && parts[0].length == 4) return '${parts[2]}/${parts[1]}/${parts[0]}';
    }
    return raw;
  }

  Future<void> _loadUserId() async {
    final prefs = await _prefs;
    String id = prefs.getString('userId') ?? '';
    String name = prefs.getString('userName') ?? '';
    if (id.isEmpty || name.isEmpty) {
      try {
        var meResponse = await apiNetworkHandler.get("${AppUrl.baseURL}auth/me");
        if (meResponse != null && (meResponse.statusCode == 200 || meResponse.statusCode == 201)) {
          final decodedMe = json.decode(meResponse.body);
          if (decodedMe['success'] == true && decodedMe['data'] != null) {
            id = decodedMe['data']['id']?.toString() ?? '';
            name = decodedMe['data']['name']?.toString() ?? '';
            if (id.isNotEmpty) {
              prefs.setString('userId', id);
            }
            if (name.isNotEmpty) {
              prefs.setString('userName', name);
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("TaskCountScreen: Error fetching me details: $e");
        }
      }
    }
    if (mounted) {
      setState(() {
        currentUserId = id.isNotEmpty ? id : (prefs.getString('mobileNo') ?? '');
        currentUserName = name.isNotEmpty ? name : (prefs.getString('userName') ?? '');
      });
    }
  }

  List<dynamic>? assignedModules = [];
  Map<String, dynamic>? moduleTilesData = {};
  bool _modulesLoaded = false;
  String? projectProfileId = '';

  Future<void> fetchAssignedModules() async {
    final towerId = widget.towarId;
    if (towerId == null || towerId.isEmpty) {
      setState(() {
        _modulesLoaded = true;
      });
      return;
    }

    try {
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        await apiNetworkHandler.ensureProjectContext(widget.projectId);
      }
      var response = await apiNetworkHandler.get(
        AppUrl.getTowerTaskDashboard(towerId),
      );
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          final data = decoded['data'];
          if (data is Map<String, dynamic>) {
            final metrics = data['metrics'];
            if (metrics is Map) {
              final tot = int.tryParse(metrics['total_task']?.toString() ?? '0') ?? (metrics['total_task'] as int? ?? 0);
              final comp = int.tryParse(metrics['completed']?.toString() ?? '0') ?? (metrics['completed'] as int? ?? 0);
              final pend = int.tryParse(metrics['pending']?.toString() ?? '0') ?? (metrics['pending'] as int? ?? 0);
              final ext = int.tryParse(metrics['ext_deadline']?.toString() ?? '0') ?? (metrics['ext_deadline'] as int? ?? 0);

              setState(() {
                totalTasks = tot;
                completedTasks = comp;
                pendingTasks = pend;
                extendedTasks = ext;
              });
            }

            final tiles = data['module_tiles'];
            if (tiles is Map<String, dynamic>) {
              if (kDebugMode) {
                print("TaskCountScreen: Loaded module_tiles from GET /tasks/tower/$towerId/dashboard: $tiles");
              }
              setState(() {
                moduleTilesData = tiles;
              });
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("TaskCountScreen: Error fetching tower task dashboard: $e");
      }
    } finally {
      setState(() {
        _modulesLoaded = true;
      });
    }
  }

  bool isModuleCardAssigned(String itemId, String? itemName) {
    if (assignedModules == null || assignedModules!.isEmpty) return false;

    for (var mod in assignedModules!) {
      if (mod is Map) {
        final String name = (mod['name'] ?? '').toString().toLowerCase();
        final String id = (mod['id'] ?? '').toString();

        if (itemId == '2') {
          // Daily Work Progress / Task RCC
          if (name.contains('rcc') || name.contains('task') || id == '8') return true;
        } else if (itemId == '3') {
          // PO Requested
          if (name.contains('purchase order') || name.contains('po') || id == '10') return true;
        } else if (itemId == '4') {
          // WO Requested
          if (name.contains('work order') || name.contains('wo') || id == '11') return true;
        } else if (itemId == '5') {
          // Sales Lead
          if (name.contains('sales') || id == '15') return true;
        } else if (itemId == '6') {
          // S.O.P
          if (name.contains('sop') || name.contains('s.o.p')) return true;
        } else if (itemId == '7') {
          // Permissions
          if (name.contains('permission') || id == '19') return true;
        }
      }
    }
    return false;
  }

  void calculateTaskStats() {
    if (taskArr != null) {
      totalTasks = taskArr!.fold(
          0, (sum, item) => sum + int.parse(item.details?.totalMyTask ?? '0'));
      completedTasks = taskArr!.fold(
          0, (sum, item) => sum + int.parse(item.details?.compMyTask ?? '0'));
      pendingTasks = taskArr!.fold(
          0, (sum, item) => sum + int.parse(item.details?.pendMyTask ?? '0'));

      extendedTasks = taskArr!.fold(
          0,
          (sum, item) =>
              sum + (int.tryParse(item.details?.extendedTask ?? '0') ?? 0));
    }
  }

  Future<List<dynamic>?> getUserMeetingsById() async {
    final towerId = widget.towarId;
    if (towerId == null || towerId.isEmpty) return null;

    if (TaskManagerMockData.useMockData) {
      setState(() {
        mettingDataResponse = TaskManagerMockData.getMockMeetings();
        taskArr = TaskManagerMockData.getMockTaskCountArray();
        calculateTaskStats();
        _isLoading = false;
      });
      return null;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (AppUrl.useNewBackend) {
        if (widget.projectId != null && widget.projectId!.isNotEmpty) {
          await apiNetworkHandler.ensureProjectContext(widget.projectId);
        }
        var response = await apiNetworkHandler.get(
          AppUrl.getTowerMeetings(towerId),
        );
        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic> && decoded['success'] == true) {
            final data = decoded['data'];
            if (data is Map<String, dynamic> && data['meetings'] is List) {
              final rawMeetings = data['meetings'] as List;
              List<MettingDatum> parsed = rawMeetings
                  .map((m) =>
                      MettingDatum.fromNewApiJson(m as Map<String, dynamic>))
                  .toList();
              setState(() {
                mettingDataResponse = parsed;
              });
            }
          }
        }
      } else {
        final SharedPreferences prefs = await _prefs;
        String? userId = prefs.getString('mobileNo');

        Map<String, String> data = {
          "user_id": userId ?? '',
          "project_id": widget.projectId ?? '',
          "towar_id": widget.towarId ?? '',
          "search_data": '',
        };

        if (kDebugMode) {
          print(data);
        }

        var response =
            await apiNetworkHandler.post(AppUrl.meetingByUserId, data);

        if (kDebugMode) {
          print(response.statusCode);
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          final dataModel = getUserMeetingByIdFromJson(response.body);

          if (dataModel.response?.errorCode == "0") {
            setState(() {
              mettingDataResponse = dataModel.response?.mettingData ?? [];
              if (filterData?.isEmpty == true) {
                filterData = dataModel.response?.filterData;
              }
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('TaskCountScreen: Exception fetching meetings: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    return null;
  }

  Future<List<dynamic>?> deleteMeetingById(
      {required String meetingId, required String taskId}) async {
    try {
      if (AppUrl.useNewBackend) {
        if (widget.projectId != null && widget.projectId!.isNotEmpty) {
          await apiNetworkHandler.ensureProjectContext(widget.projectId);
        }

        var response = await apiNetworkHandler.delete(
          AppUrl.deleteMeeting(meetingId),
        );

        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          if (!mounted) return null;
          showDialog<void>(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  titlePadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  actionsPadding:
                      const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  actionsAlignment: MainAxisAlignment.center,
                  title: const Text(
                    "Meeting Deleted Successfully.",
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
                        offset = '0';
                        getUserMeetingsById();
                        fetchAssignedModules();
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 250,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text(
                          "Okay",
                          style: TextStyle(
                            fontSize: 15,
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
      } else {
        final SharedPreferences prefs = await _prefs;
        String? userId = prefs.getString('mobileNo');

        Map<String, String> data = {
          "user_id": userId ?? '',
          "metting_id": meetingId,
          "task_id": taskId,
        };

        var response =
            await apiNetworkHandler.post(AppUrl.deleteMeetingById, data);

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (!mounted) return null;
          showDialog<void>(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  titlePadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  actionsPadding:
                      const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  actionsAlignment: MainAxisAlignment.center,
                  title: const Text(
                    "Task Deleted Successfully.",
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
                        offset = '0';
                        getUserMeetingsById();
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 250,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text(
                          "Okay",
                          style: TextStyle(
                            fontSize: 15,
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
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('TaskCountScreen: Exception deleting meeting: $e');
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadUserId();
    fetchAssignedModules();
  }

  // Helper method to build the app bar title
  String _buildAppBarTitle() {
    final projectName = widget.projectName?.toUpperCase() ?? '';
    final towarName = widget.towarName?.toUpperCase() ?? '';
    return towarName.isNotEmpty ? '$projectName - $towarName' : projectName;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _buildAppBarTitle(),
          style: const TextStyle(
            fontStyle: FontStyle.normal,
            fontSize: 17,
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomCapsuleButton(isMobile),
      body: _isLoading
          ? CustomLoading.buildTaskCountSkeletonInline(context)
          : Column(
        children: [
          const SizedBox(
            height: 38,
            child: Center(
              child: Text(
                'TASK MANAGER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'HelveticaNeue',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Divider(
            height: 1.0,
            color: Color(0xffdee2e6),
          ),
          // Animated Capsule View Switcher
          _buildCapsuleTabBar(isMobile),
          // Task Statistics Cards Bar (Visible on both My Task & My Meetings views)
          _buildTaskStatCards(isMobile),
          const SizedBox(height: 2),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isMyTasks
                  ? _buildTaskGrid(isMobile)
                  : Container(
                      key: const ValueKey("MyMeetingsViewContainer"),
                      width: double.infinity,
                      height: double.infinity,
                      color: const Color(0xfff8f9fa),
                      child: _mymeetings(isMobile),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Animated Capsule Tab Switcher (Decreased vertical padding)
  Widget _buildCapsuleTabBar(bool isMobile) {
    return Container(
      height: 42,
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 4),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xffe9ecef),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffdee2e6), width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final double halfWidth = (width - 4) / 2;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                left: isMyTasks ? 0 : halfWidth,
                top: 0,
                bottom: 0,
                width: halfWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (!isMyTasks) {
                          setState(() {
                            isMyTasks = true;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Center(
                        child: Text(
                          "MY TASK",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isMyTasks ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (isMyTasks) {
                          getUserMeetingsById();
                          setState(() {
                            isMyTasks = false;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Center(
                        child: Text(
                          "MY MEETINGS",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isMyTasks ? Colors.black87 : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // Floating Capsule Bottom Navigation Button (Fixed height 48, centered with max width)
  Widget _buildBottomCapsuleButton(bool isMobile) {
    return SafeArea(
      top: false,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? 250 : 400,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: InkWell(
              onTap: () {
                if (isMyTasks) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return TaskManagerScreen(
                          projectId: widget.projectId,
                          towarId: widget.towarId!,
                          projectName: widget.projectName,
                          towarName: widget.towarName!,
                        );
                      },
                    ),
                  ).then((val) {
                    fetchAssignedModules();
                    getUserMeetingsById();
                  });
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return CreateNewMeeting(
                          projectId: widget.projectId,
                          towarId: widget.towarId!,
                          projectName: widget.projectName,
                          towarName: widget.towarName!,
                        );
                      },
                    ),
                  ).then((value) {
                    fetchAssignedModules();
                    getUserMeetingsById();
                  });
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isMyTasks ? Icons.assignment_outlined : Icons.add_circle_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isMyTasks == true
                          ? (taskArr != null && taskArr!.isNotEmpty
                              ? "MY TASK (${taskArr?[0].details?.pendMyTask} / ${taskArr?[0].details?.totalMyTask})"
                              : 'MY TASK')
                          : "CREATE NEW MEETING",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Task Statistics Cards Bar (Black background with white/red text)
  Widget _buildTaskStatCards(bool isMobile) {
    final cards = [
      _buildStatCardItem(
        title: 'Total Task',
        count: totalTasks.toString(),
        titleColor: Colors.white,
        countColor: Colors.white,
        isMobile: isMobile,
      ),
      _buildStatCardItem(
        title: 'Completed',
        count: completedTasks.toString(),
        titleColor: Colors.white,
        countColor: Colors.white,
        isMobile: isMobile,
      ),
      _buildStatCardItem(
        title: 'Pending',
        count: pendingTasks.toString(),
        titleColor: Colors.white,
        countColor: Colors.white,
        isMobile: isMobile,
      ),
      _buildStatCardItem(
        title: 'Ext. Deadline',
        count: extendedTasks.toString(),
        titleColor: Colors.white,
        countColor: Colors.red,
        isMobile: isMobile,
      ),
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 40, vertical: 2),
      child: Row(
        children: cards
            .map((card) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 3 : 6),
                    child: card,
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildStatCardItem({
    required String title,
    required String count,
    Color titleColor = Colors.white,
    Color countColor = Colors.white,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 4 : 6,
        horizontal: isMobile ? 4 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isMobile ? 11 : 13,
              fontWeight: FontWeight.w400,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w700,
              color: countColor,
            ),
          )
        ],
      ),
    );
  }

  List<TaskArr> getTaskCardsFromAssignedModules() {
    List<TaskArr> cards = [];

    Details getDetails(dynamic tileData) {
      if (tileData is Map) {
        final comp = tileData['completed']?.toString() ?? '0';
        final tot = tileData['total']?.toString() ?? '0';
        final compInt = int.tryParse(comp) ?? 0;
        final totInt = int.tryParse(tot) ?? 0;
        final pendInt = (totInt - compInt) < 0 ? 0 : (totInt - compInt);
        return Details(
          totalMyTask: tot,
          compMyTask: comp,
          pendMyTask: pendInt.toString(),
          extendedTask: '0',
        );
      }
      return Details(totalMyTask: '0', compMyTask: '0', pendMyTask: '0', extendedTask: '0');
    }

    if (moduleTilesData != null && moduleTilesData!.isNotEmpty) {
      // Check RCC
      dynamic rccTile = moduleTilesData!['rcc'] ?? moduleTilesData!['RCC'];
      if (rccTile != null) {
        cards.add(TaskArr(id: '2', name: 'RCC', details: getDetails(rccTile)));
      }

      // Check Purchase Order
      dynamic poTile = moduleTilesData!['po'] ?? moduleTilesData!['purchase_order'] ?? moduleTilesData!['purchaseOrder'];
      if (poTile != null) {
        cards.add(TaskArr(id: '3', name: 'Purchase Order', details: getDetails(poTile)));
      }

      // Check Work Order
      dynamic woTile = moduleTilesData!['wo'] ?? moduleTilesData!['work_order'] ?? moduleTilesData!['workOrder'];
      if (woTile != null) {
        cards.add(TaskArr(id: '4', name: 'Work Order', details: getDetails(woTile)));
      }

      // Check Lead / Sales
      dynamic leadTile = moduleTilesData!['lead'] ?? moduleTilesData!['sales'] ?? moduleTilesData!['sales_lead'];
      if (leadTile != null) {
        cards.add(TaskArr(id: '5', name: 'Lead', details: getDetails(leadTile)));
      }

      // Check S.O.P (always included or if present in module_tiles)
      dynamic sopTile = moduleTilesData!['sop'] ?? moduleTilesData!['SOP'] ?? moduleTilesData!['s.o.p'];
      cards.add(TaskArr(id: '6', name: 'S.O.P', details: getDetails(sopTile)));

      // Check Permissions
      dynamic permTile = moduleTilesData!['permission'] ?? moduleTilesData!['permissions'] ?? moduleTilesData!['Permission'];
      if (permTile != null) {
        cards.add(TaskArr(id: '7', name: 'Permissions', details: getDetails(permTile)));
      }

      return cards;
    }

    // Fallback if moduleTilesData is empty (legacy fallback)
    if (assignedModules != null && assignedModules!.isNotEmpty) {
      bool hasRcc = false;
      bool hasPo = false;
      bool hasWo = false;
      bool hasSales = false;
      bool hasPermission = false;

      for (var mod in assignedModules!) {
        if (mod is Map) {
          final String name = (mod['name'] ?? '').toString().toLowerCase();
          final String id = (mod['id'] ?? '').toString();

          if (name.contains('rcc') || name.contains('task') || id == '8') hasRcc = true;
          if (name.contains('purchase order') || name.contains('po') || id == '10') hasPo = true;
          if (name.contains('work order') || name.contains('wo') || id == '11') hasWo = true;
          if (name.contains('sales') || id == '15') hasSales = true;
          if (name.contains('permission') || id == '19') hasPermission = true;
        }
      }

      if (hasRcc) cards.add(TaskArr(id: '2', name: 'RCC', details: Details(totalMyTask: '0', compMyTask: '0', pendMyTask: '0', extendedTask: '0')));
      if (hasPo) cards.add(TaskArr(id: '3', name: 'Purchase Order', details: Details(totalMyTask: '0', compMyTask: '0', pendMyTask: '0', extendedTask: '0')));
      if (hasWo) cards.add(TaskArr(id: '4', name: 'Work Order', details: Details(totalMyTask: '0', compMyTask: '0', pendMyTask: '0', extendedTask: '0')));
      if (hasSales) cards.add(TaskArr(id: '5', name: 'Lead', details: Details(totalMyTask: '0', compMyTask: '0', pendMyTask: '0', extendedTask: '0')));
      cards.add(TaskArr(id: '6', name: 'S.O.P', details: Details(totalMyTask: '0', compMyTask: '0', pendMyTask: '0', extendedTask: '0')));
      if (hasPermission) cards.add(TaskArr(id: '7', name: 'Permissions', details: Details(totalMyTask: '0', compMyTask: '0', pendMyTask: '0', extendedTask: '0')));
    }

    return cards;
  }



  // Task Grid for My Task View
  Widget _buildTaskGrid(bool isMobile) {
    if (!_modulesLoaded) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    final items = getTaskCardsFromAssignedModules();

    if (items.isEmpty) {
      return const Center(
        child: Text(
          "No Assigned Modules Available for this Project",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    return Container(
      key: const ValueKey("MyTaskGridContainer"),
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xfff8f9fa),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 40,
          vertical: 16,
        ),
        child: Center(
          child: Wrap(
            spacing: isMobile ? 12 : 20,
            runSpacing: isMobile ? 12 : 20,
            alignment: WrapAlignment.center,
            children: items
                .map((item) => DashboardCard(
                    item: item,
                    isMobile: isMobile,
                    onTap: () async {
                      if (item.id == '2') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              return TaskListScreen(
                                projectId: widget.projectId,
                                towarId: widget.towarId!,
                                projectName: widget.projectName,
                                towarName: widget.towarName!,
                                assignToId: assignToId ?? '',
                              );
                            },
                          ),
                        );
                      } else if (item.id == '3') {
                        Navigator.of(context).pushNamed(
                          '/poRequestedViewScreen',
                          arguments: NotificationArgs(
                            projectId:
                                widget.projectId! == '' ? "" : widget.projectId!,
                            projectName: widget.projectName! == ''
                                ? ""
                                : widget.projectName!,
                            towarName: widget.towarName,
                            response: NotificationResponseData(
                              assignToId: assignToId ?? '',
                              flagRedirect: 'Verified',
                              towarId: widget.towarId,
                            ),
                          ),
                        );
                      } else if (item.id == '4') {
                        Navigator.of(context).pushNamed(
                          '/woRequestedViewScreen',
                          arguments: NotificationArgs(
                            projectId: widget.projectId,
                            projectName: widget.projectName,
                            towarName: widget.towarName,
                            response: NotificationResponseData(
                              assignToId: assignToId ?? '',
                              flagRedirect: 'RequestedNew',
                              towarId: widget.towarId,
                            ),
                          ),
                        );
                      } else if (item.id == '5') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              return SalesLeadPage(
                                assignToId: assignToId ?? '',
                                projectId: widget.projectId,
                                towarId: widget.towarId,
                                projectName: widget.projectName,
                                navigationFlag: 'Project',
                                towarName: widget.towarName,
                              );
                            },
                          ),
                        );
                      } else if (item.id == '6') {
                        // S.O.P module (tower specific) - ensure project token first
                        if (widget.projectId != null && widget.projectId!.isNotEmpty) {
                          await apiNetworkHandler.ensureProjectContext(widget.projectId);
                        }
                        if (!mounted) return;
                        Navigator.of(context).pushNamed(
                          '/sopScreen',
                          arguments: NotificationArgs(
                            projectId: widget.projectId,
                            projectName: widget.projectName,
                            towarName: widget.towarName,
                            response: NotificationResponseData(
                              towarId: widget.towarId,
                              assignToId: assignToId ?? '',
                            ),
                          ),
                        );
                      } else if (item.id == '7') {
                        // Permissions module (project & profile specific) - ensure project token first
                        if (widget.projectId != null && widget.projectId!.isNotEmpty) {
                          await apiNetworkHandler.ensureProjectContext(widget.projectId);
                        }
                        if (!mounted) return;

                        final String effectiveProfileId =
                            (projectProfileId != null && projectProfileId!.isNotEmpty && projectProfileId != '0')
                                ? projectProfileId!
                                : (assignToId ?? '');

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              return TrackPermissionList(
                                projectId: widget.projectId,
                                towarId: widget.towarId,
                                projectName: widget.projectName,
                                towarName: widget.towarName,
                                assignToId: effectiveProfileId,
                                transEmpName: currentUserName ?? '',
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  // Meetings List for My Meetings View
  Widget _mymeetings(bool isMobile) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    if (mettingDataResponse == null || mettingDataResponse!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              "No meetings scheduled yet",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 8,
      ),
      shrinkWrap: true,
      itemCount: mettingDataResponse!.length,
      itemBuilder: (context, index) {
        MettingDatum temppp = mettingDataResponse![index];

        void showDeleteDialog() {
          showDialog<void>(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  titlePadding:
                      const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  actionsPadding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  actionsAlignment: MainAxisAlignment.center,
                  title: const Text(
                    "Delete Meeting",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  content: const Text(
                    "Are you sure you want to delete this meeting?",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text(
                              "No",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              deleteMeetingById(
                                  meetingId: temppp.mettingId ?? '',
                                  taskId: '');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text(
                              'Yes',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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

        return CardTileWrapper(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) {
                  return MeetingDetailsScreen(
                    projectId: widget.projectId,
                    towarId: widget.towarId!,
                    projectName: widget.projectName,
                    towarName: widget.towarName!,
                    mettingData: temppp,
                  );
                },
              ),
            ).then((value) {
              offset = '0';
              getUserMeetingsById();
              fetchAssignedModules();
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Meeting title (Left) | Tasks label (Right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      temppp.mettingTitle ?? '',
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Tasks',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Row 2: Date of creation (Left) | Count of completed/total tasks (Right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    (temppp.mettingCreate != null && temppp.mettingCreate!.isNotEmpty)
                        ? 'Date: ${_formatDisplayDate(temppp.mettingCreate)}'
                        : 'Date: N/A',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    temppp.taskcompleDetails ?? '',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Row 3: Participants (Left) | Delete button (Right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      (temppp.participants != null && temppp.participants!.isNotEmpty)
                          ? 'Participants: ${temppp.participants}'
                          : 'Participants: None',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: showDeleteDialog,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.delete_outlined,
                        color: Colors.grey.shade600,
                        size: isMobile ? 18 : 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 6),
    );
  }
}

// Reusable DashboardCard Widget with hover & tap shadow feedback
class DashboardCard extends StatefulWidget {
  final TaskArr item;
  final bool isMobile;
  final void Function() onTap;

  const DashboardCard({
    super.key,
    required this.item,
    required this.isMobile,
    required this.onTap,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double cardWidth = widget.isMobile
        ? (MediaQuery.of(context).size.width - 44) / 2
        : 240.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: _isHovered ? Matrix4.translationValues(0.0, -3.0, 0.0) : Matrix4.identity(),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: _isHovered ? 6 : 2,
          shadowColor: Colors.black.withOpacity(_isHovered ? 0.15 : 0.05),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.black12,
            highlightColor: Colors.black.withOpacity(0.04),
            child: Container(
              width: cardWidth,
              padding: EdgeInsets.symmetric(
                vertical: widget.isMobile ? 16 : 22,
                horizontal: 12,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHovered ? Colors.black.withOpacity(0.3) : const Color(0xffe9ecef),
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.item.name ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xfff8f9fa),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xffe9ecef)),
                    ),
                    child: Text(
                      '${widget.item.details?.compMyTask} / ${widget.item.details?.totalMyTask}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Card Wrapper for Meeting Tiles with tap & hover feedback
class CardTileWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const CardTileWrapper({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<CardTileWrapper> createState() => _CardTileWrapperState();
}

class _CardTileWrapperState extends State<CardTileWrapper> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: _isHovered ? Matrix4.translationValues(0.0, -2.0, 0.0) : Matrix4.identity(),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          elevation: _isHovered ? 4 : 1.5,
          shadowColor: Colors.black.withOpacity(_isHovered ? 0.12 : 0.04),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(14),
            splashColor: Colors.black12,
            highlightColor: Colors.black.withOpacity(0.04),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isHovered ? Colors.black.withOpacity(0.25) : const Color(0xffe9ecef),
                  width: 1.2,
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
