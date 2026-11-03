import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/manage_finishing_work_type.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/finishing/new_finishing/add_exterior_list.dart';
import 'package:stallion/utils/app_url.dart';

class AddFinishing extends StatefulWidget {
  const AddFinishing(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      required this.isInterior,
      this.towarName})
      : super(key: key);
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String isInterior;

  @override
  State<AddFinishing> createState() => _AddFinishingState();
}

class _AddFinishingState extends State<AddFinishing> {
  bool isCheckSelected = false;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<FinishingProjectList>? finishingProjectListData = [];
  TextEditingController searchController = TextEditingController();
  String searchText = '';

  List<FinishingProjectList>? filteredProjects() {
    if (searchText.isEmpty) {
      return finishingProjectListData;
    }
    return finishingProjectListData!.where((project) {
      return project.mstWorkName!
          .toLowerCase()
          .contains(searchText.toLowerCase());
    }).toList();
  }

  List<FinishingProjectListTemp> tempData = [];

  Future<List<FinishingProjectList>?> getFinishingAddNew() async {
    try {
      CustomLoading.progressDialog(isLoading: true, context: context);
      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "project_id": widget.projectId ?? '',
        "towar_id": widget.towarId ?? '',
        'limit': '20',
        'finishing_type': widget.isInterior,
      };

      if (kDebugMode) {
        print(data);
      }

      var response =
          await apiNetworkHandler.post(AppUrl.manageFinishingWorkType, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = manageFinishingWorkTypeFromJson(response.body);
        if (dataModel.response?.errorCode == "0") {
          setState(() {
            // tempp = dataModel.response;
            // tempData = dataModel.response!.finishingProjectList ?? [];
            // tempData = List<FinishingProjectList>.from(
            //     dataModel.response!.finishingProjectList ?? []);

            // tempData = (dataModel.response!.finishingProjectList ?? [])
            //     .map((item) => FinishingProjectList.fromJson(item.toJson()))
            //     .toList();

            finishingProjectListData = dataModel.response?.finishingProjectList;

            finishingProjectListData?.sort((a, b) {
              if (a.isActive == b.isActive) {
                return a.mstWorkName!.compareTo(b.mstWorkName ?? '');
              }
              return b.isActive!.compareTo(a.isActive ?? '');
            });

            tempData = (finishingProjectListData ?? []).map((item) {
              // Extracting specific values and creating a new instance of FinishingProjectList
              return FinishingProjectListTemp(
                // Assuming 'isActive' is the property you want to modify
                isActive: item.isActive,
                mstFinishingId: item.mstFinishingId,
                // Add other properties you need here
              );
            }).toList();
          });
        }
      } else {}
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
    } finally {
      // ignore: use_build_context_synchronously
      CustomLoading.progressDialog(isLoading: false, context: context);
    }
    return null;
  }

  Future<List<FinishingProjectList>?> setFinishingAddNew({
    required List<FinishingProjectListTemp>? dataa,
  }) async {
    try {
      CustomLoading.progressDialog(isLoading: true, context: context);
      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');
      // inspect(dataa);

      Map<String, String> data = {
        "user_id": userId ?? '',
        "project_id": widget.projectId ?? '',
        "towar_id": widget.towarId ?? '',
        // 'limit': '20',
        'finishing_type': widget.isInterior,
        "finishing_arr": jsonEncode(dataa),
      };

      if (kDebugMode) {
        print(data);
      }

      var response =
          await apiNetworkHandler.post(AppUrl.setManageFinishingWorkType, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      // if (response.statusCode == 200 || response.statusCode == 201) {
      //   final dataModel = manageFinishingWorkTypeFromJson(response.body);
      //   if (dataModel.response?.errorCode == "0") {
      //     // setState(() {});
      //   }
      // } else {}
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
    } finally {
      // ignore: use_build_context_synchronously
      CustomLoading.progressDialog(isLoading: false, context: context);

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
                "Successfully Added to Project.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              actions: [
                InkWell(
                  onTap: () {
                    // Navigator.of(context).pop();

                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
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
    return null;
  }

  confirmationModal({
    required List<FinishingProjectListTemp>? dataa,
  }) {
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
              "Are you Sure, You want to Save the Changes?",
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

                  // Navigator.of(context).pop();
                  // Navigator.of(context).pop();
                },
                child: Container(
                  width: 130,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(7)),
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
                onTap: () {
                  Navigator.of(context).pop();
                  setFinishingAddNew(dataa: dataa);

                  // Navigator.of(context).pop();
                  // Navigator.of(context).pop();
                },
                child: Container(
                  width: 130,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(7)),
                  child: const Text(
                    "Yes",
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

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getFinishingAddNew();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: InkWell(
        onTap: () {
          // Navigator.of(context).pop();
          List<FinishingProjectListTemp>? newTempFinishingProjectListData = [];
          for (int i = 0; i < tempData.length; i++) {
            //   print(
            //       '${tempFinishingProjectListData?[i].finishingName} ${tempFinishingProjectListData?[i].isActive} -----${finishingProjectListData?[i].finishingName} ${finishingProjectListData?[i].isActive}');
            if (tempData[i].isActive != finishingProjectListData?[i].isActive) {
              tempData[i].isActive = finishingProjectListData?[i].isActive;
              newTempFinishingProjectListData.add(tempData[i]);
            }
          }
          inspect(newTempFinishingProjectListData);
          // print(tempFinishingProjectListData);
          // setFinishingAddNew(dataa: newTempFinishingProjectListData);
          confirmationModal(dataa: newTempFinishingProjectListData);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.black,
          height: 50,
          child: const Text(
            'Add To Project',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
            widget.towarName!.isNotEmpty
                ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                : widget.projectName!.toUpperCase(),
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        // actions: [
        //   InkWell(
        //     onTap: () {
        //       var projectId = widget.projectId!;
        //       var projectName = widget.projectName!;
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (_) {
        //             return AddExteriorList(
        //               projectId: projectId,
        //               towarId: widget.towarId!,
        //               projectName: projectName,
        //               towarName: widget.towarName!,
        //             );
        //           },
        //         ),
        //       );
        //     },
        //     child: Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //       decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(6),
        //         color: Colors.white,
        //       ),
        //       child: const Text(
        //         'ADD EXTERIOR LIST',
        //         style: TextStyle(
        //           fontSize: 16,
        //           fontWeight: FontWeight.w600,
        //           color: Colors.black,
        //         ),
        //       ),
        //     ),
        //   ),
        //   const SizedBox(width: 30),
        // ],
      ),
      body: Column(
        children: [
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 80, vertical: 4),
          //   child: TextFormField(
          //     controller: searchController,
          //     onChanged: (value) {
          // setState(() {
          //   // filteredProjects();
          //   searchText = value;
          // });
          //     },
          //   ),
          // ),

          Container(
            padding:
                const EdgeInsets.only(left: 66, right: 66, bottom: 10, top: 12),
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        // filteredProjects();
                        searchText = value;
                      });
                    },
                    style: const TextStyle(fontSize: 13),
                    controller: searchController,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(12.0),
                        labelText: "Search by Name",
                        hintText: "Search by Name",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchController.text.length > 0
                            ? InkWell(
                                onTap: () {
                                  searchController.clear();
                                  setState(() {
                                    // filteredProjects();
                                    searchText = "";
                                  });
                                  filteredProjects();
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: const Icon(Icons.close_rounded),
                                ),
                              )
                            : const SizedBox.shrink(),
                        border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)))),
                  ),
                ),
                InkWell(
                  onTap: () {
                    // Navigator.of(context).pop();
                    List<FinishingProjectListTemp>?
                        newTempFinishingProjectListData = [];
                    for (int i = 0; i < tempData.length; i++) {
                      //   print(
                      //       '${tempFinishingProjectListData?[i].finishingName} ${tempFinishingProjectListData?[i].isActive} -----${finishingProjectListData?[i].finishingName} ${finishingProjectListData?[i].isActive}');
                      if (tempData[i].isActive !=
                          finishingProjectListData?[i].isActive) {
                        tempData[i].isActive =
                            finishingProjectListData?[i].isActive;
                        newTempFinishingProjectListData.add(tempData[i]);
                      }
                    }
                    inspect(newTempFinishingProjectListData);
                    // print(tempFinishingProjectListData);
                    // setFinishingAddNew(dataa: newTempFinishingProjectListData);
                    confirmationModal(dataa: newTempFinishingProjectListData);
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 40),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(100)),
                    child: Text(
                      "Add To Project",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
                // color: Colors.grey,
                child: const Text(
                  'Select',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                // color: Colors.grey,
                child: Text(
                  'Finishing ${widget.isInterior != '1' ? 'Interior' : "Exterior"} Name',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
                // color: Colors.grey,
                child: const Text(
                  'Unit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: filteredProjects()!.length == 0
                ? Center(
                    child: Text(
                      "No Record Found",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  )
                : SingleChildScrollView(
                    child: ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      shrinkWrap: true,
                      itemCount: filteredProjects()!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final FinishingProjectList? project =
                            filteredProjects()?[index];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.1,
                              // color: Colors.grey,
                              child: Checkbox(
                                value: int.parse(project!.isActive ?? '') == 1
                                    ? true
                                    : false,
                                onChanged: (value) {
                                  setState(() {
                                    project?.isActive =
                                        value == true ? "1" : "0";
                                    print(project?.isActive);
                                    print(tempData[index].isActive);
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              // color: Colors.grey,
                              child: Text(
                                project.mstWorkName ?? '',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.1,
                              // color: Colors.grey,
                              child: Text(
                                project.unit ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
