import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:lottie/lottie.dart';
import 'package:stallion/models/flat_status.dart';
import 'package:stallion/models/get_available_inventery_pdf.dart';
import 'package:stallion/models/get_broker_details.dart';
import 'package:stallion/models/get_flat_list_by_project.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/salesmanagement/availableInventory/parking_list.dart';
import 'package:stallion/ui/views/salesmanagement/availableInventory/tenantDetail.dart';
import 'package:stallion/ui/views/salesmanagement/bookasaleview.dart';
import 'package:stallion/ui/views/salesmanagement/bookingdetailsview.dart';
import 'package:stallion/ui/views/salesmanagement/bookingdetailsview_new.dart';
import 'package:stallion/ui/views/salesmanagement/membershipform.dart';
import 'package:stallion/ui/widgets/app_text.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:url_launcher/url_launcher.dart';

class AvailableInventory extends StatefulWidget {
  const AvailableInventory({
    super.key,
    this.projectId = "",
    this.towarId = "",
    this.projectName = "",
    this.towarName = "",
    this.member_ship_form = "",
    this.saleAccTab,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? member_ship_form;
  final String? saleAccTab;

  @override
  State<AvailableInventory> createState() => _AvailableInventoryState();
}

class _AvailableInventoryState extends State<AvailableInventory> {
  bool get isMobile => context.isMobile;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String tenentIdSelected = '';
  Color testtt(FlatDetail? data) {
    if (data?.floorTypeId == "2" ||
        data?.floorTypeId == "9" ||
        data?.floorTypeId == "10" ||
        data?.floorTypeId == "13") {
      return Color.fromRGBO(
          227, 197, 50, 1.0); //const Color.fromRGBO(245, 170, 66, 1.0);
    } else if (data?.floorTypeId == '1' || data?.floorTypeId == '6') {
      if (data?.availableStatus == '0') {
        return const Color.fromRGBO(229, 12, 17, 1.0);
      } else if (data?.availableStatus == '3') {
        return const Color.fromRGBO(50, 94, 168, 1.0);
      } else {
        return const Color.fromRGBO(1, 111, 1, 1.0);
      }
    } else if (data?.floorTypeId == "3") {
      return const Color.fromRGBO(245, 170, 66, 1.0);
    } else {
      return Colors.grey;
    }
  }

  bool checkParkingAlocated(
      {required ParkingList details, required String flatId}) {
    if (details.inventryAllocatedId != "0" &&
        details.parkingIsAllocated != "1") {
      if (flatId == details.inventryAllocatedId) {
        return false;
      }
      return true;
    }
    return false;
    // flat_id: '9670' flat
    // parking_serial_no: 'P-112'mst_parking_id: '12065'inventry_allocated_id: '9670'parking_is_allocated: '0' parking
  }

  final TextEditingController _chooseParkingController =
      TextEditingController();
  TextEditingController chooseTenantController = TextEditingController();
  List<FlatBuyerRequest>? flatBuyerRequest = [];
  String? userIdd = '';
  List<String?>? flatNoIds = [];
  double? totalflatAreaCount = 0;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  List<FlatAvailableList>? flatAvailableList;
  List<TenentList>? tenentList = [];
  String searchText = '';
  List<ParkingList>? arrSelectedParkingList = [];
  List<PodiumList>? podiumList = [];
  int totalPark = 0;
  String? strParkingSelectedNo = "";
  final TextEditingController _txtcontrollerParkingCount =
      TextEditingController();
  String? filePath = '';
  String? fileName = '';

  void _show({required String flatId}) async {
    SmartDialog.show(
        clickMaskDismiss: false,
        builder: (_) {
          return Container(
            width: MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).size.height / 1.5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 40,
                    child: Center(
                      child: Text(
                        'SELECT PARKING PLACE',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) =>
                          MyExpandableWidget(podiumList![index], flatId),
                      itemCount: podiumList!.length,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        fixedSize: const Size.fromWidth(100),
                        padding: const EdgeInsets.all(10),
                        textStyle: const TextStyle(color: Colors.white)),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text('OK', style: TextStyle(color: Colors.white)),
                    ),
                    onPressed: () {
                      if (arrSelectedParkingList!.isNotEmpty) {
                        if (arrSelectedParkingList!.length <
                            int.parse(_txtcontrollerParkingCount.text)) {
                          messageAlertAll();
                        } else {
                          SmartDialog.dismiss();
                        }
                      } else {
                        SmartDialog.dismiss();
                      }
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  List<TenentList>? filteredTenants() {
    if (searchText.isEmpty) {
      return tenentList;
    }
    return tenentList!.where((project) {
      return project.name!.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
  }

  Future<FlatStatusResponse?> setRehabTenent({
    required String inventyParkingNumber,
    required String tenentId,
    required String flatId,
  }) async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId!,
      "inventy_parking_number": inventyParkingNumber,
      "tenent_id": tenentId,
      "flat_id": flatId,
      "parking_id": jsonEncode(arrSelectedParkingList),
      "project_id": widget.projectId!,
      "towar_id": widget.towarId ?? '',
    };

    var response = await apiNetworkHandler.post(AppUrl.webSetRehabTenent, data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.of(context).pop();
      getFlatStatus();
      // final dataModel = flatStatusFromJson(response.body);
      // if (dataModel.response?.errorCode == "0") {
      // }
    }
    return null;
    // return null;
  }

  Future<FlatStatusResponse?> getAvailableInventeryPdf() async {
    Map<String, String> data = {
      "project_id": widget.projectId!,
      "towar_id": widget.towarId ?? '',
    };

    var response =
        await apiNetworkHandler.post(AppUrl.webAvailableInventeryPdf, data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getAvailableInventeryPdfFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        filePath = dataModel.response?.filePath;
        fileName = dataModel.response?.fileName;
      }
    }
    return null;
  }

  Future<FlatStatusResponse?> getFlatStatus() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId ?? '',
    };

    var response = await apiNetworkHandler.post(AppUrl.webgetFlatStatus, data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = flatStatusFromJson(response.body);
      // if (dataModel.response?.errorCode == "0") {
      setState(() {
        //inspect(flatAvailableList);
        userIdd = dataModel.response?.userId;
        flatAvailableList = dataModel.response?.flatAvailableList;
        tenentList = dataModel.response?.tenentList;

        podiumList = dataModel.response?.podiumList;

        if (podiumList!.isNotEmpty) {
          for (var i = 0; i < podiumList!.length; i++) {
            totalPark = totalPark + int.parse(podiumList![i].available!);
          }
        }

        for (int i = 0; i < arrSelectedParkingList!.length; i++) {
          for (int j = 0; j < podiumList!.length; j++) {
            for (int k = 0; k < podiumList![j].parkingList!.length; k++) {
              if (arrSelectedParkingList![i].mstParkingId! ==
                  podiumList![j].parkingList![k].mstParkingId) {
                podiumList![j].parkingList![k].selected = 'true';
              }
            }
          }
        }
      });
      // }
    }
    return null;
    // return null;
  }

  changeAssignTenantModal({
    required String flatNumber,
    required String inventyParkingNumber,
    required String tenentId,
    required String flatId,
  }) {
    return showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context1, setState2) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 0),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 0),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  "Assign Tenant (Flat. No. $flatNumber)",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: <Widget>[
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 225,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            // bottomRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    InkWell(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          inspect(arrSelectedParkingList);
                          print(
                              '$tenentIdSelected------------ $inventyParkingNumber--------- $flatId');
                          setRehabTenent(
                              inventyParkingNumber: inventyParkingNumber,
                              tenentId: tenentIdSelected,
                              flatId: flatId);
                        }
                        // arrSelectedParkingList.length
                        // changeProjectPermissionAssign(
                        //     transProjectPerId: transProjectPerId,
                        //     assignTo: transEmpId);
                        // Navigator.pop(context);
                      },
                      child: Container(
                        width: 225,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(8),
                            // bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
              content: SizedBox(
                height: 320,
                width: 400,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        const Text(
                          "Choose Tenant",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () {
                            chooseTenantModal(flatNumber: flatNumber);
                          },
                          child: TextFormField(
                            enabled: false,
                            readOnly: true,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Tenant Cannot Be Empty";
                              }
                              return null;
                            },
                            controller: chooseTenantController,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400),
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black38),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: (Colors.black38),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: (Colors.black38),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: (Colors.red),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: (Colors.black38),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.all(12.0),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black54),
                              ),
                              hintText: 'Choose Tenant',
                              hintStyle: const TextStyle(
                                color: Color.fromARGB(255, 116, 116, 116),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'HelveticaNeue',
                              ),
                              suffixIcon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "No. Of. Parking",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          onChanged: (value) {
                            // arrSelectedParkingList = [];
                            inspect(arrSelectedParkingList);
                            // podiumList![index]
                            // for (int i = 0; i < podiumList!.length; i++) {
                            //   for (int p = 0;
                            //       p < podiumList![i].parkingList!.length;
                            //       p++) {
                            //     podiumList![i].parkingList?[p].selected = '';
                            //   }
                            // }
                            // _chooseParkingController.clear();
                            // strParkingSelectedNo = '';
                          },
                          // validator: (value) {
                          //   if (value!.isEmpty) {
                          //     return "No. Of. Parking Cannot Be Empty";
                          //   }
                          //   return null;
                          // },
                          controller: _txtcontrollerParkingCount,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400),
                          decoration: InputDecoration(
                            disabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black38),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: (Colors.black38),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: (Colors.black38),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: (Colors.red),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: (Colors.black38),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(12.0),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54),
                            ),
                            hintText: 'No. Of. Parking',
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 116, 116, 116),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'HelveticaNeue',
                            ),
                            // suffixIcon: Icon(
                            //   Icons.keyboard_arrow_down_rounded,
                            // ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "Choose Parking",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () {
                            _txtcontrollerParkingCount.text.isNotEmpty
                                ? _show(flatId: flatId)
                                : null;
                          },
                          child: TextFormField(
                            enabled: false,
                            readOnly: true,
                            validator: (value) {
                              // if (value!.isEmpty) {
                              //   return "Parking Cannot Be Empty";
                              // }
                              if (_txtcontrollerParkingCount.text.isNotEmpty &&
                                  value!.isEmpty) {
                                // return "Parking Cannot Be Empty";
                                return null;
                              } else if (_txtcontrollerParkingCount
                                      .text.isNotEmpty &&
                                  value!.isNotEmpty) {
                                if (arrSelectedParkingList!.length !=
                                    double.parse(
                                        _txtcontrollerParkingCount.text)) {
                                  return "Parking Allocation should be same as Entered Parking Count";
                                }
                              }
                              return null;
                            },
                            controller: _chooseParkingController,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400),
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black38),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: (Colors.black38),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: (Colors.black38),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: (Colors.red),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: (Colors.black38),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.all(12.0),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black54),
                              ),
                              hintText: 'Choose Parking',
                              hintStyle: const TextStyle(
                                color: Color.fromARGB(255, 116, 116, 116),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'HelveticaNeue',
                              ),
                              suffixIcon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  chooseTenantModal({required String flatNumber}) {
    return showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context1, setState3) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 0),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 0),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  "Choose Tenant",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: <Widget>[
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        // String temp = '';
                        // for (int i = 0; i < tenentList!.length; i++) {
                        //   if (tenentList?[i].isSelected == true) {
                        //     if (temp == "") {
                        //       temp = '${tenentList?[i].name}';
                        //     } else {
                        //       temp = '$temp, ${tenentList?[i].name}';
                        //     }
                        //   }
                        // }

                        // chooseTenantController.text = temp;
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 460,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            // bottomRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // const SizedBox(width: 10),
                    // InkWell(
                    //   onTap: () {
                    //     // changeProjectPermissionAssign(
                    //     //     transProjectPerId: transProjectPerId,
                    //     //     assignTo: transEmpId);
                    //     // Navigator.pop(context);
                    //   },
                    //   child: Container(
                    //     width: 225,
                    //     padding: const EdgeInsets.symmetric(vertical: 8),
                    //     decoration: const BoxDecoration(
                    //       color: Colors.black,
                    //       borderRadius: BorderRadius.only(
                    //         bottomRight: Radius.circular(8),
                    //         // bottomLeft: Radius.circular(8),
                    //       ),
                    //     ),
                    //     child: const Text(
                    //       'Submit',
                    //       textAlign: TextAlign.center,
                    //       style: TextStyle(
                    //         fontSize: 18,
                    //         fontWeight: FontWeight.w600,
                    //         color: Colors.white,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                )
              ],
              content: SizedBox(
                height: 340,
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      TextFormField(
                        onChanged: (value) {
                          setState3(() {
                            searchText = value;
                          });
                        },
                        // validator: (value) {
                        //   if (value!.isEmpty) {
                        //     return "No. Of. Parking Cannot Be Empty";
                        //   }
                        //   return null;
                        // },
                        // controller: _workTypeController,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400),
                        decoration: InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black38),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: (Colors.black38),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: (Colors.black38),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: (Colors.red),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: (Colors.black38),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(12.0),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          hintText: 'Search Tenant',
                          hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 116, 116, 116),
                            fontSize: 13.0,
                            fontWeight: FontWeight.w200,
                            fontFamily: 'HelveticaNeue',
                          ),
                          // suffixIcon: Icon(
                          //   Icons.keyboard_arrow_down_rounded,
                          // ),
                        ),
                      ),
                      for (int i = 0; i < filteredTenants()!.length; i++)
                        InkWell(
                          onTap: () {
                            setState3(() {
                              if (filteredTenants()?[i].viewFlag == '0') {
                                tenentIdSelected =
                                    filteredTenants()?[i].id ?? '';
                                chooseTenantController.text =
                                    filteredTenants()?[i].name ?? '';
                                // if (filteredTenants()?[i].isSelected == true) {
                                //   filteredTenants()?[i].isSelected = false;
                                // } else {
                                //   filteredTenants()?[i].isSelected = true;
                                // }
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                              color: Colors.grey,
                            ))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  filteredTenants()?[i].name ?? '',
                                  style: TextStyle(
                                      fontSize: 19,
                                      color:
                                          filteredTenants()?[i].viewFlag == '1'
                                              ? Colors.grey
                                              : Colors.black),
                                ),
                                Icon(
                                  // filteredTenants()?[i].isSelected == true
                                  tenentIdSelected == filteredTenants()?[i].id
                                      ? Icons.check_circle_outline_outlined
                                      : Icons.circle_outlined,
                                  color:
                                      // filteredTenants()?[i].isSelected == true
                                      tenentIdSelected ==
                                              filteredTenants()?[i].id
                                          ? Colors.green
                                          : Colors.grey,
                                )
                              ],
                            ),
                          ),
                        ),
                      // Row(
                      //   children: [
                      //     Text(tenentList?[i].name ?? ''),
                      //   ],
                      // )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  @override
  void initState() {
    getFlatStatus();
    getAvailableInventeryPdf();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: InkWell(
        onTap: () {
          if (flatNoIds!.isNotEmpty) {
            if (widget.member_ship_form == "1") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return MembershipFormView(
                      projectId: widget.projectId,
                      towarId: widget.towarId!,
                      projectName: widget.projectName,
                      flagRedirect: "InventoryNew",
                      flatNoIds: flatNoIds,
                      totalflatAreaCount: totalflatAreaCount.toString(),
                    );
                  },
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return BookaSaleFormView(
                      
                      projectId: widget.projectId,
                      towarId: widget.towarId!,
                      projectName: widget.projectName,
                      flagRedirect: "InventoryNew",
                      flatNoIds: flatNoIds,
                      totalflatAreaCount: totalflatAreaCount.toString(),
                    );
                  },
                ),
              );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          color: Colors.black,
          child: const AppText(
            title: "PROCEED FOR BOOKING",
            fontSize: 16,
            titleColor: Colors.white,
            titleTextAlign: TextAlign.center,
          ),
        ),
      ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        actions: [
          InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                        actionsPadding: EdgeInsets.zero,
                        titlePadding: EdgeInsets.zero,
                        title: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          child: const Text(
                            "Info",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        actions: <Widget>[
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              width: 600,
                              color: Colors.black,
                              child: const AppText(
                                title: "CLOSE",
                                fontSize: 15,
                                titleColor: Colors.white,
                                titleTextAlign: TextAlign.center,
                              ),
                            ),
                          )
                        ],
                        content: StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return SizedBox(
                            height: 190,
                            width: 400,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  colorStatus(
                                    title: 'Available',
                                    statusColor:
                                        const Color.fromRGBO(1, 111, 1, 1.0),
                                  ),
                                  colorStatus(
                                    title: 'Sold',
                                    statusColor:
                                        const Color.fromRGBO(229, 12, 17, 1.0),
                                  ),
                                  colorStatus(
                                    title: 'Reserved',
                                    statusColor:
                                        const Color.fromRGBO(50, 94, 168, 1.0),
                                  ),
                                  colorStatus(
                                    title: 'Rehab',
                                    statusColor:
                                        const Color.fromRGBO(245, 170, 66, 1.0),
                                  ),
                                  colorStatus(
                                      title: 'Podium/Parking',
                                      statusColor: const Color.fromRGBO(
                                          227, 197, 50, 1.0)),
                                  colorStatus(
                                    title:
                                        'Blocked/Fitness Center/Society/ Office',
                                    statusColor: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }));
                  });
            },
            child: Container(
              padding: const EdgeInsets.only(right: 60),
              child: const Icon(
                Icons.info_rounded,
                size: 30,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 60),
            child: Row(
              children: [
                const SizedBox(width: 30),
                const Spacer(),
                const AppText(
                  title: "AVAILABLE INVENTORY",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  titleTextAlign: TextAlign.center,
                ),
                const Spacer(),
                InkWell(
                  onTap: () async {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) {
                    //       return PdfViewer(
                    //         fileName: fileName,
                    //         fileUrl: '$filePath',
                    //       );
                    //     },
                    //   ),
                    // );
                    // _launchURL() async {
                    final uri = Uri.parse(filePath!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      throw 'Could not launch';
                    }
                    // }
                  },
                  child: const Icon(
                    Icons.download,
                    size: 30,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          Expanded(
              child: flatAvailableList != null
                  ? ListView.separated(
                      shrinkWrap: true,
                      itemCount: flatAvailableList?.length ?? 0,
                      itemBuilder: (context, index) {
                        return inventoryCard(
                            flatAvailableListData: flatAvailableList![index],
                            ind: index);
                      },
                      separatorBuilder: (context1, index) =>
                          const SizedBox(height: 16),
                    )
                  : Center(
                      child: SizedBox(
                        height: 64,
                        child: OverflowBox(
                          minHeight: 100,
                          maxHeight: 100,
                          child: Lottie.asset(
                            'assets/animation/running2.json',
                            // 'assets/animation/chatbotfinallotiie.json',
                            repeat: true,
                          ),
                        ),
                      ),
                    )
              //  const Center(child: CircularProgressIndicator()),
              )
        ],
      ),
    );
  }

  Widget inventoryCard({
    required FlatAvailableList flatAvailableListData,
    required int ind,
  }) {
    String getName({required String val}) {
      int lastIndex = val.lastIndexOf("-");
      if (lastIndex != -1) {
        String result = val.substring(lastIndex + 1);
        result = result.trim();
        return result;
      } else {
        return val;
      }
    }

    String nameIs(FlatDetail? data) {
      if (data?.floorTypeId == "9" || data?.floorTypeId == "2") {
        if (data?.availablePark != "" && data?.flatArea != "") {
          return '${data?.flatArea}/${data?.availablePark}';
        } else {
          return "";
        }
      } else {
        return '${data?.flatArea} ${data?.isParking == "1" ? "" : "Sq.Ft."}';
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 50),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 14),
            width: isMobile ? 80 : 300,
            child: AppText(
              title: flatAvailableListData.floorDetails?.floorName ?? '',
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Wrap(
              direction: Axis.horizontal, // default
              alignment: WrapAlignment.start, // default
              spacing: 34,
              runSpacing: 24,
              children: [
                for (int i = 0;
                    i < flatAvailableListData.floorDetails!.flatDetails!.length;
                    i++)
                  InkWell(
                    onTap: () {
                      if (flatAvailableListData
                              .floorDetails!.flatDetails?[i].isParking ==
                          "1") {
// parking list
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              return ParkingListScreen(
                                title:
                                    '${flatAvailableListData.floorDetails!.floorName}, ${flatAvailableListData.floorDetails!.flatDetails?[i].flatName}',
                                projectId: widget.projectId,
                                projectName: widget.projectName,
                                towarId: widget.towarId,
                                towarName: widget.towarName!,
                                flatId: flatAvailableListData
                                    .floorDetails!.flatDetails?[i].flatId,
                              );
                            },
                          ),
                        );
                      } else if (flatAvailableListData.floorDetails!
                              .flatDetails?[i].tenentPaymentFlag ==
                          '1') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              return BookingDetailsView(
                                  // flatTotalValue: '',
                                  flat_buyer_id: flatAvailableListData
                                      .floorDetails!
                                      .flatDetails?[i]
                                      .flatBuyerId,
                                  memberShipForm: widget.member_ship_form,
                                  projectId: widget.projectId,
                                  projectName: widget.projectName,
                                  towarId: widget.towarId,
                                  towarName: widget.towarName!,
                                  flatBuyerRequest: FlatBuyerRequest(),
                                  // flatAvailableListData
                                  //     .floorDetails!
                                  //     .flatDetails?[i]
                                  //     .flatBuyerDetails?[0],
                                  navigationFlag: 'SoldInventory',
                                  title: '',
                                  inventryFlatName: flatAvailableListData
                                      .floorDetails!
                                      .flatDetails?[i]
                                      .inventryFlatName);
                            },
                          ),
                        );
                      } else {
                        if (flatAvailableListData.floorDetails!.flatDetails?[i]
                                    .floorTypeId ==
                                "2" ||
                            flatAvailableListData.floorDetails!.flatDetails?[i]
                                    .floorTypeId ==
                                "9") {
                          const Color.fromRGBO(245, 170, 66, 1.0);
                        } else if (flatAvailableListData.floorDetails!
                                    .flatDetails?[i].floorTypeId ==
                                '1' ||
                            flatAvailableListData.floorDetails!.flatDetails?[i]
                                    .floorTypeId ==
                                '6') {
                          if (flatAvailableListData.floorDetails!
                                  .flatDetails?[i].availableStatus ==
                              '0') {
                            if (widget.saleAccTab == '1') {
                              print("---------------------------------here");
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (_) {
                              //       return BookingDetailsViewNew(
                              //         memberShipForm: widget.member_ship_form,
                              //         projectId: widget.projectId,
                              //         projectName: widget.projectName,
                              //         towarId: widget.towarId,
                              //         towarName: widget.towarName!,
                              //         flatBuyerId: flatAvailableListData
                              //             .floorDetails!
                              //             .flatDetails?[i]
                              //             .flatBuyerId,
                              //         // .flatBuyerDetails?[0]
                              //         // .flatBuyerId,

                              //         // flatAvailableListData
                              //         //     .floorDetails!
                              //         //     .flatDetails?[i]
                              //         //     .floorTypeId,
                              //         // flatBuyerRequest: flatAvailableListData
                              //         //     .floorDetails!
                              //         //     .flatDetails?[i]
                              //         //     .flatBuyerDetails?[0],
                              //         // navigationFlag: 'SoldInventory',
                              //         title: "----------",
                              //         // '${flatAvailableListData.floorDetails!.flatDetails?[i].flatBuyerDetails?[0].flatBuyerName} ${flatAvailableListData.floorDetails!.flatDetails?[i].flatName}'
                              //       );
                              //     },
                              //   ),
                              // );
                              print(jsonEncode(flatAvailableListData
                                  .floorDetails!
                                  .flatDetails?[i]
                                  .inventryFlatName));
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) {
                                    return BookingDetailsView(
                                        flat_buyer_id: flatAvailableListData
                                            .floorDetails!
                                            .flatDetails?[i]
                                            .flatBuyerId,
                                        memberShipForm: widget.member_ship_form,
                                        projectId: widget.projectId,
                                        projectName: widget.projectName,
                                        towarId: widget.towarId,
                                        towarName: widget.towarName!,
                                        flatBuyerRequest: FlatBuyerRequest(),
                                        // flatAvailableListData
                                        //     .floorDetails!
                                        //     .flatDetails?[i]
                                        //     .flatBuyerDetails?[0],
                                        navigationFlag: 'SoldInventory',
                                        title: '',
                                        inventryFlatName: flatAvailableListData
                                            .floorDetails!
                                            .flatDetails?[i]
                                            .inventryFlatName);
                                  },
                                ),
                              );
                            }
                          } else if (flatAvailableListData.floorDetails!
                                  .flatDetails?[i].availableStatus ==
                              '3') {
                            if (widget.member_ship_form == "1") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) {
                                    return MembershipFormView(
                                      flatBuyerRequest: flatAvailableListData
                                          .floorDetails!
                                          .flatDetails![i]
                                          .flatBuyerDetails![0],

                                      flatNoIds: [
                                        flatAvailableList?[ind]
                                            .floorDetails!
                                            .flatDetails![i]
                                            .flatId,
                                      ],

                                      projectId: widget.projectId,
                                      towarId: widget.towarId!,
                                      projectName: widget.projectName,
                                      strBuyerID: flatAvailableListData
                                          .floorDetails!
                                          .flatDetails?[i]
                                          .flatBuyerDetails![0]
                                          .flatBuyerId,

                                      flagRedirect: "Reserve",
                                      //'Inventory',
                                      isFlatListFromReserve:
                                          flatAvailableListData
                                              .floorDetails!
                                              .flatDetails?[i]
                                              .flatBuyerDetails?[0]
                                              .selectedFlat?[0],
                                    );
                                  },
                                ),
                              );
                            } else {
                              if (widget.saleAccTab == '1' ||
                                  (widget.saleAccTab == '0' &&
                                      userIdd ==
                                          flatAvailableListData
                                              .floorDetails!
                                              .flatDetails?[i]
                                              .flatBuyerDetails![0]
                                              .userIdFk)) {
                                print(
                                    '---------------------------------------------------------++++');
                                print(json.encode(flatAvailableListData
                                    .floorDetails!.flatDetails?[i]));
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return BookaSaleFormView(
                                          floor_type_id: flatAvailableListData
                                              .floorDetails!
                                              .flatDetails?[i]
                                              .floorTypeId,
                                          flatbuyerid: flatAvailableListData
                                              .floorDetails!
                                              .flatDetails?[i]
                                              .flatBuyerId,
                                          flatidfk: flatAvailableListData
                                              .floorDetails!
                                              .flatDetails?[i]
                                              .flatId,
                                          projectId: widget.projectId,
                                          towarId: widget.towarId!,
                                          projectName: widget.projectName,
                                          strBuyerID: flatAvailableListData
                                              .floorDetails!
                                              .flatDetails?[i]
                                              .flatBuyerId,
                                          flatBuyerRequest: FlatBuyerRequest(),
                                          flagRedirect: "Reserve Avail",
                                          //'Inventory',
                                          isFlatListFromReserve: FlatList(),
                                          flatNoIds: [
                                            flatAvailableList?[ind]
                                                .floorDetails!
                                                .flatDetails![i]
                                                .flatId,
                                          ]);
                                    },
                                  ),
                                );
                              }
                            }
                          } else {
                            setState(() {
                              if (flatAvailableListData.floorDetails!
                                      .flatDetails![i].isSelected ==
                                  true) {
                                flatAvailableList?[ind]
                                    .floorDetails!
                                    .flatDetails![i]
                                    .isSelected = false;
                                totalflatAreaCount = (totalflatAreaCount! -
                                    double.parse(flatAvailableList?[ind]
                                            .floorDetails!
                                            .flatDetails![i]
                                            .flatArea ??
                                        ''));
                                flatNoIds?.remove(flatAvailableList?[ind]
                                    .floorDetails!
                                    .flatDetails![i]
                                    .flatId);
                              } else {
                                flatAvailableList?[ind]
                                    .floorDetails!
                                    .flatDetails![i]
                                    .isSelected = true;

                                flatNoIds?.add(flatAvailableList?[ind]
                                    .floorDetails!
                                    .flatDetails![i]
                                    .flatId);
                                totalflatAreaCount = (totalflatAreaCount! +
                                    double.parse(flatAvailableList?[ind]
                                            .floorDetails!
                                            .flatDetails![i]
                                            .flatArea ??
                                        ''));
                              }
                            });
                          }
                        } else if (flatAvailableListData.floorDetails!
                                    .flatDetails?[i].floorTypeId ==
                                '3' &&
                            flatAvailableListData
                                    .floorDetails!.flatDetails?[i].tenentId ==
                                '') {
                          chooseTenantController.clear();
                          _txtcontrollerParkingCount.clear();
                          _chooseParkingController.clear();
                          setState(() {
                            arrSelectedParkingList?.clear();
                            strParkingSelectedNo = '';
                            searchText = '';
                            for (int i = 0; i < tenentList!.length; i++) {
                              tenentList?[i].isSelected = false;
                            }
                            String tempp = '';
                            List<ParkingList>? temmp = [];
                            for (int j = 0; j < podiumList!.length; j++) {
                              for (int k = 0;
                                  k < podiumList![j].parkingList!.length;
                                  k++) {
                                podiumList![j].parkingList?[k].selected = '';
                                if (podiumList![j]
                                        .parkingList?[k]
                                        .inventryAllocatedId ==
                                    flatAvailableListData
                                        .floorDetails!.flatDetails?[i].flatId) {
                                  podiumList![j].parkingList?[k].selected =
                                      'true';
                                  temmp.add(podiumList![j].parkingList![k]);
                                  if (tempp == "") {
                                    tempp = podiumList![j]
                                            .parkingList?[k]
                                            .parkingSerialNo ??
                                        '';
                                  } else {
                                    tempp =
                                        '$tempp ,${podiumList![j].parkingList?[k].parkingSerialNo}';
                                  }
                                }
                              }
                            }
                            _chooseParkingController.text = tempp;
                            arrSelectedParkingList = temmp;
                          });
                          _txtcontrollerParkingCount.text =
                              flatAvailableListData.floorDetails!
                                      .flatDetails?[i].inventyParkingNumber ??
                                  '';
                          print(
                              '${flatAvailableListData.floorDetails!.flatDetails?[i].tenentId}--------------');
                          changeAssignTenantModal(
                            flatNumber: flatAvailableListData.floorDetails!
                                    .flatDetails?[i].inventryFlatName ??
                                '',
                            inventyParkingNumber: flatAvailableListData
                                    .floorDetails!
                                    .flatDetails?[i]
                                    .inventyParkingNumber ??
                                '',
                            tenentId: flatAvailableListData
                                    .floorDetails!.flatDetails?[i].tenentId ??
                                '',
                            flatId: flatAvailableListData
                                    .floorDetails!.flatDetails?[i].flatId ??
                                '',
                          );
                          // flatNumber: flatAvailableListData.floorDetails!
                          //         .flatDetails?[i].inventryFlatName ??
                          //     '');
                        } else if (flatAvailableListData.floorDetails!
                                    .flatDetails?[i].floorTypeId ==
                                '3' &&
                            flatAvailableListData
                                    .floorDetails!.flatDetails?[i].tenentId !=
                                '') {
                          if (flatAvailableListData.floorDetails!
                                  .flatDetails?[i].tenentPaymentFlag ==
                              '0') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return TenantDetail(
                                    inventyParkingNumber: flatAvailableListData
                                            .floorDetails!
                                            .flatDetails?[i]
                                            .inventyParkingNumber ??
                                        '',
                                    tenentId: flatAvailableListData
                                            .floorDetails!
                                            .flatDetails?[i]
                                            .tenentId ??
                                        '',
                                    flatId: flatAvailableListData.floorDetails!
                                            .flatDetails?[i].flatId ??
                                        '',
                                    projectId: widget.projectId,
                                    projectName: widget.projectName,
                                    towarId: widget.towarId,
                                    towarName: widget.towarName!,
                                    podiumList: podiumList ?? [],
                                  );
                                },
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: Container(
                      width: 168,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: flatAvailableListData.floorDetails!
                                              .flatDetails![i].isSelected ==
                                          true
                                      ? Colors.black
                                      : const Color.fromARGB(
                                          255, 236, 236, 236),
                                  width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 146,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        topRight: Radius.circular(6),
                                      ),
                                      color: testtt(flatAvailableListData
                                          .floorDetails!.flatDetails?[i])),
                                  child: AppText(
                                    titleTextAlign: TextAlign.center,
                                    title: flatAvailableListData.floorDetails!
                                            .flatDetails?[i].inventryFlatName ??
                                        '',
                                    overflow: TextOverflow.visible,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    titleColor: Colors.white,
                                  ),
                                ),
                                Container(
                                  width: 146,
                                  padding: const EdgeInsets.only(top: 6),
                                  child: AppText(
                                    overflow: TextOverflow.visible,
                                    titleTextAlign: TextAlign.center,
                                    title: nameIs(flatAvailableListData
                                        .floorDetails!.flatDetails?[i]),
                                    fontSize: 13,
                                    titleColor: Colors.grey,
                                  ),
                                ),
                                if ((flatAvailableListData.floorDetails!
                                                .flatDetails?[i].floorTypeId ==
                                            "6" ||
                                        flatAvailableListData.floorDetails!
                                                .flatDetails?[i].floorTypeId ==
                                            "3" ||
                                        flatAvailableListData.floorDetails!
                                                .flatDetails?[i].floorTypeId ==
                                            "1") &&
                                    flatAvailableListData.floorDetails!
                                            .flatDetails?[i].flatType !=
                                        "")
                                  Container(
                                    width: 146,
                                    padding: const EdgeInsets.only(top: 6),
                                    child: AppText(
                                      overflow: TextOverflow.visible,
                                      titleTextAlign: TextAlign.center,
                                      title: flatAvailableListData.floorDetails!
                                              .flatDetails?[i].flatType ??
                                          '',
                                      fontSize: 13,
                                    ),
                                  ),
                                Container(
                                  width: 146,
                                  padding: const EdgeInsets.only(top: 6),
                                  child: AppText(
                                    overflow: TextOverflow.visible,
                                    titleTextAlign: TextAlign.center,
                                    title: getName(
                                        val: flatAvailableListData.floorDetails!
                                                .flatDetails?[i].flatName ??
                                            ''),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppText(
                            titleTextAlign: TextAlign.center,
                            title: flatAvailableListData.floorDetails!
                                            .flatDetails![i].registrationDoc ==
                                        "1" ||
                                    flatAvailableListData
                                            .floorDetails!
                                            .flatDetails![i]
                                            .tenentPaymentFlag ==
                                        "1"
                                ? 'R'
                                : '',
                            overflow: TextOverflow.visible,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            titleColor:
                                // ? Colors.green
                                // :
                                (flatAvailableListData
                                                    .floorDetails!
                                                    .flatDetails![i]
                                                    .tenentPaymentFlag ==
                                                "1" &&
                                            flatAvailableListData
                                                    .floorDetails!
                                                    .flatDetails![i]
                                                    .registrationDoc ==
                                                "1") ||
                                        (flatAvailableListData
                                                    .floorDetails!
                                                    .flatDetails![i]
                                                    .tenentPaymentFlag ==
                                                "0" &&
                                            flatAvailableListData
                                                    .floorDetails!
                                                    .flatDetails![i]
                                                    .registrationDoc ==
                                                "1")
                                    ? Colors.green
                                    : Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget colorStatus({
    required String title,
    required Color statusColor,
  }) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(
        color: Colors.grey,
      ))),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100), color: statusColor),
          ),
          const SizedBox(width: 20),
          AppText(
            title: title,
            fontSize: 14,
          )
        ],
      ),
    );
  }

  MyExpandableWidget(PodiumList? details, String flatId) {
    return ExpansionTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpaceMedium,
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(details!.flatName!,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.black)),
                  const Spacer(),
                  Text('Available: ${details.available!}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.black)),
                ],
              ),
            ),
          ),
          verticalSpaceSmall,
          verticalSpaceMedium,
          const Divider(
            height: 1,
            thickness: 0.5,
            indent: 1,
            endIndent: 1,
            color: Colors.black,
          ),
        ],
      ),
      children: details.parkingList!
          .map<Widget>((club) => showClubs(club, context, flatId))
          .toList(),
    );
  }

  showClubs(ParkingList details, BuildContext context, String flatId) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return StatefulBuilder(builder: (context, setState) {
      return Theme(
        data: theme,
        child: ExpansionTile(
          trailing: const SizedBox(),
          key: PageStorageKey<ParkingList?>(details),
          title: InkWell(
            onTap: () {
              if (checkParkingAlocated(details: details, flatId: flatId)) {
              } else {
                print("elese");
                setState(() {
                  if (details.selected == '') {
                    if (arrSelectedParkingList!.length <
                        int.parse(_txtcontrollerParkingCount.text)) {
                      details.selected = 'true';
                      arrSelectedParkingList!.add(details);
                    } else {
                      SmartDialog.dismiss();
                      messageAlert();
                    }
                  } else if (details.selected == 'true') {
                    details.selected = '';
                    inspect(arrSelectedParkingList);

                    arrSelectedParkingList?.remove(details);
                    inspect(arrSelectedParkingList);
                  }
                });
                var parking = "";
                if (arrSelectedParkingList!.isNotEmpty) {
                  for (int i = 0; i < arrSelectedParkingList!.length; i++) {
                    if (i == 0) {
                      parking = arrSelectedParkingList![i].parkingSerialNo!;
                    } else {
                      parking =
                          '$parking, ${arrSelectedParkingList![i].parkingSerialNo!}';
                    }
                  }
                }
                _chooseParkingController.text = parking;
                updateParkingNo(parking);
                print(arrSelectedParkingList);
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpaceSmall,
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        verticalSpaceSmall,
                        Text(details.parkingSerialNo!,
                            style: TextStyle(
                                // backgroundColor: Colors.white,
                                fontSize: 15,
                                // color: details.inventryAllocatedId != "0" &&
                                //         details.parkingIsAllocated != "1"
                                color: checkParkingAlocated(
                                        details: details, flatId: flatId)
                                    ? Colors.grey
                                    : Colors.black)),
                        const Spacer(),
                        details.selected == ''
                            ? const Icon(Icons.circle_outlined)
                            : const Icon(
                                Icons.check_circle_outline_sharp,
                                color: Colors.green,
                              ),
                        verticalSpaceSmall,
                      ],
                    ),
                  ),
                ),
                verticalSpaceMedium,
                const Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 1,
                  endIndent: 1,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  updateParkingNo(String parkingNo) {
    setState(() {
      strParkingSelectedNo = parkingNo;
    });
  }

  messageAlertAll() {
    final snackBar = SnackBar(
      content: const Text(
          'Parking allocation should not be less than parking count.'),
      backgroundColor: Colors.red,
      action: SnackBarAction(
        label: 'CLOSE',
        textColor: Colors.white,
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  messageAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(""),
            content: const Text(
                "Parking allocation cannot exceed the parking count."),
            actions: [
              ElevatedButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
