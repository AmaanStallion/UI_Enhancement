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
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import '../../../models/get_po_details_by_status.dart';
import '../../../models/get_po_requistion_vendor_list.dart';
import '../../../models/get_purchase_order_default_request.dart';
import '../../../models/grade_description.dart';
import '../../../models/message_success.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import '../../widgets/simple_button.dart';
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
    CustomLoading.progressDialog(isLoading: true, context: context);
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
      CustomLoading.progressDialog(isLoading: false, context: context);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } else {
      CustomLoading.progressDialog(isLoading: false, context: context);
    }
    // return null;
  }

  Future<AssingToList?> setPoVerifyFlag({
    required String isCheck,
  }) async {
    CustomLoading.progressDialog(isLoading: true, context: context);
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
      CustomLoading.progressDialog(isLoading: false, context: context);

      Navigator.of(context).pop();
      showDialog<String>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Set radius to zero
                ),
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
                      fontSize: 18,
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
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'OK',
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
              ));
      // Navigator.of(context).pop();
    } else {
      CustomLoading.progressDialog(isLoading: false, context: context);
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
                  "Are you sure you want to assign this PO?",
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
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        setPoAssignTo();
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

        slabDetails = dataModel.response?.slabDetails;
        slabDetailsOriginal = dataModel.response?.slabDetails;

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
        showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: const Text('Purchase Order'),
                  content: const Text('Request status updated successfully.',
                      style: TextStyle(
                          fontStyle: FontStyle.normal, fontSize: 17.0)),
                  actions: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          fixedSize: const Size.fromWidth(100),
                          padding: const EdgeInsets.all(10),
                          textStyle: const TextStyle(color: Colors.white)),
                      child: const Text('CLOSE',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                              color: Colors.white)),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ],
                ));
      });
    } else {
      // Navigator.pop(dialogContext);
      Future.delayed(Duration.zero).then((_) {
        Navigator.pop(dialogContext);
        showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: const Text('Purchase Order'),
                  content: const Text('Invalid Input.',
                      style: TextStyle(
                          fontStyle: FontStyle.normal, fontSize: 17.0)),
                  actions: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          fixedSize: const Size.fromWidth(100),
                          padding: const EdgeInsets.all(10),
                          textStyle: const TextStyle(color: Colors.white)),
                      child: const Text('CLOSE',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                              color: Colors.white)),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                          // Navigator.pop(context);
                        });
                      },
                    ),
                  ],
                ));
      });
    }
    // CustomLoading.progressDialog(isLoading: false, context: context11);
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
  //         showDialog<String>(
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
          showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: const Text('Purchase Order'),
                    content: const Text('Request status updated successfully.',
                        style: TextStyle(
                            fontStyle: FontStyle.normal, fontSize: 17.0)),
                    actions: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            fixedSize: const Size.fromWidth(100),
                            padding: const EdgeInsets.all(10),
                            textStyle: const TextStyle(color: Colors.white)),
                        child: const Text('CLOSE',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0,
                                color: Colors.white)),
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          });
                        },
                      ),
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
          showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: const Text('PO Vendor Quote'),
                    content: const Text(
                        'Request for Quote is being send successfully.',
                        style: TextStyle(
                            fontStyle: FontStyle.normal, fontSize: 17.0)),
                    actions: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            fixedSize: const Size.fromWidth(100),
                            padding: const EdgeInsets.all(10),
                            textStyle: const TextStyle(color: Colors.white)),
                        child: const Text('CLOSE',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0,
                                color: Colors.white)),
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                            Navigator.maybePop(context);
                          });
                        },
                      ),
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
                  "Select Assign To",
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
                          'SUBMIT',
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
                          hintText: 'Search',
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
                      for (int i = 0; i < filteredAssignTo()!.length; i++)
                        InkWell(
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
                                  filteredAssignTo()?[i].transEmpName ?? '',
                                  style: const TextStyle(
                                    fontSize: 19,
                                  ),
                                ),
                                Icon(
                                  // filteredAssignTo()?[i].isSelected == true
                                  selectedAssignToId ==
                                          filteredAssignTo()?[i].transEmpId
                                      ? Icons.check_circle_outline_outlined
                                      : Icons.circle_outlined,
                                  color:
                                      // filteredAssignTo()?[i].isSelected == true
                                      selectedAssignToId ==
                                              filteredAssignTo()?[i].transEmpId
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
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text('${widget.projectName!.toUpperCase()} - PO ASSIGNED',
              style:
                  const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.maybePop(context);
              })),
      body: flagcalled == true
          ? SingleChildScrollView(
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Row(
                    children: [
                      const SizedBox(width: 90),
                      const Spacer(),
                      const Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Text('PO DETAILS'),
                      ),
                      const Spacer(),
                      InkWell(
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
                                  orderId: widget.orderDetails?.orderId ?? '',
                                  poNo: widget.orderDetails?.poNo ?? '',
                                );
                              },
                            ),
                          ).then((_) => {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 5),
                          decoration: BoxDecoration(
                            // border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black12,
                          ),
                          child: const Text(
                            "VIEW PO",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Colors.black,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        verticalSpaceSmall,
                        const Text(
                          'P.O. No.',
                          style: normalText,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.orderDetails!.poNo!,
                          style: boldText,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Text(
                          'P.O. Status',
                          style: normalText,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.orderDetails!.poStatus! == '0'
                              ? 'Pendng'
                              : widget.orderDetails!.poStatus! == '1'
                                  ? 'Assigned'
                                  : widget.orderDetails!.poStatus! == '2'
                                      ? 'Issued'
                                      : widget.orderDetails!.poStatus! == '3'
                                          ? 'Dispute'
                                          : '---',
                          style: boldText,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Text(
                          'Slab No',
                          style: normalText,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.orderDetails!.slabName!,
                          style: boldText,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Booking Type',
                          style: normalText,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.orderDetails!.gradeName!,
                          style: boldText,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Text(
                          'Project Name',
                          style: normalText,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.orderDetails!.projectName!,
                          style: boldText,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Text(
                          'Requested By',
                          style: normalText,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.orderDetails!.raisedBy!,
                          style: boldText,
                        ),
                      ],
                    ),
                  ],
                ),
                verticalSpaceSmall,
                const Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Colors.black,
                ),
                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    //controller: _controller,
                    shrinkWrap: true,
                    reverse: false,
                    itemCount: arrayList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 40.0, right: 40.0, bottom: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                index != 0
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            iconSize: 30,
                                            icon: const Icon(
                                              Icons.close_rounded,
                                            ),
                                            color: Colors.black,
                                            onPressed: () {
                                              setState(() {
                                                arrayList.removeAt(index);
                                              });
                                            },
                                          ),
                                        ],
                                      )
                                    : const SizedBox(height: 20),
                                _requirementType(index),
                                verticalSpaceSmall15,
                                _description(index),
                                verticalSpaceSmall15,
                                _selecteBrand(index),
                                verticalSpaceSmall15,
                                _requirementFor(index),
                                verticalSpaceSmall15,
                                _selectedReqDate(index),
                                verticalSpaceSmall15,
                                _quantityUnit(index),
                                verticalSpaceSmall15,
                                _unitPrice(index),
                                verticalSpaceSmall15,
                                _totalPrice(index),
                                verticalSpaceSmall15,
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Upload", style: TextStyle(fontSize: 14)), //
                      Row(
                        children: [
                          InkWell(
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
                                Uint8List? fileBytes = result.files.first.bytes;
                                String fileName = result.files.first.name;
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
                              height: 100,
                              width: 100,
                            ),
                          ),
                          const SizedBox(width: 10),
                          for (int j = 0;
                              j < widget.orderDetails!.poDocument!.length;
                              j++)
                            Row(
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
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        (useAccountManagementTestData
                                            ? const Icon(
                                                Icons.description_outlined,
                                                size: 48,
                                                color: Colors.black54)
                                            : Image.network(
                                                '${AppUrl.poDocPath}${widget.orderDetails!.poDocument?[j]}',
                                                // ),
                                                // File(widget
                                                //     .orderDetails!.poDocument![j]),
                                                height: 100,
                                                width: 100,
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
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        InkWell(
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
                                                  BorderRadius.circular(6),
                                            ),
                                            // width: 100,
                                            child: Image.asset(
                                              'images/projectmanagement/pdf.png',
                                              width: 100,
                                              height: 100,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: -10,
                                          top: -10,
                                          child: InkWell(
                                            onTap: () {
                                              // setState(() {
                                              //   arrayFiles
                                              //       .remove(arrayFiles[j]);
                                              //   arrayFilesBytes
                                              //       .remove(arrayFilesBytes[j]);
                                              // });
                                            },
                                            child: const Icon(Icons.close),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          const SizedBox(width: 10),
                          for (int j = 0; j < arrayFiles.length; j++)
                            Row(
                              children: [
                                if (arrayFiles[j].extension == 'jpg' ||
                                    arrayFiles[j].extension == 'jpeg' ||
                                    arrayFiles[j].extension ==
                                        'png') //'jpg','jpeg','png',
                                  Container(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Image.file(
                                          File(arrayFiles[j].path ?? ''),
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.fill,
                                        ),
                                        Positioned(
                                          right: -10,
                                          top: -10,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                arrayFiles
                                                    .remove(arrayFiles[j]);
                                                arrayFilesBytes
                                                    .remove(arrayFilesBytes[j]);
                                              });
                                            },
                                            child: const Icon(Icons.close),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                if (arrayFiles[j].extension == 'pdf')
                                  Container(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        InkWell(
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
                                                              arrayFiles[j]
                                                                  .path,
                                                          fileName:
                                                              arrayFiles[j]
                                                                  .name,
                                                          fileUrl: arrayFiles[j]
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
                                                  BorderRadius.circular(6),
                                            ),
                                            // width: 100,
                                            child: Image.asset(
                                              'images/projectmanagement/pdf.png',
                                              width: 100,
                                              height: 100,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: -10,
                                          top: -10,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                arrayFiles
                                                    .remove(arrayFiles[j]);
                                                arrayFilesBytes
                                                    .remove(arrayFilesBytes[j]);
                                              });
                                            },
                                            child: const Icon(Icons.close),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                verticalSpaceSmall,
                Padding(
                  padding: const EdgeInsets.only(left: 100.0, right: 70.0),
                  child: SizedBox(
                      child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 150,
                            child: Text('Other Remarks', style: normalText),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 40, right: 10, top: 10),
                              child: SizedBox(
                                // height: 50,
                                child: TextFormField(
                                  enabled: flagBtnHideApproveReject == false
                                      ? true
                                      : false,
                                  controller: _txtControllerRemark,
                                  maxLines: 3,
                                  onChanged: (String str) {
                                    strRemark = str;
                                  },
                                  style: normalText,
                                  decoration: InputDecoration(
                                      hintText: 'Enter Other Remarks',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: const BorderSide(
                                              color: Colors.black))),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      verticalSpaceSmall,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          flagBtnHideApproveReject == false
                              ? InkWell(
                                  onTap: () {
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
                                        casting_date:
                                            arrayList[arrayList.length - 1]
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
                                              const EdgeInsets.only(top: 0.0),
                                          image: Image.asset(
                                              'images/Icon-512.png',
                                              height: 80,
                                              fit: BoxFit.fitWidth),
                                          style: const AlertStyle(
                                              titleTextAlign: TextAlign.center,
                                              descTextAlign: TextAlign.center,
                                              descStyle: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16),
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
                                              child: const Text(
                                                "CLOSE",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15),
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
                                        left: 20, right: 20, top: 9, bottom: 9),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(28),
                                        border:
                                            Border.all(color: Colors.black)),
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

                              showDialog(
                                  context: context,
                                  // barrierDismissible: false,
                                  builder: (context) {
                                    return StatefulBuilder(
                                        builder: (context1, setState2) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8), // Set radius to zero
                                        ),
                                        titlePadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 0),
                                        actionsPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 0),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16),
                                        actionsAlignment:
                                            MainAxisAlignment.center,
                                        title: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            "Are you sure, You want to ${isChecked ? 'uncheck' : 'check'} this PO?",
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
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      // bottomRight: Radius.circular(8),
                                                      bottomLeft:
                                                          Radius.circular(8),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'NO',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 1),
                                              InkWell(
                                                onTap: () {
                                                  // setPoAssignTo();
                                                  setPoVerifyFlag(
                                                      isCheck: isChecked
                                                          ? "0"
                                                          : "1");
                                                },
                                                child: Container(
                                                  width: 170,
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomRight:
                                                          Radius.circular(8),
                                                      // bottomLeft: Radius.circular(8),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'YES',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: 20, right: 20, top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    isChecked
                                        ? Icons.check_box_outlined
                                        : Icons.check_box_outline_blank,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 14),
                                  Text(
                                    isChecked ? "Checked" : "Check",
                                    style: boldText,
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
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: Row(
        children: [
          flagBtnHideApproveReject == false
              ? Expanded(
                  child: GestureDetector(
                      onTap: () {
                        showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Purchase Order'),
                                  content: const Text(
                                      'Are you sure you want to reject purchase order?',
                                      style: TextStyle(
                                          fontStyle: FontStyle.normal,
                                          fontSize: 17.0)),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          fixedSize: const Size.fromWidth(100),
                                          padding: const EdgeInsets.all(10),
                                          textStyle: const TextStyle(
                                              color: Colors.white)),
                                      child: const Text('NO',
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16.0,
                                              color: Colors.white)),
                                      onPressed: () {
                                        setState(() {
                                          Navigator.pop(context);
                                        });
                                      },
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          fixedSize: const Size.fromWidth(100),
                                          padding: const EdgeInsets.all(10),
                                          textStyle: const TextStyle(
                                              color: Colors.white)),
                                      child: const Text('YES',
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14.0,
                                              color: Colors.white)),
                                      onPressed: () {
                                        setState(() {
                                          Navigator.pop(context);

                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              dialogContext = context;
                                              return const Center(
                                                child: SizedBox(
                                                  height: 200,
                                                  width: 200,
                                                  child: Dialog(
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
                                    ),
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
                          } else if (arrayList[i].description.toString() ==
                              "") {
                            msg = 'Please enter description.';
                            flag = false;
                          } else if (arrayList[i].casting_for.toString() ==
                              "") {
                            msg = 'Please enter requirement for.';
                            flag = false;
                          } else if (arrayList[i].casting_date.toString() ==
                              "") {
                            msg = 'Please select requirement date.';
                            flag = false;
                          } else if (arrayList[i].quantity.toString() == "") {
                            msg = 'Please enter a quantity.';
                            flag = false;
                          } else if (arrayList[i].casting_unit.toString() ==
                              "") {
                            msg = 'Please select unit.';
                            flag = false;
                          }
                        }
                        print(jsonEncode(arrayList));
                        if (flag == false) {
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: const Text(''),
                                    content: Text(msg,
                                        style: const TextStyle(
                                            fontStyle: FontStyle.normal,
                                            fontSize: 17.0)),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            fixedSize:
                                                const Size.fromWidth(100),
                                            padding: const EdgeInsets.all(10),
                                            textStyle: const TextStyle(
                                                color: Colors.white)),
                                        child: const Text('CLOSE',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14.0,
                                                color: Colors.white)),
                                        onPressed: () {
                                          setState(() {
                                            Navigator.pop(context);
                                          });
                                        },
                                      ),
                                    ],
                                  ));
                        } else {
                          bool isSame = false;
                          for (var i = 0; i < arrayList.length; i++) {
                            for (int k = i + 1; k < arrayList.length; k++) {
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
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                      elevation: 0,
                                      shadowColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8), // Set radius to zero
                                      ),
                                      titlePadding: const EdgeInsets.symmetric(
                                          vertical: 0),
                                      actionsPadding:
                                          const EdgeInsets.only(bottom: 0),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 0),
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      title: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        decoration: const BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                topRight: Radius.circular(8))),
                                        child: const Text(
                                          "Are you Sure, You want to Update an Order?",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      // title: const Text('Purchase Order'),
                                      content: Container(
                                        height: 100,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Credit Limit",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            SizedBox(width: 14),
                                            Container(
                                              width: 200,
                                              child: TextFormField(
                                                controller: creditControler,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13.0),
                                                decoration:
                                                    const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.all(12.0),
                                                  border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black)),
                                                  hintText:
                                                      'Enter Credit Limit',
                                                  hintStyle: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 116, 116, 116),
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.w200,
                                                    fontFamily: 'HelveticaNeue',
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 14),
                                            Text(
                                              "Days",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            )
                                          ],
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
                                                width: 180,
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                child: const Text(
                                                  "NO",
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
                                                setState(() {
                                                  Navigator.pop(context);

                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder:
                                                        (BuildContext context) {
                                                      dialogContext = context;
                                                      return const Center(
                                                        child: SizedBox(
                                                          height: 200,
                                                          width: 200,
                                                          child: Dialog(
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
                                                  submitOkToOrderPurchaseOrder(
                                                      context);
                                                });
                                              },
                                              child: Container(
                                                width: 180,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                decoration: const BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomRight:
                                                                Radius.circular(
                                                                    8))),
                                                child: const Text(
                                                  "YES",
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
                                image: Image.asset('images/Icon-512.png',
                                    height: 80, fit: BoxFit.fitWidth),
                                style: const AlertStyle(
                                    titleTextAlign: TextAlign.center,
                                    descTextAlign: TextAlign.center,
                                    descStyle: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16),
                                    isCloseButton: true),
                                context: context,
                                desc: 'Entered Description is Already Added',
                                alertAnimation: fadeAlertAnimation,
                                buttons: [
                                  DialogButton(
                                    onPressed: () => Navigator.pop(context),
                                    color: Colors.black,
                                    child: const Text(
                                      "CLOSE",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
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
                      child: InkWell(
                        onTap: () {
                          if (
                              // (widget.orderDetails?.poAssingTo == "0" ||
                              //       widget.orderDetails?.poAssingTo == "") &&
                              purchaseUserTrack != '0') {
                            chooseAssignToModal();
                          }
                        },
                        child: Container(
                            padding: const EdgeInsets.only(top: 13),
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Colors.white),
                              ),
                              color:
                                  // (
                                  //   widget.orderDetails?.poAssingTo == "0" ||
                                  //             widget.orderDetails?.poAssingTo ==
                                  //                 "") &&
                                  purchaseUserTrack != '0'
                                      ? Colors.black
                                      : Colors.grey,
                            ),
                            child: const Text(
                              'ASSIGN TO',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            )),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          showDialog(
                              // barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) =>
                                  StatefulBuilder(builder: (context, setState) {
                                    return Dialog(
                                      elevation: 0,
                                      child: SizedBox(
                                        height: 400,
                                        width: 360.0,
                                        child: Column(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                  top: 10.0, bottom: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'SELECT VENDOR',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Divider(
                                              color: Colors.grey.shade500,
                                              thickness: 1.5,
                                            ),
                                            SizedBox(
                                              height: 300,
                                              width: 360,
                                              child: ListView.builder(
                                                  itemCount: searchData!.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    bool selected = false;
                                                    if (searchData![index]
                                                            .sendStatus! ==
                                                        '0') {
                                                      String vendorId =
                                                          searchData![index]
                                                              .selectId!;
                                                      for (int i = 0;
                                                          i <
                                                              searchDataSelected
                                                                  .length;
                                                          i++) {
                                                        if (vendorId ==
                                                            searchDataSelected[
                                                                        i][
                                                                    "vendor_id"]
                                                                .toString()) {
                                                          selected = true;
                                                          break;
                                                        }
                                                      }
                                                    }
                                                    return Column(
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            bool flag = false;
                                                            String vendorId =
                                                                searchData![
                                                                        index]
                                                                    .selectId!;
                                                            for (int i = 0;
                                                                i <
                                                                    searchDataSelected
                                                                        .length;
                                                                i++) {
                                                              if (vendorId ==
                                                                  searchDataSelected[
                                                                              i]
                                                                          [
                                                                          "vendor_id"]
                                                                      .toString()) {
                                                                if (searchData![
                                                                            index]
                                                                        .sendStatus! ==
                                                                    '0') {
                                                                  searchDataSelected
                                                                      .removeAt(
                                                                          i);
                                                                  setState(() {
                                                                    searchData
                                                                        ?.length;
                                                                  });
                                                                  flag = true;
                                                                  break;
                                                                }
                                                              }
                                                            }
                                                            if (flag == false) {
                                                              if (searchData![
                                                                          index]
                                                                      .sendStatus! ==
                                                                  '0') {
                                                                Map<String,
                                                                        String>
                                                                    data = {
                                                                  "vendor_id":
                                                                      searchData![
                                                                              index]
                                                                          .selectId!,
                                                                };
                                                                searchDataSelected
                                                                    .add(data);
                                                                setState(() {
                                                                  searchData
                                                                      ?.length;
                                                                });
                                                              } else {
                                                                showDialog<
                                                                        String>(
                                                                    context:
                                                                        context,
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        AlertDialog(
                                                                          title:
                                                                              const Text(''),
                                                                          content: const Text(
                                                                              'Already PO Quote is being send.',
                                                                              style: TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
                                                                          actions: <Widget>[
                                                                            ElevatedButton(
                                                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, fixedSize: const Size.fromWidth(100), padding: const EdgeInsets.all(10), textStyle: const TextStyle(color: Colors.white)),
                                                                              child: const Text('CLOSE', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14.0, color: Colors.white)),
                                                                              onPressed: () {
                                                                                setState(() {
                                                                                  Navigator.pop(context);
                                                                                });
                                                                              },
                                                                            ),
                                                                          ],
                                                                        ));
                                                              }
                                                            }
                                                            //Navigator.of(
                                                            // context)
                                                            //.pop();
                                                          },
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          10.0,
                                                                      bottom:
                                                                          20.0,
                                                                      top:
                                                                          15.0),
                                                                  child: Text(searchData![
                                                                          index]
                                                                      .selectName!),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              10.0),
                                                                  child: Icon(
                                                                    searchData![index].sendStatus! ==
                                                                            "1"
                                                                        ? Icons
                                                                            .check_circle_outline_sharp
                                                                        : selected ==
                                                                                true
                                                                            ? Icons.check_circle_outline_sharp
                                                                            : Icons.circle_outlined,
                                                                    color: searchData![index].sendStatus! ==
                                                                            "1"
                                                                        ? Colors
                                                                            .grey
                                                                        : selected ==
                                                                                true
                                                                            ? Colors.green
                                                                            : Colors.black,
                                                                    size: 26,
                                                                  ),
                                                                ),
                                                              ]),
                                                        ),
                                                        const Divider(
                                                          height: 1,
                                                          thickness: 0.5,
                                                          color: Colors.black,
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                            ),
                                            Expanded(
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.of(context).pop();

                                                  showDialog(
                                                    context: context,
                                                    // barrierDismissible: false,
                                                    builder:
                                                        (BuildContext context) {
                                                      dialogContext = context;
                                                      return const Center(
                                                        child: SizedBox(
                                                          height: 200,
                                                          width: 200,
                                                          child: Dialog(
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

                                                  submitPurchaseOrderRequestion();
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  color: Colors.black,
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 13.0),
                                                    child: Text(
                                                      'REQUEST QUOTE',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }));
                        },
                        child: Container(
                            padding: const EdgeInsets.only(top: 13),
                            height: 50,
                            color: Colors.black,
                            child: const Text(
                              'GET VENDOR QUOTE',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            )),
                      ),
                    ),
                  ],
                ))
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget _requirementType(int indexRow) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Requirement Type',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
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
        //         borderRadius: const BorderRadius.all(Radius.circular(5.0))),
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
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // Set radius to zero
                    ),
                    titlePadding: EdgeInsets.zero,
                    actionsPadding: EdgeInsets.zero,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10),
                    title: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: const BoxDecoration(
                          // color: Colors.black,
                          // border:
                          //     Border(bottom: BorderSide(color: Colors.black54)),
                          borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      )),
                      child: const Text(
                        'Select Requirement Type',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
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
                          width: 500,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              )),
                          child: const Text(
                            "OK",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState1) {
                        return Container(
                          key: formkey,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          height: 450,
                          width: 400,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                  style: const TextStyle(fontSize: 13),
                                  controller: editingController,
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.all(12.0),
                                      labelText: "Search Requirement Type",
                                      hintText: "Search Requirement Type",
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(7.0)))),
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
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5.0,
                                                        vertical: 7.0),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              finishingTypeList![
                                                                      index]
                                                                  .finishingName!,
                                                              style: normalText,
                                                            ),
                                                            Text(
                                                              'Available Vendors(${finishingTypeList![index].count!})',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontSize: 13),
                                                            ),
                                                          ],
                                                        ),
                                                        _selectedReqTypeIndex ==
                                                                null
                                                            ? const Icon(
                                                                Icons
                                                                    .circle_outlined,
                                                                size: 25,
                                                                color:
                                                                    Colors.grey,
                                                              )
                                                            : _selectedReqTypeIndex ==
                                                                    finishingTypeList![
                                                                            index]
                                                                        .finishingId
                                                                ? const Icon(
                                                                    Icons
                                                                        .circle,
                                                                    size: 25,
                                                                    color: Colors
                                                                        .green,
                                                                  )
                                                                : const Icon(
                                                                    Icons
                                                                        .circle_outlined,
                                                                    size: 25,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                      ],
                                                    ),
                                                    verticalSpaceSmall,
                                                    const Divider(
                                                        height: 1.0,
                                                        color: Colors.black),
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
                                              showDialog<void>(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
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
                                                                          borderRadius: const BorderRadius.all(Radius.circular(5.0))),
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
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 15.0),
                                                                          decoration:
                                                                              const InputDecoration(
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
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceAround,
                                                                        children: [
                                                                          Expanded(
                                                                            child: SimpleButton(
                                                                                lblText: "CLOSE",
                                                                                color: Colors.black,
                                                                                onTap: () {
                                                                                  Navigator.of(context).pop();
                                                                                }),
                                                                          ),
                                                                          horizontalSpaceSmall,
                                                                          Expanded(
                                                                            child: SimpleButton(
                                                                                lblText: "SUBMIT",
                                                                                color: Colors.black,
                                                                                onTap: () {
                                                                                  if (_txtCustomRequirementType.text.isEmpty) {
                                                                                    showDialog<void>(
                                                                                        context: context,
                                                                                        builder: (BuildContext context) {
                                                                                          return AlertDialog(
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
                                                                                                          child: SimpleButton(
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
                                                                                      showDialog<void>(
                                                                                          context: context,
                                                                                          builder: (BuildContext context) {
                                                                                            return AlertDialog(
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
                                                                                                            child: SimpleButton(
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
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'ADD CUSTOM TYPE',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 17.0,
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
                height: 45.0,
                decoration: BoxDecoration(
                    color: kcTextFieldColor,
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5.0))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: TextField(
                    // controller: _txtControllerRequirmentType[indexRow],
                    controller:
                        arrayList[indexRow].editingControllerGradeTypeName,
                    autofocus: false,
                    enabled: false,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Select Requirement Type',
                    ),
                  ),
                ),
              ),
              const Positioned(
                  right: 10,
                  child: Center(
                      child: Icon(Icons.arrow_drop_down_circle_outlined))),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _description(int index) {
    // _typeAheadController.add(TextEditingController());
    // _typeAheadController[index].text = arrayList[index].description.toString();

    arrayList[index].editingControllerDescription?.text =
        arrayList[index].description.toString();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Description / Sub type',
                style: TextStyle(
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
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: TypeAheadField<String>(
                getImmediateSuggestions: true,
                textFieldConfiguration: TextFieldConfiguration(
                  onChanged: (value) {
                    arrayList[index].description = value;
                  },
                  enabled: flagBtnHideApproveReject == false ? true : false,
                  controller: TextEditingController.fromValue(TextEditingValue(
                      text: arrayList[index].description.toString(),
                      selection: TextSelection.collapsed(
                          offset: arrayList[index].description.length))),
                  decoration:
                      const InputDecoration(hintText: 'Enter Description'),
                ),
                suggestionsCallback: (pattern) {
                  return Future.delayed(
                    const Duration(seconds: 1),
                    () => CitiesService.getSuggestions(pattern),
                  );
                },
                itemBuilder: (context, String suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
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
    arrayList[index].editingControllerCastingFor?.text =
        arrayList[index].casting_for.toString();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Requirement For',
                style: TextStyle(
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
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: TextField(
                enabled: flagBtnHideApproveReject == false ? true : false,
                controller: TextEditingController.fromValue(TextEditingValue(
                    text: arrayList[index].casting_for.toString(),
                    selection: TextSelection.collapsed(
                        offset: arrayList[index].casting_for.length))),
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter requirement for',
                ),
                onChanged: (String str) {
                  arrayList[index].casting_for = str;
                },
              ),
            ),
          ),
        ),
        horizontalSpaceSmall,
        SizedBox(
          width: 120,
          height: 45,
          child: InkWell(
            onTap: () {
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    contentPadding: const EdgeInsets.all(0.0),
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            key: formkeySlab,
                            height: MediaQuery.of(context).size.height / 1.5,
                            width: MediaQuery.of(context).size.width / 1.5,
                            color: Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      "SELECT SLAB",
                                      style: boldText,
                                    ),
                                  ),
                                ),
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
                                    style: const TextStyle(fontSize: 13),
                                    controller: _txtSearchSlab,
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.all(15.0),
                                        labelText: "Search Slab",
                                        hintText: "Search Slab",
                                        prefixIcon: Icon(Icons.search),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(7.0)))),
                                  ),
                                ),
                                verticalSpaceTiny,
                                Expanded(
                                  child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: slabDetails!.length,
                                      itemBuilder: (context, int indexFor) {
                                        return InkWell(
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
                                          child: Padding(
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
                                                    Text(
                                                      slabDetails![indexFor]
                                                          .slab_name!,
                                                      style: normalText,
                                                    ),
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
                                        );
                                      }),
                                ),
                                verticalSpaceTiny,
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: SimpleButton(
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
              height: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.black,
                  width: 0.8,
                ),
              ),
              child: const Text(
                'SELECT SLAB',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  fontSize: 11.0,
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Requirement Date',
                style: TextStyle(
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
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: InkWell(
                onTap: flagBtnHideApproveReject == false
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
                  style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  decoration: InputDecoration(
                      labelText: selectedRequirementDate,
                      labelStyle:
                          const TextStyle(color: Colors.black, fontSize: 15.0),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 18.0),
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

    arrayList[index].editingControllerQuantity?.text =
        arrayList[index].quantity.toString();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Quantity',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: 45,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 0, bottom: 0),
              child: TextField(
                enabled: flagBtnHideApproveReject == false ? true : false,
                controller: TextEditingController.fromValue(TextEditingValue(
                    text: arrayList[index].quantity.toString(),
                    selection: TextSelection.collapsed(
                        offset: arrayList[index].quantity.length))),
                style: const TextStyle(color: Colors.black, fontSize: 15),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 18.0),
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
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: SearchChoices.single(
                style: const TextStyle(fontSize: 15.0, color: Colors.black),
                items: unitItems,
                value: arrayList[index].casting_unit_name.toString(),
                hint: "Select Unit Type",
                searchHint: "Select Unit Type",
                readOnly: flagBtnHideApproveReject == false ? false : true,
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

  Widget _selecteBrand(int index) {
    // arrayList[index].editingControllerBrandName?.text =
    //     arrayList[index].brandType;
    // arrayList[index].editingControllerDescription?.text =
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Brand',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            color: kcTextFieldColor,
            // height: 45.0,
            // decoration: BoxDecoration(
            //     color: kcTextFieldColor,
            //     border: Border.all(color: Colors.grey),
            //     borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: TextFormField(
              onChanged: (value) {
                arrayList[index].brand_supplier_name = value;
              },
              controller: arrayList[index].editingControllerBrandName,
              // enabled: false,
              style: const TextStyle(color: Colors.black, fontSize: 15.0),
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
                  contentPadding: const EdgeInsets.all(10),
                  // border: InputBorder.none,
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(255, 116, 116, 116),
                    fontSize: 15.0,
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
    arrayList[index].editingControllerUnitPrice?.text =
        arrayList[index].unit_price.toString();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Unit Price',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: 45,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 0, bottom: 0),
              child: TextField(
                enabled: flagBtnHideApproveReject == false ? true : false,
                controller: TextEditingController.fromValue(TextEditingValue(
                    text: arrayList[index].unit_price.toString(),
                    selection: TextSelection.collapsed(
                        offset: arrayList[index].unit_price.length))),
                style: const TextStyle(color: Colors.black, fontSize: 15),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 18.0),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Total Price',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: 45,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: TextField(
              controller: TextEditingController.fromValue(TextEditingValue(
                  text: arrayList[index].total_amount.toString(),
                  selection: TextSelection.collapsed(
                      offset: arrayList[index].total_amount.length))),
              readOnly: true,
              style: const TextStyle(color: Colors.black, fontSize: 15),
              decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: kcTextFieldGreyColor,
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
