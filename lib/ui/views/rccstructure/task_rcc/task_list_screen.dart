import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stallion/models/rcc_dpr_activity_model.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/rccstructure/task_rcc/rcc_task_details.dart';
import 'package:stallion/ui/widgets/row_three_text.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    this.assignToId,
    this.slabId,
  });
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? assignToId;
  final String? slabId;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  bool isPending = true;
  List<RccDprActivity> _allActivities = [];
  bool isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  // Filter state
  Set<String> _selectedFilterSlabIds = {};
  List<SlabInfo> _availableSlabs = [];

  List<RccDprActivity> get _filteredActivities {
    return _allActivities.where((activity) {
      // Exclude tasks where slabId is null or empty or invalid
      if (!activity.hasValidSlab) {
        return false;
      }

      // 1. Pending vs Completed
      if (isPending && activity.isCompleted) return false;
      if (!isPending && !activity.isCompleted) return false;

      // 2. Slab filter (multi-select)
      if (_selectedFilterSlabIds.isNotEmpty) {
        final actSlabId = activity.slab?.id ?? activity.slabId;
        if (actSlabId == null || !_selectedFilterSlabIds.contains(actSlabId)) {
          return false;
        }
      }

      // 3. Search query
      final query = _searchController.text.trim().toLowerCase();
      if (query.isNotEmpty) {
        final titleMatch = activity.activityName.toLowerCase().contains(query);
        final slabMatch = (activity.slab?.name ?? '').toLowerCase().contains(query);
        if (!titleMatch && !slabMatch) return false;
      }

      return true;
    }).toList();
  }

  int get _pendingCount => _allActivities
      .where((a) => a.hasValidSlab && !a.isCompleted)
      .length;

  int get _completedCount => _allActivities
      .where((a) => a.hasValidSlab && a.isCompleted)
      .length;

  Future<void> fetchDprActivities({bool isRefresh = false}) async {
    if (!isRefresh && _allActivities.isEmpty) {
      setState(() => isLoading = true);
    }

    try {
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        await apiNetworkHandler.ensureProjectContext(widget.projectId);
      }

      final String towerId = widget.towarId ?? '';
      final String url = AppUrl.getDprActivities(towerId, slabId: widget.slabId);

      final response = await apiNetworkHandler.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          final dataModel = RccDprActivityResponse.fromJson(decoded);

          // Only keep activities with valid non-null slab_id
          final validActivities = dataModel.data
              .where((act) => act.hasValidSlab)
              .toList();

          // Extract unique slabs for filter
          final Map<String, SlabInfo> slabMap = {};
          for (final act in validActivities) {
            if (act.slab != null && act.slab!.id.isNotEmpty) {
              slabMap[act.slab!.id] = act.slab!;
            }
          }

          setState(() {
            _allActivities = validActivities;
            _availableSlabs = slabMap.values.toList();
            isLoading = false;
          });
          return;
        }
      }

      setState(() {
        _allActivities = [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        _allActivities = [];
        isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {});
    });
  }

  Future<void> _onRefresh() async {
    await fetchDprActivities(isRefresh: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.slabId != null && widget.slabId!.isNotEmpty) {
      _selectedFilterSlabIds.add(widget.slabId!);
    }
    fetchDprActivities();
  }

  void _showFilterModal(BuildContext context) {
    final bool isMobile = context.isMobile;
    final Set<String> tempSelectedSlabIds = Set<String>.from(_selectedFilterSlabIds);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState1) {
            return AlertDialog(
              backgroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  "FILTER BY SLAB",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              content: SizedBox(
                width: isMobile ? 320.0 : 440.0,
                height: isMobile ? 320.0 : 380.0,
                child: Column(
                  children: [
                    const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                    Expanded(
                      child: _availableSlabs.isEmpty
                          ? const Center(
                              child: Text(
                                "No slabs found",
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _availableSlabs.length,
                              itemBuilder: (context, i) {
                                final slab = _availableSlabs[i];
                                final isSelected = tempSelectedSlabIds.contains(slab.id);

                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    slab.name,
                                    style: TextStyle(
                                      fontSize: isMobile ? 13 : 14,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(Icons.check_box, color: Colors.black, size: 22)
                                      : const Icon(Icons.check_box_outline_blank, color: Colors.grey, size: 22),
                                  onTap: () {
                                    setState1(() {
                                      if (isSelected) {
                                        tempSelectedSlabIds.remove(slab.id);
                                      } else {
                                        tempSelectedSlabIds.add(slab.id);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState1(() {
                            tempSelectedSlabIds.clear();
                          });
                          setState(() {
                            _selectedFilterSlabIds.clear();
                          });
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "RESET",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedFilterSlabIds = Set<String>.from(tempSelectedSlabIds);
                          });
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "APPLY",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;
    final double horizontalPadding = isMobile ? 12 : 24;
    final displayList = _filteredActivities;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          widget.towarName != null && widget.towarName!.isNotEmpty
              ? '${widget.projectName?.toUpperCase() ?? ''} - ${widget.towarName?.toUpperCase() ?? ''}'
              : (widget.projectName?.toUpperCase() ?? "RCC TASKS"),
          style: TextStyle(
            fontSize: isMobile ? 15.0 : 17.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          // Sub-header title with Filter button on the left
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 8,
            ),
            color: Colors.white,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () => _showFilterModal(context),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Image.asset(
                            'images/projectmanagement/filter-sort-icon.png',
                            height: isMobile ? 18 : 20,
                            fit: BoxFit.contain,
                          ),
                          if (_selectedFilterSlabIds.isNotEmpty)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Text(
                  "DPR Task's List",
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

          // Segmented Capsule Tab Bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!isPending) {
                          setState(() {
                            isPending = true;
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isPending ? Colors.black : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'PENDING ($_pendingCount)',
                          style: TextStyle(
                            color: isPending ? Colors.white : Colors.black87,
                            fontSize: isMobile ? 13 : 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (isPending) {
                          setState(() {
                            isPending = false;
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: !isPending ? Colors.black : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'COMPLETED ($_completedCount)',
                          style: TextStyle(
                            color: !isPending ? Colors.white : Colors.black87,
                            fontSize: isMobile ? 13 : 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Field Bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              bottom: 12,
            ),
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  hintText: "Search by Task Title or Slab...",
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF2F4F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

          // Body Content: Skeleton / Empty State / List View
          Expanded(
            child: isLoading
                ? CustomLoading.buildRccTaskListSkeletonInline(context)
                : displayList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              "No Records Found",
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: Colors.black,
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
                          itemCount: displayList.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 2),
                          itemBuilder: (BuildContext context, int index) {
                            final activity = displayList[index];
                            final isOverdue = activity.isOverdue;

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return RccTaskDetails(
                                        projectId: widget.projectId,
                                        towarId: widget.towarId ?? '',
                                        projectName: widget.projectName,
                                        towarName: widget.towarName ?? '',
                                        activity: activity,
                                        dprTaskId: activity.id,
                                      );
                                    },
                                  ),
                                ).then((_) {
                                  fetchDprActivities(isRefresh: true);
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: isMobile ? 4 : 6,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 14 : 18,
                                  vertical: isMobile ? 12 : 16,
                                ),
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
                                    // Task Header: Title & Status Icon
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            activity.activityName,
                                            style: TextStyle(
                                              fontSize: isMobile ? 15 : 17,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          activity.isCompleted
                                              ? Icons.check_circle_outline_sharp
                                              : Icons.circle_outlined,
                                          color: activity.isCompleted
                                              ? Colors.green
                                              : Colors.grey,
                                          size: isMobile ? 20 : 22,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                                    const SizedBox(height: 6),

                                    // Key-value attributes - always present
                                    rowThreeText(
                                      context: context,
                                      title: "Assigned On",
                                      titleValue: activity.createdAt != null
                                          ? DateFormat('dd-MM-yyyy')
                                              .format(activity.createdAt!)
                                          : '--',
                                    ),
                                    rowThreeText(
                                      context: context,
                                      title: "Deadline",
                                      titleValue: activity.targetCompletionDate != null
                                          ? DateFormat('dd-MM-yyyy')
                                              .format(activity.targetCompletionDate!)
                                          : '--',
                                      titleValueColor:
                                          isOverdue ? Colors.red : Colors.black87,
                                    ),
                                    rowThreeText(
                                      context: context,
                                      title: "Completed On",
                                      titleValue: activity.completedAt != null
                                          ? DateFormat('dd-MM-yyyy')
                                              .format(activity.completedAt!)
                                          : '--',
                                    ),
                                    rowThreeText(
                                      context: context,
                                      title: "Slab No",
                                      titleValue: (activity.slab?.name != null &&
                                              activity.slab!.name.isNotEmpty)
                                          ? activity.slab!.name
                                          : (activity.slab?.slabNumber != null
                                              ? '${activity.slab!.slabNumber}'
                                              : '--'),
                                    ),
                                    rowThreeText(
                                      context: context,
                                      title: "Assignor",
                                      titleValue: activity.resolvedAssignor ?? '--',
                                    ),
                                    rowThreeText(
                                      context: context,
                                      title: "Completed By",
                                      titleValue:
                                          activity.resolvedCompletedBy ?? '--',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
