import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_flat_list_by_project.dart';
import 'package:stallion/models/get_rehab_tenant.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/salesmanagement/setpaymenttermsviewTenant.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/app_url.dart';

class TenantDetail extends StatefulWidget {
  const TenantDetail({
    super.key,
    this.projectId = "",
    this.towarId = "",
    this.projectName = "",
    this.towarName = "",
    this.flatId = '',
    this.tenentId = '',
    required this.podiumList,
    required this.inventyParkingNumber,
  });
  final String? inventyParkingNumber;
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? flatId;
  final String? tenentId;
  final List<PodiumList> podiumList;

  @override
  State<TenantDetail> createState() => _TenantDetailState();
}

class _TenantDetailState extends State<TenantDetail> {
  bool flagTDSValue = false;
  double tdsValue = 0.0;

  final TextEditingController _txtControllerFlatAgreementValue =
      TextEditingController();

  bool isStampDutySelected = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController focController = TextEditingController();
  TextEditingController mhadaController = TextEditingController();
  TextEditingController purchaseAreaController = TextEditingController();
  TextEditingController totalProposedController = TextEditingController();
  double parkindgTotalCt = 0;
  TextEditingController purchaseCostController = TextEditingController();
  TextEditingController purchaseRateController = TextEditingController();
  TextEditingController amountAdjustedController = TextEditingController();
  TextEditingController totalConsiderationController = TextEditingController();
  TextEditingController noOfParkingController = TextEditingController();
  TextEditingController focPercentageController = TextEditingController();
  TextEditingController registrationFeesController = TextEditingController();
  TenentFlatDetails? tenentFlatDetails;
  final TextEditingController _txtControllerGstPercentage =
      TextEditingController();
  double gst_value = 0.0;

  TextEditingController remarkController = TextEditingController();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<FlatDetail>? flatDetails = [];
  String? totalTenntPaid = '';
  List<ParkingList>? parkingList = [];
  List<TenentDetail>? tenentDetails = [];
  final TextEditingController _txtcontrollerParkingCount =
      TextEditingController();
  final TextEditingController _chooseParkingController =
      TextEditingController();
  String? stampDurty = '0';
  String? tdsPercentage = '0';

  String? gstPer = '0';
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

  Future<ParkingList?> getRehabTenent() async {
    CustomLoading.progressDialog(isLoading: true, context: context);
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId!,
      "tenent_id": widget.tenentId ?? '',
      "flat_id": widget.flatId ?? '',
      "project_id": widget.projectId!,
      "towar_id": widget.towarId ?? '',
    };

    var response = await apiNetworkHandler.post(AppUrl.webGetRehabTenent, data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getRehabTenantFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          // tenentFlatDetails = dataModel.response?.tenentFlatDetails;
          if (dataModel.response?.tenentDetails?[0].tenantGstPercentage ==
              '0') {
            _txtControllerGstPercentage.text = '5';
          } else {
            _txtControllerGstPercentage.text =
                dataModel.response?.tenentDetails?[0].tenantGstPercentage ??
                    '0';
          }

          // tenentFlatDetails?.flatGstPercentage ?? '0';
          // gst_value = double.parse(tenentFlatDetails?.flatGstAmount ?? '0');
          gst_value = double.parse(
                  dataModel.response?.tenentDetails?[0].balanceConsideration ??
                      '0') *
              (double.parse(_txtControllerGstPercentage.text.trim()) / 100);
          if (double.parse(
                  dataModel.response?.tenentDetails?[0].tenantStampduty ??
                      '0') >
              0) {
            setState(() {
              isStampDutySelected = true;
            });
          }
          registrationFeesController.text =
              dataModel.response?.tenentDetails?[0].registrationFees ?? '';
          stampDurty = dataModel.response?.gstStumpDuty?.stampDurty;
          tdsPercentage = dataModel.response?.gstStumpDuty?.tdsPercentage;
          gstPer = dataModel.response?.gstStumpDuty?.gstPer;
          flatDetails = dataModel.response?.flatDetails;
          totalTenntPaid = dataModel.response?.totalTenntPaid;
          parkingList = dataModel.response?.parkingList;
          tenentDetails = dataModel.response?.tenentDetails;
          // print(jsonEncode(dataModel.response!.parkingList));
          // _txtcontrollerParkingCount.text =
          //     dataModel.response?.parkingList?.length.toString() ?? '';
          focPercentageController.text =
              dataModel.response?.tenentDetails?[0].tenentFocAreaPerc ?? '';
          focController.text =
              dataModel.response?.tenentDetails?[0].tenentFocArea ?? '';
          mhadaController.text =
              dataModel.response?.tenentDetails?[0].tenentMahadArea ?? '';
          purchaseAreaController.text =
              dataModel.response?.tenentDetails?[0].tenentPurchaseArea ?? '';
          purchaseCostController.text =
              dataModel.response?.tenentDetails?[0].proposedConsideration ?? '';
          purchaseRateController.text =
              dataModel.response?.tenentDetails?[0].proposedRatePerSqft ?? '';
          amountAdjustedController.text =
              dataModel.response?.tenentDetails?[0].tenentLampAdjusted ?? '';
          totalConsiderationController.text =
              dataModel.response?.tenentDetails?[0].balanceConsideration ?? '';
          remarkController.text =
              dataModel.response?.tenentDetails?[0].tenantRemark ?? '';
          totalProposedController =
              TextEditingController(text: tenentDetails?[0].tenantProposedArea);
          _txtcontrollerParkingCount.text =
              dataModel.response?.flatDetails?[0].inventyParkingNumber ??
                  ''; //'${parkingList?.length}';
          // _chooseParkingController
          if (dataModel.response!.tenentDetails?[0].tenantTdsAmount?.trim() !=
                  "" &&
              double.parse(
                      dataModel.response!.tenentDetails?[0].tenantTdsAmount ??
                          '0') >
                  0) {
            flagTDSValue =
                dataModel.response!.tenentDetails?[0].tenantFlagOpt == "1"
                    ? true
                    : false;
            tdsValue = double.parse(
                dataModel.response!.tenentDetails?[0].tenantTdsAmount ?? '0');
          }
          String temp = '';
          List<ParkingList>? parkingListTemp = [];

          for (int k = 0; k < parkingList!.length; k++) {
            for (int i = 0; i < widget.podiumList.length; i++) {
              for (int p = 0;
                  p < widget.podiumList[i].parkingList!.length;
                  p++) {
                if (parkingList?[k].parkingSerialNo ==
                    widget.podiumList[i].parkingList?[p].parkingSerialNo) {
                  setState(() {
                    widget.podiumList[i].parkingList?[p].selected = "true";
                    // parkingList?[k].selected = "true";
                    parkingListTemp.add(widget.podiumList[i].parkingList![p]);
                    if (temp == "") {
                      temp = widget
                              .podiumList[i].parkingList?[p].parkingSerialNo ??
                          '';
                    } else {
                      temp =
                          '${temp}, ${widget.podiumList[i].parkingList?[p].parkingSerialNo}';
                    }
                  });
                }
              }
            }
          }
          _chooseParkingController.text = temp;
          parkingList = parkingListTemp;
        });
        CustomLoading.progressDialog(isLoading: false, context: context);
      } else {
        CustomLoading.progressDialog(isLoading: false, context: context);
      }
    } else {
      CustomLoading.progressDialog(isLoading: false, context: context);
    }
    // return null;
  }

  Future<ParkingList?> updateRehabTenent() async {
    CustomLoading.progressDialog(isLoading: true, context: context);
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId!,
      "inventy_parking_number": widget.inventyParkingNumber ?? '',
      "tenent_id": widget.tenentId ?? '',
      "flat_id": widget.flatId ?? '',
      "parking_id": jsonEncode(parkingList),
      "project_id": widget.projectId!,
      "towar_id": widget.towarId ?? '',
      'tenant_exit_area': tenentDetails?[0].tenantExitArea ?? '', //existing
      'tenant_proposed_area': totalProposedController.text,
      'tenent_foc_area': focController.text,
      'tenent_mahad_area': mhadaController.text,
      'tenent_purchase_area': purchaseAreaController.text,
      'proposed_rate_per_sqft': purchaseRateController.text,
      'tenent_lamp_adjusted': amountAdjustedController.text,
      'balance_consideration': totalConsiderationController.text,
      "proposed_consideration": purchaseCostController.text,
      "stampper": stampDurty ?? '0',
      "stampduty": isStampDutySelected == false
          ? "0"
          : ((double.parse(totalConsiderationController.text) *
                      double.parse(stampDurty ?? '0')) /
                  100)
              .toStringAsFixed(2),
      "remark": remarkController.text,
      "registration_fees": registrationFeesController.text,
      "foc_percentage": focPercentageController.text,
      "tdsvalue": flagTDSValue == true ? tdsValue.toString() : '0.0',
      "tdsper": tdsPercentage ?? '0',
      "gst_percentage": _txtControllerGstPercentage.text ?? '0',
      // "gst_value": gst_value.toStringAsFixed(2),
    };

    var response = await apiNetworkHandler.post(AppUrl.webSetRehabTenent, data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      CustomLoading.progressDialog(isLoading: false, context: context);
      Future.delayed(Duration.zero).then((_) {
        Alert(
            closeIcon: const SizedBox(),
            padding: const EdgeInsets.only(top: 0.0, left: 15, right: 15),
            image: Image.asset('images/Icon-512.png',
                height: 80, fit: BoxFit.fitWidth),
            style: const AlertStyle(
                titleTextAlign: TextAlign.center,
                descTextAlign: TextAlign.center,
                descStyle:
                    TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                isCloseButton: true),
            context: context,
            desc: 'You have Successfully Updated Tenant Details.',
            alertAnimation: fadeAlertAnimation,
            buttons: [
              DialogButton(
                onPressed: () {
                  // Navigator.pop(context);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                color: Colors.black,
                child: const Text(
                  "CLOSE",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ]).show();
      });
    } else {
      CustomLoading.progressDialog(isLoading: false, context: context);
    }
    // return null;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getRehabTenent();
      if (widget.podiumList.isNotEmpty) {
        double temp = 0;
        for (int i = 0; i < widget.podiumList.length; i++) {
          print(widget.podiumList[i].available);
          temp = temp + double.parse(widget.podiumList[i].available ?? '0');
        }
        parkindgTotalCt = temp;
      }
    });

    super.initState();
  }

  updateConfirmationModal() {
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
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  "Are you sure you want to submit tenant details?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
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
                        width: 170,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            // bottomRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'NO',
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
                        Navigator.pop(context);
                        updateRehabTenent();
                      },
                      child: Container(
                        width: 170,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(8),
                            // bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'YES',
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
              // content: SizedBox(
              //   height: 300,
              //   width: 400,
              // ),
            );
          });
        });
  }

  void updateFromFocArea() {
    final exitArea =
        double.tryParse(tenentDetails?[0].tenantExitArea ?? "0") ?? 0;
    final focArea = double.tryParse(focController.text) ?? 0;

    if (exitArea > 0) {
      focPercentageController.text =
          ((focArea / exitArea) * 100).toStringAsFixed(2);
    }

    recalculateFromPurchaseAreaAndRate();
  }

  void updateFromFocPercentage() {
    final exitArea =
        double.tryParse(tenentDetails?[0].tenantExitArea ?? "0") ?? 0;
    final focPercent = double.tryParse(focPercentageController.text) ?? 0;

    if (exitArea > 0) {
      focController.text = ((exitArea * focPercent) / 100).toStringAsFixed(2);
    }

    recalculateFromPurchaseAreaAndRate();
  }

  void recalculateFromPurchaseAreaAndRate() {
    final exitArea =
        double.tryParse(tenentDetails?[0].tenantExitArea ?? "0") ?? 0;
    final focArea = double.tryParse(focController.text) ?? 0;
    final purchaseArea = double.tryParse(purchaseAreaController.text) ?? 0;
    final rate = double.tryParse(purchaseRateController.text) ?? 0;
    final adjustedAmount = double.tryParse(amountAdjustedController.text) ?? 0;

    final totalProposed = exitArea + focArea + purchaseArea;
    final purchaseCost = purchaseArea * rate;
    final totalConsideration = purchaseCost - adjustedAmount;

    // Purchase Rate Per Sqft = Purchase Cost / Purchase Area

    // setState(() {
    totalProposedController.text = totalProposed.toStringAsFixed(2);
    if (rate > 0) {
      purchaseCostController.text = purchaseCost.toStringAsFixed(2);
    }
    // purchaseCostController.text = purchaseCost.toStringAsFixed(2);
    totalConsiderationController.text = totalConsideration.toStringAsFixed(2);
    // });

    // updateFromPurchaseCost();

    // final purchaseArea = double.tryParse(purchaseAreaController.text) ?? 0;
    // final purchaseCost = double.tryParse(purchaseCostController.text) ?? 0;

    // if (purchaseArea > 0) {
    //   purchaseRateController.text =
    //       (purchaseCost / purchaseArea).toStringAsFixed(2);
    // }

    // final adjustedAmount = double.tryParse(amountAdjustedController.text) ?? 0;
    totalConsiderationController.text =
        (purchaseCost - adjustedAmount).toStringAsFixed(2);
  }

  void updateFromPurchaseCost() {
    final purchaseArea = double.tryParse(purchaseAreaController.text) ?? 0;
    final purchaseCost = double.tryParse(purchaseCostController.text) ?? 0;

    if (purchaseArea > 0) {
      purchaseRateController.text =
          (purchaseCost / purchaseArea).toStringAsFixed(2);
    }

    final adjustedAmount = double.tryParse(amountAdjustedController.text) ?? 0;
    totalConsiderationController.text =
        (purchaseCost - adjustedAmount).toStringAsFixed(2);
  }

  void updateFromAdjustedAmount() {
    final purchaseCost = double.tryParse(purchaseCostController.text) ?? 0;
    final adjusted = double.tryParse(amountAdjustedController.text) ?? 0;

    totalConsiderationController.text =
        (purchaseCost - adjusted).toStringAsFixed(2);
  }

  void updateFromTotalConsideration() {
    final totalConsideration =
        double.tryParse(totalConsiderationController.text) ?? 0;
    final adjusted = double.tryParse(amountAdjustedController.text) ?? 0;

    final purchaseCost = totalConsideration + adjusted;
    purchaseCostController.text = purchaseCost.toStringAsFixed(2);

    final purchaseArea = double.tryParse(purchaseAreaController.text) ?? 0;
    if (purchaseArea > 0) {
      purchaseRateController.text =
          (purchaseCost / purchaseArea).toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // Set radius to zero
                        ),
                        actionsPadding: EdgeInsets.zero,
                        titlePadding: EdgeInsets.zero,
                        title: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'INFO',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
                              width: 600,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'CLOSE',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        ],
                        content: StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return const SizedBox(
                            height: 220,
                            width: 400,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "1. Existing Area + Free of Cost (FOC) + Purchased Area = Total Proposed Area",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "2. Total Proposed Area - Free of Cost (FOC) = Purchased Area",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "3. Purchased Cost - Amount Adjusted = Total Consideration Value (Balance)",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "4. Purchased Cost ÷  Purchase Area = Purchased Rate Per Sq. ft",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "5. Purchased Area  × Purchased Rate Per Sq. ft = Purchased Cost",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "6. Total Consideration Value (Balance) + Amount Adjusted = Purchased Cost",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "7. Stamp duty will be Calculated on Total Consideration Value (Balance)",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          );
                        }));
                  });
            },
            child: const Icon(
              Icons.info,
              size: 30,
            ),
          ),
          const SizedBox(width: 80)
        ],
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
      ),
      bottomNavigationBar: Container(
        height: 100,
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black))),
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 80.0, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Value (Excl. G.S.T) : ',
                      style: TextStyle(
                          fontStyle: FontStyle.normal, fontSize: 17.0)),
                  const Spacer(),
                  const Text('₹',
                      style: TextStyle(
                          fontStyle: FontStyle.normal, fontSize: 17.0)),
                  Container(
                    width: 200,
                    height: 50,
                    child: TextFormField(
                      readOnly: true,
                      enabled: false,
                      controller: totalConsiderationController,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400),
                      decoration: InputDecoration(
                        disabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: (Colors.transparent),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12.0),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        hintText: 'Enter Total Consideration Value',
                        hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 116, 116, 116),
                          fontSize: 13.0,
                          fontWeight: FontWeight.w200,
                          fontFamily: 'HelveticaNeue',
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        updateConfirmationModal();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: const BoxDecoration(
                          color: Colors.black,
                          border:
                              Border(right: BorderSide(color: Colors.white))),
                      child: const Text(
                        "UPDATE",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        // updateConfirmationModal();
                        var projectId = widget.projectId!;
                        var projectName = widget.projectName!;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              return PaymentTermsViewTenant(
                                gst_percentage:
                                    _txtControllerGstPercentage.text,
                                gst_value: gst_value.toString(),
                                towarName: widget.towarName,
                                projectId: projectId,
                                towarId: widget.towarId!,
                                projectName: projectName,
                                buyerName: tenentDetails?[0].tenantName,
                                flatArea:
                                    double.parse(purchaseAreaController.text),

                                // double.parse(totalProposedController.text),
                                arrSelectedFlatForSaleList: [
                                  FlatList(
                                    flatId: flatDetails?[0].mstInventryFlatId,
                                    flatName: flatDetails?[0].inventryFlatName,
                                  )
                                ],
                                RatePerSqFt:
                                    double.parse(purchaseRateController.text),
                                strFlatValue: totalConsiderationController.text,
                                strFlatArea: totalProposedController.text,
                                TotalValue: totalConsiderationController.text,
                                isFromTenant: true,
                                tenent_mahad_area: mhadaController.text,
                                tenent_lamp_adjusted:
                                    amountAdjustedController.text,
                                inventy_parking_number:
                                    _txtcontrollerParkingCount.text,
                                tenent_purchase_area:
                                    purchaseAreaController.text,
                                flat_booking_status: '0',
                                tenent_id: tenentDetails?[0].tenantId,
                                gst_amout: ((double.parse(
                                                totalConsiderationController
                                                    .text) *
                                            double.parse(gstPer ?? '0')) /
                                        100)
                                    .toStringAsFixed(2),
                                balance_consideration:
                                    totalConsiderationController.text,
                                tenant_proposed_area:
                                    totalProposedController.text,
                                stampduty: isStampDutySelected == false
                                    ? ""
                                    : ((double.parse(
                                                    totalConsiderationController
                                                        .text) *
                                                double.parse(
                                                    stampDurty ?? '0')) /
                                            100)
                                        .toStringAsFixed(2),
                                flat_id: widget.flatId,
                                tenant_exit_area:
                                    tenentDetails?[0].tenantExitArea,
                                tenent_foc_area: focController.text,
                                proposed_rate_per_sqft:
                                    purchaseRateController.text,
                                proposed_consideration:
                                    purchaseCostController.text,
                                tdsPercentage: tdsPercentage ?? '0',
                                tdsValue: flagTDSValue == true
                                    ? tdsValue.toString()
                                    : '0',
                              );
                            },
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      color: Colors.black,
                      child: const Text(
                        "PROCEED",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
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
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 8, bottom: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black87),
                  ),
                ),
                width: double.maxFinite,
                child: const AppText(
                  title: "TENANT DETAILS",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  titleTextAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              if (tenentDetails!.isNotEmpty) ...[
                rowText(
                    title: 'Tenant Name',
                    value: tenentDetails?[0].tenantName ?? ''),
                const SizedBox(height: 14),
                rowText(
                    title: 'Email',
                    value: tenentDetails?[0].email ?? '',
                    hintText: 'Enter Email'),
                const SizedBox(height: 14),
                rowText(
                    title: 'Mobile Number',
                    value: tenentDetails?[0].mobile ?? '',
                    hintText: 'Enter Number'),
                const SizedBox(height: 14),
                rowText(
                    title: 'Flat Number',
                    value: flatDetails?[0].inventryFlatName ?? ''),
                const SizedBox(height: 14),
                rowText(
                    title: 'Opted',
                    value:
                        tenentDetails?[0].obtain == "1" ? 'Rental' : 'Transit'),
                const SizedBox(height: 14),
                rowText(
                  title: 'Residential',
                  value: tenentDetails?[0].userResidnt == "1"
                      ? 'Residential'
                      : "Non Residential",
                ),
                const SizedBox(height: 14),
                rowText(
                    title: 'Existing Area',
                    value: tenentDetails?[0].tenantExitArea ?? ''),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(left: 80.0, right: 80.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 230.0,
                        height: 40.0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: Text('FOC (Free of Cost Area)',
                              style: TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ),
                      ),
                      horizontalSpaceSmall,
                      Expanded(
                        child: TextFormField(
                          controller: focController,
                          // onChanged: (value) {
                          //   final parsedValue = double.tryParse(value) ?? 0;
                          //   final exitArea = double.tryParse(
                          //           tenentDetails?[0].tenantExitArea ?? "0") ??
                          //       0;
                          //   final purchaseArea =
                          //       double.tryParse(purchaseAreaController.text) ??
                          //           0;

                          //   if (parsedValue > 0 && exitArea > 0) {
                          //     focPercentageController.text =
                          //         ((parsedValue / exitArea) * 100)
                          //             .toStringAsFixed(2);
                          //   } else {
                          //     focPercentageController.text = "0.00";
                          //   }

                          //   totalProposedController.text =
                          //       (exitArea + parsedValue + purchaseArea)
                          //           .toStringAsFixed(2);
                          // },
                          onChanged: (_) => updateFromFocArea(),

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
                            hintText: 'Enter FOC (Free of Cost Area)',
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 116, 116, 116),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'HelveticaNeue',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 100.0,
                        height: 40.0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: Text('FOC (%)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: focPercentageController,
                          // onChanged: (value) {
                          //   final parsedFOCPercent =
                          //       double.tryParse(value) ?? 0;
                          //   final exitArea = double.tryParse(
                          //           tenentDetails?[0].tenantExitArea ?? "0") ??
                          //       0;
                          //   final purchaseArea =
                          //       double.tryParse(purchaseAreaController.text) ??
                          //           0;

                          //   // Calculate FOC Area from % input
                          //   double focArea = 0;
                          //   if (parsedFOCPercent > 0 && exitArea > 0) {
                          //     focArea = (exitArea * parsedFOCPercent) / 100;
                          //   }

                          //   focController.text = focArea.toStringAsFixed(2);

                          //   // Calculate Total Proposed Area
                          //   final totalProposed =
                          //       exitArea + focArea + purchaseArea;
                          //   totalProposedController.text =
                          //       totalProposed.toStringAsFixed(2);
                          // },
                          onChanged: (_) => updateFromFocPercentage(),

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
                            hintText: 'Enter FOC (%)',
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 116, 116, 116),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'HelveticaNeue',
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(left: 80.0, right: 80.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 230.0,
                        height: 40.0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: Text('MHADA Carpet Area',
                              style: TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ),
                      ),
                      horizontalSpaceSmall,
                      Expanded(
                        child: TextFormField(
                          // validator: (value) {
                          //   if (value!.isEmpty) {
                          //     return "Enter No. of Parking";
                          //   }
                          //   return null;
                          // },
                          controller: mhadaController,
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
                            hintText: 'Enter MHADA Carpet Area',
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 116, 116, 116),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'HelveticaNeue',
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(left: 80.0, right: 80.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 230.0,
                        height: 40.0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: Text('Purchased Area',
                              style: TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ),
                      ),
                      horizontalSpaceSmall,
                      Expanded(
                        child: TextFormField(
                          // onChanged: (value) {
                          //   final focArea =
                          //       double.tryParse(focController.text) ?? 0;
                          //   final purchaseArea = double.tryParse(value) ?? 0;
                          //   final exitArea = double.tryParse(
                          //           tenentDetails?[0].tenantExitArea ?? '0') ??
                          //       0;
                          //   final purchaseRate =
                          //       double.tryParse(purchaseRateController.text) ??
                          //           0;
                          //   final adjustedAmount = double.tryParse(
                          //           amountAdjustedController.text) ??
                          //       0;

                          //   // Total Proposed Area = FOC + Purchase + Exit Area
                          //   final totalProposed =
                          //       focArea + purchaseArea + exitArea;
                          //   totalProposedController.text =
                          //       totalProposed.toStringAsFixed(2);

                          //   // Purchase Cost = Purchase Area * Rate
                          //   final purchaseCost = purchaseArea * purchaseRate;
                          //   purchaseCostController.text =
                          //       purchaseCost.toStringAsFixed(2);

                          //   // Total Consideration = Purchase Cost - Adjusted Amount
                          //   final totalConsideration =
                          //       purchaseCost - adjustedAmount;
                          //   totalConsiderationController.text =
                          //       totalConsideration.toStringAsFixed(2);
                          // },
                          onChanged: (_) =>
                              recalculateFromPurchaseAreaAndRate(),

                          controller: purchaseAreaController,
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
                            hintText: 'Enter Purchase Area',
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 116, 116, 116),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'HelveticaNeue',
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(left: 80.0, right: 80.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 230.0,
                        height: 40.0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: Text('Total Proposed Area',
                              style: TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ),
                      ),
                      horizontalSpaceSmall,
                      Expanded(
                        child: TextFormField(
                          // enabled: false,
                          // readOnly: true,
                          // onChanged: (value) {
                          //   final totalArea = double.tryParse(value) ?? 0;
                          //   final focArea =
                          //       double.tryParse(focController.text) ?? 0;

                          //   final purchaseArea = totalArea - focArea;
                          //   purchaseAreaController.text =
                          //       purchaseArea.toStringAsFixed(2);
                          // },
                          controller: totalProposedController,
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
                            hintText: 'Enter Total Proposed Area',
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 116, 116, 116),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'HelveticaNeue',
                            ),
                          ),
                        ),
                      ),
                      // SizedBox(width: 20),
                      // const SizedBox(
                      //   // width: 230.0,
                      //   height: 40.0,
                      //   child: Padding(
                      //     padding: EdgeInsets.only(top: 15.0),
                      //     child: Text('Final Proposed Area',
                      //         style: TextStyle(
                      //             backgroundColor: Colors.white,
                      //             fontSize: 15,
                      //             color: Colors.black)),
                      //   ),
                      // ),
                      // SizedBox(width: 20),
                      // Expanded(
                      //   child: TextFormField(
                      //     // onChanged: (value) {
                      //     //   final totalArea = double.tryParse(value) ?? 0;
                      //     //   final focArea =
                      //     //       double.tryParse(focController.text) ?? 0;

                      //     //   final purchaseArea = totalArea - focArea;
                      //     //   purchaseAreaController.text =
                      //     //       purchaseArea.toStringAsFixed(2);
                      //     // },
                      //     controller: totalProposedController,
                      //     style: const TextStyle(
                      //         color: Colors.black,
                      //         fontSize: 14.0,
                      //         fontWeight: FontWeight.w400),
                      //     decoration: InputDecoration(
                      //       disabledBorder: OutlineInputBorder(
                      //         borderSide:
                      //             const BorderSide(color: Colors.black38),
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //       focusedBorder: OutlineInputBorder(
                      //         borderSide: const BorderSide(
                      //           color: (Colors.black38),
                      //         ),
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //       enabledBorder: OutlineInputBorder(
                      //         borderSide: const BorderSide(
                      //           color: (Colors.black38),
                      //         ),
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //       errorBorder: OutlineInputBorder(
                      //         borderSide: const BorderSide(
                      //           color: (Colors.red),
                      //         ),
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //       focusedErrorBorder: OutlineInputBorder(
                      //         borderSide: const BorderSide(
                      //           color: (Colors.black38),
                      //         ),
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //       contentPadding: const EdgeInsets.all(12.0),
                      //       border: const OutlineInputBorder(
                      //         borderSide: BorderSide(color: Colors.black54),
                      //       ),
                      //       hintText: 'Enter Total Proposed Area',
                      //       hintStyle: const TextStyle(
                      //         color: Color.fromARGB(255, 116, 116, 116),
                      //         fontSize: 13.0,
                      //         fontWeight: FontWeight.w200,
                      //         fontFamily: 'HelveticaNeue',
                      //       ),
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(left: 80.0, right: 80.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 230.0,
                        height: 40.0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: Text('Purchased Cost',
                              style: TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ),
                      ),
                      horizontalSpaceSmall,
                      Expanded(
                        child: TextFormField(
                          // onChanged: (value) {
                          //   final totalPurchaseCost =
                          //       double.tryParse(value) ?? 0;
                          //   final purchaseArea =
                          //       double.tryParse(purchaseAreaController.text) ??
                          //           0;

                          //   if (totalPurchaseCost > 0 && purchaseArea > 0) {
                          //     final rate = totalPurchaseCost / purchaseArea;
                          //     purchaseRateController.text =
                          //         rate.toStringAsFixed(2);
                          //   } else {
                          //     purchaseRateController.text =
                          //         "0.00"; // optional fallback
                          //   }
                          // },
                          onChanged: (_) => updateFromPurchaseCost(),

                          controller: purchaseCostController,
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
                            hintText: 'Enter Purchase Cost',
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 116, 116, 116),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'HelveticaNeue',
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(left: 80.0, right: 80.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 230.0,
                        height: 40.0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: Text('Purchased Rate Per Sqft',
                              style: TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ),
                      ),
                      horizontalSpaceSmall,
                      Expanded(
                        child: TextFormField(
                          // onChanged: (value) {
                          //   final rate = double.tryParse(value) ?? 0;
                          //   final area =
                          //       double.tryParse(purchaseAreaController.text) ??
                          //           0;

                          //   if (rate > 0 && area > 0) {
                          //     final cost = rate * area;
                          //     purchaseCostController.text =
                          //         cost.toStringAsFixed(2);
                          //   } else {}
                          //   final purchaseCost =
                          //       double.tryParse(purchaseCostController.text) ??
                          //           0;
                          //   final adjustedAmount = double.tryParse(
                          //           amountAdjustedController.text) ??
                          //       0;

                          //   final total = purchaseCost - adjustedAmount;
                          //   totalConsiderationController.text =
                          //       total.toStringAsFixed(2);
                          // },
                          onChanged: (_) =>
                              recalculateFromPurchaseAreaAndRate(),

                          controller: purchaseRateController,
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
                            hintText: 'Enter Purchase Rate Per Sqft',
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 116, 116, 116),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'HelveticaNeue',
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(left: 80.0, right: 80.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 230.0,
                        height: 40.0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: Text('Amount Adjusted',
                              style: TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ),
                      ),
                      horizontalSpaceSmall,
                      Expanded(
                        child: TextFormField(
                          controller: amountAdjustedController,
                          // onChanged: (value) {
                          //   final purchaseCost =
                          //       double.tryParse(purchaseCostController.text) ??
                          //           0;
                          //   final adjustedAmount = double.tryParse(value) ?? 0;

                          //   final total = purchaseCost - adjustedAmount;
                          //   totalConsiderationController.text =
                          //       total.toStringAsFixed(2);
                          // },
                          onChanged: (_) => updateFromAdjustedAmount(),

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
                            hintText: 'Enter Amount Adjusted',
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 116, 116, 116),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'HelveticaNeue',
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(left: 80.0, right: 80.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 230.0,
                        height: 40.0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: Text('Total Consideration Value (Balance)',
                              style: TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ),
                      ),
                      horizontalSpaceSmall,
                      Expanded(
                        child: TextFormField(
                          // onChanged: (value) {
                          //   final enteredCost = double.tryParse(value) ?? 0;
                          //   final adjustedAmount = double.tryParse(
                          //           amountAdjustedController.text) ??
                          //       0;
                          //   final purchaseArea =
                          //       double.tryParse(purchaseAreaController.text) ??
                          //           0;

                          //   // Calculate Purchase Cost
                          //   final purchaseCost = enteredCost + adjustedAmount;
                          //   purchaseCostController.text =
                          //       purchaseCost.toStringAsFixed(2);

                          //   // Calculate Purchase Rate
                          //   if (purchaseArea > 0) {
                          //     final rate = purchaseCost / purchaseArea;
                          //     purchaseRateController.text =
                          //         rate.toStringAsFixed(2);
                          //   } else {
                          //     purchaseRateController.text =
                          //         "0.00"; // Optional fallback
                          //   }
                          // },
                          onChanged: (_) => updateFromTotalConsideration(),

                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Total Consideration Value Cannot be Empty";
                            }
                            return null;
                          },
                          controller: totalConsiderationController,
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
                            hintText: 'Enter Total Consideration Value',
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 116, 116, 116),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'HelveticaNeue',
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(left: 80.0, right: 80.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 230.0,
                        height: 40.0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: Text('No. of Parking',
                              style: TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ),
                      ),
                      horizontalSpaceSmall,
                      Expanded(
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter No. of Parking";
                            }
                            return null;
                          },
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
                            hintText: 'Enter No. of Parking',
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 116, 116, 116),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'HelveticaNeue',
                            ),
                          ),
                        ),
                      ),
                      horizontalSpaceSmall,
                      SizedBox(
                        width: 50.0,
                        height: 40.0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text('/ $parkindgTotalCt',
                              style: const TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(left: 80.0, right: 80.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 230.0,
                        height: 40.0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: Text('Select Parking',
                              style: TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ),
                      ),
                      horizontalSpaceSmall,
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            print('clicked ${widget.flatId}');
                            _txtcontrollerParkingCount.text.isNotEmpty
                                ? _show(
                                    flatId: widget.flatId ?? '',
                                  )
                                : null;
                          },
                          child: TextFormField(
                            validator: (value) {
                              if (_txtcontrollerParkingCount.text.isNotEmpty &&
                                  value!.isEmpty) {
                                return null;
                              } else if (_txtcontrollerParkingCount
                                      .text.isNotEmpty &&
                                  value!.isNotEmpty) {
                                if (parkingList!.length !=
                                    double.parse(
                                        _txtcontrollerParkingCount.text)) {
                                  return "Parking Allocation should be same as Entered Parking Count";
                                }
                              }
                              return null;
                            },
                            enabled: false,
                            readOnly: true,
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
                              hintText: 'Select Parking',
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
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(left: 80.0, right: 80.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 230.0,
                        height: 40.0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: Text('GST (%)',
                              style: TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ),
                      ),
                      horizontalSpaceSmall,
                      Container(
                        height: 45.0,
                        width: 200,
                        decoration: BoxDecoration(
                            // color: kcTextFieldColor,
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5.0))),
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: TextField(
                            controller: _txtControllerGstPercentage,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 15.0),
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 18.0),
                              border: InputBorder.none,
                              hintText: 'Enter GST percentage',
                            ),
                            onChanged: (String str) {
                              setState(() {
                                // _txtControllerGstPercentage.text = dataModel
                                //         .response
                                //         ?.tenentDetails?[0]
                                //         .tenantGstPercentage ??
                                //     '0';
                                // tenentFlatDetails?.flatGstPercentage ?? '0';
                                // gst_value = double.parse(tenentFlatDetails?.flatGstAmount ?? '0');
                                if (totalConsiderationController
                                    .text.isNotEmpty)
                                  gst_value = double.parse(
                                          totalConsiderationController.text) *
                                      (double.parse(_txtControllerGstPercentage
                                              .text
                                              .trim()) /
                                          100);

                                // gst_value = strTotalValueBottom *
                                //     (double.parse(_txtControllerGstPercentage
                                //             .text
                                //             .trim()) /
                                //         100);
                              });
                            },
                          ),
                        ),
                      ),
                      horizontalSpaceSmall,
                      Padding(
                        padding: EdgeInsets.only(top: 15.0),
                        child: Text(
                            // '00',
                            currencyFormat.format(
                                double.parse(gst_value.toStringAsFixed(2))),
                            style: TextStyle(
                                backgroundColor: Colors.white,
                                fontSize: 15,
                                color: Colors.black)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(left: 80.0, right: 80.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 230.0,
                        height: 40.0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: Text('Stamp Duty Value (6%)',
                              style: TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ),
                      ),
                      horizontalSpaceSmall,
                      isStampDutySelected == true
                          ? InkWell(
                              onTap: () {
                                setState(() {
                                  isStampDutySelected = false;
                                });
                              },
                              child: const Icon(
                                Icons.check_box,
                                size: 40,
                                color: Colors.black,
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                setState(() {
                                  isStampDutySelected = true;
                                });
                              },
                              child: const Icon(
                                Icons.check_box_outline_blank,
                                size: 40,
                                color: Colors.black,
                              ),
                            ),
                      const SizedBox(width: 10),
                      Text(
                        isStampDutySelected == false
                            ? ""
                            : currencyFormat.format(
                                (double.parse(purchaseCostController.text) *
                                        double.parse(stampDurty ?? '0')) /
                                    100),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(
                        width: 230.0,
                        // height: 40.0,
                        child: Text('TDS Value (${tdsPercentage}%)',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                backgroundColor: Colors.white,
                                fontSize: 15,
                                color: Colors.black)),
                      ),
                      horizontalSpaceSmall,
                      InkWell(
                          onTap: () {
                            var rupee = "\u{20B9}";

                            var flatAgreementValue =
                                totalConsiderationController.text;
                            print(
                                '${flatAgreementValue}------------------flatAgreementValue');
                            flatAgreementValue =
                                flatAgreementValue.replaceAll(rupee, "");
                            flatAgreementValue =
                                flatAgreementValue.replaceAll(",", "");
                            setState(() {
                              tdsValue = double.parse(flatAgreementValue) *
                                  double.parse(tdsPercentage ?? '0') /
                                  100;
                              flagTDSValue = !flagTDSValue;
                            });
                          },
                          child: flagTDSValue == true
                              ? const Icon(
                                  Icons.check_box,
                                  size: 40,
                                  // color: _txtControllerFlatAgreementValue
                                  //         .text.isNotEmpty
                                  //     ? Colors.black
                                  //     : Colors.grey,
                                )
                              : const Icon(
                                  Icons.check_box_outline_blank,
                                  size: 40,
                                  color: Colors.black,
                                )),
                      horizontalSpaceSmall,
                      flagTDSValue == true
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text(currencyFormat.format(tdsValue)),
                            )
                          : const SizedBox(),
                      horizontalSpaceSmall,
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(left: 80.0, right: 80.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 230.0,
                        height: 40.0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: Text('Registration Fees',
                              style: TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ),
                      ),
                      horizontalSpaceSmall,
                      Expanded(
                        child: TextFormField(
                          onChanged: (value) {},
                          controller: registrationFeesController,
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
                            hintText: 'Enter Registration Fees',
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 116, 116, 116),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'HelveticaNeue',
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(left: 80.0, right: 80.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 230.0,
                        height: 40.0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: Text('Remark',
                              style: TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ),
                      ),
                      horizontalSpaceSmall,
                      Expanded(
                        child: TextFormField(
                          maxLines: 3,
                          controller: remarkController,
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
                            hintText: 'Enter Remark',
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 116, 116, 116),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'HelveticaNeue',
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget rowText({
    required String title,
    required String value,
    String? hintText,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 80.0, right: 80.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 230.0,
            height: 40.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Text(title,
                  style: const TextStyle(
                      backgroundColor: Colors.white,
                      fontSize: 15,
                      color: Colors.black)),
            ),
          ),
          horizontalSpaceSmall,
          Expanded(
            child: Container(
              height: 45.0,
              decoration: BoxDecoration(
                  color: kcTextFieldColor,
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(5.0))),
              child: Container(
                color: Colors.white10,
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: TextFormField(
                  enabled: false,
                  readOnly: true,
                  controller: TextEditingController(text: value),
                  style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                    border: InputBorder.none,
                    hintText: hintText ?? 'Enter Text',
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

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
                          MyExpandableWidget(widget.podiumList[index], flatId),
                      itemCount: widget.podiumList!.length,
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
                      if (parkingList!.isNotEmpty) {
                        if (parkingList!.length <
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
              setState(() {
                if (checkParkingAlocated(details: details, flatId: flatId)) {
                } else {
                  print(
                      '${details.selected}------------------------- ${details.parkingSerialNo}');

                  if (details.selected == '') {
                    if (parkingList!.length <
                        int.parse(_txtcontrollerParkingCount.text)) {
                      details.selected = 'true';
                      parkingList!.add(details);
                    } else {
                      SmartDialog.dismiss();
                      messageAlert();
                    }
                  } else if (details.selected == 'true') {
                    details.selected = '';
                    parkingList?.remove(details);
                    for (int i = 0; i < parkingList!.length; i++)
                      print('removing---------------------');
                    inspect(details);
                  }
                }
              });
              var parking = "";
              if (parkingList!.isNotEmpty) {
                for (int i = 0; i < parkingList!.length; i++) {
                  if (i == 0) {
                    parking = parkingList![i].parkingSerialNo!;
                  } else {
                    parking = '$parking, ${parkingList![i].parkingSerialNo!}';
                  }
                }
              }
              _chooseParkingController.text = parking;
              // updateParkingNo(parking);
              print(parkingList);
              inspect(parkingList);
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
                                backgroundColor: Colors.white,
                                fontSize: 15,
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
}
