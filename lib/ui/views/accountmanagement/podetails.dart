import 'po_action_feedback.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_loading.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_style.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_layout.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_document.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_network.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:search_choices/search_choices.dart';
// import 'package:search_choices/search_choices.dart';
// import 'package:search_choices/search_choices.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/add_custom_po_unit.dart';
import 'package:stallion/models/po_approved_user.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import '../../../models/get_po_details_by_status.dart';
import '../../../models/get_po_requistion_vendor_list.dart';
import '../../../models/get_purchase_order_default_request.dart';
import '../../../models/grade_description.dart';
import '../../../models/message_success.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import '../PurchaseOrder/purchase_order_form.dart';
import 'paymentdue/popreviewhtmldetails.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PoDetails extends StatefulWidget {
  const PoDetails(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.poId,
      this.orderDetails});

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? poId;
  final RccBookingHistory? orderDetails;

  @override
  State<PoDetails> createState() => _PoDetailsState();
}

class _PoDetailsState extends State<PoDetails> {
  bool isChecked = false;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = AccountManagementPreviewNetwork();
  TextEditingController editingController = TextEditingController();
  TextEditingController creditControler = TextEditingController(text: "0");
  List<PlatformFile> arrayFiles = [];
  List<Uint8List?> arrayFilesBytes = [];
  GlobalKey formkey = GlobalKey<FormState>();
  String? _selectedReqTypeIndex;
  String? castingRequirementFor = "";
  final TextEditingController _txtCustomRequirementType =
      TextEditingController();
  final TextEditingController _txtSearchSlab = TextEditingController();

  GlobalKey formkeySlab = GlobalKey<FormState>();
  List<SlabDetail>? slabDetails = [];
  List<SlabDetail>? slabDetailsOriginal = [];
  // final List<TextEditingController> _txtControllerRequirmentType = [];

  // final List<TextEditingController> _typeAheadController = [];
  // final List<TextEditingController> _txtControllerRequirementFor = [];
  // final List<TextEditingController> _txtControllerQuantity = [];
  // final List<TextEditingController> _txtControllerUnitPrice = [];
  // final List<TextEditingController> _txtControllerTotalPrice = [];
  final TextEditingController _txtControllerRemark = TextEditingController();
  List<SlabDetail>? slabDetailsSelectedArray = [];
  late BuildContext dialogContext;

  int count = 1;

  String? strRemark = '';
  String? strSlabID = '';

  bool flagcalled = false;
  String searchText = '';

  String? selectedRequirementDate;
  String? selectedUnitType;
  String? selectedUnitId;
  var selectedRow = 0;

  String? selectedRequirementTypeId;

  String? selectedRequirementType;
  String? selectedRequirementId;
  List<DropdownMenuItem> gradeItems = [];

  List<DropdownMenuItem> unitItems = [];
  List<DropdownMenuItem> requirementTypeitems = [];
  List<SimilarDescription>? descriptionList;

  List<FinishingTypeList>? finishingTypeList;
  List<FinishingTypeList>? finishingTypeListOriginal = [];

  List<FinishingUnit>? finishingUnit;
  List<POformDataArrayList> arrayList = [];
  List<VenderList>? searchData = [];
  var searchDataSelected = [];
  List<AssingToList>? assingToList = [];
  String? purchaseUserTrack = '';

  String selectedAssignToId = '';

  Future<AssingToList?> setPoAssignTo() async {
    AccountLoading.progressDialog(isLoading: true, context: context);
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
      "order_id": widget.orderDetails?.orderId ?? '',
      "assign_to_id": selectedAssignToId,
    };

    var response = await apiNetworkHandler.post(AppUrl.webSetPoAssignTo, data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      AccountLoading.progressDialog(isLoading: false, context: context);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } else {
      AccountLoading.progressDialog(isLoading: false, context: context);
    }
    // return null;
  }

  Future<AssingToList?> setPoVerifyFlag({
    required String isCheck,
  }) async {
    AccountLoading.progressDialog(isLoading: true, context: context);
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
      "order_id": widget.orderDetails?.orderId ?? '',
      "po_verify_flag": isCheck,
    };

    var response = await apiNetworkHandler.post(AppUrl.wsSetPoVerifyFlag, data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        isChecked = !isChecked;
      });
      AccountLoading.progressDialog(isLoading: false, context: context);

      Navigator.of(context).pop();
      _showPoDialog<String>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => AlertDialog(
                clipBehavior: Clip.antiAlias,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                titlePadding: const EdgeInsets.symmetric(vertical: 0),
                actionsPadding: const EdgeInsets.symmetric(horizontal: 0),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                actionsAlignment: MainAxisAlignment.center,
                // title: const Text(''),
                // content: Text(
                //     'Successfully ${isCheck == '1' ? "checked" : "unchecked"} this PO.',
                //     style:
                //         TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
                title: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Successfully ${isCheck == '1' ? "checked" : "unchecked"} this PO.',
                    // "Are you sure, You want to ${isChecked ? 'uncheck' : 'check'} this PO?",
                    style: TextStyle(
                      fontSize: context.accountFont(18, mobile: 14),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                actions: <Widget>[
                  // ElevatedButton(
                  //   style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.black,
                  //       fixedSize: const Size.fromWidth(100),
                  //       padding: const EdgeInsets.all(10),
                  //       textStyle: const TextStyle(color: Colors.white)),
                  //   child: const Text('CLOSE',
                  //       style: TextStyle(
                  //           fontWeight: FontWeight.normal,
                  //           fontSize: 14.0,
                  //           color: Colors.white)),
                  //   onPressed: () {
                  //     setState(() {
                  //       Navigator.pop(context);
                  //       // Navigator.maybePop(context, true);
                  //     });
                  //   },
                  // ),
                  PoActionFeedback(
                      child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                      child: Text(
                        'OK',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: context.accountFont(18, mobile: 14),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )),
                ],
              ));
      // Navigator.of(context).pop();
    } else {
      AccountLoading.progressDialog(isLoading: false, context: context);
    }
    // return null;
  }

  List<AssingToList>? filteredAssignTo() {
    if (searchText.isEmpty) {
      return assingToList;
    }
    return assingToList!.where((project) {
      return project.transEmpName!
          .toLowerCase()
          .contains(searchText.toLowerCase());
    }).toList();
  }

  Future<ResponsePurchaseDefaultOrderRequest?> submitAddCustomRequirementType(
      int indexRow) async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "grade_name": _txtCustomRequirementType.text,
      "towar_id": towerId
    };
    if (kDebugMode) {
      print(data);
    }
    var response =
        await apiNetworkHandler.post(AppUrl.webAddCustomRequirementType, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      arrayList[indexRow].editingControllerGradeTypeName?.text =
          _txtCustomRequirementType.text;
      final dataModel = purchaseDefaultOrderRequestFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response!.errorCode == "0") {
        setState(() {
          finishingTypeList = dataModel.response?.finishingTypeList!;
          finishingTypeListOriginal = finishingTypeList;
          print(_txtCustomRequirementType.text.toLowerCase());
          for (var i = 0; i < finishingTypeList!.length; i++) {
            if (finishingTypeList![i].finishingName?.toLowerCase() ==
                _txtCustomRequirementType.text.toLowerCase()) {
              print('indexRow');
              print(indexRow);
              _selectedReqTypeIndex = finishingTypeList![i].finishingId!;
              arrayList[indexRow].grade_id = finishingTypeList![i].finishingId!;
              selectedRequirementTypeId = finishingTypeList![i].finishingId;
              arrayList[indexRow].grade_type_name =
                  finishingTypeList![i].finishingName!;
              // _txtControllerRequirmentType[indexRow].text =
              //     finishingTypeList![i].finishingName!;
              _txtCustomRequirementType.text = '';

              break;
            }
          }
          print('Exit');
          arrayList[indexRow].casting_unit_name = '';
          arrayList[indexRow].casting_unit = '';
          arrayList[indexRow].description = '';

          fetchGradeDescription(
              // selectedRequirementTypeIds: selectedRequirementTypeId ?? ''
              );
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
    return null;
  }

  _showCheckConfirmation() {
    return _showPoDialog(
        context: context,
        builder: (context) => AlertDialog(
              clipBehavior: Clip.antiAlias,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              titlePadding: EdgeInsets.zero,
              title: _poPopupHeader(isChecked
                  ? 'Uncheck Purchase Order'
                  : 'Check Purchase Order'),
              contentPadding: const EdgeInsets.all(20),
              content: SizedBox(
                  width: 360,
                  child: Text(
                      "Are you sure you want to ${isChecked ? 'uncheck' : 'check'} this PO?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: context.accountFont(16, mobile: 14)))),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                Row(children: [
                  Expanded(
                      child: PoActionFeedback(
                          child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                  shape: const StadiumBorder(),
                                  foregroundColor: Colors.black,
                                  side: const BorderSide(color: Colors.black)),
                              child: const Text('NO')))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: PoActionFeedback(
                          child: ElevatedButton(
                              onPressed: () => setPoVerifyFlag(
                                  isCheck: isChecked ? '0' : '1'),
                              style: ElevatedButton.styleFrom(
                                  shape: const StadiumBorder(),
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white),
                              child: const Text('YES')))),
                ])
              ],
            ));
  }

  updateConfirmationModal() {
    return _showPoDialog(
        context: context,
        builder: (context) => AlertDialog(
              clipBehavior: Clip.antiAlias,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              titlePadding: EdgeInsets.zero,
              title: _poPopupHeader('Assign Purchase Order'),
              contentPadding: const EdgeInsets.all(20),
              content: SizedBox(
                  width: 360,
                  child: Text('Are you sure you want to assign this PO?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: context.accountFont(16, mobile: 14)))),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                Row(children: [
                  Expanded(
                      child: PoActionFeedback(
                          child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                  shape: const StadiumBorder(),
                                  foregroundColor: Colors.black,
                                  side: const BorderSide(color: Colors.black)),
                              child: const Text('NO')))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: PoActionFeedback(
                          child: ElevatedButton(
                              onPressed: () => setPoAssignTo(),
                              style: ElevatedButton.styleFrom(
                                  shape: const StadiumBorder(),
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white),
                              child: const Text('YES')))),
                ])
              ],
            ));
  }

  Future<ResponsePurchaseDefaultOrderRequest?>
      fetchDefaultPurchaseOrderCreate() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.getGetDefaultPoCreate, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = purchaseDefaultOrderRequestFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        //return dataModel.response;
        assingToList = dataModel.response?.assingToList;
        purchaseUserTrack = dataModel.response?.purchaseUserTrack;
        finishingTypeList = dataModel.response?.finishingTypeList;
        finishingTypeListOriginal = dataModel.response?.finishingTypeList;
        if (useAccountManagementTestData) {
          finishingTypeList = [
            ...?finishingTypeList,
            for (final name in ['Cement', 'Ready Mix Concrete', 'Bricks', 'Sand', 'Aggregate', 'Plumbing Materials'])
              FinishingTypeList(finishingId: 'preview-type-$name',
                  finishingName: name, count: '0', finishingUnit: []),
          ];
          finishingTypeListOriginal = finishingTypeList;
        }

        slabDetails = dataModel.response?.slabDetails;
        slabDetailsOriginal = dataModel.response?.slabDetails;
        if (useAccountManagementTestData) {
          slabDetails = [
            ...?slabDetails,
            for (final name in ['Basement', 'Ground Floor', 'First Floor', 'Second Floor', 'Terrace'])
              SlabDetail(slab_name: name, slab_id: 'preview-slab-$name', selected: '0'),
          ];
          slabDetailsOriginal = slabDetails;
        }

        if (finishingTypeList!.isNotEmpty) {
          requirementTypeitems = [];
          for (var i = 0; i < finishingTypeList!.length; i++) {
            requirementTypeitems.add(DropdownMenuItem(
              value: finishingTypeList![i].finishingName!,
              onTap: () {
                if (kDebugMode) {
                  print(selectedRequirementTypeId);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text(finishingTypeList![i].finishingName ?? ''),
              ),
            ));
          }

          var orderList = widget.orderDetails!.orderDetails!;
          arrayList = [];
          unitItems = [];
          selectedRequirementDate = widget.orderDetails!.castingDate!;
          for (int i = 0; i < orderList.length; i++) {
            var unitPrice = '0';
            if (orderList[i].unitPrice! != '') {
              unitPrice = orderList[i].unitPrice!;
            }
            // Map<String, dynamic> dataList = {
            //   "grade_id": orderList[i].gradeId!,
            //   "grade_type_name": orderList[i].gradeName!,
            //   "casting_date": widget.orderDetails!.castingDate!,
            //   "casting_for": orderList[i].castingFor!,
            //   "casting_unit_name": orderList[i].castingUnitName!,
            //   "casting_unit": orderList[i].castingUnit!,
            //   "quantity": orderList[i].orderQuantity!,
            //   "unit_price": orderList[i].unitPrice!,
            //   "total_amount":
            //       "${double.parse(unitPrice) * double.parse(orderList[i].orderQuantity!)}",
            //   "description": orderList[i].gradeTypeName!,
            //   "id": "$i",
            // };
            POformDataArrayList dataList = POformDataArrayList(
                brand_supplier_name: orderList[i].brandSupplierName ?? '',
                grade_id: orderList[i].gradeId!,
                grade_type_name: orderList[i].gradeName!,
                casting_date: widget.orderDetails!.castingDate!,
                casting_for: orderList[i].castingFor!,
                casting_unit_name: orderList[i].castingUnitName!,
                casting_unit: orderList[i].castingUnit!,
                quantity: orderList[i].orderQuantity!,
                unit_price: orderList[i].unitPrice!,
                total_amount:
                    "${double.parse(unitPrice) * double.parse(orderList[i].orderQuantity!)}",
                description: orderList[i].gradeTypeName!,
                id: "$i",
                editingControllerGradeTypeName:
                    TextEditingController(text: orderList[i].gradeName),
                editingControllerDescription: TextEditingController(),
                editingControllerCastingFor: TextEditingController(),
                editingControllerCastingDate: TextEditingController(),
                editingControllerQuantity: TextEditingController(),
                editingControllerCastingUnitName: TextEditingController(),
                editingControllerUnitPrice: TextEditingController(),
                editingControllerTotalAmount: TextEditingController(),
                editingControllerBrandName:
                    TextEditingController(text: orderList[i].brandSupplierName)
                //  TextEditingController(),
                // editingControllerPo: TextEditingController(),
                );
            arrayList.add(dataList);

            strRemark = widget.orderDetails!.remarks!;
            _txtControllerRemark.text = widget.orderDetails!.remarks!;

            if (unitItems.isNotEmpty) {
              for (var j = 0; j < unitItems.length; j++) {
                var flag = false;
                if (unitItems[j].value == orderList[i].castingUnitName!) {
                  flag = true;
                }
                if (flag == false) {
                  unitItems.add(DropdownMenuItem(
                    value: orderList[i].castingUnitName!,
                    onTap: () {
                      //arrayList[reqTypeIndex]['casting_unit_name = finishingUnit![i].unitName!;
                      //arrayList[reqTypeIndex]['casting_unit'] = finishingUnit![i].unitId!;
                      //selectedUnitId = finishingUnit![i].unitId!;
                      //selectedUnitType = finishingUnit![i].unitName!;
                      if (kDebugMode) {
                        print(selectedUnitType);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Text(orderList[i].castingUnitName ?? ''),
                    ),
                  ));
                }
              }
            } else {
              unitItems.add(DropdownMenuItem(
                value: orderList[i].castingUnitName!,
                onTap: () {
                  //arrayList[reqTypeIndex]['casting_unit_name'] = finishingUnit![i].unitName!;
                  //arrayList[reqTypeIndex]['casting_unit'] = finishingUnit![i].unitId!;
                  //selectedUnitId = finishingUnit![i].unitId!;
                  //selectedUnitType = finishingUnit![i].unitName!;
                  if (kDebugMode) {
                    print(selectedUnitType);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text(orderList[i].castingUnitName ?? ''),
                ),
              ));
            }
          }
        }
        List<String> result = widget.orderDetails!.castingFor!
            .split(',')
            .map((e) => e.trim())
            .toList();
        slabDetailsSelectedArray?.clear();
        for (int p = 0; p < result.length; p++) {
          for (int l = 0; l < slabDetails!.length; l++) {
            if (result[p] == slabDetails?[l].slab_name) {
              setState(() {
                slabDetails?[l].selected = '1';
                slabDetailsSelectedArray?.add(slabDetails![l]);
              });
            }
          }
        }

        setState(() {
          flagcalled = true;
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
    return null;
  }

  Future<ResponseGetPoRequistionForm?> fetchPurchaseOrderRequistion() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "order_id": widget.orderDetails!.orderId!
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.webGetPoRequisitonVendorList, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getPoRequistionFormFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        //return dataModel.response;
        setState(() {
          assingToList = dataModel.response?.assingToList;
          purchaseUserTrack = dataModel.response?.purchaseUserTrack;
          searchData = dataModel.response?.venderList;
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
    return null;
  }

  Future<ResponseGradeDescription?> fetchGradeDescription() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": widget.projectId ?? '',
      "towar_id": towerId,
      "grade_id": selectedRequirementTypeId ?? '',
    };
    if (kDebugMode) {
      print(data);
    }
    var response =
        await apiNetworkHandler.post(AppUrl.webGetDescriptionByPoGrade, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = gradeDescriptionFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        //return dataModel.response;
        setState(() {
          finishingUnit = dataModel.response?.finishingUnit;
          descriptionList = dataModel.response?.similarDescription;
          if (descriptionList!.isNotEmpty) {
            CitiesService.cities = [];
            for (var i = 0; i < descriptionList!.length; i++) {
              CitiesService.cities.add(descriptionList![i].transGradeTypeName!);
            }
          }
          if (finishingUnit!.isNotEmpty) {
            unitItems = [];
            for (var i = 0; i < finishingUnit!.length; i++) {
              var flag = false;
              for (var j = 0; j < unitItems.length; j++) {
                if (unitItems[j].value == finishingUnit![i].unitName) {
                  flag = true;
                  break;
                }
              }
              if (flag == false) {
                unitItems.add(DropdownMenuItem(
                  value: finishingUnit![i].unitName!,
                  onTap: () {
                    //arrayList[reqTypeIndex]['casting_unit_name'] = finishingUnit![i].unitName!;
                    //arrayList[reqTypeIndex]['casting_unit'] = finishingUnit![i].unitId!;
                    //selectedUnitId = finishingUnit![i].unitId!;
                    //selectedUnitType = finishingUnit![i].unitName!;
                    if (kDebugMode) {
                      print(selectedUnitType);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Text(finishingUnit![i].unitName ?? ''),
                  ),
                ));
              }
            }
          }
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
    return null;
  }

  submitOkToOrderPurchaseOrder(BuildContext context11) async {
    if (useAccountManagementTestData) {
      Navigator.of(dialogContext).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preview action completed locally')),
      );
      return;
    }

    var request = http.MultipartRequest(
        'POST', Uri.parse(AppUrl.webPurchaseOrderStatusChange));
    request.headers.addAll({"Authorization": "Bearer token"});
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));
    request.fields["user_id"] = userId!;
    request.fields["order_id"] = widget.orderDetails!.orderId!;
    request.fields["project_id"] = widget.projectId!;
    request.fields["towar_id"] = widget.towarId!;
    request.fields["po_approve_status"] = '1';
    request.fields["supplier_for"] = '2';
    request.fields["remarks"] = strRemark!;
    request.fields["booking_details_json"] = jsonEncode(arrayList);
    request.fields["slab_id"] = '';
    request.fields["slab_selected"] = jsonEncode(slabDetailsSelectedArray);
    request.fields["credit_limit"] =
        creditControler.text.trim() == "" ? '0' : creditControler.text;

    for (int i = 0; i < arrayFiles.length; i++) {
      PlatformFile file = arrayFiles[i];
      request.files.add(
        await http.MultipartFile.fromPath(
          "po_document[]",
          file.path.toString(),
          contentType: MediaType('application/pdf', file.extension ?? ""),
        ),
      );
    }
    print(jsonEncode(request.fields));
    var response = await request.send();
    var responsed = await http.Response.fromStream(response);
    final dataModel = poApprovedByUserFromJson(responsed.body);

    if (dataModel.response?.errorCode == "0") {
      print('-----------------------------++-----------');
      print(dataModel);
      print('------------------------+++++++----------------');

      Future.delayed(Duration.zero).then((_) {
        Navigator.pop(dialogContext);
        _showPoDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  surfaceTintColor: Colors.transparent,
                  title: const Text('Purchase Order'),
                  content: Text('Request status updated successfully.',
                      style: TextStyle(
                          fontStyle: FontStyle.normal,
                          fontSize: context.accountFont(17.0, mobile: 14))),
                  actions: <Widget>[
                    PoActionFeedback(
                        child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.black,
                          fixedSize: const Size.fromWidth(100),
                          padding: const EdgeInsets.all(10),
                          textStyle: const TextStyle(color: Colors.white)),
                      child: Text('CLOSE',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: context.accountFont(16.0, mobile: 14),
                              color: Colors.white)),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        });
                      },
                    )),
                  ],
                ));
      });
    } else {
      // Navigator.pop(dialogContext);
      Future.delayed(Duration.zero).then((_) {
        Navigator.pop(dialogContext);
        _showPoDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  surfaceTintColor: Colors.transparent,
                  title: const Text('Purchase Order'),
                  content: Text('Invalid Input.',
                      style: TextStyle(
                          fontStyle: FontStyle.normal,
                          fontSize: context.accountFont(17.0, mobile: 14))),
                  actions: <Widget>[
                    PoActionFeedback(
                        child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.black,
                          fixedSize: const Size.fromWidth(100),
                          padding: const EdgeInsets.all(10),
                          textStyle: const TextStyle(color: Colors.white)),
                      child: Text('CLOSE',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: context.accountFont(16.0, mobile: 14),
                              color: Colors.white)),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                          // Navigator.pop(context);
                        });
                      },
                    )),
                  ],
                ));
      });
    }
    // AccountLoading.progressDialog(isLoading: false, context: context11);
  }
  // Future<ResponseMessageSuccess?> submitOkToOrderPurchaseOrder() async {
  //   final SharedPreferences prefs = await _prefs;
  //   String? userId = (prefs.getString('mobileNo') ?? (useAccountManagementTestData ? '1' : null));

  //   String towerId = "";
  //   if (widget.towarId != null) {
  //     towerId = widget.towarId!;
  //   }

  //   Map<String, String> data = {
  //     "user_id": userId!,
  //     "order_id": widget.orderDetails!.orderId!,
  //     "project_id": widget.projectId!,
  //     "towar_id": towerId,
  //     "po_approve_status": "1",
  //     "supplier_for": '2',
  //     "remarks": strRemark!,
  //     "booking_details_json": jsonEncode(arrayList),
  //     "slab_id": "",
  //     "slab_selected": jsonEncode(slabDetailsSelectedArray),
  //     "credit_limit":
  //         creditControler.text.trim() == "" ? '0' : creditControler.text,
  //   };

  //   if (kDebugMode) {
  //     print(data);
  //   }
  //   var response =
  //       await apiNetworkHandler.post(AppUrl.webPurchaseOrderStatusChange, data);
  //   if (kDebugMode) {
  //     print(response.statusCode);
  //   }
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     final dataModel = messageSuccessFromJson(response.body);
  //     if (kDebugMode) {
  //       print(dataModel.response!);
  //     }
  //     if (dataModel.response?.errorCode == "0") {
  //       Future.delayed(Duration.zero).then((_) {
  //         Navigator.pop(dialogContext);
  //         _showPoDialog<String>(
  //             context: context,
  //             builder: (BuildContext context) => AlertDialog(
  //                   title: const Text('Purchase Order'),
  //                   content: const Text('Request status updated successfully.',
  //                       style: TextStyle(
  //                           fontStyle: FontStyle.normal, fontSize: 17.0)),
  //                   actions: <Widget>[
  //                     ElevatedButton(
  //                       style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.black,
  //                           fixedSize: const Size.fromWidth(100),
  //                           padding: const EdgeInsets.all(10),
  //                           textStyle: const TextStyle(color: Colors.white)),
  //                       child: const Text('CLOSE',
  //                           style: TextStyle(
  //                               fontWeight: FontWeight.normal,
  //                               fontSize: 16.0,
  //                               color: Colors.white)),
  //                       onPressed: () {
  //                         setState(() {
  //                           Navigator.pop(context);
  //                           Navigator.pop(context);
  //                         });
  //                       },
  //                     ),
  //                   ],
  //                 ));
  //       });
  //     }
  //   } else {
  //     if (kDebugMode) {
  //       print(response.body);
  //     }
  //     return null;
  //   }
  //   return null;
  // }

  Future<ResponseMessageSuccess?> submitRejectPurchaseOrder() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "order_id": widget.orderDetails!.orderId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "po_approve_status": "2",
      "supplier_for": '2',
      "remarks": strRemark!,
      "booking_details_json": jsonEncode(arrayList),
      'credit_limit': "0"
    };

    if (kDebugMode) {
      print(data);
    }
    var response =
        await apiNetworkHandler.post(AppUrl.webPurchaseOrderStatusChange, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = messageSuccessFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response!);
      }
      if (dataModel.response?.errorCode == "0") {
        Future.delayed(Duration.zero).then((_) {
          Navigator.maybePop(context);
          Navigator.pop(dialogContext);
          _showPoDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    surfaceTintColor: Colors.transparent,
                    title: const Text('Purchase Order'),
                    content: Text('Request status updated successfully.',
                        style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontSize: context.accountFont(17.0, mobile: 14))),
                    actions: <Widget>[
                      PoActionFeedback(
                          child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            backgroundColor: Colors.black,
                            fixedSize: const Size.fromWidth(100),
                            padding: const EdgeInsets.all(10),
                            textStyle: const TextStyle(color: Colors.white)),
                        child: Text('CLOSE',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: context.accountFont(16.0, mobile: 14),
                                color: Colors.white)),
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          });
                        },
                      )),
                    ],
                  ));
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
    return null;
  }

  Future<ResponseMessageSuccess?> submitPurchaseOrderRequestion() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "order_id": widget.orderDetails!.orderId!,
      "vender_arr": jsonEncode(searchDataSelected),
    };

    if (kDebugMode) {
      print(data);
    }
    var response =
        await apiNetworkHandler.post(AppUrl.webSendVenderPoRequisition, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = messageSuccessFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response!);
      }
      if (dataModel.response?.errorCode == "0") {
        Future.delayed(Duration.zero).then((_) {
          Navigator.pop(dialogContext);
          _showPoDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    surfaceTintColor: Colors.transparent,
                    title: const Text('PO Vendor Quote'),
                    content: Text(
                        'Request for Quote is being send successfully.',
                        style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontSize: context.accountFont(17.0, mobile: 14))),
                    actions: <Widget>[
                      PoActionFeedback(
                          child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            backgroundColor: Colors.black,
                            fixedSize: const Size.fromWidth(100),
                            padding: const EdgeInsets.all(10),
                            textStyle: const TextStyle(color: Colors.white)),
                        child: Text('CLOSE',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: context.accountFont(16.0, mobile: 14),
                                color: Colors.white)),
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                            Navigator.maybePop(context);
                          });
                        },
                      )),
                    ],
                  ));
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
    return null;
  }

  bool flagBtnHideApproveReject = false;

  chooseAssignToModal() {
    return _showPoDialog(
        context: context,
        // barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context1, setState3) {
            return AlertDialog(
              clipBehavior: Clip.antiAlias,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              titlePadding: const EdgeInsets.symmetric(vertical: 0),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 0),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: _poPopupHeader('Select Assign To'),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PoActionFeedback(
                        child: InkWell(
                      onTap: () {
                        print('----------------------');
                        Navigator.pop(context);
                        updateConfirmationModal();
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
                      },
                      child: _poPopupAction('SUBMIT'),
                    )),
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
                height: 300,
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
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.accountFont(14.0, mobile: 14),
                            fontWeight: FontWeight.w400),
                        decoration: _poPopupSearchDecoration('Search'),
                      ),
                      for (int i = 0; i < filteredAssignTo()!.length; i++)
                        PoActionFeedback(
                            child: InkWell(
                          onTap: () {
                            setState3(() {
                              selectedAssignToId =
                                  filteredAssignTo()?[i].transEmpId ?? '';
                              // if (filteredAssignTo()?[i].isSelected == true) {
                              //   filteredAssignTo()?[i].isSelected = false;
                              // } else {
                              //   filteredAssignTo()?[i].isSelected = true;
                              // }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: _poPopupRowDecoration(
                                selectedAssignToId ==
                                    filteredAssignTo()?[i].transEmpId),
                            child: _poPopupSelectionRow(
                                filteredAssignTo()?[i].transEmpName ?? '',
                                selected: selectedAssignToId ==
                                    filteredAssignTo()?[i].transEmpId),
                          ),
                        )),
                      // AccountFlowRow(
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
    super.initState();
    setState(() {
      isChecked = widget.orderDetails!.poVerifyFlag == '1' ? true : false;
    });
    if (widget.orderDetails?.poApproveStatus! == '0') {
      setState(() {
        flagBtnHideApproveReject = false;
      });
    } else if (widget.orderDetails?.poApproveStatus! == '1') {
      setState(() {
        flagBtnHideApproveReject = true;
      });
      fetchPurchaseOrderRequistion();
    } else if (widget.orderDetails?.poApproveStatus! == '2') {
      setState(() {
        flagBtnHideApproveReject = true;
      });
    }
    fetchDefaultPurchaseOrderCreate();
  }

  @override
  Widget build(BuildContext context) {
    return AccountManagementSurface(
        child: Theme(
            data: accountManagementTheme(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: widget.poId == 'Verified' ? 6 : 12),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
            child: Scaffold(
              appBar: AppBar(
                  centerTitle: true,
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  title: Text(
                      '${widget.projectName!.toUpperCase()} - PO ASSIGNED',
                      style: TextStyle(
                          fontStyle: FontStyle.normal,
                          fontSize: context.accountFont(17.0, mobile: 14))),
                  leading: PoActionFeedback(
                      child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.maybePop(context);
                          }))),
              body: flagcalled == true
                  ? SingleChildScrollView(
                      child: Column(children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: context.accountCompact ? 12 : 50),
                          child: Row(
                            children: [
                              SizedBox(width: context.accountCompact ? 72 : 90),
                              const Spacer(),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: Text(
                                    context.accountCompact
                                        ? 'VERIFY PO'
                                        : 'PO DETAILS',
                                    style: TextStyle(
                                        fontSize: context.accountFont(14,
                                            mobile: 14))),
                              ),
                              const Spacer(),
                              PoActionFeedback(
                                  child: InkWell(
                                onTap: () {
                                  var projectId = widget.projectId!;
                                  var projectName = widget.projectName!;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return PoPreviewHtml(
                                          projectId: projectId,
                                          towarId: widget.towarId!,
                                          projectName: projectName,
                                          orderId:
                                              widget.orderDetails?.orderId ??
                                                  '',
                                          poNo: widget.orderDetails?.poNo ?? '',
                                        );
                                      },
                                    ),
                                  ).then((_) => {});
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: widget.poId == 'Verified' ? 3 : 5),
                                  decoration: BoxDecoration(
                                    // border: Border.all(color: Colors.black26),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(999)),
                                    color: Colors.black12,
                                  ),
                                  child: Text(
                                    "VIEW PO",
                                    style: TextStyle(
                                        fontSize:
                                            context.accountFont(16, mobile: 14),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ))
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Colors.black,
                        ),
                        widget.poId == 'Verified'
                            ? _verifyPoSummary()
                            : _poSummaryRow(
                          children: [
                            Column(
                              children: [
                                context.accountCompact
                                    ? const SizedBox(height: 4)
                                    : verticalSpaceSmall,
                                Text(
                                  'P.O. No.',
                                  style: context.accountCompact
                                      ? normalText.copyWith(fontSize: 12, height: 1.15)
                                      : normalText,
                                ),
                                SizedBox(
                                  height: context.accountCompact ? 4 : 10,
                                ),
                                Text(
                                  widget.orderDetails!.poNo!,
                                  style: context.accountCompact
                                      ? boldText.copyWith(fontSize: 13, height: 1.2)
                                      : boldText,
                                ),
                                SizedBox(
                                  height: context.accountCompact ? 8 : 15,
                                ),
                                Text(
                                  'P.O. Status',
                                  style: context.accountCompact
                                      ? normalText.copyWith(fontSize: 12, height: 1.15)
                                      : normalText,
                                ),
                                SizedBox(
                                  height: context.accountCompact ? 4 : 10,
                                ),
                                Text(
                                  widget.orderDetails!.poStatus! == '0'
                                      ? 'Pendng'
                                      : widget.orderDetails!.poStatus! == '1'
                                          ? 'Assigned'
                                          : widget.orderDetails!.poStatus! ==
                                                  '2'
                                              ? 'Issued'
                                              : widget.orderDetails!
                                                          .poStatus! ==
                                                      '3'
                                                  ? 'Dispute'
                                                  : '---',
                                  style: context.accountCompact
                                      ? boldText.copyWith(fontSize: 13, height: 1.2)
                                      : boldText,
                                ),
                                SizedBox(
                                  height: context.accountCompact ? 8 : 15,
                                ),
                                Text(
                                  'Slab No',
                                  style: context.accountCompact
                                      ? normalText.copyWith(fontSize: 12, height: 1.15)
                                      : normalText,
                                ),
                                SizedBox(
                                  height: context.accountCompact ? 4 : 10,
                                ),
                                Text(
                                  widget.orderDetails!.slabName!,
                                  style: context.accountCompact
                                      ? boldText.copyWith(fontSize: 13, height: 1.2)
                                      : boldText,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Booking Type',
                                  style: context.accountCompact
                                      ? normalText.copyWith(fontSize: 12, height: 1.15)
                                      : normalText,
                                ),
                                SizedBox(
                                  height: context.accountCompact ? 4 : 10,
                                ),
                                Text(
                                  widget.orderDetails!.gradeName!,
                                  style: context.accountCompact
                                      ? boldText.copyWith(fontSize: 13, height: 1.2)
                                      : boldText,
                                ),
                                SizedBox(
                                  height: context.accountCompact ? 8 : 15,
                                ),
                                Text(
                                  'Project Name',
                                  style: context.accountCompact
                                      ? normalText.copyWith(fontSize: 12, height: 1.15)
                                      : normalText,
                                ),
                                SizedBox(
                                  height: context.accountCompact ? 4 : 10,
                                ),
                                Text(
                                  widget.orderDetails!.projectName!,
                                  style: context.accountCompact
                                      ? boldText.copyWith(fontSize: 13, height: 1.2)
                                      : boldText,
                                ),
                                SizedBox(
                                  height: context.accountCompact ? 8 : 15,
                                ),
                                Text(
                                  'Requested By',
                                  style: context.accountCompact
                                      ? normalText.copyWith(fontSize: 12, height: 1.15)
                                      : normalText,
                                ),
                                SizedBox(
                                  height: context.accountCompact ? 4 : 10,
                                ),
                                Text(
                                  widget.orderDetails!.raisedBy!,
                                  style: context.accountCompact
                                      ? boldText.copyWith(fontSize: 13, height: 1.2)
                                      : boldText,
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (widget.poId != 'Verified') ...[
                          context.accountCompact
                              ? const SizedBox(height: 4)
                              : verticalSpaceSmall,
                          const Divider(height: 1, thickness: 0.5, color: Colors.black),
                        ],
                        ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            //controller: _controller,
                            shrinkWrap: true,
                            reverse: false,
                            itemCount: arrayList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: EdgeInsets.fromLTRB(8,
                                    widget.poId == 'Verified' && index == 0 ? 4 : 8, 8, 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: widget.poId == 'Verified'
                                        ? const Color(0xffe1e5e9) : Colors.grey),
                                    boxShadow: widget.poId == 'Verified' ? const [
                                      BoxShadow(color: Color(0x10000000),
                                          blurRadius: 10, offset: Offset(0, 3)),
                                    ] : null,
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: context.accountCompact ? 12 : 40,
                                        right: context.accountCompact ? 12 : 40,
                                        bottom: widget.poId == 'Verified' ? 8 : 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        index != 0
                                            ? AccountFlowRow(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  PoActionFeedback(
                                                      child: IconButton(
                                                    iconSize: 30,
                                                    icon: const Icon(
                                                      Icons.close_rounded,
                                                    ),
                                                    color: Colors.black,
                                                    onPressed: () {
                                                      setState(() {
                                                        arrayList
                                                            .removeAt(index);
                                                      });
                                                    },
                                                  )),
                                                ],
                                              )
                                            : const SizedBox(height: 20),
                                        _requirementType(index),
                                        widget.poId == 'Verified'
                                            ? const SizedBox(height: 8)
                                            : verticalSpaceSmall15,
                                        _description(index),
                                        widget.poId == 'Verified'
                                            ? const SizedBox(height: 8)
                                            : verticalSpaceSmall15,
                                        _selecteBrand(index),
                                        widget.poId == 'Verified'
                                            ? const SizedBox(height: 8)
                                            : verticalSpaceSmall15,
                                        _requirementFor(index),
                                        widget.poId == 'Verified'
                                            ? const SizedBox(height: 8)
                                            : verticalSpaceSmall15,
                                        _selectedReqDate(index),
                                        widget.poId == 'Verified'
                                            ? const SizedBox(height: 8)
                                            : verticalSpaceSmall15,
                                        _quantityUnit(index),
                                        widget.poId == 'Verified'
                                            ? const SizedBox(height: 8)
                                            : verticalSpaceSmall15,
                                        _unitPrice(index),
                                        widget.poId == 'Verified'
                                            ? const SizedBox(height: 8)
                                            : verticalSpaceSmall15,
                                        _totalPrice(index),
                                        widget.poId == 'Verified'
                                            ? const SizedBox(height: 4)
                                            : verticalSpaceSmall15,
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                        if (widget.poId == 'Verified') ...[
                          Padding(
                            padding: EdgeInsets.only(
                                left: 8 + (context.accountCompact ? 12 : 40),
                                right: 8 + (context.accountCompact ? 12 : 40)),
                            child: _otherRemarksField(),
                          ),
                          verticalSpaceSmall,
                        ],
                        Container(
                          width: widget.poId == 'Verified' ? double.infinity : null,
                          padding: EdgeInsets.symmetric(
                              horizontal: widget.poId == 'Verified'
                                  ? 8 + (context.accountCompact ? 12 : 40)
                                  : (context.accountCompact ? 12 : 50)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.poId == 'Verified')
                                _poFormRow('Upload', children: [
                                  const Text('Upload'),
                                  Expanded(child: _uploadControls()),
                                ])
                              else ...[
                              Text("Upload",
                                  style: TextStyle(
                                      fontSize: context.accountFont(14,
                                          mobile: 14))), //
                                _uploadControls(),
                              ],
                            ],
                          ),
                        ),
                        verticalSpaceSmall,
                        Padding(
                          padding: EdgeInsets.only(
                              left: context.accountCompact ? 12 : 100,
                              right: (context.accountCompact ? 12.0 : 70.0)),
                          child: SizedBox(
                              child: Column(
                            children: [
                              if (widget.poId != 'Verified') _otherRemarksField(),
                              verticalSpaceSmall,
                              AccountFlowRow(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  flagBtnHideApproveReject == false
                                      ? InkWell(
                                          onTap: () {
                                            bool isSame = false;
                                            for (var i = 0;
                                                i < arrayList.length;
                                                i++) {
                                              for (int k = i + 1;
                                                  k < arrayList.length;
                                                  k++) {
                                                if (arrayList[i]
                                                            .grade_type_name ==
                                                        arrayList[k]
                                                            .grade_type_name &&
                                                    arrayList[i].description ==
                                                        arrayList[k]
                                                            .description) {
                                                  setState(() {
                                                    isSame = true;
                                                  });
                                                }
                                              }
                                            }
                                            if (isSame == false) {
                                              selectedRow = arrayList.length;
                                              // print(arrayList[arrayList.length - 1]
                                              //     .casting_for
                                              //     .toString());
                                              // Map<String, dynamic> dataList1 = {
                                              //   "grade_id": "",
                                              //   "grade_type_name": "",
                                              //   "casting_date": "",
                                              //   "casting_for": "$castingRequirementFor",
                                              //   "casting_unit_name": "",
                                              //   "casting_unit": "",
                                              //   "quantity": "",
                                              //   "unit_price": "",
                                              //   "total_amount": "",
                                              //   "description": "",
                                              //   "id": selectedRow
                                              // };
                                              // arrayList[index].casting_for.toString()
                                              POformDataArrayList dataList1 =
                                                  POformDataArrayList(
                                                brand_supplier_name: "",
                                                grade_id: "",
                                                grade_type_name: "",
                                                casting_date: arrayList[
                                                        arrayList.length - 1]
                                                    .casting_date,
                                                casting_for: arrayList[
                                                        arrayList.length - 1]
                                                    .casting_for
                                                    .toString(), // "$castingRequirementFor",
                                                casting_unit_name: "",
                                                casting_unit: "",
                                                quantity: "",
                                                unit_price: "",
                                                total_amount: "0",
                                                description: "",
                                                id: selectedRow.toString(),
                                                editingControllerGradeTypeName:
                                                    TextEditingController(),
                                                editingControllerDescription:
                                                    TextEditingController(),
                                                editingControllerCastingFor:
                                                    TextEditingController(),
                                                editingControllerCastingDate:
                                                    TextEditingController(),
                                                editingControllerQuantity:
                                                    TextEditingController(),
                                                editingControllerCastingUnitName:
                                                    TextEditingController(),
                                                editingControllerUnitPrice:
                                                    TextEditingController(),
                                                editingControllerTotalAmount:
                                                    TextEditingController(),
                                                editingControllerBrandName:
                                                    TextEditingController(),
                                                // editingControllerPo: TextEditingController(),
                                              );
                                              setState(() {
                                                arrayList.add(dataList1);
                                                //_controller.jumpTo(_controller.position.maxScrollExtent);
                                              });
                                            } else {
                                              Alert(
                                                  closeIcon: const SizedBox(),
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 0.0),
                                                  image: Image.asset(
                                                      'images/Icon-512.png',
                                                      height: 80,
                                                      fit: BoxFit.fitWidth),
                                                  style: AlertStyle(
                                                      titleTextAlign:
                                                          TextAlign.center,
                                                      descTextAlign:
                                                          TextAlign.center,
                                                      descStyle: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: context
                                                              .accountFont(16,
                                                                  mobile: 14)),
                                                      isCloseButton: true),
                                                  context: context,
                                                  desc:
                                                      'Entered Description is Already Added',
                                                  alertAnimation:
                                                      fadeAlertAnimation,
                                                  buttons: [
                                                    DialogButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      color: Colors.black,
                                                      child: Text(
                                                        "CLOSE",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: context
                                                                .accountFont(15,
                                                                    mobile:
                                                                        14)),
                                                      ),
                                                    ),
                                                  ]).show();
                                            }
                                          },
                                          // style: OutlinedButton.styleFrom(
                                          //   fixedSize: const Size(200, 45),
                                          // ),
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                                top: 9,
                                                bottom: 9),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(999)),
                                                border: Border.all(
                                                    color: Colors.black)),
                                            child: const Text(
                                              'Add More',
                                              style: boldText,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                  SizedBox(width: 10),
                                  InkWell(
                                    onTap: () {
                                      //  setState(() {
                                      //   isChecked = !isChecked;
                                      // });
                                      // setPoVerifyFlag();

                                      _showCheckConfirmation();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          top: widget.poId == 'Verified' ? 4.5 : 5,
                                          bottom: widget.poId == 'Verified' ? 4.5 : 5),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(999)),
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: AccountFlowRow(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isChecked
                                                ? Icons.check_box
                                                : Icons.check_box_outline_blank,
                                            size: widget.poId == 'Verified' ? 29 : 30,
                                            color: Colors.black,
                                          ),
                                          SizedBox(width: 14),
                                          Text(
                                            isChecked ? "Checked" : "Check",
                                            style: widget.poId == 'Verified'
                                                ? boldText.copyWith(fontSize: 15) : boldText,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              verticalSpaceSmall,
                            ],
                          )),
                        ),
                      ]),
                    )
                  : const AccountSkeleton(),
              bottomNavigationBar: AccountFlowRow(
                children: [
                  flagBtnHideApproveReject == false
                      ? Expanded(
                          child: GestureDetector(
                              onTap: () {
                                _showPoDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          clipBehavior: Clip.antiAlias,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                          surfaceTintColor: Colors.transparent,
                                          title: const Text('Purchase Order'),
                                          content: Text(
                                              'Are you sure you want to reject purchase order?',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.normal,
                                                  fontSize: context.accountFont(
                                                      17.0,
                                                      mobile: 14))),
                                          actions: <Widget>[
                                            PoActionFeedback(
                                                child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  shape: const StadiumBorder(),
                                                  backgroundColor: Colors.black,
                                                  fixedSize:
                                                      const Size.fromWidth(100),
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  textStyle: const TextStyle(
                                                      color: Colors.white)),
                                              child: Text('NO',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: context
                                                          .accountFont(16.0,
                                                              mobile: 14),
                                                      color: Colors.white)),
                                              onPressed: () {
                                                setState(() {
                                                  Navigator.pop(context);
                                                });
                                              },
                                            )),
                                            PoActionFeedback(
                                                child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  shape: const StadiumBorder(),
                                                  backgroundColor: Colors.black,
                                                  fixedSize:
                                                      const Size.fromWidth(100),
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  textStyle: const TextStyle(
                                                      color: Colors.white)),
                                              child: Text('YES',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: context
                                                          .accountFont(14.0,
                                                              mobile: 14),
                                                      color: Colors.white)),
                                              onPressed: () {
                                                setState(() {
                                                  Navigator.pop(context);

                                                  _showPoDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder:
                                                        (BuildContext context) {
                                                      dialogContext = context;
                                                      return Center(
                                                        child: SizedBox(
                                                          height: 200,
                                                          width: context
                                                                  .accountCompact
                                                              ? 100
                                                              : 200,
                                                          child: Dialog(
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16)),
                                                            surfaceTintColor:
                                                                Colors
                                                                    .transparent,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                verticalSpaceSmall,
                                                                CircularProgressIndicator(),
                                                                verticalSpaceSmall,
                                                                Text("Loading"),
                                                                verticalSpaceSmall,
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                  submitRejectPurchaseOrder();
                                                });
                                              },
                                            )),
                                          ],
                                        ));
                              },
                              child: Container(
                                  padding: const EdgeInsets.only(top: 13),
                                  height: 50,
                                  color: Colors.black,
                                  child: const Text(
                                    'REJECT PO',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ))),
                        )
                      : const SizedBox(),
                  flagBtnHideApproveReject == false
                      ? const SizedBox(width: 2)
                      : const SizedBox(),
                  flagBtnHideApproveReject == false
                      ? Expanded(
                          child: GestureDetector(
                              onTap: () {
                                var flag = true;
                                String msg = "";
                                for (var i = 0; i < arrayList.length; i++) {
                                  if (arrayList[i].grade_id.toString() == "") {
                                    msg = 'Please select Requirement type.';
                                    flag = false;
                                  } else if (arrayList[i]
                                          .description
                                          .toString() ==
                                      "") {
                                    msg = 'Please enter description.';
                                    flag = false;
                                  } else if (arrayList[i]
                                          .casting_for
                                          .toString() ==
                                      "") {
                                    msg = 'Please enter requirement for.';
                                    flag = false;
                                  } else if (arrayList[i]
                                          .casting_date
                                          .toString() ==
                                      "") {
                                    msg = 'Please select requirement date.';
                                    flag = false;
                                  } else if (arrayList[i].quantity.toString() ==
                                      "") {
                                    msg = 'Please enter a quantity.';
                                    flag = false;
                                  } else if (arrayList[i]
                                          .casting_unit
                                          .toString() ==
                                      "") {
                                    msg = 'Please select unit.';
                                    flag = false;
                                  }
                                }
                                print(jsonEncode(arrayList));
                                if (flag == false) {
                                  _showPoDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                            clipBehavior: Clip.antiAlias,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                            surfaceTintColor:
                                                Colors.transparent,
                                            title: const Text(''),
                                            content: Text(msg,
                                                style: TextStyle(
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: context
                                                        .accountFont(17.0,
                                                            mobile: 14))),
                                            actions: <Widget>[
                                              PoActionFeedback(
                                                  child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    shape:
                                                        const StadiumBorder(),
                                                    backgroundColor:
                                                        Colors.black,
                                                    fixedSize:
                                                        const Size.fromWidth(
                                                            100),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    textStyle: const TextStyle(
                                                        color: Colors.white)),
                                                child: Text('CLOSE',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: context
                                                            .accountFont(14.0,
                                                                mobile: 14),
                                                        color: Colors.white)),
                                                onPressed: () {
                                                  setState(() {
                                                    Navigator.pop(context);
                                                  });
                                                },
                                              )),
                                            ],
                                          ));
                                } else {
                                  bool isSame = false;
                                  for (var i = 0; i < arrayList.length; i++) {
                                    for (int k = i + 1;
                                        k < arrayList.length;
                                        k++) {
                                      if (arrayList[i].grade_type_name ==
                                              arrayList[k].grade_type_name &&
                                          arrayList[i].description ==
                                              arrayList[k].description) {
                                        setState(() {
                                          isSame = true;
                                        });
                                      }
                                    }
                                  }

                                  if (isSame == false) {
                                    _showPoDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                              clipBehavior: Clip.antiAlias,
                                              surfaceTintColor:
                                                  Colors.transparent,
                                              elevation: 0,
                                              shadowColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16)),
                                              titlePadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 0),
                                              actionsPadding:
                                                  const EdgeInsets.only(
                                                      bottom: 0),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 0),
                                              actionsAlignment:
                                                  MainAxisAlignment.center,
                                              title: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                decoration: const BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft: Radius
                                                                .circular(8),
                                                            topRight:
                                                                Radius.circular(
                                                                    8))),
                                                child: Text(
                                                  "Are you Sure, You want to Update an Order?",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: context
                                                          .accountFont(18,
                                                              mobile: 14),
                                                      fontWeight:
                                                          FontWeight.w600),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              // title: const Text('Purchase Order'),
                                              content: Container(
                                                height: 100,
                                                child: AccountFlowRow(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Credit Limit",
                                                      style: TextStyle(
                                                        fontSize: context
                                                            .accountFont(16,
                                                                mobile: 14),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                    SizedBox(width: 14),
                                                    Container(
                                                      width:
                                                          context.accountCompact
                                                              ? 100
                                                              : 200,
                                                      child: TextFormField(
                                                        controller:
                                                            creditControler,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: context
                                                                .accountFont(
                                                                    13.0,
                                                                    mobile:
                                                                        13)),
                                                        decoration:
                                                            InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  12.0),
                                                          border: OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .black)),
                                                          hintText:
                                                              'Enter Credit Limit',
                                                          hintStyle: TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    116,
                                                                    116,
                                                                    116),
                                                            fontSize: context
                                                                .accountFont(
                                                                    13.0,
                                                                    mobile: 13),
                                                            fontWeight:
                                                                FontWeight.w200,
                                                            fontFamily:
                                                                'HelveticaNeue',
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 14),
                                                    Text(
                                                      "Days",
                                                      style: TextStyle(
                                                        fontSize: context
                                                            .accountFont(16,
                                                                mobile: 14),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),

                                              actions: <Widget>[
                                                AccountFlowRow(
                                                  children: [
                                                    PoActionFeedback(
                                                        child: InkWell(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        width: 180,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4),
                                                        decoration: const BoxDecoration(
                                                            color: Colors.black,
                                                            border: Border(
                                                                right: BorderSide(
                                                                    color: Colors
                                                                        .white)),
                                                            borderRadius:
                                                                BorderRadius.only(
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            8))),
                                                        child: Text(
                                                          "NO",
                                                          style: TextStyle(
                                                            fontSize: context
                                                                .accountFont(16,
                                                                    mobile: 14),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    )),
                                                    PoActionFeedback(
                                                        child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          Navigator.pop(
                                                              context);

                                                          _showPoDialog(
                                                            context: context,
                                                            barrierDismissible:
                                                                false,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              dialogContext =
                                                                  context;
                                                              return Center(
                                                                child: SizedBox(
                                                                  height: 200,
                                                                  width: context
                                                                          .accountCompact
                                                                      ? 100
                                                                      : 200,
                                                                  child: Dialog(
                                                                    clipBehavior:
                                                                        Clip.antiAlias,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(16)),
                                                                    surfaceTintColor:
                                                                        Colors
                                                                            .transparent,
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        verticalSpaceSmall,
                                                                        CircularProgressIndicator(),
                                                                        verticalSpaceSmall,
                                                                        Text(
                                                                            "Loading"),
                                                                        verticalSpaceSmall,
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                          submitOkToOrderPurchaseOrder(
                                                              context);
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 180,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4),
                                                        decoration: const BoxDecoration(
                                                            color: Colors.black,
                                                            borderRadius:
                                                                BorderRadius.only(
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            8))),
                                                        child: Text(
                                                          "YES",
                                                          style: TextStyle(
                                                            fontSize: context
                                                                .accountFont(16,
                                                                    mobile: 14),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    )),
                                                  ],
                                                )
                                              ],
                                            ));
                                    // Alert(
                                    //     closeIcon: const SizedBox(),
                                    //     padding: const EdgeInsets.only(
                                    //         top: 0.0, left: 24, right: 24),
                                    //     image: Image.asset('images/Icon-512.png',
                                    //         height: 80, fit: BoxFit.fitWidth),
                                    //     style: const AlertStyle(
                                    //         titleTextAlign: TextAlign.center,
                                    //         descTextAlign: TextAlign.center,
                                    //         descStyle: TextStyle(
                                    //             fontWeight: FontWeight.normal,
                                    //             fontSize: 16),
                                    //         isCloseButton: true),
                                    //     context: context,
                                    //     desc:
                                    //         'Are you sure you want to update an order?',
                                    //     alertAnimation: fadeAlertAnimation,
                                    //     buttons: [
                                    //       DialogButton(
                                    //         onPressed: () => Navigator.pop(context),
                                    //         color: Colors.black,
                                    //         child: const Text(
                                    //           "NO",
                                    //           style: TextStyle(
                                    //               color: Colors.white, fontSize: 15),
                                    //         ),
                                    //       ),
                                    //       DialogButton(
                                    //         onPressed: () {
                                    //           Navigator.pop(context);
                                    //           // context.loaderOverlay.show();
                                    //           // wsworkordersubmit();
                                    //         },
                                    //         color: Colors.black,
                                    //         child: const Text(
                                    //           "YES",
                                    //           style: TextStyle(
                                    //               color: Colors.white, fontSize: 15),
                                    //         ),
                                    //       ),
                                    //     ]).show();
                                  } else {
                                    Alert(
                                        closeIcon: const SizedBox(),
                                        padding: const EdgeInsets.only(
                                            top: 0.0, left: 18, right: 18),
                                        image: Image.asset(
                                            'images/Icon-512.png',
                                            height: 80,
                                            fit: BoxFit.fitWidth),
                                        style: AlertStyle(
                                            titleTextAlign: TextAlign.center,
                                            descTextAlign: TextAlign.center,
                                            descStyle: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: context.accountFont(
                                                    16,
                                                    mobile: 14)),
                                            isCloseButton: true),
                                        context: context,
                                        desc:
                                            'Entered Description is Already Added',
                                        alertAnimation: fadeAlertAnimation,
                                        buttons: [
                                          DialogButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            color: Colors.black,
                                            child: Text(
                                              "CLOSE",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: context.accountFont(
                                                      15,
                                                      mobile: 14)),
                                            ),
                                          ),
                                        ]).show();
                                  }
                                }
                              },
                              child: Container(
                                  padding: const EdgeInsets.only(top: 13),
                                  height: 50,
                                  color: Colors.black,
                                  child: const Text(
                                    'OK TO ORDER',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ))))
                      : const SizedBox(),
                  flagBtnHideApproveReject == true
                      ? Expanded(
                          child: Row(
                          children: [
                            Expanded(
                              child: PoActionFeedback(
                                  child: InkWell(
                                onTap: () {
                                  if (
                                      // (widget.orderDetails?.poAssingTo == "0" ||
                                      //       widget.orderDetails?.poAssingTo == "") &&
                                      purchaseUserTrack != '0') {
                                    chooseAssignToModal();
                                  }
                                },
                                child: _poFooterCapsule('ASSIGN TO',
                                    enabled: purchaseUserTrack != '0'),
                              )),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  _showPoDialog(
                                      // barrierDismissible: false,
                                      context: context,
                                      builder:
                                          (BuildContext context) =>
                                              StatefulBuilder(
                                                  builder: (context, setState) {
                                                return Dialog(
                                                  clipBehavior: Clip.antiAlias,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16)),
                                                  surfaceTintColor:
                                                      Colors.transparent,
                                                  elevation: 0,
                                                  child: SizedBox(
                                                    width: 432.0,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        _poPopupHeader(
                                                            'SELECT VENDOR'),
                                                        Divider(
                                                          color: Colors
                                                              .grey.shade500,
                                                          thickness: 1.5,
                                                        ),
                                                        SizedBox(
                                                          height: 300,
                                                          width: 360,
                                                          child:
                                                              ListView.builder(
                                                                  itemCount:
                                                                      searchData!
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    bool
                                                                        selected =
                                                                        false;
                                                                    if (searchData![index]
                                                                            .sendStatus! ==
                                                                        '0') {
                                                                      String
                                                                          vendorId =
                                                                          searchData![index]
                                                                              .selectId!;
                                                                      for (int i =
                                                                              0;
                                                                          i < searchDataSelected.length;
                                                                          i++) {
                                                                        if (vendorId ==
                                                                            searchDataSelected[i]["vendor_id"].toString()) {
                                                                          selected =
                                                                              true;
                                                                          break;
                                                                        }
                                                                      }
                                                                    }
                                                                    return Column(
                                                                      children: [
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            bool
                                                                                flag =
                                                                                false;
                                                                            String
                                                                                vendorId =
                                                                                searchData![index].selectId!;
                                                                            for (int i = 0;
                                                                                i < searchDataSelected.length;
                                                                                i++) {
                                                                              if (vendorId == searchDataSelected[i]["vendor_id"].toString()) {
                                                                                if (searchData![index].sendStatus! == '0') {
                                                                                  searchDataSelected.removeAt(i);
                                                                                  setState(() {
                                                                                    searchData?.length;
                                                                                  });
                                                                                  flag = true;
                                                                                  break;
                                                                                }
                                                                              }
                                                                            }
                                                                            if (flag ==
                                                                                false) {
                                                                              if (searchData![index].sendStatus! == '0') {
                                                                                Map<String, String> data = {
                                                                                  "vendor_id": searchData![index].selectId!,
                                                                                };
                                                                                searchDataSelected.add(data);
                                                                                setState(() {
                                                                                  searchData?.length;
                                                                                });
                                                                              } else {
                                                                                _showPoDialog<String>(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) => AlertDialog(
                                                                                          clipBehavior: Clip.antiAlias,
                                                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                                          surfaceTintColor: Colors.transparent,
                                                                                          title: const Text(''),
                                                                                          content: Text('Already PO Quote is being send.', style: TextStyle(fontStyle: FontStyle.normal, fontSize: context.accountFont(17.0, mobile: 14))),
                                                                                          actions: <Widget>[
                                                                                            PoActionFeedback(
                                                                                                child: ElevatedButton(
                                                                                              style: ElevatedButton.styleFrom(shape: const StadiumBorder(), backgroundColor: Colors.black, fixedSize: const Size.fromWidth(100), padding: const EdgeInsets.all(10), textStyle: const TextStyle(color: Colors.white)),
                                                                                              child: Text('CLOSE', style: TextStyle(fontWeight: FontWeight.normal, fontSize: context.accountFont(14.0, mobile: 14), color: Colors.white)),
                                                                                              onPressed: () {
                                                                                                setState(() {
                                                                                                  Navigator.pop(context);
                                                                                                });
                                                                                              },
                                                                                            )),
                                                                                          ],
                                                                                        ));
                                                                              }
                                                                            }
                                                                            //Navigator.of(
                                                                            // context)
                                                                            //.pop();
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            margin:
                                                                                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                                            padding:
                                                                                const EdgeInsets.all(12),
                                                                            decoration:
                                                                                _poPopupRowDecoration(selected || searchData![index].sendStatus == '1'),
                                                                            child: _poPopupSelectionRow(searchData![index].selectName ?? '',
                                                                                selected: selected || searchData![index].sendStatus == '1',
                                                                                disabled: searchData![index].sendStatus == '1'),
                                                                          ),
                                                                        ),
                                                                        const Divider(
                                                                          height:
                                                                              1,
                                                                          thickness:
                                                                              0.5,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ],
                                                                    );
                                                                  }),
                                                        ),
                                                        PoActionFeedback(
                                                            child: InkWell(
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();

                                                            _showPoDialog(
                                                              context: context,
                                                              // barrierDismissible: false,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                dialogContext =
                                                                    context;
                                                                return _quoteLoadingDialog(context);
                                                              },
                                                            );

                                                            submitPurchaseOrderRequestion();
                                                          },
                                                          child: _poPopupAction(
                                                              'REQUEST QUOTE'),
                                                        )),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }));
                                },
                                child: _poFooterCapsule('GET VENDOR QUOTE'),
                              ),
                            ),
                          ],
                        ))
                      : const SizedBox(),
                ],
              ),
            )));
  }

  Future<T?> _showPoDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) => showAccountDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) {
      if (dialogContext.accountCompact) return builder(dialogContext);
      final size = MediaQuery.sizeOf(dialogContext);
      final theme = Theme.of(dialogContext);
      return Theme(
        data: theme.copyWith(dialogTheme: theme.dialogTheme.copyWith(
          constraints: BoxConstraints(
            minWidth: (size.width - 48).clamp(0.0, 360.0),
            maxWidth: (size.width * 0.48).clamp(360.0, 760.0),
            maxHeight: size.height * 0.85,
          ),
          insetPadding: const EdgeInsets.all(24),
        )),
        child: Builder(builder: builder),
      );
    },
  );

  Widget _quoteLoadingDialog(BuildContext dialogContext) {
    final size = MediaQuery.sizeOf(dialogContext);
    final width = dialogContext.accountCompact
        ? (size.width - 48).clamp(0.0, 360.0)
        : (size.width * 0.30).clamp(320.0, 440.0);
    return Dialog(
      key: const ValueKey('po-quote-loading-dialog'),
      insetPadding: const EdgeInsets.all(24),
      constraints: BoxConstraints.tightFor(width: width),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      surfaceTintColor: Colors.transparent,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: 32, height: 32, child: CircularProgressIndicator()),
          SizedBox(height: 16),
          Text('Loading'),
        ]),
      ),
    );
  }

  Widget _uploadControls() => AccountFlowRow(
                                children: [
                                  PoActionFeedback(
                                      child: InkWell(
                                    onTap: () async {
                                      // if (arrayFiles.length != 4) {
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: [
                                          'jpg',
                                          'jpeg',
                                          'png',
                                          // "mp4",
                                          "pdf",
                                        ],
                                      );
                                      if (result != null) {
                                        PlatformFile file = result.files.first;
                                        Uint8List? fileBytes =
                                            result.files.first.bytes;
                                        String fileName =
                                            result.files.first.name;
                                        setState(() {
                                          arrayFilesBytes.add(fileBytes);
                                          arrayFiles.add(file);
                                        });

                                        //inspect(arrayFiles[0]);
                                      } else {
                                        // User canceled the picker
                                      }
                                      // }
                                    },
                                    child: Image.asset(
                                      'images/projectmanagement/img5.png',
                                      height: widget.poId == 'Verified' ? 64 : 100,
                                      width: widget.poId == 'Verified' ? 64 : 100,
                                    ),
                                  )),
                                  const SizedBox(width: 10),
                                  for (int j = 0;
                                      j <
                                          widget
                                              .orderDetails!.poDocument!.length;
                                      j++)
                                    AccountFlowRow(
                                      children: [
                                        if (widget.orderDetails!.poDocument?[j]
                                                    .split('.')
                                                    .last
                                                    .toLowerCase() ==
                                                'jpg' ||
                                            widget.orderDetails!.poDocument?[j]
                                                    .split('.')
                                                    .last
                                                    .toLowerCase() ==
                                                'jpeg' ||
                                            widget.orderDetails!.poDocument?[j]
                                                    .split('.')
                                                    .last
                                                    .toLowerCase() ==
                                                'png') //'jpg','jpeg','png',
                                          Container(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                (useAccountManagementTestData
                                                    ? Icon(
                                                        Icons
                                                            .description_outlined,
                                                        size: widget.poId == 'Verified' ? 36 : 48,
                                                        color: Colors.black54)
                                                    : Image.network(
                                                        '${AppUrl.poDocPath}${widget.orderDetails!.poDocument?[j]}',
                                                        // ),
                                                        // File(widget
                                                        //     .orderDetails!.poDocument![j]),
                                                        height: widget.poId == 'Verified' ? 64 : 100,
                                                        width: widget.poId == 'Verified' ? 64 : 100,
                                                        fit: BoxFit.fill,
                                                      )),
                                                // Positioned(
                                                //   right: -10,
                                                //   top: -10,
                                                //   child: InkWell(
                                                //     onTap: () {
                                                //       // setState(() {
                                                //       //   arrayFiles
                                                //       //       .remove(arrayFiles[j]);
                                                //       //   arrayFilesBytes
                                                //       //       .remove(arrayFilesBytes[j]);
                                                //       // });
                                                //     },
                                                //     child: const Icon(Icons.close),
                                                //   ),
                                                // )
                                              ],
                                            ),
                                          ),
                                        if (widget.orderDetails!.poDocument?[j]
                                                .split('.')
                                                .last
                                                .toLowerCase() ==
                                            'pdf')
                                          Container(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                PoActionFeedback(
                                                    child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) {
                                                          return (useAccountManagementTestData
                                                              ? const AccountManagementPreviewDocumentScreen()
                                                              : PdfViewer(
                                                                  fileName: widget
                                                                      .orderDetails!
                                                                      .poDocument?[j],
                                                                  fileUrl:
                                                                      '${AppUrl.globalGrnPath}${widget.orderDetails!.poDocument?[j]}',

                                                                  // isLocalFileUpload: false,
                                                                  // localFiles:
                                                                  //     arrayFiles[j].path,
                                                                  // fileName: widget
                                                                  //     .orderDetails!
                                                                  //     .poDocument?[j],
                                                                  // fileUrl: arrayFiles[j].path,
                                                                ));
                                                        },
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.grey,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    // width: 100,
                                                    child: Image.asset(
                                                      'images/projectmanagement/pdf.png',
                                                      width: widget.poId == 'Verified' ? 64 : 100,
                                                      height: widget.poId == 'Verified' ? 64 : 100,
                                                    ),
                                                  ),
                                                )),
                                                Positioned(
                                                  right: -10,
                                                  top: -10,
                                                  child: PoActionFeedback(
                                                      child: InkWell(
                                                    onTap: () {
                                                      // setState(() {
                                                      //   arrayFiles
                                                      //       .remove(arrayFiles[j]);
                                                      //   arrayFilesBytes
                                                      //       .remove(arrayFilesBytes[j]);
                                                      // });
                                                    },
                                                    child:
                                                        const Icon(Icons.close),
                                                  )),
                                                )
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  const SizedBox(width: 10),
                                  for (int j = 0; j < arrayFiles.length; j++)
                                    AccountFlowRow(
                                      children: [
                                        if (arrayFiles[j].extension == 'jpg' ||
                                            arrayFiles[j].extension == 'jpeg' ||
                                            arrayFiles[j].extension ==
                                                'png') //'jpg','jpeg','png',
                                          Container(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Image.file(
                                                  File(
                                                      arrayFiles[j].path ?? ''),
                                                  height: widget.poId == 'Verified' ? 64 : 100,
                                                  width: widget.poId == 'Verified' ? 64 : 100,
                                                  fit: BoxFit.fill,
                                                ),
                                                Positioned(
                                                  right: -10,
                                                  top: -10,
                                                  child: PoActionFeedback(
                                                      child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        arrayFiles.remove(
                                                            arrayFiles[j]);
                                                        arrayFilesBytes.remove(
                                                            arrayFilesBytes[j]);
                                                      });
                                                    },
                                                    child:
                                                        const Icon(Icons.close),
                                                  )),
                                                )
                                              ],
                                            ),
                                          ),
                                        if (arrayFiles[j].extension == 'pdf')
                                          Container(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                PoActionFeedback(
                                                    child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) {
                                                          return (useAccountManagementTestData
                                                              ? const AccountManagementPreviewDocumentScreen()
                                                              : PdfViewer(
                                                                  isLocalFileUpload:
                                                                      true,
                                                                  localFiles:
                                                                      arrayFiles[
                                                                              j]
                                                                          .path,
                                                                  fileName:
                                                                      arrayFiles[
                                                                              j]
                                                                          .name,
                                                                  fileUrl:
                                                                      arrayFiles[
                                                                              j]
                                                                          .path,
                                                                ));
                                                        },
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.grey,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    // width: 100,
                                                    child: Image.asset(
                                                      'images/projectmanagement/pdf.png',
                                                      width: widget.poId == 'Verified' ? 64 : 100,
                                                      height: widget.poId == 'Verified' ? 64 : 100,
                                                    ),
                                                  ),
                                                )),
                                                Positioned(
                                                  right: -10,
                                                  top: -10,
                                                  child: PoActionFeedback(
                                                      child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        arrayFiles.remove(
                                                            arrayFiles[j]);
                                                        arrayFilesBytes.remove(
                                                            arrayFilesBytes[j]);
                                                      });
                                                    },
                                                    child:
                                                        const Icon(Icons.close),
                                                  )),
                                                )
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                ],
                              );

  Widget _otherRemarksField() => _poFormRow('Other Remarks',
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                        context.accountCompact
                                            ? 'Other Remarks -'
                                            : 'Other Remarks',
                                        style: normalText),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: widget.poId == 'Verified' ? 0 : (context.accountCompact ? 0 : 40),
                                          right: widget.poId == 'Verified' ? 0 : 10,
                                          top: 0),
                                      child: SizedBox(
                                        child: TextFormField(
                                          enabled: widget.poId == 'Verified' ||
                                              !flagBtnHideApproveReject,
                                          controller: _txtControllerRemark,
                                          minLines: widget.poId == 'Verified' ? 2 : null,
                                          maxLines: widget.poId == 'Verified' ? 2 : 3,
                                          onChanged: (String str) {
                                            strRemark = str;
                                          },
                                          style: widget.poId == 'Verified'
                                              ? normalText.copyWith(
                                                  fontSize: context.accountFont(15, mobile: 12.6), height: 1.5)
                                              : context.accountCompact
                                                  ? normalText.copyWith(fontSize: 12.6)
                                                  : normalText,
                                          decoration: InputDecoration(
                                            hintText: 'Enter Other Remarks',
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: context.accountCompact ? 12.6 : 14,
                                                    vertical: widget.poId == 'Verified' ? 6 : (context.accountCompact ? 10.8 : 12)),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                    color: Color(0xffd0d4d8))),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                    color: Color(0xffd0d4d8))),
                                            disabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                    color: Color(0xffd0d4d8))),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                    color: Colors.black)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              );

  Widget _poFooterCapsule(String label, {bool enabled = true}) => LayoutBuilder(
      builder: (context, constraints) => Container(
      key: ValueKey('po-footer-$label'),
      height: widget.poId == 'Verified' ? 45.6 : 48,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(
          horizontal: constraints.maxWidth * 0.01, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: enabled ? Colors.black : Colors.grey,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
                color: Color(0x18000000), blurRadius: 6, offset: Offset(0, 3))
          ]),
      child: Text(label,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: context.accountFont(14, mobile: 12)))));

  Widget _poPopupHeader(String title) => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      child: Text(title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: context.accountFont(17, mobile: 15),
              fontWeight: FontWeight.w700,
              color: Colors.white)));

  Widget _poPopupAction(String label) => Container(
      width:
          context.accountCompact ? MediaQuery.sizeOf(context).width - 96 : 400,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: context.accountFont(15, mobile: 13))));
  BoxDecoration _poPopupRowDecoration(bool selected) => BoxDecoration(
      color: selected ? const Color(0xfff1f3f5) : Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
          color: selected ? const Color(0xffced4da) : const Color(0xffe9ecef)));

  Widget _poPopupSelectionRow(String label,
          {required bool selected, bool disabled = false}) =>
      Row(children: [
        Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: context.accountFont(15, mobile: 13),
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: Colors.black87))),
        const SizedBox(width: 12),
        Icon(selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 22,
            color: disabled
                ? Colors.grey
                : selected
                    ? Colors.green
                    : Colors.grey),
      ]);

  InputDecoration _poPopupSearchDecoration(String hint) {
    final border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffdee2e6)));
    return InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xfff8f9fa),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        prefixIcon:
            const Icon(Icons.search_rounded, size: 19, color: Colors.black54),
        border: border,
        enabledBorder: border,
        focusedBorder:
            border.copyWith(borderSide: const BorderSide(color: Colors.black)));
  }

  Widget _verifyPoSummary() {
    final order = widget.orderDetails!;
    String value(String? text) => text == null || text.trim().isEmpty ? '—' : text;
    final status = const {'0': 'Pending', '1': 'Assigned', '2': 'Issued', '3': 'Dispute'}[order.poStatus] ?? '---';
    final statusColor = order.poStatus == '2'
        ? Color.alphaBlend(const Color(0xff00802b).withOpacity(0.38), Colors.white)
        : ['0', '1', '3'].contains(order.poStatus)
            ? Color.alphaBlend(const Color(0xffffd633).withOpacity(0.55), Colors.white)
            : Colors.white;
    Widget detail(String label, String text, {Color color = Colors.white}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(flex: 4, child: Text(label, style: TextStyle(
            color: Colors.white, fontSize: context.accountCompact ? 11 : 14,
            height: 1.25))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('-', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ),
        Expanded(flex: 6, child: Text(text, style: TextStyle(
            color: color, fontSize: context.accountCompact ? 12 : 14,
            height: 1.25, fontWeight: FontWeight.w700))),
      ]),
    );
    return Container(
      key: const ValueKey('verify-po-summary-card'),
      margin: const EdgeInsets.fromLTRB(8, 10, 8, 4),
      padding: EdgeInsets.symmetric(horizontal: context.accountCompact ? 12 : 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: IntrinsicHeight(child: Row(
        key: context.accountCompact ? const ValueKey('po-mobile-summary') : null,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: Column(children: [
            detail('P.O. No.', value(order.poNo)),
            detail('P.O. Status', status, color: statusColor),
            detail('Slab No', value(order.slabName)),
          ])),
          const VerticalDivider(width: 16, thickness: 0.5, color: Colors.white24),
          Expanded(child: Column(children: [
            detail('Booking Type', value(order.gradeName)),
            detail('Project Name', value(order.projectName)),
            detail('Requested By', value(order.raisedBy)),
          ])),
        ],
      )),
    );
  }

  Widget _poSummaryRow({required List<Widget> children}) {
    if (!context.accountCompact) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: children);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
          key: const ValueKey('po-mobile-summary'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: children[i]),
            ]
          ]),
    );
  }

  Widget _poFormRow(String label,
      {required List<Widget> children,
      CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) {
    final compactLabels = widget.poId == 'Verified';
    final gradeLabel = const {
      'Requirement Type': 'Grade type',
      'Description / Sub type': 'Grade name',
    }[label];
    final infoMessage = const {
      'Requirement Type': 'Also know as Requirement/Product type',
      'Description / Sub type': 'Grade name: Also known as Description/Sub type',
    }[label];
    final displayLabel = '${gradeLabel ?? label} -';
    final labelText = FittedBox(
      fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
      child: Text(displayLabel, maxLines: 1, style: TextStyle(
        fontSize: context.accountCompact ? 12 : 14,
        height: 1.1, fontWeight: FontWeight.w600, color: Colors.black87)));
    final Widget title = compactLabels
        ? SizedBox(height: _poFieldHeight,
            child: infoMessage == null ? labelText : Tooltip(
              key: ValueKey('po-grade-info-$label'),
              message: infoMessage,
              triggerMode: TooltipTriggerMode.tap,
              waitDuration: const Duration(milliseconds: 350),
              showDuration: const Duration(seconds: 4),
              child: Row(children: [
                Flexible(child: labelText),
                const SizedBox(width: 4),
                const Icon(Icons.info_outline, size: 16, color: Colors.black54),
              ])))
        : Text('$label -', style: TextStyle(
            fontSize: context.accountFont(15, mobile: 13),
            fontWeight: FontWeight.w600, color: Colors.black87));
    if (!context.accountCompact) {
      if (compactLabels) {
        return Row(key: ValueKey('po-form-$label'),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [SizedBox(width: 110, child: title), ...children.skip(1)]);
      }
      return AccountFlowRow(
          crossAxisAlignment: crossAxisAlignment, children: children);
    }
    final controls = children.skip(1)
        .where((child) => child is! SizedBox || child.child != null)
        .map((child) => child is Flexible ? child.child : child).toList();
    if (label == 'Description / Sub type' && widget.poId != 'Verified') {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [title, const SizedBox(height: 8), ...controls]);
    }
    if (label == 'Requirement For') {
      if (compactLabels) {
        return Row(key: const ValueKey('po-form-Requirement For'),
            crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(flex: 3, child: title),
          const SizedBox(width: 8),
          Expanded(flex: 8, child: Row(children: [
            Expanded(child: controls.first),
            const SizedBox(width: 6),
            controls.last,
          ])),
        ]);
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [Expanded(child: title), controls.last]),
        const SizedBox(height: 8), controls.first
      ]);
    }
    return Row(key: ValueKey('po-form-$label'),
        crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(flex: compactLabels ? 3 : 4, child: title),
          const SizedBox(width: 8),
          Expanded(flex: compactLabels ? 8 : 7,
              child: Row(children: [
                for (var i = 0; i < controls.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(child: controls[i]),
                ]
              ])),
        ]);
  }

  double get _poFieldHeight {
    if (widget.poId != 'Verified') return context.accountCompact ? 40.5 : 45;
    final fontSize = context.accountCompact ? 14.0 : 15.0;
    return MediaQuery.textScalerOf(context).scale(fontSize) * 1.5 + 14;
  }

  Widget _requirementType(int indexRow) {
    return _poFormRow(
      'Requirement Type',
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.accountCompact ? 100 : 230.0,
          height: widget.poId == 'Verified' ? _poFieldHeight : 40,
          child: Padding(
            padding: EdgeInsets.only(top: widget.poId == 'Verified' ? 6 : 15),
            child: Text('Requirement Type',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: context.accountFont(15, mobile: 14),
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        // Expanded(
        //   child: Container(
        //     decoration: BoxDecoration(
        //         color: kcTextFieldColor,
        //         border: Border.all(
        //           color: Colors.grey,
        //         ),
        //         borderRadius: const BorderRadius.all(Radius.circular(8.0))),
        //     child: Padding(
        //       padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        //       child: SearchChoices.single(
        //         style: const TextStyle(fontSize: 15.0, color: Colors.black),
        //         items: requirementTypeitems,
        //         value: arrayList[index].grade_type_name.toString(),
        //         hint: "Select Requirement Type",
        //         searchHint: "Select Requirement Type",
        //         readOnly: flagBtnHideApproveReject == false ? false : true,
        //         onChanged: (value) {
        //           setState(() {
        //             //if (index == int.parse(arrayList[index]["id"].toString())) {
        //             arrayList[index].grade_type_name = value;
        //             for (var i = 0; i < finishingTypeList!.length; i++) {
        //               if (finishingTypeList![i].finishingName == value) {
        //                 arrayList[index].grade_id =
        //                     finishingTypeList![i].finishingId ?? '';
        //                 selectedRequirementTypeId =
        //                     finishingTypeList![i].finishingId;
        //                 break;
        //               }
        //             }
        //             //}
        //           });
        //           arrayList[index].casting_unit_name = '';
        //           arrayList[index].casting_unit = '';
        //           arrayList[index].description = '';
        //           fetchGradeDescription();
        //         },
        //         padding: selectedRequirementType == '' ||
        //                 selectedRequirementType == null
        //             ? 0.0
        //             : 0.0,
        //         dialogBox: false,
        //         isExpanded: true,
        //         menuConstraints:
        //             BoxConstraints.tight(const Size.fromHeight(350.0)),
        //         onClear: () {
        //           setState(() {
        //             arrayList[index].grade_type_name = '';
        //             arrayList[index].grade_id = '';
        //             arrayList[index].casting_unit_name = '';
        //             arrayList[index].casting_unit = '';
        //             arrayList[index].description = '';
        //           });
        //         },
        //         underline: const SizedBox(height: 0.0),
        //       ),
        //     ),
        //   ),
        // ),
        Expanded(
          child: InkWell(
            onTap: () {
              print('Clicked');
              editingController.text = "";
              finishingTypeList = finishingTypeListOriginal;
              _selectedReqTypeIndex = arrayList[indexRow].grade_id.toString();
              _showPoDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    clipBehavior: Clip.antiAlias,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    constraints: context.accountCompact
                        ? BoxConstraints.tightFor(width: (MediaQuery.sizeOf(context).width - 32) * 0.9)
                        : null,
                    actionsAlignment: MainAxisAlignment.center,
                    titlePadding: EdgeInsets.zero,
                    actionsPadding: EdgeInsets.zero,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10),
                    title: _poPopupHeader('Select Requirement Type'),
                    actions: <Widget>[
                      PoActionFeedback(
                          child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: _poPopupAction('OK'),
                      )),
                    ],
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState1) {
                        return Container(
                          key: formkey,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          height: widget.poId == 'Verified'
                              ? (context.accountCompact ? 360 : 400)
                              : (context.accountCompact ? 405 : 450),
                          width: 400,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (useAccountManagementTestData) ...[
                                const Text('Sample requirement types · preview only',
                                    style: TextStyle(fontSize: 12, color: Colors.black54)),
                                const SizedBox(height: 8),
                              ],
                              SizedBox(
                                height: 40,
                                child: TextField(
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      if (value.length > 2) {
                                        List<FinishingTypeList>? filteredList =
                                            [];
                                        filteredList = finishingTypeListOriginal
                                            ?.where((element) => element
                                                .finishingName!
                                                .toLowerCase()
                                                .contains(value.toLowerCase()))
                                            .toList();
                                        setState1(() {
                                          finishingTypeList = filteredList;
                                        });
                                      }
                                    } else {
                                      setState1(() {
                                        finishingTypeList =
                                            finishingTypeListOriginal;
                                      });
                                    }
                                  },
                                  style: TextStyle(
                                      fontSize:
                                          context.accountFont(13, mobile: 13)),
                                  controller: editingController,
                                  decoration: _poPopupSearchDecoration(
                                      'Search Requirement Type').copyWith(
                                          filled: true, fillColor: Colors.white),
                                ),
                              ),
                              verticalSpaceTiny,
                              Expanded(
                                  child: finishingTypeList!.isNotEmpty
                                      ? ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: finishingTypeList!.length,
                                          itemBuilder: (context, int index) {
                                            return InkWell(
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                setState1(() {
                                                  _selectedReqTypeIndex =
                                                      finishingTypeList![index]
                                                          .finishingId;
                                                  // _txtControllerRequirmentType[
                                                  //             indexRow]
                                                  //         .text =
                                                  //     finishingTypeList![index]
                                                  //         .finishingName!;
                                                  arrayList[indexRow]
                                                          .grade_type_name =
                                                      finishingTypeList![index]
                                                          .finishingName!;
                                                  arrayList[indexRow].grade_id =
                                                      finishingTypeList![index]
                                                          .finishingId!;

                                                  selectedRequirementTypeId =
                                                      finishingTypeList![index]
                                                          .finishingId;

                                                  // arrayList[indexRow]
                                                  //     .casting_unit_name = '';
                                                  // arrayList[indexRow].casting_unit =
                                                  //     '';
                                                  // arrayList[indexRow].description =
                                                  //     '';

                                                  arrayList[indexRow]
                                                      .editingControllerGradeTypeName
                                                      ?.text = finishingTypeList![
                                                          index]
                                                      .finishingName!;
                                                  arrayList[indexRow].grade_id =
                                                      finishingTypeList![index]
                                                          .finishingId!;
                                                  // arrayList[indexRow]
                                                  //     .editingControllerCastingUnitName
                                                  //     ?.clear();
                                                  // arrayList[index]
                                                  //     .editingControllerDescription
                                                  //     ?.clear();

                                                  fetchGradeDescription();
                                                });
                                              },
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                decoration:
                                                    _poPopupRowDecoration(
                                                        _selectedReqTypeIndex ==
                                                            finishingTypeList![
                                                                    index]
                                                                .finishingId),
                                                padding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 5.0,
                                                        vertical: widget.poId == 'Verified' ? 5 : 7),
                                                child: Column(
                                                  children: [
                                                    Row(children: [
                                                      Expanded(child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(finishingTypeList![index].finishingName!,
                                                              textAlign: TextAlign.left, style: normalText),
                                                          Text('Available Vendors(${finishingTypeList![index].count ?? '0'})',
                                                              style: TextStyle(color: Colors.blue,
                                                                  fontSize: context.accountFont(13, mobile: 13))),
                                                        ],
                                                      )),
                                                      const SizedBox(width: 8),
                                                      Icon(
                                                        _selectedReqTypeIndex == finishingTypeList![index].finishingId
                                                            ? Icons.check_circle_outline_outlined
                                                            : Icons.circle_outlined,
                                                        size: 25,
                                                        color: _selectedReqTypeIndex == finishingTypeList![index].finishingId
                                                            ? Colors.green : Colors.grey,
                                                      ),
                                                    ]),
                                                    if (widget.poId != 'Verified') ...[
                                                    verticalSpaceSmall,
                                                    const Divider(
                                                        height: 1.0,
                                                        color: Colors.black),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            );
                                          })
                                      : Center(
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              _txtCustomRequirementType.text =
                                                  "";
                                              _showPoDialog<void>(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16)),
                                                        surfaceTintColor:
                                                            Colors.transparent,
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .all(0.0),
                                                        content: SizedBox(
                                                          width: 500,
                                                          height: 300,
                                                          child: Center(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          10.0,
                                                                      right: 10,
                                                                      top: 20,
                                                                      bottom:
                                                                          10),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const Text(
                                                                    'Enter Requirement Type',
                                                                    style:
                                                                        boldText,
                                                                  ),
                                                                  verticalSpaceMedium,
                                                                  verticalSpaceSmall,
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            20.0),
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          45.0,
                                                                      decoration: BoxDecoration(
                                                                          color: kcTextFieldColor,
                                                                          border: Border.all(
                                                                            color:
                                                                                Colors.grey,
                                                                          ),
                                                                          borderRadius: const BorderRadius.all(Radius.circular(8.0))),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10.0,
                                                                            right:
                                                                                10.0),
                                                                        child:
                                                                            TextField(
                                                                          controller:
                                                                              _txtCustomRequirementType,
                                                                          autofocus:
                                                                              false,
                                                                          enabled:
                                                                              true,
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: context.accountFont(15.0, mobile: 12.6)),
                                                                          decoration:
                                                                              InputDecoration(
                                                                            border:
                                                                                InputBorder.none,
                                                                            hintText:
                                                                                'Enter Requirement Type',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  verticalSpaceMedium,
                                                                  verticalSpaceSmall,
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            20.0,
                                                                        right:
                                                                            20),
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          40,
                                                                      child:
                                                                          AccountFlowRow(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceAround,
                                                                        children: [
                                                                          Expanded(
                                                                            child: AccountActionButton(
                                                                                lblText: "CLOSE",
                                                                                color: Colors.black,
                                                                                onTap: () {
                                                                                  Navigator.of(context).pop();
                                                                                }),
                                                                          ),
                                                                          horizontalSpaceSmall,
                                                                          Expanded(
                                                                            child: AccountActionButton(
                                                                                lblText: "SUBMIT",
                                                                                color: Colors.black,
                                                                                onTap: () {
                                                                                  if (_txtCustomRequirementType.text.isEmpty) {
                                                                                    _showPoDialog<void>(
                                                                                        context: context,
                                                                                        builder: (BuildContext context) {
                                                                                          return AlertDialog(
                                                                                              clipBehavior: Clip.antiAlias,
                                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                                              surfaceTintColor: Colors.transparent,
                                                                                              contentPadding: const EdgeInsets.all(0.0),
                                                                                              content: SizedBox(
                                                                                                  width: 400,
                                                                                                  height: 200,
                                                                                                  child: Column(
                                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                                    children: [
                                                                                                      verticalSpaceMedium,
                                                                                                      const Text(
                                                                                                        'Please enter a requirement type.',
                                                                                                        style: normalText,
                                                                                                      ),
                                                                                                      verticalSpaceMedium,
                                                                                                      Padding(
                                                                                                        padding: const EdgeInsets.symmetric(horizontal: 70.0),
                                                                                                        child: SizedBox(
                                                                                                          height: 40,
                                                                                                          child: AccountActionButton(
                                                                                                              lblText: "CLOSE",
                                                                                                              color: Colors.black,
                                                                                                              onTap: () {
                                                                                                                Navigator.of(context).pop();
                                                                                                              }),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  )));
                                                                                        });
                                                                                  } else {
                                                                                    var flag = false;
                                                                                    for (var i = 0; i < finishingTypeListOriginal!.length; i++) {
                                                                                      if (finishingTypeListOriginal![i].finishingName!.toLowerCase() == _txtCustomRequirementType.text.toLowerCase()) {
                                                                                        flag = true;
                                                                                        break;
                                                                                      }
                                                                                    }
                                                                                    if (flag == true) {
                                                                                      _showPoDialog<void>(
                                                                                          context: context,
                                                                                          builder: (BuildContext context) {
                                                                                            return AlertDialog(
                                                                                                clipBehavior: Clip.antiAlias,
                                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                                                surfaceTintColor: Colors.transparent,
                                                                                                contentPadding: const EdgeInsets.all(0.0),
                                                                                                content: SizedBox(
                                                                                                    width: 400,
                                                                                                    height: 300,
                                                                                                    child: Column(
                                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                      children: [
                                                                                                        verticalSpaceMedium,
                                                                                                        const Padding(
                                                                                                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                                                                                                          child: Text(
                                                                                                            'Entered requirement type already exists. Please enter new requirement type or select from a requirement type list.',
                                                                                                            style: normalText,
                                                                                                            textAlign: TextAlign.center,
                                                                                                          ),
                                                                                                        ),
                                                                                                        verticalSpaceMedium,
                                                                                                        Padding(
                                                                                                          padding: const EdgeInsets.symmetric(horizontal: 70.0),
                                                                                                          child: SizedBox(
                                                                                                            height: 40,
                                                                                                            child: AccountActionButton(
                                                                                                                lblText: "CLOSE",
                                                                                                                color: Colors.black,
                                                                                                                onTap: () {
                                                                                                                  Navigator.of(context).pop();
                                                                                                                }),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ],
                                                                                                    )));
                                                                                          });
                                                                                    } else {
                                                                                      Navigator.of(context).pop();
                                                                                      submitAddCustomRequirementType(indexRow);
                                                                                    }
                                                                                  }
                                                                                }),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ));
                                                  });
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 18),
                                              decoration: BoxDecoration(
                                                border: Border.all(),
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(999)),
                                              ),
                                              child: Text(
                                                'ADD CUSTOM TYPE',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: context.accountFont(
                                                      17.0,
                                                      mobile: 14),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
            child: Stack(alignment: Alignment.center, children: [
              Container(
                height: _poFieldHeight,
                decoration: BoxDecoration(
                    color: kcTextFieldColor,
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(8.0))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextField(
                    // controller: _txtControllerRequirmentType[indexRow],
                    controller:
                        arrayList[indexRow].editingControllerGradeTypeName,
                    autofocus: false,
                    enabled: false,
                    textAlign: TextAlign.start,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.accountFont(15.0, mobile: 12.6)),
                    decoration: InputDecoration(
                      isDense: widget.poId == 'Verified',
                      contentPadding:
                          EdgeInsets.only(
                            top: widget.poId == 'Verified' ? 0 : 12,
                            bottom: widget.poId == 'Verified' ? 0 : 12,
                            left: 0,
                            right: 28),
                      border: InputBorder.none,
                      hintText: 'Select Requirement Type',
                    ),
                    ),
                  ),
                ),
              ),
              Positioned(
                  right: 10,
                  child: Center(
                      child: Icon(widget.poId == 'Verified' ? Icons.keyboard_arrow_down : Icons.arrow_drop_down,
                          key: const ValueKey('po-requirement-type-dropdown-icon'),
                          size: context.accountCompact ? 18 : 24))),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _description(int index) {
    // _typeAheadController.add(TextEditingController());
    // _typeAheadController[index].text = arrayList[index].description.toString();

    final controller = arrayList[index].editingControllerDescription ??=
        TextEditingController(text: arrayList[index].description.toString());
    if (controller.text != arrayList[index].description.toString()) {
      controller.text = arrayList[index].description.toString();
    }
    return _poFormRow(
      'Description / Sub type',
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.accountCompact ? 100 : 230.0,
          height: widget.poId == 'Verified' ? _poFieldHeight : 40,
          child: Padding(
            padding: EdgeInsets.only(top: widget.poId == 'Verified' ? 6 : 15),
            child: Text('Description / Sub type',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: context.accountFont(15, mobile: 14),
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: _poFieldHeight,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8.0))),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: TypeAheadField<String>(
                getImmediateSuggestions: true,
                textFieldConfiguration: TextFieldConfiguration(
                  onChanged: (value) {
                    arrayList[index].description = value;
                  },
                  enabled: !flagBtnHideApproveReject ||
                      widget.poId == 'Verified',
                  controller: controller,
                  style: TextStyle(fontSize: context.accountFont(15, mobile: 12.6)),
                  decoration:
                      InputDecoration(hintText: 'Enter Description'),
                ),
                suggestionsCallback: (pattern) {
                  return Future.delayed(
                    const Duration(seconds: 1),
                    () => CitiesService.getSuggestions(pattern),
                  );
                },
                itemBuilder: (context, String suggestion) {
                  return AccountCard(
                      child: ListTile(
                    title: Text(suggestion),
                  ));
                },
                onSuggestionSelected: (String suggestion) {
                  setState(() {
                    // _typeAheadController[index].text = suggestion;
                    arrayList[index].editingControllerDescription?.text =
                        suggestion;
                    arrayList[index].description = suggestion;
                    arrayList[index].editingControllerDescription?.text =
                        suggestion;
                  });

                  if (kDebugMode) {
                    print(suggestion);
                  }
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _requirementFor(int index) {
    // _txtControllerRequirementFor.add(TextEditingController());
    // _txtControllerRequirementFor[index].text =
    //     arrayList[index].casting_for.toString();
    final controller = arrayList[index].editingControllerCastingFor ??=
        TextEditingController(text: arrayList[index].casting_for.toString());
    if (controller.text != arrayList[index].casting_for.toString()) {
      controller.text = arrayList[index].casting_for.toString();
    }
    return _poFormRow(
      'Requirement For',
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.accountCompact ? 100 : 230.0,
          height: widget.poId == 'Verified' ? _poFieldHeight : 40,
          child: Padding(
            padding: EdgeInsets.only(top: widget.poId == 'Verified' ? 6 : 15),
            child: Text('Requirement For',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: context.accountFont(15, mobile: 14),
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: _poFieldHeight,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8.0))),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: TypeAheadField<String>(
                getImmediateSuggestions: true,
                textFieldConfiguration: TextFieldConfiguration(
                  enabled: !flagBtnHideApproveReject ||
                      widget.poId == 'Verified',
                  controller: controller,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.accountFont(15, mobile: 12.6)),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        vertical: widget.poId == 'Verified' ? 6 : (context.accountCompact ? 10.8 : 12)),
                    border: InputBorder.none,
                    hintText: 'Enter requirement for',
                  ),
                  onChanged: (value) => arrayList[index].casting_for = value,
                ),
                suggestionsCallback: (pattern) => (slabDetailsOriginal ?? [])
                    .map((slab) => slab.slab_name ?? '')
                    .where((name) => name.isNotEmpty &&
                        name.toLowerCase().contains(pattern.toLowerCase()))
                    .toSet()
                    .toList(),
                itemBuilder: (context, suggestion) => ListTile(
                    title: Text(suggestion)),
                onSuggestionSelected: (suggestion) {
                  controller.text = suggestion;
                  arrayList[index].casting_for = suggestion;
                },
              ),
            ),
          ),
        ),
        horizontalSpaceSmall,
        SizedBox(
          width: widget.poId == 'Verified'
              ? (context.accountCompact ? 74 : 103)
              : (context.accountCompact ? 86.4 : 120),
          height: widget.poId == 'Verified'
              ? (context.accountCompact ? 28 : 38.5)
              : (context.accountCompact ? 32.4 : 45),
          child: InkWell(
            onTap: () {
              _txtSearchSlab.clear();
              slabDetails = slabDetailsOriginal;
              _showPoDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    surfaceTintColor: Colors.transparent,
                    constraints: context.accountCompact
                        ? BoxConstraints.tightFor(width: (MediaQuery.sizeOf(context).width - 48) * 0.9)
                        : null,
                    titlePadding: EdgeInsets.zero,
                    title: _poPopupHeader('SELECT SLAB'),
                    contentPadding: const EdgeInsets.all(0.0),
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            key: formkeySlab,
                            height: (MediaQuery.sizeOf(context).height * 0.65)
                                .clamp(220.0, 520.0) * (context.accountCompact ? 0.9 : 1) - 48,
                            width: context.accountCompact
                                ? MediaQuery.sizeOf(context).width - 64
                                : 480,
                            color: Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (useAccountManagementTestData)
                                  const Text('Sample slabs · preview only',
                                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                                verticalSpaceTiny,
                                SizedBox(
                                  height: 45,
                                  child: TextField(
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        if (value.length > 2) {
                                          List<SlabDetail>? filteredList = [];
                                          filteredList = slabDetailsOriginal
                                              ?.where((element) => element
                                                  .slab_name!
                                                  .toLowerCase()
                                                  .contains(
                                                      value.toLowerCase()))
                                              .toList();
                                          setState(() {
                                            slabDetails = filteredList;
                                          });
                                        }
                                      } else {
                                        setState(() {
                                          slabDetails = slabDetailsOriginal;
                                        });
                                      }
                                    },
                                    style: TextStyle(
                                        fontSize: context.accountFont(13,
                                            mobile: 13)),
                                    controller: _txtSearchSlab,
                                    decoration:
                                        _poPopupSearchDecoration('Search Slab').copyWith(
                                            filled: true, fillColor: Colors.white),
                                  ),
                                ),
                                verticalSpaceTiny,
                                Expanded(
                                  child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: slabDetails!.length,
                                      itemBuilder: (context, int indexFor) {
                                        return PoActionFeedback(
                                            child: InkWell(
                                          onTap: () {
                                            print('Selected');
                                            var castingFor = "";
                                            setState(() {
                                              if (slabDetails![indexFor]
                                                      .selected ==
                                                  "1") {
                                                slabDetails![indexFor]
                                                    .selected = '0';
                                                slabDetailsSelectedArray
                                                    ?.remove(
                                                        slabDetails![indexFor]);
                                              } else {
                                                slabDetails![indexFor]
                                                    .selected = '1';
                                                slabDetailsSelectedArray?.add(
                                                    slabDetails![indexFor]);
                                              }
                                            });
                                            for (int i = 0;
                                                i < slabDetails!.length;
                                                i++) {
                                              if (slabDetails![i].selected ==
                                                  "1") {
                                                if (castingFor.isEmpty) {
                                                  castingFor = slabDetails![i]
                                                      .slab_name!;
                                                } else {
                                                  castingFor =
                                                      "$castingFor, ${slabDetails![i].slab_name!}";
                                                }
                                              }
                                            }
                                            updateRequirementFor(
                                                castingFor, index);
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            decoration: _poPopupRowDecoration(
                                                slabDetails![indexFor]
                                                        .selected ==
                                                    '1'),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                                vertical: 13.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(child: Text(
                                                      slabDetails![indexFor].slab_name!,
                                                      textAlign: TextAlign.left,
                                                      style: normalText,
                                                    )),
                                                    const SizedBox(width: 8),
                                                    slabDetails![indexFor]
                                                                .selected ==
                                                            '1'
                                                        ? const Icon(
                                                            Icons
                                                                .check_circle_outline_outlined,
                                                            size: 25,
                                                            color: Colors.green,
                                                          )
                                                        : const Icon(
                                                            Icons
                                                                .circle_outlined,
                                                            size: 25,
                                                            color: Colors.grey,
                                                          )
                                                  ],
                                                ),
                                                verticalSpaceSmall,
                                                const Divider(
                                                    height: 1.0,
                                                    color: Colors.black),
                                              ],
                                            ),
                                          ),
                                        ));
                                      }),
                                ),
                                verticalSpaceTiny,
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: AccountActionButton(
                                    lblText: 'OK',
                                    color: kcPrimaryColor,
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
            child: Container(
              width: double.infinity,
              height: widget.poId == 'Verified'
              ? (context.accountCompact ? 28 : 38.5)
              : (context.accountCompact ? 32.4 : 45),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(999)),
                border: Border.all(
                  color: Colors.black,
                  width: 0.8,
                ),
              ),
              child: Text(
                'SELECT SLAB',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  fontSize: widget.poId == 'Verified'
                      ? context.accountFont(10, mobile: 10)
                      : context.accountFont(11, mobile: 11),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void updateRequirementFor(String castingFor, int index) {
    for (int i = 0; i < arrayList.length; i++) {
      arrayList[i].casting_for = castingFor;
    }

    setState(() {
      // arrayList.length;
      castingRequirementFor = castingFor;
      // _txtControllerRequirementFor[index].text = castingFor;
      arrayList[index].editingControllerCastingFor?.text = castingFor;
    });
  }

  Widget _selectedReqDate(int index) {
    return _poFormRow(
      'Requirement Date',
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.accountCompact ? 100 : 230.0,
          height: widget.poId == 'Verified' ? _poFieldHeight : 40,
          child: Padding(
            padding: EdgeInsets.only(top: widget.poId == 'Verified' ? 6 : 15),
            child: Text('Requirement Date',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: context.accountFont(15, mobile: 14),
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: _poFieldHeight,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8.0))),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: InkWell(
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: (!flagBtnHideApproveReject ||
                        widget.poId == 'Verified')
                    ? () async {
                        DateTime? newDateTime = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(DateTime.now().year - 20),
                          lastDate: DateTime(DateTime.now().year + 20),
                        );
                        if (newDateTime != null) {
                          setState(() {
                            selectedRequirementDate = DateFormat('dd MMM yyyy')
                                .format(newDateTime)
                                .toString();

                            String dateStart = '$selectedRequirementDate';
                            DateFormat inputFormat = DateFormat('dd MMM yyyy');
                            DateTime input = inputFormat.parse(dateStart);
                            String dateRequired =
                                DateFormat('dd-MM-yyyy').format(input);

                            for (var i = 0; i < arrayList.length; i++) {
                              setState(() {
                                arrayList[i].casting_date = dateRequired;
                              });
                            }
                          });
                        }
                      }
                    : () async {},
                child: TextField(
                  enabled: false,
                  controller:
                      TextEditingController(text: selectedRequirementDate),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.accountFont(15.0, mobile: 12.6)),
                  decoration: InputDecoration(
                      suffixIcon:
                          const Icon(Icons.calendar_month_outlined, size: 19),
                      suffixIconConstraints: const BoxConstraints(minWidth: 24),
                      labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: context.accountFont(15.0, mobile: 12.6)),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: widget.poId == 'Verified' ? 6 : (context.accountCompact ? 10.8 : 12)),
                      border: InputBorder.none,
                      hintText: 'Select Requirement Date'),
                  onChanged: (text) {
                    setState(() {
                      //fullName = text;
                      //you can access nameController in its scope to get
                      // the value of text entered as shown below
                      //fullName = nameController.text;
                    });
                  },
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _quantityUnit(int index) {
    // _txtControllerQuantity.add(TextEditingController());
    // _txtControllerQuantity[index].text = arrayList[index].quantity.toString();

    final controller = arrayList[index].editingControllerQuantity ??=
        TextEditingController(text: arrayList[index].quantity.toString());
    if (controller.text != arrayList[index].quantity.toString()) {
      controller.text = arrayList[index].quantity.toString();
    }
    final canEdit = !flagBtnHideApproveReject ||
        widget.poId == 'Verified';
    return _poFormRow(
      'Quantity',
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.accountCompact ? 100 : 230,
          height: widget.poId == 'Verified' ? _poFieldHeight : 40,
          child: Padding(
            padding: EdgeInsets.only(top: widget.poId == 'Verified' ? 6 : 15),
            child: Text('Quantity',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: context.accountFont(15, mobile: 14),
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: _poFieldHeight,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8.0))),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 0, bottom: 0),
              child: TextField(
                enabled: canEdit,
                controller: controller,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: context.accountFont(15, mobile: 14)),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: widget.poId == 'Verified' ? 6 : 12),
                    border: InputBorder.none,
                    hintText: 'Enter Quantity'),
                onChanged: (String str) {
                  setState(() {
                    arrayList[index].quantity = str;
                    if (arrayList[index].unit_price.toString() != '' &&
                        arrayList[index].quantity.toString() != '') {
                      var amount =
                          ((double.parse(arrayList[index].quantity.toString()) *
                                  double.parse(
                                      arrayList[index].unit_price.toString())))
                              .toStringAsFixed(2);
                      arrayList[index].total_amount = amount;
                    } else {
                      arrayList[index].total_amount = '';
                    }
                  });
                },
              ),
            ),
          ),
        ),
        horizontalSpaceMedium,
        Expanded(
          child: Container(
            height: widget.poId == 'Verified' ? _poFieldHeight : null,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8.0))),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: useAccountManagementTestData
                  ? _previewUnitField(index, canEdit)
                  : SearchChoices.single(
                icon: Icon(widget.poId == 'Verified' ? Icons.keyboard_arrow_down : Icons.arrow_drop_down),
                iconSize: context.accountCompact ? 18 : 24,
                style: TextStyle(
                    fontSize: context.accountFont(15.0, mobile: 12.6),
                    color: Colors.black),
                items: unitItems,
                value: arrayList[index].casting_unit_name.toString(),
                hint: "Select Unit Type",
                searchHint: "Select Unit Type",
                readOnly: !canEdit,
                onTap: () {
                  if (kDebugMode) {
                    print('OnTapped');
                  }
                  selectedRequirementTypeId =
                      arrayList[index].grade_id.toString();
                  if (selectedRequirementTypeId != "") {
                    fetchGradeDescription();
                  }
                },
                onChanged: (value1) {
                  setState(() {
                    //if (index == int.parse(arrayList[index]["id"].toString())) {
                    arrayList[index].casting_unit_name = value1;
                    for (var i = 0; i < finishingUnit!.length; i++) {
                      if (finishingUnit![i].unitName == value1) {
                        arrayList[index].casting_unit =
                            finishingUnit![i].unitId ?? '';
                        break;
                      }
                    }
                    //}
                  });
                },
                padding: 0.0,
                //padding: arrayList[index]["wo_unit"].toString() == '' ? 10.0 : 0.0,
                dialogBox: false,
                isExpanded: true,
                menuConstraints:
                    BoxConstraints.tight(const Size.fromHeight(350)),
                onClear: () {
                  setState(() {
                    arrayList[index].casting_unit_name = '';
                    arrayList[index].casting_unit = '';
                  });
                  if (kDebugMode) {
                    print(arrayList);
                  }
                },
                underline: const SizedBox(height: 0.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Demonstration units are local to this screen and never persisted.
  final List<String> _previewUnitNames = ['MT', 'Kg', 'Nos', 'Bags', 'Cu.m', 'Sq.m'];

  Widget _previewUnitField(int index, bool canEdit) => InkWell(
        onTap: canEdit ? () => _showPreviewUnits(index) : null,
        child: SizedBox(
          height: _poFieldHeight,
          child: Row(children: [
            Expanded(child: Text(
                arrayList[index].casting_unit_name.toString().isEmpty
                    ? 'Select Unit Type'
                    : arrayList[index].casting_unit_name.toString(),
                style: TextStyle(fontSize: context.accountCompact ? 12.6 : 15),
                overflow: TextOverflow.ellipsis)),
            Icon(widget.poId == 'Verified' ? Icons.keyboard_arrow_down : Icons.arrow_drop_down,
                size: context.accountCompact ? 18 : 24),
          ]),
        ),
      );

  Future<void> _showPreviewUnits(int index) async {
    var query = '';
    await _showPoDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, updateDialog) {
          final names = {
            if (arrayList[index].casting_unit_name.toString().isNotEmpty)
              arrayList[index].casting_unit_name.toString(),
            ..._previewUnitNames,
          }.where((name) => name.toLowerCase().contains(query.toLowerCase())).toList();
          return AlertDialog(
            clipBehavior: Clip.antiAlias,
            constraints: BoxConstraints.tightFor(
                width: context.accountCompact
                    ? (MediaQuery.sizeOf(dialogContext).width - 32).clamp(0.0, 368.0) * 0.8
                    : (MediaQuery.sizeOf(dialogContext).width * 0.32).clamp(360.0, 520.0)),
            titlePadding: EdgeInsets.zero,
            contentPadding: const EdgeInsets.all(12),
            actionsPadding: const EdgeInsets.fromLTRB(10, 6, 10, 12),
            title: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.black,
              child: const Text('Select Unit Type',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ),
            content: SizedBox(
              width: 256,
              height: (MediaQuery.sizeOf(dialogContext).height * 0.45)
                  .clamp(180.0, 360.0) * 0.8,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Sample units · preview only',
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 8),
                TextField(
                  decoration: _poPopupSearchDecoration('Search units').copyWith(
                      fillColor: Colors.white),
                  onChanged: (value) => updateDialog(() => query = value),
                ),
                Expanded(child: Material(
                  color: Colors.white,
                  child: ListView(children: [
                  for (final name in names)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: _poPopupRowDecoration(arrayList[index].casting_unit_name == name),
                      child: Material(type: MaterialType.transparency, child: ListTile(
                      dense: true,
                      minVerticalPadding: 5,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                      title: Text(name, textAlign: TextAlign.left, style: normalText),
                      trailing: Icon(
                          arrayList[index].casting_unit_name == name
                              ? Icons.check_circle_outline_outlined : Icons.circle_outlined,
                          size: 25,
                          color: arrayList[index].casting_unit_name == name ? Colors.green : Colors.grey),
                      onTap: () {
                        setState(() {
                          if (arrayList[index].casting_unit_name != name) {
                            arrayList[index].casting_unit_name = name;
                            arrayList[index].casting_unit =
                                'preview-unit-${_previewUnitNames.indexOf(name)}';
                          }
                        });
                        Navigator.pop(dialogContext);
                      },
                    ))),
                  ListTile(
                    dense: true,
                    minVerticalPadding: 5,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                    title: const Text('Clear unit'),
                    onTap: () {
                      setState(() {
                        arrayList[index].casting_unit_name = '';
                        arrayList[index].casting_unit = '';
                      });
                      Navigator.pop(dialogContext);
                    },
                  ),
                ]))),
              ]),
            ),
            actions: [
              Row(children: [
                Expanded(child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      shape: const StadiumBorder()),
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('CLOSE', style: TextStyle(fontSize: 12)))),
                Expanded(child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      shape: const StadiumBorder()),
                  onPressed: () async {
                    final name = await _addPreviewUnit();
                    if (name == null || !mounted || !dialogContext.mounted) return;
                    updateDialog(() {
                      if (!_previewUnitNames.any((unit) =>
                          unit.toLowerCase() == name.toLowerCase())) {
                        _previewUnitNames.add(name);
                      }
                    });
                  },
                  child: const FittedBox(fit: BoxFit.scaleDown,
                      child: Text('ADD CUSTOM UNIT', style: TextStyle(fontSize: 12))))),
              ]),
            ],
          );
        },
      ),
    );
  }

  Future<String?> _addPreviewUnit() async {
    var unitName = '';
    final formKey = GlobalKey<FormState>();
    final result = await _showPoDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        clipBehavior: Clip.antiAlias,
        constraints: BoxConstraints.tightFor(
            width: context.accountCompact
                ? (MediaQuery.sizeOf(dialogContext).width - 32).clamp(0.0, 368.0) * 0.8
                : (MediaQuery.sizeOf(dialogContext).width * 0.32).clamp(360.0, 520.0)),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.all(12),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: Colors.black,
          child: const Text('Add Custom Unit',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 15,
                  fontWeight: FontWeight.w600)),
        ),
        content: Form(key: formKey, child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Preview only · saved locally for this screen',
                style: TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 12),
            TextFormField(
              onChanged: (value) => unitName = value,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Enter custom unit',
                filled: true,
                fillColor: const Color(0xfff1f3f5),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a unit name' : null,
            ),
          ],
        )),
        actions: [
          Row(children: [
          Expanded(child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  shape: const StadiumBorder()),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCEL', style: TextStyle(fontSize: 12)))),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  shape: const StadiumBorder()),
              onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(dialogContext, unitName.trim());
            }
          }, child: const Text('ADD', style: TextStyle(fontSize: 12)))),
          ]),
        ],
      ),
    );
    return result;
  }

  Widget _selecteBrand(int index) {
    // arrayList[index].editingControllerBrandName?.text =
    //     arrayList[index].brandType;
    // arrayList[index].editingControllerDescription?.text =
    return _poFormRow(
      'Brand',
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.accountCompact ? 100 : 230.0,
          height: widget.poId == 'Verified' ? _poFieldHeight : 40,
          child: Padding(
            padding: EdgeInsets.only(top: widget.poId == 'Verified' ? 6 : 15),
            child: Text('Brand',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: context.accountFont(15, mobile: 14),
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            color: kcTextFieldColor,
            // height: _poFieldHeight,
            // decoration: BoxDecoration(
            //     color: kcTextFieldColor,
            //     border: Border.all(color: Colors.grey),
            //     borderRadius: const BorderRadius.all(Radius.circular(8.0))),
            child: TextFormField(
              onChanged: (value) {
                arrayList[index].brand_supplier_name = value;
              },
              controller: arrayList[index].editingControllerBrandName,
              // enabled: false,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.accountFont(15.0, mobile: 12.6)),
              decoration: InputDecoration(
                  disabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF5F5C5C)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: (Color(0xFF5F5C5C)),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: (Color(0xFF5F5C5C)),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: (Color(0xFF5F5C5C)),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: (Colors.grey),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: context.accountCompact ? 9 : 10,
                      vertical: widget.poId == 'Verified' ? 6 : (context.accountCompact ? 9 : 10)),
                  // border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 116, 116, 116),
                    fontSize: context.accountFont(15.0, mobile: 12.6),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'HelveticaNeue',
                  ),
                  hintText: 'Enter Brand Name'),
            ),
          ),
        )
      ],
    );
  }

  Widget _unitPrice(int index) {
    // _txtControllerUnitPrice.add(TextEditingController());
    // _txtControllerUnitPrice[index].text =
    //     arrayList[index].unit_price.toString();
    final controller = arrayList[index].editingControllerUnitPrice ??=
        TextEditingController(text: arrayList[index].unit_price.toString());
    if (controller.text != arrayList[index].unit_price.toString()) {
      controller.text = arrayList[index].unit_price.toString();
    }
    return _poFormRow(
      'Unit Price (₹)',
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.accountCompact ? 100 : 230,
          height: widget.poId == 'Verified' ? _poFieldHeight : 40,
          child: Padding(
            padding: EdgeInsets.only(top: widget.poId == 'Verified' ? 6 : 15),
            child: Text('Unit Price',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: context.accountFont(15, mobile: 14),
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: _poFieldHeight,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8.0))),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 0, bottom: 0),
              child: TextField(
                enabled: !flagBtnHideApproveReject || widget.poId == 'Verified',
                controller: controller,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: context.accountFont(15, mobile: 14)),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: widget.poId == 'Verified' ? 6 : 12),
                    border: InputBorder.none,
                    hintText: 'Enter Unit Price (Optional)'),
                onChanged: (String str) {
                  setState(() {
                    arrayList[index].unit_price = str;
                    if (arrayList[index].unit_price.toString() != '' &&
                        arrayList[index].quantity.toString() != '') {
                      var amount =
                          ((double.parse(arrayList[index].quantity.toString()) *
                                  double.parse(
                                      arrayList[index].unit_price.toString())))
                              .toStringAsFixed(2);
                      arrayList[index].total_amount = amount;
                    } else {
                      arrayList[index].total_amount = '';
                    }
                  });
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _totalPrice(int index) {
    // _txtControllerTotalPrice.add(TextEditingController());
    // _txtControllerTotalPrice[index].text =
    //     arrayList[index].total_amount.toString();
    arrayList[index].editingControllerTotalAmount?.text =
        arrayList[index].total_amount.toString();
    return _poFormRow(
      'Total Price (₹)',
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.accountCompact ? 100 : 230,
          height: widget.poId == 'Verified' ? _poFieldHeight : 40,
          child: Padding(
            padding: EdgeInsets.only(top: widget.poId == 'Verified' ? 6 : 15),
            child: Text('Total Price',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: context.accountFont(15, mobile: 14),
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: _poFieldHeight,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8.0))),
            child: TextField(
              controller: TextEditingController.fromValue(TextEditingValue(
                  text: arrayList[index].total_amount.toString(),
                  selection: TextSelection.collapsed(
                      offset: arrayList[index].total_amount.length))),
              readOnly: true,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.accountFont(15, mobile: 12.6)),
              decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: widget.poId == 'Verified' ? 6 : (context.accountCompact ? 13.5 : 15), horizontal: 15),
                  border: InputBorder.none,
                  filled: false,
                  hintText: 'Total Price'),
              onChanged: (String str) {
                arrayList[index].total_amount = str;
              },
            ),
          ),
        )
      ],
    );
  }
}
