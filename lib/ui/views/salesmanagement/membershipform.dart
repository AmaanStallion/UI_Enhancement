import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_awesome_select/flutter_awesome_select.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/flat_status.dart' as saleflatstatus;
import 'package:stallion/models/get_broker_details.dart' as salebuyer;
import 'package:stallion/ui/views/salesmanagement/setpaymenttermsview.dart';
// import 'package:stallion/models/get_broker_details.dart' as salebuyer;
import 'package:stallion/ui/widgets/app_text.dart';
import '../../../models/get_flat_list_by_project.dart';
import '../../../models/message_success.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import 'buyerdetailsview.dart';

class MembershipFormView extends StatefulWidget {
  MembershipFormView({
    Key? key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.flatBuyerRequest,
    this.flagRedirect, //Inventory  InventoryNew
    this.buyerName = '',
    this.emailId = '',
    this.mobileNumber = '',
    this.flatNoIds,
    this.totalflatAreaCount = "",
    this.isFlatListFromReserve,
    this.strBuyerID = "",
    this.memberShipform = "0",
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? flagRedirect;
  final String? totalflatAreaCount;
  final String? strBuyerID;
  final String? memberShipform;
  List<String?>? flatNoIds;
  FlatList? isFlatListFromReserve;

  String buyerName;
  String emailId;
  String mobileNumber;
  final salebuyer.FlatBuyerRequest? flatBuyerRequest;

  @override
  State<MembershipFormView> createState() => _MembershipFormViewState();
}

class _MembershipFormViewState extends State<MembershipFormView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  TextEditingController flatNoController = TextEditingController();

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
  String? _finishingType = '0';

  bool flagParking = false;
  bool flagcalled = false;
  String? buyerType = "Gold";
  String? fundingType = "Self Funding";
  String? strParkingSelectedNo = "";

  var gstValue = 0.0;
  var SDValue = 0.0;
  bool flagSDValue = false;

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
  final TextEditingController _txtControllerFlatAgreementValue =
      TextEditingController();
  final TextEditingController _txtControllerRemark = TextEditingController();
  final TextEditingController _txtControllerSpouseName =
      TextEditingController();
  final TextEditingController _txtControllerChild1Name =
      TextEditingController();
  final TextEditingController _txtControllerChild2Name =
      TextEditingController();
  final TextEditingController _txtControllerResidentialAddress =
      TextEditingController();
  final TextEditingController _txtControllerCorrespondenceAddress =
      TextEditingController();
  final TextEditingController _txtControllerExpectedWeddingYear =
      TextEditingController();
  final TextEditingController _txtControllerMembershipPeriod =
      TextEditingController();
  final TextEditingController _txtControllerAadharNo = TextEditingController();

  TextEditingController txtMemberDOBControler = TextEditingController();
  TextEditingController txtChild1DOB = TextEditingController();
  TextEditingController txtChild2DOB = TextEditingController();
  TextEditingController txtSpouseDOB = TextEditingController();
  TextEditingController txtAniversaryDOB = TextEditingController();

  DateTime? _selectedMemberDOB;
  DateTime? _selectedSpouseDOB;
  DateTime? _selectedChild1DOB;
  DateTime? _selectedChild2DOB;
  DateTime? _selectedAnniversaryDOB;

  List<TextEditingController>? txtOtherChargesAmount = [];
  List<TextEditingController>? txtOtherChargesOneTimeAmount = [];

  String? strSlabID = '';
  String? strSdValue = '0';
  String? strParkingTypeSelected = "";
  String? strJSONCharges = "";
  int strStampDutyFlag = 0;
  String strSalesLeadId = "";
  String strFinishingTypeSelected = '';
  String strOtherChargesSelected = '';
  String strBuyerID = '';
  double selectedTotalOtherCharges = 0.0;
  double strTotalValueBottom = 0.0;
  double totalCustomChargesGST = 0.0;
  double totalflatarea = 0.0;
  String searchFlatNumberText = '';

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

  @override
  void initState() {
    super.initState();
    _focusRatePerSqFt = FocusNode();
    _focusAgreementValue = FocusNode();
    _txtControllerRemark.text = "";
    strBuyerID = widget.strBuyerID!;
    fetchDefaultSalesMgtDropdown();

    /*_focusRatePerSqFt.addListener(() {
      if (_focusRatePerSqFt.hasFocus == false) {
        setState(() {
          customChargesCalculation();
        });
      }
    });*/

    /*_focusAgreementValue.addListener(() {
      if (_focusAgreementValue.hasFocus == false) {
        setState(() {
          customChargesCalculation();
        });
      }
    });*/

    if (widget.flagRedirect! == 'Reserve' ||
        widget.flagRedirect! == 'Inventory') {
      if (widget.flatBuyerRequest!.flagInvestor! == '0') {
        buyerType = 'Gold';
      } else {
        buyerType = 'Silver';
      }

      if (widget.flatBuyerRequest!.flatBookingRemark!.isNotEmpty) {
        _txtControllerRemark.text = widget.flatBuyerRequest!.flatBookingRemark!;
      }

      if (widget.flatBuyerRequest!.flatBuyerName!.isNotEmpty) {
        _txtControllerBuyerName.text = widget.flatBuyerRequest!.flatBuyerName!;
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

      print(widget.flatBuyerRequest!.finshingType!);
      if (widget.flatBuyerRequest!.finshingType == "1") {
        setState(() {
          strFinishingTypeSelected = "Raw";
          _finishingType = widget.flatBuyerRequest!.finshingType!;
        });
      } else {
        setState(() {
          strFinishingTypeSelected = "Finished";
          _finishingType = widget.flatBuyerRequest!.finshingType! == "0"
              ? "2"
              : widget.flatBuyerRequest!.finshingType!;
        });
      }

      var rupee = "\u{20B9}";
      var strRate = widget.flatBuyerRequest!.flatRateCal!;
      strRate = strRate.replaceAll(rupee, "");
      strRate = strRate.replaceAll(',', "");
      strRate = strRate.replaceAll(' ', "");

      var strFlatValue = widget.flatBuyerRequest!.flatValue;
      strFlatValue = strFlatValue?.replaceAll(rupee, "");
      strFlatValue = strFlatValue?.replaceAll(',', "");
      strFlatValue = strFlatValue?.replaceAll(' ', "");

      _txtControllerFlatAgreementValue.text =
          currencyFormat.format(double.parse(strFlatValue!));

      strParkingTypeSelected = "";

      arrSelectedParkingList = [];
      strParkingSelectedNo = '';

      gstValue = widget.flatBuyerRequest!.flatGstValue!.isNotEmpty
          ? double.parse(widget.flatBuyerRequest!.flatGstValue!)
          : 0.0;

      if (widget.flatBuyerRequest!.aadharNo != '') {
        _txtControllerAadharNo.text = widget.flatBuyerRequest!.aadharNo!;
      }

      if (widget.flatBuyerRequest!.flatTotalWithoutGst! != '0') {
        strTotalValueBottom =
            double.parse(widget.flatBuyerRequest!.flatTotalWithoutGst!);
      }
      if (widget.flatBuyerRequest!.memberDetails!.isNotEmpty) {
        if (widget.flatBuyerRequest!.memberDetails![0].memberDob != '') {
          txtMemberDOBControler.text =
              widget.flatBuyerRequest!.memberDetails![0].memberDob!;
        }
      }

      if (widget.flatBuyerRequest!.memberDetails!.isNotEmpty) {
        if (widget.flatBuyerRequest!.memberDetails![0].spouseName != '') {
          _txtControllerSpouseName.text =
              widget.flatBuyerRequest!.memberDetails![0].spouseName!;
        }
      }

      if (widget.flatBuyerRequest!.memberDetails!.isNotEmpty) {
        if (widget.flatBuyerRequest!.memberDetails![0].spouseDob != '') {
          txtSpouseDOB.text =
              widget.flatBuyerRequest!.memberDetails![0].spouseDob!;
        }
      }

      if (widget.flatBuyerRequest!.memberDetails!.isNotEmpty) {
        if (widget.flatBuyerRequest!.memberDetails![0].childName1 != '') {
          _txtControllerChild1Name.text =
              widget.flatBuyerRequest!.memberDetails![0].childName1!;
        }
      }

      if (widget.flatBuyerRequest!.memberDetails!.isNotEmpty) {
        if (widget.flatBuyerRequest!.memberDetails![0].childName2 != '') {
          _txtControllerChild2Name.text =
              widget.flatBuyerRequest!.memberDetails![0].childName2!;
        }
      }

      if (widget.flatBuyerRequest!.memberDetails!.isNotEmpty) {
        if (widget.flatBuyerRequest!.memberDetails![0].child1Dob != '') {
          txtChild1DOB.text =
              widget.flatBuyerRequest!.memberDetails![0].child1Dob!;
        }
      }

      if (widget.flatBuyerRequest!.memberDetails!.isNotEmpty) {
        if (widget.flatBuyerRequest!.memberDetails![0].child2Dob != '') {
          txtChild2DOB.text =
              widget.flatBuyerRequest!.memberDetails![0].child2Dob!;
        }
      }

      if (widget.flatBuyerRequest!.memberDetails!.isNotEmpty) {
        if (widget.flatBuyerRequest!.memberDetails![0].weddingAniversary !=
            '') {
          txtAniversaryDOB.text =
              widget.flatBuyerRequest!.memberDetails![0].weddingAniversary!;
        }
      }

      if (widget.flatBuyerRequest!.memberDetails!.isNotEmpty) {
        if (widget.flatBuyerRequest!.memberDetails![0].residentialAddress !=
            '') {
          _txtControllerResidentialAddress.text =
              widget.flatBuyerRequest!.memberDetails![0].residentialAddress!;
        }
      }

      if (widget.flatBuyerRequest!.memberDetails!.isNotEmpty) {
        if (widget.flatBuyerRequest!.memberDetails![0].correspndenceAddress !=
            '') {
          _txtControllerCorrespondenceAddress.text =
              widget.flatBuyerRequest!.memberDetails![0].correspndenceAddress!;
        }
      }

      if (widget.flatBuyerRequest!.memberDetails!.isNotEmpty) {
        if (widget.flatBuyerRequest!.memberDetails![0].exprectedWeddingYear !=
            '') {
          _txtControllerExpectedWeddingYear.text =
              widget.flatBuyerRequest!.memberDetails![0].exprectedWeddingYear!;
        }

        if (widget.flatBuyerRequest!.memberDetails![0].memberShipPeriod != '') {
          _txtControllerMembershipPeriod.text =
              widget.flatBuyerRequest!.memberDetails![0].memberShipPeriod!;
        }
      }

      setState(() {});
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
  }

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
      "buyer_id": widget.flagRedirect == 'Reserve'
          ? widget.flatBuyerRequest!.flatBuyerId!
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
        finishingBookList = dataModel.response?.finishingBookList;
        podiumList = dataModel.response?.podiumList;
        flatList = dataModel.response?.flatList;
        customCharges = dataModel.response?.customCharges;
        borkerList = dataModel.response?.borkerList;
        percentagate = dataModel.response?.percentagate;
        totalPark = 0;
        if (widget.flatNoIds != null) {
          for (var k = 0; k < widget.flatNoIds!.length; k++) {
            for (var i = 0; i < flatList!.length; i++) {
              if (widget.flatNoIds?[k] == flatList?[i].flatId) {
                flatList?[i].isSelected = true;
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

        if (flatList!.isNotEmpty) {
          for (var i = 0; i < flatList!.length; i++) {
            flats.add(
              {
                'id': '${flatList?[i].flatId!}',
                'name': '${flatList?[i].flatName!}'
              },
            );
          }
        }

        if (finishingBookList!.isNotEmpty) {
          for (var i = 0; i < finishingBookList!.length; i++) {
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
            widget.flagRedirect == 'Inventory') {
          _flatNo = [];
          List<FlatList>? flatListSelected =
              widget.flatBuyerRequest?.selectedFlat;
          for (int i = 0; i < flatListSelected!.length; i++) {
            if (i == 0) {
              _flatNo.add(flatListSelected[i].flatId!);
            } else {
              _flatNo.add(flatListSelected[i].flatId!);
            }
          }
        }

        //customChargesCalculation();

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

  Future<ResponseMessageSuccess?> webServiceForReserveBooking() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    var rupee = "\u{20B9}";

    var flatAgreementValue = _txtControllerFlatAgreementValue.text;
    flatAgreementValue = flatAgreementValue.replaceAll(rupee, "");
    flatAgreementValue = flatAgreementValue.replaceAll(",", "");

    List<FlatList> flatListSelected = [];
    for (int j = 0; j < _flatNo.length; j++) {
      for (int k = 0; k < flatList!.length; k++) {
        if (_flatNo[j] == flatList![k].flatId!) {
          flatListSelected.add(flatList![k]);
          break;
        }
      }
    }

    var flaginvestor = "0";
    if (buyerType == "Gold") {
      flaginvestor = "0";
    } else {
      flaginvestor = "1";
    }

    var funding = "0";
    if (fundingType == "Self Funding") {
      funding = "0";
    } else {
      funding = "1";
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "buyer_name": _txtControllerBuyerName.text,
      "flat_area": "1",
      "rate_put": "1",
      "flat_value": flatAgreementValue,
      "flat_market_value": "",
      "brokerage_value": "0",
      "sd_value": "0",
      "gst_value": '$gstValue',
      "total_value": flatAgreementValue,
      "finshing_type": '1',
      "payment_term_type": "0",
      "payment_term_json": "",
      "buyer_email": _txtControllerEmailAddress.text,
      "buyer_number": _txtControllerMobileNumber.text,
      "podium_id": "",
      "no_of_park": "",
      "flatList": jsonEncode(flatListSelected),
      "flat_booking_status": "3",
      "customer_charges": "",
      "flag_investor": flaginvestor,
      "aadhar_no": _txtControllerAadharNo.text,
      "pan_no": "",
      "flat_buyer_id": widget.flagRedirect == 'Reserve'
          ? widget.flatBuyerRequest!.flatBuyerId!
          : '',
      "parkinglist": "",
      "broker_id": "",
      "broker_percentage": "",
      "flag_stump_cal": "",
      "lead_id": "",
      "flat_remark": _txtControllerRemark.text,
      "flat_funding_type": "",
      "member_dob": txtMemberDOBControler.text,
      "spouse_name": _txtControllerSpouseName.text,
      "spouse_dob": txtSpouseDOB.text,
      "child_name_1": _txtControllerChild1Name.text,
      "child_1_dob": txtChild1DOB.text,
      "child_name_2": _txtControllerChild2Name.text,
      "child_2_dob": txtChild2DOB.text,
      "wedding_aniversary": txtAniversaryDOB.text,
      "residential_address": _txtControllerResidentialAddress.text,
      "correspndence_address": _txtControllerCorrespondenceAddress.text,
      "exprected_wedding_year": _txtControllerExpectedWeddingYear.text,
      "member_ship_period": _txtControllerMembershipPeriod.text,
      "member_aadhar_no": _txtControllerAadharNo.text,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.wssetflatMemberBook, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = messageSuccessFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
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
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      useDefaultLoading: false,
      overlayWidgetBuilder: (_) => const Center(
        child: SpinKitRing(
          lineWidth: 5.0,
          color: Colors.black,
          size: 50.0,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
              widget.flagRedirect == 'Inventory'
                  ? widget.projectName!.toUpperCase()
                  : '${widget.projectName!.toUpperCase()} BOOK A SALE',
              style:
                  const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
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
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 80.0, right: 80.0),
                        child: Container(
                            color: Colors.white,
                            child: SafeArea(
                                child: Column(
                              children: [
                                _memberType(),
                                verticalSpaceSmall15,
                                _memberName(),
                                verticalSpaceSmall15,
                                _memberDOB(),
                                verticalSpaceSmall15,
                                _memberSpouseName(),
                                verticalSpaceSmall15,
                                _memberSpouseDOB(),
                                verticalSpaceSmall15,
                                _memberChild1Name(),
                                verticalSpaceSmall15,
                                _memberChild1DOB(),
                                verticalSpaceSmall15,
                                _memberChild2Name(),
                                verticalSpaceSmall15,
                                _memberChild2DOB(),
                                verticalSpaceSmall15,
                                _flatNumber(),
                                verticalSpaceSmall15,
                                _mobilenumber(),
                                verticalSpaceSmall15,
                                _buyeremail(),
                                verticalSpaceSmall15,
                                _memberAnniversaryDOB(),
                                verticalSpaceSmall15,
                                _memberResidentialAdd(),
                                verticalSpaceSmall15,
                                _memberCorrespondenceAdd(),
                                verticalSpaceSmall15,
                                _expectedWeddingYear(),
                                verticalSpaceSmall15,
                                _membershipPeriod(),
                                verticalSpaceSmall15,
                                _flatAgreementValue(),
                                verticalSpaceSmall15,
                                _aadharNo(),
                                verticalSpaceSmall15,
                                _Remark(),
                                verticalSpaceSmall15,
                                _gstvalue(),
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
                                  var flag = true;
                                  String msg = "";
                                  if (_txtControllerBuyerName.text.isEmpty) {
                                    msg = 'Please enter member name';
                                    flag = false;
                                  } else if (txtMemberDOBControler
                                      .text.isEmpty) {
                                    msg = 'Please enter member date of birth';
                                    flag = false;
                                  } else if (_flatNo.isEmpty) {
                                    msg =
                                        'Please select flat no from a flat list.';
                                    flag = false;
                                  } else if (_txtControllerMobileNumber.text ==
                                      "") {
                                    msg = 'Please enter mobile number.';
                                    flag = false;
                                  } else if (_txtControllerMobileNumber
                                          .text.length <
                                      10) {
                                    msg = 'Mobile number should be 10 digit.';
                                    flag = false;
                                  } else if (_txtControllerEmailAddress.text ==
                                      "") {
                                    msg = 'Please enter email address.';
                                    flag = false;
                                  } else if (!isValidEmail(
                                      _txtControllerEmailAddress.text!)) {
                                    msg =
                                        'Please enter valid email address format.';
                                    flag = false;
                                  } else if (_txtControllerResidentialAddress
                                          .text ==
                                      "") {
                                    msg = 'Please enter Residential Address.';
                                    flag = false;
                                  } else if (_txtControllerCorrespondenceAddress
                                          .text ==
                                      "") {
                                    msg =
                                        'Please enter Correspondence Address.';
                                    flag = false;
                                  } else if (_txtControllerMembershipPeriod
                                          .text ==
                                      "") {
                                    msg = 'Please enter membership period.';
                                    flag = false;
                                  } else if (_txtControllerFlatAgreementValue
                                          .text ==
                                      "") {
                                    msg = 'Please enter membership amount.';
                                    flag = false;
                                  } else if (_txtControllerAadharNo.text ==
                                      "") {
                                    msg = 'Please enter Aadhar No.';
                                    flag = false;
                                  } else if (_txtControllerAadharNo
                                          .text.length <
                                      12) {
                                    msg = 'Please enter valid Aadhar No.';
                                    flag = false;
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
                                  } else {
                                    //if (buyerType == "End Buyer") {
                                    //End buyer
                                    //} else {
                                    //Reserve
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

                                    // 'Are you sure, you want to reserve a flat?.',
                                    //
                                    //}
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
                                    'RESERVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  var flag = true;
                                  String msg = "";
                                  if (_txtControllerBuyerName.text.isEmpty) {
                                    msg = 'Please enter member name';
                                    flag = false;
                                  } else if (txtMemberDOBControler
                                      .text.isEmpty) {
                                    msg = 'Please enter member date of birth';
                                    flag = false;
                                  } else if (_flatNo.isEmpty) {
                                    msg =
                                        'Please select flat no from a flat list.';
                                    flag = false;
                                  } else if (_txtControllerMobileNumber.text ==
                                      "") {
                                    msg = 'Please enter mobile number.';
                                    flag = false;
                                  } else if (_txtControllerMobileNumber
                                          .text.length <
                                      10) {
                                    msg = 'Mobile number should be 10 digit.';
                                    flag = false;
                                  } else if (_txtControllerEmailAddress.text ==
                                      "") {
                                    msg = 'Please enter email address.';
                                    flag = false;
                                  } else if (!isValidEmail(
                                      _txtControllerEmailAddress.text!)) {
                                    msg =
                                        'Please enter valid email address format.';
                                    flag = false;
                                  } else if (_txtControllerResidentialAddress
                                          .text ==
                                      "") {
                                    msg = 'Please enter Residential Address.';
                                    flag = false;
                                  } else if (_txtControllerCorrespondenceAddress
                                          .text ==
                                      "") {
                                    msg =
                                        'Please enter Correspondence Address.';
                                    flag = false;
                                  } else if (_txtControllerMembershipPeriod
                                          .text ==
                                      "") {
                                    msg = 'Please enter membership period.';
                                    flag = false;
                                  } else if (_txtControllerFlatAgreementValue
                                          .text ==
                                      "") {
                                    msg = 'Please enter membership amount.';
                                    flag = false;
                                  } else if (_txtControllerAadharNo.text ==
                                      "") {
                                    msg = 'Please enter Aadhar No.';
                                    flag = false;
                                  } else if (_txtControllerAadharNo
                                          .text.length <
                                      12) {
                                    msg = 'Please enter valid Aadhar No.';
                                    flag = false;
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
                                  } else {
                                    List<FlatList>? arrSelectedFlatForSaleList =
                                        [];
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
                                    //             '$flatsSelected, ${flatList![j].inventryFlatName!}';
                                    //       }
                                    //       break;
                                    //     }
                                    //   }
                                    // }

                                    // List<FlatList> flatListSelected = [];
                                    for (int j = 0; j < flatList!.length; j++) {
                                      if (flatList![j].isSelected == true) {
                                        arrSelectedFlatForSaleList
                                            .add(flatList![j]);
                                      }
                                    }

                                    // if (widget.flagRedirect == 'Inventory' &&
                                    //     widget.isFlatListFromReserve != null) {
                                    //   arrSelectedFlatForSaleList
                                    //       .add(widget.isFlatListFromReserve!);
                                    // }

                                    var rupee = "\u{20B9}";

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

                                    List<CustomCharge> arrCharges = [];
                                    for (int i = 0;
                                        i < otherCharges.length;
                                        i++) {
                                      if (otherCharges[i].selected == 'true') {
                                        arrCharges.add(otherCharges[i]);
                                      }
                                    }

                                    for (int i = 0;
                                        i < otherChargesOneTime.length;
                                        i++) {
                                      if (otherChargesOneTime[i].selected ==
                                          'true') {
                                        arrCharges.add(otherChargesOneTime[i]);
                                      }
                                    }

                                    var flaginvestor = "0";
                                    if (buyerType == "End Buyer") {
                                      //End buyer
                                      flaginvestor = "0";

                                      var projectId = widget.projectId!;
                                      var projectName = widget.projectName!;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) {
                                            return BuyerDetailsView(
                                              projectId: projectId,

                                              towarId: widget.towarId!,
                                              projectName: projectName,
                                              flatNumber: flatsSelected,
                                              buyerName:
                                                  _txtControllerBuyerName.text,
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
                                              strNoOfParking: "",
                                              strSalesLeadId: strSalesLeadId,
                                              arrSelectedParkingList:
                                                  arrSelectedParkingList,
                                              strPanCardNo: "",
                                              strAadharCardNo: "",
                                              RatePerSqFt: 1,
                                              strFlatValue: strFlatValue,
                                              strFlatArea: "1",
                                              strRateSqFt: "1",
                                              strGSTValue: '$gstValue',
                                              strSDValue: strSdValue,
                                              TotalValue:
                                                  '$strTotalValueBottom',
                                              strMarketValue: "",
                                              strStampDutyFlag:
                                                  '$strStampDutyFlag',
                                              arrCharges: arrCharges,
                                              strBuyerID: strBuyerID,
                                              strBrokerIDSelected: _broker!,
                                              strBrokerPercentage: "",
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
                                      // flaginvestor = "1";
                                      var flaginvestor = "0";
                                      if (buyerType == "Gold") {
                                        flaginvestor = "0";
                                      } else {
                                        flaginvestor = "1";
                                      }
                                      var projectId = widget.projectId!;
                                      var projectName = widget.projectName!;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) {
                                            // return BuyerDetailsView(
                                            //   projectId: projectId,

                                            //   towarId: widget.towarId!,
                                            //   projectName: projectName,
                                            //   flatNumber: flatsSelected,
                                            //   buyerName:
                                            //   _txtControllerBuyerName.text,
                                            //   buyerEmail:
                                            // _txtControllerEmailAddress
                                            //     .text,
                                            //   flatArea: totalflatarea,
                                            //   arrSelectedFlatForSaleList:
                                            //   arrSelectedFlatForSaleList,
                                            //   buyerMobileNumber:
                                            // _txtControllerMobileNumber
                                            //     .text,
                                            //   strFinishingTypeSelected:
                                            //   strFinishingTypeSelected,
                                            //   strNoOfParking:"",
                                            //   strSalesLeadId: strSalesLeadId,
                                            //   arrSelectedParkingList:
                                            //   arrSelectedParkingList,
                                            //   strPanCardNo: "",
                                            //   strAadharCardNo: "",
                                            //   RatePerSqFt: 1,
                                            //   strFlatValue: strFlatValue,
                                            //   strFlatArea: "1",
                                            //   strRateSqFt: "1",
                                            //   strGSTValue: '$gstValue',
                                            //   strSDValue: strSdValue,
                                            //   TotalValue:
                                            //   '$strTotalValueBottom',
                                            //   strMarketValue: "",
                                            //   strStampDutyFlag:
                                            //   '$strStampDutyFlag',
                                            //   arrCharges: arrCharges,
                                            //   strBuyerID: strBuyerID,
                                            //   strBrokerIDSelected: _broker!,
                                            //   strBrokerPercentage:"",
                                            //   strParkingID:
                                            //   strParkingTypeSelected,
                                            //   //from Reserve
                                            //   flaginvestor: flaginvestor,
                                            //   strRemark:
                                            //   _txtControllerRemark.text,
                                            //   fundingType: fundingType,
                                            // );
                                            return PaymentTermsView(
                                              gst_percentage: '0',
                                              gst_value: '0',
                                              tdsPercentage: '',
                                              tdsValue: '',
                                              member_dob:
                                                  txtMemberDOBControler.text,
                                              spouse_name:
                                                  _txtControllerSpouseName.text,
                                              spouse_dob: txtSpouseDOB.text,
                                              child_name_1:
                                                  _txtControllerChild1Name.text,
                                              child_1_dob: txtChild1DOB.text,
                                              child_name_2:
                                                  _txtControllerChild2Name.text,
                                              child_2_dob: txtChild2DOB.text,
                                              wedding_aniversary:
                                                  txtAniversaryDOB.text,
                                              residential_address:
                                                  _txtControllerResidentialAddress
                                                      .text,
                                              correspndence_address:
                                                  _txtControllerCorrespondenceAddress
                                                      .text,
                                              exprected_wedding_year:
                                                  _txtControllerExpectedWeddingYear
                                                      .text,
                                              member_ship_period:
                                                  _txtControllerMembershipPeriod
                                                      .text,
                                              member_aadhar_no:
                                                  _txtControllerAadharNo.text,
                                              memberShipform:
                                                  widget.memberShipform,
                                              projectId: projectId,
                                              towarId: widget.towarId!,
                                              // arrAadharFilesUpload: arrAadharFilesUpload,
                                              // arrPanFilesUpload: arrPanFilesUpload,
                                              projectName: projectName,
                                              flatNumber: flatsSelected,
                                              buyerName:
                                                  _txtControllerBuyerName.text,
                                              buyerEmail:
                                                  _txtControllerEmailAddress
                                                      .text,
                                              flatArea: totalflatarea,
                                              // arrBuyerDetails: arrBuyerDetails,
                                              arrSelectedFlatForSaleList:
                                                  arrSelectedFlatForSaleList,
                                              buyerMobileNumber:
                                                  _txtControllerMobileNumber
                                                      .text,
                                              strFinishingTypeSelected:
                                                  strFinishingTypeSelected,
                                              strNoOfParking: '',
                                              strSalesLeadId: strSalesLeadId,
                                              arrSelectedParkingList:
                                                  arrSelectedParkingList,
                                              strPanCardNo: '',
                                              strAadharCardNo: '',
                                              RatePerSqFt: 1,
                                              strFlatValue: strFlatValue,
                                              strFlatArea: '1',
                                              strRateSqFt: '1',
                                              strGSTValue: '$gstValue',
                                              strSDValue: strSdValue,
                                              TotalValue:
                                                  _txtControllerFlatAgreementValue
                                                      .text,
                                              strMarketValue: '',
                                              strStampDutyFlag:
                                                  '$strStampDutyFlag',
                                              arrCharges: arrCharges,
                                              strBuyerID: widget.strBuyerID,
                                              strBrokerIDSelected: _broker,
                                              strBrokerPercentage: '',
                                              strParkingID:
                                                  strParkingTypeSelected,
                                              // arrayAadharFilesBytes: arrayAadharFiles,
                                              // arrayPanCardFilesBytes: arrayPanCardFiles,
                                              // strAddress: arrBuyerDetails![0].address!,
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
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  bool isValidEmail(String val) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(val);
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

  Widget _memberType() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Membership Type',
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
                "Gold",
                style: normalText,
              ),
              value: "Gold",
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
                "Silver",
                style: normalText,
              ),
              value: "Silver",
              groupValue: buyerType,
              onChanged: (value) {
                if (kDebugMode) {
                  print(value);
                }
                setState(() {
                  buyerType = value.toString();
                });
              }),
        )
      ],
    );
  }

  Widget _memberName() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Member Name *',
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
                controller: _txtControllerBuyerName,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter Member Name',
                ),
                onChanged: (String str) {},
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _memberDOB() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Member D.O.B *',
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
            child: InkWell(
              onTap: () {
                _selectMemberDOBDate(context);
              },
              child: TextFormField(
                enabled: false,
                readOnly: true,
                controller: txtMemberDOBControler,
                style: const TextStyle(color: Colors.black, fontSize: 13.0),
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    hintText: 'Select Member Date of Birth',
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 116, 116, 116),
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'HelveticaNeue',
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_month_outlined,
                    )),
              ),
            ),
          ),
        )
      ],
    );
  }

  Future<void> _selectMemberDOBDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMemberDOB ?? DateTime.now(),
      firstDate: DateTime(1800),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedMemberDOB) {
      setState(() {
        _selectedMemberDOB = picked;
        txtMemberDOBControler.text =
            DateFormat('dd-MM-yyyy').format(_selectedMemberDOB!);
      });
    }
  }

  Widget _memberSpouseName() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Spouse Name',
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
                controller: _txtControllerSpouseName,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter Spouse Name',
                ),
                onChanged: (String str) {},
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _memberSpouseDOB() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Spouse D.O.B',
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
            child: InkWell(
              onTap: () {
                _selectMemberSpouseDOBDate(context);
              },
              child: TextFormField(
                enabled: false,
                readOnly: true,
                controller: txtSpouseDOB,
                style: const TextStyle(color: Colors.black, fontSize: 13.0),
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    hintText: 'Select Spouse Date of Birth',
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 116, 116, 116),
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'HelveticaNeue',
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_month_outlined,
                    )),
              ),
            ),
          ),
        )
      ],
    );
  }

  Future<void> _selectMemberSpouseDOBDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedSpouseDOB ?? DateTime.now(),
      firstDate: DateTime(1800),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedSpouseDOB) {
      setState(() {
        _selectedSpouseDOB = picked;
        txtSpouseDOB.text =
            DateFormat('dd-MM-yyyy').format(_selectedSpouseDOB!);
      });
    }
  }

  Widget _memberChild1Name() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Child1',
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
                controller: _txtControllerChild1Name,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter Child1 Name',
                ),
                onChanged: (String str) {},
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _memberChild1DOB() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Child1 D.O.B',
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
            child: InkWell(
              onTap: () {
                _selectMemberChild1DOBDate(context);
              },
              child: TextFormField(
                enabled: false,
                readOnly: true,
                controller: txtChild1DOB,
                style: const TextStyle(color: Colors.black, fontSize: 13.0),
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    hintText: 'Select Child1 Date of Birth',
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 116, 116, 116),
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'HelveticaNeue',
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_month_outlined,
                    )),
              ),
            ),
          ),
        )
      ],
    );
  }

  Future<void> _selectMemberChild1DOBDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedChild1DOB ?? DateTime.now(),
      firstDate: DateTime(1800),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedChild1DOB) {
      setState(() {
        _selectedChild1DOB = picked;
        txtChild1DOB.text =
            DateFormat('dd-MM-yyyy').format(_selectedChild1DOB!);
      });
    }
  }

  Widget _memberChild2Name() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Child2',
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
                controller: _txtControllerChild2Name,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter Child2 Name',
                ),
                onChanged: (String str) {},
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _memberChild2DOB() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Child2 D.O.B',
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
            child: InkWell(
              onTap: () {
                _selectMemberChild2DOBDate(context);
              },
              child: TextFormField(
                enabled: false,
                readOnly: true,
                controller: txtChild2DOB,
                style: const TextStyle(color: Colors.black, fontSize: 13.0),
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    hintText: 'Select Child2 Date of Birth',
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 116, 116, 116),
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'HelveticaNeue',
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_month_outlined,
                    )),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _memberAnniversaryDOB() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Anniversary Date',
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
            child: InkWell(
              onTap: () {
                _selectAnniversaryDOBDate(context);
              },
              child: TextFormField(
                enabled: false,
                readOnly: true,
                controller: txtAniversaryDOB,
                style: const TextStyle(color: Colors.black, fontSize: 13.0),
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    hintText: 'Select Anniversary Date',
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 116, 116, 116),
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'HelveticaNeue',
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_month_outlined,
                    )),
              ),
            ),
          ),
        )
      ],
    );
  }

  Future<void> _selectAnniversaryDOBDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedAnniversaryDOB ?? DateTime.now(),
      firstDate: DateTime(1800),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedAnniversaryDOB) {
      setState(() {
        _selectedAnniversaryDOB = picked;
        txtAniversaryDOB.text =
            DateFormat('dd-MM-yyyy').format(_selectedAnniversaryDOB!);
      });
    }
  }

  Future<void> _selectMemberChild2DOBDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedChild2DOB ?? DateTime.now(),
      firstDate: DateTime(1800),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedChild2DOB) {
      setState(() {
        _selectedChild2DOB = picked;
        txtChild2DOB.text =
            DateFormat('dd-MM-yyyy').format(_selectedChild2DOB!);
      });
    }
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
            child: Text('Email *',
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
                  hintText: 'Enter email address',
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

  Widget _mobilenumber() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Mobile Number *',
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

  Widget _flatNumber() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Flat Number',
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

                                    _flatNo.add(flatList?[i].flatName);
                                  }
                                }
                                // setState(() {
                                //   _txtControllerArea.text =
                                //       "$totalflatarea SqFt";
                                // });
                                //             _flatNo = selected.value;
                                //             print('PRINT ONCHANGE');
                                //             print(selected.value);
                                //             totalflatarea = 0.0;
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
                                            if (filteredFlatNumberProjects()![
                                                        ind]
                                                    .isSelected ==
                                                true) {
                                              filteredFlatNumberProjects()![ind]
                                                  .isSelected = false;
                                            } else {
                                              filteredFlatNumberProjects()![ind]
                                                  .isSelected = true;
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
      ],
    );
    //  Row(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     const SizedBox(
    //       width: 230.0,
    //       height: 40.0,
    //       child: Padding(
    //         padding: EdgeInsets.only(top: 15.0),
    //         child: Text('Flat Number *',
    //             style: TextStyle(
    //                 backgroundColor: Colors.white,
    //                 fontSize: 15,
    //                 color: Colors.black)),
    //       ),
    //     ),
    //     horizontalSpaceSmall,
    //     /*Expanded(
    //       child: Container(
    //         height: 65,
    //         decoration: BoxDecoration(
    //             color: kcTextFieldColor,
    //             border: Border.all(
    //               color: Colors.grey,
    //             ),
    //             borderRadius: const BorderRadius.all(Radius.circular(5.0))),
    //         child: SmartSelect<String?>.multiple(
    //           title: 'Flat No.',
    //           selectedValue: _flatNo,
    //           modalConfig: const S2ModalConfig(
    //               type: S2ModalType.bottomSheet,
    //               useFilter: true,
    //               confirmMargin: EdgeInsets.symmetric(horizontal: 120)),
    //           placeholder: 'Select one or multiple flats.',
    //           onChange: (selected) => setState(() {
    //             _flatNo = selected.value;
    //             print('PRINT ONCHANGE');
    //             print(selected.value);
    //             totalflatarea = 0.0;
    //           }),
    //           choiceType: S2ChoiceType.checkboxes,
    //           choiceItems: S2Choice.listFrom<String, Map<String, String>>(
    //             source: flats,
    //             value: (index, item) => item['id'] ?? '',
    //             title: (index, item) => item['name'] ?? '',
    //           ),
    //           //modalType: S2ModalType.popupDialog,
    //           modalFilter: true,
    //           modalHeader: true,
    //           modalFilterAuto: true,
    //           modalFooterBuilder: (context, state) {
    //             return GestureDetector(
    //               onTap: () {
    //                 Navigator.pop(context);
    //               },
    //               child: Container(
    //                 width: double.infinity,
    //                 height: 50,
    //                 alignment: Alignment.center,
    //                 decoration: const BoxDecoration(
    //                   color: Colors.black,
    //                 ),
    //                 child: const Text(
    //                   'SUBMIT',
    //                   style: TextStyle(
    //                     color: Colors.white,
    //                     fontSize: 16.0,
    //                   ),
    //                 ),
    //               ),
    //             );
    //           },
    //           tileBuilder: (context, state) {
    //             return S2Tile.fromState(
    //               state,
    //               isTwoLine: true,
    //             );
    //           },
    //         ),
    //       ),
    //     ),*/
    //   ],
    // );
  }

  Widget _memberResidentialAdd() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Residential Address *',
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
                controller: _txtControllerResidentialAddress,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                maxLines: 3,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter Residential Address',
                ),
                onChanged: (String str) {},
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _memberCorrespondenceAdd() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Correspondence Address *',
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
                controller: _txtControllerCorrespondenceAddress,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                maxLines: 3,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter Correspondence Address',
                ),
                onChanged: (String str) {},
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _expectedWeddingYear() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Expected Wedding Year',
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
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: TextField(
                controller: _txtControllerExpectedWeddingYear,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter Expected Wedding Year',
                ),
                onChanged: (String str) {},
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _membershipPeriod() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Membership Period *',
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
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: TextField(
                controller: _txtControllerMembershipPeriod,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter Membership Period',
                ),
                onChanged: (String str) {},
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _aadharNo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Aadhar No. *',
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
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: TextField(
                controller: _txtControllerAadharNo,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter Aadhar Number',
                ),
                onChanged: (String str) {},
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    _focusRatePerSqFt.dispose();
    _focusAgreementValue.dispose();
    super.dispose();
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
            child: Text('Membership Amount *',
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
                  onChanged: (value) {
                    setState(() {
                      gstValue = 0.0;
                      gstValue = double.parse(value) *
                          double.parse('${percentagate!.gstPer}') /
                          100;
                      gstValue = gstValue + totalCustomChargesGST;
                    });
                  },
                  controller: _txtControllerFlatAgreementValue,
                  style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                    border: InputBorder.none,
                    hintText: 'Enter Membership Amount',
                  ),
                  onSubmitted: (String str) {},
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _Remark() {
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
  }

  Widget _gstvalue() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text('GST Value (${percentagate!.gstPer!}%)',
                style: const TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(currencyFormat.format(gstValue)),
          ),
        ),
        horizontalSpaceSmall,
      ],
    );
  }
}
