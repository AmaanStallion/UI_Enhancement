import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_awesome_select/flutter_awesome_select.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/getBuyerPaymentsDetailsNew.dart';
import 'package:stallion/models/get_all_sales_lead.dart';
// import 'package:stallion/models/flat_status.dart' as saleflatstatus;
import 'package:stallion/models/get_broker_details.dart' as salebuyer;
import 'package:stallion/models/get_broker_details.dart';
import 'package:stallion/models/ws_get_buyer_payment_details.dart';
// import 'package:stallion/models/ws_get_buyer_payment_details.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/salesmanagement/buyerdetailsview_endbuyer.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import '../../../models/get_flat_list_by_project.dart';
import '../../../models/message_success.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import 'buyerdetailsview.dart';

class BookaSaleFormView extends StatefulWidget {
  BookaSaleFormView({
    Key? key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName = "",
    this.flatBuyerRequest,
    this.flagRedirect, //Inventory  InventoryNew
    this.buyerName = '',
    this.emailId = '',
    this.mobileNumber = '',
    this.flatNoIds,
    this.totalflatAreaCount = "",
    this.isFlatListFromReserve,
    this.strBuyerID = "",
    this.flatbuyerid = '',
    this.flatidfk = '',
    this.salesLeadData,
    this.buyerContactDetails,
    this.customCharges,
    this.floor_type_id,
  });
  List<List<CustomCharge>>? customCharges;
  String? floor_type_id;
  final String? projectId;
  final String? towarId;
  final String? towarName;

  final String? projectName;
  final String? flagRedirect;
  final String? totalflatAreaCount;
  final String? strBuyerID;
  List<String?>? flatNoIds;
  FlatList? isFlatListFromReserve;

  final String? flatbuyerid;
  final String? flatidfk;

  String buyerName;
  String emailId;
  String mobileNumber;
  salebuyer.FlatBuyerRequest? flatBuyerRequest;
  final SalesLead? salesLeadData;

  List<FlatBuyerInfo>? buyerContactDetails = [];

  @override
  State<BookaSaleFormView> createState() => _BookaSaleFormViewState();
}

class _BookaSaleFormViewState extends State<BookaSaleFormView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController _textFieldController = TextEditingController();
  String searchText = '';
  String searchFlatNumberText = '';
  String searchTextBroker = '';

  List<FlatBuyerInfo>? endBuyerByerControllers = [FlatBuyerInfo(id: "")];

  String calVal({required int index}) {
    double temp = 0;
    if (otherChargesOneTime[index].unit == 'per Sq.ft.') {
      temp = double.parse(txtOtherChargesOneTimeAmount![index].text == ""
              ? '0'
              : txtOtherChargesOneTimeAmount![index].text) *
          double.parse(
              (_txtControllerArea.text == "" ? "0" : _txtControllerArea.text)
                  .replaceAll('SqFt', ""));
    } else {
      temp = double.parse(txtOtherChargesOneTimeAmount![index].text == ""
              ? '0'
              : txtOtherChargesOneTimeAmount![index].text) *
          _flatNo!.length;
    }

    double tempp2 =
        (temp * double.parse(otherChargesOneTime[index].chargesGst!)) / 100;
    return (temp + tempp2).toStringAsFixed(2);
  }

  NetworkHandler apiNetworkHandler = NetworkHandler();

  late FocusNode _focusRatePerSqFt;
  late FocusNode _focusAgreementValue;

  List<Map<String, String>> flats = [];
  List<Map<String, String>> finishingType = [];
  //List<Map<String, String>> otherCharges = [];
  //List<Map<String, String>> otherChargesSelected = [];
  List<Map<String, String>> broker = [];

  List<String?> _flatNo = [];
  List<CustomCharge> otherCharges = [];
  List<CustomCharge> otherChargesOneTime = [];
  String? _broker = '';
  // String? _finishingType = '';

  bool flagParking = false;
  bool flagcalled = false;
  String? buyerType = "End Buyer";
  String? fundingType = "Self Funding";
  String? strParkingSelectedNo = "";

  var gstValue = 0.0;
  var SDValue = 0.0;
  double tdsValue = 0.0;

  bool flagSDValue = false;
  bool flagTDSValue = false;

  List<FinishingBookList>? finishingBookList;
  List<PodiumList>? podiumList = [];
  Percentagate? percentagate;
  List<FlatList>? flatList;
  List<List<CustomCharge>>? customCharges;
  List<BorkerList>? borkerList;

  List<ParkingList>? arrSelectedParkingList = [];

  int totalPark = 0;

  final TextEditingController _txtControllerBuyerName = TextEditingController();
  final TextEditingController _txtControllerEmailAddress =
      TextEditingController();
  final TextEditingController _txtControllerMobileNumber =
      TextEditingController();
  final TextEditingController _txtControllerArea = TextEditingController();
  final TextEditingController _txtControllerRatePerSqFt =
      TextEditingController();
  final TextEditingController _txtControllerLeaseValueMonthly =
      TextEditingController();
  final TextEditingController _txtControllerLeaseValueYearly =
      TextEditingController();
  final TextEditingController _txtControllerFlatAgreementValue =
      TextEditingController();
  final TextEditingController _txtControllerRemark = TextEditingController();
  final TextEditingController _txtControllerFlatMarketValue =
      TextEditingController();
  final TextEditingController _txtControllerOthercharges =
      TextEditingController();
  final TextEditingController _txtControllerBrokerPercentage =
      TextEditingController();
  final TextEditingController _txtControllerGstPercentage =
      TextEditingController();

  double gst_value = 0.0;
  final TextEditingController _txtcontrollerParkingCount =
      TextEditingController();

  List<TextEditingController>? txtOtherChargesAmount = [];
  List<TextEditingController>? txtOtherChargesOneTimeAmount = [];

  String? strSlabID = '';
  String? strSdValue = '0';
  String? strParkingTypeSelected = "";
  String? strJSONCharges = "";
  //String strBrokerIDSelected = "";
  int strStampDutyFlag = 0;
  String strSalesLeadId = "";
  String strFinishingTypeSelected = '';
  String strOtherChargesSelected = '';
  String strBuyerID = '';
  double selectedTotalOtherCharges = 0.0;
  double strTotalValueBottom = 0.0;
  double totalCustomChargesGST = 0.0;
  FinishingBookList? selectedFinishingType;
  FlatList? selectedFinishingFlatNumber;
  String? averagePrice = '';

  BorkerList? selectedBrokerType;
  double totalflatarea = 0.0;
  TextEditingController finishingtypeController = TextEditingController();

  TextEditingController finishingBrokerController = TextEditingController();

  TextEditingController flatNoController = TextEditingController();

  List<FinishingBookList>? filteredProjects() {
    // List<FinishingBookList>? finishingBookList
    if (searchText.isEmpty) {
      return finishingBookList!;
    }
    return finishingBookList!.where((project) {
      return project.mstFinishingName!
          .toLowerCase()
          .contains(searchText.toLowerCase());
    }).toList();
  }

// List<BorkerList>? borkerList
  List<BorkerList>? filteredBrokerProjects() {
    // List<FinishingBookList>? finishingBookList
    if (searchTextBroker.isEmpty) {
      return borkerList!;
    }
    return borkerList!.where((project) {
      return project.companyName!
          .toLowerCase()
          .contains(searchTextBroker.toLowerCase());
    }).toList();
  }

  // List<FlatList>? flatList;
  List<FlatList>? filteredFlatNumberProjects() {
    // List<FinishingBookList>? finishingBookList
    if (searchFlatNumberText.isEmpty) {
      return flatList!;
    }
    return flatList!.where((project) {
      return project.flatName!
          .toLowerCase()
          .contains(searchFlatNumberText.toLowerCase());
    }).toList();
  }

  Future<GetBuyerPaymentsDetails?> fetchBookingPaymentDetails() async {
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
      "flat_buyer_id": widget.flatbuyerid!
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.wsgetbuyerpaymentsdetails, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getBuyerPaymentsDetailsFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        widget?.flatBuyerRequest = dataModel.response!.flatBuyerDetails?[0];
        widget.customCharges = dataModel.response?.customCharges;
        if (widget.flatBuyerRequest!.brokerName != '') {
          _broker = widget.flatBuyerRequest!.brokerIdFk ?? '';
          _txtControllerBrokerPercentage.text =
              widget.flatBuyerRequest!.brokerPercentage ?? '';
        }

        if (widget.flatBuyerRequest!.flatMarketValue! != '') {
          _txtControllerFlatMarketValue.text = currencyFormat
              .format(double.parse(widget.flatBuyerRequest!.flatMarketValue!));
        }

        if (widget.flatBuyerRequest!.flagStumpCal! != '') {
          strStampDutyFlag = int.parse(widget.flatBuyerRequest!.flagStumpCal!);
        }

        if (widget.flatBuyerRequest!.flagInvestor! == '0') {
          buyerType = 'End Buyer';
        } else {
          buyerType = 'Investor';
        }

        if (widget.flatBuyerRequest!.flatFundingType! == '0') {
          fundingType = 'Self Funding';
        } else {
          fundingType = 'Bank Funding';
        }

        if (widget.flatBuyerRequest!.flatBookingRemark!.isNotEmpty) {
          _txtControllerRemark.text =
              widget.flatBuyerRequest!.flatBookingRemark!;
        }

        if (widget.flatBuyerRequest!.flatBuyerName!.isNotEmpty) {
          _txtControllerBuyerName.text =
              widget.flatBuyerRequest!.flatBuyerName!;
        }

        if (widget.flatBuyerRequest!.flatBuyerEmail!.isNotEmpty) {
          _txtControllerEmailAddress.text =
              widget.flatBuyerRequest!.flatBuyerEmail!;
        }

        if (widget.flatBuyerRequest!.flatBuyerNumber!.isNotEmpty) {
          _txtControllerMobileNumber.text =
              widget.flatBuyerRequest!.flatBuyerNumber!;
        }

        var strFlatArea = widget.flatBuyerRequest!.flatArea!;
        strFlatArea = strFlatArea.replaceAll('SqFt', "");
        strFlatArea = strFlatArea.replaceAll(',', "");
        strFlatArea = strFlatArea.replaceAll(' ', "");
        print(strFlatArea);
        totalflatarea = double.parse(strFlatArea);
        _txtControllerArea.text = widget.flatBuyerRequest!.flatArea!;

        print(widget.flatBuyerRequest!.finshingType!);
        if (widget.flatBuyerRequest!.finshingType == "1") {
          setState(() {
            // strFinishingTypeSelected = "Raw";
            // _finishingType = widget.flatBuyerRequest!.finshingType!;
            // selectedFinishingType = finishingBookList![0];
            finishingtypeController.text = 'Raw';
            strFinishingTypeSelected = 'Raw';
          });
        } else {
          setState(() {
            // strFinishingTypeSelected = "Finished";
            // _finishingType = widget.flatBuyerRequest!.finshingType! == "0"
            //     ? "2"
            //     : widget.flatBuyerRequest!.finshingType!;
            // selectedFinishingType = finishingBookList![1];
            finishingtypeController.text = 'Finished';
            strFinishingTypeSelected = 'Finished';
          });
        }

        var rupee = "\u{20B9}";
        var strRate = widget.flatBuyerRequest!.flatRateCal!;
        strRate = strRate.replaceAll(rupee, "");
        strRate = strRate.replaceAll(',', "");
        strRate = strRate.replaceAll(' ', "");

        _txtControllerRatePerSqFt.text = strRate;

        var strFlatValue = widget.flatBuyerRequest!.flatValue;
        strFlatValue = strFlatValue?.replaceAll(rupee, "");
        strFlatValue = strFlatValue?.replaceAll(',', "");
        strFlatValue = strFlatValue?.replaceAll(' ', "");

        _txtControllerFlatAgreementValue.text =
            currencyFormat.format(double.parse(strFlatValue!));

        var strMarketValue = widget.flatBuyerRequest!.flatMarketValue;
        strMarketValue = strMarketValue?.replaceAll(rupee, "");
        strMarketValue = strMarketValue?.replaceAll(',', "");
        strMarketValue = strMarketValue?.replaceAll(' ', "");

        _txtControllerFlatMarketValue.text =
            currencyFormat.format(double.parse(strMarketValue!));

        if (widget.flatBuyerRequest!.noOfParking! != "0") {
          flagParking = true;
          _txtcontrollerParkingCount.text =
              widget.flatBuyerRequest!.noOfParking!;
        }

        strParkingTypeSelected = widget.flatBuyerRequest!.flatIdFk!;

        var arrParking = widget.flatBuyerRequest!.parkingList!;
        var selectedParking = '';
        arrSelectedParkingList = [];
        for (int i = 0; i < arrParking.length; i++) {
          if (i == 0) {
            selectedParking = arrParking[i].parkingSerialNo!;
            arrSelectedParkingList?.add(arrParking[i]);
          } else {
            selectedParking =
                '$selectedParking, ${arrParking[i].parkingSerialNo!}';
            arrSelectedParkingList?.add(arrParking[i]);
          }
        }
        strParkingSelectedNo = selectedParking;

        gstValue = widget.flatBuyerRequest!.flatGstValue!.isNotEmpty
            ? double.parse(widget.flatBuyerRequest!.flatGstValue!)
            : 0.0;

        if (widget.flatBuyerRequest!.flatStampDutyValue! != '0') {
          flagSDValue = true;
          SDValue = double.parse(widget.flatBuyerRequest!.flatStampDutyValue!);
          strSdValue = widget.flatBuyerRequest!.flatStampDutyValue!;
        }
        if (widget.flatBuyerRequest!.flatTdsValue! != '0') {
          flagTDSValue = true;
          tdsValue = double.parse(widget.flatBuyerRequest!.flatTdsValue!);
          // strSdValue = widget.flatBuyerRequest!.flatStampDutyValue!;
        }

        if (widget.flatBuyerRequest!.flatTotalWithoutGst! != '0') {
          strTotalValueBottom =
              double.parse(widget.flatBuyerRequest!.flatTotalWithoutGst!);
        }

        //Custom Charges

        var strCharges = "";
        selectedTotalOtherCharges = 0.0;
        for (int i = 0;
            i < widget.flatBuyerRequest!.customCharges!.length;
            i++) {
          for (int j = 0;
              j < widget.flatBuyerRequest!.customCharges![i].length;
              j++) {
            if (j == 0) {
              strCharges = strCharges.isEmpty
                  ? widget.flatBuyerRequest!.customCharges![i][j].name!
                  : '$strCharges, ${widget.flatBuyerRequest!.customCharges![i][j].name!}';
            } else {
              strCharges =
                  '$strCharges, ${widget.flatBuyerRequest!.customCharges![i][j].name!}';
            }
          }
        }
        // strOtherChargesSelected = strCharges;

        endBuyerByerControllers = [];
        endBuyerByerControllers = dataModel.response?.buyerContactDetails;
        _flatNo = widget.flatNoIds ?? [];
        finishingBrokerController.text = widget.flatBuyerRequest?.brokerName ??
            ''; //widget.salesLeadData?.brokerName ?? '';

        // _txtControllerArea.text = "${widget.totalflatAreaCount} SqFt";

        setState(() {
          flagcalled = true;
        });
      }
      print('--------------------++++');

      // updaterecords();
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    print(widget.buyerContactDetails);
    endBuyerByerControllers = [
      FlatBuyerInfo(id: "", buyerName: widget.buyerName)
    ];
    if (widget.salesLeadData?.mstSalesLeadId != '') {
      strSalesLeadId = widget.salesLeadData?.mstSalesLeadId ?? '';
    }
    if (widget.buyerContactDetails != [] &&
        widget.buyerContactDetails != null) {
      endBuyerByerControllers = [];
      endBuyerByerControllers = widget.buyerContactDetails;
    }

    strBuyerID = widget.strBuyerID!;
    print("in init------------------------------------");
    fetchDefaultSalesMgtDropdown();
    _focusRatePerSqFt = FocusNode();
    _focusAgreementValue = FocusNode();
    _txtControllerRemark.text = "";
    _focusRatePerSqFt.addListener(() {
      if (_focusRatePerSqFt.hasFocus == false) {
        setState(() {
          customChargesCalculation();
        });
      }
    });

    _focusAgreementValue.addListener(() {
      if (_focusAgreementValue.hasFocus == false) {
        setState(() {
          customChargesCalculation();
        });
      }
    });

    if (widget.flagRedirect! == 'Reserve Avail') {
      fetchBookingPaymentDetails();
    } else {
      print('-================');
      print(widget.salesLeadData?.brokerName);
      if (widget.salesLeadData?.brokerName != "") {
        finishingBrokerController.text = widget.salesLeadData?.brokerName ?? '';
        // selectedBrokerType = filteredBrokerProjects()![i];
      }

      if (widget.flagRedirect! == 'Reserve' ||
          widget.flagRedirect! == 'Inventory') {
        _txtControllerGstPercentage.text =
            widget.flatBuyerRequest?.flatGstPercentage ?? '0';
        if (widget.flatBuyerRequest!.brokerName != '') {
          _broker = widget.flatBuyerRequest!.brokerIdFk ?? '';
          _txtControllerBrokerPercentage.text =
              widget.flatBuyerRequest!.brokerPercentage ?? '';
        }

        if (widget.flatBuyerRequest!.flatMarketValue! != '') {
          _txtControllerFlatMarketValue.text = currencyFormat
              .format(double.parse(widget.flatBuyerRequest!.flatMarketValue!));
        }

        if (widget.flatBuyerRequest!.flagStumpCal! != '') {
          strStampDutyFlag = int.parse(widget.flatBuyerRequest!.flagStumpCal!);
        }

        if (widget.flatBuyerRequest!.flagInvestor! == '0') {
          buyerType = 'End Buyer';
        } else {
          buyerType = 'Investor';
        }

        if (widget.flatBuyerRequest!.flatFundingType! == '0') {
          fundingType = 'Self Funding';
        } else if (widget.flatBuyerRequest!.flatFundingType! == '2') {
          fundingType = "Sell to Asset";
        } else {
          fundingType = 'Bank Funding';
        }

        if (widget.flatBuyerRequest!.flatBookingRemark!.isNotEmpty) {
          _txtControllerRemark.text =
              widget.flatBuyerRequest!.flatBookingRemark!;
        }

        if (widget.flatBuyerRequest!.flatBuyerName!.isNotEmpty) {
          _txtControllerBuyerName.text =
              widget.flatBuyerRequest!.flatBuyerName!;
        }

        if (widget.flatBuyerRequest!.flatBuyerEmail!.isNotEmpty) {
          _txtControllerEmailAddress.text =
              widget.flatBuyerRequest!.flatBuyerEmail!;
        }

        if (widget.flatBuyerRequest!.flatBuyerNumber!.isNotEmpty) {
          _txtControllerMobileNumber.text =
              widget.flatBuyerRequest!.flatBuyerNumber!;
        }

        var strFlatArea = widget.flatBuyerRequest!.flatArea!;
        strFlatArea = strFlatArea.replaceAll('SqFt', "");
        strFlatArea = strFlatArea.replaceAll(',', "");
        strFlatArea = strFlatArea.replaceAll(' ', "");
        print(strFlatArea);
        totalflatarea = double.parse(strFlatArea);
        _txtControllerArea.text = widget.flatBuyerRequest!.flatArea!;

        print(widget.flatBuyerRequest!.finshingType!);
        if (widget.flatBuyerRequest!.finshingType == "1") {
          setState(() {
            // strFinishingTypeSelected = "Raw";
            // _finishingType = widget.flatBuyerRequest!.finshingType!;
            // selectedFinishingType = finishingBookList![0];
            finishingtypeController.text = 'Raw';
            strFinishingTypeSelected = 'Raw';
          });
        } else {
          setState(() {
            // strFinishingTypeSelected = "Finished";
            // _finishingType = widget.flatBuyerRequest!.finshingType! == "0"
            //     ? "2"
            //     : widget.flatBuyerRequest!.finshingType!;
            // selectedFinishingType = finishingBookList![1];
            finishingtypeController.text = 'Finished';
            strFinishingTypeSelected = 'Finished';
          });
        }

        var rupee = "\u{20B9}";
        var strRate = widget.flatBuyerRequest!.flatRateCal!;
        strRate = strRate.replaceAll(rupee, "");
        strRate = strRate.replaceAll(',', "");
        strRate = strRate.replaceAll(' ', "");

        _txtControllerRatePerSqFt.text = strRate;

        var strFlatValue = widget.flatBuyerRequest!.flatValue;
        strFlatValue = strFlatValue?.replaceAll(rupee, "");
        strFlatValue = strFlatValue?.replaceAll(',', "");
        strFlatValue = strFlatValue?.replaceAll(' ', "");

        _txtControllerFlatAgreementValue.text =
            currencyFormat.format(double.parse(strFlatValue!));

        var strMarketValue = widget.flatBuyerRequest!.flatMarketValue;
        strMarketValue = strMarketValue?.replaceAll(rupee, "");
        strMarketValue = strMarketValue?.replaceAll(',', "");
        strMarketValue = strMarketValue?.replaceAll(' ', "");

        _txtControllerFlatMarketValue.text =
            currencyFormat.format(double.parse(strMarketValue!));

        if (widget.flatBuyerRequest!.noOfParking! != "0") {
          flagParking = true;
          _txtcontrollerParkingCount.text =
              widget.flatBuyerRequest!.noOfParking!;
        }

        strParkingTypeSelected = widget.flatBuyerRequest!.flatIdFk!;

        var arrParking = widget.flatBuyerRequest!.parkingList!;
        var selectedParking = '';
        arrSelectedParkingList = [];
        for (int i = 0; i < arrParking.length; i++) {
          if (i == 0) {
            selectedParking = arrParking[i].parkingSerialNo!;
            arrSelectedParkingList?.add(arrParking[i]);
          } else {
            selectedParking =
                '$selectedParking, ${arrParking[i].parkingSerialNo!}';
            arrSelectedParkingList?.add(arrParking[i]);
          }
        }
        strParkingSelectedNo = selectedParking;

        gstValue = widget.flatBuyerRequest!.flatGstValue!.isNotEmpty
            ? double.parse(widget.flatBuyerRequest!.flatGstValue!)
            : 0.0;

        if (widget.flatBuyerRequest!.flatStampDutyValue! != '0') {
          flagSDValue = true;
          SDValue = double.parse(widget.flatBuyerRequest!.flatStampDutyValue!);
          strSdValue = widget.flatBuyerRequest!.flatStampDutyValue!;
        }

        if (widget.flatBuyerRequest!.flatTdsValue! != '0') {
          flagTDSValue = true;
          tdsValue = double.parse(widget.flatBuyerRequest!.flatTdsValue!);
          // strSdValue = widget.flatBuyerRequest!.flatStampDutyValue!;
        }

        if (widget.flatBuyerRequest!.flatTotalWithoutGst! != '0') {
          strTotalValueBottom =
              double.parse(widget.flatBuyerRequest!.flatTotalWithoutGst!);
        }

        //Custom Charges

        // var strCharges = "";
        // selectedTotalOtherCharges = 0.0;
        // for (int i = 0;
        //     i < widget.flatBuyerRequest!.customCharges!.length;
        //     i++) {
        //   for (int j = 0;
        //       j < widget.flatBuyerRequest!.customCharges![i].length;
        //       j++) {
        //     if (j == 0) {
        //       strCharges = strCharges.isEmpty
        //           ? widget.flatBuyerRequest!.customCharges![i][j].name!
        //           : '$strCharges, ${widget.flatBuyerRequest!.customCharges![i][j].name!}';
        //     } else {
        //       strCharges =
        //           '$strCharges, ${widget.flatBuyerRequest!.customCharges![i][j].name!}';
        //     }
        //   }
        // }
        // strOtherChargesSelected = strCharges;

        setState(() {});
      } else if (widget.flagRedirect! == 'InventoryNew' ||
          widget.flagRedirect! == 'Inventory') {
        setState(() {
          _flatNo = widget.flatNoIds ?? [];
          _txtControllerArea.text = "${widget.totalflatAreaCount} SqFt";
        });
      } else {
        if (widget.buyerName.isNotEmpty) {
          _txtControllerBuyerName.text = widget.buyerName;
        }
        if (widget.emailId.isNotEmpty) {
          _txtControllerEmailAddress.text = widget.emailId ?? '';
        }
        if (widget.mobileNumber.isNotEmpty) {
          _txtControllerMobileNumber.text = widget.mobileNumber ?? '';
        }
      }
      setState(() {
        flagcalled = true;
      });
    }
  }

  String? bookingType = '';

  Future<ResponseGetFlatListByProject?> fetchDefaultSalesMgtDropdown() async {
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
      "buyer_id": widget.flagRedirect == 'Reserve' ||
              widget.flagRedirect == "Reserve Avail"
          ? widget.flatbuyerid ?? ''
          : '',
      "gst_flag": "1",
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.wsgetflatlistbyproject, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getFlatListByProjectFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        bookingType = dataModel.response?.bookingType;

        if (_txtControllerGstPercentage.text.isEmpty) {
          print('widget.floor_type_id${widget.floor_type_id}');
          // if (widget.floor_type_id == "1") {
          //   _txtControllerGstPercentage.text =
          //       dataModel.response?.percentagate?.commertialPercentage ?? '0';
          // } else if (widget.flatbuyerid == '6') {
          //   _txtControllerGstPercentage.text =
          //       dataModel.response?.percentagate?.residentialPercentage ?? '0';
          // } else {
          _txtControllerGstPercentage.text =
              dataModel.response?.percentagate?.gstPer ?? '0';
          // }
        }

        // gst_value = strTotalValueBottom *
        //               (double.parse(_txtControllerGstPercentage.text.trim()) /
        //                   100);

        averagePrice = dataModel.response?.averagePrice;
        finishingBookList = dataModel.response?.finishingBookList;
        podiumList = dataModel.response?.podiumList;
        flatList = dataModel.response?.flatList;
        customCharges = dataModel.response?.customCharges;

        borkerList = dataModel.response?.borkerList;
        if (widget.salesLeadData?.brokerName != "") {
          // selectedBrokerType = filteredBrokerProjects()![i];

          for (int i = 0; i < borkerList!.length; i++) {
            if (borkerList?[i].companyName ==
                widget.salesLeadData?.brokerName) {
              _txtControllerBrokerPercentage.text =
                  borkerList?[i].brokeragePercent ?? '';
              selectedBrokerType = borkerList?[i];
            }
          }
        }
        percentagate = dataModel.response?.percentagate;
        totalPark = 0;

        if (podiumList!.isNotEmpty) {
          for (var i = 0; i < podiumList!.length; i++) {
            totalPark = totalPark + int.parse(podiumList![i].available!);
          }
        }
        List<ParkingList>? tempp = [];
        for (int i = 0; i < arrSelectedParkingList!.length; i++) {
          for (int j = 0; j < podiumList!.length; j++) {
            for (int k = 0; k < podiumList![j].parkingList!.length; k++) {
              if (arrSelectedParkingList![i].mstParkingId! ==
                  podiumList![j].parkingList![k].mstParkingId) {
                podiumList![j].parkingList![k].selected = 'true';
                tempp.add(podiumList![j].parkingList![k]);
              }
            }
          }
        }
        arrSelectedParkingList = tempp;

        if (flatList!.isNotEmpty) {
          for (var i = 0; i < flatList!.length; i++) {
            flats.add(
              {
                'id': '${flatList?[i].flatId!}',
                'name': '${flatList?[i].flatName!}'
              },
            );
          }

          // flatList
          print(widget.flatBuyerRequest?.selectedFlat?.length);
          print("+++++++++++++++++++++++++++++++++++++++++++++++++");
          if (widget.flatBuyerRequest?.selectedFlat?.length != null) {
            for (int i = 0;
                i < widget.flatBuyerRequest!.selectedFlat!.length;
                i++) {
              if (flatList?.length != 0) {
                for (var l = 0; l < flatList!.length; l++) {
                  if (widget.flatBuyerRequest!.selectedFlat?[i].flatId ==
                      flatList?[l].flatId) {
                    flatList?[l]?.isSelected = true;
                  }
                }
              }
            }
          }
          if (widget.flatNoIds != null) {
            for (var k = 0; k < widget.flatNoIds!.length; k++) {
              for (var i = 0; i < flatList!.length; i++) {
                if (widget.flatNoIds?[k] == flatList?[i].flatId) {
                  flatList?[i].isSelected = true;

                  if (widget.flatNoIds!.length == 1) {
                    widget.floor_type_id = flatList?[i].floorTypeId;
                  }
                }
              }
            }

            flatNoController.clear();
            String selectedFlats = flatList!
                .where((flat) => flat.isSelected == true)
                .map((flat) => flat.inventryFlatName)
                .join(", ");

            flatNoController.text = selectedFlats;
          }
          if (widget.flatNoIds?.length == 1 && widget.flatNoIds != null) {
            if (widget.floor_type_id == "1") {
              _txtControllerGstPercentage.text =
                  dataModel.response?.percentagate?.commertialPercentage ?? '0';
            } else if (widget.flatbuyerid == '6') {
              _txtControllerGstPercentage.text =
                  dataModel.response?.percentagate?.residentialPercentage ??
                      '0';
            }
          } else {
            // _txtControllerGstPercentage.text = '0';
          }
        }

        if (finishingBookList?.length != 0) {
          //  if (widget.flatBuyerRequest!.brokerName ==
          //       borkerList![i].companyName) {
          //     selectedBrokerType = filteredBrokerProjects()![i];
          //   }

          for (var i = 0; i < finishingBookList!.length; i++) {
            if (widget.flatBuyerRequest?.finshingType ==
                finishingBookList?[i].mstFinishingId) {
              selectedFinishingType = finishingBookList?[i];
            }
            finishingType.add(
              {
                'id': '${finishingBookList?[i].mstFinishingId!}',
                'name': '${finishingBookList?[i].mstFinishingName!}'
              },
            );
          }
        }

        otherCharges = [];
        if (customCharges!.isNotEmpty) {
          for (var i = 0; i < customCharges!.length; i++) {
            if (i == 0) {
              for (var j = 0; j < customCharges![i].length; j++) {
                otherCharges.add(customCharges![i][j]);
              }
            }
          }
        }

        otherChargesOneTime = [];
        if (customCharges!.isNotEmpty) {
          for (var i = 0; i < customCharges!.length; i++) {
            if (i != 0) {
              for (var j = 0; j < customCharges![i].length; j++) {
                otherChargesOneTime.add(customCharges![i][j]);
              }
            }
          }
        }

        if (widget.flagRedirect == 'Reserve' ||
            widget.flagRedirect == 'Inventory' ||
            widget.flagRedirect == "Reserve Avail") {
          _flatNo = [];
          List<FlatList>? flatListSelected =
              widget.flatBuyerRequest?.selectedFlat;
          if (flatListSelected?.length != 0) {
            String selectedFlats =
                flatListSelected!.map((flat) => flat.flatName).join(", ");
            flatNoController.text = selectedFlats;
            for (int i = 0; i < flatListSelected!.length; i++) {
              if (i == 0) {
                _flatNo.add(flatListSelected[i].flatId!);
              } else {
                _flatNo.add(flatListSelected[i].flatId!);
              }
            }
          }

          if (widget.flatBuyerRequest!.brokerName != '') {
            _broker = widget.flatBuyerRequest!.brokerIdFk!;
            finishingBrokerController.text =
                widget.flatBuyerRequest?.brokerName ?? '';
            _txtControllerBrokerPercentage.text =
                widget.flatBuyerRequest!.brokerPercentage ?? '';
          }

          if (widget.flatBuyerRequest!.customCharges!.isNotEmpty) {
            selectedTotalOtherCharges = 0.0;
            for (int i = 0;
                i < widget.flatBuyerRequest!.customCharges!.length;
                i++) {
              for (int j = 0;
                  j < widget.flatBuyerRequest!.customCharges![i].length;
                  j++) {
                for (var k = 0; k < otherCharges.length; k++) {
                  if (otherCharges[k].chargesId ==
                      widget
                          .flatBuyerRequest!.customCharges![i][j].chargesId!) {
                    otherCharges[k].selected = 'true';
                    otherCharges[k].value =
                        widget.flatBuyerRequest!.customCharges![i][j].value;
                  }
                }

                // for (var R = 0; R < otherChargesOneTime.length; R++) {
                //   if (otherChargesOneTime[R].chargesId ==
                //       widget
                //           .flatBuyerRequest!.customCharges![i][j].chargesId!) {
                //     otherChargesOneTime[R].selected = 'true';
                //     otherChargesOneTime[R].value =
                //         widget.flatBuyerRequest!.customCharges![i][j].value;
                //   }
                // }
              }
            }
          }
        }
        if (widget.customCharges != null) {
          for (int k = 0; k < widget.customCharges![0].length; k++) {
            for (int i = 0; i < otherCharges.length; i++) {
              if (widget.customCharges![0][k].id == otherCharges[i].id) {
                otherCharges[i].selected = "true";
              }
            }
          }
          print(widget.customCharges![1].length);
          for (int k = 0; k < widget.customCharges![1].length; k++) {
            for (int i = 0; i < otherChargesOneTime.length; i++) {
              if (widget.customCharges![1][k].id == otherChargesOneTime[i].id) {
                otherChargesOneTime[i].selected = "true";
                otherChargesOneTime[i].value =
                    widget.customCharges![1][k].value;
                otherChargesOneTime[i].totalValue =
                    widget.customCharges![1][k].totalValue;
              }
            }
          }
        }

        customChargesCalculation();

        if (borkerList?.length != 0) {
          for (var i = 0; i < borkerList!.length; i++) {
            if (widget.flatBuyerRequest?.brokerName ==
                borkerList?[i].companyName) {
              selectedBrokerType = filteredBrokerProjects()![i];
            }
            broker.add(
              {
                'id': '${borkerList?[i].brokerId!}',
                'name': '${borkerList?[i].companyName!}'
              },
            );
          }
        }
        // setState(() {
        //   flagcalled = true;
        // });
      }
      updaterecords();
      inspect(widget.customCharges);
      print('9999999999999999999999999999999999999999999999999999999999');
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
  }

  Future<ResponseMessageSuccess?> webServiceForReserveBooking() async {
    List<CustomCharge> arrCharges = [];
    for (int i = 0; i < otherCharges.length; i++) {
      if (otherCharges[i].selected == 'true') {
        arrCharges.add(otherCharges[i]);
      }
    }

    for (int i = 0; i < otherChargesOneTime.length; i++) {
      if (otherChargesOneTime[i].selected == 'true') {
        arrCharges.add(otherChargesOneTime[i]);
      }
    }
    CustomLoading.progressDialog(isLoading: true, context: context);

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    var rupee = "\u{20B9}";
    var ratePerSqft = _txtControllerRatePerSqFt.text;
    ratePerSqft = ratePerSqft.replaceAll(rupee, "");
    ratePerSqft = ratePerSqft.replaceAll(",", "");

    var flatMarketValue = _txtControllerFlatMarketValue.text;
    flatMarketValue = flatMarketValue.replaceAll(rupee, "");
    flatMarketValue = flatMarketValue.replaceAll(",", "");

    var flatAgreementValue = _txtControllerFlatAgreementValue.text;
    flatAgreementValue = flatAgreementValue.replaceAll(rupee, "");
    flatAgreementValue = flatAgreementValue.replaceAll(",", "");

    print(arrSelectedParkingList);

    List<CustomCharge> selectedCharges = [];
    for (int i = 0; i < otherCharges.length; i++) {
      if (otherCharges[i].selected == 'true') {
        selectedCharges.add(otherCharges[i]);
      }
    }

    for (int i = 0; i < otherChargesOneTime.length; i++) {
      if (otherChargesOneTime[i].selected == 'true') {
        selectedCharges.add(otherChargesOneTime[i]);
      }
    }
    List<FlatList> flatListSelected = [];
    if (flatList!.length != 0) {
      for (int i = 0; i < flatList!.length; i++) {
        if (flatList?[i].isSelected == true) {
          flatListSelected.add(flatList![i]);
        }
      }
    }
    // for (int j = 0; j < _flatNo.length; j++) {
    //   for (int k = 0; k < flatList!.length; k++) {
    //     if (_flatNo[j] == flatList![k].flatId!) {
    //       flatListSelected.add(flatList![k]);
    //       break;
    //     }
    //   }
    // }

    var flaginvestor = "0";
    if (buyerType == "End Buyer") {
      //End buyer
      flaginvestor = "0";
    } else {
      flaginvestor = "1";
    }

    var funding = "0";
    if (fundingType == "Self Funding") {
      funding = "0";
    } else if (fundingType == "Sell to Asset") {
      funding = "2";
    } else {
      funding = "1";
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "buyer_name": _txtControllerBuyerName.text,
      "flat_area": _txtControllerArea.text,
      "rate_put": ratePerSqft,
      "flat_value": flatAgreementValue,
      "flat_market_value": flatMarketValue,
      "brokerage_value": "0",
      "sd_value": strSdValue!,
      // "gst_value": '$gstValue',
      "total_value": '$strTotalValueBottom',
      "finshing_type": selectedFinishingType?.mstFinishingId ?? '',
      "payment_term_type": "0",
      "payment_term_json": "",
      "buyer_email": _txtControllerEmailAddress.text,
      "buyer_number": _txtControllerMobileNumber.text,
      "podium_id": strParkingTypeSelected!,
      "no_of_park": _txtcontrollerParkingCount.text,
      "flatList": jsonEncode(flatListSelected),
      "flat_booking_status": "3",
      "customer_charges": jsonEncode(arrCharges),
      "flag_investor": flaginvestor,
      "aadhar_no": "",
      "pan_no": "",
      "flat_buyer_id": widget.flagRedirect == 'Reserve' ||
              widget.flagRedirect == "Reserve Avail"
          ? widget.flatBuyerRequest!.flatBuyerId!
          : '',
      "parkinglist": jsonEncode(arrSelectedParkingList),
      "broker_id": _broker!,
      "broker_percentage": _txtControllerBrokerPercentage.text,
      "flag_stump_cal": '$strStampDutyFlag',
      "lead_id": strSalesLeadId,
      "flat_remark": _txtControllerRemark.text,
      "flat_funding_type": funding,
      "arr_buyer_flatlist": jsonEncode(endBuyerByerControllers),
      "tds_percentage": percentagate?.tdsPercentage ?? '0',
      "tds_value": flagTDSValue == true ? tdsValue.toString() : '0',
      "gst_percentage": _txtControllerGstPercentage.text,
      "gst_value": gst_value.toStringAsFixed(2),
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(AppUrl.wssetflatbook, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = messageSuccessFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        CustomLoading.progressDialog(isLoading: false, context: context);

        // ignore: use_build_context_synchronously
        showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: const Text(''),
                  content: const Text('Successfully updated your flat details.',
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
                              fontSize: 14.0,
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
      }
    } else {
      CustomLoading.progressDialog(isLoading: false, context: context);

      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
  }

  Future<ResponseMessageSuccess?> rejectReserveInventory() async {
    CustomLoading.progressDialog(isLoading: true, context: context);

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId ?? '',
      "flat_buyer_id": widget.flatbuyerid ?? '',
      "status": '2',
      "flat_id_fk": widget.flatidfk ?? '',
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(AppUrl.wssetflatStatus, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      CustomLoading.progressDialog(isLoading: false, context: context);

      final dataModel = messageSuccessFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    } else {
      CustomLoading.progressDialog(isLoading: false, context: context);

      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
  }

  rejectReserveInventoryModal() {
    return showDialog<void>(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 10),
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: const Text(
                "Are you sure you want to reject this booking?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              content: const SizedBox(
                height: 20,
              ),
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7)),
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
                  onTap: () async {
                    rejectReserveInventory();
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Text(
                      'YES',
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
        });
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      useDefaultLoading: false,
      overlayWidgetBuilder: (_) => Center(
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
      ),
      // const Center(
      //   child: SpinKitRing(
      //     lineWidth: 5.0,
      //     color: Colors.black,
      //     size: 50.0,
      //   ),
      // ),
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
                widget.towarName!.isNotEmpty
                    ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                    : widget.projectName!.toUpperCase(),
                // widget.flagRedirect == 'Inventory'
                //     ? widget.projectName!.toUpperCase()
                //     : '${widget.projectName!.toUpperCase()}',
                style: const TextStyle(
                    fontStyle: FontStyle.normal, fontSize: 17.0)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.maybePop(context);
              },
            ),
          ),
          body: flagcalled == true
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.flagRedirect == 'Inventory')
                      Container(
                        width: double.maxFinite,
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                          color: Colors.black,
                        ))),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: const AppText(
                          title: 'AVAILABLE INVENTORY',
                          fontSize: 17,
                          titleTextAlign: TextAlign.center,
                        ),
                      ),
                    if (widget.flagRedirect == 'Reserve')
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 10),
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                          color: Colors.black,
                        ))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 140),
                            const AppText(
                              title: 'RESERVED INVENTORY',
                              fontSize: 17,
                              titleTextAlign: TextAlign.center,
                            ),
                            OutlinedButton(
                              onPressed: () {
                                rejectReserveInventoryModal();
                              },
                              style: OutlinedButton.styleFrom(
                                // backgroundColor: Colors.black,
                                side: const BorderSide(
                                    width: 1.0, color: Colors.black45),
                              ),
                              child: const Text("REJECT",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 80.0, right: 80.0),
                          child: Container(
                              color: Colors.white,
                              child: SafeArea(
                                  child: Column(
                                children: [
                                  _buyersType(),
                                  verticalSpaceSmall15,
                                  _fundingType(),
                                  if (buyerType == "Investor")
                                    verticalSpaceSmall15,
                                  buyerType == "Investor"
                                      ? _buyersName()
                                      : _buyersNameEndBuyer(),
                                  verticalSpaceSmall15,
                                  _buyeremail(),
                                  verticalSpaceSmall15,
                                  _mobilenumber(),
                                  verticalSpaceSmall15,
                                  _flatNumber(),
                                  verticalSpaceSmall15,
                                  _flatarea(),
                                  verticalSpaceSmall15,
                                  _flatFinishingType(),
                                  if (bookingType != "1") verticalSpaceSmall15,
                                  if (bookingType != "1") _flatRatePerSqFt(),
                                  if (bookingType != "1") verticalSpaceSmall15,
                                  if (bookingType != "1") _flatAgreementValue(),
                                  if (bookingType != "1") verticalSpaceSmall15,
                                  if (bookingType != "1") _flatMarketValue(),
                                  if (bookingType != "0") verticalSpaceSmall15,
                                  if (bookingType != "0") _flatLeaseValue(),
                                  verticalSpaceSmall15,
                                  _includeParking(
                                      averagePrice: averagePrice ?? ''),
                                  verticalSpaceSmall15,
                                  _OtherCharges(),
                                  verticalSpaceSmall15,
                                  _totalOtherCharges(),
                                  verticalSpaceSmall15,
                                  _SelectBroker(),
                                  verticalSpaceSmall15,
                                  _BrokerPercentage(),
                                  verticalSpaceSmall15,
                                  _GstPercentage(),
                                  verticalSpaceSmall15,
                                  _sdvalue(),
                                  verticalSpaceSmall15,
                                  _Remark(),
                                  verticalSpaceMedium,
                                ],
                              ))),
                        ),
                      ),
                    ),
                    SizedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Divider(
                            height: 1.0,
                            color: Colors.black,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 80.0, vertical: 13),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Value (Excl. G.S.T) : ',
                                    style: TextStyle(
                                        fontStyle: FontStyle.normal,
                                        fontSize: 17.0)),
                                const Spacer(),
                                Text(currencyFormat.format(strTotalValueBottom),
                                    style: const TextStyle(
                                        fontStyle: FontStyle.normal,
                                        fontSize: 17.0))
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (bookingType == "1" ||
                                        _txtControllerLeaseValueMonthly.text !=
                                            "") {
                                    } else {
                                      var flag = true;
                                      String msg = "";
                                      if (_flatNo.isEmpty) {
                                        msg =
                                            'Please select flat no from a flat list.';
                                        flag = false;
                                      }
                                      // else if (_txtControllerRatePerSqFt.text ==
                                      //     "") {
                                      //   msg = 'Please enter Rate per SqFt.';
                                      //   flag = false;
                                      // }
                                      // else if (_txtControllerFlatAgreementValue
                                      //         .text ==
                                      //     "") {
                                      //   msg = 'Please enter flat value.';
                                      //   flag = false;
                                      // }
                                      else if (_txtControllerMobileNumber
                                              .text ==
                                          "") {
                                        msg = 'Please enter mobile number.';
                                        flag = false;
                                      } else if (_txtControllerMobileNumber
                                              .text.length <
                                          10) {
                                        msg =
                                            'Mobile number should be 10 digit.';
                                        flag = false;
                                      } else if (_broker! != "") {
                                        if (_txtControllerBrokerPercentage
                                            .text.isEmpty) {
                                          msg =
                                              'Please enter broker percentage';
                                          flag = false;
                                        }
                                      } else if (flagParking == true) {
                                        if (_txtcontrollerParkingCount
                                                .text.isEmpty ==
                                            true) {
                                          msg =
                                              'Please enter no. of parking required.';
                                          flag = false;
                                        }
                                      }
                                      //else if (double.parse(
                                      //             _txtcontrollerParkingCount.text)
                                      //         .ceil() !=
                                      //     arrSelectedParkingList?.length) {
                                      //   print(
                                      //       '${arrSelectedParkingList!.length} ++ ${double.parse(_txtcontrollerParkingCount.text).ceil()}');
                                      //   //                 arrSelectedParkingList!.length <
                                      //   // int.parse(_txtcontrollerParkingCount.text
                                      //   msg =
                                      //       'Parking Allocation should be Equal to Entered Parking Count';
                                      //   flag = false;
                                      // }

                                      if (flag == false) {
                                        context.loaderOverlay.hide();
                                        Alert(
                                            closeIcon: const SizedBox(),
                                            padding:
                                                const EdgeInsets.only(top: 0.0),
                                            image: Image.asset(
                                                'images/Icon-512.png',
                                                height: 80,
                                                fit: BoxFit.fitWidth),
                                            style: const AlertStyle(
                                                titleTextAlign:
                                                    TextAlign.center,
                                                descTextAlign: TextAlign.center,
                                                descStyle: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 16),
                                                isCloseButton: true),
                                            context: context,
                                            desc: msg,
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
                                      // else if (arrSelectedParkingList!
                                      //         .isNotEmpty &&
                                      //     double.parse(_txtcontrollerParkingCount
                                      //                 .text)
                                      //             .ceil() !=
                                      //         arrSelectedParkingList?.length) {
                                      //   print("in else");
                                      //   context.loaderOverlay.hide();
                                      //   Alert(
                                      //       closeIcon: const SizedBox(),
                                      //       padding: const EdgeInsets.only(
                                      //           top: 0.0, left: 10, right: 10),
                                      //       image: Image.asset(
                                      //           'images/Icon-512.png',
                                      //           height: 80,
                                      //           fit: BoxFit.fitWidth),
                                      //       style: const AlertStyle(
                                      //           titleTextAlign: TextAlign.center,
                                      //           descTextAlign: TextAlign.center,
                                      //           descStyle: TextStyle(
                                      //               fontWeight: FontWeight.normal,
                                      //               fontSize: 16),
                                      //           isCloseButton: true),
                                      //       context: context,
                                      //       desc:
                                      //           "Parking Allocation should be Equal to Entered Parking Count",
                                      //       alertAnimation: fadeAlertAnimation,
                                      //       buttons: [
                                      //         DialogButton(
                                      //           onPressed: () =>
                                      //               Navigator.pop(context),
                                      //           color: Colors.black,
                                      //           child: const Text(
                                      //             "CLOSE",
                                      //             style: TextStyle(
                                      //                 color: Colors.white,
                                      //                 fontSize: 15),
                                      //           ),
                                      //         ),
                                      //       ]).show();
                                      // }
                                      else {
                                        Alert(
                                            closeIcon: const SizedBox(),
                                            padding:
                                                const EdgeInsets.only(top: 0.0),
                                            image: Image.asset(
                                                'images/Icon-512.png',
                                                height: 80,
                                                fit: BoxFit.fitWidth),
                                            style: const AlertStyle(
                                                titleTextAlign:
                                                    TextAlign.center,
                                                descTextAlign: TextAlign.center,
                                                descStyle: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 16),
                                                isCloseButton: true),
                                            context: context,
                                            desc:
                                                'Are you sure, you want to reserve a flat?.',
                                            alertAnimation: fadeAlertAnimation,
                                            buttons: [
                                              DialogButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  webServiceForReserveBooking();
                                                },
                                                color: Colors.black,
                                                child: const Text(
                                                  "YES",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15),
                                                ),
                                              ),
                                              DialogButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                color: Colors.black,
                                                child: const Text(
                                                  "NO",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15),
                                                ),
                                              ),
                                            ]).show();
                                      }
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 45,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: bookingType == "1" ||
                                              _txtControllerLeaseValueMonthly
                                                      .text !=
                                                  ""
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                    child: const Text(
                                      'RESERVE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    var flag = true;
                                    String msg = "";
                                    if (_flatNo.isEmpty) {
                                      msg =
                                          'Please select flat no from a flat list.';
                                      flag = false;
                                    } else if (_txtControllerRatePerSqFt.text ==
                                        "") {
                                      if (bookingType == "1" ||
                                          _txtControllerLeaseValueMonthly
                                                  .text !=
                                              "") {
                                      } else {
                                        msg = 'Please enter Rate per SqFt.';
                                        flag = false;
                                      }
                                    } else if (_txtControllerFlatAgreementValue
                                            .text ==
                                        "") {
                                      msg =
                                          'Please enter flat agreement value.';
                                      flag = false;
                                    } else if (_txtControllerMobileNumber
                                            .text ==
                                        "") {
                                      msg = 'Please enter mobile number.';
                                      flag = false;
                                    } else if (_txtControllerMobileNumber
                                            .text.length <
                                        10) {
                                      msg = 'Mobile number should be 10 digit.';
                                      flag = false;
                                    } else if (_broker! != "") {
                                      if (_txtControllerBrokerPercentage
                                          .text.isEmpty) {
                                        msg = 'Please enter broker percentage';
                                        flag = false;
                                      }
                                    } else if (flagParking == true) {
                                      if (_txtcontrollerParkingCount
                                              .text.isEmpty ==
                                          true) {
                                        msg =
                                            'Please enter no. of parking required.';
                                        flag = false;
                                      }
                                    }

                                    if (flag == false) {
                                      context.loaderOverlay.hide();
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
                                          desc: msg,
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
                                    } else if (arrSelectedParkingList!
                                            .isNotEmpty &&
                                        double.parse(_txtcontrollerParkingCount
                                                    .text)
                                                .ceil() !=
                                            arrSelectedParkingList?.length) {
                                      print("in else");
                                      context.loaderOverlay.hide();
                                      Alert(
                                          closeIcon: const SizedBox(),
                                          padding: const EdgeInsets.only(
                                              top: 0.0, left: 10, right: 10),
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
                                              "Parking Allocation should be Equal to Entered Parking Count",
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
                                      List<FlatList>?
                                          arrSelectedFlatForSaleList = [];
                                      var flatsSelected = '';
                                      // for (int i = 0; i < _flatNo.length; i++) {
                                      //   for (int j = 0;
                                      //       j < flatList!.length;
                                      //       j++) {
                                      //     if (_flatNo[i] ==
                                      //         flatList![j].flatId!) {
                                      //       arrSelectedFlatForSaleList
                                      //           .add(flatList![j]);
                                      //       if (flatsSelected.isEmpty) {
                                      //         flatsSelected =
                                      //             flatList![j].inventryFlatName!;
                                      //       } else {
                                      //         flatsSelected =
                                      //             '${flatsSelected}, ${flatList![j].inventryFlatName!}';
                                      //       }
                                      //       break;
                                      //     }
                                      //   }
                                      // }
                                      for (int j = 0;
                                          j < flatList!.length;
                                          j++) {
                                        if (flatList![j].isSelected == true) {
                                          arrSelectedFlatForSaleList
                                              .add(flatList![j]);
                                        }
                                      }
                                      // flatList

                                      // if (widget.flagRedirect == 'Inventory' &&
                                      //     widget.isFlatListFromReserve != null) {
                                      //   arrSelectedFlatForSaleList
                                      //       .add(widget.isFlatListFromReserve!);
                                      // }

                                      var rupee = "\u{20B9}";
                                      var RatePerSqFt =
                                          _txtControllerRatePerSqFt.text;
                                      RatePerSqFt =
                                          RatePerSqFt.replaceAll(rupee, "");
                                      RatePerSqFt =
                                          RatePerSqFt.replaceAll(',', "");
                                      RatePerSqFt =
                                          RatePerSqFt.replaceAll(' ', "");
                                      print('RatePerSqFt');
                                      var strFlatValue =
                                          _txtControllerFlatAgreementValue.text;
                                      strFlatValue =
                                          strFlatValue.replaceAll(rupee, "");
                                      strFlatValue =
                                          strFlatValue.replaceAll(',', "");
                                      strFlatValue =
                                          strFlatValue.replaceAll(' ', "");
                                      print('strFlatValue');
                                      print(strFlatValue);

                                      var strFlatArea = _txtControllerArea.text;
                                      strFlatArea =
                                          strFlatArea.replaceAll(rupee, "");
                                      strFlatArea =
                                          strFlatArea.replaceAll(',', "");
                                      strFlatArea =
                                          strFlatArea.replaceAll(' ', "");
                                      print('strFlatArea');
                                      print(strFlatArea);

                                      var strMarketValue =
                                          _txtControllerFlatMarketValue.text;
                                      strMarketValue =
                                          strMarketValue.replaceAll(rupee, "");
                                      strMarketValue =
                                          strMarketValue.replaceAll(',', "");
                                      strMarketValue =
                                          strMarketValue.replaceAll(' ', "");
                                      print('strMarketValue');
                                      print(strMarketValue);

                                      var strBrokerPercentage =
                                          _txtControllerBrokerPercentage.text;
                                      strBrokerPercentage = strBrokerPercentage
                                          .replaceAll('%', "");
                                      strBrokerPercentage = strBrokerPercentage
                                          .replaceAll(',', "");
                                      strBrokerPercentage = strBrokerPercentage
                                          .replaceAll(' ', "");
                                      print('strBrokerPercentage');
                                      print(strBrokerPercentage);

                                      List<CustomCharge> arrCharges = [];
                                      for (int i = 0;
                                          i < otherCharges.length;
                                          i++) {
                                        if (otherCharges[i].selected ==
                                            'true') {
                                          arrCharges.add(otherCharges[i]);
                                        }
                                      }

                                      for (int i = 0;
                                          i < otherChargesOneTime.length;
                                          i++) {
                                        if (otherChargesOneTime[i].selected ==
                                            'true') {
                                          arrCharges
                                              .add(otherChargesOneTime[i]);
                                        }
                                      }

                                      var flaginvestor = "0";
                                      if (buyerType == "End Buyer") {
                                        // buyerType == "Investor" endBuyerByerControllers
                                        // List<String> arr_buyer_flatlist_temp =
                                        //     [];
                                        // for (int i = 0;
                                        //     i < endBuyerByerControllers.length;
                                        //     i++) {
                                        //   arr_buyer_flatlist_temp.add(
                                        //       endBuyerByerControllers[i].text);
                                        // }
                                        //End buyer
                                        flaginvestor = "0";
// emailId:_txtControllerEmailAddress
//                                                         .text ,

                                        var projectId = widget.projectId!;
                                        var projectName = widget.projectName!;
                                        // gstValue =
                                        //     (strTotalValueBottom * 12) / 100;
                                        print(jsonEncode(
                                            endBuyerByerControllers));
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) {
                                              return BuyerDetailsViewEndBuyer(
                                                txtControllerLeaseValueMonthly:
                                                    _txtControllerLeaseValueMonthly
                                                        .text,
                                                txtControllerLeaseValueYearly:
                                                    _txtControllerLeaseValueYearly
                                                        .text,
                                                gst_value: gst_value.toString(),
                                                gst_percentage:
                                                    _txtControllerGstPercentage
                                                        .text,
                                                tdsPercentage: percentagate
                                                        ?.tdsPercentage ??
                                                    '0',
                                                tdsValue: flagTDSValue == true
                                                    ? tdsValue.toString()
                                                    : '0',

                                                arr_buyer_flatlist:
                                                    endBuyerByerControllers,
                                                projectId: projectId,
                                                towarName: widget.towarName,
                                                towarId: widget.towarId!,
                                                projectName: projectName,
                                                flatNumber:
                                                    flatNoController.text,
                                                buyerName:
                                                    _txtControllerBuyerName
                                                        .text,
                                                buyerEmail:
                                                    _txtControllerEmailAddress
                                                        .text,
                                                flatArea: totalflatarea,
                                                arrSelectedFlatForSaleList:
                                                    arrSelectedFlatForSaleList,
                                                buyerMobileNumber:
                                                    _txtControllerMobileNumber
                                                        .text,
                                                strFinishingTypeSelected:
                                                    strFinishingTypeSelected,
                                                strNoOfParking:
                                                    _txtcontrollerParkingCount
                                                        .text,
                                                strSalesLeadId: strSalesLeadId,
                                                arrSelectedParkingList:
                                                    arrSelectedParkingList,
                                                strPanCardNo: "",
                                                strAadharCardNo: "",
                                                RatePerSqFt: RatePerSqFt
                                                        .isNotEmpty
                                                    ? double.parse(RatePerSqFt)
                                                    : 0,
                                                strFlatValue: strFlatValue,
                                                strFlatArea: strFlatArea,
                                                strRateSqFt: RatePerSqFt,
                                                strGSTValue: '$gstValue',
                                                strSDValue: strSdValue,
                                                TotalValue:
                                                    '$strTotalValueBottom',
                                                strMarketValue: strMarketValue,
                                                strStampDutyFlag:
                                                    '$strStampDutyFlag',
                                                arrCharges: arrCharges,
                                                strBuyerID: strBuyerID,
                                                strBrokerIDSelected: _broker!,
                                                strBrokerPercentage:
                                                    strBrokerPercentage,
                                                strParkingID:
                                                    strParkingTypeSelected,
                                                //from Reserve
                                                flaginvestor: flaginvestor,
                                                strRemark:
                                                    _txtControllerRemark.text,
                                                fundingType: fundingType,
                                              );
                                            },
                                          ),
                                        );
                                      } else {
                                        flaginvestor = "1";

                                        var projectId = widget.projectId!;
                                        var projectName = widget.projectName!;
                                        // gstValue =
                                        //     (strTotalValueBottom * 18) / 100;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) {
                                              return BuyerDetailsViewEndBuyer(
                                                txtControllerLeaseValueMonthly:
                                                    _txtControllerLeaseValueMonthly
                                                        .text,
                                                txtControllerLeaseValueYearly:
                                                    _txtControllerLeaseValueYearly
                                                        .text,
                                                gst_value: gst_value.toString(),
                                                gst_percentage:
                                                    _txtControllerGstPercentage
                                                        .text,
                                                tdsPercentage: percentagate
                                                        ?.tdsPercentage ??
                                                    '0',
                                                tdsValue: flagTDSValue == true
                                                    ? tdsValue.toString()
                                                    : '0',
                                                arr_buyer_flatlist: [
                                                  FlatBuyerInfo(
                                                      id: "",
                                                      emailId:
                                                          _txtControllerEmailAddress
                                                              .text,
                                                      buyerName:
                                                          _txtControllerBuyerName
                                                              .text)
                                                ],
                                                // [
                                                //   _txtControllerBuyerName.text
                                                // ],
                                                projectId: projectId,
                                                towarName: widget.towarName,
                                                towarId: widget.towarId!,
                                                projectName: projectName,
                                                flatNumber:
                                                    flatNoController.text,
                                                buyerName:
                                                    _txtControllerBuyerName
                                                        .text,
                                                buyerEmail:
                                                    _txtControllerEmailAddress
                                                        .text,
                                                flatArea: totalflatarea,
                                                arrSelectedFlatForSaleList:
                                                    arrSelectedFlatForSaleList,
                                                buyerMobileNumber:
                                                    _txtControllerMobileNumber
                                                        .text,
                                                strFinishingTypeSelected:
                                                    strFinishingTypeSelected,
                                                strNoOfParking:
                                                    _txtcontrollerParkingCount
                                                        .text,
                                                strSalesLeadId: strSalesLeadId,
                                                arrSelectedParkingList:
                                                    arrSelectedParkingList,
                                                strPanCardNo: "",
                                                strAadharCardNo: "",
                                                RatePerSqFt: RatePerSqFt
                                                        .isNotEmpty
                                                    ? double.parse(RatePerSqFt)
                                                    : 0,
                                                strFlatValue: strFlatValue,
                                                strFlatArea: strFlatArea,
                                                strRateSqFt: RatePerSqFt,
                                                strGSTValue: '$gstValue',
                                                strSDValue: strSdValue,
                                                TotalValue:
                                                    '$strTotalValueBottom',
                                                strMarketValue: strMarketValue,
                                                strStampDutyFlag:
                                                    '$strStampDutyFlag',
                                                arrCharges: arrCharges,
                                                strBuyerID: strBuyerID,
                                                strBrokerIDSelected: _broker!,
                                                strBrokerPercentage:
                                                    strBrokerPercentage,
                                                strParkingID:
                                                    strParkingTypeSelected,
                                                //from Reserve
                                                flaginvestor: flaginvestor,
                                                strRemark:
                                                    _txtControllerRemark.text,
                                                fundingType: fundingType,
                                              );
                                            },
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 45,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                    ),
                                    child: const Text(
                                      'PROCEED',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.0,
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
                  ],
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
          ),
    );
  }

  void checkNavigation() async {
    final SharedPreferences prefs = await _prefs;
    String? flagRedirect = prefs.getString('flagRedirectToWorkProgress');
    if (flagRedirect == 'true') {
      backToScreen();
    }
  }

  void backToScreen() {
    Navigator.maybePop(context);
  }

  Widget _buyersType() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Buyer\'s  Type',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: RadioListTile(
              title: const Text(
                "End Buyer",
                style: normalText,
              ),
              value: "End Buyer",
              groupValue: buyerType, // test
              onChanged: (value) {
                if (kDebugMode) {
                  print(value);
                }
                setState(() {
                  buyerType = value.toString();
                });
              }),
        ),
        Expanded(
          child: RadioListTile(
              title: const Text(
                "Investor",
                style: normalText,
              ),
              value: "Investor",
              groupValue: buyerType,
              onChanged: (value) {
                if (kDebugMode) {
                  print(value);
                }
                setState(() {
                  buyerType = value.toString();
                });
              }),
        ),
        const Expanded(child: Text('')),
      ],
    );
  }

  Widget _fundingType() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Funding Type',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: RadioListTile(
              title: const Text(
                "Self Funding",
                style: normalText,
              ),
              value: "Self Funding",
              groupValue: fundingType,
              onChanged: (value) {
                if (kDebugMode) {
                  print(value);
                }
                setState(() {
                  fundingType = value.toString();
                });
              }),
        ),
        Expanded(
          child: RadioListTile(
              title: const Text(
                "Bank Funding",
                style: normalText,
              ),
              value: "Bank Funding",
              groupValue: fundingType,
              onChanged: (value) {
                if (kDebugMode) {
                  print(value);
                }
                setState(() {
                  fundingType = value.toString();
                });
              }),
        ),
        Expanded(
          child: RadioListTile(
              title: const Text(
                "Sell to Asset",
                style: normalText,
              ),
              value: "Sell to Asset",
              groupValue: fundingType,
              onChanged: (value) {
                if (kDebugMode) {
                  print(value);
                }
                setState(() {
                  fundingType = value.toString();
                });
              }),
        )
      ],
    );
  }

// End Buyer
  Widget _buyersNameEndBuyer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 230.0,
          // height: 40.0,
          child: Container(
            padding: const EdgeInsets.only(top: 15.0),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'HelveticaNeue'),
                children: [
                  TextSpan(
                    text: 'Buyer\'s Name',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'HelveticaNeue'),
                  ),
                  // if (isRequired == true)
                  TextSpan(
                    text: "*", // The asterisk
                    style: TextStyle(
                      color: Colors.red, // Color for the asterisk
                    ),
                  ),
                ],
              ),
            ),
            //  Text('Buyer\'s Name',
            //     style: TextStyle(
            //         backgroundColor: Colors.white,
            //         fontSize: 15,
            //         color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Column(
          children: [
            for (int i = 0; i < endBuyerByerControllers!.length; i++)
              Container(
                padding: EdgeInsets.only(
                    bottom: endBuyerByerControllers!.length - 1 == i ? 0 : 15),
                // margin: EdgeInsets.only(top: 15),
                child: Row(
                  children: [
                    Container(
                      height: 45.0,
                      width: MediaQuery.of(context).size.width * 0.55,
                      decoration: BoxDecoration(
                          color: kcTextFieldColor,
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5.0))),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: TextFormField(
                          controller: TextEditingController(
                              text: endBuyerByerControllers?[i].buyerName),
                          // endBuyerByerControllers?[i]
                          //     .textEditingController, //_txtControllerBuyerName,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 15.0),
                          decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 18.0),
                            border: InputBorder.none,
                            hintText: 'Enter Buyer Name',
                          ),
                          onChanged: (String str) {
                            endBuyerByerControllers?[i].buyerName = str;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (i == 0) {
                            endBuyerByerControllers?.add(FlatBuyerInfo(id: ""));
                          } else {
                            endBuyerByerControllers?.removeAt(i);
                          }
                        });
                      },
                      child: Icon(
                        i == 0
                            ? Icons.add_circle_outline
                            : Icons.remove_circle_outline,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              )
          ],
        )
      ],
    );
  }

  Widget _buyersName() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Buyer\'s Name',
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
              child: TextFormField(
                controller: _txtControllerBuyerName,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter Buyer Name',
                ),
                // onChanged: (String str) {},
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buyeremail() {
    //_txtControllerRequirementFor.add(TextEditingController());
    //_txtControllerRequirementFor[index].text =
    // arrayList[index]['casting_for'].toString();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Email',
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
                controller: _txtControllerEmailAddress,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter email address (Optional)',
                ),
                onChanged: (String str) {
                  endBuyerByerControllers?[0].emailId = str;
                  //arrayList[index]['casting_for'] = str;
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _mobilenumber() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 230.0,
          child: Container(
            padding: const EdgeInsets.only(top: 15),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'HelveticaNeue'),
                children: [
                  TextSpan(
                    text: 'Mobile Number',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'HelveticaNeue'),
                  ),
                  // if (isRequired == true)
                  TextSpan(
                    text: "*", // The asterisk
                    style: TextStyle(
                      color: Colors.red, // Color for the asterisk
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.only(top: 15.0),
          //   child: Text('Mobile Number',
          //       style: TextStyle(
          //           backgroundColor: Colors.white,
          //           fontSize: 15,
          //           color: Colors.black)),
          // ),
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
                onTap: () {},
                child: TextField(
                  controller: _txtControllerMobileNumber,
                  maxLength: 10,
                  style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(top: 0.0),
                    border: InputBorder.none,
                    hintText: 'Enter mobile number',
                  ),
                  onChanged: (text) {
                    // setState(() {
                    endBuyerByerControllers?[0].mobileNumber = text;
                    //fullName = text;
                    //you can access nameController in its scope to get
                    // the value of text entered as shown below
                    //fullName = nameController.text;
                    // });
                  },
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _flatNumber() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 230.0,
          height: 40.0,
          child: Container(
            padding: const EdgeInsets.only(top: 15),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'HelveticaNeue'),
                children: [
                  TextSpan(
                    text: 'Flat Number',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'HelveticaNeue'),
                  ),
                  // if (isRequired == true)
                  TextSpan(
                    text: "*", // The asterisk
                    style: TextStyle(
                      color: Colors.red, // Color for the asterisk
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.only(top: 15.0),
          //   child: Text('Flat Number',
          //       style: TextStyle(
          //           backgroundColor: Colors.white,
          //           fontSize: 15,
          //           color: Colors.black)),
          // ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: InkWell(
            onTap: () {
              searchFlatNumberText = '';
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    surfaceTintColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    titlePadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    actionsPadding:
                        const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    actionsAlignment: MainAxisAlignment.center,
                    title: const Text(
                      "Select Flats Number",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                // totalflatarea =
                                //                   totalflatarea + double.parse(flatList![j].flatArea!);
                                //               break;
                                totalflatarea = 0.0;
                                _flatNo.clear();
                                for (int i = 0; i < flatList!.length; i++) {
                                  if (flatList?[i].isSelected == true) {
                                    totalflatarea = totalflatarea +
                                        double.parse(
                                            flatList?[i].flatArea ?? '');

                                    //_flatNo.add(flatList?[i].flatName);
                                    _flatNo.add(flatList?[i].flatId);
                                  }
                                }
                                setState(() {
                                  _txtControllerArea.text =
                                      "$totalflatarea SqFt";
                                });

                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(7)),
                                child: const Center(
                                  child: Text(
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
                            ),
                          ),
                        ],
                      ),
                    ],
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState1) {
                        return Container(
                          width: 500,
                          height: 404,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              verticalSpaceTiny,
                              SizedBox(
                                height: 40,
                                child: TextField(
                                  onChanged: (value) {
                                    setState1(() {
                                      searchFlatNumberText = value;
                                    });
                                  },
                                  style: const TextStyle(fontSize: 13),
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.all(12.0),
                                      labelText: 'Search Flat',
                                      hintText: "Search Flat ",
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
                                    itemCount:
                                        filteredFlatNumberProjects()!.length,
                                    itemBuilder: (context, int ind) {
                                      return InkWell(
                                        onTap: () {
                                          setState1(() {
                                            flagParking = false;
                                            // if (selectedFinishingFlatNumber
                                            //         ?.flatName ==
                                            // filteredFlatNumberProjects()![
                                            //         ind]
                                            //         .flatName) {
                                            if (filteredFlatNumberProjects()![
                                                        ind]
                                                    .isSelected ==
                                                true) {
                                              // arrayList[index]!.selectedUnitId =
                                              //     "";
                                              // arrayList[index]!
                                              //     .controllerText
                                              //     ?.text = '';
                                              // arrayList[index]!.woUnit = "";
                                              // selectedFinishingFlatNumber =
                                              //     null;
                                              filteredFlatNumberProjects()![ind]
                                                  .isSelected = false;
                                              // flatNoController.clear();
                                            } else {
                                              // selectedFinishingFlatNumber =
                                              //     filteredFlatNumberProjects()![
                                              //         ind];
                                              filteredFlatNumberProjects()![ind]
                                                  .isSelected = true;
                                              // flatNoController.text =
                                              //     filteredFlatNumberProjects()![
                                              //                 ind]
                                              //             .flatName ??
                                              //         '';

                                              // arrayList[index]!.selectedUnitId =
                                              //     filteredProjects()![ind]
                                              //         .unitId;
                                              // arrayList[index]!
                                              //     .controllerText
                                              //     ?.text = widget
                                              //         .gradeUnit![ind]
                                              //         .unitName ??
                                              //     '';
                                              // arrayList[index]!.woUnit = widget
                                              //         .gradeUnit![ind]
                                              //         .unitName ??
                                              //     '';
                                            }

                                            String selectedFlats =
                                                filteredFlatNumberProjects()!
                                                    .where((flat) =>
                                                        flat.isSelected == true)
                                                    .map(
                                                        (flat) => flat.flatName)
                                                    .join(", ");
                                            flatNoController.text =
                                                selectedFlats;

                                            _txtControllerRatePerSqFt.clear();
                                            _txtControllerFlatAgreementValue
                                                .clear();
                                            _txtControllerFlatMarketValue
                                                .clear();
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0, vertical: 7.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        filteredFlatNumberProjects()![
                                                                    ind]
                                                                .flatName ??
                                                            '',
                                                        style: normalText,
                                                      ),
                                                    ],
                                                  ),
                                                  // selectedFinishingFlatNumber
                                                  //             ?.flatName ==
                                                  //         filteredFlatNumberProjects()![
                                                  //                 ind]
                                                  //             .flatName
                                                  filteredFlatNumberProjects()![
                                                                  ind]
                                                              .isSelected ==
                                                          true
                                                      ? const Icon(
                                                          Icons
                                                              .check_circle_outline,
                                                          size: 25,
                                                          color: Colors.green,
                                                        )
                                                      : const Icon(
                                                          Icons.circle_outlined,
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
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
            child: Container(
              color: kcTextFieldColor,
              child: TextFormField(
                minLines: 1,
                maxLines: 6,
                autofocus: false,
                enabled: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "(Flat No Cannot Be Empty)";
                  }
                },
                controller: flatNoController,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: InputDecoration(
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down_sharp,
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.all(10),
                  border: InputBorder.none,
                  hintText: 'Enter Flat No',
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF5F5C5C)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: (Colors.red),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: (Color(0xFF5F5C5C)),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Expanded(
        //   child: Container(
        //     height: 65,
        //     decoration: BoxDecoration(
        //         color: kcTextFieldColor,
        //         border: Border.all(
        //           color: Colors.grey,
        //         ),
        //         borderRadius: const BorderRadius.all(Radius.circular(5.0))),
        //     child: SmartSelect<String?>.multiple(
        //       title: 'Flat No.',
        //       selectedValue: _flatNo,
        //       modalConfig: const S2ModalConfig(
        //           type: S2ModalType.bottomSheet,
        //           useFilter: true,
        //           confirmMargin: EdgeInsets.symmetric(horizontal: 120)),
        //       placeholder: 'Select one or multiple flats.',
        //       onChange: (selected) => setState(() {
        //         _flatNo = selected.value;
        //         print('PRINT ONCHANGE');
        //         print(selected.value);
        //         totalflatarea = 0.0;
        //         for (int i = 0; i < selected.value.length; i++) {
        //           for (int j = 0; j < flatList!.length; j++) {
        //             if (selected.value[i] == flatList![j].flatId!) {
        //               totalflatarea =
        //                   totalflatarea + double.parse(flatList![j].flatArea!);
        //               break;
        //             }
        //           }
        //         }
        //         print('TotalFlatArea');
        //         print(totalflatarea);
        //         setState(() {
        //           _txtControllerArea.text = "$totalflatarea SqFt";
        //         });
        //       }),
        //       choiceType: S2ChoiceType.checkboxes,
        //       choiceItems: S2Choice.listFrom<String, Map<String, String>>(
        //         source: flats,
        //         value: (index, item) => item['id'] ?? '',
        //         title: (index, item) => item['name'] ?? '',
        //       ),
        //       //modalType: S2ModalType.popupDialog,
        //       modalFilter: true,
        //       modalHeader: true,
        //       modalFilterAuto: true,
        //       modalFooterBuilder: (context, state) {
        //         return GestureDetector(
        //           onTap: () {
        //             Navigator.pop(context);
        //           },
        //           child: Container(
        //             width: double.infinity,
        //             height: 50,
        //             alignment: Alignment.center,
        //             decoration: const BoxDecoration(
        //               color: Colors.black,
        //             ),
        //             child: const Text(
        //               'SUBMIT',
        //               style: TextStyle(
        //                 color: Colors.white,
        //                 fontSize: 16.0,
        //               ),
        //             ),
        //           ),
        //         );
        //       },
        //       tileBuilder: (context, state) {
        //         return S2Tile.fromState(
        //           state,
        //           isTwoLine: true,
        //         );
        //       },
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _flatarea() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 230.0,
          height: 40.0,
          child: Container(
            padding: const EdgeInsets.only(top: 15),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'HelveticaNeue'),
                children: [
                  TextSpan(
                    text: 'Flat Area',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'HelveticaNeue'),
                  ),
                  // if (isRequired == true)
                  TextSpan(
                    text: "*", // The asterisk
                    style: TextStyle(
                      color: Colors.red, // Color for the asterisk
                    ),
                  ),
                ],
              ),
            ),
          ),
          //  Padding(
          //   padding: EdgeInsets.only(top: 15.0),
          //   child: Text('Flat Area',
          //       style: TextStyle(
          //           backgroundColor: Colors.white,
          //           fontSize: 15,
          //           color: Colors.black)),
          // ),
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
                controller: _txtControllerArea,
                enabled: false,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Area',
                ),
                onChanged: (String str) {
                  //arrayList[index]['casting_for'] = str;
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _flatFinishingType() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 230.0,
          height: 40.0,
          child: Container(
            padding: const EdgeInsets.only(top: 15),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'HelveticaNeue'),
                children: [
                  TextSpan(
                    text: 'Finishing Type',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'HelveticaNeue'),
                  ),
                  // if (isRequired == true)
                  TextSpan(
                    text: "*", // The asterisk
                    style: TextStyle(
                      color: Colors.red, // Color for the asterisk
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.only(top: 15.0),
          //   child: Text('Finishing Type',
          //       style: TextStyle(
          //           backgroundColor: Colors.white,
          //           fontSize: 15,
          //           color: Colors.black)),
          // ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: InkWell(
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    surfaceTintColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    titlePadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    actionsPadding:
                        const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    actionsAlignment: MainAxisAlignment.center,
                    title: const Text(
                      "Select Unit Type",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      Row(
                        children: [
                          // Expanded(
                          //   child: InkWell(
                          //     onTap: () {
                          //       searchText = "";
                          //       _textFieldController.clear();
                          //       Navigator.of(context).pop();
                          //       // _displayTextInputDialog(
                          //       //     context: context, selectedInd: index);
                          //     },
                          //     child: Container(
                          //       padding:
                          //           const EdgeInsets.symmetric(vertical: 4),
                          //       decoration: BoxDecoration(
                          //           color: Colors.black,
                          //           borderRadius: BorderRadius.circular(7)),
                          //       child: const Center(
                          //         child: Text(
                          //           "ADD CUSTOM UNIT",
                          //           style: TextStyle(
                          //             fontSize: 16,
                          //             fontWeight: FontWeight.w600,
                          //             color: Colors.white,
                          //           ),
                          //           textAlign: TextAlign.center,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(width: 30),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(7)),
                                child: const Center(
                                  child: Text(
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
                            ),
                          ),
                        ],
                      ),
                    ],
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState1) {
                        return Container(
                          width: 500,
                          height: 404,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              verticalSpaceTiny,
                              SizedBox(
                                height: 40,
                                child: TextField(
                                  onChanged: (value) {
                                    setState1(() {
                                      searchText = value;
                                    });
                                  },
                                  style: const TextStyle(fontSize: 13),
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.all(12.0),
                                      labelText: 'Search Unit Type',
                                      hintText: "Search Unit Type",
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
                                    itemCount: filteredProjects()!.length,
                                    itemBuilder: (context, int ind) {
                                      return InkWell(
                                        onTap: () {
                                          setState1(() {
                                            if (selectedFinishingType
                                                    ?.mstFinishingId ==
                                                filteredProjects()![ind]
                                                    .mstFinishingId) {
                                              // arrayList[index]!.selectedUnitId =
                                              //     "";
                                              // arrayList[index]!
                                              //     .controllerText
                                              //     ?.text = '';
                                              // arrayList[index]!.woUnit = "";
                                              selectedFinishingType = null;
                                              finishingtypeController.clear();
                                              strFinishingTypeSelected = "";
                                            } else {
                                              selectedFinishingType =
                                                  filteredProjects()![ind];
                                              finishingtypeController.text =
                                                  filteredProjects()![ind]
                                                          .mstFinishingName ??
                                                      '';
                                              strFinishingTypeSelected =
                                                  filteredProjects()![ind]
                                                          .mstFinishingName ??
                                                      '';
                                              // arrayList[index]!.selectedUnitId =
                                              //     filteredProjects()![ind]
                                              //         .unitId;
                                              // arrayList[index]!
                                              //     .controllerText
                                              //     ?.text = widget
                                              //         .gradeUnit![ind]
                                              //         .unitName ??
                                              //     '';
                                              // arrayList[index]!.woUnit = widget
                                              //         .gradeUnit![ind]
                                              //         .unitName ??
                                              //     '';
                                            }
                                            // inspect(arrayList[index]);
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0, vertical: 7.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        filteredProjects()![ind]
                                                                .mstFinishingName ??
                                                            '',
                                                        style: normalText,
                                                      ),
                                                    ],
                                                  ),
                                                  selectedFinishingType
                                                              ?.mstFinishingId ==
                                                          filteredProjects()![
                                                                  ind]
                                                              .mstFinishingId
                                                      ? const Icon(
                                                          Icons.circle,
                                                          size: 25,
                                                          color: Colors.green,
                                                        )
                                                      : const Icon(
                                                          Icons.circle_outlined,
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
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
            child: Container(
              color: kcTextFieldColor,
              child: TextFormField(
                autofocus: false,
                enabled: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "(Finishing Type Cannot Be Empty)";
                  }
                },
                controller: finishingtypeController,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: InputDecoration(
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down_sharp,
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.all(10),
                  border: InputBorder.none,
                  hintText: 'Select finishing type',
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF5F5C5C)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: (Colors.red),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: (Color(0xFF5F5C5C)),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Expanded(
        //   child: Container(
        //     height: 65,
        //     decoration: BoxDecoration(
        //         color: kcTextFieldColor,
        //         border: Border.all(
        //           color: Colors.grey,
        //         ),
        //         borderRadius: const BorderRadius.all(Radius.circular(5.0))),
        //     child: SmartSelect<String?>.single(
        //       title: 'Finishing Type',
        //       selectedValue: _finishingType,
        //       placeholder: 'Select finishing type',
        //       onChange: (selected) => setState(() {
        //         _finishingType = selected.value;
        //         print('_finishingType');
        //         print('${_finishingType}');
        //         for (int i = 0; i < selected.value!.length; i++) {
        //           for (int j = 0; j < finishingBookList!.length; j++) {
        //             if (selected.value![i] ==
        //                 finishingBookList![j].mstFinishingId!) {
        //               strFinishingTypeSelected =
        //                   finishingBookList![j].mstFinishingName!;
        //               break;
        //             }
        //           }
        //         }
        //       }),
        //       choiceType: S2ChoiceType.radios,
        //       choiceItems: S2Choice.listFrom<String, Map<String, String>>(
        //         source: finishingType,
        //         value: (index, item) => item['id'] ?? '',
        //         title: (index, item) => item['name'] ?? '',
        //       ),
        //       modalConfig: const S2ModalConfig(
        //           type: S2ModalType.bottomSheet,
        //           useFilter: true,
        //           confirmMargin: EdgeInsets.symmetric(horizontal: 120)),
        //       modalFilter: true,
        //       modalHeader: true,
        //       modalFilterAuto: true,
        //       modalFooterBuilder: (context, state) {
        //         return GestureDetector(
        //           onTap: () {
        //             Navigator.pop(context);
        //           },
        //           child: Container(
        //             width: double.infinity,
        //             height: 50,
        //             alignment: Alignment.center,
        //             decoration: const BoxDecoration(
        //               color: Colors.black,
        //             ),
        //             child: const Text(
        //               'SUBMIT',
        //               style: TextStyle(
        //                 color: Colors.white,
        //                 fontSize: 16.0,
        //               ),
        //             ),
        //           ),
        //         );
        //       },
        //       tileBuilder: (context, state) {
        //         return S2Tile.fromState(
        //           state,
        //           isTwoLine: true,
        //         );
        //       },
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _flatRatePerSqFt() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Rate Per Sq.Ft.',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            height: 45.0,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(color: Colors.grey),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: RawKeyboardListener(
                focusNode: _focusRatePerSqFt,
                child: TextField(
                  controller: _txtControllerRatePerSqFt,
                  style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                    border: InputBorder.none,
                    hintText: 'Enter Rate Per Sq.Ft.',
                  ),
                  onChanged: (value) {
                    _txtControllerFlatAgreementValue.clear();
                  },
                  onSubmitted: (String str) {
                    if (str.isNotEmpty) {
                      if (_txtControllerArea.text.isNotEmpty) {
                        customChargesCalculation();
                      }
                    } else {
                      setState(() {
                        _txtControllerFlatAgreementValue.text = "";
                      });
                    }
                  },
                ),
                onKey: (RawKeyEvent event) {
                  if (event.isKeyPressed(LogicalKeyboardKey.tab)) {
                    if (_txtControllerArea.text.isNotEmpty) {
                      customChargesCalculation();
                    } else {
                      setState(() {
                        _txtControllerFlatAgreementValue.text = "";
                      });
                    }
                  }
                }),
          ),
        )
      ],
    );
  }

  void customChargesCalculation() {
    print('Called');
    var totalValueAddedCustom = 0.0;
    selectedTotalOtherCharges = 0.0;
    strTotalValueBottom = 0.0;
    totalCustomChargesGST = 0.0;
    var rupee = "\u{20B9}";
    var totalArea = _txtControllerArea.text;
    totalArea = totalArea.replaceAll('SqFt', "");
    totalArea = totalArea.replaceAll('Sq.ft.', "");
    totalArea = totalArea.replaceAll(',', "");
    totalArea = totalArea.replaceAll(' ', "");
    print('totalArea');
    print(totalArea);

    for (int i = 0; i < otherCharges.length; i++) {
      print('INSIDE');
      if (otherCharges[i].selected == 'true') {
        var actualCharges = 0.0;
        var calculated = otherCharges[i].calculated!;
        if (calculated == "0") {
          //Sqft
          print('IN 0');
          if (otherCharges[i].chargesId! == "3") {
            var floorRise = 0.0;
            for (int j = 0; j < _flatNo.length; j++) {
              for (int k = 0; k < flatList!.length; k++) {
                if (_flatNo[j] == flatList![k].flatId!) {
                  floorRise = floorRise +
                      (double.parse(flatList![k].floorNumber!) *
                          double.parse(otherCharges[i].value!) *
                          double.parse(flatList![k].flatArea!));
                }
              }
            }
            if (otherCharges[i].collected == "0") {
              var gst = 0.0;
              if (otherCharges[i].chargesGst != "") {
                gst =
                    floorRise * double.parse(otherCharges[i].chargesGst!) / 100;
                totalCustomChargesGST = totalCustomChargesGST + gst;
              }
            } else {
              var gst = 0.0;
              if (otherCharges[i].chargesGst != "") {
                gst =
                    floorRise * double.parse(otherCharges[i].chargesGst!) / 100;
                floorRise = floorRise + gst;
              }
            }
            actualCharges = floorRise;
            selectedTotalOtherCharges =
                selectedTotalOtherCharges + actualCharges;
            var collected = otherCharges[i].collected!;
            if (collected == "0") {
              totalValueAddedCustom = totalValueAddedCustom + actualCharges;
            }
            otherCharges[i].totalValue = '$actualCharges';
          } else {
            print('IN else');
            actualCharges =
                double.parse(totalArea) * double.parse(otherCharges[i].value!);
            print('actualCharges');
            print(actualCharges);
            if (otherCharges[i].collected == "0") {
              print('collected_0');
              var gst = 0.0;
              if (otherCharges[i].chargesGst != "") {
                gst = actualCharges *
                    double.parse(otherCharges[i].chargesGst!) /
                    100;
                totalCustomChargesGST = totalCustomChargesGST + gst;
              }
            } else {
              print('collected_1');
              var gst = 0.0;
              if (otherCharges[i].chargesGst != "") {
                gst = actualCharges *
                    double.parse(otherCharges[i].chargesGst!) /
                    100;
                actualCharges = actualCharges + gst;
              }
            }
            selectedTotalOtherCharges =
                selectedTotalOtherCharges + actualCharges;
            print('selectedTotalOtherCharges_IN');
            print(selectedTotalOtherCharges);
            var collected = otherCharges[i].collected!;
            if (collected == "0") {
              totalValueAddedCustom = totalValueAddedCustom + actualCharges;
            }
            otherCharges[i].totalValue = '$actualCharges';
          }
        } else if (calculated == "1") {
          //Lumsum
          if (otherCharges[i].chargesId! == "3") {
            var floorRise = 0.0;
            for (int j = 0; j < _flatNo.length; j++) {
              for (int k = 0; k < flatList!.length; k++) {
                if (_flatNo[j] == flatList![k].flatId!) {
                  floorRise = floorRise +
                      (double.parse(flatList![k].floorNumber!) *
                          double.parse(otherCharges[i].value!) *
                          double.parse(flatList![k].flatArea!));
                }
              }
            }
            if (otherCharges[i].collected == "0") {
              var gst = 0.0;
              if (otherCharges[i].chargesGst != "") {
                gst =
                    floorRise * double.parse(otherCharges[i].chargesGst!) / 100;
                totalCustomChargesGST = totalCustomChargesGST + gst;
              }
            } else {
              var gst = 0.0;
              if (otherCharges[i].chargesGst != "") {
                gst =
                    floorRise * double.parse(otherCharges[i].chargesGst!) / 100;
                floorRise = floorRise + gst;
              }
            }
            actualCharges = floorRise;
            selectedTotalOtherCharges =
                selectedTotalOtherCharges + actualCharges;
            var collected = otherCharges[i].collected!;
            if (collected == "0") {
              totalValueAddedCustom = totalValueAddedCustom + actualCharges;
            }
            otherCharges[i].totalValue = '$actualCharges';
          } else {
            for (int j = 0; j < _flatNo.length; j++) {
              for (int k = 0; k < flatList!.length; k++) {
                if (_flatNo[j] == flatList![k].flatId!) {
                  actualCharges =
                      actualCharges + double.parse(otherCharges[i].value!);
                }
              }
            }
            if (otherCharges[i].collected == "0") {
              var gst = 0.0;
              if (otherCharges[i].chargesGst != "") {
                gst = actualCharges *
                    double.parse(otherCharges[i].chargesGst!) /
                    100;
                totalCustomChargesGST = totalCustomChargesGST + gst;
              }
            } else {
              var gst = 0.0;
              if (otherCharges[i].chargesGst != "") {
                gst = actualCharges *
                    double.parse(otherCharges[i].chargesGst!) /
                    100;
                actualCharges = actualCharges + gst;
              }
            }

            selectedTotalOtherCharges =
                selectedTotalOtherCharges + actualCharges;
            var collected = otherCharges[i].collected!;
            if (collected == "0") {
              totalValueAddedCustom = totalValueAddedCustom + actualCharges;
            }
            otherCharges[i].totalValue = '$actualCharges';
          }
        } else if (calculated == "2") {
          print('IN_2');
          if (flagParking == true) {
            var parkingValue = double.parse(otherCharges[i].value!);

            if (arrSelectedParkingList!.isNotEmpty) {
              print('Parking_isNotEmpty');
              var actualValue = parkingValue *
                  double.parse('${arrSelectedParkingList!.length}');
              totalValueAddedCustom = totalValueAddedCustom + actualValue;
              otherCharges[i].totalValue = '$actualValue';
              selectedTotalOtherCharges =
                  selectedTotalOtherCharges + actualValue;
              var collected = otherCharges[i].collected!;
              if (collected == "0") {
                var gst = 0.0;
                if (otherCharges[i].chargesGst != "") {
                  gst = actualValue *
                      double.parse(otherCharges[i].chargesGst!) /
                      100;
                  totalCustomChargesGST = totalCustomChargesGST + gst;
                }
              }
            } else {
              print('Parking_isEmpty');
              if (_txtcontrollerParkingCount.text.isEmpty) {
                print('ParkingCount_isEmpty');
                totalValueAddedCustom = totalValueAddedCustom + parkingValue;
                otherCharges[i].totalValue = '$parkingValue';
                selectedTotalOtherCharges =
                    selectedTotalOtherCharges + parkingValue;
                var collected = otherCharges[i].collected!;
                if (collected == "0") {
                  var gst = 0.0;
                  if (otherCharges[i].chargesGst != "") {
                    gst = parkingValue *
                        double.parse(otherCharges[i].chargesGst!) /
                        100;
                    totalCustomChargesGST = totalCustomChargesGST + gst;
                  }
                }
              } else {
                print('ParkingCount_isNotEmpty');
                var actualValue = parkingValue *
                    double.parse(_txtcontrollerParkingCount.text);
                totalValueAddedCustom = totalValueAddedCustom + actualValue;
                otherCharges[i].totalValue = '$actualValue';
                selectedTotalOtherCharges =
                    selectedTotalOtherCharges + actualValue;
                var collected = otherCharges[i].collected!;
                if (collected == "0") {
                  var gst = 0.0;
                  if (otherCharges[i].chargesGst != "") {
                    gst = actualValue *
                        double.parse(otherCharges[i].chargesGst!) /
                        100;
                    totalCustomChargesGST = totalCustomChargesGST + gst;
                  }
                }
              }
            }
          }
        }
      }
    }

    for (int i = 0; i < otherChargesOneTime.length; i++) {
      print('otherChargesOneTime Inside');
      if (otherChargesOneTime[i].selected == 'true') {
        print('otherChargesOneTime true');
        var actualCharges = 0.0;
        var calculated = otherChargesOneTime[i].calculated!;
        if (calculated == "0") {
          //Sqft
          print('IN 0');
          if (otherChargesOneTime[i].chargesId! == "3") {
            var floorRise = 0.0;
            for (int j = 0; j < _flatNo.length; j++) {
              for (int k = 0; k < flatList!.length; k++) {
                if (_flatNo[j] == flatList![k].flatId!) {
                  floorRise = floorRise +
                      (double.parse(flatList![k].floorNumber!) *
                          double.parse(otherChargesOneTime[i].value!) *
                          double.parse(flatList![k].flatArea!));
                }
              }
            }
            if (otherChargesOneTime[i].collected == "0") {
              var gst = 0.0;
              if (otherChargesOneTime[i].chargesGst != "") {
                gst = floorRise *
                    double.parse(otherChargesOneTime[i].chargesGst!) /
                    100;
                totalCustomChargesGST = totalCustomChargesGST + gst;
              }
            } else {
              var gst = 0.0;
              if (otherChargesOneTime[i].chargesGst != "") {
                gst = floorRise *
                    double.parse(otherChargesOneTime[i].chargesGst!) /
                    100;
                floorRise = floorRise + gst;
              }
            }
            actualCharges = floorRise;
            selectedTotalOtherCharges =
                selectedTotalOtherCharges + actualCharges;
            var collected = otherChargesOneTime[i].collected!;
            if (collected == "0") {
              totalValueAddedCustom = totalValueAddedCustom + actualCharges;
            }
            otherChargesOneTime[i].totalValue = '$actualCharges';
          } else {
            print('IN else');
            actualCharges = double.parse(totalArea) *
                double.parse(otherChargesOneTime[i].value!);
            print('actualCharges');
            print(actualCharges);
            if (otherChargesOneTime[i].collected == "0") {
              print('collected_0');
              var gst = 0.0;
              if (otherChargesOneTime[i].chargesGst != "") {
                gst = actualCharges *
                    double.parse(otherChargesOneTime[i].chargesGst!) /
                    100;
                totalCustomChargesGST = totalCustomChargesGST + gst;
              }
            } else {
              print('collected_1');
              var gst = 0.0;
              if (otherChargesOneTime[i].chargesGst != "") {
                gst = actualCharges *
                    double.parse(otherChargesOneTime[i].chargesGst!) /
                    100;
                actualCharges = actualCharges + gst;
              }
            }
            selectedTotalOtherCharges =
                selectedTotalOtherCharges + actualCharges;
            print('selectedTotalOtherCharges_IN');
            print(selectedTotalOtherCharges);
            var collected = otherChargesOneTime[i].collected!;
            if (collected == "0") {
              totalValueAddedCustom = totalValueAddedCustom + actualCharges;
            }
            otherChargesOneTime[i].totalValue = '$actualCharges';
          }
        } else if (calculated == "1") {
          //Lumsum

          if (otherChargesOneTime[i].chargesId! == "3") {
            var floorRise = 0.0;
            for (int j = 0; j < _flatNo.length; j++) {
              print(_flatNo[j]);
              for (int k = 0; k < flatList!.length; k++) {
                print(flatList![k].flatId!);
                if (_flatNo[j] == flatList![k].flatId!) {
                  floorRise = floorRise +
                      (double.parse(flatList![k].floorNumber!) *
                          double.parse(otherChargesOneTime[i].value!) *
                          double.parse(flatList![k].flatArea!));
                }
              }
            }

            print('floorRise');
            print(floorRise);

            if (otherChargesOneTime[i].collected == "0") {
              var gst = 0.0;
              if (otherChargesOneTime[i].chargesGst != "") {
                gst = floorRise *
                    double.parse(otherChargesOneTime[i].chargesGst!) /
                    100;
                totalCustomChargesGST = totalCustomChargesGST + gst;
              }
            } else {
              var gst = 0.0;
              if (otherChargesOneTime[i].chargesGst != "") {
                gst = floorRise *
                    double.parse(otherChargesOneTime[i].chargesGst!) /
                    100;
                floorRise = floorRise + gst;
              }
            }
            actualCharges = floorRise;
            selectedTotalOtherCharges =
                selectedTotalOtherCharges + actualCharges;
            var collected = otherChargesOneTime[i].collected!;
            if (collected == "0") {
              totalValueAddedCustom = totalValueAddedCustom + actualCharges;
            }
            otherChargesOneTime[i].totalValue = '$actualCharges';
          } else {
            //actualCharges = floorRise;
            print('actualCharges');
            print(actualCharges);
            for (int j = 0; j < _flatNo.length; j++) {
              for (int k = 0; k < flatList!.length; k++) {
                if (_flatNo[j] == flatList![k].flatId!) {
                  actualCharges = actualCharges +
                      double.parse(otherChargesOneTime[i].value!);
                }
              }
            }
            if (otherChargesOneTime[i].collected == "0") {
              var gst = 0.0;
              if (otherChargesOneTime[i].chargesGst != "") {
                gst = actualCharges *
                    double.parse(otherChargesOneTime[i].chargesGst!) /
                    100;
                totalCustomChargesGST = totalCustomChargesGST + gst;
              }
            } else {
              var gst = 0.0;
              if (otherChargesOneTime[i].chargesGst != "") {
                gst = actualCharges *
                    double.parse(otherChargesOneTime[i].chargesGst!) /
                    100;
                actualCharges = actualCharges + gst;
              }
            }

            selectedTotalOtherCharges =
                selectedTotalOtherCharges + actualCharges;
            var collected = otherChargesOneTime[i].collected!;
            if (collected == "0") {
              totalValueAddedCustom = totalValueAddedCustom + actualCharges;
            }
            otherChargesOneTime[i].totalValue = '$actualCharges';
          }
        } else if (calculated == "2") {
          print('IN_2');
          if (flagParking == true) {
            var parkingValue = double.parse(otherChargesOneTime[i].value!);

            if (arrSelectedParkingList!.isNotEmpty) {
              print('Parking_isNotEmpty');
              var actualValue = parkingValue *
                  double.parse('${arrSelectedParkingList!.length}');
              totalValueAddedCustom = totalValueAddedCustom + actualValue;
              otherChargesOneTime[i].totalValue = '$actualValue';
              selectedTotalOtherCharges =
                  selectedTotalOtherCharges + actualValue;
              var collected = otherChargesOneTime[i].collected!;
              if (collected == "0") {
                var gst = 0.0;
                if (otherChargesOneTime[i].chargesGst != "") {
                  gst = actualValue *
                      double.parse(otherChargesOneTime[i].chargesGst!) /
                      100;
                  totalCustomChargesGST = totalCustomChargesGST + gst;
                }
              }
            } else {
              print('Parking_isEmpty');
              if (_txtcontrollerParkingCount.text.isEmpty) {
                print('ParkingCount_isEmpty');
                totalValueAddedCustom = totalValueAddedCustom + parkingValue;
                otherChargesOneTime[i].totalValue = '$parkingValue';
                selectedTotalOtherCharges =
                    selectedTotalOtherCharges + parkingValue;
                var collected = otherChargesOneTime[i].collected!;
                if (collected == "0") {
                  var gst = 0.0;
                  if (otherChargesOneTime[i].chargesGst != "") {
                    gst = parkingValue *
                        double.parse(otherChargesOneTime[i].chargesGst!) /
                        100;
                    totalCustomChargesGST = totalCustomChargesGST + gst;
                  }
                }
              } else {
                print('ParkingCount_isNotEmpty');
                var actualValue = parkingValue *
                    double.parse(_txtcontrollerParkingCount.text);
                totalValueAddedCustom = totalValueAddedCustom + actualValue;
                otherChargesOneTime[i].totalValue = '$actualValue';
                selectedTotalOtherCharges =
                    selectedTotalOtherCharges + actualValue;
                var collected = otherChargesOneTime[i].collected!;
                if (collected == "0") {
                  var gst = 0.0;
                  if (otherChargesOneTime[i].chargesGst != "") {
                    gst = actualValue *
                        double.parse(otherChargesOneTime[i].chargesGst!) /
                        100;
                    totalCustomChargesGST = totalCustomChargesGST + gst;
                  }
                }
              }
            }
          }
        }
      }
    }

    print('selectedTotalOtherCharges');
    print(selectedTotalOtherCharges);

    setState(() {
      _txtControllerOthercharges.text =
          currencyFormat.format(selectedTotalOtherCharges);
    });

    var value = _txtControllerFlatAgreementValue.text;
    value = value.replaceAll(rupee, "");
    value = value.replaceAll(',', "");
    value = value.replaceAll(' ', "");
    print('value');
    print(value);

    if (value != '') {
      var flatValue = double.parse(value) / double.parse(totalArea);
      setState(() {
        _txtControllerRatePerSqFt.text = currencyFormat.format(flatValue);
      });
      gstValue = 0.0;
      gstValue =
          double.parse(value) * double.parse('${percentagate!.gstPer}') / 100;
      gstValue = gstValue + totalCustomChargesGST;
      print('GST');
      print(gstValue);
      var totalValue = double.parse(value) + totalValueAddedCustom;

      setState(() {
        _txtControllerFlatAgreementValue.text =
            currencyFormat.format(double.parse(value));
      });

      var MarketAgreemntValue = "0";
      if (strStampDutyFlag == 0) {
        //Agreement Value
        MarketAgreemntValue = _txtControllerFlatAgreementValue.text;
        MarketAgreemntValue = MarketAgreemntValue.replaceAll(rupee, "");
        MarketAgreemntValue = MarketAgreemntValue.replaceAll(',', "");
        MarketAgreemntValue = MarketAgreemntValue.replaceAll(' ', "");
        print('MarketAgreemntValue');
        print(MarketAgreemntValue);
        var totalValueAgreement =
            double.parse(MarketAgreemntValue) + totalValueAddedCustom;
        SDValue = 0.0;
        if (flagSDValue == true) {
          setState(() {
            SDValue = totalValueAgreement *
                double.parse('${percentagate!.stampDurty}') /
                100;
          });
        }
        strSdValue = '$SDValue';
      } else if (strStampDutyFlag == 1) {
        //Market Value
        MarketAgreemntValue = _txtControllerFlatMarketValue.text;
        MarketAgreemntValue = MarketAgreemntValue.replaceAll(rupee, "");
        MarketAgreemntValue = MarketAgreemntValue.replaceAll(',', "");
        MarketAgreemntValue = MarketAgreemntValue.replaceAll(' ', "");
        print('MarketAgreemntValue');
        print(MarketAgreemntValue);
        var totalValueAgreement = double.parse(MarketAgreemntValue);
        SDValue = 0.0;
        if (flagSDValue == true) {
          setState(() {
            SDValue = totalValueAgreement *
                double.parse('${percentagate!.stampDurty}') /
                100;
          });
        }
        strSdValue = '$SDValue';
      } /*else {
        SDValue = 0.0;
        if (flagSDValue == true) {
          setState(() {
            SDValue =
                totalValue * double.parse('${percentagate!.stampDurty}') / 100;
          });
        }
        strSdValue = '${SDValue}';
      }*/
      print('totalValue1');
      print(totalValue);
      setState(() {
        strTotalValueBottom = totalValue;
      });
    } else if (_txtControllerRatePerSqFt.text != "") {
      var rupee = "\u{20B9}";
      var valueRate = _txtControllerRatePerSqFt.text;
      valueRate = valueRate.replaceAll(rupee, "");
      valueRate = valueRate.replaceAll(',', "");
      valueRate = valueRate.replaceAll(' ', "");
      print('valueRate');
      print(valueRate);
      var flatValue = double.parse(valueRate) * double.parse(totalArea);
      print('flatValue');
      print(flatValue);
      setState(() {
        _txtControllerFlatAgreementValue.text =
            currencyFormat.format(flatValue);
      });
      var totalValueCustom = flatValue;
      gstValue = 0.0;
      gstValue = double.parse(valueRate) *
          double.parse('${percentagate!.gstPer}') /
          100;
      gstValue = gstValue + totalCustomChargesGST;
      print('GST');
      print(gstValue);
      var totalValue = totalValueCustom + totalValueAddedCustom;

      var MarketAgreemntValue = "0";
      if (strStampDutyFlag == 0) {
        //Agreement Value
        MarketAgreemntValue = _txtControllerFlatAgreementValue.text;
        MarketAgreemntValue = MarketAgreemntValue.replaceAll('SqFt', "");
        MarketAgreemntValue = MarketAgreemntValue.replaceAll(',', "");
        MarketAgreemntValue = MarketAgreemntValue.replaceAll(' ', "");
        print('MarketAgreemntValue');
        print(MarketAgreemntValue);
        var totalValueAgreement =
            double.parse(MarketAgreemntValue) + totalValueAddedCustom;
        SDValue = 0.0;
        if (flagSDValue == true) {
          setState(() {
            SDValue = totalValueAgreement *
                double.parse('${percentagate!.stampDurty}') /
                100;
          });
        }
        strSdValue = '$SDValue';
      } else if (strStampDutyFlag == 1) {
        //Market Value
        MarketAgreemntValue = _txtControllerFlatMarketValue.text;
        MarketAgreemntValue = MarketAgreemntValue.replaceAll('SqFt', "");
        MarketAgreemntValue = MarketAgreemntValue.replaceAll(',', "");
        MarketAgreemntValue = MarketAgreemntValue.replaceAll(' ', "");
        print('MarketAgreemntValue');
        print(MarketAgreemntValue);
        var totalValueAgreement = double.parse(MarketAgreemntValue);
        SDValue = 0.0;
        if (flagSDValue == true) {
          setState(() {
            SDValue = totalValueAgreement *
                double.parse('${percentagate!.stampDurty}') /
                100;
          });
        }
        strSdValue = '$SDValue';
      } else {
        SDValue = 0.0;
        if (flagSDValue == true) {
          setState(() {
            SDValue =
                totalValue * double.parse('${percentagate!.stampDurty}') / 100;
          });
        }
        strSdValue = '$SDValue';
      }
      print('totalValue');
      print(totalValue);

      setState(() {
        strTotalValueBottom = totalValue;
      });
    } else {
      print('totalValueAddedCustom');
      print(totalValueAddedCustom);
      setState(() {
        strTotalValueBottom = totalValueAddedCustom;
      });
    }

    setState(() {
      gstValue = 0.0;
      gstValue =
          strTotalValueBottom * double.parse('${percentagate!.gstPer}') / 100;
      // gstValue = gstValue + totalCustomChargesGST;
      // strTotalValueBottom = strTotalValueBottom + gstValue;
      print('GST');
      print(
          '--------------$gstValue ============= $strTotalValueBottom**************** ${percentagate!.gstPer}');
      gst_value = strTotalValueBottom *
          (double.parse(_txtControllerGstPercentage.text.trim()) / 100);
    });

    if (bookingType == "1" || _txtControllerLeaseValueMonthly.text != "") {
      setState(() {
        // _txtControllerFlatAgreementValue.text =
        //     currencyFormat.format(strTotalValueBottom);
        // _txtControllerLeaseValueYearly
        setState(() {
          strTotalValueBottom =
              double.parse(_txtControllerLeaseValueYearly.text);
          _txtControllerLeaseValueMonthly.text =
              (double.parse(_txtControllerLeaseValueYearly.text) / 12.0)
                  .toStringAsFixed(2);
          gst_value = strTotalValueBottom *
              (double.parse(_txtControllerGstPercentage.text.trim()) / 100);
        });
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    _focusRatePerSqFt.dispose();
    _focusAgreementValue.dispose();
    super.dispose();
  }

  Widget _flatLeaseValue() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Lease',
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
                onTap: () {},
                child: TextField(
                  controller: _txtControllerLeaseValueYearly,
                  style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                    border: InputBorder.none,
                    hintText: 'Yearly Value',
                  ),
                  onChanged: (String str) {
                    if (str.isNotEmpty) {
                      setState(() {
                        strTotalValueBottom = double.parse(str);
                        _txtControllerLeaseValueMonthly.text =
                            (double.parse(str) / 12.0).toStringAsFixed(2);
                        gst_value = strTotalValueBottom *
                            (double.parse(
                                    _txtControllerGstPercentage.text.trim()) /
                                100);
                      });
                      //     if (_txtControllerArea.text.isNotEmpty) {
                      //       customChargesCalculation();
                      //     }
                      //   } else {
                      //     setState(() {
                      //       _txtControllerRatePerSqFt.text = "";
                      //     });
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 8, left: 10),
          child: Text(
            '/',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        ),
        // const SizedBox(
        //   // width: 80.0,
        //   height: 40.0,
        //   // child: Padding(
        //   //   padding: EdgeInsets.only(top: 15.0),
        //   //   child: Text('',
        //   //       textAlign: TextAlign.right,
        //   //       style: TextStyle(
        //   //           backgroundColor: Colors.white,
        //   //           fontSize: 15,
        //   //           color: Colors.black)),
        //   // ),
        // ),
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
                onTap: () {},
                child: TextField(
                  controller: _txtControllerLeaseValueMonthly,
                  style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                    border: InputBorder.none,
                    hintText: 'Monthly Value',
                  ),
                  onChanged: (String str) {
                    if (str.isNotEmpty) {
                      setState(() {
                        _txtControllerLeaseValueYearly.text =
                            (double.parse(str) * 12.0).toStringAsFixed(2);
                        strTotalValueBottom = double.parse(str) * 12.0;
                        gst_value = strTotalValueBottom *
                            (double.parse(
                                    _txtControllerGstPercentage.text.trim()) /
                                100);
                        // _txtControllerLeaseValueMonthly.text =
                        //     (double.parse(str) / 12.0).toStringAsFixed(2);
                      });
                      //     if (_txtControllerArea.text.isNotEmpty) {
                      //       customChargesCalculation();
                      //     }
                      //   } else {
                      //     setState(() {
                      //       _txtControllerRatePerSqFt.text = "";
                      //     });
                    }
                  },
                  // onSubmitted: (String str) {
                  //   if (str.isNotEmpty) {
                  //     if (_txtControllerArea.text.isNotEmpty) {
                  //       customChargesCalculation();
                  //     }
                  //   } else {
                  //     setState(() {
                  //       _txtControllerRatePerSqFt.text = "";
                  //     });
                  //   }
                  // },
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _flatAgreementValue() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Flat Agreement Value',
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
                onTap: () {},
                child: RawKeyboardListener(
                    focusNode: _focusAgreementValue,
                    child: TextField(
                      controller: _txtControllerFlatAgreementValue,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 15.0),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                        border: InputBorder.none,
                        hintText: 'Enter flat agreement value',
                      ),
                      onSubmitted: (String str) {
                        if (str.isNotEmpty) {
                          if (_txtControllerArea.text.isNotEmpty) {
                            customChargesCalculation();
                          }
                        } else {
                          setState(() {
                            _txtControllerRatePerSqFt.text = "";
                          });
                        }
                      },
                    ),
                    onKey: (RawKeyEvent event) {
                      if (event.isKeyPressed(LogicalKeyboardKey.tab)) {
                        setState(() {
                          customChargesCalculation();
                        });
                      }
                    }),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _flatMarketValue() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Flat Market Value',
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
                onTap: () {},
                child: TextField(
                  style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  controller: _txtControllerFlatMarketValue,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                    border: InputBorder.none,
                    hintText: 'Enter flat market value',
                  ),
                  onSubmitted: (String str) {
                    customChargesCalculation();
                  },
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _includeParking({
    required String averagePrice,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: 230.0,
              height: 40.0,
              child: Padding(
                padding: EdgeInsets.only(top: 15.0),
                child: Text('Include Parking',
                    style: TextStyle(
                        backgroundColor: Colors.white,
                        fontSize: 15,
                        color: Colors.black)),
              ),
            ),
            horizontalSpaceSmall,
            InkWell(
                onTap: () {
                  for (int j = 0; j < podiumList!.length; j++) {
                    for (int k = 0;
                        k < podiumList![j].parkingList!.length;
                        k++) {
                      podiumList?[j].parkingList?[k].selected = '';
                    }
                  }
                  print(flatNoController.text.isNotEmpty);

                  if (flatNoController.text.isNotEmpty) {
                    double tempCt = 0;
                    List<FlatListParkingList>? tempParkingList = [];

                    for (int i = 0;
                        i < filteredFlatNumberProjects()!.length;
                        i++) {
                      if (filteredFlatNumberProjects()?[i].isSelected == true) {
                        tempCt = tempCt +
                            double.parse(filteredFlatNumberProjects()?[i]
                                    .inventyParkingNumber ??
                                '0');
                        tempParkingList = [
                          ...?tempParkingList,
                          ...?filteredFlatNumberProjects()?[i].parkingList
                        ];
                      }
                    }

                    String parking = "";
                    arrSelectedParkingList?.clear();
                    for (int u = 0; u < tempParkingList!.length; u++) {
                      for (int j = 0; j < podiumList!.length; j++) {
                        for (int k = 0;
                            k < podiumList![j].parkingList!.length;
                            k++) {
                          if (tempParkingList[u].mstParkingId! ==
                              podiumList![j].parkingList![k].mstParkingId) {
                            podiumList?[j].parkingList?[k].selected = 'true';
                            arrSelectedParkingList!
                                .add(podiumList![j].parkingList![k]);
                            if (parking == "") {
                              parking = podiumList![j]
                                  .parkingList![k]
                                  .parkingSerialNo!;
                            } else {
                              parking =
                                  '$parking, ${podiumList![j].parkingList![k].parkingSerialNo!}';
                            }
                          } else {
                            // podiumList![j].parkingList![k].selected = "";
                          }
                        }
                      }
                    }
                    updateParkingNo(parking);

                    //       arrSelectedParkingList
                    // var parking = "";
                    // if (arrSelectedParkingList!.isNotEmpty) {
                    //   for (int i = 0; i < arrSelectedParkingList!.length; i++) {
                    //     if (i == 0) {
                    //       parking = arrSelectedParkingList![i].parkingSerialNo!;
                    //     } else {
                    //       parking =
                    //           '$parking, ${arrSelectedParkingList![i].parkingSerialNo!}';
                    //     }
                    //   }
                    // }
                    // updateParkingNo(parking);

                    _txtcontrollerParkingCount.text = tempCt.toStringAsFixed(0);
                    if (podiumList!.isNotEmpty) {
                      if (flagParking == false) {
                        for (int i = 0; i < otherCharges.length; i++) {
                          if (otherCharges[i].chargesId == "4") {
                            otherCharges[i].selected = 'true';
                            break;
                          }
                        }

                        for (int i = 0; i < otherChargesOneTime.length; i++) {
                          if (otherChargesOneTime[i].chargesId == "4") {
                            otherChargesOneTime[i].selected = 'true';
                            break;
                          }
                        }
                        updaterecords();
                        setState(() {
                          flagParking = true;
                        });
                      } else {
                        for (int i = 0; i < otherCharges.length; i++) {
                          if (otherCharges[i].chargesId == "4") {
                            otherCharges[i].selected = "false";
                            break;
                          }
                        }

                        for (int i = 0; i < otherChargesOneTime.length; i++) {
                          if (otherChargesOneTime[i].chargesId == "4") {
                            otherChargesOneTime[i].selected = "false";
                            break;
                          }
                        }
                        updaterecords();
                        setState(() {
                          flagParking = false;
                          strParkingSelectedNo = '';
                          _txtcontrollerParkingCount.text = '';
                        });
                      }
                      customChargesCalculation();
                    }
                  }
                },
                child: flagParking == false
                    ? Icon(
                        Icons.check_box_outline_blank,
                        size: 40,
                        color:
                            podiumList!.isNotEmpty ? Colors.black : Colors.grey,
                      )
                    : const Icon(Icons.check_box_outlined,
                        size: 40, color: Colors.black)),
            horizontalSpaceSmall,
            flagParking == true
                ? Expanded(
                    child: Container(
                      height: 45.0,
                      decoration: BoxDecoration(
                          color: kcTextFieldColor,
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5.0))),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: InkWell(
                          onTap: () {},
                          child: TextField(
                            controller: _txtcontrollerParkingCount,
                            onSubmitted: (String str) {
                              customChargesCalculation();
                            },
                            style: const TextStyle(
                                color: Colors.black, fontSize: 15.0),
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 18.0),
                              border: InputBorder.none,
                              hintText: 'Enter Parking Count',
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            horizontalSpaceSmall,
            flagParking == true
                ? Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Text('/ $totalPark',
                        style: const TextStyle(
                            backgroundColor: Colors.white,
                            fontSize: 15,
                            color: Colors.black)),
                  )
                : const SizedBox(),
            horizontalSpaceSmall
          ],
        ),
        if (flagParking == true)
          Container(
            padding: const EdgeInsets.only(
              left: 250.0,
            ),
            child: Text(
                '(Avg. Parking Price: ${currencyFormat.format(double.parse(averagePrice))})',
                style: const TextStyle(
                    // backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black54)),
          ),
        flagParking == true
            ? Padding(
                padding: const EdgeInsets.only(left: 240.0, top: 10),
                child: Container(
                    height: 65,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: kcTextFieldColor,
                        border: Border.all(
                          color: Colors.grey,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5.0))),
                    child: InkWell(
                      onTap: () {
                        print('clicked${_txtcontrollerParkingCount.text}');
                        _txtcontrollerParkingCount.text.isNotEmpty
                            ? _show()
                            : null;
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15.0, top: 10.0),
                            child: Text(
                              'Select Parking Place',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0, top: 5),
                            child: Text(
                              '$strParkingSelectedNo',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    )

                    /*SmartSelect<String>.multiple(
                title: 'Parking Place',
                placeholder: 'Choose one or more',
                selectedValue: _parkingPlace,
                onChange: (state) =>
                    setState(() => _parkingPlace = state.value),
                choiceItems: S2Choice.listFrom<String, Map>(
                  source: parkingPlace,
                  value: (index, item) => item['value'],
                  title: (index, item) => item['title'],
                  group: (index, item) => item['body'],
                ),
                choiceGrouped: true,
                modalType: S2ModalType.popupDialog,
                modalConfirm: true,
                modalFilter: true,
                groupBuilder: (context, header, choices) {
                  return StickyHeader(
                    header: header.titleWidget,
                    content: header.groupChoices(choices),
                  );
                },
                groupHeaderBuilder: (context, group, searchText) {
                  return Container(
                    color: Colors.redAccent,
                    padding: const EdgeInsets.all(15),
                    alignment: Alignment.centerLeft,
                    child: S2Text(
                      text: group.title,
                      highlightColor: Colors.teal,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
                tileBuilder: (context, state) {
                  return S2Tile.fromState(
                    state,
                    isTwoLine: true,
                    leading: const CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://source.unsplash.com/yeVtxxPxzbw/100x100'),
                    ),
                  );
                }),*/
                    ),
              )
            : const SizedBox(),
      ],
    );
  }

  void _show() async {
    //   SmartDialog.show(
    //       clickMaskDismiss: false,
    //       builder: (_) {
    //         return Container(
    //           width: MediaQuery.of(context).size.width / 2,
    //           height: MediaQuery.of(context).size.height / 1.5,
    //           decoration: BoxDecoration(
    //             color: Colors.white,
    //             borderRadius: BorderRadius.circular(10),
    //           ),
    //           alignment: Alignment.center,
    //           child: Padding(
    //             padding: const EdgeInsets.all(15.0),
    //             child: Column(
    //               mainAxisAlignment: MainAxisAlignment.start,
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               children: [
    //                 const SizedBox(
    //                   height: 40,
    //                   child: Center(
    //                     child: Text(
    //                       'SELECT PARKING PLACE',
    //                       style: TextStyle(
    //                         color: Colors.black,
    //                         fontSize: 18,
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //                 const Divider(),
    //                 Expanded(
    //                   child:
    // ListView.builder(
    //                     itemBuilder: (BuildContext context, int index) =>
    //                         MyExpandableWidget(podiumList![index]),
    //                     itemCount: podiumList!.length,
    //                   ),
    //                 ),
    //                 ElevatedButton(
    //                   style: ElevatedButton.styleFrom(
    //                       backgroundColor: Colors.black,
    //                       fixedSize: const Size.fromWidth(100),
    //                       padding: const EdgeInsets.all(10),
    //                       textStyle: const TextStyle(color: Colors.white)),
    //                   child: const Padding(
    //                     padding: EdgeInsets.all(10.0),
    //                     child: Text('OK', style: TextStyle(color: Colors.white)),
    //                   ),
    //                   onPressed: () {
    //                     if (arrSelectedParkingList!.isNotEmpty) {
    //                       if (arrSelectedParkingList!.length <
    //                           int.parse(_txtcontrollerParkingCount.text)) {
    //                         // messageAlertAll();
    //                         SmartDialog.dismiss();
    //                       } else {
    //                         SmartDialog.dismiss();
    //                       }
    //                     } else {
    //                       SmartDialog.dismiss();
    //                     }
    //                   },
    //                 )
    //               ],
    //             ),
    //           ),
    //         );
    //       });

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context1, setState1) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
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
                "SELECT PARKING PLACE",
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
                  // InkWell(
                  //   onTap: () {
                  //     Navigator.pop(dialogContext);
                  //   },
                  //   child: Container(
                  //     width: 220,
                  //     padding: const EdgeInsets.symmetric(vertical: 8),
                  //     decoration: const BoxDecoration(
                  //       color: Colors.black,
                  //       borderRadius: BorderRadius.only(
                  //         // bottomRight: Radius.circular(8),
                  //         bottomLeft: Radius.circular(8),
                  //       ),
                  //     ),
                  //     child: const Text(
                  //       'Add Custom',
                  //       textAlign: TextAlign.center,
                  //       style: TextStyle(
                  //         fontSize: 18,
                  //         fontWeight: FontWeight.w600,
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(width: 1),
                  InkWell(
                    onTap: () {
                      if (arrSelectedParkingList!.isNotEmpty) {
                        if (arrSelectedParkingList!.length <
                            int.parse(_txtcontrollerParkingCount.text)) {
                          // messageAlertAll();
                          Navigator.pop(dialogContext);
                        } else {
                          Navigator.pop(dialogContext);
                        }
                      } else {
                        Navigator.pop(dialogContext);
                      }
                    },
                    child: Container(
                      width: 650,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(8),
                          // bottomLeft: Radius.circular(8),
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
              )
            ],
            content: SizedBox(
              height: 400,
              width: 600,
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) =>
                    MyExpandableWidget(podiumList![index]),
                itemCount: podiumList!.length,
              ),
            ),
          );
        });
      },
    );
  }

  MyExpandableWidget(PodiumList? details) {
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
          .map<Widget>((club) => showClubs(club, context))
          .toList(),
    );
  }

  Widget _OtherCharges() {
    txtOtherChargesAmount = [];
    txtOtherChargesOneTimeAmount = [];
    var totalArea = _txtControllerArea.text;
    totalArea = totalArea.replaceAll('SqFt', "");
    totalArea = totalArea.replaceAll(',', "");
    totalArea = totalArea.replaceAll(' ', "");
    print('totalArea');
    print(totalArea);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Other Charges',
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
            if (_flatNo.isEmpty) {
              Alert(
                  closeIcon: const SizedBox(),
                  padding: const EdgeInsets.only(top: 0.0),
                  image: Image.asset('images/Icon-512.png',
                      height: 80, fit: BoxFit.fitWidth),
                  style: const AlertStyle(
                      titleTextAlign: TextAlign.center,
                      descTextAlign: TextAlign.center,
                      descStyle: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 16),
                      isCloseButton: true),
                  context: context,
                  desc: 'Please select flat no from a flat list.',
                  alertAnimation: fadeAlertAnimation,
                  buttons: [
                    DialogButton(
                      onPressed: () => Navigator.pop(context),
                      color: Colors.black,
                      child: const Text(
                        "CLOSE",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ]).show();
            } else {
              if (otherCharges.isNotEmpty || otherChargesOneTime.isNotEmpty) {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return StatefulBuilder(builder: (context, setState) {
                        return AlertDialog(
                          //titlePadding: const EdgeInsets.all(0),
                          title: Container(
                            width: 650,
                            height: 35.0,
                            child: const Center(
                              child: Text('OTHER CHARGES',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black)),
                            ),
                          ),
                          actionsAlignment: MainAxisAlignment.center,
                          actionsPadding: const EdgeInsets.all(20),
                          content: SingleChildScrollView(
                            child: SizedBox(
                              width: 300,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 10),
                                  Container(
                                    height: 35,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: const BoxDecoration(
                                        color: Colors.black12),
                                    child: const Center(
                                      child: Text(
                                        'Added to Flat Value',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 120.0 * otherCharges.length,
                                    child: ListView.builder(
                                      itemCount: otherCharges.length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        txtOtherChargesAmount
                                            ?.add(TextEditingController());
                                        txtOtherChargesAmount![index].text =
                                            currencyFormatWothoutSymbol.format(
                                                double.parse(otherCharges[index]
                                                    .value!));
                                        var floorrise = 0.0;
                                        if (otherCharges[index].chargesId! ==
                                            "3") {
                                          for (int i = 0;
                                              i < _flatNo.length;
                                              i++) {
                                            for (int j = 0;
                                                j < flatList!.length;
                                                j++) {
                                              if (_flatNo[i] ==
                                                  flatList![j].flatId!) {
                                                floorrise = floorrise +
                                                    (double.parse(flatList![j]
                                                            .floorNumber!) *
                                                        double.parse(
                                                            otherCharges[index]
                                                                .value!) *
                                                        double.parse(
                                                            flatList![j]
                                                                .flatArea!));
                                                break;
                                              }
                                            }
                                          }
                                        }
                                        inspect(otherCharges);
                                        return Container(
                                          height: 120,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          if (otherCharges[
                                                                      index]
                                                                  .selected ==
                                                              "true") {
                                                            otherCharges[index]
                                                                    .selected =
                                                                'false';
                                                          } else {
                                                            otherCharges[index]
                                                                    .selected =
                                                                'true';
                                                          }
                                                        });
                                                        //updateOtherChargesAmount();
                                                        customChargesCalculation();
                                                      },
                                                      icon: otherCharges[index]
                                                                  .selected ==
                                                              "true"
                                                          ? const Icon(
                                                              Icons
                                                                  .check_circle_outline_rounded,
                                                              size: 30,
                                                              color:
                                                                  Colors.green,
                                                            )
                                                          : const Icon(
                                                              Icons
                                                                  .circle_outlined,
                                                              size: 30,
                                                            )),
                                                  horizontalSpaceSmall,
                                                  Text(otherCharges[index]
                                                      .name!),
                                                ],
                                              ),
                                              verticalSpaceTiny,
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 30.0),
                                                child: Row(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Text("\u{20B9}"),
                                                        horizontalSpaceSmall,
                                                        SizedBox(
                                                          width: 100,
                                                          height: 40,
                                                          child: TextField(
                                                            controller:
                                                                txtOtherChargesAmount![
                                                                    index],
                                                            enabled: true,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        15.0),
                                                            decoration:
                                                                const InputDecoration(
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                              contentPadding:
                                                                  EdgeInsets.only(
                                                                      left:
                                                                          10.0,
                                                                      right: 10,
                                                                      top: 7.0),
                                                              hintText: 'Rs. 0',
                                                            ),
                                                            // onTapOutside:
                                                            //     (event) {
                                                            //   setState(() {
                                                            //     print('object');
                                                            //   });
                                                            // },
                                                            onTapOutside:
                                                                (event) {
                                                              setState(() {
                                                                print('object');
                                                              });
                                                            },
                                                            onChanged:
                                                                (String str) {
                                                              //arrayList[index]['casting_for'] = str;
                                                              if (str
                                                                  .isNotEmpty) {
                                                                // var strValue =
                                                                //     str;
                                                                // strValue = strValue
                                                                //     .replaceAll(
                                                                //         ",",
                                                                //         "");
                                                                // strValue = strValue
                                                                //     .replaceAll(
                                                                //         " ",
                                                                //         "");
                                                                // setState(() {
                                                                otherCharges[
                                                                        index]
                                                                    .value = str;
                                                                // });
                                                              }
                                                              //updateOtherChargesAmount();
                                                              customChargesCalculation();
                                                            },
                                                          ),
                                                        ),
                                                        horizontalSpaceSmall,
                                                        Text(otherCharges[index]
                                                                .unit ??
                                                            ''),
                                                      ],
                                                    ),
                                                    const Spacer(),
                                                    otherCharges[index].chargesId! ==
                                                            "3"
                                                        ? Text(currencyFormat
                                                            .format(floorrise))
                                                        : otherCharges[index]
                                                                    .name! ==
                                                                "Parking"
                                                            ? _txtcontrollerParkingCount
                                                                    .text
                                                                    .isNotEmpty
                                                                ? Text(currencyFormat.format(double.parse(
                                                                        otherCharges[index]
                                                                            .value!) *
                                                                    double.parse(
                                                                        _txtcontrollerParkingCount
                                                                            .text)))
                                                                : Text(currencyFormat
                                                                    .format(double.parse(otherCharges[index].value!)))
                                                            : otherCharges[index].calculated == '1'
                                                                ? Text(currencyFormat.format(((_flatNo.length * double.parse(otherCharges[index].value!)) + ((_flatNo.length * double.parse(otherCharges[index].value!)) * double.parse(otherCharges[index].chargesGst!) / 100))))
                                                                : Text(currencyFormat.format(double.parse(totalArea) * double.parse(otherCharges[index].value!))),
                                                    horizontalSpaceMedium,
                                                  ],
                                                ),
                                              ),
                                              verticalSpaceTiny,
                                              verticalSpaceTiny,
                                              const Divider(),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: const BoxDecoration(
                                        color: Colors.black12),
                                    child: const Center(
                                      child: Text(
                                        'One Time Charges',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 120.0 * otherChargesOneTime.length,
                                    child: ListView.builder(
                                      itemCount: otherChargesOneTime.length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        txtOtherChargesOneTimeAmount
                                            ?.add(TextEditingController());
                                        txtOtherChargesOneTimeAmount![index]
                                                .text =
                                            // currencyFormatWothoutSymbol.format(
                                            // double.parse(
                                            otherChargesOneTime[index].value!;
                                        // );
                                        // );
                                        var floorrise = 0.0;
                                        if (otherChargesOneTime[index]
                                                .chargesId! ==
                                            "3") {
                                          for (int i = 0;
                                              i < _flatNo.length;
                                              i++) {
                                            for (int j = 0;
                                                j < flatList!.length;
                                                j++) {
                                              if (_flatNo[i] ==
                                                  flatList![j].flatId!) {
                                                floorrise = floorrise +
                                                    (double.parse(flatList![j]
                                                            .floorNumber!) *
                                                        double.parse(
                                                            otherChargesOneTime[
                                                                    index]
                                                                .value!) *
                                                        double.parse(
                                                            flatList![j]
                                                                .flatArea!));
                                                break;
                                              }
                                            }
                                          }
                                        }

                                        return SizedBox(
                                          height: 120,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          if (otherChargesOneTime[
                                                                      index]
                                                                  .selected ==
                                                              "true") {
                                                            otherChargesOneTime[
                                                                        index]
                                                                    .selected =
                                                                'false';
                                                          } else {
                                                            otherChargesOneTime[
                                                                        index]
                                                                    .selected =
                                                                'true';
                                                          }
                                                        });
                                                        //updateOtherChargesAmount();
                                                        customChargesCalculation();
                                                      },
                                                      icon: otherChargesOneTime[
                                                                      index]
                                                                  .selected ==
                                                              "true"
                                                          ? const Icon(
                                                              Icons
                                                                  .check_circle_outline_rounded,
                                                              size: 30,
                                                              color:
                                                                  Colors.green,
                                                            )
                                                          : const Icon(
                                                              Icons
                                                                  .circle_outlined,
                                                              size: 30,
                                                            )),
                                                  horizontalSpaceSmall,
                                                  Text(
                                                      otherChargesOneTime[index]
                                                          .name!),
                                                ],
                                              ),
                                              verticalSpaceTiny,
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 30.0),
                                                child: Row(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Text("\u{20B9}"),
                                                        horizontalSpaceSmall,
                                                        SizedBox(
                                                          width: 100,
                                                          height: 40,
                                                          child: TextField(
                                                            controller:
                                                                txtOtherChargesOneTimeAmount![
                                                                    index],
                                                            enabled: true,
                                                            onEditingComplete:
                                                                () {
                                                              setState(() {
                                                                print('object');
                                                              });
                                                            },
                                                            onTapOutside:
                                                                (event) {
                                                              setState(() {
                                                                print('object');
                                                              });
                                                            },
                                                            onChanged: (value) {
                                                              // setState(() {
                                                              // txtOtherChargesOneTimeAmount![
                                                              //         index]
                                                              //     .text = value;
                                                              otherChargesOneTime[
                                                                          index]
                                                                      .value =
                                                                  value;
                                                              // });
                                                              print('$value');
                                                            },
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        15.0),
                                                            decoration:
                                                                const InputDecoration(
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                              contentPadding:
                                                                  EdgeInsets.only(
                                                                      left:
                                                                          10.0,
                                                                      right: 10,
                                                                      top: 7.0),
                                                              hintText: 'Rs. 0',
                                                            ),
                                                            onSubmitted:
                                                                (String str) {
                                                              //arrayList[index]['casting_for'] = str;
                                                              if (str
                                                                  .isNotEmpty) {
                                                                var strValue =
                                                                    str;
                                                                strValue = strValue
                                                                    .replaceAll(
                                                                        ",",
                                                                        "");
                                                                strValue = strValue
                                                                    .replaceAll(
                                                                        " ",
                                                                        "");
                                                                setState(() {
                                                                  otherChargesOneTime[
                                                                              index]
                                                                          .value =
                                                                      strValue;
                                                                });
                                                              }
                                                              //updateOtherChargesAmount();
                                                              customChargesCalculation();
                                                            },
                                                          ),
                                                        ),
                                                        horizontalSpaceSmall,
                                                        Text(
                                                            otherChargesOneTime[
                                                                    index]
                                                                .unit!),
                                                      ],
                                                    ),
                                                    const Spacer(),
                                                    otherChargesOneTime[index]
                                                                .chargesId! ==
                                                            "3"
                                                        ? Text(currencyFormat
                                                            .format(floorrise))
                                                        : otherChargesOneTime[index]
                                                                    .name! ==
                                                                "Parking"
                                                            ? _txtcontrollerParkingCount
                                                                    .text
                                                                    .isNotEmpty
                                                                ? Text(currencyFormat.format(double.parse(otherChargesOneTime[index].value ?? '0') *
                                                                    double.parse(
                                                                        _txtcontrollerParkingCount
                                                                            .text)))
                                                                : Text(currencyFormat
                                                                    .format(
                                                                        double.parse(otherChargesOneTime[index].value ?? '0')))
                                                            : otherChargesOneTime[index].collected == '1'
                                                                ? Text(currencyFormat.format(double.parse(calVal(index: index)))
                                                                    // (double.parse(txtOtherChargesOneTimeAmount![index].text ?? '0') * double.parse((_txtControllerArea.text).replaceAll('SqFt', ""))).toStringAsFixed(2)
                                                                    // _txtControllerArea.text
                                                                    // otherChargesOneTime[index].chargesGst ?? ''
                                                                    // txtOtherChargesOneTimeAmount![index].text
                                                                    // _flatNo.length.toString()
                                                                    // currencyFormat.format(
                                                                    // ((_flatNo.length * double.parse(txtOtherChargesOneTimeAmount![index].text != "" ? txtOtherChargesOneTimeAmount![index].text : "0")) + ((_flatNo.length * double.parse(txtOtherChargesOneTimeAmount![index].text != "" ? txtOtherChargesOneTimeAmount![index].text : "0")) * double.parse(otherChargesOneTime[index].chargesGst!) / 100)))
                                                                    )
                                                                : Text(currencyFormat.format(double.parse(totalArea) * double.parse(otherChargesOneTime[index].value!))),
                                                    horizontalSpaceMedium,
                                                  ],
                                                ),
                                              ),
                                              verticalSpaceTiny,
                                              verticalSpaceTiny,
                                              const Divider(),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          actions: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        fixedSize: const Size.fromWidth(100),
                                        padding: const EdgeInsets.all(10),
                                        textStyle: const TextStyle(
                                            color: Colors.white)),
                                    child: const Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Text('CANCEL',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                    onPressed: () {
                                      updaterecords();
                                      //updateOtherChargesAmount();
                                      customChargesCalculation();
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        fixedSize: const Size.fromWidth(100),
                                        padding: const EdgeInsets.all(10),
                                        textStyle: const TextStyle(
                                            color: Colors.white)),
                                    child: const Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Text('SUBMIT',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                    onPressed: () {
                                      updaterecords();
                                      //updateOtherChargesAmount();
                                      customChargesCalculation();
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        );
                      });
                    });
              } else {
                Alert(
                    closeIcon: const SizedBox(),
                    padding: const EdgeInsets.only(top: 0.0),
                    image: Image.asset('images/Icon-512.png',
                        height: 80, fit: BoxFit.fitWidth),
                    style: const AlertStyle(
                        titleTextAlign: TextAlign.center,
                        descTextAlign: TextAlign.center,
                        descStyle: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 16),
                        isCloseButton: true),
                    context: context,
                    desc: 'Please set other charges from admin panel.',
                    alertAnimation: fadeAlertAnimation,
                    buttons: [
                      DialogButton(
                        onPressed: () => Navigator.pop(context),
                        color: Colors.black,
                        child: const Text(
                          "CLOSE",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ]).show();
              }
            }
          },
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              color: kcTextFieldColor,
              border: Border.all(width: 0.5),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Other Charges',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  verticalSpaceTiny,
                  Text(
                    strOtherChargesSelected,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ))
        /*Expanded(
          child: Container(
            height: 65,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: SmartSelect<String?>.multiple(
              title: 'Other Charges',
              selectedValue: _otherCharges,
              placeholder: 'Select one or multiple charges.',
              onChange: (selected) {
                for (int i = 0; i < selected.value.length; i++) {
                  for (int j = 0; j < customCharges!.length; j++) {
                    print('inside');
                    var arrCustomCharges = customCharges![j];
                    for (int k = 0; k < arrCustomCharges.length; k++) {
                      if (arrCustomCharges[k].id == selected.value[i]) {
                        print('yes');
                        customCharges![j][k].selected = 'true';
                      } else {
                        print('no');
                        customCharges![j][k].selected = 'false';
                      }
                    }
                  }
                }
                print('customCharges');

                for (int j = 0; j < customCharges!.length; j++) {
                  var arrCustomCharges = customCharges![j];
                  for (int k = 0; k < arrCustomCharges.length; k++) {
                    print(arrCustomCharges[k].name);
                    print(arrCustomCharges[k].selected);
                  }
                }
                setState(() {
                  _otherCharges = selected.value;
                });
              },
              choiceType: S2ChoiceType.checkboxes,
              choiceItems: S2Choice.listFrom<String, Map<String, String>>(
                source: otherCharges,
                value: (index, item) => item['id'] ?? '',
                title: (index, item) => item['name'] ?? '',
              ),
              modalType: S2ModalType.popupDialog,
              modalFilter: true,
              modalHeader: true,
              modalFooterBuilder: (context, state) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                    child: const Text(
                      'SUBMIT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                );
              },
              tileBuilder: (context, state) {
                return S2Tile.fromState(
                  state,
                  isTwoLine: true,
                );
              },
            ),
          ),
        ),*/
      ],
    );
  }

  Widget _Remark() {
    txtOtherChargesAmount = [];
    var totalArea = _txtControllerArea.text;
    totalArea = totalArea.replaceAll('SqFt', "");
    totalArea = totalArea.replaceAll(',', "");
    totalArea = totalArea.replaceAll(' ', "");
    print('totalArea');
    print(totalArea);
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
              child: InkWell(
                onTap: () {},
                child: TextField(
                  controller: _txtControllerRemark,
                  style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                    border: InputBorder.none,
                    hintText: 'Enter Remark',
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  void updaterecords() {
    strOtherChargesSelected = "";
    for (int i = 0; i < otherCharges.length; i++) {
      if (otherCharges[i].selected == "true") {
        if (i == 0) {
          setState(() {
            strOtherChargesSelected = otherCharges[i].name!;
          });
        } else {
          setState(() {
            strOtherChargesSelected =
                "$strOtherChargesSelected, ${otherCharges[i].name!}";
          });
        }
      }
    }

    for (int i = 0; i < otherChargesOneTime.length; i++) {
      if (otherChargesOneTime[i].selected == "true") {
        if (strOtherChargesSelected == "") {
          setState(() {
            strOtherChargesSelected = otherChargesOneTime[i].name!;
          });
        } else {
          setState(() {
            strOtherChargesSelected =
                "$strOtherChargesSelected, ${otherChargesOneTime[i].name!}";
          });
        }
      }
    }

    print(
        '------------------>>>>>>>>>>>$strOtherChargesSelected ${otherCharges.length} ${otherChargesOneTime.length}');
  }

  /*void updateOtherChargesAmount() {
    var totalArea = _txtControllerArea.text;
    totalArea = totalArea.replaceAll('SqFt', "");
    totalArea = totalArea.replaceAll(',', "");
    totalArea = totalArea.replaceAll(' ', "");
    print('totalArea');
    print(totalArea);
    var total = 0.0;
    for (int i = 0; i < otherCharges.length; i++) {
      if (otherCharges[i].selected == "true") {
        if (otherCharges[i].chargesId! == "3") {
          var floorrise = 0.0;
          for (int k = 0; k < _flatNo.length; k++) {
            for (int j = 0; j < flatList!.length; j++) {
              if (_flatNo[k] == flatList![j].flatId!) {
                floorrise = floorrise +
                    (double.parse(flatList![j].floorNumber!) *
                        double.parse(otherCharges[i].value!) *
                        double.parse(flatList![j].flatArea!));
                break;
              }
            }
          }
          print(floorrise);
          total = total + floorrise;
          print(total);
        } else if (otherCharges[i].name! == "Parking") {
          if (_txtcontrollerParkingCount.text.isNotEmpty) {
            total = total +
                (double.parse(otherCharges[i].value!) *
                    double.parse(_txtcontrollerParkingCount.text));
          } else {
            total = total + (double.parse(otherCharges[i].value!));
          }
        } else if (otherCharges[i].collected == '1') {
          total = total +
              ((_flatNo.length * double.parse(otherCharges[i].value!)) +
                  ((_flatNo.length * double.parse(otherCharges[i].value!)) *
                      double.parse(otherCharges[i].chargesGst!) /
                      100));
        } else {
          total = total +
              (double.parse(totalArea) * double.parse(otherCharges[i].value!));
        }
      }
    }
    print(total);
    setState(() {
      _txtControllerOthercharges.text = currencyFormat.format(total);
    });
  }*/

  Widget _totalOtherCharges() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Total Other Charges',
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
                /*controller: TextEditingController.fromValue(TextEditingValue(
                    text: arrayList[index]['casting_for'].toString(),
                    selection: TextSelection.collapsed(
                        offset: arrayList[index]['casting_for'].length))),*/
                controller: _txtControllerOthercharges,
                enabled: false,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Rs. 0',
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _SelectBroker() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Select CP',
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
              searchTextBroker = '';
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    surfaceTintColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    titlePadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    actionsPadding:
                        const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    actionsAlignment: MainAxisAlignment.center,
                    title: const Text(
                      "Select CP",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(7)),
                                child: const Center(
                                  child: Text(
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
                            ),
                          ),
                        ],
                      ),
                    ],
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState1) {
                        return Container(
                          width: 500,
                          height: 404,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              verticalSpaceTiny,
                              SizedBox(
                                height: 40,
                                child: TextField(
                                  onChanged: (value) {
                                    setState1(() {
                                      searchTextBroker = value;
                                    });
                                  },
                                  style: const TextStyle(fontSize: 13),
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.all(12.0),
                                      labelText: 'Search CP',
                                      hintText: "Search CP  ",
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
                                    itemCount: filteredBrokerProjects()!.length,
                                    itemBuilder: (context, int ind) {
                                      return InkWell(
                                        onTap: () {
                                          setState1(() {
                                            if (selectedBrokerType?.brokerId ==
                                                filteredBrokerProjects()![ind]
                                                    .brokerId) {
                                              // arrayList[index]!.selectedUnitId =
                                              //     "";
                                              // arrayList[index]!
                                              //     .controllerText
                                              //     ?.text = '';
                                              // arrayList[index]!.woUnit = "";
                                              // selectedFinishingType = null;
                                              _broker =
                                                  filteredBrokerProjects()![ind]
                                                          .brokerId ??
                                                      '';
                                              selectedBrokerType = null;
                                              finishingBrokerController.clear();
                                            } else {
                                              // selectedBrokerType =
                                              //     filteredBrokerProjects()![
                                              //         ind];
                                              selectedBrokerType =
                                                  filteredBrokerProjects()![
                                                      ind];
                                              _broker =
                                                  filteredBrokerProjects()![ind]
                                                          .brokerId ??
                                                      '';
                                              finishingBrokerController.text =
                                                  filteredBrokerProjects()![ind]
                                                          .companyName ??
                                                      '';
                                              _broker =
                                                  filteredBrokerProjects()![ind]
                                                          .brokerId ??
                                                      '';
                                              _txtControllerBrokerPercentage
                                                      .text =
                                                  filteredBrokerProjects()![ind]
                                                      .brokeragePercent!;

                                              // arrayList[index]!.selectedUnitId =
                                              //     filteredProjects()![ind]
                                              //         .unitId;
                                              // arrayList[index]!
                                              //     .controllerText
                                              //     ?.text = widget
                                              //         .gradeUnit![ind]
                                              //         .unitName ??
                                              //     '';
                                              // arrayList[index]!.woUnit = widget
                                              //         .gradeUnit![ind]
                                              //         .unitName ??
                                              //     '';
                                            }
                                            // inspect(arrayList[index]);
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0, vertical: 7.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        filteredBrokerProjects()![
                                                                    ind]
                                                                .companyName ??
                                                            '',
                                                        style: normalText,
                                                      ),
                                                    ],
                                                  ),
                                                  selectedBrokerType
                                                              ?.brokerId ==
                                                          filteredBrokerProjects()![
                                                                  ind]
                                                              .brokerId
                                                      ? const Icon(Icons.circle,
                                                          size: 25,
                                                          color: Colors.green)
                                                      : const Icon(
                                                          Icons.circle_outlined,
                                                          size: 25,
                                                          color: Colors.grey)
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
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
            child: Container(
              color: kcTextFieldColor,
              child: TextFormField(
                autofocus: false,
                enabled: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "(CP Cannot Be Empty)";
                  }
                },
                controller: finishingBrokerController,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: InputDecoration(
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down_sharp,
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.all(10),
                  border: InputBorder.none,
                  hintText: 'Select CP',
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF5F5C5C)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: (Colors.red),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: (Color(0xFF5F5C5C)),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Expanded(
        //   child: Container(
        //     height: 65,
        //     decoration: BoxDecoration(
        //         color: kcTextFieldColor,
        //         border: Border.all(
        //           color: Colors.grey,
        //         ),
        //         borderRadius: const BorderRadius.all(Radius.circular(5.0))),
        //     child: SmartSelect<String?>.single(
        //       title: 'Broker',
        //       selectedValue: _broker,
        //       placeholder: 'Select Broker',
        //       onChange: (selected) {
        //         setState(() => _broker = selected.value);
        //         for (var i = 0; i < borkerList!.length; i++) {
        //           if (borkerList![i].brokerId == selected.value) {
        //             setState(() {
        //               _txtControllerBrokerPercentage.text =
        //                   borkerList![i].brokeragePercent!;
        //             });
        //             break;
        //           }
        //         }
        //       },
        //       choiceType: S2ChoiceType.radios,
        //       choiceItems: S2Choice.listFrom<String, Map<String, String>>(
        //         source: broker,
        //         value: (index, item) => item['id'] ?? '',
        //         title: (index, item) => item['name'] ?? '',
        //       ),
        //       modalConfig: const S2ModalConfig(
        //           type: S2ModalType.bottomSheet,
        //           useFilter: true,
        //           confirmMargin: EdgeInsets.symmetric(horizontal: 120)),
        //       modalFilter: true,
        //       modalHeader: true,
        //       modalFooterBuilder: (context, state) {
        //         return GestureDetector(
        //           onTap: () {
        //             Navigator.pop(context);
        //           },
        //           child: Container(
        //             width: double.infinity,
        //             height: 50,
        //             alignment: Alignment.center,
        //             decoration: const BoxDecoration(
        //               color: Colors.black,
        //             ),
        //             child: const Text(
        //               'SUBMIT',
        //               style: TextStyle(
        //                 color: Colors.white,
        //                 fontSize: 16.0,
        //               ),
        //             ),
        //           ),
        //         );
        //       },
        //       tileBuilder: (context, state) {
        //         return S2Tile.fromState(
        //           state,
        //           isTwoLine: true,
        //         );
        //       },
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _BrokerPercentage() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Broker Percentage',
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
                controller: _txtControllerBrokerPercentage,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter broker percentage',
                ),
                onChanged: (String str) {
                  //arrayList[index]['casting_for'] = str;
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _GstPercentage() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('GST Percentage',
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
              color: kcTextFieldColor,
              border: Border.all(
                color: Colors.grey,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(5.0))),
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: TextField(
              controller: _txtControllerGstPercentage,
              style: const TextStyle(color: Colors.black, fontSize: 15.0),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                border: InputBorder.none,
                hintText: 'Enter GST percentage',
              ),
              onChanged: (String str) {
                setState(() {
                  // String value = _txtControllerFlatAgreementValue.text;

                  // var rupee = "\u{20B9}";
                  // value = value.replaceAll(rupee, "");
                  // value = value.replaceAll(',', "");
                  // value = value.replaceAll(' ', "");
                  // print('value');
                  // print(value);
                  gst_value = strTotalValueBottom *
                      (double.parse(_txtControllerGstPercentage.text.trim()) /
                          100);
                });
                // _txtControllerGstPercentage
                // _txtControllerFlatMarketValue.text.trim()
                //arrayList[index]['casting_for'] = str;
              },
            ),
          ),
        ),
        horizontalSpaceSmall,
        Padding(
          padding: EdgeInsets.only(top: 15.0),
          child: Text(
              // gst_value.toStringAsFixed(2),
              // _txtControllerFlatMarketValue.text.trim() != ''
              //     ?
              currencyFormat.format(double.parse(gst_value.toStringAsFixed(2))),
              //     : '0', //'180000',
              style: TextStyle(
                  backgroundColor: Colors.white,
                  fontSize: 15,
                  color: Colors.black)),
        ),
      ],
    );
  }

  Widget _sdvalue() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 230.0,
          // height: 40.0,
          child: Text('Stamp Duty Value (${percentagate?.stampDurty}%)',
              style: const TextStyle(
                  backgroundColor: Colors.white,
                  fontSize: 15,
                  color: Colors.black)),
        ),
        horizontalSpaceSmall,
        InkWell(
            onTap: () {
              if (bookingType == "1" ||
                  _txtControllerLeaseValueMonthly.text != "") {
                setState(() {
                  flagSDValue = !flagSDValue;
                  SDValue = strTotalValueBottom *
                      double.parse('${percentagate!.stampDurty}') /
                      100;
                });
              } else {
                if (_txtControllerFlatAgreementValue.text.isNotEmpty) {
                  if (flagSDValue == false) {
                    if (_txtControllerFlatMarketValue.text.isNotEmpty &&
                        _txtControllerFlatAgreementValue.text.isNotEmpty) {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return StatefulBuilder(
                                builder: (context, setState) {
                              setState(() {
                                flagSDValue = true;
                              });
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // Set radius to zero
                                ),
                                titlePadding:
                                    const EdgeInsets.symmetric(vertical: 0),
                                actionsPadding:
                                    const EdgeInsets.symmetric(horizontal: 0),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                actionsAlignment: MainAxisAlignment.center,
                                title: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "Calculate Stamp Duty On",
                                    // "Stamp Duty Calculation on",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                // title: const Text('Stamp Duty Calculation on'),
                                // actionsAlignment: MainAxisAlignment.center,
                                content: Container(
                                  height: 200,
                                  width: 400,
                                  child: ListView.builder(
                                    itemCount: 2,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                          color: Colors.grey,
                                        ))),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    if (index == 0) {
                                                      //Agreement
                                                      strStampDutyFlag = 0;
                                                    } else {
                                                      //Market
                                                      strStampDutyFlag = 1;
                                                    }
                                                  });
                                                  //updateOtherChargesAmount();
                                                  customChargesCalculation();
                                                },
                                                icon: index == strStampDutyFlag
                                                    ? const Icon(
                                                        Icons
                                                            .check_circle_outline_rounded,
                                                        size: 30,
                                                        color: Colors.green,
                                                      )
                                                    : const Icon(
                                                        Icons.circle_outlined,
                                                        size: 30,
                                                      )),
                                            horizontalSpaceSmall,
                                            index == 0
                                                ? const Text(
                                                    'Flat Agreement Value')
                                                : const Text(
                                                    'Flat Market Value'),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // actions: <Widget>[
                                //   ElevatedButton(
                                //     style: ElevatedButton.styleFrom(
                                //         backgroundColor: Colors.black,
                                //         textStyle:
                                //             const TextStyle(color: Colors.white)),
                                //     child: const Padding(
                                //       padding: EdgeInsets.all(10.0),
                                //       child: Text('CANCEL',
                                //           style: TextStyle(color: Colors.white)),
                                //     ),
                                //     onPressed: () {
                                //       updaterecords();
                                //       //updateOtherChargesAmount();
                                //       customChargesCalculation();
                                //       Navigator.pop(context);
                                //     },
                                //   ),
                                //   horizontalSpaceMedium,
                                //   ElevatedButton(
                                //     style: ElevatedButton.styleFrom(
                                //         backgroundColor: Colors.black,
                                //         textStyle:
                                //             const TextStyle(color: Colors.white)),
                                //     child: const Padding(
                                //       padding: EdgeInsets.all(10.0),
                                //       child: Text('SUBMIT',
                                //           style: TextStyle(color: Colors.white)),
                                //     ),
                                //     onPressed: () {
                                //       updaterecords();
                                //       //updateOtherChargesAmount();
                                //       customChargesCalculation();
                                //       Navigator.pop(context);
                                //     },
                                //   ),
                                // ],
                                actions: <Widget>[
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          updaterecords();
                                          //updateOtherChargesAmount();
                                          customChargesCalculation();
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          width: 225,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
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
                                      const SizedBox(width: 1),
                                      InkWell(
                                        onTap: () {
                                          updaterecords();
                                          //updateOtherChargesAmount();
                                          customChargesCalculation();
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          width: 225,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
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
                              );
                            });
                          });
                    } else {
                      setState(() {
                        flagSDValue = true;
                      });
                      customChargesCalculation();
                    }
                  } else {
                    setState(() {
                      flagSDValue = false;
                    });
                    customChargesCalculation();
                  }
                }
              }
            },
            child: flagSDValue == false
                ? Icon(
                    Icons.check_box_outline_blank,
                    size: 40,
                    color: _txtControllerFlatAgreementValue.text.isNotEmpty
                        ? Colors.black
                        : Colors.grey,
                  )
                : const Icon(
                    Icons.check_box_outlined,
                    size: 40,
                    color: Colors.black,
                  )),
        horizontalSpaceSmall,
        flagSDValue == true
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(currencyFormat.format(SDValue)),
              )
            : const SizedBox(),
        SizedBox(
          width: 230.0,
          // height: 40.0,
          child: Text('TDS Value (${percentagate?.tdsPercentage}%)',
              textAlign: TextAlign.end,
              style: const TextStyle(
                  backgroundColor: Colors.white,
                  fontSize: 15,
                  color: Colors.black)),
        ),
        horizontalSpaceSmall,
        InkWell(
            onTap: () {
              if (bookingType == "1" ||
                  _txtControllerLeaseValueMonthly.text != "") {
                setState(() {
                  flagTDSValue = !flagTDSValue;
                });
                tdsValue = strTotalValueBottom *
                    double.parse(percentagate?.tdsPercentage ?? '0') /
                    100;
              } else {
                var rupee = "\u{20B9}";

                var flatAgreementValue = _txtControllerFlatAgreementValue.text;
                flatAgreementValue = flatAgreementValue.replaceAll(rupee, "");
                flatAgreementValue = flatAgreementValue.replaceAll(",", "");
                setState(() {
                  tdsValue = double.parse(flatAgreementValue) *
                      double.parse(percentagate?.tdsPercentage ?? '0') /
                      100;
                  flagTDSValue = !flagTDSValue;
                });
                // }
                // setState(() {
                //   flagTDSValue = !flagTDSValue;
                // });
                //           tdsValue = double.parse(flatAgreementValue) *
                // double.parse(percentagate?.tdsPercentage ?? '0') /
                // 100;
              }
            },
            child: flagTDSValue == false
                ? Icon(
                    Icons.check_box_outline_blank,
                    size: 40,
                    color: _txtControllerFlatAgreementValue.text.isNotEmpty
                        ? Colors.black
                        : Colors.grey,
                  )
                : const Icon(
                    Icons.check_box_outlined,
                    size: 40,
                    color: Colors.black,
                  )),
        horizontalSpaceSmall,
        flagTDSValue == true
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(currencyFormat.format(tdsValue)),
              )
            : const SizedBox(),
        horizontalSpaceSmall,
      ],
    );
  }

  showClubs(ParkingList details, BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return StatefulBuilder(builder: (context, setState) {
      return Theme(
        data: theme,
        child: ExpansionTile(
          trailing: const SizedBox(),
          key: PageStorageKey<ParkingList?>(details),
          title: InkWell(
            onTap: () {
              if (details.inventryAllocatedId != "0" &&
                  details.inventryAllocatedId !=
                      widget.flatBuyerRequest?.flatIdFk) {
              } else {
                setState(() {
                  print('--------------${details.selected}');
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
                    arrSelectedParkingList!.remove(details);
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
                print('$parking ---- parking');
                updateParkingNo(parking);
                print(arrSelectedParkingList);
              }
            },
            child: Container(
              color: details.inventryAllocatedId != "0" &&
                      details.inventryAllocatedId !=
                          widget.flatBuyerRequest?.flatIdFk
                  ? Colors.black12
                  : Colors.transparent,
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
                              style: const TextStyle(
                                  // backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
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
        ),
      );
    });
  }

  messageAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Set radius to zero
            ),
            titlePadding: const EdgeInsets.symmetric(vertical: 0),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 0),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            actionsAlignment: MainAxisAlignment.center,
            // title: const Text(""),
            title: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: const Text(
                "Parking Allocation should be Equal to Entered Parking Count.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // content: const Text(
            //     "Parking allocation cannot exceed the parking count."),
            actions: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 425,
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
            ],
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

  updateParkingNo(String parkingNo) {
    setState(() {
      strParkingSelectedNo = parkingNo;
    });
  }
}

class CitiesService {
  static List<String> cities = [];

  static List<String> getSuggestions(String query) {
    List<String> matches = <String>[];
    matches.addAll(cities);

    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }
}
