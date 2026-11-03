import 'package:stallion/ui/views/accountmanagement/account_management_preview.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/models/track_assign.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/accountmanagement/porequested.dart';
import 'package:stallion/ui/views/accountmanagement/worequested.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/utils/app_url.dart';

class TrackAccountManagement extends StatefulWidget {
  const TrackAccountManagement({
    super.key,
    required this.projectId,
    required this.towarId,
    required this.projectName,
    required this.towarName,
  });
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;

  @override
  State<TrackAccountManagement> createState() => _TrackAccountManagementState();
}

class _TrackAccountManagementState extends State<TrackAccountManagement> {
  bool isPoSelected = true;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<TrackList>? trackList = [];

  Future<TrackList?> getTrackAssign() async {
    CustomLoading.progressDialog(isLoading: true, context: context);
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));
    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
      "track_status": isPoSelected == true ? "0" : "1",
    };
    var response = await AccountManagementPreviewNetwork()
        .post(AppUrl.webTrackingAssignToList, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = trackAssignFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          trackList = dataModel.response?.trackList;
        });
      }
    }
    CustomLoading.progressDialog(isLoading: false, context: context);
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
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 10, bottom: 8),
            width: double.maxFinite,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black),
              ),
            ),
            child: const Text(
              "TRACK PO & WO ASSIGN",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isPoSelected = true;
                      });
                      getTrackAssign();
                    },
                    child: Container(
                      color: isPoSelected == true ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "PO ASSIGN",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isPoSelected == true
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isPoSelected = false;
                      });
                      getTrackAssign();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      color: isPoSelected == true ? Colors.white : Colors.black,
                      child: Text(
                        "WO ASSIGN",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isPoSelected == true
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
                border: Border(
              bottom: BorderSide(
                color: Colors.black,
              ),
            )),
            padding: const EdgeInsets.only(bottom: 8, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 4,
                  // padding: EdgeInsets.only(left: 120),
                  child: const Text(
                    "Employee Name",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 4,
                  child: const Text(
                    "Pending / Assigned",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 4,
                  // padding: EdgeInsets.only(right: 150),
                  child: const Text(
                    "Action",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          for (int i = 0; i < trackList!.length; i++)
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black45,
                  ),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 8, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    // padding: EdgeInsets.only(left: 120),
                    child: Text(
                      trackList?[i].transEmpName ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        // fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: Text(
                      '${trackList?[i].pendingCount} / ${trackList?[i].totalCount}',
                      style: const TextStyle(
                        fontSize: 16,
                        // fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (_) {
                            //       return TrackPermissionList(
                            //         projectId: widget.projectId,
                            //         towarId: widget.towarId,
                            //         projectName: widget.projectName,
                            //         towarName: widget.towarName,
                            //         assignToId:
                            //             permissionTrackingListData?[i].transEmpId,
                            //         transEmpName: permissionTrackingListData?[i]
                            //             .transEmpName,
                            //       );
                            //     },
                            //   ),
                            // );
                            if (isPoSelected == true) {
                              // Navigator.push(context,
                              //     MaterialPageRoute(builder: (_) {
                              //   return PoRequestedView(
                              //       assignToId: trackList?[i].transEmpId ?? '',
                              // projectId: widget.projectId! == ''
                              //     ? ""
                              //     : widget.projectId!,
                              //       towarId: widget.towarId!,
                              // projectName: widget.projectName! == ''
                              //     ? ""
                              //     : widget.projectName!,
                              //       flagRedirect: '');
                              // }));
                              Navigator.of(context).pushNamed(
                                '/poRequestedViewScreen',
                                arguments: NotificationArgs(
                                  projectId: widget.projectId! == ''
                                      ? ""
                                      : widget.projectId!,
                                  projectName: widget.projectName! == ''
                                      ? ""
                                      : widget.projectName!,
                                  towarName: widget.towarName,
                                  response: NotificationResponseData(
                                    assignToId: trackList?[i].transEmpId ?? '',
                                    flagRedirect: '',
                                    towarId: widget.towarId,
                                  ),
                                ),
                              );
                            } else {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (_) {
                              //       return WoRequestedView(
                              //           assignToId:
                              //               trackList?[i].transEmpId ?? '',
                              //           projectId: widget.projectId!,
                              //           towarId: widget.towarId!,
                              //           projectName: widget.projectName!,
                              //           flagRedirect: 'RequestedNew');
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
                                    assignToId: trackList?[i].transEmpId ?? '',
                                    flagRedirect: 'RequestedNew',
                                    towarId: widget.towarId,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black54),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "View",
                              style: TextStyle(
                                fontSize: 16,
                                // fontWeight: FontWeight.w600,
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
            )
        ],
      ),
    );
  }
}
