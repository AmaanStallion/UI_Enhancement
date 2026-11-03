import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_all_members_by_project.dart';
import 'package:stallion/models/get_meeting_id.dart';
import 'package:stallion/models/get_user_task_by_id.dart';
import 'package:stallion/models/mettingDetailsByUser.dart';
import 'package:stallion/models/tenant_payment_list.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/task_manager/add_task.dart';
import 'package:stallion/ui/views/task_manager/assign_meeting.dart';
import 'package:stallion/ui/views/task_manager/task_details.dart';
import 'package:stallion/ui/views/task_manager/task_manager_mock_data.dart';
import 'package:stallion/ui/widgets/row_three_text.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';

class MeetingDetailsScreen extends StatefulWidget {
  const MeetingDetailsScreen({
    super.key,
    this.towarId,
    this.projectId,
    this.projectName,
    this.towarName,
    required this.mettingData,
  });
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final MettingDatum mettingData;

  @override
  State<MeetingDetailsScreen> createState() => _MeetingDetailsScreenState();
}

class _MeetingDetailsScreenState extends State<MeetingDetailsScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController _participantsController = TextEditingController();
  List<MemberDetail>? memberDetailsRes = [];
  List<MemberDetail>? memberDetailsResShareMeeting = [];

  List<MemberDetail>? selectedMember = [];
  String participantsNumberSelected = '';
  // MettingDatum? mettingData;
  List<UserTask>? taskDetails = [];
  List<ShareDetail>? shareDetails = [];
  String? profileId = '';
  String shareWithNames = '';
  List<MemberDetail> shareWithMemberDetails = [];

  Future<List<TenantPaymentListElement>?> deleteMeetingById(
      {required String meetingId, required String taskId}) async {
    try {
      if (AppUrl.useNewBackend) {
        if (widget.projectId != null && widget.projectId!.isNotEmpty) {
          await apiNetworkHandler.ensureProjectContext(widget.projectId);
        }

        var response = await apiNetworkHandler.delete(
          AppUrl.deleteTask(taskId),
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
                    borderRadius: BorderRadius.circular(8),
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
                        getMettingDetailsByUser(
                            meetingId: widget.mettingData.mettingId ?? '');
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

        if (kDebugMode) {
          print(data);
        }

        var response =
            await apiNetworkHandler.post(AppUrl.deleteMeetingById, data);

        if (kDebugMode) {
          print(response.statusCode);
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (!mounted) return null;
          showDialog<void>(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
                        getMettingDetailsByUser(
                            meetingId: widget.mettingData.mettingId ?? '');
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
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('MeetingDetailsScreen: Exception deleting task: $e');
      }
    }
    return null;
  }

  MettingDatum? fetchedMeetingDatum;

  Future<List<TenantPaymentListElement>?> getMettingDetailsByUser(
      {required String meetingId}) async {
    if (meetingId.isEmpty) return null;

    if (TaskManagerMockData.useMockData) {
      setState(() {
        taskDetails = TaskManagerMockData.getMockUserTasks();
        shareDetails = TaskManagerMockData.getMockShareDetails(meetingId);
        profileId = "P001";
      });
      return null;
    }
    try {
      if (AppUrl.useNewBackend) {
        if (widget.projectId != null && widget.projectId!.isNotEmpty) {
          await apiNetworkHandler.ensureProjectContext(widget.projectId);
        }

        var response = await apiNetworkHandler.get(
          AppUrl.getMeetingDetailsAndTasks(meetingId),
        );

        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic> && decoded['success'] == true) {
            final data = decoded['data'];
            if (data is Map<String, dynamic>) {
              final meeting = data['meeting'];
              List<MemberDetail> parsedParticipants = [];
              List<MemberDetail> parsedShareWith = [];
              String formattedDate = '';
              String meetingTitle = widget.mettingData.mettingTitle ?? '';
              String assignor = widget.mettingData.assignBy ?? '';
              String participantsNames = widget.mettingData.participants ?? '';
              String parsedShareWithNames = '';

              if (meeting is Map<String, dynamic>) {
                meetingTitle = meeting['title']?.toString() ?? meetingTitle;
                assignor = meeting['assignor']?.toString() ?? assignor;
                participantsNames =
                    meeting['participants_names']?.toString() ?? participantsNames;
                parsedShareWithNames =
                    meeting['share_with_names']?.toString() ?? '';

                String rawDate = meeting['date']?.toString() ?? '';
                if (rawDate.isNotEmpty) {
                  try {
                    DateTime? dt = DateTime.tryParse(rawDate);
                    if (dt != null) {
                      formattedDate = DateFormat('dd/MM/yyyy').format(dt);
                    }
                  } catch (_) {}
                }

                if (meeting['participants'] is List) {
                  for (var p in meeting['participants']) {
                    if (p is Map) {
                      parsedParticipants.add(MemberDetail(
                        memberId: p['id']?.toString(),
                        memberName: p['name']?.toString(),
                        isSelected: false,
                      ));
                    }
                  }
                }

                if (meeting['share_with'] is List) {
                  for (var s in meeting['share_with']) {
                    if (s is Map) {
                      parsedShareWith.add(MemberDetail(
                        memberId: s['id']?.toString(),
                        memberName: s['name']?.toString(),
                        isSelected: false,
                      ));
                    }
                  }
                }
              }

              List<UserTask> parsedTasks = [];
              if (data['tasks'] is List) {
                for (var t in data['tasks']) {
                  if (t is Map<String, dynamic>) {
                    parsedTasks.add(UserTask.fromNewMeetingTaskJson(t));
                  }
                }
              }

              setState(() {
                memberDetailsRes = parsedParticipants;
                shareWithMemberDetails = parsedShareWith;
                shareWithNames = parsedShareWithNames;
                taskDetails = parsedTasks;
                fetchedMeetingDatum = MettingDatum(
                  mettingId: meetingId,
                  mettingTitle: meetingTitle,
                  mettingCreate: formattedDate.isNotEmpty
                      ? formattedDate
                      : widget.mettingData.mettingCreate,
                  participants: participantsNames,
                  assignBy: assignor,
                  memberDetails: parsedParticipants,
                );
              });
              return null;
            }
          }
        }
      } else {
        final SharedPreferences prefs = await _prefs;
        String? userId = prefs.getString('mobileNo');

        Map<String, String> data = {
          "user_id": userId ?? '',
          "metting_id": meetingId,
          "towar_id": widget.towarId ?? '',
          "project_id": widget.projectId ?? '',
        };

        if (kDebugMode) {
          print(data);
        }

        var response =
            await apiNetworkHandler.post(AppUrl.mettingDetailsByUser, data);

        if (kDebugMode) {
          print(response.statusCode);
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          final dataModel = mettingDetailsByUserFromJson(response.body);
          if (dataModel.response?.errorCode == "0") {
            setState(() {
              taskDetails = dataModel.response?.mettingData?[0].taskDetails;
              shareDetails = dataModel.response?.mettingData?[0].shareDetails;
              profileId = dataModel.response?.profileId;
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('MeetingDetailsScreen: Error fetching meeting details and tasks: $e');
      }
    }
    return null;
  }

  // Future<List<TenantPaymentListElement>?> addPartipantsByMeetingId({
  //   required String meetingId,
  // }) async {
  //   try {
  //     final SharedPreferences prefs = await _prefs;
  //     String? userId = prefs.getString('mobileNo');

  //     Map<String, String> data = {
  //       'project_id': widget.projectId ?? '',
  //       "user_id": userId ?? '',
  //       "participaint": participantsNumberSelected,
  //       "metting_id": meetingId,
  //       "towar_id": widget.towarId ?? '',
  //     };

  //     if (kDebugMode) {
  //       print(data);
  //     }

  //     var response =
  //         await apiNetworkHandler.post(AppUrl.participaintAddByMeeting, data);

  //     if (kDebugMode) {
  //       print(response.statusCode);
  //     }

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       // ignore: use_build_context_synchronously
  //       showDialog<void>(
  //           barrierDismissible: true,
  //           context: context,
  //           builder: (context) {
  //             return AlertDialog(
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(8), // Set radius to zero
  //               ),
  //               titlePadding:
  //                   const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
  //               actionsPadding:
  //                   const EdgeInsets.only(bottom: 10, left: 10, right: 10),
  //               contentPadding: const EdgeInsets.symmetric(horizontal: 16),
  //               actionsAlignment: MainAxisAlignment.center,
  //               title: const Text(
  //                 "Participants Added Successfully.",
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //                 textAlign: TextAlign.center,
  //               ),
  //               actions: [
  //                 InkWell(
  //                   onTap: () {
  //                     Navigator.of(context).pop();
  //                     // getUserTaskById();
  //                     Navigator.of(context).pop();
  //                     // Navigator.of(context).pop();
  //                   },
  //                   child: Container(
  //                     width: 250,
  //                     padding: const EdgeInsets.symmetric(vertical: 4),
  //                     decoration: BoxDecoration(
  //                         color: Colors.black,
  //                         borderRadius: BorderRadius.circular(7)),
  //                     child: const Text(
  //                       "Okay",
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.w600,
  //                         color: Colors.white,
  //                       ),
  //                       textAlign: TextAlign.center,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             );
  //           });
  //     } else {}
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Exception occurred: $e');
  //     }
  //   } finally {}
  //   return null;
  // }

  Future<List<TenantPaymentListElement>?> shareMettingWithOthers({
    required String meetingId,
    required String shareUser,
  }) async {
    try {
      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        'project_id': widget.projectId ?? '',
        "user_id": userId ?? '',
        // "participaint": participantsNumberSelected,
        "metting_id": meetingId,
        "towar_id": widget.towarId ?? '',
        "share_user": shareUser,
      };

      if (kDebugMode) {
        print(data);
      }

      var response =
          await apiNetworkHandler.post(AppUrl.shareMettingWithOther, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        showDialog<void>(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              titlePadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              actionsPadding:
                  const EdgeInsets.only(bottom: 10, left: 10, right: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: const Text(
                "Successfully shared this meeting with selected members.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              actions: [
                InkWell(
                  onTap: () {
                    getMembersByProject();
                    getMettingDetailsByUser(
                      meetingId: widget.mettingData.mettingId ?? '',
                    );

                    Navigator.of(context).pop();

                    // Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(7),
                    ),
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
          },
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
    }
    return null;
  }

  Future<List<TenantPaymentListElement>?> addPartipantsByMeetingId({
    required String meetingId,
    required String removedParticipantIds,
  }) async {
    try {
      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        'project_id': widget.projectId ?? '',
        "user_id": userId ?? '',
        "participaint": participantsNumberSelected,
        "metting_id": meetingId,
        "towar_id": widget.towarId ?? '',
        "removed_participaint": removedParticipantIds,
      };

      if (kDebugMode) {
        print(data);
      }

      var response =
          await apiNetworkHandler.post(AppUrl.participaintAddByMeeting, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        showDialog<void>(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              titlePadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              actionsPadding:
                  const EdgeInsets.only(bottom: 10, left: 10, right: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: const Text(
                "Participants Added Successfully.",
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
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(7),
                    ),
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
          },
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
    }
    return null;
  }

  Future<List<TenantPaymentListElement>?> getMembersByProject() async {
    String formatDate(DateTime dateTime) {
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    }

    try {
      // CustomLoading.progressDialog(isLoading: true, context: context);

      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "project_id": widget.projectId ?? '',
        "towar_id": widget.towarId ?? '',
      };

      if (kDebugMode) {
        print(data);
      }

      var response =
          await apiNetworkHandler.post(AppUrl.getMemberByProject, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = getAllMembersByProjectFromJson(response.body);

        if (kDebugMode) {
          print(dataModel.response?.errorCode);
        }

        if (dataModel.response?.errorCode == "0") {
          setState(() {
            // memberDetailsRes = dataModel.response?.memberDetails;
            // memberDetailsResShareMeeting = dataModel.response?.memberDetails;

            memberDetailsRes = dataModel.response?.memberDetails
                ?.map((e) => MemberDetail.from(e))
                .toList();

            memberDetailsResShareMeeting = dataModel.response?.memberDetails
                ?.map((e) => MemberDetail.from(e))
                .toList();

            for (MemberDetail item in (memberDetailsRes ?? [])) {
              bool isActive = (widget.mettingData.memberDetails ?? []).any((element) =>
                  element.memberName == item.memberName &&
                  element.memberId == item.memberId);

              item.isSelected = isActive;
            }
          });
          // getUserMeetingsById();
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
      // Handle exceptions here if needed
      // throw SomeCustomException('Exc eption occurred: $e');
    } finally {
      // ignore: use_build_context_synchronously
      // CustomLoading.progressDialog(isLoading: false, context: context);
    }
    return null;
  }

  @override
  void initState() {
    getMembersByProject();
    getMettingDetailsByUser(
      meetingId: widget.mettingData.mettingId ?? '',
    );
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
            (widget.towarName ?? '').isNotEmpty
                ? '${(widget.projectName ?? '').toUpperCase()} - ${(widget.towarName ?? '').toUpperCase()}'
                : (widget.projectName ?? '').toUpperCase(),
            style: TextStyle(
                fontStyle: FontStyle.normal,
                fontSize: isMobile ? 14.0 : 17.0)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 24, vertical: 6),
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
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.mettingData.mettingTitle ?? 'Meeting Details',
                        style: TextStyle(
                          fontSize: isMobile ? 15 : 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        customShowUpdateDialogAddAssignor(
                          meetingId: widget.mettingData.mettingId ?? '',
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 10 : 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Share Meeting",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 11 : 13,
                              fontWeight: FontWeight.w600),
                        ),
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
                  titleValue: fetchedMeetingDatum?.mettingCreate ?? widget.mettingData.mettingCreate ?? '',
                ),
                rowThreeText(
                  context: context,
                  title: "Participants",
                  titleValue: fetchedMeetingDatum?.participants ?? widget.mettingData.participants ?? '',
                  buttonIcon: Icons.edit_outlined,
                  onTapButton: () {
                    customShowUpdateDialog(
                      meetingId: widget.mettingData.mettingId ?? '',
                    );
                  },
                ),
                rowThreeText(
                  context: context,
                  title: "Assignor",
                  titleValue: fetchedMeetingDatum?.assignBy ?? widget.mettingData.assignBy ?? '',
                ),
                rowThreeText(
                  context: context,
                  title: "Share With",
                  titleValue: shareWithNames.isNotEmpty
                      ? shareWithNames
                      : (shareDetails
                              ?.map((detail) => detail.memberName)
                              .where((name) => name != null && name.isNotEmpty)
                              .join(', ') ??
                          ''),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
            child: Row(
              children: [
                Text(
                  "Tasks List",
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    List<MemberDetail> availableMembers =
                        (memberDetailsRes != null && memberDetailsRes!.isNotEmpty)
                            ? memberDetailsRes!
                            : (widget.mettingData.memberDetails ?? []);
                    MettingDatum mData = fetchedMeetingDatum ?? widget.mettingData;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          return AssignMeeting(
                            isFromCreateNewMeeting: false,
                            dataa: mData,
                            memberDetailsRes: availableMembers,
                            projectId: widget.projectId,
                            towarId: widget.towarId ?? '',
                            projectName: widget.projectName,
                            towarName: widget.towarName ?? '',
                            mettingTilte: mData.mettingTitle,
                          );
                        },
                      ),
                    ).then((_) {
                      getMettingDetailsByUser(
                        meetingId: widget.mettingData.mettingId ?? '',
                      );
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "+ ADD TASK",
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: taskDetails?.length ?? 0,
              itemBuilder: (context, index) {
                UserTask temp = taskDetails![index];

                void showDeleteTaskDialog() {
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
                            "Are you sure you want to delete\n this task?",
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
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(20)),
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
                                deleteMeetingById(
                                    meetingId:
                                        widget.mettingData.mettingId ?? '',
                                    taskId: temp.taskId ?? '');
                              },
                              child: Container(
                                width: 150,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(20)),
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
                          return TaskDetailsScreen(
                            userTask: temp,
                            projectId: widget.projectId,
                            towarId: widget.towarId ?? '',
                            projectName: widget.projectName,
                            towarName: widget.towarName ?? '',
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 24, vertical: isMobile ? 4 : 6),
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
                                temp.taskTitle ?? '',
                                style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              temp.taskCompleteStatus == '1'
                                  ? Icons.check_circle_outline_sharp
                                  : Icons.circle_outlined,
                              color: temp.taskCompleteStatus == '1'
                                  ? Colors.green
                                  : Colors.grey,
                              size: isMobile ? 20 : 22,
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: showDeleteTaskDialog,
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
                          title: "Assigned On",
                          titleValue: temp.taskCreateAt ?? '',
                        ),
                        rowThreeText(
                          context: context,
                          title: "Deadline",
                          titleValue: temp.taskDeadline ?? '',
                          titleValueColor: temp.taskDeadlineStatus == '1'
                              ? Colors.red
                              : Colors.black,
                        ),
                        rowThreeText(
                          context: context,
                          title: "Assign To",
                          titleValue: temp.assignTo ?? '',
                        ),
                        rowThreeText(
                          context: context,
                          title: "Assignor",
                          titleValue: temp.assignBy ?? '',
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 2),
            ),
          ),
        ],
      ),
    );
  }

  customShowUpdateDialogAddAssignor({
    required String meetingId,
  }) async {
    List<MemberDetail> projectUsersList = [];

    Set<String> currentShareWithIds = {};
    for (var m in shareWithMemberDetails) {
      if (m.memberId != null && m.memberId!.isNotEmpty) {
        currentShareWithIds.add(m.memberId!);
      }
    }
    if (shareDetails != null) {
      for (var s in shareDetails!) {
        if (s.memberId != null && s.memberId!.isNotEmpty) {
          currentShareWithIds.add(s.memberId!);
        }
      }
    }

    if (AppUrl.useNewBackend && widget.projectId != null && widget.projectId!.isNotEmpty) {
      try {
        await apiNetworkHandler.ensureProjectContext(widget.projectId);
        var response = await apiNetworkHandler.get(
          AppUrl.getProjectUsers(widget.projectId!),
        );

        if (response != null && response.statusCode == 200) {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic> && decoded['success'] == true && decoded['data'] is List) {
            for (var u in decoded['data']) {
              if (u is Map) {
                String uId = u['id']?.toString() ?? '';
                String uName = u['name']?.toString() ?? '';
                String uType = u['user_type']?.toString() ?? '';
                projectUsersList.add(MemberDetail(
                  memberId: uId,
                  memberName: uName,
                  compayName: uType,
                  isSelected: currentShareWithIds.contains(uId),
                ));
              }
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('MeetingDetailsScreen: Error fetching project users for share: $e');
        }
      }
    } else {
      projectUsersList = List<MemberDetail>.from(memberDetailsResShareMeeting ?? []);
      for (var member in projectUsersList) {
        if (shareDetails!.any((share) => share.memberId == member.memberId)) {
          member.isSelected = true;
        }
      }
    }

    if (!mounted) return;

    TextEditingController searchController = TextEditingController();
    String searchQuery = '';

    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState1) {
          final filteredList = projectUsersList
              .where((member) =>
                  (member.memberName ?? '')
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()) ||
                  (member.contactNubmer ?? '')
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()))
              .toList();

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
              padding: const EdgeInsets.symmetric(vertical: 14),
              width: double.infinity,
              child: const Text(
                "Share Meeting",
                style: TextStyle(
                  fontFamily: 'HelveticaNeue',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            content: SizedBox(
              height: 340,
              width: 400,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      onChanged: (value) {
                        setState1(() {
                          searchQuery = value;
                        });
                      },
                      style: const TextStyle(fontSize: 13),
                      controller: searchController,
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          labelText: "Search by Name or Contact",
                          hintText: "Search by Name or Contact",
                          prefixIcon: Icon(Icons.search, size: 18),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0)))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredList.length,
                      itemBuilder: (context, i) {
                        final item = filteredList[i];
                        final bool isSelected = item.isSelected == true;
                        final bool isCurrentProfile = profileId == item.memberId;
                        return AnimatedOpacity(
                          opacity: isCurrentProfile ? 0.4 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.withValues(alpha: 0.15),
                                ),
                              ),
                            ),
                            margin: const EdgeInsets.only(bottom: 4),
                            child: InkWell(
                              onTap: () {
                                if (!isCurrentProfile) {
                                  setState1(() {
                                    item.isSelected = !isSelected;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xfff8f9fa)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.memberName ?? '',
                                          style: TextStyle(
                                            fontFamily: 'HelveticaNeue',
                                            fontSize: 15,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? Colors.black
                                                : Colors.black87,
                                          ),
                                        ),
                                        if ((item.compayName ?? '').isNotEmpty)
                                          Text(
                                            item.compayName ?? '',
                                            style: const TextStyle(
                                                fontSize: 12, color: Colors.grey),
                                          ),
                                      ],
                                    ),
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle_outline_rounded
                                          : Icons.circle_outlined,
                                      color: isSelected ? Colors.green : Colors.grey,
                                      size: 20,
                                    )
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
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (AppUrl.useNewBackend) {
                            List<int> selectedUserIds = [];
                            for (var member in projectUsersList) {
                              if (member.isSelected == true) {
                                int? parsedId = int.tryParse(member.memberId ?? '');
                                if (parsedId != null) {
                                  selectedUserIds.add(parsedId);
                                }
                              }
                            }

                            try {
                              if (widget.projectId != null && widget.projectId!.isNotEmpty) {
                                await apiNetworkHandler.ensureProjectContext(widget.projectId);
                              }

                              String url = AppUrl.shareMeeting(meetingId);
                              Map<String, String> fields = {
                                "shared_with": json.encode(selectedUserIds),
                              };

                              if (kDebugMode) {
                                print('🚀 [MeetingDetailsScreen] PATCH shareMeeting: $url fields: $fields');
                              }

                              var response = await apiNetworkHandler.patchMultipart(url, fields);

                              if (kDebugMode) {
                                print('📥 [MeetingDetailsScreen] shareMeeting Status: ${response.statusCode}');
                                print('   Body: ${response.body}');
                              }

                              if (response.statusCode == 200 || response.statusCode == 201) {
                                if (mounted) {
                                  Navigator.of(context).pop();
                                  getMettingDetailsByUser(meetingId: meetingId);
                                }
                                return;
                              }
                            } catch (e) {
                              if (kDebugMode) {
                                print('Error sharing meeting: $e');
                              }
                            }
                          } else {
                            List<String> selectedIds = [];
                            for (var member in (memberDetailsResShareMeeting ?? [])) {
                              if (member.isSelected == true) {
                                selectedIds.add(member.memberId ?? '');
                              }
                            }
                            String finalIds = selectedIds.join(',');
                            shareMettingWithOthers(
                                meetingId: meetingId, shareUser: finalIds);
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20)),
                          child: const Text(
                            "Share",
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
                ),
              ),
            ],
          );
        });
      },
    );
  }

  customShowUpdateDialog({
    required String meetingId,
  }) async {
    List<MemberDetail> projectUsersList = [];

    Set<String> currentParticipantIds = {};
    if (memberDetailsRes != null) {
      for (var m in memberDetailsRes!) {
        if (m.memberId != null && m.memberId!.isNotEmpty) {
          currentParticipantIds.add(m.memberId!);
        }
      }
    }

    if (AppUrl.useNewBackend && widget.projectId != null && widget.projectId!.isNotEmpty) {
      try {
        await apiNetworkHandler.ensureProjectContext(widget.projectId);
        var response = await apiNetworkHandler.get(
          AppUrl.getProjectUsers(widget.projectId!),
        );

        if (response != null && response.statusCode == 200) {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic> && decoded['success'] == true && decoded['data'] is List) {
            for (var u in decoded['data']) {
              if (u is Map) {
                String uId = u['id']?.toString() ?? '';
                String uName = u['name']?.toString() ?? '';
                String uType = u['user_type']?.toString() ?? '';
                projectUsersList.add(MemberDetail(
                  memberId: uId,
                  memberName: uName,
                  compayName: uType,
                  isSelected: currentParticipantIds.contains(uId),
                ));
              }
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('MeetingDetailsScreen: Error fetching project users: $e');
        }
      }
    } else {
      projectUsersList = List<MemberDetail>.from(memberDetailsRes ?? []);
    }

    if (!mounted) return;

    TextEditingController searchController = TextEditingController();
    String searchQuery = '';

    List<String> originallySelectedIds = (memberDetailsRes ?? [])
        .where((member) => member.isSelected == true)
        .map((member) => member.memberId.toString())
        .toList();

    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState1) {
          final filteredList = projectUsersList
              .where((member) => (member.memberName ?? '')
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
              .toList();

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
              padding: const EdgeInsets.symmetric(vertical: 14),
              width: double.infinity,
              child: const Text(
                "Select Participants",
                style: TextStyle(
                  fontFamily: 'HelveticaNeue',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            content: SizedBox(
              height: 340,
              width: 400,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      onChanged: (value) {
                        setState1(() {
                          searchQuery = value;
                        });
                      },
                      style: const TextStyle(fontSize: 13),
                      controller: searchController,
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          labelText: "Search by Name",
                          hintText: "Search by Name",
                          prefixIcon: Icon(Icons.search, size: 18),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0)))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredList.length,
                      itemBuilder: (context, i) {
                        final item = filteredList[i];
                        final bool isSelected = item.isSelected == true;
                        final bool isCurrentProfile = profileId == item.memberId;
                        return AnimatedOpacity(
                          opacity: isCurrentProfile ? 0.4 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.withValues(alpha: 0.15),
                                ),
                              ),
                            ),
                            margin: const EdgeInsets.only(bottom: 4),
                            child: InkWell(
                              onTap: () {
                                if (!isCurrentProfile) {
                                  setState1(() {
                                    item.isSelected = !isSelected;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xfff8f9fa)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.memberName ?? '',
                                          style: TextStyle(
                                            fontFamily: 'HelveticaNeue',
                                            fontSize: 15,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? Colors.black
                                                : Colors.black87,
                                          ),
                                        ),
                                        if ((item.compayName ?? '').isNotEmpty)
                                          Text(
                                            item.compayName ?? '',
                                            style: const TextStyle(
                                                fontSize: 12, color: Colors.grey),
                                          ),
                                      ],
                                    ),
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle_outline_rounded
                                          : Icons.circle_outlined,
                                      color: isSelected ? Colors.green : Colors.grey,
                                      size: 20,
                                    )
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
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (AppUrl.useNewBackend) {
                            List<int> selectedParticipantIds = [];
                            for (var member in projectUsersList) {
                              if (member.isSelected == true) {
                                int? parsedId = int.tryParse(member.memberId ?? '');
                                if (parsedId != null) {
                                  selectedParticipantIds.add(parsedId);
                                }
                              }
                            }

                            try {
                              if (widget.projectId != null && widget.projectId!.isNotEmpty) {
                                await apiNetworkHandler.ensureProjectContext(widget.projectId);
                              }

                              String url = AppUrl.updateMeetingParticipants(meetingId);
                              Map<String, String> fields = {
                                "participants": json.encode(selectedParticipantIds),
                              };

                              if (kDebugMode) {
                                print('🚀 [MeetingDetailsScreen] PATCH updateMeetingParticipants: $url fields: $fields');
                              }

                              var response = await apiNetworkHandler.patchMultipart(url, fields);

                              if (kDebugMode) {
                                print('📥 [MeetingDetailsScreen] updateMeetingParticipants Status: ${response.statusCode}');
                                print('   Body: ${response.body}');
                              }

                              if (response.statusCode == 200 || response.statusCode == 201) {
                                if (mounted) {
                                  Navigator.of(context).pop();
                                  getMettingDetailsByUser(meetingId: meetingId);
                                }
                                return;
                              }
                            } catch (e) {
                              if (kDebugMode) {
                                print('Error updating meeting participants: $e');
                              }
                            }
                          } else {
                            _participantsController.clear();
                            setState1(() {
                              participantsNumberSelected = '';
                              selectedMember?.clear();
                            });

                            for (int i = 0; i < (memberDetailsRes?.length ?? 0); i++) {
                              if (memberDetailsRes?[i].isSelected == true) {
                                setState1(() {
                                  participantsNumberSelected = participantsNumberSelected
                                              .trim() ==
                                          ''
                                      ? '${memberDetailsRes?[i].memberId}'
                                      : "$participantsNumberSelected,${memberDetailsRes?[i].memberId ?? ''}";
                                  selectedMember?.add(memberDetailsRes![i]);
                                });
                                _participantsController.text = _participantsController
                                            .text
                                            .trim() ==
                                        ''
                                    ? '${memberDetailsRes?[i].memberName}'
                                    : "${_participantsController.text},${memberDetailsRes?[i].memberName ?? ''}";
                              }
                            }

                            List<String> finalSelectedIds = (selectedMember ?? [])
                                .map((member) => member.memberId.toString())
                                .toList();

                            List<String> removedParticipants = originallySelectedIds
                                .where((id) => !finalSelectedIds.contains(id))
                                .toList();

                            String removedParticipantsString =
                                removedParticipants.join(',');

                            addPartipantsByMeetingId(
                              meetingId: meetingId,
                              removedParticipantIds: removedParticipantsString,
                            );

                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20)),
                          child: const Text(
                            "OK",
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
                ),
              ),
            ],
          );
        });
      },
    );
  }
}
