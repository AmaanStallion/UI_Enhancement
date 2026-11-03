import 'dart:convert';

import 'package:alert_dialog/alert_dialog.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_broker_details.dart';
import 'package:stallion/ui/views/salesmanagement/bookingpreviewview.dart';
import 'package:stallion/utils/remove_temp_file.dart';
import '../../../models/flat_buyer_upload_files.dart';
import '../../../models/flat_buyers_list.dart';
import '../../../models/get_buyer_template.dart';
import '../../../models/get_flat_list_by_project.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import '../../widgets/simple_button.dart';
import 'dart:math' as math;

class PaymentTermsView extends StatefulWidget {
  PaymentTermsView(
      {Key? key,
      this.projectName,
      this.memberShipform = "0",
      this.projectId,
      this.towarId,
      this.buyerName,
      this.buyerEmail,
      this.flaginvestor,
      this.buyerMobileNumber,
      this.flatArea,
      this.strFinishingTypeSelected,
      this.arrSelectedFlatForSaleList,
      this.strParkingID,
      this.strNoOfParking,
      this.strAadharCardNo,
      this.strPanCardNo,
      this.arrSelectedParkingList,
      this.strSalesLeadId,
      this.strFlatValue,
      this.strFlatArea,
      this.strRateSqFt,
      this.RatePerSqFt,
      this.strGSTValue,
      this.TotalValue,
      this.strMarketValue,
      this.strSDValue,
      this.strStampDutyFlag,
      this.arrCharges,
      this.strBuyerID,
      this.strBrokerIDSelected,
      this.strBrokerPercentage,
      this.arrayAadharFilesBytes,
      this.arrayPanCardFilesBytes,
      this.arrAadharFilesUpload,
      this.arrPanFilesUpload,
      this.arrBuyerDetails,
      this.strAddress,
      this.fundingType,
      this.strRemark,
      this.member_dob,
      this.spouse_name,
      this.spouse_dob,
      this.child_name_1,
      this.child_1_dob,
      this.child_name_2,
      this.child_2_dob,
      this.wedding_aniversary,
      this.residential_address,
      this.correspndence_address,
      this.exprected_wedding_year,
      this.member_ship_period,
      this.member_aadhar_no,
      this.towarName = "",
      this.arr_buyer_flatlist,
      required this.tdsPercentage,
      required this.tdsValue,
      this.flatNumber,
      required this.gst_percentage,
      required this.gst_value})
      : super(key: key);
  final List<FlatBuyerInfo>? arr_buyer_flatlist;

  final String? towarName;
  final String? flatNumber;
  final String? memberShipform;
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? buyerName;
  final String? buyerEmail;
  final String? buyerMobileNumber;
  final String? flaginvestor;
  final double? flatArea;
  final String? strNoOfParking;
  final String? strFinishingTypeSelected;
  final String? strParkingID;
  final String? strPanCardNo;
  final String? strAadharCardNo;
  final String? strSalesLeadId;
  final double? RatePerSqFt;
  final String? strFlatValue;
  final String? strFlatArea;
  final String? strRateSqFt;
  final String? strGSTValue;
  final String? strSDValue;
  final String? TotalValue;
  final String? strMarketValue;
  final String? strStampDutyFlag;
  final String? strBuyerID;
  final String? strBrokerIDSelected;
  final String? strBrokerPercentage;
  final String? strAddress;
  List<CustomCharge>? arrCharges;
  List<FlatList>? arrSelectedFlatForSaleList;
  List<ParkingList>? arrSelectedParkingList;
  List<PlatformFile>? arrayAadharFilesBytes;
  List<PlatformFile>? arrayPanCardFilesBytes;
  final String? fundingType;
  final String? strRemark;

  final String? member_dob;
  final String? spouse_name;
  final String? spouse_dob;
  final String? child_name_1;
  final String? child_1_dob;
  final String? child_name_2;
  final String? child_2_dob;
  final String? wedding_aniversary;
  final String? residential_address;
  final String? correspndence_address;
  final String? exprected_wedding_year;
  final String? member_ship_period;
  final String? member_aadhar_no;
  final String? tdsPercentage;
  final String? tdsValue;
  final String? gst_percentage;
  final String? gst_value;

  // "member_dob": txtMemberDOBControler.text,
  // "spouse_name": _txtControllerSpouseName.text,
  // "spouse_dob": txtSpouseDOB.text,
  // "child_name_1": _txtControllerChild1Name.text,
  // "child_1_dob": txtChild1DOB.text,
  // "child_name_2": _txtControllerChild2Name.text,
  // "child_2_dob": txtChild2DOB.text,
  // "wedding_aniversary": txtAniversaryDOB.text,
  // "residential_address": _txtControllerResidentialAddress.text,
  // "correspndence_address": _txtControllerCorrespondenceAddress.text,
  // "exprected_wedding_year": _txtControllerExpectedWeddingYear.text,
  // "member_ship_period": _txtControllerMembershipPeriod.text,
  // "member_aadhar_no": _txtControllerAadharNo.text,

  List<BuyerUploadFiles>? arrAadharFilesUpload;
  List<BuyerUploadFiles>? arrPanFilesUpload;

  List<BuyerListDetail>? arrBuyerDetails;

  @override
  State<PaymentTermsView> createState() => _PaymentTermsViewState();
}

class _PaymentTermsViewState extends State<PaymentTermsView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  TextEditingController _searchController = TextEditingController();
  TextEditingController _customTypeController = TextEditingController();

  String _searchQuery = "";

  double? totalPercentage = 0.0;
  double? totalAmount = 0.0;

  late List<DragAndDropList> _contents;
  bool flagcenterAddbutton = false;
  bool flagcalled = false;
  List<MasoryList>? arrayList = [];

  var flagSelectedTab = 'Custom';
  var strSelectedTemplate = '';

  List<MasoryList>? masoryList;
  List<DefaultMasonryList>? defaultMasonryList;
  List<SalesType>? salesType;
  List<SalesType>? salesTypeOriginal;
  List<FinishingTypeList>? finishingTypeList;

  Future<ResponseWebgetbuyertemplate?> webServiceForGetBuyerList() async {
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
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(AppUrl.wsForGetBuyerList, data);
    if (kDebugMode) {
      print(response.statusCode);
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = webgetbuyertemplateFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        masoryList = dataModel.response?.masoryList;
        var arrList = dataModel.response?.defaultMasonryList;
        salesType = dataModel.response?.salesType;
        salesTypeOriginal = dataModel.response?.salesType;
        finishingTypeList = dataModel.response?.finishingTypeList;

        defaultMasonryList = [];

        for (int i = 0; i < masoryList!.length; i++) {
          masoryList![i].payment_amount = '';
          var percentage = masoryList![i].masonry_percentage!.trim();
          if (percentage.isNotEmpty && widget.TotalValue!.isNotEmpty) {
            var actualAmt = (double.parse('${widget.TotalValue}') *
                    double.parse(percentage) /
                    100)
                .round()
                .toStringAsFixed(2);
            print(actualAmt);
            masoryList![i].payment_amount = actualAmt;
          }
          masoryList![i].payment_name = masoryList![i].masonry_name;
          masoryList![i].payment_percentage = masoryList![i].masonry_percentage;
          masoryList![i].advanceFlag = '0';
        }
        DefaultMasonryList? dict = DefaultMasonryList(
          name: "Default Payment Template",
          details: masoryList,
        );
        defaultMasonryList!.add(dict);

        for (int i = 0; i < arrList!.length; i++) {
          var list = arrList[i].details;
          for (int j = 0; j < list!.length; j++) {
            String percentage = list[j].masonry_percentage?.trim() ?? '0';
            print("${percentage}=====================");
            if (percentage.isNotEmpty && widget.TotalValue!.isNotEmpty) {
              var actualAmt = (double.parse('${widget.TotalValue}') *
                      double.parse(percentage) /
                      100)
                  .round()
                  .toStringAsFixed(2);
              print(actualAmt);
              list[j].payment_amount = actualAmt;
            }
            list[j].payment_name = list[j].masonry_name;
            list[j].payment_percentage = list[j].masonry_percentage;
            list[j].advanceFlag = '0';
            arrList[i].details = list;
          }
          defaultMasonryList!.add(arrList[i]);
        }

        print(defaultMasonryList);

        strSelectedTemplate = defaultMasonryList![0].name!;

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
  }

  Future<ResponseWebgetbuyertemplate?> webServiceForAddNewPayment() async {
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
      "sales_type_name": _customTypeController.text,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.webSetPaymentTermsTitle, data);
    if (kDebugMode) {
      print(response.statusCode);
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = webgetbuyertemplateFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          salesType = dataModel.response?.salesType;
          salesTypeOriginal = dataModel.response?.salesType;
        });
        _customTypeController.clear();
        _searchController.clear();
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
  }

  MasoryList? dict = MasoryList(
      payment_percentage: "",
      payment_amount: "",
      payment_date: "",
      payment_name: "",
      payment_id: "",
      masonry_id: "",
      flat_id: "",
      advanceFlag: "0",
      select_type_id: "",
      template_remark: "",
      date_show: "0",
      masonry_percentage: '');

  List<TextEditingController> _controllerstxtHeaderTitle = [];
  List<TextEditingController> _controllerstxtRemarkDate = [];
  List<TextEditingController> _controllerstxtPercentage = [];
  List<TextEditingController> _controllerstxtAmount = [];

  TextEditingController txtControllerAdvanceAmt = TextEditingController();
  TextEditingController txtControllerRemark = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    arrayList!.add(dict!);
    updateContent();
    webServiceForGetBuyerList();
  }

  void updateContent() {
    setState(() {
      _contents = List.generate(arrayList!.length, (index) {
        _controllerstxtHeaderTitle.add(TextEditingController());
        _controllerstxtRemarkDate.add(TextEditingController());
        _controllerstxtPercentage.add(TextEditingController());
        _controllerstxtAmount.add(TextEditingController());
        return DragAndDropList(
          header: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 10.0, bottom: 10.0),
                child: // Generated code for this Column Widget...
                    Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    // radius of 10
                    color: Colors.white,
                    border: Border.all(
                        color: Colors.black,
                        width: 1.0), // green as background color
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      flagSelectedTab == 'Custom'
                          ? Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 10.0, 0.0),
                                  child: IconButton(
                                    iconSize: 30.0,
                                    icon: const Icon(
                                      Icons.add_circle_outline_outlined,
                                      color: Colors.black,
                                      size: 30.0,
                                    ),
                                    onPressed: () {
                                      if (kDebugMode) {
                                        print('Header Add Clicked');
                                        print(index);
                                      }

                                      MasoryList? dict = MasoryList(
                                          payment_percentage: "",
                                          payment_amount: "",
                                          payment_date: "",
                                          payment_name: "",
                                          payment_id: "",
                                          masonry_id: "",
                                          flat_id: "",
                                          advanceFlag: "0",
                                          select_type_id: "",
                                          template_remark: "",
                                          date_show: "0",
                                          masonry_percentage: '');

                                      setState(() {
                                        arrayList!.insert(index + 1, dict);
                                        updateContent();
                                      });
                                    },
                                  ),
                                ),
                                Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 25.0, 0.0),
                                    child: IconButton(
                                      iconSize: 30.0,
                                      icon: const Icon(
                                        Icons.remove_circle_outline_outlined,
                                        color: Colors.black,
                                        size: 30.0,
                                      ),
                                      onPressed: () {
                                        if (kDebugMode) {
                                          print('Header Remove Clicked');
                                        }

                                        _controllerstxtHeaderTitle
                                            .removeAt(index);
                                        _controllerstxtRemarkDate
                                            .removeAt(index);
                                        _controllerstxtPercentage
                                            .removeAt(index);
                                        _controllerstxtAmount.removeAt(index);

                                        arrayList!.remove(arrayList![index]);
                                        updateContent();
                                        setState(() {
                                          if (arrayList!.isEmpty) {
                                            flagcenterAddbutton = true;
                                          }
                                        });
                                      },
                                    )),
                              ],
                            )
                          : const SizedBox(height: 10),
                      SizedBox(
                        height: 80.0,
                        child: Row(
                          children: [
                            Flexible(
                              child: Column(
                                children: [
                                  Text('Title'),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Stack(children: [
                                      TextFormField(
                                        readOnly: true,
                                        style: normalText,
                                        onTap: () {
                                          print('Title');

                                          showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (context) {
                                                return StatefulBuilder(builder:
                                                    (context, setState) {
                                                  return AlertDialog(
                                                    title: const Center(
                                                      child: Text(
                                                          'Select Payment Title'),
                                                    ),
                                                    actionsAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    content: SizedBox(
                                                      height: 400,
                                                      width: 400,
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 50,
                                                            child: TextField(
                                                              controller:
                                                                  _searchController,
                                                              onChanged:
                                                                  (value) {
                                                                if (value
                                                                    .isNotEmpty) {
                                                                  var filteredList = salesTypeOriginal
                                                                      ?.where((element) => element
                                                                          .name!
                                                                          .toLowerCase()
                                                                          .contains(
                                                                              value.toLowerCase()))
                                                                      .toList();
                                                                  setState(() {
                                                                    salesType =
                                                                        filteredList;
                                                                  });
                                                                } else {
                                                                  setState(() {
                                                                    salesType =
                                                                        salesTypeOriginal;
                                                                  });
                                                                }
                                                              },
                                                              decoration:
                                                                  const InputDecoration(
                                                                hintText:
                                                                    'Search',
                                                                border:
                                                                    OutlineInputBorder(),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Expanded(
                                                            child: ListView
                                                                .builder(
                                                              itemCount:
                                                                  salesType!
                                                                      .length,
                                                              itemBuilder:
                                                                  (BuildContext
                                                                          context,
                                                                      int indexList) {
                                                                return InkWell(
                                                                  onTap: () {
                                                                    _updatetitle(
                                                                        index,
                                                                        indexList);
                                                                    setState(
                                                                        () {
                                                                      salesType =
                                                                          salesTypeOriginal;
                                                                    });
                                                                    _searchController
                                                                        .clear();
                                                                    print(
                                                                        '----------------------------------------------');
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child:
                                                                      SizedBox(
                                                                    // height: 50,
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        verticalSpaceTiny,
                                                                        Text(salesType![indexList]
                                                                            .name!),
                                                                        verticalSpaceTiny,
                                                                        const Divider(
                                                                          height:
                                                                              1.0,
                                                                        ),
                                                                      ],
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
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.black,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            textStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10.0),
                                                          child: Text('CLOSE',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          setState(() {
                                                            salesType =
                                                                salesTypeOriginal;
                                                          });
                                                          _searchController
                                                              .clear();
                                                          print(
                                                              '----------------------------------------------');
                                                        },
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.black,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            textStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10.0),
                                                          child: Text(
                                                              'ADD CUSTOM',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          _showTextFieldAlert(
                                                              context);
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                });
                                              });
                                        },
                                        controller: TextEditingController
                                            .fromValue(TextEditingValue(
                                                text: arrayList![index]
                                                    .payment_name
                                                    .toString(),
                                                selection:
                                                    TextSelection.collapsed(
                                                        offset:
                                                            arrayList![index]
                                                                .payment_name
                                                                .toString()
                                                                .length))),
                                        obscureText: false,
                                        decoration: const InputDecoration(
                                          filled: true,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 15.0, horizontal: 15.0),
                                          hintText: 'Title',
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.black54,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4.0),
                                              topRight: Radius.circular(4.0),
                                              bottomLeft: Radius.circular(4.0),
                                              bottomRight: Radius.circular(4.0),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.black54,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4.0),
                                              topRight: Radius.circular(4.0),
                                              bottomLeft: Radius.circular(4.0),
                                              bottomRight: Radius.circular(4.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Positioned(
                                          right: 10,
                                          top: 13,
                                          child: Icon(
                                            Icons.arrow_drop_down_outlined,
                                            size: 25,
                                          ))
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Column(
                                children: [
                                  Text('Remarks/Date'),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: TextFormField(
                                      readOnly:
                                          arrayList![index].date_show == "1"
                                              ? true
                                              : false,
                                      onTap: () async {
                                        print('Tapped');
                                        if (arrayList![index].date_show ==
                                            "1") {
                                          DateTime? pickedDate =
                                              await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime
                                                      .now(), //get today's date
                                                  firstDate: DateTime(
                                                      2000), //DateTime.now() - not to allow to choose before today.
                                                  lastDate: DateTime(2501));
                                          if (pickedDate != null) {
                                            if (kDebugMode) {
                                              print(pickedDate);
                                            } //get the picked date in the format => 2022-07-04 00:00:00.000
                                            String formattedDate =
                                                DateFormat('dd-MM-yyyy').format(
                                                    pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
                                            if (kDebugMode) {
                                              print(formattedDate);
                                            }
                                            setState(() {
                                              //dateController.text = formattedDate;
                                              arrayList![index].masnory_date =
                                                  formattedDate;
                                              arrayList![index].payment_date =
                                                  formattedDate;
                                              arrayList![index]
                                                      .template_remark =
                                                  formattedDate;
                                              updateContent();
                                            });
                                          } else {
                                            print("Date is not selected");
                                          }
                                        }
                                      },
                                      onChanged: (text) {
                                        setState(() {
                                          arrayList![index].template_remark =
                                              text;
                                          arrayList![index].masnory_date = '';
                                          arrayList![index].payment_date = '';
                                        });
                                        if (kDebugMode) {
                                          print(arrayList);
                                        }
                                      },
                                      style: normalText,
                                      controller:
                                          TextEditingController.fromValue(
                                        TextEditingValue(
                                          text:
                                              // arrayList![index].date_show == "1"
                                              //     ? arrayList![index]
                                              //         .payment_date
                                              //         .toString()
                                              //     :
                                              arrayList![index]
                                                  .template_remark
                                                  .toString(),
                                          selection: TextSelection.collapsed(
                                              offset:
                                                  arrayList![index].date_show ==
                                                          "1"
                                                      ? arrayList![index]
                                                          .payment_date
                                                          .toString()
                                                          .length
                                                      : arrayList![index]
                                                          .template_remark
                                                          .toString()
                                                          .length),
                                        ),
                                      ),
                                      obscureText: false,
                                      decoration: const InputDecoration(
                                        filled: true,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 15.0, horizontal: 15.0),
                                        hintText: 'Remark/Date',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.black54,
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(4.0),
                                            topRight: Radius.circular(4.0),
                                            bottomLeft: Radius.circular(4.0),
                                            bottomRight: Radius.circular(4.0),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.black54,
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(4.0),
                                            topRight: Radius.circular(4.0),
                                            bottomLeft: Radius.circular(4.0),
                                            bottomRight: Radius.circular(4.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Column(
                                children: [
                                  Text('Percentage'),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: TextFormField(
                                      onChanged: (text) {
                                        if (text.isNotEmpty &&
                                            widget.TotalValue!.isNotEmpty) {
                                          var actualAmt = (double.parse(
                                                      '${widget.TotalValue}') *
                                                  double.parse(text) /
                                                  100)
                                              .toStringAsFixed(2);
                                          print(actualAmt);
                                          arrayList![index].payment_percentage =
                                              text;
                                          arrayList![index].masonry_percentage =
                                              text;
                                          arrayList![index].payment_amount =
                                              actualAmt;

                                          totalPercentage = 0.0;
                                          totalAmount = 0.0;
                                          for (int i = 0;
                                              i < arrayList!.length;
                                              i++) {
                                            if (arrayList![i]
                                                .payment_percentage!
                                                .isNotEmpty) {
                                              totalPercentage =
                                                  totalPercentage! +
                                                      double.parse(arrayList![i]
                                                          .payment_percentage!);
                                            }
                                            if (arrayList![i]
                                                .payment_amount!
                                                .isNotEmpty) {
                                              totalAmount = totalAmount! +
                                                  double.parse(arrayList![i]
                                                      .payment_amount!);
                                            }
                                          }
                                          setState(() {
                                            updateContent();
                                          });
                                        } else {
                                          arrayList![index].payment_percentage =
                                              '';
                                          arrayList![index].masonry_percentage =
                                              '';
                                          arrayList![index].payment_amount = '';

                                          totalPercentage = 0.0;
                                          totalAmount = 0.0;
                                          for (int i = 0;
                                              i < arrayList!.length;
                                              i++) {
                                            if (arrayList![i]
                                                .payment_percentage!
                                                .isNotEmpty) {
                                              totalPercentage =
                                                  totalPercentage! +
                                                      double.parse(arrayList![i]
                                                          .payment_percentage!);
                                            }
                                            if (arrayList![i]
                                                .payment_amount!
                                                .isNotEmpty) {
                                              totalAmount = totalAmount! +
                                                  double.parse(arrayList![i]
                                                      .payment_amount!);
                                            }
                                          }
                                          setState(() {
                                            updateContent();
                                          });
                                        }
                                      },
                                      style: normalText,
                                      controller: TextEditingController
                                          .fromValue(TextEditingValue(
                                              text: arrayList![index]
                                                  .payment_percentage
                                                  .toString(),
                                              selection:
                                                  TextSelection.collapsed(
                                                      offset: arrayList![index]
                                                          .payment_percentage
                                                          .toString()
                                                          .length))),
                                      obscureText: false,
                                      // inputFormatters: [
                                      //   DecimalTextInputFormatter(
                                      //       decimalRange: 2)
                                      // ],
                                      decoration: const InputDecoration(
                                        filled: true,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 15.0, horizontal: 15.0),
                                        hintText: 'Percentage',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.black54,
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(4.0),
                                            topRight: Radius.circular(4.0),
                                            bottomLeft: Radius.circular(4.0),
                                            bottomRight: Radius.circular(4.0),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.black54,
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(4.0),
                                            topRight: Radius.circular(4.0),
                                            bottomLeft: Radius.circular(4.0),
                                            bottomRight: Radius.circular(4.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Column(
                                children: [
                                  Text('Amount'),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: TextFormField(
                                      onChanged: (text) {
                                        if (text.isNotEmpty) {
                                          var actualPercentage =
                                              (double.parse(text) /
                                                      double.parse(
                                                          widget.TotalValue!) *
                                                      100.0)
                                                  .toStringAsFixed(3);
                                          setState(() {
                                            arrayList![index]
                                                    .payment_percentage =
                                                actualPercentage;
                                            arrayList![index]
                                                    .masonry_percentage =
                                                actualPercentage;
                                          });
                                        } else {
                                          setState(() {
                                            arrayList![index]
                                                .payment_percentage = '';
                                            arrayList![index]
                                                .masonry_percentage = '';
                                          });
                                        }
                                        arrayList![index].payment_amount = text;
                                        totalPercentage = 0.0;
                                        totalAmount = 0.0;
                                        for (int i = 0;
                                            i < arrayList!.length;
                                            i++) {
                                          if (arrayList![i]
                                              .payment_percentage!
                                              .isNotEmpty) {
                                            totalPercentage = totalPercentage! +
                                                double.parse(arrayList![i]
                                                    .payment_percentage!);
                                          }
                                          if (arrayList![i]
                                              .payment_amount!
                                              .isNotEmpty) {
                                            totalAmount = totalAmount! +
                                                double.parse(arrayList![i]
                                                    .payment_amount!);
                                          }
                                        }

                                        setState(() {
                                          updateContent();
                                        });
                                      },
                                      style: normalText,
                                      controller: TextEditingController
                                          .fromValue(TextEditingValue(
                                              text: arrayList![index]
                                                  .payment_amount
                                                  .toString(),
                                              selection:
                                                  TextSelection.collapsed(
                                                      offset: arrayList![index]
                                                          .payment_amount
                                                          .toString()
                                                          .length))),
                                      obscureText: false,
                                      decoration: const InputDecoration(
                                        filled: true,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 15.0, horizontal: 15.0),
                                        hintText: 'Amount',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.black54,
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(4.0),
                                            topRight: Radius.circular(4.0),
                                            bottomLeft: Radius.circular(4.0),
                                            bottomRight: Radius.circular(4.0),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.black54,
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(4.0),
                                            topRight: Radius.circular(4.0),
                                            bottomLeft: Radius.circular(4.0),
                                            bottomRight: Radius.circular(4.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          children: <DragAndDropItem>[
            DragAndDropItem(
              child: const SizedBox(),
            ),
          ],
        );
      });
    });
  }

  _updatetitle(int index, int indextitle) {
    arrayList![index].payment_name = salesType![indextitle].name!;
    arrayList![index].masonry_id = salesType![indextitle].id!;
    arrayList![index].payment_id = salesType![indextitle].id!;
    arrayList![index].select_type_id = salesType![indextitle].selectType!;
    arrayList![index].date_show = salesType![indextitle].dateShow!;
    setState(() {
      updateContent();
    });
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
      body: SafeArea(
        child: flagcalled == true
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(5.0, 10.0, 5.0, 10.0),
                    child: Text(
                      'SET PAYMENT TERMS',
                      style: boldText13,
                    ),
                  ),
                  const Divider(
                    height: 1.0,
                    thickness: 0.5,
                    indent: 1.0,
                    endIndent: 1.0,
                    color: Colors.black,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          child: Column(
                            children: [
                              IntrinsicHeight(
                                child: Row(
                                  children: [
                                    horizontalSpaceSmall,
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            const Text('FLAT AREA',
                                                style: boldText),
                                            verticalSpaceSmall,
                                            // Text('${widget.flatArea} Sq.Ft.',
                                            //     style: boldText13)
                                            Text(
                                                '${widget.flatArea} ${widget.memberShipform == "1" ? "" : "Sq.Ft."}',
                                                style: boldText13)
                                          ],
                                        ),
                                      ),
                                    ),
                                    const VerticalDivider(
                                      width: 1.0,
                                      thickness: 1.0,
                                      indent: 10.0,
                                      endIndent: 10.0,
                                      color: Colors.black54,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            const Text('RATE PER Sq.Ft.',
                                                style: boldText),
                                            verticalSpaceSmall,
                                            Text(
                                              currencyFormat
                                                  .format(widget.RatePerSqFt),
                                              style: boldText13,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    const VerticalDivider(
                                      width: 1.0,
                                      thickness: 1.0,
                                      indent: 10.0,
                                      endIndent: 10.0,
                                      color: Colors.black54,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            const Text('Total Value(100%)',
                                                style: boldText),
                                            verticalSpaceTiny,
                                            Text(
                                                currencyFormat.format(
                                                    double.parse(
                                                        '${widget.TotalValue}')),
                                                style: boldText13),
                                            const Text('(Excl. G.S.T)',
                                                style: normalText12),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1.0,
                          thickness: 0.5,
                          indent: 1.0,
                          endIndent: 1.0,
                          color: Colors.black,
                        ),
                        SizedBox(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      verticalSpaceSmall,
                                      const Text(
                                        'Advance Payment Received',
                                        style: normalText,
                                      ),
                                      verticalSpaceSmall,
                                      SizedBox(
                                        height: 40,
                                        width: 300,
                                        child: TextField(
                                          controller: txtControllerAdvanceAmt,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 15.0),
                                          decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 15.0),
                                            hintText: 'Amount',
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1,
                                                  color: Colors
                                                      .black45), //<-- SEE HERE
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      verticalSpaceSmall,
                                      const Text(
                                        'Remark',
                                        style: normalText,
                                      ),
                                      verticalSpaceSmall,
                                      SizedBox(
                                        height: 40,
                                        width: 300,
                                        child: TextField(
                                          controller: txtControllerRemark,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 15.0),
                                          decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 15.0),
                                            hintText: 'Enter Remark',
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1,
                                                  color: Colors
                                                      .black45), //<-- SEE HERE
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, top: 35),
                                  child: Container(
                                    width: 200,
                                    child: SimpleButton(
                                        lblText: 'SUBMIT',
                                        color: kcPrimaryColor,
                                        onTap: () {
                                          print('Advnace amount tapped');
                                          if (txtControllerAdvanceAmt
                                              .text.isEmpty) {
                                            Alert(
                                                closeIcon: const SizedBox(),
                                                padding: const EdgeInsets.only(
                                                    top: 0.0),
                                                image: Image.asset(
                                                    'images/Icon-512.png',
                                                    height: 80,
                                                    fit: BoxFit.fitWidth),
                                                style: const AlertStyle(
                                                    titleTextAlign:
                                                        TextAlign.center,
                                                    descTextAlign:
                                                        TextAlign.center,
                                                    descStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 16),
                                                    isCloseButton: true),
                                                context: context,
                                                desc:
                                                    'Please enter advance payment received.',
                                                alertAnimation:
                                                    fadeAlertAnimation,
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
                                          } else if (double.parse(
                                                  txtControllerAdvanceAmt
                                                      .text) >
                                              double.parse(
                                                  widget.TotalValue!)) {
                                            Alert(
                                                closeIcon: const SizedBox(),
                                                padding: const EdgeInsets.only(
                                                    top: 0.0),
                                                image: Image.asset(
                                                    'images/Icon-512.png',
                                                    height: 80,
                                                    fit: BoxFit.fitWidth),
                                                style: const AlertStyle(
                                                    titleTextAlign:
                                                        TextAlign.center,
                                                    descTextAlign:
                                                        TextAlign.center,
                                                    descStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 16),
                                                    isCloseButton: true),
                                                context: context,
                                                desc:
                                                    'Advance payment should not be greater than total amount.',
                                                alertAnimation:
                                                    fadeAlertAnimation,
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
                                          } else if (txtControllerRemark
                                              .text.isEmpty) {
                                            Alert(
                                                closeIcon: const SizedBox(),
                                                padding: const EdgeInsets.only(
                                                    top: 0.0),
                                                image: Image.asset(
                                                    'images/Icon-512.png',
                                                    height: 80,
                                                    fit: BoxFit.fitWidth),
                                                style: const AlertStyle(
                                                    titleTextAlign:
                                                        TextAlign.center,
                                                    descTextAlign:
                                                        TextAlign.center,
                                                    descStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 16),
                                                    isCloseButton: true),
                                                context: context,
                                                desc: 'Please enter remark.',
                                                alertAnimation:
                                                    fadeAlertAnimation,
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
                                          } else {
                                            print('Tapped');
                                            print(flagSelectedTab);
                                            if (flagSelectedTab == 'Custom') {
                                              var arrayTemplate = arrayList;
                                              arrayList = [];

                                              var actualPercentage = (double.parse(
                                                          txtControllerAdvanceAmt
                                                              .text) /
                                                      double.parse(
                                                          widget.TotalValue!) *
                                                      100.0)
                                                  .toStringAsFixed(3);

                                              MasoryList? dict = MasoryList(
                                                payment_percentage:
                                                    "$actualPercentage",
                                                payment_amount:
                                                    "${txtControllerAdvanceAmt.text}",
                                                payment_date: "",
                                                payment_name: "Advance",
                                                masonry_name: "Advance",
                                                payment_id: "",
                                                masonry_id: "1",
                                                flat_id: "",
                                                advanceFlag: "1",
                                                select_type_id: "1",
                                                template_remark:
                                                    "${txtControllerRemark.text}",
                                                date_show: "0",
                                                masonry_percentage:
                                                    "$actualPercentage",
                                              );

                                              arrayList?.add(dict);

                                              for (int i = 0;
                                                  i < arrayTemplate!.length;
                                                  i++) {
                                                if (arrayTemplate[i]
                                                        .advanceFlag !=
                                                    '1') {
                                                  arrayList
                                                      ?.add(arrayTemplate[i]);
                                                }
                                              }

                                              totalPercentage = 0.0;
                                              totalAmount = 0.0;
                                              for (int i = 0;
                                                  i < arrayList!.length;
                                                  i++) {
                                                if (arrayList![i]
                                                    .payment_percentage!
                                                    .isNotEmpty) {
                                                  totalPercentage = totalPercentage! +
                                                      double.parse(arrayList![i]
                                                          .payment_percentage!);
                                                }
                                                if (arrayList![i]
                                                    .payment_amount!
                                                    .isNotEmpty) {
                                                  totalAmount = totalAmount! +
                                                      double.parse(arrayList![i]
                                                          .payment_amount!);
                                                }
                                              }

                                              setState(() {
                                                txtControllerAdvanceAmt.text =
                                                    "";
                                                txtControllerRemark.text = "";
                                                updateContent();
                                              });
                                            } else {
                                              var arrayTemplate = arrayList;
                                              arrayList = [];

                                              var actualPercentage = (double.parse(
                                                          txtControllerAdvanceAmt
                                                              .text) /
                                                      double.parse(
                                                          widget.TotalValue!) *
                                                      100.0)
                                                  .toStringAsFixed(3);

                                              MasoryList? dict = MasoryList(
                                                payment_percentage:
                                                    "$actualPercentage",
                                                payment_amount:
                                                    "${txtControllerAdvanceAmt.text}",
                                                payment_date: "",
                                                payment_name: "Advance",
                                                masonry_name: "Advance",
                                                payment_id: "",
                                                masonry_id: "1",
                                                flat_id: "",
                                                advanceFlag: "1",
                                                select_type_id: "1",
                                                template_remark:
                                                    "${txtControllerRemark.text}",
                                                date_show: "0",
                                                masonry_percentage:
                                                    "$actualPercentage",
                                              );

                                              arrayList?.add(dict);

                                              for (int i = 0;
                                                  i < arrayTemplate!.length;
                                                  i++) {
                                                if (arrayTemplate[i]
                                                        .advanceFlag !=
                                                    '1') {
                                                  arrayList
                                                      ?.add(arrayTemplate[i]);
                                                }
                                              }

                                              totalPercentage = 0.0;
                                              totalAmount = 0.0;
                                              for (int i = 0;
                                                  i < arrayList!.length;
                                                  i++) {
                                                if (arrayList![i]
                                                    .payment_percentage!
                                                    .isNotEmpty) {
                                                  totalPercentage = totalPercentage! +
                                                      double.parse(arrayList![i]
                                                          .payment_percentage!);
                                                }
                                                if (arrayList![i]
                                                    .payment_amount!
                                                    .isNotEmpty) {
                                                  totalAmount = totalAmount! +
                                                      double.parse(arrayList![i]
                                                          .payment_amount!);
                                                }
                                              }

                                              setState(() {
                                                txtControllerAdvanceAmt.text =
                                                    "";
                                                txtControllerRemark.text = "";
                                                updateContent();
                                              });
                                            }
                                          }
                                        }),
                                  ),
                                ),
                              ]),
                        ),
                        verticalSpaceSmall,
                        const Divider(
                          height: 1.0,
                          thickness: 0.5,
                          indent: 1.0,
                          endIndent: 1.0,
                          color: Colors.black,
                        ),
                        Container(
                          height: 50,
                          child: Row(
                            children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    arrayList = [];
                                    MasoryList? dict = MasoryList(
                                      payment_percentage: "",
                                      payment_amount: "",
                                      payment_date: "",
                                      payment_name: "",
                                      payment_id: "",
                                      masonry_id: "",
                                      flat_id: "",
                                      advanceFlag: "0",
                                      select_type_id: "",
                                      template_remark: "",
                                      date_show: "0",
                                      masonry_percentage: '',
                                    );

                                    setState(() {
                                      totalAmount = 0.0;
                                      totalPercentage = 0.0;
                                      flagSelectedTab = 'Custom';
                                      arrayList!.add(dict);
                                      updateContent();
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: flagSelectedTab == 'Slab'
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    child: Text(
                                      'Custom Template',
                                      style: TextStyle(
                                        color: flagSelectedTab == 'Slab'
                                            ? Colors.black
                                            : Colors.white,
                                        fontSize: 17.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      flagSelectedTab = 'Slab';
                                      strSelectedTemplate =
                                          defaultMasonryList![0].name!;
                                      arrayList =
                                          defaultMasonryList![0].details;
                                      totalPercentage = 0.0;
                                      totalAmount = 0.0;
                                      for (int i = 0;
                                          i < arrayList!.length;
                                          i++) {
                                        if (arrayList![i]
                                            .payment_percentage!
                                            .isNotEmpty) {
                                          totalPercentage = totalPercentage! +
                                              double.parse(arrayList![i]
                                                  .payment_percentage!);
                                        }
                                        if (arrayList![i]
                                            .payment_amount!
                                            .isNotEmpty) {
                                          totalAmount = totalAmount! +
                                              double.parse(arrayList![i]
                                                  .payment_amount!);
                                        }
                                      }
                                      updateContent();
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: flagSelectedTab == 'Slab'
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                    child: Text(
                                      'Slab Wise Payment',
                                      style: TextStyle(
                                        color: flagSelectedTab == 'Slab'
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 17.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1.0,
                          thickness: 0.5,
                          indent: 1.0,
                          endIndent: 1.0,
                          color: Colors.black,
                        ),
                        flagSelectedTab == 'Slab'
                            ? GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return StatefulBuilder(
                                            builder: (context, setState) {
                                          return AlertDialog(
                                            title: const Center(
                                              child: Text(
                                                  'Select Payment Template'),
                                            ),
                                            actionsAlignment:
                                                MainAxisAlignment.center,
                                            content: Container(
                                              height: 400,
                                              width: 400,
                                              child: SizedBox(
                                                height: 400,
                                                child: ListView.builder(
                                                  itemCount: defaultMasonryList!
                                                      .length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return SizedBox(
                                                      height: 70,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    _changeTemplate(
                                                                        index);
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  icon: strSelectedTemplate ==
                                                                          defaultMasonryList![index]
                                                                              .name!
                                                                      ? const Icon(
                                                                          Icons
                                                                              .check_circle_outline_rounded,
                                                                          size:
                                                                              30,
                                                                          color:
                                                                              Colors.green,
                                                                        )
                                                                      : const Icon(
                                                                          Icons
                                                                              .circle_outlined,
                                                                          size:
                                                                              30,
                                                                        )),
                                                              horizontalSpaceSmall,
                                                              Text(
                                                                  defaultMasonryList![
                                                                          index]
                                                                      .name!),
                                                            ],
                                                          ),
                                                          verticalSpaceTiny,
                                                          const Divider(),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            actions: <Widget>[
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
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
                                                child: const Padding(
                                                  padding: EdgeInsets.all(10.0),
                                                  child: Text('CANCEL',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
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
                                                child: const Padding(
                                                  padding: EdgeInsets.all(10.0),
                                                  child: Text('SUBMIT',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        });
                                      });
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        strSelectedTemplate,
                                        style: TextStyle(
                                          color: flagSelectedTab == 'Slab'
                                              ? Colors.black
                                              : Colors.white,
                                          fontSize: 17.0,
                                        ),
                                      ),
                                      horizontalSpaceSmall,
                                      const Icon(Icons.arrow_drop_down_outlined,
                                          size: 25)
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        const Divider(
                          height: 1.0,
                          thickness: 0.5,
                          indent: 1.0,
                          endIndent: 1.0,
                          color: Colors.black,
                        ),
                        verticalSpaceSmall,
                        Expanded(
                          child: DragAndDropLists(
                            children: _contents,
                            onItemReorder: _onItemReorder,
                            onListReorder: _onListReorder,
                          ),
                        ),
                      ],
                    ),
                  ),
                  verticalSpaceSmall,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(
                        height: 1.0,
                        thickness: 0.5,
                        indent: 1.0,
                        endIndent: 1.0,
                        color: Colors.black,
                      ),
                      verticalSpaceSmall,
                      SizedBox(
                        height: 40.0,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Center(
                                        child:
                                            Text('Total', style: boldText13)),
                                  ),
                                ),
                                const VerticalDivider(
                                  width: 1.0,
                                  thickness: 1.0,
                                  indent: 5.0,
                                  endIndent: 0.0,
                                  color: Colors.black54,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Center(
                                        child: Text(
                                            '${totalPercentage!.toStringAsFixed(2)} %',
                                            style: boldText13)),
                                  ),
                                ),
                                const VerticalDivider(
                                  width: 1.0,
                                  thickness: 1.0,
                                  indent: 5.0,
                                  endIndent: 0.0,
                                  color: Colors.black54,
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Center(
                                        child: RichText(
                                      text: TextSpan(
                                        text: '',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 13),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: currencyFormat
                                                .format(totalAmount),
                                            // '\u{20B9} ${totalAmount!.toStringAsFixed(2)} ',
                                            style: boldText13,
                                          ),
                                          if ((double.parse(
                                                      '${widget.TotalValue}') -
                                                  totalAmount! !=
                                              0))
                                            TextSpan(
                                              text:
                                                  '  (${currencyFormat.format(double.parse('${widget.TotalValue}') - totalAmount!)})',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                        // Text(
                                        //     '\u{20B9} ${totalAmount!.toStringAsFixed(2)}',
                                        //     style: boldText13)
                                        ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const Divider(
                        height: 1.0,
                        thickness: 0.5,
                        indent: 1.0,
                        endIndent: 1.0,
                        color: Colors.black,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 70.0, right: 70.0, bottom: 10.0, top: 10.0),
                        child: SimpleButton(
                          lblText: 'PREVIEW BOOKING',
                          color: kcPrimaryColor,
                          onTap: () {
                            print(totalPercentage);
                            if (totalPercentage!.isBetween(99.98, 101)) {
                              if (totalAmount !=
                                  double.parse(widget.TotalValue!)) {
                                var diff = double.parse(widget.TotalValue!) -
                                    totalAmount!;
                                print(diff);

                                Alert(
                                    closeIcon: const SizedBox(),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10.0),
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
                                    desc:
                                        'The difference amount of \u{20B9} ${diff.toStringAsFixed(2)} will be \nadjusted in your final payment template',
                                    alertAnimation: fadeAlertAnimation,
                                    buttons: [
                                      DialogButton(
                                        onPressed: () {
                                          //if (flagSelectedTab == 'Custom') {
                                          arrayList![arrayList!.length - 1]
                                                  .payment_amount =
                                              '${double.parse(arrayList![arrayList!.length - 1].payment_amount!) + diff}';
                                          // }

                                          arrayList![arrayList!.length - 1]
                                                  .payment_percentage =
                                              (double.parse(arrayList![arrayList!
                                                                      .length -
                                                                  1]
                                                              .payment_amount ??
                                                          '0') /
                                                      double.parse(
                                                          widget.TotalValue ??
                                                              '0') *
                                                      100)
                                                  .toStringAsFixed(3);

                                          totalPercentage = 0.0;
                                          totalAmount = 0.0;
                                          for (int i = 0;
                                              i < arrayList!.length;
                                              i++) {
                                            if (arrayList![i]
                                                .payment_percentage!
                                                .isNotEmpty) {
                                              totalPercentage =
                                                  totalPercentage! +
                                                      double.parse(arrayList![i]
                                                          .payment_percentage!);
                                            }
                                            if (arrayList![i]
                                                .payment_amount!
                                                .isNotEmpty) {
                                              totalAmount = totalAmount! +
                                                  double.parse(arrayList![i]
                                                      .payment_amount!);
                                            }
                                          }

                                          setState(() {
                                            updateContent();
                                          });

                                          Navigator.pop(context);
                                        },
                                        color: Colors.black,
                                        child: const Text(
                                          "CLOSE",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                      ),
                                    ]).show();
                              } else {
                                bool errorflag = false;
                                var errorMessage = '';

                                for (var i = 0; i < arrayList!.length; i++) {
                                  var title =
                                      arrayList![i].payment_name.toString();
                                  var percentage = arrayList![i]
                                      .payment_percentage
                                      .toString();
                                  if (title.isNotEmpty && percentage.isEmpty) {
                                    errorMessage = 'Please enter percentage';
                                    errorflag = true;
                                    break;
                                  } else if (title.isEmpty &&
                                      percentage.isNotEmpty) {
                                    errorMessage = 'Please enter title';
                                    errorflag = true;
                                    break;
                                  }
                                }

                                if (errorflag == true) {
                                  Alert(
                                      closeIcon: const SizedBox(),
                                      padding: const EdgeInsets.only(top: 0.0),
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
                                      desc: errorMessage,
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
                                } else {
                                  if (kDebugMode) {
                                    print('NEXT PAGE');
                                  }
                                  List<MasoryList>? arrActualListSent = [];
                                  for (var i = 0; i < arrayList!.length; i++) {
                                    var title = arrayList![i]
                                        .payment_percentage
                                        .toString();
                                    if (title != '' && title != '0') {
                                      arrActualListSent.add(arrayList![i]);
                                    }
                                  }
                                  if (kDebugMode) {
                                    print('----arrActualListSent-----');
                                    print(arrActualListSent);
                                  }

                                  var projectId = widget.projectId!;
                                  var projectName = widget.projectName!;
                                  print('----------------');
                                  print(jsonEncode(widget.arr_buyer_flatlist));
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return BookingPreviewView(
                                            gst_percentage:
                                                widget.gst_percentage,
                                            gst_value: widget.gst_value,
                                            tdsPercentage: widget.tdsPercentage,
                                            tdsValue: widget.tdsValue,
                                            arr_buyer_flatlist:
                                                widget.arr_buyer_flatlist,
                                            towarName: widget.towarName,
                                            member_dob: widget.member_dob ?? '',
                                            spouse_name:
                                                widget.spouse_name ?? '',
                                            spouse_dob: widget.spouse_dob ?? '',
                                            child_name_1:
                                                widget.child_name_1 ?? '',
                                            child_1_dob:
                                                widget.child_1_dob ?? '',
                                            child_name_2:
                                                widget.child_name_2 ?? '',
                                            child_2_dob:
                                                widget.child_2_dob ?? '',
                                            wedding_aniversary:
                                                widget.wedding_aniversary ?? '',
                                            residential_address:
                                                widget.residential_address ??
                                                    '',
                                            correspndence_address:
                                                widget.correspndence_address ??
                                                    '',
                                            exprected_wedding_year:
                                                widget.exprected_wedding_year ??
                                                    '',
                                            member_ship_period:
                                                widget.member_ship_period ?? '',
                                            member_aadhar_no:
                                                widget.member_aadhar_no ?? '',
                                            memberShipform:
                                                widget.memberShipform,
                                            projectId: projectId,
                                            towarId: widget.towarId!,
                                            arrAadharFilesUpload:
                                                widget.arrAadharFilesUpload,
                                            arrPanFilesUpload:
                                                widget.arrPanFilesUpload,
                                            projectName: projectName,
                                            flatNumber: widget.flatNumber,
                                            arrBuyerDetails:
                                                widget.arrBuyerDetails,
                                            buyerName: widget.buyerName,
                                            buyerEmail: widget.buyerEmail,
                                            strAddress: widget.strAddress,
                                            flatArea: widget.flatArea,
                                            arrSelectedFlatForSaleList: widget
                                                .arrSelectedFlatForSaleList,
                                            buyerMobileNumber:
                                                widget.buyerMobileNumber,
                                            strFinishingTypeSelected:
                                                widget.strFinishingTypeSelected,
                                            strNoOfParking: widget.strNoOfParking,
                                            strSalesLeadId: widget.strSalesLeadId,
                                            arrSelectedParkingList: widget.arrSelectedParkingList,
                                            strPanCardNo: widget.strPanCardNo,
                                            strAadharCardNo: widget.strAadharCardNo,
                                            RatePerSqFt: widget.RatePerSqFt,
                                            strFlatValue: widget.strFlatValue,
                                            strFlatArea: widget.strFlatArea,
                                            strRateSqFt: widget.strRateSqFt,
                                            strGSTValue: widget.strGSTValue,
                                            strSDValue: widget.strSDValue,
                                            TotalValue: widget.TotalValue,
                                            strMarketValue: widget.strMarketValue,
                                            strPaymentTermType: flagSelectedTab == 'Custom' ? '0' : '1',
                                            strStampDutyFlag: widget.strStampDutyFlag,
                                            arrCharges: widget.arrCharges,
                                            strBuyerID: widget.strBuyerID,
                                            strBrokerIDSelected: widget.strBrokerIDSelected,
                                            strBrokerPercentage: widget.strBrokerPercentage,
                                            strParkingID: widget.strParkingID,
                                            arrayList: arrActualListSent,
                                            arrayAadharFilesBytes: widget.arrayAadharFilesBytes,
                                            arrayPanCardFilesBytes: widget.arrayPanCardFilesBytes,
                                            strRemark: widget.strRemark!,
                                            fundingType: widget.fundingType,
                                            flaginvestor: widget.flaginvestor);
                                      },
                                    ),
                                  ).then((value) => {});
                                }
                              }
                            } else if (totalPercentage != 100) {
                              Alert(
                                  closeIcon: const SizedBox(),
                                  padding: const EdgeInsets.only(top: 0.0),
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
                                  desc: 'Please match total percentage to 100.',
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
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  _changeTemplate(int index) {
    setState(() {
      strSelectedTemplate = defaultMasonryList![index].name!;
      arrayList = defaultMasonryList![index].details!;

      totalPercentage = 0.0;
      totalAmount = 0.0;
      for (int i = 0; i < arrayList!.length; i++) {
        if (arrayList![i].payment_percentage!.isNotEmpty) {
          totalPercentage = totalPercentage! +
              double.parse(arrayList![i].payment_percentage!);
        }
        if (arrayList![i].payment_amount!.isNotEmpty) {
          totalAmount =
              totalAmount! + double.parse(arrayList![i].payment_amount!);
        }
      }

      updateContent();
    });
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      var movedItem = _contents[oldListIndex].children.removeAt(oldItemIndex);
      _contents[newListIndex].children.insert(newItemIndex, movedItem);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = _contents.removeAt(oldListIndex);
      _contents.insert(newListIndex, movedList);
    });
  }

  void _showTextFieldAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter Custom Payment Title"),
          content: TextField(
            // Add your customizations to the TextField here
            controller: _customTypeController,
            decoration: InputDecoration(
              hintText: "Custom Title",
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("OK"),
              onPressed: () {
                // Add your logic for the 'OK' button here
                // You can access the text field value using the controller
                if (_customTypeController.text.isEmpty) {
                  //Navigator.of(context).pop();

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(""),
                      content: Text("Please enter payment title."),
                      actionsAlignment: MainAxisAlignment.center,
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('CLOSE'),
                        ),
                      ],
                    ),
                  );
                } else {
                  var flag = false;
                  for (int i = 0; i < salesTypeOriginal!.length; i++) {
                    if (salesTypeOriginal![i].name?.toLowerCase() ==
                        _customTypeController.text.toLowerCase()) {
                      flag = true;
                      break;
                    }
                  }
                  if (flag == true) {
                    print('IN');
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(""),
                        content: Text(
                            "Entered payment title has already exists. Please enter new payment title or select from a payment title list."),
                        actionsAlignment: MainAxisAlignment.center,
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('CLOSE'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    print('Else');
                    Navigator.of(context).pop();
                    webServiceForAddNewPayment();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}

extension Range on num {
  bool isBetween(num from, num to) {
    return from < this && this < to;
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange == null || decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}
