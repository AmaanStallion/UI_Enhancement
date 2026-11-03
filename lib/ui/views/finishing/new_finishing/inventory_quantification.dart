import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/finishing_interior_quantification.dart';
import 'package:stallion/models/get_finishing_interior_new.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/finishing/new_finishing/add_finishing.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/addSalesLeadPage.dart';
import 'package:stallion/utils/app_url.dart';

class InventoryQuantification extends StatefulWidget {
  const InventoryQuantification(
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
  State<InventoryQuantification> createState() =>
      _InventoryQuantificationState();
}

class _InventoryQuantificationState extends State<InventoryQuantification> {
  String formatToIndianStandard(double numberString) {
    final indianRupeesFormat = NumberFormat.currency(
      name: "INR",
      locale: 'en_IN',
      decimalDigits: 0, // change it to get decimal places
      symbol: '',
    );

    return indianRupeesFormat.format(numberString);
  }

  TextEditingController searchController = TextEditingController();
  String searchText = '';

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<HeaderList>? headerListResponse = [];
  String headerTitle = '';
  List<BodyList>? bodyListResponse = [];
  List<BodyList>? filteredProjects() {
    if (searchText.isEmpty) {
      return bodyListResponse;
    }
    return bodyListResponse!.where((project) {
      return project.name!.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
  }

  Future<List<FinalResultInterior>?>
      getFinishingInteriorQuantification() async {
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

      var response = await apiNetworkHandler.post(
          AppUrl.finishingInteriorQuantification, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel =
            finishingInteriorQuantificationFromJson(response.body);
        if (dataModel.response?.errorCode == "0") {
          setState(() {
            // finalResultInterior = dataModel.response?.finalResult;
            headerListResponse = dataModel.response?.finalDetails?.headerList;
            bodyListResponse = dataModel.response?.finalDetails?.bodyList;

            headerTitle = headerListResponse?[0].invFinishTypeName ?? '';
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

  Future<List<FinalResultInterior>?> setFinishingInteriorQuantification(
      {required List<DetailTemp>? dataa}) async {
    try {
      CustomLoading.progressDialog(isLoading: true, context: context);
      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "project_id": widget.projectId ?? '',
        "towar_id": widget.towarId ?? '',
        'finishing_type': "2",
        'finishing_arr': jsonEncode(dataa),
      };

      if (kDebugMode) {
        print(data);
      }

      var response = await apiNetworkHandler.post(
          AppUrl.setFinishingInteriorQuantification, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        getFinishingInteriorQuantification().then(
          (value) => showDialog<void>(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8), // Set radius to zero
                  ),
                  titlePadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  actionsPadding:
                      const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  actionsAlignment: MainAxisAlignment.center,
                  title: const Text(
                    "Successfully Saved.",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          searchController.clear();
                          searchText = '';
                        });
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
              }),
        );

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
      CustomLoading.progressDialog(isLoading: false, context: context);
    }
    return null;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getFinishingInteriorQuantification();
    });
    super.initState();
  }

  confirmationModal({required List<DetailTemp>? dataa}) {
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
              "Are you Sure, You want to update Interior Quantification?",
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
                  setFinishingInteriorQuantification(dataa: dataa);
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
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: InkWell(
        onTap: () {
          // finalResult

          List<DetailTemp>? temppData = [];
          for (int p = 0; p < bodyListResponse!.length; p++) {
            for (int i = 0; i < bodyListResponse![p].details!.length; i++) {
              temppData.add(DetailTemp(
                qty: bodyListResponse![p].details?[i].controller?.text.trim() !=
                        ""
                    ? '${bodyListResponse![p].details?[i].controller?.text}'
                    : "0",
                finishing_id: bodyListResponse![p].details?[i].finishingId,
                type_id: bodyListResponse![p].details?[i].typeId,
              ));
            }
          }
          // List<FinalResultTemp>? tempData = (finalResult ?? []).map((item) {
          //   return FinalResultTemp(
          //     id: item.finishingId,
          //     qty: item.controller?.text == "" ? "0" : item.controller?.text,
          //   );
          // }).toList();

          inspect(temppData);
          // setFinishingInteriorQuantification(dataa: temppData);
          confirmationModal(dataa: temppData);
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
          InkWell(
            onTap: () {
              var projectId = widget.projectId!;
              var projectName = widget.projectName!;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return AddFinishing(
                      isInterior: "2",
                      projectId: projectId,
                      towarId: widget.towarId!,
                      projectName: projectName,
                      towarName: widget.towarName!,
                    );
                  },
                ),
              ).then((value) {
                getFinishingInteriorQuantification();
                // if (isInterior) {
                //   getFinishingInteriorNew();
                // } else {
                //   getFinishingExteriorNew();
                // }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          const SizedBox(width: 48),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                  left: 66, right: 66, bottom: 10, top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                      List<DetailTemp>? temppData = [];
                      bool isDataChanged = false;
                      for (int p = 0; p < bodyListResponse!.length; p++) {
                        for (int i = 0;
                            i < bodyListResponse![p].details!.length;
                            i++) {
                          temppData.add(DetailTemp(
                            qty: bodyListResponse![p]
                                        .details?[i]
                                        .controller
                                        ?.text
                                        .trim() !=
                                    ""
                                ? '${bodyListResponse![p].details?[i].controller?.text}'
                                : "0",
                            finishing_id:
                                bodyListResponse![p].details?[i].finishingId,
                            type_id: bodyListResponse![p].details?[i].typeId,
                          ));
                        }
                      }
                      // List<FinalResultTemp>? tempData = (finalResult ?? []).map((item) {
                      //   return FinalResultTemp(
                      //     id: item.finishingId,
                      //     qty: item.controller?.text == "" ? "0" : item.controller?.text,
                      //   );
                      // }).toList();

                      inspect(temppData);
                      // setFinishingInteriorQuantification(dataa: temppData);
                      confirmationModal(dataa: temppData);
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 40),
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(
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
            filteredProjects()!.length == 0
                ? Container(
                    height: MediaQuery.of(context).size.height - 170,
                    child: Center(
                      child: Text(
                        "No Record Found",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        // color: Colors.amber,
                        width: 220,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey.shade300),
                                  right:
                                      BorderSide(color: Colors.grey.shade300),
                                  top: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              height: 46,
                              width: 220,
                              child: Center(
                                child: Text(
                                  headerTitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            for (int p = 0; p < filteredProjects()!.length; p++)
                              Container(
                                height: 39,
                                width: 220,
                                decoration: BoxDecoration(
                                    border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey.shade300),
                                  right:
                                      BorderSide(color: Colors.grey.shade300),
                                )),
                                child: Center(
                                  child: Text(
                                    filteredProjects()?[p].name ?? '',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      // fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.black12),
                                            top: BorderSide(
                                                color: Colors.black12),
                                            right: BorderSide(
                                                color: Colors.black12))),
                                    width: 220,
                                    height: 46,
                                    child: const Center(
                                        child: Text(
                                      "Units",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    )),
                                  ),
                                  for (int i = 1;
                                      i < headerListResponse!.length;
                                      i++)
                                    Container(
                                      padding: EdgeInsets.only(
                                        left: i % 2 == 0
                                            ? 40
                                            : i ==
                                                    headerListResponse!.length -
                                                        1
                                                ? 50
                                                : 10,
                                        top: i % 2 == 0
                                            ? 0
                                            : i ==
                                                    headerListResponse!.length -
                                                        1
                                                ? 12
                                                : 0,
                                      ),
                                      height: 46,
                                      width: 160,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey.shade300),
                                          top: BorderSide(
                                              color: Colors.grey.shade300),
                                          right: BorderSide(
                                              color: i % 2 == 0
                                                  ? Colors.grey.shade300
                                                  : i ==
                                                          headerListResponse!
                                                                  .length -
                                                              1
                                                      ? Colors.grey.shade300
                                                      : Colors.transparent),
                                        ),
                                      ),
                                      child: Text(
                                        i != headerListResponse!.length - 1
                                            ? '${headerListResponse?[i].qtyPerFlat != "1" ? '' : '${headerListResponse?[i].invFinishTypeName} (${headerListResponse?[i].invFinishTypeSqft})'} ${headerListResponse?[i].qtyPerFlat == "1" ? "\n(Qty Per Flat)" : 'Total Qty =  ${headerListResponse?[i].qtyPerFlat} Flats'}'
                                            : headerListResponse?[i]
                                                    .invFinishTypeName ??
                                                '',
                                        // "2 BHK ( 740.33 Sqft)\n(Qty Per  Flat)",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              for (int p = 0;
                                  p < filteredProjects()!.length;
                                  p++)
                                Row(
                                  children: [
                                    for (int i = 0;
                                        i <
                                            filteredProjects()![p]
                                                .details!
                                                .length;
                                        i++)
                                      Container(
                                        height: 39,
                                        width: i == 0 ? 540 : 320,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            right: BorderSide(
                                                color: Colors.grey.shade300),
                                            bottom: BorderSide(
                                                color: Colors.grey.shade300),
                                          ),
                                        ),
                                        padding: const EdgeInsets.only(
                                            left: 10, top: 0, right: 10),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            if (i == 0)
                                              Container(
                                                height: 39,
                                                decoration: const BoxDecoration(
                                                    border: Border(
                                                        right: BorderSide(
                                                            color: Colors
                                                                .black12))),
                                                padding: const EdgeInsets.only(
                                                    right: 10),
                                                width: 210,
                                                child: Center(
                                                  child: Text(
                                                    "${filteredProjects()![p].unit}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      // fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            SizedBox(
                                              width: 110,
                                              height: 34,
                                              child: TextFormField(
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                        decimal: true),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(
                                                          r'^\d+\.?\d{0,2}')),
                                                ],

                                                // keyboardType: TextInputType.number,
                                                // scrollPadding: const EdgeInsets.all(0.0),
                                                controller:
                                                    filteredProjects()![p]
                                                        .details?[i]
                                                        .controller,
                                                // TextEditingController(
                                                //     text: bodyListResponse![p]
                                                //         .details?[i]
                                                //         .inputPunch),
                                                //
                                                onChanged: (value) {
                                                  setState(() {
                                                    if (value.trim() != "") {
                                                      filteredProjects()![p]
                                                          .details?[i]
                                                          .totalBoq = (int.parse(
                                                                  filteredProjects()![
                                                                              p]
                                                                          .details?[
                                                                              i]
                                                                          .totalQty ??
                                                                      '0') *
                                                              int.parse(value))
                                                          .toString();
                                                    } else {
                                                      filteredProjects()![p]
                                                          .details?[i]
                                                          .totalBoq = "0";
                                                    }
                                                  });
                                                },
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13.0),
                                                decoration:
                                                    const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          bottom: 0, left: 12),
                                                  // border: OutlineInputBorder(
                                                  //   borderSide: BorderSide(color: Colors.transparent),
                                                  // ),
                                                  hintText:
                                                      'Please Enter Quantity',
                                                  hintStyle: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 116, 116, 116),
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.w200,
                                                    fontFamily: 'HelveticaNeue',
                                                  ),
                                                  // suffixIcon: Icon(
                                                  //   Icons.calendar_month_outlined,
                                                  // ),
                                                  // border: InputBorder.none,
                                                  // enabledBorder: OutlineInputBorder(
                                                  //   borderSide: const BorderSide(
                                                  //       color: Color(0xFF5F5C5C)),
                                                  //   borderRadius:
                                                  //       BorderRadius.circular(8),
                                                  // ),
                                                  // focusedBorder: OutlineInputBorder(
                                                  //   borderSide: const BorderSide(
                                                  //     color: (Color(0xFF5F5C5C)),
                                                  //   ),
                                                  //   borderRadius:
                                                  //       BorderRadius.circular(8),
                                                  // ),
                                                  // errorBorder: OutlineInputBorder(
                                                  //   borderSide: const BorderSide(
                                                  //     color: (Colors.red),
                                                  //   ),
                                                  //   borderRadius:
                                                  //       BorderRadius.circular(8),
                                                  // ),
                                                  // focusedErrorBorder:
                                                  //     OutlineInputBorder(
                                                  //   borderSide: const BorderSide(
                                                  //     color: (Color(0xFF5F5C5C)),
                                                  //   ),
                                                  //   borderRadius:
                                                  //       BorderRadius.circular(8),
                                                  // ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            // const Text(
                                            //   "Per Flat",
                                            //   style: TextStyle(
                                            //     fontSize: 13,
                                            //     // fontWeight: FontWeight.w600,
                                            //   ),
                                            // ),
                                            // SizedBox(width: 43),
                                            // const Spacer(),
                                            Container(
                                              // color: Colors.amber,
                                              width: 66,
                                              child: Text(
                                                "* ${filteredProjects()![p].details?[i].totalQty} = ",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  // fontWeight: FontWeight.w600,
                                                ),
                                                textAlign: TextAlign.end,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              width: 100,
                                              height: 26,
                                              margin: const EdgeInsets.only(
                                                  bottom: 6),
                                              padding:
                                                  const EdgeInsets.only(top: 2),
                                              decoration: BoxDecoration(
                                                  color: Colors.black12,
                                                  borderRadius:
                                                      BorderRadius.circular(6)
                                                  // border: Border.all(color: Colors.grey),
                                                  ),
                                              child: Text(
                                                formatToIndianStandard(
                                                    double.parse(
                                                        filteredProjects()![p]
                                                                .details?[i]
                                                                .totalBoq ??
                                                            '0')),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  // fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    Container(
                                      decoration: BoxDecoration(
                                        // color: Colors.black12,
                                        // borderRadius: BorderRadius.circular(6),
                                        border: Border(
                                          right: BorderSide(
                                              color: Colors.grey.shade300),
                                          bottom: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                      ),
                                      padding: const EdgeInsets.only(
                                          bottom: 0, top: 5),
                                      child: Container(
                                        width: 139,
                                        // width: 90,
                                        height: 26,
                                        margin: const EdgeInsets.only(
                                            bottom: 6, left: 10, right: 10),
                                        padding: const EdgeInsets.only(top: 2),
                                        // padding: EdgeInsets.only(top: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black12,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          // border: Border(
                                          //   right:
                                          //       BorderSide(color: Colors.grey.shade600),
                                          //   bottom:
                                          //       BorderSide(color: Colors.grey.shade600),
                                          // ),
                                        ),
                                        child: Text(
                                          formatToIndianStandard(double.parse(
                                              filteredProjects()![p].totalBoq ??
                                                  '0')),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            // fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                            ],
                          ),
                        ),
                      )
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
