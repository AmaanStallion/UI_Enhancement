import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stallion/models/sop_heading_model.dart';
import 'package:stallion/models/sop_sub_heading_model.dart';
import 'package:stallion/models/sop_track_modal.dart';
import 'package:stallion/models/sop_tower_task_model.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/sopModule/sop_details.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';

class SopTrackScreen extends StatefulWidget {
  const SopTrackScreen(
      {super.key,
      required this.projectId,
      required this.towarId,
      required this.projectName,
      required this.towarName,
      required this.sopId,
      required this.assingIoId,
      required this.title});

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? sopId;
  final String? assingIoId;
  final String? title;

  @override
  State<SopTrackScreen> createState() => _SopTrackScreenState();
}

class _SopTrackScreenState extends State<SopTrackScreen> {
  bool get isMobile => context.isMobile;
  final NetworkHandler apiNetworkHandler = NetworkHandler();
  static const bool testWithMockData = false;
  bool _isLoading = true;

  List<SopAssignList>? sopAssignList = [];

  Future<dynamic> getTrackAssign() async {
    setState(() {
      _isLoading = true;
    });

    if (testWithMockData) {
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        sopAssignList = [
          SopAssignList(
            transEmpName: "John Doe",
            transEmpId: "11",
            pendingCount: "0",
            totalCount: "2",
          ),
          SopAssignList(
            transEmpName: "Jane Smith",
            transEmpId: "12",
            pendingCount: "1",
            totalCount: "1",
          ),
          SopAssignList(
            transEmpName: "Robert Johnson",
            transEmpId: "13",
            pendingCount: "0",
            totalCount: "1",
          ),
        ];
        _isLoading = false;
      });
      return null;
    }

    try {
      Set<String> disabledSubHeadingIds = {};

      // Fetch headings once to identify disabled headings and subheadings
      if (widget.sopId != null && widget.sopId!.isNotEmpty) {
        try {
          String headingsUrl = "${AppUrl.devSopHeadings}?category_id=${widget.sopId}";
          if (widget.towarId != null && widget.towarId!.isNotEmpty) {
            headingsUrl = "$headingsUrl&tower_id=${widget.towarId}";
          }
          var headingsResp = await apiNetworkHandler.get(headingsUrl);
          if (headingsResp != null && (headingsResp.statusCode == 200 || headingsResp.statusCode == 201)) {
            final headingData = devSopHeadingResponseFromJson(headingsResp.body);
            List<DevSopHeading> headings = headingData.data ?? [];
            for (var h in headings) {
              if (h.isEnabled == false) {
                for (var sh in h.subHeadings) {
                  if (sh.id != null) {
                    disabledSubHeadingIds.add(sh.id!);
                  }
                }
              } else {
                for (var sh in h.subHeadings) {
                  if (sh.isEnabled == false || sh.isDeleted == true) {
                    if (sh.id != null) {
                      disabledSubHeadingIds.add(sh.id!);
                    }
                  }
                }
              }
            }
          }
        } catch (_) {}
      }

      String taskUrl = "${AppUrl.devSopTowerTaskList}?tower_id=${widget.towarId ?? ''}";
      var response = await apiNetworkHandler.get(taskUrl);

      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        final taskDataModel = towerSopTaskListResponseFromJson(response.body);
        List<TowerSopTask> tasks = taskDataModel.data?.tasks ?? [];

        // Group tasks by assigned user
        Map<String, SopAssignList> groupedMap = {};
        for (var t in tasks) {
          String shId = t.subHeading?.id ?? t.subHeadingId ?? "";

          // Skip inactive/disabled tasks or subheadings
          if (disabledSubHeadingIds.contains(shId) ||
              t.isEnabled == false ||
              t.subHeading?.isEnabled == false ||
              t.subHeading?.heading?.isEnabled == false ||
              t.subHeading?.heading?.category?.isEnabled == false) {
            continue;
          }

          // Filter tasks by Category ID (widget.sopId)
          if (widget.sopId != null && widget.sopId!.isNotEmpty) {
            String? taskCatId = t.subHeading?.heading?.category?.id;
            if (taskCatId != null && taskCatId.isNotEmpty && taskCatId != widget.sopId) {
              continue;
            }
          }

          String? uId = t.assignedUser?.id ?? t.assignedUserId;
          String? uName = t.assignedUser?.name;

          // Skip tasks that do not have an assigned employee
          if (uId == null ||
              uId.isEmpty ||
              uId == "unassigned" ||
              uName == null ||
              uName.isEmpty ||
              uName.toLowerCase() == "unassigned") {
            continue;
          }

          if (!groupedMap.containsKey(uId)) {
            groupedMap[uId] = SopAssignList(
              transEmpId: uId,
              transEmpName: uName,
              totalCount: "0",
              pendingCount: "0",
            );
          }

          int tot = int.tryParse(groupedMap[uId]!.totalCount ?? "0") ?? 0;
          int pend = int.tryParse(groupedMap[uId]!.pendingCount ?? "0") ?? 0;

          tot++;
          if (t.status?.toLowerCase() != "completed") {
            pend++;
          }

          groupedMap[uId]!.totalCount = tot.toString();
          groupedMap[uId]!.pendingCount = pend.toString();
        }

        if (mounted) {
          setState(() {
            sopAssignList = groupedMap.values.toList();
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in getTrackAssign: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    return null;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getTrackAssign();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            '${widget.projectName!.toUpperCase()} ${widget.towarName!.isNotEmpty ? "-" : ""} ${widget.towarName!.toUpperCase()}',
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: _isLoading
          ? CustomLoading.buildSopTrackSkeletonInline(context)
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 8),
                  width: double.maxFinite,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.black),
                    ),
                  ),
                  child: Text(
                    "TRACK SOP",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'HelveticaNeue',
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                // Modernized Table Header Card
                Container(
                  margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xfff8f9fa),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xffe9ecef), width: 1.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          "Employee Name",
                          style: TextStyle(
                            fontFamily: 'HelveticaNeue',
                            fontSize: isMobile ? 12 : 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "Pending / Assigned",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'HelveticaNeue',
                            fontSize: isMobile ? 12 : 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Action",
                          style: TextStyle(
                            fontFamily: 'HelveticaNeue',
                            fontSize: isMobile ? 12 : 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                for (int i = 0; i < sopAssignList!.length; i++)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 3),
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
                    padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            sopAssignList?[i].transEmpName ?? '',
                            style: TextStyle(
                              fontFamily: 'HelveticaNeue',
                              fontSize: isMobile ? 12 : 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${sopAssignList?[i].pendingCount} / ${sopAssignList?[i].totalCount}',
                            style: TextStyle(
                              fontFamily: 'HelveticaNeue',
                              fontSize: isMobile ? 12 : 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return SopDetails(
                                          projectId: widget.projectId,
                                          towarId: widget.towarId!,
                                          projectName: widget.projectName,
                                          towarName: widget.towarName!,
                                          sopId: widget.sopId,
                                          title: widget.title,
                                          assingToId: sopAssignList?[i].transEmpId,
                                        );
                                      },
                                    ),
                                  ).then((value) => getTrackAssign());
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black54),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "View",
                                    style: TextStyle(
                                      fontFamily: 'HelveticaNeue',
                                      fontSize: isMobile ? 11 : 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (sopAssignList!.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        "No Record Found",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
              ],
            ),
    );
  }
}
