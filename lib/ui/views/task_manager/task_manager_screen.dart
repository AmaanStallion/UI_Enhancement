import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_meeting_id.dart';
import 'package:stallion/models/get_user_task_by_id.dart';
import 'package:stallion/models/tenant_payment_list.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/task_manager/add_task.dart';
import 'package:stallion/ui/views/task_manager/create_new_meeting.dart';
import 'package:stallion/ui/views/task_manager/meeting_detail_screen.dart';
import 'package:stallion/ui/views/task_manager/task_details.dart';
import 'package:stallion/ui/views/task_manager/task_manager_mock_data.dart';
import 'package:stallion/ui/widgets/row_three_text.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({
    super.key,
    this.towarId,
    this.projectId,
    this.projectName,
    this.towarName,
  });
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  @override
  State<TaskManagerScreen> createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  List<String>? filterData = [];
  String myTaskSelectedModal = '';
  TextEditingController searchController = TextEditingController();
  String searchText = '';
  bool isMyTasks = true;
  String offset = "0";
  String isFilterArray = '';
  String searchTermValue = '';
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<UserTask>? userTaskResponse = [];
  List<MettingDatum>? mettingDataResponse = [];
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  GetUserTaskByIdResponse? responseData;

  Future<List<TenantPaymentListElement>?> getUserTaskById() async {
    if (TaskManagerMockData.useMockData) {
      setState(() {
        userTaskResponse = TaskManagerMockData.getMockUserTasks();
        mettingDataResponse = TaskManagerMockData.getMockMeetings();
        filterData = ["All", "Pending", "Completed", "Extended"];
      });
      return null;
    }
    try {
      CustomLoading.progressDialog(isLoading: true, context: context);

      final towerId = widget.towarId;
      if (towerId != null && towerId.isNotEmpty) {
        if (widget.projectId != null && widget.projectId!.isNotEmpty) {
          await apiNetworkHandler.ensureProjectContext(widget.projectId);
        }

        var response = await apiNetworkHandler.get(
          AppUrl.getTowerTaskList(towerId),
        );

        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic> && decoded['success'] == true) {
            final data = decoded['data'];
            if (data is Map<String, dynamic>) {
              final List rawTasks = data['tasks'] as List? ?? [];
              List<UserTask> allFetchedTasks = rawTasks
                  .map((x) => UserTask.fromJson(x as Map<String, dynamic>))
                  .toList();

              final totalPendingCount = allFetchedTasks
                  .where((t) => t.taskCompleteStatus != '1')
                  .length
                  .toString();

              List<UserTask> tasks = List.from(allFetchedTasks);

              if (searchTermValue.isNotEmpty) {
                tasks = tasks
                    .where((t) => (t.taskTitle ?? '')
                        .toLowerCase()
                        .contains(searchTermValue.toLowerCase()))
                    .toList();
              }

              if (myTaskSelectedModal.isNotEmpty &&
                  myTaskSelectedModal.toLowerCase() != 'all') {
                final targetStatus = myTaskSelectedModal.toLowerCase();
                if (targetStatus == 'completed' || targetStatus == '1') {
                  tasks =
                      tasks.where((t) => t.taskCompleteStatus == '1').toList();
                } else if (targetStatus == 'pending' || targetStatus == '0') {
                  tasks =
                      tasks.where((t) => t.taskCompleteStatus != '1').toList();
                } else if (targetStatus == 'extended') {
                  tasks =
                      tasks.where((t) => t.taskDeadlineStatus == '1').toList();
                }
              }

              setState(() {
                userTaskResponse = tasks;
                responseData = GetUserTaskByIdResponse(
                  errorCode: "0",
                  msg: decoded['message']?.toString() ?? '',
                  totalTaskPending: totalPendingCount,
                  userTask: tasks,
                );
              });
              getUserMeetingsById();
              return null;
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('TaskManagerScreen: Error fetching tower task list: $e');
      }
    } finally {
      CustomLoading.progressDialog(isLoading: false, context: context);
    }
    return null;
  }

  Future<List<TenantPaymentListElement>?> getUserMeetingsById() async {
    if (AppUrl.useNewBackend) return null;
    if (TaskManagerMockData.useMockData) {
      setState(() {
        mettingDataResponse = TaskManagerMockData.getMockMeetings();
      });
      return null;
    }
    try {
      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "project_id": widget.projectId ?? '',
        "towar_id": widget.towarId ?? '',
        "search_data": isFilterArray,
      };

      if (kDebugMode) {
        print(data);
      }

      var response = await apiNetworkHandler.post(AppUrl.meetingByUserId, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = getUserMeetingByIdFromJson(response.body);

        if (kDebugMode) {
          print(dataModel.response?.errorCode);
        }

        if (dataModel.response?.errorCode == "0") {
          setState(() {
            mettingDataResponse = dataModel.response?.mettingData;
            if (filterData?.length == 0) {
              filterData = dataModel.response?.filterData;
            }
          });
        } else {
          // Handle error when errorCode is not "0"
        }
      } else {
        // Handle error for non-200/201 status codes
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
    } finally {}
    return null;
  }

  Future<List<TenantPaymentListElement>?> deleteMeetingById(
      {required String meetingId, required String taskId}) async {
    if (TaskManagerMockData.useMockData) {
      setState(() {
        mettingDataResponse?.removeWhere((m) => m.mettingId == meetingId);
      });
      showDialog<void>(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Task Deleted Successfully.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              actions: [
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("Okay", style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            );
          });
      return null;
    }
    try {
      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "metting_id": meetingId,
        "task_id": taskId,
      };

      if (kDebugMode) {
        print(data);
      }

      var response =
          await apiNetworkHandler.post(AppUrl.deleteMeetingById, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ignore: use_build_context_synchronously
        showDialog<void>(
            barrierDismissible: true,
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Set radius to zero
                ),
                titlePadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                actionsPadding:
                    const EdgeInsets.only(bottom: 10, left: 10, right: 10),
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
                      searchTermValue = '';
                      userTaskResponse = [];
                      getUserTaskById();
                      // Navigator.of(context).pop();
                      // Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 250,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(7)),
                      child: const Text(
                        "Okay",
                        style: TextStyle(
                          fontSize: 16,
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
      } else {}
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
    } finally {}
    return null;
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));

    offset = '0';
    searchTermValue = '';

    getUserTaskById();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));
    getUserTaskById();
    _refreshController.loadComplete();
  }

  List<String>? filteredProjects() {
    if (searchText.isEmpty) {
      return filterData;
    }
    return filterData!.where((project) {
      return project.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      offset = '0';
      searchTermValue = '';
      userTaskResponse = [];
      getUserTaskById();
    });
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
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                var projectId = widget.projectId!;
                var projectName = widget.projectName!;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return AddTaskScreen(
                        projectId: projectId,
                        towarId: widget.towarId!,
                        projectName: projectName,
                        towarName: widget.towarName!,
                      );
                    },
                  ),
                ).then((value) {
                  offset = '0';
                  searchTermValue = '';
                  userTaskResponse = [];
                  getUserTaskById();
                });
              },
              child: Container(
                width: double.maxFinite,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                color: Colors.black54,
                child: const Text(
                  "ADD QUICK TASK",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              width: double.maxFinite,
              color: Colors.black,
              child: Text(
                "Total Task Remaining : ${responseData?.totalTaskPending}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      // Row(
      //   children: [
      //     Expanded(
      //       child:
      // InkWell(
      //         onTap: () {
      //           var projectId = widget.projectId!;
      //           var projectName = widget.projectName!;
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (_) {
      //                 return AddTaskScreen(
      //                   projectId: projectId,
      //                   towarId: widget.towarId!,
      //                   projectName: projectName,
      //                   towarName: widget.towarName!,
      //                 );
      //               },
      //             ),
      //           ).then((value) {
      //             offset = '0';
      //             searchTermValue = '';
      //             userTaskResponse = [];
      //             getUserTaskById();
      //           });
      //         },
      //         child: Container(
      //           padding: const EdgeInsets.symmetric(vertical: 8),
      //           color: Colors.black54,
      //           child: const Text(
      //             "ADD QUICK TASK",
      //             textAlign: TextAlign.center,
      //             style: TextStyle(
      //               fontSize: 16,
      //               color: Colors.white,
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //     Expanded(
      //       child: InkWell(
      //         onTap: () {
      //           // setState(() {
      //           //   isMyTasks = false;
      //           // });
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (_) {
      //                 return CreateNewMeeting(
      //                   projectId: widget.projectId,
      //                   towarId: widget.towarId!,
      //                   projectName: widget.projectName,
      //                   towarName: widget.towarName!,
      //                 );
      //               },
      //             ),
      //           ).then((value) {
      //             offset = '0';
      //             searchTermValue = '';
      //             filterData = [];
      //             userTaskResponse = [];
      //             getUserTaskById();
      //           });
      //         },
      //         child: Container(
      //           padding: const EdgeInsets.symmetric(vertical: 8),
      //           color: Colors.black,
      //           child: const Text(
      //             "CREATE NEW MEETING",
      //             textAlign: TextAlign.center,
      //             style: TextStyle(
      //               fontSize: 16,
      //               color: Colors.white,
      //             ),
      //           ),
      //         ),
      //       ),
      //     )
      //   ],
      // ),
      body: Column(
        children: [
          Container(
            height: 38,
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 20),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xffdee2e6)))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: isMobile ? 24 : 32,
                  height: isMobile ? 24 : 32,
                  child: InkWell(
                    onTap: () {
                      if (isMyTasks == false) {
                        selectFilterModal();
                      } else {
                        selectMyTaskFilterModal();
                      }
                    },
                    child: Center(
                      child: Image.asset(
                        'images/projectmanagement/filter-sort-icon.png',
                        height: isMobile ? 18 : 20,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'TASK MANAGER',
                  style: TextStyle(
                    fontFamily: 'HelveticaNeue',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(width: isMobile ? 24 : 32),
              ],
            ),
          ),
          if (isMyTasks == true)
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12.0 : 60.0, vertical: isMobile ? 6 : 12),
              child: SizedBox(
                height: isMobile ? 36 : 40,
                child: TextField(
                  onChanged: (value) {
                    Future.delayed(const Duration(seconds: 1), () {
                      if (value.isNotEmpty) {
                        if (value.length > 2) {
                          print('--------------');
                          offset = '0';
                          searchTermValue = value.trim();
                          getUserTaskById();
                        }
                      } else {
                        print('++++++++++++++++++');
                        offset = '0';
                        searchTermValue = '';
                      }
                    });
                  },
                  style: TextStyle(fontSize: isMobile ? 12 : 13),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: isMobile ? 6.0 : 12.0),
                      labelText: "Search by Task Title",
                      hintText: "Search by Task Title",
                      prefixIcon: Icon(Icons.search, size: isMobile ? 18 : 22),
                      border: const OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(25.0)))),
                ),
              ),
            ),

          isMyTasks
              ? Expanded(
                  child: SmartRefresher(
                    enablePullDown: searchTermValue.isEmpty ? true : false,
                    enablePullUp: searchTermValue.isEmpty ? true : false,
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    footer: const ClassicFooter(
                        loadStyle: LoadStyle.ShowWhenLoading),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: userTaskResponse!.length,
                      itemBuilder: (context, index) {
                        UserTask tempp = userTaskResponse![index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return TaskDetailsScreen(
                                    userTask: tempp,
                                    projectId: widget.projectId,
                                    towarId: widget.towarId!,
                                    projectName: widget.projectName,
                                    towarName: widget.towarName!,
                                    isFromMyTask: true,
                                  );
                                },
                              ),
                            ).then((value) {
                              offset = '0';
                              searchTermValue = '';
                              userTaskResponse = [];
                              getUserTaskById();
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: isMobile ? 12 : 24, vertical: isMobile ? 2 : 3),
                            padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 14),
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        tempp.taskTitle ?? '',
                                        style: TextStyle(
                                            fontSize: isMobile ? 14 : 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Icon(
                                      tempp.taskCompleteStatus == '1'
                                          ? Icons.check_circle_outline_sharp
                                          : Icons.circle_outlined,
                                      color: tempp.taskCompleteStatus == '1'
                                          ? Colors.green
                                          : Colors.grey,
                                      size: isMobile ? 20 : 22,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Divider(height: 1),
                                const SizedBox(height: 4),
                                rowThreeText(
                                  context: context,
                                  title: "Assigned On",
                                  titleValue: tempp.taskCreateAt ?? '',
                                ),
                                rowThreeText(
                                  context: context,
                                  title: "Deadline",
                                  titleValue: tempp.taskDeadline ?? '',
                                  titleValueColor:
                                      tempp.taskDeadlineStatus == '1'
                                          ? Colors.red
                                          : Colors.black,
                                ),
                                rowThreeText(
                                  context: context,
                                  title: "Assigned To",
                                  titleValue: tempp.assignTo ?? '',
                                ),
                                rowThreeText(
                                  context: context,
                                  title: "Assignor",
                                  titleValue: tempp.assignBy ?? '',
                                ),
                                rowThreeText(
                                  context: context,
                                  title: "Completed By",
                                  titleValue:
                                      tempp.taskCompletedBy?.trim() ?? '--',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(height: 2),
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.separated(
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
                                titlePadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                actionsPadding: const EdgeInsets.only(
                                    bottom: 10, left: 10, right: 10),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                actionsAlignment: MainAxisAlignment.center,
                                title: const Text(
                                  "Are you sure you want to delete\n this meeting?",
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
                                    },
                                    child: Container(
                                      width: 150,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: const Text(
                                        "No",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      Navigator.of(context).pop();
                                      inspect(temppp);
                                      deleteMeetingById(
                                          meetingId: temppp.mettingId ?? '',
                                          taskId: '');
                                    },
                                    child: Container(
                                      width: 150,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: const Text(
                                        'Yes',
                                        style: TextStyle(
                                          fontSize: 16,
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

                      return InkWell(
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
                            searchTermValue = '';
                            getUserTaskById();
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 24, vertical: isMobile ? 2 : 3),
                          padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 14),
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
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      temppp.mettingTitle ?? '',
                                      style: TextStyle(
                                        fontSize: isMobile ? 14 : 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: showDeleteDialog,
                                    child: Icon(
                                      Icons.delete_outlined,
                                      color: Colors.grey,
                                      size: isMobile ? 20 : 22,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Divider(height: 1),
                              const SizedBox(height: 4),
                              rowThreeText(
                                context: context,
                                title: "Date",
                                titleValue: temppp.mettingCreate ?? '',
                              ),
                              rowThreeText(
                                context: context,
                                title: "Tasks",
                                titleValue: temppp.taskcompleDetails ?? '',
                                titleValueColor: Colors.red,
                              ),
                              rowThreeText(
                                context: context,
                                title: "Participants",
                                titleValue: temppp.participants ?? '',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(height: 2),
                  ),
                ),
          if ((userTaskResponse!.length == 0 && isMyTasks) ||
              (mettingDataResponse!.length == 0 && isMyTasks == false))
            const Expanded(
              child: Text("No Record Found"),
            ),
        ],
      ),
    );
  }

  selectMyTaskFilterModal() {
    return showDialog<void>(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState1) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              titlePadding: EdgeInsets.zero,
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              contentPadding: const EdgeInsets.all(16),
              actionsAlignment: MainAxisAlignment.center,
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
                  'MY TASK FILTER',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: [
                InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(25)),
                    child: const Center(
                      child: Text(
                        "CLOSE",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFilterOption(
                      title: 'ALL',
                      isSelected: myTaskSelectedModal == "",
                      onTap: () {
                        setState(() {
                          offset = '0';
                          filterData = [];
                          userTaskResponse = [];
                          myTaskSelectedModal = "";
                        });
                        getUserTaskById();
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildFilterOption(
                      title: 'PENDING',
                      isSelected: myTaskSelectedModal == "0",
                      onTap: () {
                        setState(() {
                          offset = '0';
                          filterData = [];
                          userTaskResponse = [];
                          myTaskSelectedModal = "0";
                        });
                        getUserTaskById();
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildFilterOption(
                      title: 'COMPLETED',
                      isSelected: myTaskSelectedModal == "1",
                      onTap: () {
                        setState(() {
                          offset = '0';
                          filterData = [];
                          userTaskResponse = [];
                          myTaskSelectedModal = "1";
                        });
                        getUserTaskById();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  Widget _buildFilterOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xfff8f9fa) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.black54 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            Icon(
              isSelected ? Icons.check_circle_outline_rounded : Icons.circle_outlined,
              color: isSelected ? Colors.green : Colors.grey,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  selectFilterModal() {
    return showDialog<void>(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState1) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              titlePadding: EdgeInsets.zero,
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              contentPadding: const EdgeInsets.all(16),
              actionsAlignment: MainAxisAlignment.center,
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
                  'MY MEETINGS FILTER',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: [
                InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(25)),
                    child: const Center(
                      child: Text(
                        "CLOSE",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
              content: SizedBox(
                width: 360,
                height: 300,
                child: filterData != null && filterData!.isNotEmpty
                    ? Column(
                        children: [
                          TextField(
                            onChanged: (value) {
                              setState1(() {
                                searchText = value;
                              });
                            },
                            style: const TextStyle(fontSize: 13),
                            controller: searchController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              hintText: "Search by Name",
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: searchController.text.isNotEmpty
                                  ? InkWell(
                                      onTap: () {
                                        searchController.clear();
                                        setState1(() {
                                          searchText = "";
                                        });
                                      },
                                      child: const Icon(Icons.close_rounded,
                                          size: 18),
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: filteredProjects()!.length,
                              itemBuilder: (context, index) {
                                final item = filteredProjects()?[index] ?? '';
                                final isSelected = (isFilterArray == item);
                                return _buildFilterOption(
                                  title: item,
                                  isSelected: isSelected,
                                  onTap: () {
                                    setState(() {
                                      if (isFilterArray == item) {
                                        isFilterArray = "";
                                      } else {
                                        isFilterArray = item;
                                      }
                                      offset = '0';
                                      searchTermValue = '';
                                    });
                                    Navigator.of(context).pop();
                                    getUserMeetingsById();
                                  },
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Text(
                          "No Record Found",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
            );
          });
        });
  }
}

class TaskManagerView extends StatefulWidget {
  const TaskManagerView({super.key});

  @override
  State<TaskManagerView> createState() => _TaskManagerViewState();
}

class _TaskManagerViewState extends State<TaskManagerView> {
  NotificationArgs? args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is NotificationArgs) {
      args = routeArgs;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String pId = args?.projectId != null && args!.projectId!.isNotEmpty
        ? args!.projectId!
        : (args?.response?.projectId ?? '');
    final String tId = args?.response?.towarId != null && args!.response!.towarId!.isNotEmpty
        ? args!.response!.towarId!
        : (args?.towarName ?? '');
    final String pName = args?.projectName ?? '';
    final String tName = args?.towarName ?? '';

    return TaskManagerScreen(
      projectId: pId,
      towarId: tId,
      projectName: pName,
      towarName: tName,
    );
  }
}
