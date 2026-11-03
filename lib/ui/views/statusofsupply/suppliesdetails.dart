import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:search_choices/search_choices.dart';
// import 'package:search_choices/search_choices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/views/PurchaseOrder/purchase_order_form.dart';
import 'package:stallion/ui/views/statusofsupply/uploadchallan.dart';
import '../../../models/get_contractor_no.dart';
import '../../../models/get_po_challan_by_order.dart';
import '../../../models/get_status_of_supply_list.dart';
import '../../../models/message_success.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import '../../widgets/simple_button.dart';
import '../accountmanagement/paymentdue/popreviewhtmldetails.dart';

class SuppliesPoDetails extends StatefulWidget {
  SuppliesPoDetails(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.poId,
      this.orderDetails});

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? poId;
  RccBookingHistory? orderDetails;

  @override
  State<SuppliesPoDetails> createState() => _SuppliesPoDetailsState();
}

class _SuppliesPoDetailsState extends State<SuppliesPoDetails> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final ScrollController _sc = ScrollController();

  NetworkHandler apiNetworkHandler = NetworkHandler();
  String? selectedRequirementDate = "";
  List<TextEditingController> _typeAheadController = [];
  final TextEditingController _txtControllerRequirementFor =
      TextEditingController();
  final TextEditingController _txtVehicleNumber = TextEditingController();
  final TextEditingController _txtQuantityController = TextEditingController();
  final TextEditingController _txtRemarkController = TextEditingController();
  final TextEditingController _txtChallanNo = TextEditingController();
  final TextEditingController _txtDeliveryDate = TextEditingController();
  final TextEditingController _txtHandoverto = TextEditingController();
  final TextEditingController _txtWorkOrderNo = TextEditingController();
  final TextEditingController _txtRemark = TextEditingController();

  double actualQty = 0.0;
  double deliveredQty = 0.0;
  String units = "";
  String deliver = "";
  String grades = "";
  var arrayList = [];
  late BuildContext dialogContext;
  bool flagBtnHide = false;
  int count = 0;
  String? strGradName = '';
  String? strGradId = '';
  String? remainQty = '';
  String? strGradeUnit = '';
  String? strGradeUnitId = '';
  String? strContractorId = '';
  String? stockConsumeType = '';

  String? strWorkOrderId = '';
  bool flagcalled = false;
  List<DropdownMenuItem> gradeItems = [];
  List<GradeDetail>? gradeDetailsList = [];
  List<GradeDetail>? gradeDetailsListOriginal = [];
  List<ChalanDetail>? challanDetailsList = [];
  List<ContractorList>? contractorList = [];
  List<ContractorList>? contractorListOriginal = [];
  List<WoList>? woList;
  List<WoList>? woListOriginal;
  String? orderCompletFlag = '0';
  String? sopChallanFlag = '';

  Future<ResponseGetContractorNo?> fetchWorkOrderNoWithContractor() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "company_id": strContractorId!,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.webGetWoOrderNoByContractor, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getContractorNoFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        //return dataModel.response;
        woListOriginal = dataModel.response?.woList;
        setState(() {
          woList = dataModel.response?.woList;
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
  }

  Future<ResponseGetPoChallanByOrder?>
      fetchtPurchaseOrderChallanByOrder() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "order_id": widget.orderDetails!.orderId!,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.webGetChalanByOrder, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getPoChallanByOrderFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        sopChallanFlag = dataModel.response?.sopChallanFlag;
        orderCompletFlag = dataModel.response?.orderCompletFlag;
        //return dataModel.response;
        gradeDetailsList = dataModel.response?.gradeDetails;
        gradeDetailsListOriginal = dataModel.response?.gradeDetails;
        contractorList = dataModel.response?.contractorList!;
        challanDetailsList = dataModel.response?.chalanDetails!;
        if (gradeDetailsList!.isNotEmpty) {
          gradeItems = [];
          for (var i = 0; i < gradeDetailsList!.length; i++) {
            gradeItems.add(DropdownMenuItem(
              value: gradeDetailsList![i].gradeTypeName!,
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text(gradeDetailsList![i].gradeTypeName ?? ''),
              ),
            ));
          }
        }
        setState(() {
          flagcalled = true;
          int? leng = challanDetailsList?.length.toInt();
          count = leng! + 1;
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
  }

  Future<ResponseMessageSuccess?> webserviceForSendNotification() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    var arrList = [];
    Map<String, dynamic> dataList = {
      "quantity": _txtQuantityController.text,
      "grade_id": strGradId!,
      "grad_name": strGradName!,
      "chalan_type": _txtVehicleNumber.text,
      "chalan_id": strGradeUnitId!,
      "casting_unit_name": strGradeUnit!,
    };
    arrList.add(dataList);

    Map<String, String> data = {
      "user_id": userId!,
      "order_id": widget.orderDetails!.orderId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "supplier_details_json": jsonEncode(arrList),
    };

    if (kDebugMode) {
      print(data);
    }
    var response =
        await apiNetworkHandler.post(AppUrl.websetpartialchalanbyorder, data);
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
                    content: const Text(
                        'Order has been partially delivered successfully.',
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
  }

  Future<ResponseMessageSuccess?> submitPurchaseOrderComplete() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    var arrList = [];
    Map<String, dynamic> dataList = {
      "quantity": _txtQuantityController.text,
      "grade_id": strGradId!,
      "grad_name": strGradName!,
      "chalan_type": _txtVehicleNumber.text,
      "chalan_id": strGradeUnitId!,
      "casting_unit_name": strGradeUnit!,
      "company_id": strContractorId!,
      "work_order_id": strWorkOrderId!,
      "contractor_name": _txtHandoverto.text,
      "workorderno": _txtWorkOrderNo.text,
      "remark": _txtRemark.text,
      "challan_no": _txtChallanNo.text,
    };
    arrList.add(dataList);

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "order_id": widget.orderDetails!.orderId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "supplier_details_json": jsonEncode(arrList),
      "remark": _txtRemarkController.text!,
    };

    if (kDebugMode) {
      print(data);
    }
    var response =
        await apiNetworkHandler.post(AppUrl.webCompleteChalanByOrder, data);
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
                    content: const Text(
                        'You have successfully updated order status.',
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
  }

  Future<ResponseGetPoChallanByOrder?> submitPurchaseOrderAddMore() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    var arrList = [];
    Map<String, dynamic> dataList = {
      "quantity": _txtQuantityController.text,
      "grade_id": strGradId!,
      "grad_name": strGradName!,
      "chalan_type": _txtVehicleNumber.text,
      "chalan_id": strGradeUnitId!,
      "casting_unit_name": strGradeUnit!,
      "company_id": strContractorId!,
      "work_order_id": strWorkOrderId!,
      "contractor_name": stockConsumeType == '1' ? _txtHandoverto.text : '',
      "workorderno": _txtWorkOrderNo.text,
      "remark": _txtRemark.text,
      "challan_no": _txtChallanNo.text,
      'delivery_date': _txtDeliveryDate.text,
      "contractor_name_handover":
          stockConsumeType == '0' ? _txtHandoverto.text : '',
    };
    arrList.add(dataList);

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "order_id": widget.orderDetails!.orderId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "supplier_details_json": jsonEncode(arrList),
    };

    if (kDebugMode) {
      print(data);
    }
    var response =
        await apiNetworkHandler.post(AppUrl.wsSetChalanByOrder, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getPoChallanByOrderFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response!);
      }
      if (dataModel.response?.errorCode == "0") {
        gradeDetailsList = dataModel.response?.gradeDetails;
        challanDetailsList = dataModel.response?.chalanDetails!;
        //contractorList = dataModel.response?.contractorList!;
        if (gradeDetailsList!.isNotEmpty) {
          gradeItems = [];
          for (var i = 0; i < gradeDetailsList!.length; i++) {
            gradeItems.add(DropdownMenuItem(
              value: gradeDetailsList![i].gradeTypeName!,
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text(gradeDetailsList![i].gradeTypeName ?? ''),
              ),
            ));
          }
        }

        setState(() {
          remainQty = '';
          _txtControllerRequirementFor.text = '';
          _txtVehicleNumber.text = '';
          _txtQuantityController.text = '';
          _txtDeliveryDate.text = '';
          _txtChallanNo.text = '';
          _txtRemark.text = '';
          _txtWorkOrderNo.text = '';
          _txtHandoverto.text = '';

          strGradName = '';
          strGradId = '';
          strGradeUnitId = '';
          strGradeUnit = '';
          strWorkOrderId = '';
          strContractorId = '';
          selectedRequirementDate = '';

          flagcalled = true;
          int? leng = challanDetailsList?.length.toInt();
          count = leng! + 1;
          if (kDebugMode) {
            print('====count====');
            print(count);
          }
        });

        Future.delayed(Duration.zero).then((_) {
          Navigator.pop(dialogContext);
          showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: const Text('Purchase Order'),
                    content: const Text('Order received successfully.',
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
                          });
                        },
                      ),
                    ],
                  ));
        });

        Future.delayed(Duration(seconds: 1)).then((_) {
          _sc.jumpTo(_sc.position.maxScrollExtent);
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
  }

  /*Future<ResponseGradeDescription?> fetchGradeDescription() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "grade_id":selectedRequirementTypeId!
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
        setState((){
          finishingUnit = dataModel.response?.finishingUnit;
          descriptionList = dataModel.response?.similarDescription;
          if (descriptionList!.isNotEmpty) {
            CitiesService.cities = [];
            for (var i = 0; i < descriptionList!.length; i++) {
              CitiesService.cities.add(descriptionList![i].transGradeTypeName!);
            }
          }
          if (finishingUnit!.isNotEmpty) {
            //unitItems = [];
            for (var i = 0; i < finishingUnit!.length; i++) {
              var flag = false;
              for (var j = 0; j < unitItems.length; j++) {
                if(unitItems[j].value == finishingUnit![i].unitName) {
                  flag = true;
                  break;
                }
              }
              if(flag == false){
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
                    child: Text(StringUtils.capitalize(
                        finishingUnit![i].unitName!.toLowerCase())),
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
  }

  Future<ResponseMessageSuccess?> submitOkToOrderPurchaseOrder() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId!,
      "order_id": widget.orderDetails!.orderId!,
      "project_id": widget.projectId!,
      "po_approve_status": "1",
      "supplier_for": '2',
      "remarks": strRemark!,
      "booking_details_json": jsonEncode(arrayList),
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
          Navigator.pop(dialogContext);
          showDialog<String>(
              context: context,
              builder: (BuildContext context) =>
                  AlertDialog(
                    title: const Text('Purchase Order'),
                    content: const Text('Request status updated successfully.',
                        style: TextStyle(
                            fontStyle: FontStyle.normal,

                            fontSize: 17.0)
                    ),
                    actions: <Widget>[
                      FlatButton(
                        color: Colors.white,
                        textColor: Colors.black,
                        child: const Text('CLOSE', style:  normalText),
                        onPressed: () {
                          setState(() {
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
  }

  Future<ResponseMessageSuccess?> submitPurchaseOrderRequestion() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
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
              builder: (BuildContext context) =>
                  AlertDialog(
                    title: const Text('PO Vendor Quote'),
                    content: const Text('Request for Quoteis being send successfully.',
                        style: TextStyle(
                            fontStyle: FontStyle.normal,

                            fontSize: 17.0)
                    ),
                    actions: <Widget>[
                      FlatButton(
                        color: Colors.white,
                        textColor: Colors.black,
                        child: const Text('CLOSE', style:  normalText),
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
  }*/

  @override
  void initState() {
    super.initState();
    actualQty = 0.0;
    deliveredQty = 0.0;
    units = "";
    deliver = "";
    grades = "";

    List<OrderDetail>? orderDetails = widget.orderDetails?.orderDetails!;
    for (int i = 0; i < orderDetails!.length; i++) {
      actualQty = double.parse(orderDetails[i].orderQuantity!);
      deliveredQty = double.parse(orderDetails[i].deliveryQuantity!);
      if (i == 0) {
        units =
            '${actualQty.toStringAsFixed(3)} ${orderDetails[i].castingUnitName!}';
        deliver =
            '${deliveredQty.toStringAsFixed(3)} ${orderDetails[i].castingUnitName!}';
        grades = orderDetails[i].gradeTypeName!;
      } else {
        units =
            '$units, ${actualQty.toStringAsFixed(3)} ${orderDetails[i].castingUnitName!}';
        deliver =
            '$deliver, ${deliveredQty.toStringAsFixed(3)} ${orderDetails[i].castingUnitName!}';
        grades = '$grades, ${orderDetails[i].gradeTypeName!}';
      }
    }

    fetchtPurchaseOrderChallanByOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.projectName!.toUpperCase(),
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: SafeArea(
        child: flagcalled == true
            ? SingleChildScrollView(
                controller: _sc,
                child: Column(children: [
                  SizedBox(
                    height: 50,
                    child: Stack(
                      children: [
                        horizontalSpaceLarge,
                        const Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Center(child: Text('UPDATE PROGRESS')),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return PoPreviewHtml(
                                        projectId: widget.projectId!,
                                        towarId: widget.towarId!,
                                        projectName: widget.projectName!,
                                        orderId: widget.orderDetails!.orderId!,
                                        poNo: widget.orderDetails!.poNo!,
                                      );
                                    },
                                  ),
                                ).then((_) => {});
                              },
                              child: Container(
                                  height: 35,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'VIEW PO',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  )),
                            ),
                          ),
                        ),
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
                            'P.O. Date',
                            style: normalText,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            widget.orderDetails!.poCreatedAt!,
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
                            'Vendor Name',
                            style: normalText,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            widget.orderDetails!.venderName!,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      horizontalSpaceSmall,
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3.5,
                        child: Column(
                          children: [
                            verticalSpaceSmall,
                            const Text(
                              'P.O. Quantity',
                              style: normalText,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              units,
                              textAlign: TextAlign.center,
                              style: boldText,
                            ),
                          ],
                        ),
                      ),
                      horizontalSpaceSmall,
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3.5,
                        child: Column(
                          children: [
                            verticalSpaceSmall,
                            const Text(
                              'Grades',
                              style: normalText,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 3.5,
                              child: Text(
                                grades,
                                textAlign: TextAlign.center,
                                style: boldText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      horizontalSpaceSmall,
                      InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          8), // Set radius to zero
                                    ),
                                    elevation: 0,
                                    titlePadding: EdgeInsets.zero,
                                    actionsPadding: const EdgeInsets.only(
                                        bottom: 10, left: 10, right: 10),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    actionsAlignment: MainAxisAlignment.center,
                                    title: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                      ),
                                      child: const Text(
                                        "Order Details",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    actions: <Widget>[
                                      Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 10, bottom: 10, left: 10),
                                            decoration: BoxDecoration(
                                                border: Border(
                                                    top: BorderSide(
                                                        color: Colors.grey))),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 120,
                                                  child: Text(
                                                    'Total',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: 120,
                                                  child: Text(
                                                    widget.orderDetails!
                                                            .orderQuantity ??
                                                        '',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: 120,
                                                  child: Text(
                                                    widget.orderDetails!
                                                            .deliveryQuantity ??
                                                        '',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: 120,
                                                  child: Text(
                                                    '${double.parse(widget.orderDetails!.orderQuantity ?? '0') - double.parse(widget.orderDetails!.deliveryQuantity ?? '0')}',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Container(
                                              width: 500,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(7)),
                                              child: const Text(
                                                "CLOSE",
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
                                      ),
                                    ],
                                    content: StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setState) {
                                      return SizedBox(
                                        height: 340,
                                        width: 400,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(
                                                    top: 10, bottom: 10),
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        bottom: BorderSide(
                                                            color:
                                                                Colors.grey))),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 120,
                                                      child: Text(
                                                        "Grade",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 120,
                                                      child: Text(
                                                        "PO Qty",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 120,
                                                      child: Text(
                                                        "Del Qty",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 120,
                                                      child: Text(
                                                        "Rmng. Qty",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              for (int i = 0;
                                                  i <
                                                      widget.orderDetails!
                                                          .orderDetails!.length;
                                                  i++)
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      top: 10, bottom: 10),
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                          bottom: BorderSide(
                                                              color: Colors
                                                                  .grey))),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 120,
                                                        child: Text(
                                                          widget
                                                                  .orderDetails!
                                                                  .orderDetails?[
                                                                      i]
                                                                  .gradeTypeName ??
                                                              '',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            // fontWeight:
                                                            //     FontWeight
                                                            //         .w600,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 120,
                                                        child: Text(
                                                          '${widget.orderDetails!.orderDetails?[i].orderQuantity} ${widget.orderDetails!.orderDetails?[i].castingUnitName}',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            // fontWeight:
                                                            //     FontWeight
                                                            //         .w600,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 120,
                                                        child: Text(
                                                          '${widget.orderDetails!.orderDetails?[i].deliveryQuantity} ${widget.orderDetails!.orderDetails?[i].castingUnitName}',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            // fontWeight:
                                                            //     FontWeight
                                                            //         .w600,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 120,
                                                        child: Text(
                                                          '${double.parse(widget.orderDetails!.orderDetails?[i].orderQuantity ?? '0') - double.parse(widget.orderDetails!.orderDetails?[i].deliveryQuantity ?? '0')} ${widget.orderDetails!.orderDetails?[i].castingUnitName}',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            // fontWeight:
                                                            //     FontWeight
                                                            //         .w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }));
                              });
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 3.5,
                          child: Column(
                            children: [
                              verticalSpaceSmall,
                              const Text(
                                'Delivered Quantity',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16.0,
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                deliver,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  color: Colors.black,
                                  // decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      horizontalSpaceSmall,
                    ],
                  ),
                  verticalSpaceSmall,
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.black,
                  ),
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      //controller: _controller,
                      shrinkWrap: true,
                      reverse: false,
                      itemCount: count,
                      itemBuilder: (BuildContext context, int index) {
                        return (count - 1) == index
                            ? SizedBox(
                                child: Column(
                                  children: [
                                    Container(
                                      // margin: EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                          left: 30,
                                          right: 30),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                          shape: BoxShape.rectangle,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 40.0,
                                              right: 40.0,
                                              bottom: 20.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              verticalSpaceSmall15,
                                              _gradeNameEdit(),
                                              verticalSpaceSmall15,
                                              _quantityEdit(),
                                              verticalSpaceSmall15,
                                              _deliveryModeEdit(index),
                                              verticalSpaceSmall15,
                                              _challanNoEdit(index),
                                              verticalSpaceSmall15,
                                              _deliveryDateEdit(),
                                              verticalSpaceSmall15,
                                              _stockOutEdit(),
                                              verticalSpaceSmall15,
                                              _handoverEdit(),
                                              verticalSpaceSmall15,
                                              _WorkOrderEdit(),
                                              verticalSpaceSmall15,
                                              _RemarkEdit(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70.0, right: 70.0),
                                      child: SizedBox(
                                          height: 100,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            // mainAxisAlignment:
                                            //     MainAxisAlignment.spaceAround,
                                            children: [
                                              Row(
                                                children: [
                                                  horizontalSpaceMedium,
                                                  Expanded(
                                                    child: SizedBox(
                                                      height: 40,
                                                      child: OutlinedButton(
                                                        style: ButtonStyle(
                                                          elevation:
                                                              MaterialStateProperty
                                                                  .all(3),
                                                          shadowColor:
                                                              MaterialStateProperty
                                                                  .all(Colors
                                                                      .black),
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(Colors
                                                                      .grey
                                                                      .shade300),
                                                        ),
                                                        onPressed: () {
                                                          var projectId =
                                                              widget.projectId!;
                                                          var projectName =
                                                              widget
                                                                  .projectName!;
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) {
                                                                return UploadChallanofPo(
                                                                    projectId:
                                                                        projectId,
                                                                    projectName:
                                                                        projectName,
                                                                    orderId: widget
                                                                        .orderDetails
                                                                        ?.orderId!,
                                                                    navigationFlag:
                                                                        'UploadChallan');
                                                              },
                                                            ),
                                                          );
                                                        },
                                                        child: const Text(
                                                          'UPLOAD CHALLAN',
                                                          style: boldText,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  horizontalSpaceMedium,
                                                  Expanded(
                                                    child: SizedBox(
                                                      height: 40,
                                                      child: OutlinedButton(
                                                        onPressed: () {
                                                          String msg = '';
                                                          bool flag = true;
                                                          if (strGradName! ==
                                                              "") {
                                                            msg =
                                                                'Please select grade.';
                                                            flag = false;
                                                          } else if (_txtQuantityController
                                                                  .text ==
                                                              "") {
                                                            msg =
                                                                'Please enter quantity.';
                                                            flag = false;
                                                          } else if (_txtVehicleNumber
                                                                  .text ==
                                                              "") {
                                                            msg =
                                                                'Please enter delivery mode.';
                                                            flag = false;
                                                          } else {
                                                            double orderedqty =
                                                                0;
                                                            var orderDetails =
                                                                widget
                                                                    .orderDetails
                                                                    ?.orderDetails;
                                                            for (int i = 0;
                                                                i <
                                                                    orderDetails!
                                                                        .length;
                                                                i++) {
                                                              if (strGradId ==
                                                                  orderDetails[
                                                                          i]
                                                                      .gradeTypeId) {
                                                                if (orderDetails[
                                                                        i]
                                                                    .orderQuantity!
                                                                    .isNotEmpty) {
                                                                  orderedqty = double.parse(
                                                                      orderDetails[
                                                                              i]
                                                                          .orderQuantity!);
                                                                  break;
                                                                }
                                                              }
                                                            }

                                                            orderedqty =
                                                                orderedqty +
                                                                    (orderedqty *
                                                                        20 /
                                                                        100);
                                                            print(orderedqty);

                                                            double actualQty =
                                                                0;
                                                            actualQty =
                                                                double.parse(
                                                                    _txtQuantityController
                                                                        .text);

                                                            double
                                                                deliveredQty =
                                                                0;
                                                            for (int j = 0;
                                                                j <
                                                                    challanDetailsList!
                                                                        .length;
                                                                j++) {
                                                              if (challanDetailsList![
                                                                      j]
                                                                  .chalanQuantity!
                                                                  .isNotEmpty) {
                                                                if (strGradId ==
                                                                    challanDetailsList![
                                                                            j]
                                                                        .gradId) {
                                                                  deliveredQty =
                                                                      deliveredQty +
                                                                          double.parse(
                                                                              challanDetailsList![j].chalanQuantity!);
                                                                }
                                                              }
                                                            }
                                                            if (kDebugMode) {
                                                              print(
                                                                  deliveredQty);
                                                            }
                                                            double
                                                                remainingQty =
                                                                orderedqty -
                                                                    deliveredQty;
                                                            if (kDebugMode) {
                                                              print(
                                                                  remainingQty);
                                                            }

                                                            if (actualQty >
                                                                remainingQty) {
                                                              flag = false;
                                                              msg =
                                                                  'You can\'t enter more than ${remainingQty.toStringAsFixed(3)} quantity.';
                                                            } else {
                                                              flag = true;
                                                            }
                                                          }

                                                          if (flag == false) {
                                                            showDialog<String>(
                                                                context:
                                                                    context,
                                                                builder: (BuildContext
                                                                        context) =>
                                                                    AlertDialog(
                                                                      title:
                                                                          const Text(
                                                                              ''),
                                                                      content: Text(
                                                                          msg,
                                                                          style: const TextStyle(
                                                                              fontStyle: FontStyle.normal,
                                                                              fontSize: 17.0)),
                                                                      actions: <Widget>[
                                                                        ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(
                                                                              backgroundColor: Colors.black,
                                                                              fixedSize: const Size.fromWidth(100),
                                                                              padding: const EdgeInsets.all(10),
                                                                              textStyle: const TextStyle(color: Colors.white)),
                                                                          child: const Text(
                                                                              'CLOSE',
                                                                              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14.0, color: Colors.white)),
                                                                          onPressed:
                                                                              () {
                                                                            setState(() {
                                                                              Navigator.pop(context);
                                                                            });
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ));
                                                          } else {
                                                            showDialog<String>(
                                                                context:
                                                                    context,
                                                                builder: (BuildContext
                                                                        context) =>
                                                                    AlertDialog(
                                                                      title: const Text(
                                                                          'Update Order'),
                                                                      content: const Text(
                                                                          'Are you sure, you want to update? Once updated it cannot be amended!',
                                                                          style: TextStyle(
                                                                              fontStyle: FontStyle.normal,
                                                                              fontFamily: 'RobotoMono',
                                                                              fontSize: 17.0)),
                                                                      actions: <Widget>[
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 15.0,
                                                                              right: 15.0),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, fixedSize: const Size.fromWidth(100), padding: const EdgeInsets.all(10), textStyle: const TextStyle(color: Colors.white)),
                                                                                child: const Text('NO', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16.0, color: Colors.white)),
                                                                                onPressed: () {
                                                                                  setState(() {
                                                                                    Navigator.pop(context);
                                                                                  });
                                                                                },
                                                                              ),
                                                                              horizontalSpaceMedium,
                                                                              ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, fixedSize: const Size.fromWidth(100), padding: const EdgeInsets.all(10), textStyle: const TextStyle(color: Colors.white)),
                                                                                child: const Text('YES', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14.0, color: Colors.white)),
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
                                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                                children: [
                                                                                                  verticalSpaceSmall,
                                                                                                  // CircularProgressIndicator(),
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
                                                                                    setState(() {
                                                                                      flagcalled = false;
                                                                                    });
                                                                                    submitPurchaseOrderAddMore();
                                                                                  });
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ));
                                                          }
                                                        },
                                                        style: ButtonStyle(
                                                          elevation:
                                                              MaterialStateProperty
                                                                  .all(3),
                                                          shadowColor:
                                                              MaterialStateProperty
                                                                  .all(Colors
                                                                      .black),
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(Colors
                                                                      .grey
                                                                      .shade300),
                                                        ),

                                                        // style: ButtonStyle(
                                                        //     backgroundColor: MaterialStateColo),
                                                        child: const Text(
                                                          'UPDATE & ADD MORE',
                                                          style: boldText,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  horizontalSpaceMedium,
                                                ],
                                              ),
                                            ],
                                          )),
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, bottom: 8.0, left: 30, right: 30),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (challanDetailsList?[index]
                                                .editedName !=
                                            "")
                                          Container(
                                              padding: EdgeInsets.only(top: 6),
                                              width: double.maxFinite,
                                              child: Text(
                                                "(Edited By- ${challanDetailsList?[index].editedName})",
                                                textAlign: TextAlign.end,
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                ),
                                              )),
                                        verticalSpaceSmall15,
                                        _gradeName(index),
                                        verticalSpaceSmall15,
                                        _quantity(index),
                                        verticalSpaceSmall15,
                                        _deliveryMode(index),
                                        verticalSpaceSmall15,
                                        _challanNo(index),
                                        verticalSpaceSmall15,
                                        _deliveryDate(index),
                                        verticalSpaceSmall15,
                                        _stockOut(index),
                                        verticalSpaceSmall15,
                                        _handover(index),
                                        verticalSpaceSmall15,
                                        _WorkOrder(index),
                                        verticalSpaceSmall15,
                                        _Remark(index),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                      }),
                ]),
              )
            : Center(
                child: SizedBox(
                  height: 64,
                  child: OverflowBox(
                    minHeight: 100,
                    maxHeight: 100,
                    child: Lottie.asset(
                      'assets/animation/running2.json',
                      repeat: true,
                    ),
                  ),
                ),
              ),
        // const Center(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: Row(
        children: [
          Expanded(
            child: GestureDetector(
                onTap: () {
                  challanDetailsList!.isNotEmpty
                      ? showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: const Text('Purchase Order'),
                                content: const Text(
                                    'Are you sure, you want to deliver this order as partial?',
                                    style: TextStyle(
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'RobotoMono',
                                        fontSize: 17.0)),
                                actions: <Widget>[
                                  verticalSpaceSmall,
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15.0, right: 15.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              fixedSize:
                                                  const Size.fromWidth(100),
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
                                        horizontalSpaceMedium,
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              fixedSize:
                                                  const Size.fromWidth(100),
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
                                              webserviceForSendNotification();
                                              //submitRejectPurchaseOrder();
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ))
                      : const SizedBox();
                },
                child: Container(
                    padding: const EdgeInsets.only(top: 13),
                    height: 50,
                    color: challanDetailsList!.isNotEmpty
                        ? Colors.black
                        : Colors.grey.shade600,
                    child: const Text(
                      'PARTIALLY DELIVERED',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                      textAlign: TextAlign.center,
                    ))),
          ),
          const SizedBox(width: 1),
          Expanded(
              child: GestureDetector(
                  onTap: () {
                    if (orderCompletFlag == '1') {
                      var flag = false;
                      String msg = "";

                      if (strGradName! == "" &&
                          _txtQuantityController.text == "" &&
                          _txtVehicleNumber.text == "") {
                        if (challanDetailsList!.isNotEmpty) {
                          flag = true;
                        } else {
                          msg = 'Please select grade.';
                          flag = false;
                        }
                      } else {
                        flag = true;
                        if (strGradName! == "") {
                          msg = 'Please select grade.';
                          flag = false;
                        } else if (_txtQuantityController.text == "") {
                          msg = 'Please enter quantity.';
                          flag = false;
                        } else if (_txtVehicleNumber.text == "") {
                          msg = 'Please enter delivery mode.';
                          flag = false;
                        } else {
                          double orderedqty = 0;
                          var orderDetails = widget.orderDetails?.orderDetails;
                          for (int i = 0; i < orderDetails!.length; i++) {
                            if (strGradId == orderDetails[i].gradeTypeId) {
                              if (orderDetails[i].orderQuantity!.isNotEmpty) {
                                orderedqty = double.parse(
                                    orderDetails[i].orderQuantity!);
                                break;
                              }
                            }
                          }

                          orderedqty = orderedqty + (orderedqty * 20 / 100);
                          print(orderedqty);

                          double actualQty = 0;
                          actualQty = double.parse(_txtQuantityController.text);

                          double deliveredQty = 0;
                          for (int j = 0; j < challanDetailsList!.length; j++) {
                            if (challanDetailsList![j]
                                .chalanQuantity!
                                .isNotEmpty) {
                              if (strGradId == challanDetailsList![j].gradId) {
                                deliveredQty = deliveredQty +
                                    double.parse(
                                        challanDetailsList![j].chalanQuantity!);
                              }
                            }
                          }
                          if (kDebugMode) {
                            print(deliveredQty);
                          }
                          double remainingQty = orderedqty - deliveredQty;
                          if (kDebugMode) {
                            print(remainingQty);
                          }

                          if (actualQty > remainingQty) {
                            flag = false;
                            msg =
                                'You can\'t enter more than $remainingQty quantity.';
                          } else {
                            flag = true;
                          }
                        }
                      }

                      if (flag == false) {
                        showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                  title: const Text(''),
                                  content: Text(msg,
                                      style: const TextStyle(
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'RobotoMono',
                                          fontSize: 17.0)),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          fixedSize: const Size.fromWidth(100),
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
                        showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Purchase Order'),
                                  content: const Text(
                                      'Are you sure you want to complete this purchase order?',
                                      style: TextStyle(
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'RobotoMono',
                                          fontSize: 17.0)),
                                  actions: <Widget>[
                                    const Padding(
                                      padding: EdgeInsets.only(
                                          left: 15.0, right: 15.0),
                                      child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text('Write Your Remarks')),
                                    ),
                                    verticalSpaceSmall,
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 15.0),
                                      child: Container(
                                        height: 155.0,
                                        decoration: BoxDecoration(
                                            color: kcTextFieldColor,
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(5.0))),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, right: 10.0),
                                          child: TextField(
                                            maxLines: 10,
                                            enabled: true,
                                            controller: _txtRemarkController,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 15.0),
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 18.0),
                                              border: InputBorder.none,
                                              hintText: 'Enter remarks',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    verticalSpaceSmall,
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 15.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black,
                                                fixedSize:
                                                    const Size.fromWidth(100),
                                                padding:
                                                    const EdgeInsets.all(10),
                                                textStyle: const TextStyle(
                                                    color: Colors.white)),
                                            child: const Text('NO',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 16.0,
                                                    color: Colors.white)),
                                            onPressed: () {
                                              setState(() {
                                                Navigator.pop(context);
                                              });
                                            },
                                          ),
                                          horizontalSpaceMedium,
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black,
                                                fixedSize:
                                                    const Size.fromWidth(100),
                                                padding:
                                                    const EdgeInsets.all(10),
                                                textStyle: const TextStyle(
                                                    color: Colors.white)),
                                            child: const Text('YES',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 14.0,
                                                    color: Colors.white)),
                                            onPressed: () {
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
                                                submitPurchaseOrderComplete();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ));
                      }
                    }
                  },
                  child: Container(
                      padding: const EdgeInsets.only(top: 13),
                      height: 50,
                      color:
                          orderCompletFlag == '1' ? Colors.black : Colors.grey,
                      child: const Text(
                        'ORDER COMPLETE',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                        textAlign: TextAlign.center,
                      )))),
        ],
      ),
    );
  }

  Widget _gradeName(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Grade',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
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
                items: gradeItems,
                value: challanDetailsList![index].gradName!,
                hint: "Select Grade",
                searchHint: "Select Grade",
                readOnly: true,
                onChanged: (value) {},
                padding: 0.0,
                dialogBox: false,
                isExpanded: true,
                menuConstraints:
                    BoxConstraints.tight(const Size.fromHeight(350.0)),
                onClear: () {},
                underline: const SizedBox(height: 0.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _quantity(int index) {
    _typeAheadController.add(TextEditingController());
    _typeAheadController[index].text =
        challanDetailsList![index].chalanQuantity!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 230.0,
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
        Container(
          width: 250,
          height: 45.0,
          decoration: BoxDecoration(
              color: kcTextFieldColor,
              border: Border.all(
                color: Colors.grey,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(5.0))),
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10),
            child: TextField(
              enabled: false,
              controller: TextEditingController.fromValue(TextEditingValue(
                  text: challanDetailsList![index].chalanQuantity.toString(),
                  selection: TextSelection.collapsed(
                      offset: challanDetailsList![index]
                          .chalanQuantity
                          .toString()
                          .length))),
              style: const TextStyle(color: Colors.black, fontSize: 15.0),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                border: InputBorder.none,
                hintText: 'Enter Quantity',
              ),
              onChanged: (String str) {},
            ),
          ),
        ),
        horizontalSpaceMedium,
        Center(
          child: Text(challanDetailsList![index].castingUnitName!,
              style: const TextStyle(
                  backgroundColor: Colors.white,
                  fontSize: 15,
                  color: Colors.black)),
        ),
      ],
    );
  }

  Widget _deliveryMode(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Vehicle No.',
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
                enabled: false,
                controller: TextEditingController.fromValue(TextEditingValue(
                    text: challanDetailsList![index].chalanType!.toString(),
                    selection: TextSelection.collapsed(
                        offset:
                            challanDetailsList![index].chalanType!.length))),
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter Vehicle No',
                ),
                onChanged: (String str) {
                  arrayList[index]['casting_for'] = str;
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _challanNo(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Challan No.',
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
                enabled: false,
                controller: TextEditingController.fromValue(TextEditingValue(
                    text: challanDetailsList![index].challanNo!.toString(),
                    selection: TextSelection.collapsed(
                        offset: challanDetailsList![index].challanNo!.length))),
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _deliveryDate(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Delivery On.',
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
                enabled: false,
                controller: TextEditingController.fromValue(TextEditingValue(
                    text: challanDetailsList![index].deliveryDate!.toString(),
                    selection: TextSelection.collapsed(
                        offset:
                            challanDetailsList![index].deliveryDate!.length))),
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _handover(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Handover To',
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
                enabled: false,
                controller: TextEditingController.fromValue(TextEditingValue(
                    text: challanDetailsList![index].stockConsumeType == "0"
                        ? challanDetailsList![index].companyName!.toString()
                        : '',
                    // challanDetailsList![index].companyName!.toString(),
                    selection: TextSelection.collapsed(
                        offset:
                            challanDetailsList![index].stockConsumeType == "0"
                                ? challanDetailsList![index].companyName!.length
                                : 0
                        // challanDetailsList![index].companyName!.length
                        ))),
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _stockOut(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Stock Out',
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
                enabled: false,
                controller: TextEditingController.fromValue(TextEditingValue(
                    text: challanDetailsList![index].stockConsumeType == "1"
                        ? challanDetailsList![index].companyName!.toString()
                        : '',
                    selection: TextSelection.collapsed(
                        offset:
                            challanDetailsList![index].stockConsumeType == "1"
                                ? challanDetailsList![index].companyName!.length
                                : 0))),
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _WorkOrder(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Work Order No.',
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
                enabled: false,
                controller: TextEditingController.fromValue(TextEditingValue(
                    text:
                        challanDetailsList![index].workOrderNumber!.toString(),
                    selection: TextSelection.collapsed(
                        offset: challanDetailsList![index]
                            .workOrderNumber!
                            .length))),
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _Remark(int index) {
    return Row(
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
          child: Container(
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: TextField(
                enabled: false,
                maxLines: 4,
                controller: TextEditingController.fromValue(TextEditingValue(
                    text: challanDetailsList![index].stockRemark!.toString(),
                    selection: TextSelection.collapsed(
                        offset:
                            challanDetailsList![index].stockRemark!.length))),
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _gradeNameEdit() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Grade',
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
              print('Clicked');
              gradeDetailsList!.isNotEmpty
                  ? showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          contentPadding: const EdgeInsets.all(0.0),
                          content: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState1) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 1.5,
                                  width:
                                      MediaQuery.of(context).size.width / 1.5,
                                  color: Colors.white,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(
                                            "SELECT GRADE",
                                            style: boldText,
                                          ),
                                        ),
                                      ),
                                      verticalSpaceTiny,
                                      SizedBox(
                                        height: 40,
                                        child: TextField(
                                          onChanged: (value) {
                                            if (value.isNotEmpty) {
                                              if (value.length > 2) {
                                                var filteredList =
                                                    gradeDetailsListOriginal
                                                        ?.where((element) => element
                                                            .gradeTypeName!
                                                            .toLowerCase()
                                                            .contains(value
                                                                .toLowerCase()))
                                                        .toList();
                                                setState(() {
                                                  gradeDetailsList =
                                                      filteredList;
                                                });
                                              }
                                            } else {
                                              setState(() {
                                                gradeDetailsList =
                                                    gradeDetailsListOriginal;
                                              });
                                            }
                                          },
                                          style: const TextStyle(fontSize: 13),
                                          decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.all(12.0),
                                              labelText: 'Search Grade',
                                              hintText: 'Search Grade',
                                              prefixIcon: Icon(Icons.search),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              7.0)))),
                                        ),
                                      ),
                                      verticalSpaceTiny,
                                      Expanded(
                                        child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount: gradeDetailsList!.length,
                                            itemBuilder: (context, int index) {
                                              return InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    remainQty =
                                                        '/ ${gradeDetailsList![index].remainingQty} ${gradeDetailsList![index].castingUnitName}';
                                                  });
                                                  setState1(() {
                                                    print(
                                                        gradeDetailsList![index]
                                                            .remainingQty);
                                                    strGradId =
                                                        gradeDetailsList![index]
                                                            .gradeTypeId;
                                                    strGradName =
                                                        gradeDetailsList![index]
                                                            .gradeTypeName!;
                                                    _txtControllerRequirementFor
                                                            .text =
                                                        gradeDetailsList![index]
                                                            .gradeTypeName!;
                                                  });
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
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
                                                                gradeDetailsList![
                                                                        index]
                                                                    .gradeTypeName!,
                                                                style:
                                                                    normalText,
                                                              ),
                                                            ],
                                                          ),
                                                          strGradId == null
                                                              ? const Icon(
                                                                  Icons
                                                                      .circle_outlined,
                                                                  size: 25,
                                                                  color: Colors
                                                                      .grey,
                                                                )
                                                              : strGradId ==
                                                                      gradeDetailsList![
                                                                              index]
                                                                          .gradeTypeId!
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
                    )
                  : null;
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
                    controller: _txtControllerRequirementFor,
                    autofocus: false,
                    enabled: false,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Select Grade',
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
        /*Expanded(
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
                items: gradeItems,
                value: strGradName!,
                hint: "Select Grade",
                searchHint: "Select Grade",
                readOnly: false,
                onChanged: (value) {
                  strGradName = value;
                  if (kDebugMode) {
                    print(strGradName);
                  }
                  for (int i = 0; i < gradeDetailsList!.length; i++) {
                    if (gradeDetailsList?[i].gradeTypeName! == strGradName) {
                      strGradId = gradeDetailsList?[i].gradeTypeId!;
                      strGradeUnitId = gradeDetailsList?[i].castingUnitId!;
                      strGradeUnit = gradeDetailsList?[i].castingUnitName!;
                      if (kDebugMode) {
                        print(strGradeUnitId);
                        print(strGradeUnit);
                      }
                    }
                  }
                },
                padding: strGradName == '' || strGradName == null ? 0.0 : 0.0,
                dialogBox: false,
                isExpanded: true,
                menuConstraints:
                    BoxConstraints.tight(const Size.fromHeight(350.0)),
                onClear: () {},
                underline: const SizedBox(height: 0.0),
              ),
            ),
          ),
        ),*/
      ],
    );
  }

  Widget _quantityEdit() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 230.0,
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
        Container(
          width: 250,
          height: 45.0,
          decoration: BoxDecoration(
              color: kcTextFieldColor,
              border: Border.all(
                color: Colors.grey,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(5.0))),
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10),
            child: TextField(
              // keyboardType: TextInputType.number,
              // inputFormatters: <TextInputFormatter>[
              //   FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              // ],
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [DecimalTextInputFormatter(decimalPlaces: 3)],
              enabled: true,
              controller: _txtQuantityController,
              style: const TextStyle(color: Colors.black, fontSize: 15.0),
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter Quantity',
                  hintStyle: TextStyle(color: Colors.black45)),
            ),
          ),
        ),
        horizontalSpaceMedium,
        Text(remainQty ?? '',
            style: TextStyle(
                backgroundColor: Colors.white,
                fontSize: 15,
                color: Colors.black)),
        horizontalSpaceMedium,
        Center(
          child: Text(strGradeUnit!,
              style: const TextStyle(
                  backgroundColor: Colors.white,
                  fontSize: 15,
                  color: Colors.black)),
        ),
      ],
    );
  }

  Widget _deliveryModeEdit(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Vehicle No.',
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
                enabled: true,
                controller: _txtVehicleNumber,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                    border: InputBorder.none,
                    hintText: 'Enter Vehicle No',
                    hintStyle: TextStyle(color: Colors.black45)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: () {
            setState(() {
              _txtVehicleNumber.text =
                  challanDetailsList?[index - 1].chalanType ?? '';
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 17),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              "Same Vehicle",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _challanNoEdit(int index) {
    // TextEditingController.fromValue(TextEditingValue(
    //                 text: challanDetailsList![index].challanNo!.toString(),
    //                 selection: TextSelection.collapsed(
    //                     offset: challanDetailsList![index].challanNo!.length))),

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Challan No.',
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
                enabled: true,
                controller: _txtChallanNo,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                    border: InputBorder.none,
                    hintText: 'Enter Challan No.',
                    hintStyle: TextStyle(color: Colors.black45)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: () {
            if (sopChallanFlag != "2") {
              setState(() {
                _txtChallanNo.text =
                    challanDetailsList?[index - 1].challanNo ?? '';
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6),
              color: sopChallanFlag != "2"
                  ? Colors.transparent
                  : Colors.grey.shade300,
            ),
            child: Text(
              "Same Challan",
              style: TextStyle(
                fontSize: 15,
                color: sopChallanFlag != "2" ? Colors.black : Colors.grey,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _deliveryDateEdit() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Delivery Date',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: InkWell(
            onTap: () async {
              DateTime? newDateTime = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 7)),
                lastDate: DateTime.now(),
              );
              if (newDateTime != null) {
                setState(() {
                  selectedRequirementDate =
                      DateFormat('dd MMM yyyy').format(newDateTime).toString();

                  String dateStart = '$selectedRequirementDate';
                  DateFormat inputFormat = DateFormat('dd MMM yyyy');
                  DateTime input = inputFormat.parse(dateStart);
                  String dateRequired = DateFormat('dd-MM-yyyy').format(input);
                  selectedRequirementDate = dateRequired;

                  _txtDeliveryDate.text = selectedRequirementDate!;
                });
              }
            },
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
                  enabled: false,
                  controller: _txtDeliveryDate,
                  style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                    border: InputBorder.none,
                    hintText: 'Select Delivery Date',
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _handoverEdit() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Handover To',
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
              print('Clicked');
              contractorList!.isNotEmpty
                  ? showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          contentPadding: const EdgeInsets.all(0.0),
                          content: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState1) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 1.5,
                                  width:
                                      MediaQuery.of(context).size.width / 1.5,
                                  color: Colors.white,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(
                                            "SELECT CONTRACTOR",
                                            style: boldText,
                                          ),
                                        ),
                                      ),
                                      verticalSpaceTiny,
                                      SizedBox(
                                        height: 40,
                                        child: TextField(
                                          onChanged: (value) {
                                            if (value.isNotEmpty) {
                                              if (value.length > 2) {
                                                var filteredList =
                                                    contractorListOriginal
                                                        ?.where((element) => element
                                                            .mstCompanyName!
                                                            .toLowerCase()
                                                            .contains(value
                                                                .toLowerCase()))
                                                        .toList();
                                                setState(() {
                                                  contractorList = filteredList;
                                                });
                                              }
                                            } else {
                                              setState(() {
                                                contractorList =
                                                    contractorListOriginal;
                                              });
                                            }
                                          },
                                          style: const TextStyle(fontSize: 13),
                                          decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.all(12.0),
                                              labelText: 'Search Contractor',
                                              hintText: 'Search Contractor',
                                              prefixIcon: Icon(Icons.search),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              7.0)))),
                                        ),
                                      ),
                                      verticalSpaceTiny,
                                      Expanded(
                                        child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount: contractorList!.length,
                                            itemBuilder: (context, int index) {
                                              return InkWell(
                                                onTap: () {
                                                  setState1(() {
                                                    if (stockConsumeType ==
                                                            "0" &&
                                                        strContractorId ==
                                                            contractorList![
                                                                    index]
                                                                .mstCompanyId) {
                                                      stockConsumeType = "";
                                                      strContractorId = '';
                                                      _txtHandoverto.text = '';
                                                    } else {
                                                      stockConsumeType = "0";
                                                      strContractorId =
                                                          contractorList![index]
                                                              .mstCompanyId;
                                                      _txtHandoverto.text =
                                                          contractorList![index]
                                                              .mstCompanyName!;
                                                    }
                                                  });
                                                  fetchWorkOrderNoWithContractor();
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
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
                                                                contractorList![
                                                                        index]
                                                                    .mstCompanyName!,
                                                                style:
                                                                    normalText,
                                                              ),
                                                            ],
                                                          ),
                                                          strContractorId ==
                                                                  null
                                                              ? const Icon(
                                                                  Icons
                                                                      .circle_outlined,
                                                                  size: 25,
                                                                  color: Colors
                                                                      .grey,
                                                                )
                                                              : strContractorId ==
                                                                          contractorList![index]
                                                                              .mstCompanyId! &&
                                                                      stockConsumeType ==
                                                                          "0"
                                                                  ? const Icon(
                                                                      Icons
                                                                          .check_circle,
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
                    )
                  : null;
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
                    controller: stockConsumeType == "0"
                        ? _txtHandoverto
                        : TextEditingController(),
                    autofocus: false,
                    enabled: false,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Select Contractor (Optional)',
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
        /*Expanded(
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
                items: gradeItems,
                value: strGradName!,
                hint: "Select Grade",
                searchHint: "Select Grade",
                readOnly: false,
                onChanged: (value) {
                  strGradName = value;
                  if (kDebugMode) {
                    print(strGradName);
                  }
                  for (int i = 0; i < gradeDetailsList!.length; i++) {
                    if (gradeDetailsList?[i].gradeTypeName! == strGradName) {
                      strGradId = gradeDetailsList?[i].gradeTypeId!;
                      strGradeUnitId = gradeDetailsList?[i].castingUnitId!;
                      strGradeUnit = gradeDetailsList?[i].castingUnitName!;
                      if (kDebugMode) {
                        print(strGradeUnitId);
                        print(strGradeUnit);
                      }
                    }
                  }
                },
                padding: strGradName == '' || strGradName == null ? 0.0 : 0.0,
                dialogBox: false,
                isExpanded: true,
                menuConstraints:
                    BoxConstraints.tight(const Size.fromHeight(350.0)),
                onClear: () {},
                underline: const SizedBox(height: 0.0),
              ),
            ),
          ),
        ),*/
      ],
    );
  }

  Widget _stockOutEdit() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Stock Out',
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
              print('Clicked');
              contractorList!.isNotEmpty
                  ? showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          contentPadding: const EdgeInsets.all(0.0),
                          content: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 1.5,
                                  width:
                                      MediaQuery.of(context).size.width / 1.5,
                                  color: Colors.white,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(
                                            "SELECT CONTRACTOR",
                                            style: boldText,
                                          ),
                                        ),
                                      ),
                                      verticalSpaceTiny,
                                      SizedBox(
                                        height: 40,
                                        child: TextField(
                                          onChanged: (value) {
                                            if (value.isNotEmpty) {
                                              if (value.length > 2) {
                                                var filteredList =
                                                    contractorListOriginal
                                                        ?.where((element) => element
                                                            .mstCompanyName!
                                                            .toLowerCase()
                                                            .contains(value
                                                                .toLowerCase()))
                                                        .toList();
                                                setState(() {
                                                  contractorList = filteredList;
                                                });
                                              }
                                            } else {
                                              setState(() {
                                                contractorList =
                                                    contractorListOriginal;
                                              });
                                            }
                                          },
                                          style: const TextStyle(fontSize: 13),
                                          decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.all(12.0),
                                              labelText: 'Search Contractor',
                                              hintText: 'Search Contractor',
                                              prefixIcon: Icon(Icons.search),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              7.0)))),
                                        ),
                                      ),
                                      verticalSpaceTiny,
                                      Expanded(
                                        child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount: contractorList!.length,
                                            itemBuilder: (context, int index) {
                                              return InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (stockConsumeType ==
                                                            "1" &&
                                                        strContractorId ==
                                                            contractorList![
                                                                    index]
                                                                .mstCompanyId) {
                                                      stockConsumeType = "";
                                                      strContractorId = '';
                                                      _txtHandoverto.text = '';
                                                    } else {
                                                      stockConsumeType = "1";
                                                      strContractorId =
                                                          contractorList![index]
                                                              .mstCompanyId;
                                                      _txtHandoverto.text =
                                                          contractorList![index]
                                                              .mstCompanyName!;
                                                    }
                                                  });
                                                  fetchWorkOrderNoWithContractor();
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
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
                                                                contractorList![
                                                                        index]
                                                                    .mstCompanyName!,
                                                                style:
                                                                    normalText,
                                                              ),
                                                            ],
                                                          ),
                                                          strContractorId ==
                                                                  null
                                                              ? const Icon(
                                                                  Icons
                                                                      .circle_outlined,
                                                                  size: 25,
                                                                  color: Colors
                                                                      .grey,
                                                                )
                                                              : strContractorId ==
                                                                          contractorList![index]
                                                                              .mstCompanyId! &&
                                                                      stockConsumeType ==
                                                                          "1"
                                                                  ? const Icon(
                                                                      Icons
                                                                          .check_circle,
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
                    )
                  : null;
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
                    // controller:
                    controller: stockConsumeType == "1"
                        ? _txtHandoverto
                        : TextEditingController(),
                    // _txtHandoverto,
                    autofocus: false,
                    enabled: false,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Select Contractor (Optional)',
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
        /*Expanded(
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
                items: gradeItems,
                value: strGradName!,
                hint: "Select Grade",
                searchHint: "Select Grade",
                readOnly: false,
                onChanged: (value) {
                  strGradName = value;
                  if (kDebugMode) {
                    print(strGradName);
                  }
                  for (int i = 0; i < gradeDetailsList!.length; i++) {
                    if (gradeDetailsList?[i].gradeTypeName! == strGradName) {
                      strGradId = gradeDetailsList?[i].gradeTypeId!;
                      strGradeUnitId = gradeDetailsList?[i].castingUnitId!;
                      strGradeUnit = gradeDetailsList?[i].castingUnitName!;
                      if (kDebugMode) {
                        print(strGradeUnitId);
                        print(strGradeUnit);
                      }
                    }
                  }
                },
                padding: strGradName == '' || strGradName == null ? 0.0 : 0.0,
                dialogBox: false,
                isExpanded: true,
                menuConstraints:
                    BoxConstraints.tight(const Size.fromHeight(350.0)),
                onClear: () {},
                underline: const SizedBox(height: 0.0),
              ),
            ),
          ),
        ),*/
      ],
    );
  }

  Widget _WorkOrderEdit() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Work Order No.',
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
              print('Clicked');
              woList!.isNotEmpty
                  ? showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          contentPadding: const EdgeInsets.all(0.0),
                          content: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 1.5,
                                  width:
                                      MediaQuery.of(context).size.width / 1.5,
                                  color: Colors.white,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(
                                            "SELECT WORK ORDER NO.",
                                            style: boldText,
                                          ),
                                        ),
                                      ),
                                      verticalSpaceTiny,
                                      SizedBox(
                                        height: 40,
                                        child: TextField(
                                          onChanged: (value) {
                                            if (value.isNotEmpty) {
                                              if (value.length > 2) {
                                                var filteredList = woListOriginal
                                                    ?.where((element) => element
                                                        .workOrderNumber!
                                                        .toLowerCase()
                                                        .contains(value
                                                            .toLowerCase()))
                                                    .toList();
                                                setState(() {
                                                  woList = filteredList;
                                                });
                                              }
                                            } else {
                                              setState(() {
                                                woList = woListOriginal;
                                              });
                                            }
                                          },
                                          style: const TextStyle(fontSize: 13),
                                          decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.all(12.0),
                                              labelText:
                                                  'Search Work Order No.',
                                              hintText: 'Search Work Order No.',
                                              prefixIcon: Icon(Icons.search),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              7.0)))),
                                        ),
                                      ),
                                      verticalSpaceTiny,
                                      Expanded(
                                        child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount: woList!.length,
                                            itemBuilder: (context, int index) {
                                              return InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    strWorkOrderId =
                                                        woList![index]
                                                            .workOrderId;

                                                    _txtWorkOrderNo.text =
                                                        woList![index]
                                                            .workOrderNumber!;
                                                  });
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
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
                                                                woList![index]
                                                                    .workOrderNumber!,
                                                                style:
                                                                    normalText,
                                                              ),
                                                            ],
                                                          ),
                                                          strGradId == null
                                                              ? const Icon(
                                                                  Icons
                                                                      .circle_outlined,
                                                                  size: 25,
                                                                  color: Colors
                                                                      .grey,
                                                                )
                                                              : strWorkOrderId ==
                                                                      woList![index]
                                                                          .workOrderId!
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
                    )
                  : null;
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
                    controller: _txtWorkOrderNo,
                    autofocus: false,
                    enabled: false,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Select Work Order No. (Optional)',
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
        /*Expanded(
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
                items: gradeItems,
                value: strGradName!,
                hint: "Select Grade",
                searchHint: "Select Grade",
                readOnly: false,
                onChanged: (value) {
                  strGradName = value;
                  if (kDebugMode) {
                    print(strGradName);
                  }
                  for (int i = 0; i < gradeDetailsList!.length; i++) {
                    if (gradeDetailsList?[i].gradeTypeName! == strGradName) {
                      strGradId = gradeDetailsList?[i].gradeTypeId!;
                      strGradeUnitId = gradeDetailsList?[i].castingUnitId!;
                      strGradeUnit = gradeDetailsList?[i].castingUnitName!;
                      if (kDebugMode) {
                        print(strGradeUnitId);
                        print(strGradeUnit);
                      }
                    }
                  }
                },
                padding: strGradName == '' || strGradName == null ? 0.0 : 0.0,
                dialogBox: false,
                isExpanded: true,
                menuConstraints:
                    BoxConstraints.tight(const Size.fromHeight(350.0)),
                onClear: () {},
                underline: const SizedBox(height: 0.0),
              ),
            ),
          ),
        ),*/
      ],
    );
  }

  Widget _RemarkEdit() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Remark.',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: TextField(
                enabled: true,
                controller: _txtRemark,
                maxLines: 4,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                    border: InputBorder.none,
                    hintText: 'Enter Remark',
                    hintStyle: TextStyle(color: Colors.black45)),
              ),
            ),
          ),
        )
      ],
    );
  }
}
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
// import 'package:intl/intl.dart';
// import 'package:search_choices/search_choices.dart';
// // import 'package:search_choices/search_choices.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stallion/ui/views/PurchaseOrder/purchase_order_form.dart';
// import 'package:stallion/ui/views/statusofsupply/uploadchallan.dart';
// import '../../../models/get_contractor_no.dart';
// import '../../../models/get_po_challan_by_order.dart';
// import '../../../models/get_status_of_supply_list.dart';
// import '../../../models/message_success.dart';
// import '../../../utils/api_network_call.dart';
// import '../../../utils/app_url.dart';
// import '../../shared/ui_helpers.dart';
// import '../../widgets/simple_button.dart';
// import '../accountmanagement/paymentdue/popreviewhtmldetails.dart';

// class SuppliesPoDetails extends StatefulWidget {
//   SuppliesPoDetails(
//       {Key? key,
//       this.projectId,
//       this.towarId,
//       this.projectName,
//       this.poId,
//       this.orderDetails});

//   final String? projectId;
//   final String? towarId;
//   final String? projectName;
//   final String? poId;
//   RccBookingHistory? orderDetails;

//   @override
//   State<SuppliesPoDetails> createState() => _SuppliesPoDetailsState();
// }

// class _SuppliesPoDetailsState extends State<SuppliesPoDetails> {
//   final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
//   final ScrollController _sc = ScrollController();

//   NetworkHandler apiNetworkHandler = NetworkHandler();
//   String? selectedRequirementDate = "";
//   List<TextEditingController> _typeAheadController = [];
//   final TextEditingController _txtControllerRequirementFor =
//       TextEditingController();
//   final TextEditingController _txtVehicleNumber = TextEditingController();
//   final TextEditingController _txtQuantityController = TextEditingController();
//   final TextEditingController _txtRemarkController = TextEditingController();
//   final TextEditingController _txtChallanNo = TextEditingController();
//   final TextEditingController _txtDeliveryDate = TextEditingController();
//   final TextEditingController _txtHandoverto = TextEditingController();
//   final TextEditingController _txtWorkOrderNo = TextEditingController();
//   final TextEditingController _txtRemark = TextEditingController();

//   double actualQty = 0.0;
//   double deliveredQty = 0.0;
//   String units = "";
//   String deliver = "";
//   String grades = "";
//   var arrayList = [];
//   late BuildContext dialogContext;
//   bool flagBtnHide = false;
//   int count = 0;
//   String? strGradName = '';
//   String? strGradId = '';
//   String? remainQty = '';
//   String? strGradeUnit = '';
//   String? strGradeUnitId = '';
//   String? strContractorId = '';
//   String? strWorkOrderId = '';
//   bool flagcalled = false;
//   List<DropdownMenuItem> gradeItems = [];
//   List<GradeDetail>? gradeDetailsList = [];
//   List<GradeDetail>? gradeDetailsListOriginal = [];
//   List<ChalanDetail>? challanDetailsList = [];
//   List<ContractorList>? contractorList = [];
//   List<ContractorList>? contractorListOriginal = [];
//   List<WoList>? woList;
//   List<WoList>? woListOriginal;
//   String? orderCompletFlag = '0';

//   Future<ResponseGetContractorNo?> fetchWorkOrderNoWithContractor() async {
//     final SharedPreferences prefs = await _prefs;
//     String? userId = prefs.getString('mobileNo');

//     String towerId = "";
//     if (widget.towarId != null) {
//       towerId = widget.towarId!;
//     }

//     Map<String, String> data = {
//       "user_id": userId!,
//       "project_id": widget.projectId!,
//       "towar_id": towerId,
//       "company_id": strContractorId!,
//     };

//     if (kDebugMode) {
//       print(data);
//     }

//     var response =
//         await apiNetworkHandler.post(AppUrl.webGetWoOrderNoByContractor, data);
//     if (kDebugMode) {
//       print(response.statusCode);
//     }
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final dataModel = getContractorNoFromJson(response.body);
//       if (kDebugMode) {
//         print(dataModel.response?.errorCode);
//       }
//       if (dataModel.response?.errorCode == "0") {
//         //return dataModel.response;
//         woListOriginal = dataModel.response?.woList;
//         setState(() {
//           woList = dataModel.response?.woList;
//         });
//       }
//     } else {
//       if (kDebugMode) {
//         print(response.body);
//       }
//       return null;
//     }
//   }

//   Future<ResponseGetPoChallanByOrder?>
//       fetchtPurchaseOrderChallanByOrder() async {
//     final SharedPreferences prefs = await _prefs;
//     String? userId = prefs.getString('mobileNo');

//     String towerId = "";
//     if (widget.towarId != null) {
//       towerId = widget.towarId!;
//     }

//     Map<String, String> data = {
//       "user_id": userId!,
//       "project_id": widget.projectId!,
//       "towar_id": towerId,
//       "order_id": widget.orderDetails!.orderId!,
//     };

//     if (kDebugMode) {
//       print(data);
//     }

//     var response =
//         await apiNetworkHandler.post(AppUrl.webGetChalanByOrder, data);
//     if (kDebugMode) {
//       print(response.statusCode);
//     }
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final dataModel = getPoChallanByOrderFromJson(response.body);
//       if (kDebugMode) {
//         print(dataModel.response?.errorCode);
//       }
//       if (dataModel.response?.errorCode == "0") {
//         orderCompletFlag = dataModel.response?.orderCompletFlag;
//         //return dataModel.response;
//         gradeDetailsList = dataModel.response?.gradeDetails;
//         gradeDetailsListOriginal = dataModel.response?.gradeDetails;
//         contractorList = dataModel.response?.contractorList!;
//         challanDetailsList = dataModel.response?.chalanDetails!;
//         if (gradeDetailsList!.isNotEmpty) {
//           gradeItems = [];
//           for (var i = 0; i < gradeDetailsList!.length; i++) {
//             gradeItems.add(DropdownMenuItem(
//               value: gradeDetailsList![i].gradeTypeName!,
//               onTap: () {},
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//                 child: Text(gradeDetailsList![i].gradeTypeName ?? ''),
//               ),
//             ));
//           }
//         }
//         setState(() {
//           flagcalled = true;
//           int? leng = challanDetailsList?.length.toInt();
//           count = leng! + 1;
//         });
//       }
//     } else {
//       if (kDebugMode) {
//         print(response.body);
//       }
//       return null;
//     }
//   }

//   Future<ResponseMessageSuccess?> webserviceForSendNotification() async {
//     final SharedPreferences prefs = await _prefs;
//     String? userId = prefs.getString('mobileNo');

//     String towerId = "";
//     if (widget.towarId != null) {
//       towerId = widget.towarId!;
//     }

//     var arrList = [];
//     Map<String, dynamic> dataList = {
//       "quantity": _txtQuantityController.text,
//       "grade_id": strGradId!,
//       "grad_name": strGradName!,
//       "chalan_type": _txtVehicleNumber.text,
//       "chalan_id": strGradeUnitId!,
//       "casting_unit_name": strGradeUnit!,
//     };
//     arrList.add(dataList);

//     Map<String, String> data = {
//       "user_id": userId!,
//       "order_id": widget.orderDetails!.orderId!,
//       "project_id": widget.projectId!,
//       "towar_id": towerId,
//       "supplier_details_json": jsonEncode(arrList),
//     };

//     if (kDebugMode) {
//       print(data);
//     }
//     var response =
//         await apiNetworkHandler.post(AppUrl.websetpartialchalanbyorder, data);
//     if (kDebugMode) {
//       print(response.statusCode);
//     }
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final dataModel = messageSuccessFromJson(response.body);
//       if (kDebugMode) {
//         print(dataModel.response!);
//       }
//       if (dataModel.response?.errorCode == "0") {
//         Future.delayed(Duration.zero).then((_) {
//           Navigator.maybePop(context);
//           Navigator.pop(dialogContext);
//           showDialog<String>(
//               context: context,
//               builder: (BuildContext context) => AlertDialog(
//                     title: const Text('Purchase Order'),
//                     content: const Text(
//                         'Order has been partially delivered successfully.',
//                         style: TextStyle(
//                             fontStyle: FontStyle.normal, fontSize: 17.0)),
//                     actions: <Widget>[
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.black,
//                             fixedSize: const Size.fromWidth(100),
//                             padding: const EdgeInsets.all(10),
//                             textStyle: const TextStyle(color: Colors.white)),
//                         child: const Text('CLOSE',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.normal,
//                                 fontSize: 16.0,
//                                 color: Colors.white)),
//                         onPressed: () {
//                           setState(() {
//                             Navigator.pop(context);
//                             Navigator.maybePop(context);
//                           });
//                         },
//                       ),
//                     ],
//                   ));
//         });
//       }
//     } else {
//       if (kDebugMode) {
//         print(response.body);
//       }
//       return null;
//     }
//   }

//   Future<ResponseMessageSuccess?> submitPurchaseOrderComplete() async {
//     final SharedPreferences prefs = await _prefs;
//     String? userId = prefs.getString('mobileNo');

//     var arrList = [];
//     Map<String, dynamic> dataList = {
//       "quantity": _txtQuantityController.text,
//       "grade_id": strGradId!,
//       "grad_name": strGradName!,
//       "chalan_type": _txtVehicleNumber.text,
//       "chalan_id": strGradeUnitId!,
//       "casting_unit_name": strGradeUnit!,
//       "company_id": strContractorId!,
//       "work_order_id": strWorkOrderId!,
//       "contractor_name": _txtHandoverto.text,
//       "workorderno": _txtWorkOrderNo.text,
//       "remark": _txtRemark.text,
//       "challan_no": _txtChallanNo.text,
//     };
//     arrList.add(dataList);

//     String towerId = "";
//     if (widget.towarId != null) {
//       towerId = widget.towarId!;
//     }

//     Map<String, String> data = {
//       "user_id": userId!,
//       "order_id": widget.orderDetails!.orderId!,
//       "project_id": widget.projectId!,
//       "towar_id": towerId,
//       "supplier_details_json": jsonEncode(arrList),
//       "remark": _txtRemarkController.text!,
//     };

//     if (kDebugMode) {
//       print(data);
//     }
//     var response =
//         await apiNetworkHandler.post(AppUrl.webCompleteChalanByOrder, data);
//     if (kDebugMode) {
//       print(response.statusCode);
//     }
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final dataModel = messageSuccessFromJson(response.body);
//       if (kDebugMode) {
//         print(dataModel.response!);
//       }
//       if (dataModel.response?.errorCode == "0") {
//         Future.delayed(Duration.zero).then((_) {
//           Navigator.maybePop(context);
//           Navigator.pop(dialogContext);
//           showDialog<String>(
//               context: context,
//               builder: (BuildContext context) => AlertDialog(
//                     title: const Text('Purchase Order'),
//                     content: const Text(
//                         'You have successfully updated order status.',
//                         style: TextStyle(
//                             fontStyle: FontStyle.normal, fontSize: 17.0)),
//                     actions: <Widget>[
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.black,
//                             fixedSize: const Size.fromWidth(100),
//                             padding: const EdgeInsets.all(10),
//                             textStyle: const TextStyle(color: Colors.white)),
//                         child: const Text('CLOSE',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.normal,
//                                 fontSize: 16.0,
//                                 color: Colors.white)),
//                         onPressed: () {
//                           setState(() {
//                             Navigator.pop(context);
//                             Navigator.maybePop(context);
//                           });
//                         },
//                       ),
//                     ],
//                   ));
//         });
//       }
//     } else {
//       if (kDebugMode) {
//         print(response.body);
//       }
//       return null;
//     }
//   }

//   Future<ResponseGetPoChallanByOrder?> submitPurchaseOrderAddMore() async {
//     final SharedPreferences prefs = await _prefs;
//     String? userId = prefs.getString('mobileNo');

//     var arrList = [];
//     Map<String, dynamic> dataList = {
//       "quantity": _txtQuantityController.text,
//       "grade_id": strGradId!,
//       "grad_name": strGradName!,
//       "chalan_type": _txtVehicleNumber.text,
//       "chalan_id": strGradeUnitId!,
//       "casting_unit_name": strGradeUnit!,
//       "company_id": strContractorId!,
//       "work_order_id": strWorkOrderId!,
//       "contractor_name": _txtHandoverto.text,
//       "workorderno": _txtWorkOrderNo.text,
//       "remark": _txtRemark.text,
//       "challan_no": _txtChallanNo.text,
//       'delivery_date': _txtDeliveryDate.text,
//     };
//     arrList.add(dataList);

//     String towerId = "";
//     if (widget.towarId != null) {
//       towerId = widget.towarId!;
//     }

//     Map<String, String> data = {
//       "user_id": userId!,
//       "order_id": widget.orderDetails!.orderId!,
//       "project_id": widget.projectId!,
//       "towar_id": towerId,
//       "supplier_details_json": jsonEncode(arrList),
//     };

//     if (kDebugMode) {
//       print(data);
//     }
//     var response =
//         await apiNetworkHandler.post(AppUrl.wsSetChalanByOrder, data);
//     if (kDebugMode) {
//       print(response.statusCode);
//     }
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final dataModel = getPoChallanByOrderFromJson(response.body);
//       if (kDebugMode) {
//         print(dataModel.response!);
//       }
//       if (dataModel.response?.errorCode == "0") {
//         gradeDetailsList = dataModel.response?.gradeDetails;
//         challanDetailsList = dataModel.response?.chalanDetails!;
//         //contractorList = dataModel.response?.contractorList!;
//         if (gradeDetailsList!.isNotEmpty) {
//           gradeItems = [];
//           for (var i = 0; i < gradeDetailsList!.length; i++) {
//             gradeItems.add(DropdownMenuItem(
//               value: gradeDetailsList![i].gradeTypeName!,
//               onTap: () {},
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//                 child: Text(gradeDetailsList![i].gradeTypeName ?? ''),
//               ),
//             ));
//           }
//         }

//         setState(() {
//           remainQty = '';
//           _txtControllerRequirementFor.text = '';
//           _txtVehicleNumber.text = '';
//           _txtQuantityController.text = '';
//           _txtDeliveryDate.text = '';
//           _txtChallanNo.text = '';
//           _txtRemark.text = '';
//           _txtWorkOrderNo.text = '';
//           _txtHandoverto.text = '';

//           strGradName = '';
//           strGradId = '';
//           strGradeUnitId = '';
//           strGradeUnit = '';
//           strWorkOrderId = '';
//           strContractorId = '';
//           selectedRequirementDate = '';

//           flagcalled = true;
//           int? leng = challanDetailsList?.length.toInt();
//           count = leng! + 1;
//           if (kDebugMode) {
//             print('====count====');
//             print(count);
//           }
//         });

//         Future.delayed(Duration.zero).then((_) {
//           Navigator.pop(dialogContext);
//           showDialog<String>(
//               context: context,
//               builder: (BuildContext context) => AlertDialog(
//                     title: const Text('Purchase Order'),
//                     content: const Text('Order received successfully.',
//                         style: TextStyle(
//                             fontStyle: FontStyle.normal, fontSize: 17.0)),
//                     actions: <Widget>[
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.black,
//                             fixedSize: const Size.fromWidth(100),
//                             padding: const EdgeInsets.all(10),
//                             textStyle: const TextStyle(color: Colors.white)),
//                         child: const Text('CLOSE',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.normal,
//                                 fontSize: 16.0,
//                                 color: Colors.white)),
//                         onPressed: () {
//                           setState(() {
//                             Navigator.pop(context);
//                           });
//                         },
//                       ),
//                     ],
//                   ));
//         });

//         Future.delayed(Duration(seconds: 1)).then((_) {
//           _sc.jumpTo(_sc.position.maxScrollExtent);
//         });
//       }
//     } else {
//       if (kDebugMode) {
//         print(response.body);
//       }
//       return null;
//     }
//   }

//   /*Future<ResponseGradeDescription?> fetchGradeDescription() async {
//     final SharedPreferences prefs = await _prefs;
//     String? userId = prefs.getString('mobileNo');

//     Map<String, String> data = {
//       "user_id": userId!,
//       "project_id": widget.projectId!,
//       "grade_id":selectedRequirementTypeId!
//     };
//     if (kDebugMode) {
//       print(data);
//     }
//     var response =
//     await apiNetworkHandler.post(AppUrl.webGetDescriptionByPoGrade, data);
//     if (kDebugMode) {
//       print(response.statusCode);
//     }
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final dataModel = gradeDescriptionFromJson(response.body);
//       if (kDebugMode) {
//         print(dataModel.response?.errorCode);
//       }
//       if (dataModel.response?.errorCode == "0") {
//         //return dataModel.response;
//         setState((){
//           finishingUnit = dataModel.response?.finishingUnit;
//           descriptionList = dataModel.response?.similarDescription;
//           if (descriptionList!.isNotEmpty) {
//             CitiesService.cities = [];
//             for (var i = 0; i < descriptionList!.length; i++) {
//               CitiesService.cities.add(descriptionList![i].transGradeTypeName!);
//             }
//           }
//           if (finishingUnit!.isNotEmpty) {
//             //unitItems = [];
//             for (var i = 0; i < finishingUnit!.length; i++) {
//               var flag = false;
//               for (var j = 0; j < unitItems.length; j++) {
//                 if(unitItems[j].value == finishingUnit![i].unitName) {
//                   flag = true;
//                   break;
//                 }
//               }
//               if(flag == false){
//                 unitItems.add(DropdownMenuItem(
//                   value: finishingUnit![i].unitName!,
//                   onTap: () {
//                     //arrayList[reqTypeIndex]['casting_unit_name'] = finishingUnit![i].unitName!;
//                     //arrayList[reqTypeIndex]['casting_unit'] = finishingUnit![i].unitId!;
//                     //selectedUnitId = finishingUnit![i].unitId!;
//                     //selectedUnitType = finishingUnit![i].unitName!;
//                     if (kDebugMode) {
//                       print(selectedUnitType);
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//                     child: Text(StringUtils.capitalize(
//                         finishingUnit![i].unitName!.toLowerCase())),
//                   ),
//                 ));
//               }
//             }
//           }
//         });

//       }
//     } else {
//       if (kDebugMode) {
//         print(response.body);
//       }
//       return null;
//     }
//   }

//   Future<ResponseMessageSuccess?> submitOkToOrderPurchaseOrder() async {
//     final SharedPreferences prefs = await _prefs;
//     String? userId = prefs.getString('mobileNo');

//     Map<String, String> data = {
//       "user_id": userId!,
//       "order_id": widget.orderDetails!.orderId!,
//       "project_id": widget.projectId!,
//       "po_approve_status": "1",
//       "supplier_for": '2',
//       "remarks": strRemark!,
//       "booking_details_json": jsonEncode(arrayList),
//     };

//     if (kDebugMode) {
//       print(data);
//     }
//     var response =
//     await apiNetworkHandler.post(AppUrl.webPurchaseOrderStatusChange, data);
//     if (kDebugMode) {
//       print(response.statusCode);
//     }
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final dataModel = messageSuccessFromJson(response.body);
//       if (kDebugMode) {
//         print(dataModel.response!);
//       }
//       if (dataModel.response?.errorCode == "0") {
//         Future.delayed(Duration.zero).then((_) {
//           Navigator.pop(dialogContext);
//           showDialog<String>(
//               context: context,
//               builder: (BuildContext context) =>
//                   AlertDialog(
//                     title: const Text('Purchase Order'),
//                     content: const Text('Request status updated successfully.',
//                         style: TextStyle(
//                             fontStyle: FontStyle.normal,

//                             fontSize: 17.0)
//                     ),
//                     actions: <Widget>[
//                       FlatButton(
//                         color: Colors.white,
//                         textColor: Colors.black,
//                         child: const Text('CLOSE', style:  normalText),
//                         onPressed: () {
//                           setState(() {
//                             Navigator.pop(context);
//                           });
//                         },
//                       ),
//                     ],
//                   ));
//         });
//       }
//     } else {
//       if (kDebugMode) {
//         print(response.body);
//       }
//       return null;
//     }
//   }

//   Future<ResponseMessageSuccess?> submitPurchaseOrderRequestion() async {
//     final SharedPreferences prefs = await _prefs;
//     String? userId = prefs.getString('mobileNo');

//     Map<String, String> data = {
//       "user_id": userId!,
//       "project_id": widget.projectId!,
//       "order_id": widget.orderDetails!.orderId!,
//       "vender_arr": jsonEncode(searchDataSelected),
//     };

//     if (kDebugMode) {
//       print(data);
//     }
//     var response =
//     await apiNetworkHandler.post(AppUrl.webSendVenderPoRequisition, data);
//     if (kDebugMode) {
//       print(response.statusCode);
//     }
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final dataModel = messageSuccessFromJson(response.body);
//       if (kDebugMode) {
//         print(dataModel.response!);
//       }
//       if (dataModel.response?.errorCode == "0") {
//         Future.delayed(Duration.zero).then((_) {
//           Navigator.pop(dialogContext);
//           showDialog<String>(
//               context: context,
//               builder: (BuildContext context) =>
//                   AlertDialog(
//                     title: const Text('PO Vendor Quote'),
//                     content: const Text('Request for Quoteis being send successfully.',
//                         style: TextStyle(
//                             fontStyle: FontStyle.normal,

//                             fontSize: 17.0)
//                     ),
//                     actions: <Widget>[
//                       FlatButton(
//                         color: Colors.white,
//                         textColor: Colors.black,
//                         child: const Text('CLOSE', style:  normalText),
//                         onPressed: () {
//                           setState(() {
//                             Navigator.pop(context);
//                             Navigator.maybePop(context);
//                           });
//                         },
//                       ),
//                     ],
//                   ));
//         });
//       }
//     } else {
//       if (kDebugMode) {
//         print(response.body);
//       }
//       return null;
//     }
//   }*/

//   @override
//   void initState() {
//     super.initState();
//     actualQty = 0.0;
//     deliveredQty = 0.0;
//     units = "";
//     deliver = "";
//     grades = "";

//     List<OrderDetail>? orderDetails = widget.orderDetails?.orderDetails!;
//     for (int i = 0; i < orderDetails!.length; i++) {
//       actualQty = double.parse(orderDetails[i].orderQuantity!);
//       deliveredQty = double.parse(orderDetails[i].deliveryQuantity!);
//       if (i == 0) {
//         units =
//             '${actualQty.toStringAsFixed(3)} ${orderDetails[i].castingUnitName!}';
//         deliver =
//             '${deliveredQty.toStringAsFixed(3)} ${orderDetails[i].castingUnitName!}';
//         grades = orderDetails[i].gradeTypeName!;
//       } else {
//         units =
//             '$units, ${actualQty.toStringAsFixed(3)} ${orderDetails[i].castingUnitName!}';
//         deliver =
//             '$deliver, ${deliveredQty.toStringAsFixed(3)} ${orderDetails[i].castingUnitName!}';
//         grades = '$grades, ${orderDetails[i].gradeTypeName!}';
//       }
//     }

//     fetchtPurchaseOrderChallanByOrder();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: Text(widget.projectName!.toUpperCase(),
//             style:
//                 const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.maybePop(context);
//           },
//         ),
//       ),
//       body: SafeArea(
//         child: flagcalled == true
//             ? SingleChildScrollView(
//                 controller: _sc,
//                 child: Column(children: [
//                   SizedBox(
//                     height: 50,
//                     child: Stack(
//                       children: [
//                         horizontalSpaceLarge,
//                         const Padding(
//                           padding: EdgeInsets.only(top: 10, bottom: 10),
//                           child: Center(child: Text('UPDATE PROGRESS')),
//                         ),
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: Padding(
//                             padding: const EdgeInsets.only(right: 20.0),
//                             child: InkWell(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) {
//                                       return PoPreviewHtml(
//                                         projectId: widget.projectId!,
//                                         towarId: widget.towarId!,
//                                         projectName: widget.projectName!,
//                                         orderId: widget.orderDetails!.orderId!,
//                                         poNo: widget.orderDetails!.poNo!,
//                                       );
//                                     },
//                                   ),
//                                 ).then((_) => {});
//                               },
//                               child: Container(
//                                   height: 35,
//                                   width: 100,
//                                   decoration: BoxDecoration(
//                                     border: Border.all(color: Colors.grey),
//                                     borderRadius: BorderRadius.circular(10),
//                                     color: Colors.white,
//                                     shape: BoxShape.rectangle,
//                                   ),
//                                   child: const Center(
//                                     child: Text(
//                                       'VIEW PO',
//                                       style: TextStyle(
//                                           color: Colors.black,
//                                           fontWeight: FontWeight.bold),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   )),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Divider(
//                     height: 1,
//                     thickness: 0.5,
//                     color: Colors.black,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       Column(
//                         children: [
//                           verticalSpaceSmall,
//                           const Text(
//                             'P.O. No.',
//                             style: normalText,
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           Text(
//                             widget.orderDetails!.poNo!,
//                             style: boldText,
//                           ),
//                           const SizedBox(
//                             height: 15,
//                           ),
//                           const Text(
//                             'P.O. Date',
//                             style: normalText,
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           Text(
//                             widget.orderDetails!.poCreatedAt!,
//                             style: boldText,
//                           ),
//                           const SizedBox(
//                             height: 15,
//                           ),
//                           const Text(
//                             'Slab No',
//                             style: normalText,
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           Text(
//                             widget.orderDetails!.slabName!,
//                             style: boldText,
//                           ),
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           const Text(
//                             'Booking Type',
//                             style: normalText,
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           Text(
//                             widget.orderDetails!.gradeName!,
//                             style: boldText,
//                           ),
//                           const SizedBox(
//                             height: 15,
//                           ),
//                           const Text(
//                             'Project Name',
//                             style: normalText,
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           Text(
//                             widget.orderDetails!.projectName!,
//                             style: boldText,
//                           ),
//                           const SizedBox(
//                             height: 15,
//                           ),
//                           const Text(
//                             'Vendor Name',
//                             style: normalText,
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           Text(
//                             widget.orderDetails!.venderName!,
//                             style: boldText,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   verticalSpaceSmall,
//                   const Divider(
//                     height: 1,
//                     thickness: 0.5,
//                     color: Colors.black,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       horizontalSpaceSmall,
//                       SizedBox(
//                         width: MediaQuery.of(context).size.width / 3.5,
//                         child: Column(
//                           children: [
//                             verticalSpaceSmall,
//                             const Text(
//                               'P.O. Quantity',
//                               style: normalText,
//                             ),
//                             const SizedBox(
//                               height: 10,
//                             ),
//                             Text(
//                               units,
//                               textAlign: TextAlign.center,
//                               style: boldText,
//                             ),
//                           ],
//                         ),
//                       ),
//                       horizontalSpaceSmall,
//                       SizedBox(
//                         width: MediaQuery.of(context).size.width / 3.5,
//                         child: Column(
//                           children: [
//                             verticalSpaceSmall,
//                             const Text(
//                               'Grades',
//                               style: normalText,
//                             ),
//                             const SizedBox(
//                               height: 10,
//                             ),
//                             SizedBox(
//                               width: MediaQuery.of(context).size.width / 3.5,
//                               child: Text(
//                                 grades,
//                                 textAlign: TextAlign.center,
//                                 style: boldText,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       horizontalSpaceSmall,
//                       InkWell(
//                         onTap: () {
//                           showDialog(
//                               context: context,
//                               builder: (context) {
//                                 return AlertDialog(
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(
//                                           8), // Set radius to zero
//                                     ),
//                                     elevation: 0,
//                                     titlePadding: EdgeInsets.zero,
//                                     actionsPadding: const EdgeInsets.only(
//                                         bottom: 10, left: 10, right: 10),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         horizontal: 16),
//                                     actionsAlignment: MainAxisAlignment.center,
//                                     title: Container(
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 8),
//                                       decoration: const BoxDecoration(
//                                         color: Colors.black,
//                                       ),
//                                       child: const Text(
//                                         "Order Details",
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                         ),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ),
//                                     actions: <Widget>[
//                                       Column(
//                                         children: [
//                                           Container(
//                                             padding: EdgeInsets.only(
//                                                 top: 10, bottom: 10, left: 10),
//                                             decoration: BoxDecoration(
//                                                 border: Border(
//                                                     top: BorderSide(
//                                                         color: Colors.grey))),
//                                             child: Row(
//                                               children: [
//                                                 Container(
//                                                   width: 120,
//                                                   child: Text(
//                                                     'Total',
//                                                     style: TextStyle(
//                                                       fontSize: 16,
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 Container(
//                                                   width: 120,
//                                                   child: Text(
//                                                     widget.orderDetails!
//                                                             .orderQuantity ??
//                                                         '',
//                                                     style: TextStyle(
//                                                       fontSize: 16,
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 Container(
//                                                   width: 120,
//                                                   child: Text(
//                                                     widget.orderDetails!
//                                                             .deliveryQuantity ??
//                                                         '',
//                                                     style: TextStyle(
//                                                       fontSize: 16,
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 Container(
//                                                   width: 120,
//                                                   child: Text(
//                                                     '${double.parse(widget.orderDetails!.orderQuantity ?? '0') - double.parse(widget.orderDetails!.deliveryQuantity ?? '0')}',
//                                                     style: TextStyle(
//                                                       fontSize: 16,
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           InkWell(
//                                             onTap: () {
//                                               Navigator.of(context).pop();
//                                             },
//                                             child: Container(
//                                               width: 500,
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       vertical: 4),
//                                               decoration: BoxDecoration(
//                                                   color: Colors.black,
//                                                   borderRadius:
//                                                       BorderRadius.circular(7)),
//                                               child: const Text(
//                                                 "CLOSE",
//                                                 style: TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.w600,
//                                                   color: Colors.white,
//                                                 ),
//                                                 textAlign: TextAlign.center,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                     content: StatefulBuilder(builder:
//                                         (BuildContext context,
//                                             StateSetter setState) {
//                                       return SizedBox(
//                                         height: 340,
//                                         width: 400,
//                                         child: SingleChildScrollView(
//                                           child: Column(
//                                             children: [
//                                               Container(
//                                                 padding: EdgeInsets.only(
//                                                     top: 10, bottom: 10),
//                                                 decoration: BoxDecoration(
//                                                     border: Border(
//                                                         bottom: BorderSide(
//                                                             color:
//                                                                 Colors.grey))),
//                                                 child: Row(
//                                                   children: [
//                                                     Container(
//                                                       width: 120,
//                                                       child: Text(
//                                                         "Grade",
//                                                         style: TextStyle(
//                                                           fontSize: 16,
//                                                           fontWeight:
//                                                               FontWeight.w600,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     Container(
//                                                       width: 120,
//                                                       child: Text(
//                                                         "PO Qty",
//                                                         style: TextStyle(
//                                                           fontSize: 16,
//                                                           fontWeight:
//                                                               FontWeight.w600,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     Container(
//                                                       width: 120,
//                                                       child: Text(
//                                                         "Del Qty",
//                                                         style: TextStyle(
//                                                           fontSize: 16,
//                                                           fontWeight:
//                                                               FontWeight.w600,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     Container(
//                                                       width: 120,
//                                                       child: Text(
//                                                         "Rmng. Qty",
//                                                         style: TextStyle(
//                                                           fontSize: 16,
//                                                           fontWeight:
//                                                               FontWeight.w600,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                               for (int i = 0;
//                                                   i <
//                                                       widget.orderDetails!
//                                                           .orderDetails!.length;
//                                                   i++)
//                                                 Container(
//                                                   padding: EdgeInsets.only(
//                                                       top: 10, bottom: 10),
//                                                   decoration: BoxDecoration(
//                                                       border: Border(
//                                                           bottom: BorderSide(
//                                                               color: Colors
//                                                                   .grey))),
//                                                   child: Row(
//                                                     children: [
//                                                       Container(
//                                                         width: 120,
//                                                         child: Text(
//                                                           widget
//                                                                   .orderDetails!
//                                                                   .orderDetails?[
//                                                                       i]
//                                                                   .gradeTypeName ??
//                                                               '',
//                                                           style: TextStyle(
//                                                             fontSize: 16,
//                                                             // fontWeight:
//                                                             //     FontWeight
//                                                             //         .w600,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       Container(
//                                                         width: 120,
//                                                         child: Text(
//                                                           '${widget.orderDetails!.orderDetails?[i].orderQuantity} ${widget.orderDetails!.orderDetails?[i].castingUnitName}',
//                                                           style: TextStyle(
//                                                             fontSize: 16,
//                                                             // fontWeight:
//                                                             //     FontWeight
//                                                             //         .w600,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       Container(
//                                                         width: 120,
//                                                         child: Text(
//                                                           '${widget.orderDetails!.orderDetails?[i].deliveryQuantity} ${widget.orderDetails!.orderDetails?[i].castingUnitName}',
//                                                           style: TextStyle(
//                                                             fontSize: 16,
//                                                             // fontWeight:
//                                                             //     FontWeight
//                                                             //         .w600,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       Container(
//                                                         width: 120,
//                                                         child: Text(
//                                                           '${double.parse(widget.orderDetails!.orderDetails?[i].orderQuantity ?? '0') - double.parse(widget.orderDetails!.orderDetails?[i].deliveryQuantity ?? '0')} ${widget.orderDetails!.orderDetails?[i].castingUnitName}',
//                                                           style: TextStyle(
//                                                             fontSize: 16,
//                                                             // fontWeight:
//                                                             //     FontWeight
//                                                             //         .w600,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     }));
//                               });
//                         },
//                         child: SizedBox(
//                           width: MediaQuery.of(context).size.width / 3.5,
//                           child: Column(
//                             children: [
//                               verticalSpaceSmall,
//                               const Text(
//                                 'Delivered Quantity',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.normal,
//                                   fontSize: 16.0,
//                                   color: Colors.black,
//                                   decoration: TextDecoration.underline,
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               Text(
//                                 deliver,
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16.0,
//                                   color: Colors.black,
//                                   // decoration: TextDecoration.underline,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       horizontalSpaceSmall,
//                     ],
//                   ),
//                   verticalSpaceSmall,
//                   const Divider(
//                     height: 1,
//                     thickness: 0.5,
//                     color: Colors.black,
//                   ),
//                   ListView.builder(
//                       physics: NeverScrollableScrollPhysics(),
//                       //controller: _controller,
//                       shrinkWrap: true,
//                       reverse: false,
//                       itemCount: count,
//                       itemBuilder: (BuildContext context, int index) {
//                         return (count - 1) == index
//                             ? SizedBox(
//                                 child: Column(
//                                   children: [
//                                     Container(
//                                       // margin: EdgeInsets.only(bottom: 10),
//                                       padding: const EdgeInsets.only(
//                                           top: 8.0,
//                                           bottom: 8.0,
//                                           left: 30,
//                                           right: 30),
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           border:
//                                               Border.all(color: Colors.grey),
//                                           borderRadius:
//                                               BorderRadius.circular(10),
//                                           color: Colors.white,
//                                           shape: BoxShape.rectangle,
//                                         ),
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 40.0,
//                                               right: 40.0,
//                                               bottom: 20.0),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               verticalSpaceSmall15,
//                                               _gradeNameEdit(),
//                                               verticalSpaceSmall15,
//                                               _quantityEdit(),
//                                               verticalSpaceSmall15,
//                                               _deliveryModeEdit(index),
//                                               verticalSpaceSmall15,
//                                               _challanNoEdit(index),
//                                               verticalSpaceSmall15,
//                                               _deliveryDateEdit(),
//                                               verticalSpaceSmall15,
//                                               _handoverEdit(),
//                                               verticalSpaceSmall15,
//                                               _WorkOrderEdit(),
//                                               verticalSpaceSmall15,
//                                               _RemarkEdit(),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(
//                                           left: 70.0, right: 70.0),
//                                       child: SizedBox(
//                                           height: 100,
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.start,
//                                             // mainAxisAlignment:
//                                             //     MainAxisAlignment.spaceAround,
//                                             children: [
//                                               Row(
//                                                 children: [
//                                                   horizontalSpaceMedium,
//                                                   Expanded(
//                                                     child: SizedBox(
//                                                       height: 40,
//                                                       child: OutlinedButton(
//                                                         style: ButtonStyle(
//                                                           elevation:
//                                                               MaterialStateProperty
//                                                                   .all(3),
//                                                           shadowColor:
//                                                               MaterialStateProperty
//                                                                   .all(Colors
//                                                                       .black),
//                                                           backgroundColor:
//                                                               MaterialStateProperty
//                                                                   .all(Colors
//                                                                       .grey
//                                                                       .shade300),
//                                                         ),
//                                                         onPressed: () {
//                                                           var projectId =
//                                                               widget.projectId!;
//                                                           var projectName =
//                                                               widget
//                                                                   .projectName!;
//                                                           Navigator.push(
//                                                             context,
//                                                             MaterialPageRoute(
//                                                               builder: (_) {
//                                                                 return UploadChallanofPo(
//                                                                     projectId:
//                                                                         projectId,
//                                                                     projectName:
//                                                                         projectName,
//                                                                     orderId: widget
//                                                                         .orderDetails
//                                                                         ?.orderId!,
//                                                                     navigationFlag:
//                                                                         'UploadChallan');
//                                                               },
//                                                             ),
//                                                           );
//                                                         },
//                                                         child: const Text(
//                                                           'UPLOAD CHALLAN',
//                                                           style: boldText,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   horizontalSpaceMedium,
//                                                   Expanded(
//                                                     child: SizedBox(
//                                                       height: 40,
//                                                       child: OutlinedButton(
//                                                         onPressed: () {
//                                                           String msg = '';
//                                                           bool flag = true;
//                                                           if (strGradName! ==
//                                                               "") {
//                                                             msg =
//                                                                 'Please select grade.';
//                                                             flag = false;
//                                                           } else if (_txtQuantityController
//                                                                   .text ==
//                                                               "") {
//                                                             msg =
//                                                                 'Please enter quantity.';
//                                                             flag = false;
//                                                           } else if (_txtVehicleNumber
//                                                                   .text ==
//                                                               "") {
//                                                             msg =
//                                                                 'Please enter delivery mode.';
//                                                             flag = false;
//                                                           } else {
//                                                             double orderedqty =
//                                                                 0;
//                                                             var orderDetails =
//                                                                 widget
//                                                                     .orderDetails
//                                                                     ?.orderDetails;
//                                                             for (int i = 0;
//                                                                 i <
//                                                                     orderDetails!
//                                                                         .length;
//                                                                 i++) {
//                                                               if (strGradId ==
//                                                                   orderDetails[
//                                                                           i]
//                                                                       .gradeTypeId) {
//                                                                 if (orderDetails[
//                                                                         i]
//                                                                     .orderQuantity!
//                                                                     .isNotEmpty) {
//                                                                   orderedqty = double.parse(
//                                                                       orderDetails[
//                                                                               i]
//                                                                           .orderQuantity!);
//                                                                   break;
//                                                                 }
//                                                               }
//                                                             }

//                                                             orderedqty =
//                                                                 orderedqty +
//                                                                     (orderedqty *
//                                                                         20 /
//                                                                         100);
//                                                             print(orderedqty);

//                                                             double actualQty =
//                                                                 0;
//                                                             actualQty =
//                                                                 double.parse(
//                                                                     _txtQuantityController
//                                                                         .text);

//                                                             double
//                                                                 deliveredQty =
//                                                                 0;
//                                                             for (int j = 0;
//                                                                 j <
//                                                                     challanDetailsList!
//                                                                         .length;
//                                                                 j++) {
//                                                               if (challanDetailsList![
//                                                                       j]
//                                                                   .chalanQuantity!
//                                                                   .isNotEmpty) {
//                                                                 if (strGradId ==
//                                                                     challanDetailsList![
//                                                                             j]
//                                                                         .gradId) {
//                                                                   deliveredQty =
//                                                                       deliveredQty +
//                                                                           double.parse(
//                                                                               challanDetailsList![j].chalanQuantity!);
//                                                                 }
//                                                               }
//                                                             }
//                                                             if (kDebugMode) {
//                                                               print(
//                                                                   deliveredQty);
//                                                             }
//                                                             double
//                                                                 remainingQty =
//                                                                 orderedqty -
//                                                                     deliveredQty;
//                                                             if (kDebugMode) {
//                                                               print(
//                                                                   remainingQty);
//                                                             }

//                                                             if (actualQty >
//                                                                 remainingQty) {
//                                                               flag = false;
//                                                               msg =
//                                                                   'You can\'t enter more than ${remainingQty.toStringAsFixed(3)} quantity.';
//                                                             } else {
//                                                               flag = true;
//                                                             }
//                                                           }

//                                                           if (flag == false) {
//                                                             showDialog<String>(
//                                                                 context:
//                                                                     context,
//                                                                 builder: (BuildContext
//                                                                         context) =>
//                                                                     AlertDialog(
//                                                                       title:
//                                                                           const Text(
//                                                                               ''),
//                                                                       content: Text(
//                                                                           msg,
//                                                                           style: const TextStyle(
//                                                                               fontStyle: FontStyle.normal,
//                                                                               fontSize: 17.0)),
//                                                                       actions: <Widget>[
//                                                                         ElevatedButton(
//                                                                           style: ElevatedButton.styleFrom(
//                                                                               backgroundColor: Colors.black,
//                                                                               fixedSize: const Size.fromWidth(100),
//                                                                               padding: const EdgeInsets.all(10),
//                                                                               textStyle: const TextStyle(color: Colors.white)),
//                                                                           child: const Text(
//                                                                               'CLOSE',
//                                                                               style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14.0, color: Colors.white)),
//                                                                           onPressed:
//                                                                               () {
//                                                                             setState(() {
//                                                                               Navigator.pop(context);
//                                                                             });
//                                                                           },
//                                                                         ),
//                                                                       ],
//                                                                     ));
//                                                           } else {
//                                                             showDialog<String>(
//                                                                 context:
//                                                                     context,
//                                                                 builder: (BuildContext
//                                                                         context) =>
//                                                                     AlertDialog(
//                                                                       title: const Text(
//                                                                           'Update Order'),
//                                                                       content: const Text(
//                                                                           'Are you sure, you want to update? Once updated it cannot be amended!',
//                                                                           style: TextStyle(
//                                                                               fontStyle: FontStyle.normal,
//                                                                               fontFamily: 'RobotoMono',
//                                                                               fontSize: 17.0)),
//                                                                       actions: <Widget>[
//                                                                         Padding(
//                                                                           padding: const EdgeInsets
//                                                                               .only(
//                                                                               left: 15.0,
//                                                                               right: 15.0),
//                                                                           child:
//                                                                               Row(
//                                                                             mainAxisAlignment:
//                                                                                 MainAxisAlignment.end,
//                                                                             children: [
//                                                                               ElevatedButton(
//                                                                                 style: ElevatedButton.styleFrom(backgroundColor: Colors.black, fixedSize: const Size.fromWidth(100), padding: const EdgeInsets.all(10), textStyle: const TextStyle(color: Colors.white)),
//                                                                                 child: const Text('NO', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16.0, color: Colors.white)),
//                                                                                 onPressed: () {
//                                                                                   setState(() {
//                                                                                     Navigator.pop(context);
//                                                                                   });
//                                                                                 },
//                                                                               ),
//                                                                               horizontalSpaceMedium,
//                                                                               ElevatedButton(
//                                                                                 style: ElevatedButton.styleFrom(backgroundColor: Colors.black, fixedSize: const Size.fromWidth(100), padding: const EdgeInsets.all(10), textStyle: const TextStyle(color: Colors.white)),
//                                                                                 child: const Text('YES', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14.0, color: Colors.white)),
//                                                                                 onPressed: () {
//                                                                                   setState(() {
//                                                                                     Navigator.pop(context);
//                                                                                     showDialog(
//                                                                                       context: context,
//                                                                                       barrierDismissible: false,
//                                                                                       builder: (BuildContext context) {
//                                                                                         dialogContext = context;
//                                                                                         return const Center(
//                                                                                           child: SizedBox(
//                                                                                             height: 200,
//                                                                                             width: 200,
//                                                                                             child: Dialog(
//                                                                                               child: Column(
//                                                                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                                                                 children: [
//                                                                                                   verticalSpaceSmall,
//                                                                                                   // CircularProgressIndicator(),
//                                                                                                   verticalSpaceSmall,
//                                                                                                   Text("Loading"),
//                                                                                                   verticalSpaceSmall,
//                                                                                                 ],
//                                                                                               ),
//                                                                                             ),
//                                                                                           ),
//                                                                                         );
//                                                                                       },
//                                                                                     );
//                                                                                     setState(() {
//                                                                                       flagcalled = false;
//                                                                                     });
//                                                                                     submitPurchaseOrderAddMore();
//                                                                                   });
//                                                                                 },
//                                                                               ),
//                                                                             ],
//                                                                           ),
//                                                                         ),
//                                                                       ],
//                                                                     ));
//                                                           }
//                                                         },
//                                                         style: ButtonStyle(
//                                                           elevation:
//                                                               MaterialStateProperty
//                                                                   .all(3),
//                                                           shadowColor:
//                                                               MaterialStateProperty
//                                                                   .all(Colors
//                                                                       .black),
//                                                           backgroundColor:
//                                                               MaterialStateProperty
//                                                                   .all(Colors
//                                                                       .grey
//                                                                       .shade300),
//                                                         ),

//                                                         // style: ButtonStyle(
//                                                         //     backgroundColor: MaterialStateColo),
//                                                         child: const Text(
//                                                           'UPDATE & ADD MORE',
//                                                           style: boldText,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   horizontalSpaceMedium,
//                                                 ],
//                                               ),
//                                             ],
//                                           )),
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             : Padding(
//                                 padding: const EdgeInsets.only(
//                                     top: 8.0, bottom: 8.0, left: 30, right: 30),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     border: Border.all(color: Colors.grey),
//                                     borderRadius: BorderRadius.circular(10),
//                                     color: Colors.white,
//                                     shape: BoxShape.rectangle,
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 40.0, right: 40.0, bottom: 20.0),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         if (challanDetailsList?[index]
//                                                 .editedName !=
//                                             "")
//                                           Container(
//                                               padding: EdgeInsets.only(top: 6),
//                                               width: double.maxFinite,
//                                               child: Text(
//                                                 "(Edited By- ${challanDetailsList?[index].editedName})",
//                                                 textAlign: TextAlign.end,
//                                                 style: const TextStyle(
//                                                   color: Colors.black54,
//                                                   fontSize: 14,
//                                                 ),
//                                               )),
//                                         verticalSpaceSmall15,
//                                         _gradeName(index),
//                                         verticalSpaceSmall15,
//                                         _quantity(index),
//                                         verticalSpaceSmall15,
//                                         _deliveryMode(index),
//                                         verticalSpaceSmall15,
//                                         _challanNo(index),
//                                         verticalSpaceSmall15,
//                                         _deliveryDate(index),
//                                         verticalSpaceSmall15,
//                                         _handover(index),
//                                         verticalSpaceSmall15,
//                                         _WorkOrder(index),
//                                         verticalSpaceSmall15,
//                                         _Remark(index),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                       }),
//                 ]),
//               )
//             : const Center(child: CircularProgressIndicator()),
//       ),
//       bottomNavigationBar: Row(
//         children: [
//           Expanded(
//             child: GestureDetector(
//                 onTap: () {
//                   challanDetailsList!.isNotEmpty
//                       ? showDialog<String>(
//                           context: context,
//                           builder: (BuildContext context) => AlertDialog(
//                                 title: const Text('Purchase Order'),
//                                 content: const Text(
//                                     'Are you sure, you want to deliver this order as partial?',
//                                     style: TextStyle(
//                                         fontStyle: FontStyle.normal,
//                                         fontFamily: 'RobotoMono',
//                                         fontSize: 17.0)),
//                                 actions: <Widget>[
//                                   verticalSpaceSmall,
//                                   Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 15.0, right: 15.0),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.end,
//                                       children: [
//                                         ElevatedButton(
//                                           style: ElevatedButton.styleFrom(
//                                               backgroundColor: Colors.black,
//                                               fixedSize:
//                                                   const Size.fromWidth(100),
//                                               padding: const EdgeInsets.all(10),
//                                               textStyle: const TextStyle(
//                                                   color: Colors.white)),
//                                           child: const Text('NO',
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.normal,
//                                                   fontSize: 16.0,
//                                                   color: Colors.white)),
//                                           onPressed: () {
//                                             setState(() {
//                                               Navigator.pop(context);
//                                             });
//                                           },
//                                         ),
//                                         horizontalSpaceMedium,
//                                         ElevatedButton(
//                                           style: ElevatedButton.styleFrom(
//                                               backgroundColor: Colors.black,
//                                               fixedSize:
//                                                   const Size.fromWidth(100),
//                                               padding: const EdgeInsets.all(10),
//                                               textStyle: const TextStyle(
//                                                   color: Colors.white)),
//                                           child: const Text('YES',
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.normal,
//                                                   fontSize: 14.0,
//                                                   color: Colors.white)),
//                                           onPressed: () {
//                                             setState(() {
//                                               Navigator.pop(context);
//                                               showDialog(
//                                                 context: context,
//                                                 barrierDismissible: false,
//                                                 builder:
//                                                     (BuildContext context) {
//                                                   dialogContext = context;
//                                                   return const Center(
//                                                     child: SizedBox(
//                                                       height: 200,
//                                                       width: 200,
//                                                       child: Dialog(
//                                                         child: Column(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .center,
//                                                           children: [
//                                                             verticalSpaceSmall,
//                                                             CircularProgressIndicator(),
//                                                             verticalSpaceSmall,
//                                                             Text("Loading"),
//                                                             verticalSpaceSmall,
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   );
//                                                 },
//                                               );
//                                               webserviceForSendNotification();
//                                               //submitRejectPurchaseOrder();
//                                             });
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ))
//                       : const SizedBox();
//                 },
//                 child: Container(
//                     padding: const EdgeInsets.only(top: 13),
//                     height: 50,
//                     color: challanDetailsList!.isNotEmpty
//                         ? Colors.black
//                         : Colors.grey.shade600,
//                     child: const Text(
//                       'PARTIALLY DELIVERED',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16),
//                       textAlign: TextAlign.center,
//                     ))),
//           ),
//           const SizedBox(width: 1),
//           Expanded(
//               child: GestureDetector(
//                   onTap: () {
//                     if (orderCompletFlag == '1') {
//                       var flag = false;
//                       String msg = "";

//                       if (strGradName! == "" &&
//                           _txtQuantityController.text == "" &&
//                           _txtVehicleNumber.text == "") {
//                         if (challanDetailsList!.isNotEmpty) {
//                           flag = true;
//                         } else {
//                           msg = 'Please select grade.';
//                           flag = false;
//                         }
//                       } else {
//                         flag = true;
//                         if (strGradName! == "") {
//                           msg = 'Please select grade.';
//                           flag = false;
//                         } else if (_txtQuantityController.text == "") {
//                           msg = 'Please enter quantity.';
//                           flag = false;
//                         } else if (_txtVehicleNumber.text == "") {
//                           msg = 'Please enter delivery mode.';
//                           flag = false;
//                         } else {
//                           double orderedqty = 0;
//                           var orderDetails = widget.orderDetails?.orderDetails;
//                           for (int i = 0; i < orderDetails!.length; i++) {
//                             if (strGradId == orderDetails[i].gradeTypeId) {
//                               if (orderDetails[i].orderQuantity!.isNotEmpty) {
//                                 orderedqty = double.parse(
//                                     orderDetails[i].orderQuantity!);
//                                 break;
//                               }
//                             }
//                           }

//                           orderedqty = orderedqty + (orderedqty * 20 / 100);
//                           print(orderedqty);

//                           double actualQty = 0;
//                           actualQty = double.parse(_txtQuantityController.text);

//                           double deliveredQty = 0;
//                           for (int j = 0; j < challanDetailsList!.length; j++) {
//                             if (challanDetailsList![j]
//                                 .chalanQuantity!
//                                 .isNotEmpty) {
//                               if (strGradId == challanDetailsList![j].gradId) {
//                                 deliveredQty = deliveredQty +
//                                     double.parse(
//                                         challanDetailsList![j].chalanQuantity!);
//                               }
//                             }
//                           }
//                           if (kDebugMode) {
//                             print(deliveredQty);
//                           }
//                           double remainingQty = orderedqty - deliveredQty;
//                           if (kDebugMode) {
//                             print(remainingQty);
//                           }

//                           if (actualQty > remainingQty) {
//                             flag = false;
//                             msg =
//                                 'You can\'t enter more than $remainingQty quantity.';
//                           } else {
//                             flag = true;
//                           }
//                         }
//                       }

//                       if (flag == false) {
//                         showDialog<String>(
//                             context: context,
//                             builder: (BuildContext context) => AlertDialog(
//                                   title: const Text(''),
//                                   content: Text(msg,
//                                       style: const TextStyle(
//                                           fontStyle: FontStyle.normal,
//                                           fontFamily: 'RobotoMono',
//                                           fontSize: 17.0)),
//                                   actions: <Widget>[
//                                     ElevatedButton(
//                                       style: ElevatedButton.styleFrom(
//                                           backgroundColor: Colors.black,
//                                           fixedSize: const Size.fromWidth(100),
//                                           padding: const EdgeInsets.all(10),
//                                           textStyle: const TextStyle(
//                                               color: Colors.white)),
//                                       child: const Text('CLOSE',
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.normal,
//                                               fontSize: 14.0,
//                                               color: Colors.white)),
//                                       onPressed: () {
//                                         setState(() {
//                                           Navigator.pop(context);
//                                         });
//                                       },
//                                     ),
//                                   ],
//                                 ));
//                       } else {
//                         showDialog<String>(
//                             context: context,
//                             builder: (BuildContext context) => AlertDialog(
//                                   title: const Text('Purchase Order'),
//                                   content: const Text(
//                                       'Are you sure you want to complete this purchase order?',
//                                       style: TextStyle(
//                                           fontStyle: FontStyle.normal,
//                                           fontFamily: 'RobotoMono',
//                                           fontSize: 17.0)),
//                                   actions: <Widget>[
//                                     const Padding(
//                                       padding: EdgeInsets.only(
//                                           left: 15.0, right: 15.0),
//                                       child: Align(
//                                           alignment: Alignment.centerLeft,
//                                           child: Text('Write Your Remarks')),
//                                     ),
//                                     verticalSpaceSmall,
//                                     Padding(
//                                       padding: const EdgeInsets.only(
//                                           left: 15.0, right: 15.0),
//                                       child: Container(
//                                         height: 155.0,
//                                         decoration: BoxDecoration(
//                                             color: kcTextFieldColor,
//                                             border: Border.all(
//                                               color: Colors.grey,
//                                             ),
//                                             borderRadius:
//                                                 const BorderRadius.all(
//                                                     Radius.circular(5.0))),
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 10.0, right: 10.0),
//                                           child: TextField(
//                                             maxLines: 10,
//                                             enabled: true,
//                                             controller: _txtRemarkController,
//                                             style: const TextStyle(
//                                                 color: Colors.black,
//                                                 fontSize: 15.0),
//                                             decoration: const InputDecoration(
//                                               contentPadding:
//                                                   EdgeInsets.symmetric(
//                                                       vertical: 18.0),
//                                               border: InputBorder.none,
//                                               hintText: 'Enter remarks',
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     verticalSpaceSmall,
//                                     Padding(
//                                       padding: const EdgeInsets.only(
//                                           left: 15.0, right: 15.0),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.end,
//                                         children: [
//                                           ElevatedButton(
//                                             style: ElevatedButton.styleFrom(
//                                                 backgroundColor: Colors.black,
//                                                 fixedSize:
//                                                     const Size.fromWidth(100),
//                                                 padding:
//                                                     const EdgeInsets.all(10),
//                                                 textStyle: const TextStyle(
//                                                     color: Colors.white)),
//                                             child: const Text('NO',
//                                                 style: TextStyle(
//                                                     fontWeight:
//                                                         FontWeight.normal,
//                                                     fontSize: 16.0,
//                                                     color: Colors.white)),
//                                             onPressed: () {
//                                               setState(() {
//                                                 Navigator.pop(context);
//                                               });
//                                             },
//                                           ),
//                                           horizontalSpaceMedium,
//                                           ElevatedButton(
//                                             style: ElevatedButton.styleFrom(
//                                                 backgroundColor: Colors.black,
//                                                 fixedSize:
//                                                     const Size.fromWidth(100),
//                                                 padding:
//                                                     const EdgeInsets.all(10),
//                                                 textStyle: const TextStyle(
//                                                     color: Colors.white)),
//                                             child: const Text('YES',
//                                                 style: TextStyle(
//                                                     fontWeight:
//                                                         FontWeight.normal,
//                                                     fontSize: 14.0,
//                                                     color: Colors.white)),
//                                             onPressed: () {
//                                               setState(() {
//                                                 Navigator.pop(context);
//                                                 showDialog(
//                                                   context: context,
//                                                   barrierDismissible: false,
//                                                   builder:
//                                                       (BuildContext context) {
//                                                     dialogContext = context;
//                                                     return const Center(
//                                                       child: SizedBox(
//                                                         height: 200,
//                                                         width: 200,
//                                                         child: Dialog(
//                                                           child: Column(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .center,
//                                                             children: [
//                                                               verticalSpaceSmall,
//                                                               CircularProgressIndicator(),
//                                                               verticalSpaceSmall,
//                                                               Text("Loading"),
//                                                               verticalSpaceSmall,
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     );
//                                                   },
//                                                 );
//                                                 submitPurchaseOrderComplete();
//                                               });
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ));
//                       }
//                     }
//                   },
//                   child: Container(
//                       padding: const EdgeInsets.only(top: 13),
//                       height: 50,
//                       color:
//                           orderCompletFlag == '1' ? Colors.black : Colors.grey,
//                       child: const Text(
//                         'ORDER COMPLETE',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16),
//                         textAlign: TextAlign.center,
//                       )))),
//         ],
//       ),
//     );
//   }

//   Widget _gradeName(int index) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(
//           width: 230.0,
//           height: 40.0,
//           child: Padding(
//             padding: EdgeInsets.only(top: 15.0),
//             child: Text('Grade',
//                 style: TextStyle(
//                     backgroundColor: Colors.white,
//                     fontSize: 15,
//                     color: Colors.black)),
//           ),
//         ),
//         horizontalSpaceSmall,
//         Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//                 color: kcTextFieldColor,
//                 border: Border.all(
//                   color: Colors.grey,
//                 ),
//                 borderRadius: const BorderRadius.all(Radius.circular(5.0))),
//             child: Padding(
//               padding: const EdgeInsets.only(left: 8.0, right: 8.0),
//               child: SearchChoices.single(
//                 style: const TextStyle(fontSize: 15.0, color: Colors.black),
//                 items: gradeItems,
//                 value: challanDetailsList![index].gradName!,
//                 hint: "Select Grade",
//                 searchHint: "Select Grade",
//                 readOnly: true,
//                 onChanged: (value) {},
//                 padding: 0.0,
//                 dialogBox: false,
//                 isExpanded: true,
//                 menuConstraints:
//                     BoxConstraints.tight(const Size.fromHeight(350.0)),
//                 onClear: () {},
//                 underline: const SizedBox(height: 0.0),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _quantity(int index) {
//     _typeAheadController.add(TextEditingController());
//     _typeAheadController[index].text =
//         challanDetailsList![index].chalanQuantity!;
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         const SizedBox(
//           width: 230.0,
//           height: 40.0,
//           child: Padding(
//             padding: EdgeInsets.only(top: 15.0),
//             child: Text('Quantity',
//                 style: TextStyle(
//                     backgroundColor: Colors.white,
//                     fontSize: 15,
//                     color: Colors.black)),
//           ),
//         ),
//         horizontalSpaceSmall,
//         Container(
//           width: 250,
//           height: 45.0,
//           decoration: BoxDecoration(
//               color: kcTextFieldColor,
//               border: Border.all(
//                 color: Colors.grey,
//               ),
//               borderRadius: const BorderRadius.all(Radius.circular(5.0))),
//           child: Padding(
//             padding: const EdgeInsets.only(left: 10.0, right: 10),
//             child: TextField(
//               enabled: false,
//               controller: TextEditingController.fromValue(TextEditingValue(
//                   text: challanDetailsList![index].chalanQuantity.toString(),
//                   selection: TextSelection.collapsed(
//                       offset: challanDetailsList![index]
//                           .chalanQuantity
//                           .toString()
//                           .length))),
//               style: const TextStyle(color: Colors.black, fontSize: 15.0),
//               decoration: const InputDecoration(
//                 contentPadding: EdgeInsets.symmetric(vertical: 18.0),
//                 border: InputBorder.none,
//                 hintText: 'Enter Quantity',
//               ),
//               onChanged: (String str) {},
//             ),
//           ),
//         ),
//         horizontalSpaceMedium,
//         Center(
//           child: Text(challanDetailsList![index].castingUnitName!,
//               style: const TextStyle(
//                   backgroundColor: Colors.white,
//                   fontSize: 15,
//                   color: Colors.black)),
//         ),
//       ],
//     );
//   }

//   Widget _deliveryMode(int index) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(
//           width: 230.0,
//           height: 40.0,
//           child: Padding(
//             padding: EdgeInsets.only(top: 15.0),
//             child: Text('Vehicle No.',
//                 style: TextStyle(
//                     backgroundColor: Colors.white,
//                     fontSize: 15,
//                     color: Colors.black)),
//           ),
//         ),
//         horizontalSpaceSmall,
//         Expanded(
//           child: Container(
//             height: 45.0,
//             decoration: BoxDecoration(
//                 color: kcTextFieldColor,
//                 border: Border.all(
//                   color: Colors.grey,
//                 ),
//                 borderRadius: const BorderRadius.all(Radius.circular(5.0))),
//             child: Padding(
//               padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//               child: TextField(
//                 enabled: false,
//                 controller: TextEditingController.fromValue(TextEditingValue(
//                     text: challanDetailsList![index].chalanType!.toString(),
//                     selection: TextSelection.collapsed(
//                         offset:
//                             challanDetailsList![index].chalanType!.length))),
//                 style: const TextStyle(color: Colors.black, fontSize: 15.0),
//                 decoration: const InputDecoration(
//                   contentPadding: EdgeInsets.symmetric(vertical: 18.0),
//                   border: InputBorder.none,
//                   hintText: 'Enter Vehicle No',
//                 ),
//                 onChanged: (String str) {
//                   arrayList[index]['casting_for'] = str;
//                 },
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   Widget _challanNo(int index) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(
//           width: 230.0,
//           height: 40.0,
//           child: Padding(
//             padding: EdgeInsets.only(top: 15.0),
//             child: Text('Challan No.',
//                 style: TextStyle(
//                     backgroundColor: Colors.white,
//                     fontSize: 15,
//                     color: Colors.black)),
//           ),
//         ),
//         horizontalSpaceSmall,
//         Expanded(
//           child: Container(
//             height: 45.0,
//             decoration: BoxDecoration(
//                 color: kcTextFieldColor,
//                 border: Border.all(
//                   color: Colors.grey,
//                 ),
//                 borderRadius: const BorderRadius.all(Radius.circular(5.0))),
//             child: Padding(
//               padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//               child: TextField(
//                 enabled: false,
//                 controller: TextEditingController.fromValue(TextEditingValue(
//                     text: challanDetailsList![index].challanNo!.toString(),
//                     selection: TextSelection.collapsed(
//                         offset: challanDetailsList![index].challanNo!.length))),
//                 style: const TextStyle(color: Colors.black, fontSize: 15.0),
//                 decoration: const InputDecoration(
//                   contentPadding: EdgeInsets.symmetric(vertical: 18.0),
//                   border: InputBorder.none,
//                 ),
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   Widget _deliveryDate(int index) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(
//           width: 230.0,
//           height: 40.0,
//           child: Padding(
//             padding: EdgeInsets.only(top: 15.0),
//             child: Text('Delivery On.',
//                 style: TextStyle(
//                     backgroundColor: Colors.white,
//                     fontSize: 15,
//                     color: Colors.black)),
//           ),
//         ),
//         horizontalSpaceSmall,
//         Expanded(
//           child: Container(
//             height: 45.0,
//             decoration: BoxDecoration(
//                 color: kcTextFieldColor,
//                 border: Border.all(
//                   color: Colors.grey,
//                 ),
//                 borderRadius: const BorderRadius.all(Radius.circular(5.0))),
//             child: Padding(
//               padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//               child: TextField(
//                 enabled: false,
//                 controller: TextEditingController.fromValue(TextEditingValue(
//                     text: challanDetailsList![index].deliveryDate!.toString(),
//                     selection: TextSelection.collapsed(
//                         offset:
//                             challanDetailsList![index].deliveryDate!.length))),
//                 style: const TextStyle(color: Colors.black, fontSize: 15.0),
//                 decoration: const InputDecoration(
//                   contentPadding: EdgeInsets.symmetric(vertical: 18.0),
//                   border: InputBorder.none,
//                 ),
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   Widget _handover(int index) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(
//           width: 230.0,
//           height: 40.0,
//           child: Padding(
//             padding: EdgeInsets.only(top: 15.0),
//             child: Text('Handover to',
//                 style: TextStyle(
//                     backgroundColor: Colors.white,
//                     fontSize: 15,
//                     color: Colors.black)),
//           ),
//         ),
//         horizontalSpaceSmall,
//         Expanded(
//           child: Container(
//             height: 45.0,
//             decoration: BoxDecoration(
//                 color: kcTextFieldColor,
//                 border: Border.all(
//                   color: Colors.grey,
//                 ),
//                 borderRadius: const BorderRadius.all(Radius.circular(5.0))),
//             child: Padding(
//               padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//               child: TextField(
//                 enabled: false,
//                 controller: TextEditingController.fromValue(TextEditingValue(
//                     text: challanDetailsList![index].companyName!.toString(),
//                     selection: TextSelection.collapsed(
//                         offset:
//                             challanDetailsList![index].companyName!.length))),
//                 style: const TextStyle(color: Colors.black, fontSize: 15.0),
//                 decoration: const InputDecoration(
//                   contentPadding: EdgeInsets.symmetric(vertical: 18.0),
//                   border: InputBorder.none,
//                 ),
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   Widget _WorkOrder(int index) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(
//           width: 230.0,
//           height: 40.0,
//           child: Padding(
//             padding: EdgeInsets.only(top: 15.0),
//             child: Text('Work Order No.',
//                 style: TextStyle(
//                     backgroundColor: Colors.white,
//                     fontSize: 15,
//                     color: Colors.black)),
//           ),
//         ),
//         horizontalSpaceSmall,
//         Expanded(
//           child: Container(
//             height: 45.0,
//             decoration: BoxDecoration(
//                 color: kcTextFieldColor,
//                 border: Border.all(
//                   color: Colors.grey,
//                 ),
//                 borderRadius: const BorderRadius.all(Radius.circular(5.0))),
//             child: Padding(
//               padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//               child: TextField(
//                 enabled: false,
//                 controller: TextEditingController.fromValue(TextEditingValue(
//                     text:
//                         challanDetailsList![index].workOrderNumber!.toString(),
//                     selection: TextSelection.collapsed(
//                         offset: challanDetailsList![index]
//                             .workOrderNumber!
//                             .length))),
//                 style: const TextStyle(color: Colors.black, fontSize: 15.0),
//                 decoration: const InputDecoration(
//                   contentPadding: EdgeInsets.symmetric(vertical: 18.0),
//                   border: InputBorder.none,
//                 ),
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   Widget _Remark(int index) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(
//           width: 230.0,
//           height: 40.0,
//           child: Padding(
//             padding: EdgeInsets.only(top: 15.0),
//             child: Text('Remark',
//                 style: TextStyle(
//                     backgroundColor: Colors.white,
//                     fontSize: 15,
//                     color: Colors.black)),
//           ),
//         ),
//         horizontalSpaceSmall,
//         Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//                 color: kcTextFieldColor,
//                 border: Border.all(
//                   color: Colors.grey,
//                 ),
//                 borderRadius: const BorderRadius.all(Radius.circular(5.0))),
//             child: Padding(
//               padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//               child: TextField(
//                 enabled: false,
//                 maxLines: 4,
//                 controller: TextEditingController.fromValue(TextEditingValue(
//                     text: challanDetailsList![index].stockRemark!.toString(),
//                     selection: TextSelection.collapsed(
//                         offset:
//                             challanDetailsList![index].stockRemark!.length))),
//                 style: const TextStyle(color: Colors.black, fontSize: 15.0),
//                 decoration: const InputDecoration(
//                   contentPadding: EdgeInsets.symmetric(vertical: 18.0),
//                   border: InputBorder.none,
//                 ),
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   Widget _gradeNameEdit() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(
//           width: 230.0,
//           height: 40.0,
//           child: Padding(
//             padding: EdgeInsets.only(top: 15.0),
//             child: Text('Grade',
//                 style: TextStyle(
//                     backgroundColor: Colors.white,
//                     fontSize: 15,
//                     color: Colors.black)),
//           ),
//         ),
//         horizontalSpaceSmall,
//         Expanded(
//           child: InkWell(
//             onTap: () {
//               print('Clicked');
//               gradeDetailsList!.isNotEmpty
//                   ? showDialog<void>(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return AlertDialog(
//                           contentPadding: const EdgeInsets.all(0.0),
//                           content: StatefulBuilder(
//                             builder:
//                                 (BuildContext context, StateSetter setState1) {
//                               return Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Container(
//                                   height:
//                                       MediaQuery.of(context).size.height / 1.5,
//                                   width:
//                                       MediaQuery.of(context).size.width / 1.5,
//                                   color: Colors.white,
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       const Padding(
//                                         padding: EdgeInsets.all(8.0),
//                                         child: Center(
//                                           child: Text(
//                                             "SELECT GRADE",
//                                             style: boldText,
//                                           ),
//                                         ),
//                                       ),
//                                       verticalSpaceTiny,
//                                       SizedBox(
//                                         height: 40,
//                                         child: TextField(
//                                           onChanged: (value) {
//                                             if (value.isNotEmpty) {
//                                               if (value.length > 2) {
//                                                 var filteredList =
//                                                     gradeDetailsListOriginal
//                                                         ?.where((element) => element
//                                                             .gradeTypeName!
//                                                             .toLowerCase()
//                                                             .contains(value
//                                                                 .toLowerCase()))
//                                                         .toList();
//                                                 setState(() {
//                                                   gradeDetailsList =
//                                                       filteredList;
//                                                 });
//                                               }
//                                             } else {
//                                               setState(() {
//                                                 gradeDetailsList =
//                                                     gradeDetailsListOriginal;
//                                               });
//                                             }
//                                           },
//                                           style: const TextStyle(fontSize: 13),
//                                           decoration: const InputDecoration(
//                                               contentPadding:
//                                                   EdgeInsets.all(12.0),
//                                               labelText: 'Search Grade',
//                                               hintText: 'Search Grade',
//                                               prefixIcon: Icon(Icons.search),
//                                               border: OutlineInputBorder(
//                                                   borderRadius:
//                                                       BorderRadius.all(
//                                                           Radius.circular(
//                                                               7.0)))),
//                                         ),
//                                       ),
//                                       verticalSpaceTiny,
//                                       Expanded(
//                                         child: ListView.builder(
//                                             padding: EdgeInsets.zero,
//                                             itemCount: gradeDetailsList!.length,
//                                             itemBuilder: (context, int index) {
//                                               return InkWell(
//                                                 onTap: () {
//                                                   setState(() {
//                                                     remainQty =
//                                                         '/ ${gradeDetailsList![index].remainingQty} ${gradeDetailsList![index].castingUnitName}';
//                                                   });
//                                                   setState1(() {
//                                                     print(
//                                                         gradeDetailsList![index]
//                                                             .remainingQty);
//                                                     strGradId =
//                                                         gradeDetailsList![index]
//                                                             .gradeTypeId;
//                                                     strGradName =
//                                                         gradeDetailsList![index]
//                                                             .gradeTypeName!;
//                                                     _txtControllerRequirementFor
//                                                             .text =
//                                                         gradeDetailsList![index]
//                                                             .gradeTypeName!;
//                                                   });
//                                                 },
//                                                 child: Padding(
//                                                   padding: const EdgeInsets
//                                                       .symmetric(
//                                                       horizontal: 5.0,
//                                                       vertical: 7.0),
//                                                   child: Column(
//                                                     children: [
//                                                       Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .spaceBetween,
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .center,
//                                                         children: [
//                                                           Column(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .start,
//                                                             crossAxisAlignment:
//                                                                 CrossAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               Text(
//                                                                 gradeDetailsList![
//                                                                         index]
//                                                                     .gradeTypeName!,
//                                                                 style:
//                                                                     normalText,
//                                                               ),
//                                                             ],
//                                                           ),
//                                                           strGradId == null
//                                                               ? const Icon(
//                                                                   Icons
//                                                                       .circle_outlined,
//                                                                   size: 25,
//                                                                   color: Colors
//                                                                       .grey,
//                                                                 )
//                                                               : strGradId ==
//                                                                       gradeDetailsList![
//                                                                               index]
//                                                                           .gradeTypeId!
//                                                                   ? const Icon(
//                                                                       Icons
//                                                                           .circle,
//                                                                       size: 25,
//                                                                       color: Colors
//                                                                           .green,
//                                                                     )
//                                                                   : const Icon(
//                                                                       Icons
//                                                                           .circle_outlined,
//                                                                       size: 25,
//                                                                       color: Colors
//                                                                           .grey,
//                                                                     ),
//                                                         ],
//                                                       ),
//                                                       verticalSpaceSmall,
//                                                       const Divider(
//                                                           height: 1.0,
//                                                           color: Colors.black),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               );
//                                             }),
//                                       ),
//                                       verticalSpaceTiny,
//                                       Align(
//                                         alignment: Alignment.bottomCenter,
//                                         child: SimpleButton(
//                                           lblText: 'OK',
//                                           color: kcPrimaryColor,
//                                           onTap: () {
//                                             Navigator.pop(context);
//                                           },
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         );
//                       },
//                     )
//                   : null;
//             },
//             child: Stack(alignment: Alignment.center, children: [
//               Container(
//                 height: 45.0,
//                 decoration: BoxDecoration(
//                     color: kcTextFieldColor,
//                     border: Border.all(
//                       color: Colors.grey,
//                     ),
//                     borderRadius: const BorderRadius.all(Radius.circular(5.0))),
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//                   child: TextField(
//                     controller: _txtControllerRequirementFor,
//                     autofocus: false,
//                     enabled: false,
//                     style: const TextStyle(color: Colors.black, fontSize: 15.0),
//                     decoration: const InputDecoration(
//                       border: InputBorder.none,
//                       hintText: 'Select Grade',
//                     ),
//                   ),
//                 ),
//               ),
//               const Positioned(
//                   right: 10,
//                   child: Center(
//                       child: Icon(Icons.arrow_drop_down_circle_outlined))),
//             ]),
//           ),
//         ),
//         /*Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//                 color: kcTextFieldColor,
//                 border: Border.all(
//                   color: Colors.grey,
//                 ),
//                 borderRadius: const BorderRadius.all(Radius.circular(5.0))),
//             child: Padding(
//               padding: const EdgeInsets.only(left: 8.0, right: 8.0),
//               child: SearchChoices.single(
//                 style: const TextStyle(fontSize: 15.0, color: Colors.black),
//                 items: gradeItems,
//                 value: strGradName!,
//                 hint: "Select Grade",
//                 searchHint: "Select Grade",
//                 readOnly: false,
//                 onChanged: (value) {
//                   strGradName = value;
//                   if (kDebugMode) {
//                     print(strGradName);
//                   }
//                   for (int i = 0; i < gradeDetailsList!.length; i++) {
//                     if (gradeDetailsList?[i].gradeTypeName! == strGradName) {
//                       strGradId = gradeDetailsList?[i].gradeTypeId!;
//                       strGradeUnitId = gradeDetailsList?[i].castingUnitId!;
//                       strGradeUnit = gradeDetailsList?[i].castingUnitName!;
//                       if (kDebugMode) {
//                         print(strGradeUnitId);
//                         print(strGradeUnit);
//                       }
//                     }
//                   }
//                 },
//                 padding: strGradName == '' || strGradName == null ? 0.0 : 0.0,
//                 dialogBox: false,
//                 isExpanded: true,
//                 menuConstraints:
//                     BoxConstraints.tight(const Size.fromHeight(350.0)),
//                 onClear: () {},
//                 underline: const SizedBox(height: 0.0),
//               ),
//             ),
//           ),
//         ),*/
//       ],
//     );
//   }

//   Widget _quantityEdit() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         const SizedBox(
//           width: 230.0,
//           height: 40.0,
//           child: Padding(
//             padding: EdgeInsets.only(top: 15.0),
//             child: Text('Quantity',
//                 style: TextStyle(
//                     backgroundColor: Colors.white,
//                     fontSize: 15,
//                     color: Colors.black)),
//           ),
//         ),
//         horizontalSpaceSmall,
//         Container(
//           width: 250,
//           height: 45.0,
//           decoration: BoxDecoration(
//               color: kcTextFieldColor,
//               border: Border.all(
//                 color: Colors.grey,
//               ),
//               borderRadius: const BorderRadius.all(Radius.circular(5.0))),
//           child: Padding(
//             padding: const EdgeInsets.only(left: 10.0, right: 10),
//             child: TextField(
//               // keyboardType: TextInputType.number,
//               // inputFormatters: <TextInputFormatter>[
//               //   FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
//               // ],
//               keyboardType: TextInputType.numberWithOptions(decimal: true),
//               inputFormatters: [DecimalTextInputFormatter(decimalPlaces: 3)],
//               enabled: true,
//               controller: _txtQuantityController,
//               style: const TextStyle(color: Colors.black, fontSize: 15.0),
//               decoration: const InputDecoration(
//                   contentPadding: EdgeInsets.symmetric(vertical: 18.0),
//                   border: InputBorder.none,
//                   hintText: 'Enter Quantity',
//                   hintStyle: TextStyle(color: Colors.black45)),
//             ),
//           ),
//         ),
//         horizontalSpaceMedium,
//         Text(remainQty ?? '',
//             style: TextStyle(
//                 backgroundColor: Colors.white,
//                 fontSize: 15,
//                 color: Colors.black)),
//         horizontalSpaceMedium,
//         Center(
//           child: Text(strGradeUnit!,
//               style: const TextStyle(
//                   backgroundColor: Colors.white,
//                   fontSize: 15,
//                   color: Colors.black)),
//         ),
//       ],
//     );
//   }

//   Widget _deliveryModeEdit(int index) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(
//           width: 230.0,
//           height: 40.0,
//           child: Padding(
//             padding: EdgeInsets.only(top: 15.0),
//             child: Text('Vehicle No.',
//                 style: TextStyle(
//                     backgroundColor: Colors.white,
//                     fontSize: 15,
//                     color: Colors.black)),
//           ),
//         ),
//         horizontalSpaceSmall,
//         Expanded(
//           child: Container(
//             height: 45.0,
//             decoration: BoxDecoration(
//                 color: kcTextFieldColor,
//                 border: Border.all(
//                   color: Colors.grey,
//                 ),
//                 borderRadius: const BorderRadius.all(Radius.circular(5.0))),
//             child: Padding(
//               padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//               child: TextField(
//                 enabled: true,
//                 controller: _txtVehicleNumber,
//                 style: const TextStyle(color: Colors.black, fontSize: 15.0),
//                 decoration: const InputDecoration(
//                     contentPadding: EdgeInsets.symmetric(vertical: 18.0),
//                     border: InputBorder.none,
//                     hintText: 'Enter Vehicle No',
//                     hintStyle: TextStyle(color: Colors.black45)),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 16),
//         InkWell(
//           onTap: () {
//             setState(() {
//               _txtVehicleNumber.text =
//                   challanDetailsList?[index - 1].chalanType ?? '';
//             });
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 17),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Text(
//               "Same Vehicle",
//               style: TextStyle(
//                 fontSize: 15,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   Widget _challanNoEdit(int index) {
//     // TextEditingController.fromValue(TextEditingValue(
//     //                 text: challanDetailsList![index].challanNo!.toString(),
//     //                 selection: TextSelection.collapsed(
//     //                     offset: challanDetailsList![index].challanNo!.length))),

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(
//           width: 230.0,
//           height: 40.0,
//           child: Padding(
//             padding: EdgeInsets.only(top: 15.0),
//             child: Text('Challan No.',
//                 style: TextStyle(
//                     backgroundColor: Colors.white,
//                     fontSize: 15,
//                     color: Colors.black)),
//           ),
//         ),
//         horizontalSpaceSmall,
//         Expanded(
//           child: Container(
//             height: 45.0,
//             decoration: BoxDecoration(
//                 color: kcTextFieldColor,
//                 border: Border.all(
//                   color: Colors.grey,
//                 ),
//                 borderRadius: const BorderRadius.all(Radius.circular(5.0))),
//             child: Padding(
//               padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//               child: TextField(
//                 enabled: true,
//                 controller: _txtChallanNo,
//                 style: const TextStyle(color: Colors.black, fontSize: 15.0),
//                 decoration: const InputDecoration(
//                     contentPadding: EdgeInsets.symmetric(vertical: 18.0),
//                     border: InputBorder.none,
//                     hintText: 'Enter Challan No.',
//                     hintStyle: TextStyle(color: Colors.black45)),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 16),
//         InkWell(
//           onTap: () {
//             setState(() {
//               _txtChallanNo.text =
//                   challanDetailsList?[index - 1].challanNo ?? '';
//             });
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Text(
//               "Same Challan",
//               style: TextStyle(
//                 fontSize: 15,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   Widget _deliveryDateEdit() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(
//           width: 230.0,
//           height: 40.0,
//           child: Padding(
//             padding: EdgeInsets.only(top: 15.0),
//             child: Text('Delivery Date',
//                 style: TextStyle(
//                     backgroundColor: Colors.white,
//                     fontSize: 15,
//                     color: Colors.black)),
//           ),
//         ),
//         horizontalSpaceSmall,
//         Expanded(
//           child: InkWell(
//             onTap: () async {
//               DateTime? newDateTime = await showDatePicker(
//                 context: context,
//                 initialDate: DateTime.now(),
//                 firstDate: DateTime.now().subtract(const Duration(days: 7)),
//                 lastDate: DateTime.now(),
//               );
//               if (newDateTime != null) {
//                 setState(() {
//                   selectedRequirementDate =
//                       DateFormat('dd MMM yyyy').format(newDateTime).toString();

//                   String dateStart = '$selectedRequirementDate';
//                   DateFormat inputFormat = DateFormat('dd MMM yyyy');
//                   DateTime input = inputFormat.parse(dateStart);
//                   String dateRequired = DateFormat('dd-MM-yyyy').format(input);
//                   selectedRequirementDate = dateRequired;

//                   _txtDeliveryDate.text = selectedRequirementDate!;
//                 });
//               }
//             },
//             child: Container(
//               height: 45.0,
//               decoration: BoxDecoration(
//                   color: kcTextFieldColor,
//                   border: Border.all(
//                     color: Colors.grey,
//                   ),
//                   borderRadius: const BorderRadius.all(Radius.circular(5.0))),
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//                 child: TextField(
//                   enabled: false,
//                   controller: _txtDeliveryDate,
//                   style: const TextStyle(color: Colors.black, fontSize: 15.0),
//                   decoration: const InputDecoration(
//                     contentPadding: EdgeInsets.symmetric(vertical: 18.0),
//                     border: InputBorder.none,
//                     hintText: 'Select Delivery Date',
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   Widget _handoverEdit() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(
//           width: 230.0,
//           height: 40.0,
//           child: Padding(
//             padding: EdgeInsets.only(top: 15.0),
//             child: Text('Handover to',
//                 style: TextStyle(
//                     backgroundColor: Colors.white,
//                     fontSize: 15,
//                     color: Colors.black)),
//           ),
//         ),
//         horizontalSpaceSmall,
//         Expanded(
//           child: InkWell(
//             onTap: () {
//               print('Clicked');
//               contractorList!.isNotEmpty
//                   ? showDialog<void>(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return AlertDialog(
//                           contentPadding: const EdgeInsets.all(0.0),
//                           content: StatefulBuilder(
//                             builder:
//                                 (BuildContext context, StateSetter setState) {
//                               return Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Container(
//                                   height:
//                                       MediaQuery.of(context).size.height / 1.5,
//                                   width:
//                                       MediaQuery.of(context).size.width / 1.5,
//                                   color: Colors.white,
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       const Padding(
//                                         padding: EdgeInsets.all(8.0),
//                                         child: Center(
//                                           child: Text(
//                                             "SELECT CONTRACTOR",
//                                             style: boldText,
//                                           ),
//                                         ),
//                                       ),
//                                       verticalSpaceTiny,
//                                       SizedBox(
//                                         height: 40,
//                                         child: TextField(
//                                           onChanged: (value) {
//                                             if (value.isNotEmpty) {
//                                               if (value.length > 2) {
//                                                 var filteredList =
//                                                     contractorListOriginal
//                                                         ?.where((element) => element
//                                                             .mstCompanyName!
//                                                             .toLowerCase()
//                                                             .contains(value
//                                                                 .toLowerCase()))
//                                                         .toList();
//                                                 setState(() {
//                                                   contractorList = filteredList;
//                                                 });
//                                               }
//                                             } else {
//                                               setState(() {
//                                                 contractorList =
//                                                     contractorListOriginal;
//                                               });
//                                             }
//                                           },
//                                           style: const TextStyle(fontSize: 13),
//                                           decoration: const InputDecoration(
//                                               contentPadding:
//                                                   EdgeInsets.all(12.0),
//                                               labelText: 'Search Contractor',
//                                               hintText: 'Search Contractor',
//                                               prefixIcon: Icon(Icons.search),
//                                               border: OutlineInputBorder(
//                                                   borderRadius:
//                                                       BorderRadius.all(
//                                                           Radius.circular(
//                                                               7.0)))),
//                                         ),
//                                       ),
//                                       verticalSpaceTiny,
//                                       Expanded(
//                                         child: ListView.builder(
//                                             padding: EdgeInsets.zero,
//                                             itemCount: contractorList!.length,
//                                             itemBuilder: (context, int index) {
//                                               return InkWell(
//                                                 onTap: () {
//                                                   setState(() {
//                                                     strContractorId =
//                                                         contractorList![index]
//                                                             .mstCompanyId;
//                                                     _txtHandoverto.text =
//                                                         contractorList![index]
//                                                             .mstCompanyName!;
//                                                   });
//                                                   fetchWorkOrderNoWithContractor();
//                                                 },
//                                                 child: Padding(
//                                                   padding: const EdgeInsets
//                                                       .symmetric(
//                                                       horizontal: 5.0,
//                                                       vertical: 7.0),
//                                                   child: Column(
//                                                     children: [
//                                                       Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .spaceBetween,
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .center,
//                                                         children: [
//                                                           Column(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .start,
//                                                             crossAxisAlignment:
//                                                                 CrossAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               Text(
//                                                                 contractorList![
//                                                                         index]
//                                                                     .mstCompanyName!,
//                                                                 style:
//                                                                     normalText,
//                                                               ),
//                                                             ],
//                                                           ),
//                                                           strContractorId ==
//                                                                   null
//                                                               ? const Icon(
//                                                                   Icons
//                                                                       .circle_outlined,
//                                                                   size: 25,
//                                                                   color: Colors
//                                                                       .grey,
//                                                                 )
//                                                               : strContractorId ==
//                                                                       contractorList![
//                                                                               index]
//                                                                           .mstCompanyId!
//                                                                   ? const Icon(
//                                                                       Icons
//                                                                           .circle,
//                                                                       size: 25,
//                                                                       color: Colors
//                                                                           .green,
//                                                                     )
//                                                                   : const Icon(
//                                                                       Icons
//                                                                           .circle_outlined,
//                                                                       size: 25,
//                                                                       color: Colors
//                                                                           .grey,
//                                                                     ),
//                                                         ],
//                                                       ),
//                                                       verticalSpaceSmall,
//                                                       const Divider(
//                                                           height: 1.0,
//                                                           color: Colors.black),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               );
//                                             }),
//                                       ),
//                                       verticalSpaceTiny,
//                                       Align(
//                                         alignment: Alignment.bottomCenter,
//                                         child: SimpleButton(
//                                           lblText: 'OK',
//                                           color: kcPrimaryColor,
//                                           onTap: () {
//                                             Navigator.pop(context);
//                                           },
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         );
//                       },
//                     )
//                   : null;
//             },
//             child: Stack(alignment: Alignment.center, children: [
//               Container(
//                 height: 45.0,
//                 decoration: BoxDecoration(
//                     color: kcTextFieldColor,
//                     border: Border.all(
//                       color: Colors.grey,
//                     ),
//                     borderRadius: const BorderRadius.all(Radius.circular(5.0))),
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//                   child: TextField(
//                     controller: _txtHandoverto,
//                     autofocus: false,
//                     enabled: false,
//                     style: const TextStyle(color: Colors.black, fontSize: 15.0),
//                     decoration: const InputDecoration(
//                       border: InputBorder.none,
//                       hintText: 'Select Contractor (Optional)',
//                     ),
//                   ),
//                 ),
//               ),
//               const Positioned(
//                   right: 10,
//                   child: Center(
//                       child: Icon(Icons.arrow_drop_down_circle_outlined))),
//             ]),
//           ),
//         ),
//         /*Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//                 color: kcTextFieldColor,
//                 border: Border.all(
//                   color: Colors.grey,
//                 ),
//                 borderRadius: const BorderRadius.all(Radius.circular(5.0))),
//             child: Padding(
//               padding: const EdgeInsets.only(left: 8.0, right: 8.0),
//               child: SearchChoices.single(
//                 style: const TextStyle(fontSize: 15.0, color: Colors.black),
//                 items: gradeItems,
//                 value: strGradName!,
//                 hint: "Select Grade",
//                 searchHint: "Select Grade",
//                 readOnly: false,
//                 onChanged: (value) {
//                   strGradName = value;
//                   if (kDebugMode) {
//                     print(strGradName);
//                   }
//                   for (int i = 0; i < gradeDetailsList!.length; i++) {
//                     if (gradeDetailsList?[i].gradeTypeName! == strGradName) {
//                       strGradId = gradeDetailsList?[i].gradeTypeId!;
//                       strGradeUnitId = gradeDetailsList?[i].castingUnitId!;
//                       strGradeUnit = gradeDetailsList?[i].castingUnitName!;
//                       if (kDebugMode) {
//                         print(strGradeUnitId);
//                         print(strGradeUnit);
//                       }
//                     }
//                   }
//                 },
//                 padding: strGradName == '' || strGradName == null ? 0.0 : 0.0,
//                 dialogBox: false,
//                 isExpanded: true,
//                 menuConstraints:
//                     BoxConstraints.tight(const Size.fromHeight(350.0)),
//                 onClear: () {},
//                 underline: const SizedBox(height: 0.0),
//               ),
//             ),
//           ),
//         ),*/
//       ],
//     );
//   }

//   Widget _WorkOrderEdit() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(
//           width: 230.0,
//           height: 40.0,
//           child: Padding(
//             padding: EdgeInsets.only(top: 15.0),
//             child: Text('Work Order No.',
//                 style: TextStyle(
//                     backgroundColor: Colors.white,
//                     fontSize: 15,
//                     color: Colors.black)),
//           ),
//         ),
//         horizontalSpaceSmall,
//         Expanded(
//           child: InkWell(
//             onTap: () {
//               print('Clicked');
//               woList!.isNotEmpty
//                   ? showDialog<void>(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return AlertDialog(
//                           contentPadding: const EdgeInsets.all(0.0),
//                           content: StatefulBuilder(
//                             builder:
//                                 (BuildContext context, StateSetter setState) {
//                               return Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Container(
//                                   height:
//                                       MediaQuery.of(context).size.height / 1.5,
//                                   width:
//                                       MediaQuery.of(context).size.width / 1.5,
//                                   color: Colors.white,
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       const Padding(
//                                         padding: EdgeInsets.all(8.0),
//                                         child: Center(
//                                           child: Text(
//                                             "SELECT WORK ORDER NO.",
//                                             style: boldText,
//                                           ),
//                                         ),
//                                       ),
//                                       verticalSpaceTiny,
//                                       SizedBox(
//                                         height: 40,
//                                         child: TextField(
//                                           onChanged: (value) {
//                                             if (value.isNotEmpty) {
//                                               if (value.length > 2) {
//                                                 var filteredList = woListOriginal
//                                                     ?.where((element) => element
//                                                         .workOrderNumber!
//                                                         .toLowerCase()
//                                                         .contains(value
//                                                             .toLowerCase()))
//                                                     .toList();
//                                                 setState(() {
//                                                   woList = filteredList;
//                                                 });
//                                               }
//                                             } else {
//                                               setState(() {
//                                                 woList = woListOriginal;
//                                               });
//                                             }
//                                           },
//                                           style: const TextStyle(fontSize: 13),
//                                           decoration: const InputDecoration(
//                                               contentPadding:
//                                                   EdgeInsets.all(12.0),
//                                               labelText:
//                                                   'Search Work Order No.',
//                                               hintText: 'Search Work Order No.',
//                                               prefixIcon: Icon(Icons.search),
//                                               border: OutlineInputBorder(
//                                                   borderRadius:
//                                                       BorderRadius.all(
//                                                           Radius.circular(
//                                                               7.0)))),
//                                         ),
//                                       ),
//                                       verticalSpaceTiny,
//                                       Expanded(
//                                         child: ListView.builder(
//                                             padding: EdgeInsets.zero,
//                                             itemCount: woList!.length,
//                                             itemBuilder: (context, int index) {
//                                               return InkWell(
//                                                 onTap: () {
//                                                   setState(() {
//                                                     strWorkOrderId =
//                                                         woList![index]
//                                                             .workOrderId;

//                                                     _txtWorkOrderNo.text =
//                                                         woList![index]
//                                                             .workOrderNumber!;
//                                                   });
//                                                 },
//                                                 child: Padding(
//                                                   padding: const EdgeInsets
//                                                       .symmetric(
//                                                       horizontal: 5.0,
//                                                       vertical: 7.0),
//                                                   child: Column(
//                                                     children: [
//                                                       Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .spaceBetween,
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .center,
//                                                         children: [
//                                                           Column(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .start,
//                                                             crossAxisAlignment:
//                                                                 CrossAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               Text(
//                                                                 woList![index]
//                                                                     .workOrderNumber!,
//                                                                 style:
//                                                                     normalText,
//                                                               ),
//                                                             ],
//                                                           ),
//                                                           strGradId == null
//                                                               ? const Icon(
//                                                                   Icons
//                                                                       .circle_outlined,
//                                                                   size: 25,
//                                                                   color: Colors
//                                                                       .grey,
//                                                                 )
//                                                               : strWorkOrderId ==
//                                                                       woList![index]
//                                                                           .workOrderId!
//                                                                   ? const Icon(
//                                                                       Icons
//                                                                           .circle,
//                                                                       size: 25,
//                                                                       color: Colors
//                                                                           .green,
//                                                                     )
//                                                                   : const Icon(
//                                                                       Icons
//                                                                           .circle_outlined,
//                                                                       size: 25,
//                                                                       color: Colors
//                                                                           .grey,
//                                                                     ),
//                                                         ],
//                                                       ),
//                                                       verticalSpaceSmall,
//                                                       const Divider(
//                                                           height: 1.0,
//                                                           color: Colors.black),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               );
//                                             }),
//                                       ),
//                                       verticalSpaceTiny,
//                                       Align(
//                                         alignment: Alignment.bottomCenter,
//                                         child: SimpleButton(
//                                           lblText: 'OK',
//                                           color: kcPrimaryColor,
//                                           onTap: () {
//                                             Navigator.pop(context);
//                                           },
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         );
//                       },
//                     )
//                   : null;
//             },
//             child: Stack(alignment: Alignment.center, children: [
//               Container(
//                 height: 45.0,
//                 decoration: BoxDecoration(
//                     color: kcTextFieldColor,
//                     border: Border.all(
//                       color: Colors.grey,
//                     ),
//                     borderRadius: const BorderRadius.all(Radius.circular(5.0))),
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//                   child: TextField(
//                     controller: _txtWorkOrderNo,
//                     autofocus: false,
//                     enabled: false,
//                     style: const TextStyle(color: Colors.black, fontSize: 15.0),
//                     decoration: const InputDecoration(
//                       border: InputBorder.none,
//                       hintText: 'Select Work Order No. (Optional)',
//                     ),
//                   ),
//                 ),
//               ),
//               const Positioned(
//                   right: 10,
//                   child: Center(
//                       child: Icon(Icons.arrow_drop_down_circle_outlined))),
//             ]),
//           ),
//         ),
//         /*Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//                 color: kcTextFieldColor,
//                 border: Border.all(
//                   color: Colors.grey,
//                 ),
//                 borderRadius: const BorderRadius.all(Radius.circular(5.0))),
//             child: Padding(
//               padding: const EdgeInsets.only(left: 8.0, right: 8.0),
//               child: SearchChoices.single(
//                 style: const TextStyle(fontSize: 15.0, color: Colors.black),
//                 items: gradeItems,
//                 value: strGradName!,
//                 hint: "Select Grade",
//                 searchHint: "Select Grade",
//                 readOnly: false,
//                 onChanged: (value) {
//                   strGradName = value;
//                   if (kDebugMode) {
//                     print(strGradName);
//                   }
//                   for (int i = 0; i < gradeDetailsList!.length; i++) {
//                     if (gradeDetailsList?[i].gradeTypeName! == strGradName) {
//                       strGradId = gradeDetailsList?[i].gradeTypeId!;
//                       strGradeUnitId = gradeDetailsList?[i].castingUnitId!;
//                       strGradeUnit = gradeDetailsList?[i].castingUnitName!;
//                       if (kDebugMode) {
//                         print(strGradeUnitId);
//                         print(strGradeUnit);
//                       }
//                     }
//                   }
//                 },
//                 padding: strGradName == '' || strGradName == null ? 0.0 : 0.0,
//                 dialogBox: false,
//                 isExpanded: true,
//                 menuConstraints:
//                     BoxConstraints.tight(const Size.fromHeight(350.0)),
//                 onClear: () {},
//                 underline: const SizedBox(height: 0.0),
//               ),
//             ),
//           ),
//         ),*/
//       ],
//     );
//   }

//   Widget _RemarkEdit() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(
//           width: 230.0,
//           height: 40.0,
//           child: Padding(
//             padding: EdgeInsets.only(top: 15.0),
//             child: Text('Remark.',
//                 style: TextStyle(
//                     backgroundColor: Colors.white,
//                     fontSize: 15,
//                     color: Colors.black)),
//           ),
//         ),
//         horizontalSpaceSmall,
//         Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//                 color: kcTextFieldColor,
//                 border: Border.all(
//                   color: Colors.grey,
//                 ),
//                 borderRadius: const BorderRadius.all(Radius.circular(5.0))),
//             child: Padding(
//               padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//               child: TextField(
//                 enabled: true,
//                 controller: _txtRemark,
//                 maxLines: 4,
//                 style: const TextStyle(color: Colors.black, fontSize: 15.0),
//                 decoration: const InputDecoration(
//                     contentPadding: EdgeInsets.symmetric(vertical: 18.0),
//                     border: InputBorder.none,
//                     hintText: 'Enter Remark',
//                     hintStyle: TextStyle(color: Colors.black45)),
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }
// }
