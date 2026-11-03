import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_finishing_exterior_list_new.dart';
import 'package:stallion/models/get_finishing_interior_new.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/finishing/new_finishing/add_finishing.dart';
import 'package:stallion/ui/views/finishing/new_finishing/certify_finishing.dart';
import 'package:stallion/ui/views/finishing/new_finishing/checklist_finishing/checklist_finishing_screen.dart';
import 'package:stallion/ui/views/finishing/new_finishing/daily_progress_report_interior.dart';
import 'package:stallion/ui/views/finishing/new_finishing/finishing_interior_new.dart';
import 'package:stallion/ui/views/finishing/new_finishing/inventory_quantification.dart';
import 'package:stallion/utils/app_url.dart';

class FinishingManagement extends StatefulWidget {
  const FinishingManagement(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.towarName})
      : super(key: key);
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;

  @override
  State<FinishingManagement> createState() => _FinishingManagementState();
}

class _FinishingManagementState extends State<FinishingManagement> {
  bool isInterior = false;

  TextEditingController searchController = TextEditingController();
  String searchText = '';
  int selectedDropdownOpen = 0;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<FinalResult>? finalResult = [];
  List<FinalResultInterior>? finalResultInterior = [];
  String formatToIndianStandard(double numberString) {
    final indianRupeesFormat = NumberFormat.currency(
      name: "INR",
      locale: 'en_IN',
      decimalDigits: 0, // change it to get decimal places
      symbol: '',
    );

    return indianRupeesFormat.format(numberString);
  }

  Future<List<FinalResult>?> getFinishingExteriorNew() async {
    try {
      CustomLoading.progressDialog(isLoading: true, context: context);
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
          await apiNetworkHandler.post(AppUrl.getFinishingExteriorNew, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = getFinishingExteriorListNewFromJson(response.body);
        if (dataModel.response?.errorCode == "0") {
          setState(() {
            finalResult = dataModel.response?.finalResult;
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

  Future<List<FinalResultInterior>?> getFinishingInteriorNew() async {
    try {
      CustomLoading.progressDialog(isLoading: true, context: context);
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
          await apiNetworkHandler.post(AppUrl.getFinishingInteriorList, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = getFinishingInteriorNewFromJson(response.body);
        if (dataModel.response?.errorCode == "0") {
          setState(() {
            inspect(dataModel.response?.finalResult);
            finalResultInterior = dataModel.response?.finalResult;
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

  Future<List<FinalResultInterior>?> setFinishingExteriorQuantification(
      {required List<FinalResultTemp>? dataa}) async {
    try {
      CustomLoading.progressDialog(isLoading: true, context: context);
      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "project_id": widget.projectId ?? '',
        "towar_id": widget.towarId ?? '',
        'finishing_type': "1",
        'finishing_arr': jsonEncode(dataa),
      };

      if (kDebugMode) {
        print(data);
      }

      var response = await apiNetworkHandler.post(
          AppUrl.setFinishingExteriorQuantification, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomLoading.progressDialog(isLoading: false, context: context);

        getFinishingExteriorNew().then((value) => {
              Future.delayed(const Duration(milliseconds: 200), () {
// Here you can write your code
                showDialog<void>(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // Set radius to zero
                        ),
                        titlePadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        actionsPadding: const EdgeInsets.only(
                            bottom: 10, left: 10, right: 10),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        actionsAlignment: MainAxisAlignment.center,
                        title: const Text(
                          "Saved Successfully.",
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

                              // Navigator.of(context).pop();
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

                // setState(() {
                //   // Here you can write your code for open new view
                // });
              }),
            });

        // final dataModel = getFinishingInteriorNewFromJson(response.body);
        // if (dataModel.response?.errorCode == "0") {
        //   // setState(() {
        //   //   finalResultInterior = dataModel.response?.finalResult;
        //   // });
        // }
      } else {}
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
    } finally {
      // ignore: use_build_context_synchronously
    }
    return null;
  }
  // List<FinalResult>? finalResult = [];

  List<FinalResult>? filteredProjects() {
    if (searchText.isEmpty) {
      return finalResult;
    }
    return finalResult!.where((project) {
      return project.finishingName!
          .toLowerCase()
          .contains(searchText.toLowerCase());
    }).toList();
  }

  confirmationModal({required List<FinalResultTemp>? dataa}) {
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
              "Are you Sure, You want to update Exterior Quantification?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            actions: [
              InkWell(
                onTap: () {
                  for (int i = 0; i < dataa!.length; i++) {
                    for (int j = 0; j < finalResult!.length; j++) {
                      if (dataa[i].id == finalResult?[j].finishingId) {
                        setState(() {
                          finalResult?[j].boqQuantity =
                              finalResult?[j].boqQuantityTemp;
                          finalResult?[j].controller?.clear();
                        });
                        // filteredProjects()?[i].boqQuantity =
                        //                   value != ""
                        //                       ? value
                        //                       : filteredProjects()?[i]
                        //                           .boqQuantityTemp;
                      }
                    }
                  }
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
                  setFinishingExteriorQuantification(dataa: dataa);
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

  pleaseSaveChangesModal() {
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
              "Please Save Changes?",
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
                  width: 230,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(7)),
                  child: const Text(
                    "Ok",
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
      getFinishingExteriorNew();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: isInterior
          ? const SizedBox.shrink()
          : InkWell(
              onTap: () {
                // finalResult
                List<FinalResultTemp>? tempData =
                    (finalResult ?? []).map((item) {
                  return FinalResultTemp(
                      id: item.finishingId,
                      // qty: item.controller?.text == "" ? "0" : item.controller?.text,
                      qty: item.boqQuantity);
                }).toList();

                // inspect(tempData);
                // setFinishingExteriorQuantification(dataa: tempData);
                confirmationModal(dataa: tempData);
              },
              child: Container(
                color: Colors.black,
                height: 44,
                child: const Center(
                  child: Text(
                    "SAVE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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
        actions: [
          // OutlinedButton(
          //   onPressed: () {
          //     // setState(() {
          //     //   slabId = plist.masonryId;
          //     // });
          //     var projectId = widget.projectId!;
          //     var projectName = widget.projectName!;
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) {
          //           return CheckListMasonryScreen(
          //             projectId: projectId,
          //             towarId: widget.towarId!,
          //             projectName: projectName,
          //             towarName: widget.towarName!,
          //             title: 'plist.masonryId',
          //             slabId: 'slabId',
          //           );
          //         },
          //       ),
          //     ).then((value) {});
          //   },
          //   style: OutlinedButton.styleFrom(
          //     side: const BorderSide(width: 1.0, color: Colors.black45),
          //   ),
          //   child: const Text('         Checklist         ', style: normalText),
          // ),

          InkWell(
            onTap: () {
              var projectId = widget.projectId!;
              var projectName = widget.projectName!;

              // setState(() {
              //   slabId = plist.masonryId;
              // });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return CheckListFinishingScreen(
                      projectId: projectId,
                      towarId: widget.towarId!,
                      projectName: projectName,
                      towarName: widget.towarName!,
                      title: 'plist.masonryId',
                      slabId: '0',
                    );
                  },
                ),
              ).then((value) {
                if (isInterior) {
                  getFinishingInteriorNew();
                } else {
                  getFinishingExteriorNew();
                }
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 15),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
              ),
              child: const Text(
                'Checklist',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          InkWell(
            onTap: () {
              var projectId = widget.projectId!;
              var projectName = widget.projectName!;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return DailyProgressReportInterior(
                      projectId: projectId,
                      towarId: widget.towarId!,
                      projectName: projectName,
                      towarName: widget.towarName!,
                      title: '',
                      slabId: '',
                    );
                    // return AddFinishing(
                    //   isInterior: isInterior ? "2" : "1",
                    //   projectId: projectId,
                    //   towarId: widget.towarId!,
                    //   projectName: projectName,
                    //   towarName: widget.towarName!,
                    // );
                  },
                ),
              ).then((value) {
                if (isInterior) {
                  getFinishingInteriorNew();
                } else {
                  getFinishingExteriorNew();
                }
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 15),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
              ),
              child: const Text(
                'DPR',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          if (isInterior)
            InkWell(
              onTap: () {
                var projectId = widget.projectId!;
                var projectName = widget.projectName!;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return InventoryQuantification(
                        isInterior: isInterior ? "2" : "1",
                        projectId: projectId,
                        towarId: widget.towarId!,
                        projectName: projectName,
                        towarName: widget.towarName!,
                      );
                    },
                  ),
                ).then((value) {
                  getFinishingInteriorNew();
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                child: const Text(
                  'Inventory Quantification',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          // const SizedBox(width: 15),
          if (isInterior == false)
            InkWell(
              onTap: () {
                var projectId = widget.projectId!;
                var projectName = widget.projectName!;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return AddFinishing(
                        isInterior: isInterior ? "2" : "1",
                        projectId: projectId,
                        towarId: widget.towarId!,
                        projectName: projectName,
                        towarName: widget.towarName!,
                      );
                    },
                  ),
                ).then((value) {
                  if (isInterior) {
                    getFinishingInteriorNew();
                  } else {
                    getFinishingExteriorNew();
                  }
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                child: const Text(
                  'Add/Edit Work Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 30),
        ],
      ),
      body: Column(
        children: [
          if (isInterior == false)
            Container(
              padding: const EdgeInsets.only(
                  left: 66, right: 66, bottom: 10, top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
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
                  if (!isInterior)
                    InkWell(
                      onTap: () {
                        // finalResult
                        List<FinalResultTemp>? tempData =
                            (finalResult ?? []).map((item) {
                          return FinalResultTemp(
                              id: item.finishingId,
                              // qty: item.controller?.text == "" ? "0" : item.controller?.text,
                              qty: item.boqQuantity);
                        }).toList();

                        // inspect(tempData);
                        // setFinishingExteriorQuantification(dataa: tempData);
                        confirmationModal(dataa: tempData);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 40),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(100)),
                        child: const Text(
                          "SAVE",
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
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                    child: InkWell(
                  onTap: () {
                    setState(() {
                      isInterior = false;
                    });
                    getFinishingExteriorNew();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: isInterior ? Colors.transparent : Colors.black,
                    child: Text(
                      "Exterior",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isInterior ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                )),
                Expanded(
                    child: InkWell(
                  onTap: () {
                    getFinishingInteriorNew();
                    setState(() {
                      isInterior = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: isInterior ? Colors.black : Colors.transparent,
                    child: Text(
                      "Interior",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isInterior ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
          isInterior ? interiorContainer() : exteriorContainer()
        ],
      ),
    );
  }

  Widget interiorContainer() {
    return Column(
      children: [
        const SizedBox(height: 8),

        SizedBox(
          height: MediaQuery.of(context).size.height - 148,
          child: finalResultInterior!.length == 0
              ? const Center(
                  child: Text(
                    "No Record Found",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                )
              : SingleChildScrollView(
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: finalResultInterior!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return FinishingInteriorNew(
                          isInterior: isInterior ? "2" : "1",
                          headerPart: finalResultInterior?[index].headerPart,
                          bodyPart: finalResultInterior?[index].bodyPart,
                          projectId: widget.projectId,
                          towarId: widget.towarId!,
                          projectName: widget.projectName,
                          towarName: widget.towarName!,
                          index: index,
                          selectedDropdownOpen: selectedDropdownOpen,
                          onTap: () {
                            getFinishingInteriorNew();
                          },
                          onTapOpenDropDown: () {
                            setState(() {
                              if (selectedDropdownOpen != index) {
                                selectedDropdownOpen = index;
                              } else {
                                selectedDropdownOpen = -1;
                              }
                              // selectedDropdownOpen = index;
                            });
                          });
                    },
                  ),
                ),
        )
        // FinishingInteriorNew
        //     // FinishingManagement
        //     (
        //   projectId: widget.projectId,
        //   towarId: widget.towarId!,
        //   projectName: widget.projectName,
        //   towarName: widget.towarName!,
        // ),
        // QuantificationScreen(),
      ],
    );
  }

  Color getColorCode({required double quantity, required double certifyQty}) {
    if (certifyQty == 0.00 && quantity > 0.0) {
      return Colors.transparent;
    } else if (quantity == certifyQty &&
        certifyQty != 0.00 &&
        quantity != 0.00) {
      return Colors.green;
    } else if (certifyQty == 0.00 && quantity == 0.00) {
      return Colors.transparent;
    } else {
      return const Color.fromRGBO(255, 235, 59, 1);
    }
  }

  Widget exteriorContainer() {
    return Column(
      children: [
        // const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: Colors.black12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                // color: Colors.grey,
                child: const Text(
                  'Finishing Exterior Name',
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
                  'Certify Quantity',
                  textAlign: TextAlign.center,
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
                  'Total BOQ',
                  textAlign: TextAlign.center,
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
                  'Units',
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
                  'Work Completed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.11,
                // color: Colors.grey,
                child: const Text(
                  '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        // const Divider(),
        SizedBox(
          height: MediaQuery.of(context).size.height - 257,
          child: filteredProjects()!.length == 0
              ? const Center(
                  child: Text(
                    "No Record Found",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      for (int i = 0; i < filteredProjects()!.length; i++)
                        Container(
                          padding: EdgeInsets.only(top: i == 0 ? 0 : 14),
                          decoration: BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(color: Colors.grey.shade300)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                // color: Colors.grey,
                                child: Text(
                                  filteredProjects()?[i].finishingName ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    // fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(right: 10, left: 10),
                                width: MediaQuery.of(context).size.width * 0.1,
                                // color: Colors.grey,
                                // child: Text(
                                //   '90',
                                //   style: TextStyle(
                                //     fontSize: 16,
                                //     // fontWeight: FontWeight.w600,
                                //   ),
                                // ),

                                height: 36,
                                child: TextFormField(
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}')),
                                  ],

                                  // inputFormatters: [
                                  //   DecimalTextInputFormatter(decimalRange: 2)
                                  // ],
                                  // keyboardType:
                                  //     TextInputType.numberWithOptions(decimal: true),
                                  // keyboardType: TextInputType.number,
                                  // inputFormatters: <TextInputFormatter>[
                                  //   FilteringTextInputFormatter.digitsOnly
                                  // ], //
                                  // scrollPadding: const EdgeInsets.all(0.0),
                                  controller: filteredProjects()?[i].controller,
                                  onChanged: (value) {
                                    setState(() {
                                      filteredProjects()?[i].boqQuantity =
                                          value != ""
                                              ? value
                                              : filteredProjects()?[i]
                                                  .boqQuantityTemp;
                                    });
                                  },
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 13.0),
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.only(bottom: 0, left: 12),
                                    // border: OutlineInputBorder(
                                    //   borderSide: BorderSide(color: Colors.transparent),
                                    // ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                    ),
                                    hintText: 'Please Enter Quantity',
                                    hintStyle: TextStyle(
                                      color: Color.fromARGB(255, 116, 116, 116),
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w200,
                                      fontFamily: 'HelveticaNeue',
                                    ),
                                    // suffixIcon: Icon(
                                    //   Icons.calendar_month_outlined,
                                    // ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.1,
                                // color: Colors.grey,
                                child: Text(
                                  formatToIndianStandard(double.parse(
                                      filteredProjects()?[i].boqQuantity ??
                                          '0')),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,

                                    // fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.1,
                                // color: Colors.grey,
                                child: Text(
                                  filteredProjects()?[i].unitName ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    // fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.1,
                                // color: Colors.grey,
                                child: Text(
                                  double.parse(filteredProjects()?[i]
                                              .cetifyQuantity ??
                                          '0')
                                      .toStringAsFixed(2),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,

                                    // fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: getColorCode(
                                          quantity: double.parse(
                                              filteredProjects()?[i]
                                                      .boqQuantity ??
                                                  '0'),
                                          certifyQty: double.parse(
                                              filteredProjects()?[i]
                                                      .cetifyQuantity ??
                                                  '0')),
                                      width: 3,
                                    ),
                                  ),
                                ),
                                width: MediaQuery.of(context).size.width * 0.1,
                                // color: Colors.grey,
                                child: InkWell(
                                  onTap: () {
                                    if (filteredProjects()?[i].boqQuantity ==
                                        filteredProjects()?[i]
                                            .boqQuantityTemp) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) {
                                            // return AddFinishingWorkExterior(
                                            //   isInterior:
                                            //       isInterior ? "2" : "1",
                                            //   finishingDetails:
                                            //       filteredProjects()?[i],
                                            //   floorId: '0',
                                            //   // flatDetailsListSelected:
                                            //   //     widget.flatDetailsListSelected, finishingListExterior
                                            //   // finishingListData:
                                            //   //     finishingListData?[index],
                                            //   projectId: widget.projectId,
                                            //   towarId: widget.towarId!,
                                            //   projectName: widget.projectName,
                                            //   towarName: widget.towarName!,
                                            //   // slabName: "Internal Paint (R-101)",
                                            // );
                                            return CertifyFinishingScreen(
                                              certifiedQty: double.parse(
                                                  filteredProjects()?[i]
                                                          .cetifyQuantity ??
                                                      '0'),
                                              totalQty: double.parse(
                                                  filteredProjects()?[i]
                                                          .boqQuantity ??
                                                      '0'),
                                              floorName: filteredProjects()?[i]
                                                      .finishingName ??
                                                  '',
                                              finishingMaterial:
                                                  filteredProjects()?[i]
                                                          .finishingName ??
                                                      '',
                                              projectId: widget.projectId,
                                              towarId: widget.towarId!,
                                              projectName: widget.projectName,
                                              towarName: widget.towarName!,
                                              isInterior: "1",
                                              finishingId:
                                                  filteredProjects()?[i]
                                                          .finishingId ??
                                                      '',
                                              floorId: '0',
                                            );
                                          },
                                        ),
                                      ).then((value) {
                                        getFinishingExteriorNew();
                                      });
                                    } else {
                                      pleaseSaveChangesModal();
                                    }

                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (_) {
                                    //       return AddFinishingWork(
                                    //         // finishingDetails:
                                    //         //     finalResultRes?[k]
                                    //         //         .finishingDetails?[j],
                                    //         // floorName:
                                    //         //     finalResultRes?[k]
                                    //         //         .floorData,
                                    //         // floorId:
                                    //         //     finalResultRes?[k]
                                    //         //         .floorId,
                                    //         // flatDetailsListSelected:
                                    //         //     widget.flatDetailsListSelected,
                                    //         // finishingListData:
                                    //         //     finishingListData?[index],
                                    //         projectId: widget.projectId,
                                    //         towarId: widget.towarId!,
                                    //         projectName: widget.projectName,
                                    //         towarName: widget.towarName!,
                                    //         // slabName: "Internal Paint (R-101)",
                                    //       );
                                    //     },
                                    //   ),
                                    // );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 60,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Colors.black
                                            // color: getColorCode(
                                            //     quantity: double.parse(
                                            //         filteredProjects()?[i]
                                            //                 .boqQuantity ??
                                            //             '0'),
                                            //     certifyQty: double.parse(
                                            //         filteredProjects()?[i]
                                            //                 .cetifyQuantity ??
                                            //             '0')),
                                            ),
                                        child: const Text(
                                          'Certify',
                                          style: TextStyle(
                                            color: Colors.white,
                                            //   fontWeight: FontWeight.w500,
                                          ),
                                          // style: TextStyle(
                                          //   decoration:
                                          //       TextDecoration.underline,
                                          //   decorationColor:
                                          //       Color.fromRGBO(26, 35, 126, 1),
                                          //   fontSize: 13,
                                          //   fontWeight: FontWeight.w400,
                                          //   color:
                                          //       Color.fromRGBO(26, 35, 126, 1),
                                          // ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
        )
      ],
    );
  }
}
