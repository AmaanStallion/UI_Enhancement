import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:stallion/models/add_lead_details_response.dart';
import 'package:stallion/models/get_all_sales_lead.dart';
import 'package:stallion/models/lead_other_add.dart';
import 'package:stallion/models/lead_phone_number.dart';
import 'package:stallion/models/region_list_response.dart';
import 'package:stallion/models/sales_lead_default_filter.dart';
import 'package:stallion/models/verify_email_otp.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/salesLeadDetailPage.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class AddSalesLeadPage extends StatefulWidget {
  String? projectId;
  String? towarId;
  String? projectName;
  String? navigationFlag;
  String? towarName;
  List<AreaRangeList>? intrestFilters = [];
  List<AreaRangeList>? location = [];
  List<BrokerList>? brokerList = [];
  List<String>? requirementList = [];
  List<AreaRangeList>? rangeList = [];
  List<AreaRangeList>? sourceList = [];
  List<FlatDetail>? flatDetails = [];
  List<AreaRangeList>? areaRangeList = [];
  List<AreaRangeList>? subSources = [];
  List<AreaRangeList>? ethnicity = [];
  List<AreaRangeList>? leadStage = [];
  List<AreaRangeList>? lostReason = [];
  List<AreaRangeList>? currentOwner = [];
  List<AreaRangeList>? currentConfiguration = [];
  List<AreaRangeList>? campaign = [];
  List<AreaRangeList>? nationality = [];

  SalesLead? dataEdit;
  String? clientAccess = '';
  List<AssingUserList>? assingUserList = [];
  bool dataEditBool = true;
  AddSalesLeadPage({
    super.key,
    this.projectId,
    this.clientAccess,
    this.towarId,
    this.projectName,
    this.navigationFlag,
    this.towarName,
    this.intrestFilters,
    this.location,
    this.brokerList,
    this.requirementList,
    this.rangeList,
    this.subSources,
    this.flatDetails,
    this.areaRangeList,
    this.ethnicity,
    this.leadStage,
    this.dataEdit,
    this.lostReason,
    this.assingUserList,
    this.dataEditBool = true,
    this.currentOwner,
    this.currentConfiguration,
    this.sourceList,
    this.campaign,
    this.nationality,
  });

  @override
  State<AddSalesLeadPage> createState() => _AddSalesLeadPageState();
}

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class _AddSalesLeadPageState extends State<AddSalesLeadPage> {
  List<AlternatePhone>? alternatePhone = [AlternatePhone(mobilenumber: '')];

  String? buyerType = "End Buyer";
  String? fundingType = "Self Funding";

  DateTime? _selectExcavationdate;
  final TextEditingController _selectDateExcavationController =
      TextEditingController();

  Future<void> _selectExcavationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectExcavationdate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      // DateTime(2000),
      lastDate: DateTime.now(), //DateTime.now(),
    );
    if (picked != null && picked != _selectExcavationdate) {
      setState(() {
        _selectExcavationdate = picked;
        _selectDateExcavationController.text =
            DateFormat('dd-MM-yyyy').format(_selectExcavationdate!);
      });
    }
  }

  final GlobalKey<FormState> _formKeyRera = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyRequirement = GlobalKey<FormState>();
  TextEditingController searchController = TextEditingController();
  TextEditingController intrestContoller = TextEditingController();
  TextEditingController statusContoller = TextEditingController();
  TextEditingController assignToContoller = TextEditingController();
  TextEditingController sourceManagerContoller = TextEditingController();
  TextEditingController closingManagerContoller = TextEditingController();

  TextEditingController otpControler = TextEditingController();
  TextEditingController ageControler = TextEditingController();

  TextEditingController currentOwnerControler = TextEditingController();
  TextEditingController currentConfigurationControler = TextEditingController();
  TextEditingController currentCampaignControler = TextEditingController();
  TextEditingController currentNationalityControler = TextEditingController();
  TextEditingController pincodeControler = TextEditingController();
  String isEmailVerified = "0";
  String isEmailVerifiedMesage = "";

  String isPhoneVerified = "0";

  String currentText = "";
  final formKey = GlobalKey<FormState>();
  StreamController<ErrorAnimationType>? errorController;
  TextEditingController? textEditingController;

  String searchTextBroker = '';
  bool isChecked = false;
  String selectedRequirement = "";
  String selectedCurrentOwner = "";
  String selectedCurrentConfiguration = '';
  String selectedNationality = '';
  String selectedcampaign = "";
  String selectedRequirementFlats = "";
  String selectedArea = "";

  String selectedSubSource = "0";

  String selectedRequirementBudget = "";
  String selectedReraArea = "0";
  String selectedSourceManager = '0';
  String selectedClosingManager = '0';

  String selectedRequirementSource = "";
  String selectedlocation = "";

  TextEditingController remarkControler = TextEditingController();
  TextEditingController customReraControler = TextEditingController();

  String selectedInterest = "";
  String selectedethnicity = "0";

  String selectedBroker = "";
  String selectedLostReason = "0";

  String selectedLeadStage = "0";
  List<RegionList>? regionList = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController errorTextCustomRequirement = TextEditingController();
  TextEditingController buyerControler = TextEditingController();
  TextEditingController bankNameControler = TextEditingController();
  TextEditingController accountHolderControler = TextEditingController();
  TextEditingController accountNoControler = TextEditingController();
  TextEditingController ifscCodeControler = TextEditingController();
  TextEditingController branchNameControler = TextEditingController();

  TextEditingController areaControler = TextEditingController();

  TextEditingController phoneControler = TextEditingController();
  TextEditingController emailControler = TextEditingController();
  TextEditingController budgetControler = TextEditingController();
  TextEditingController reraAreaControler = TextEditingController();
  TextEditingController ethnicityControler = TextEditingController();
  TextEditingController leadStageControler = TextEditingController();
  TextEditingController lostReasonControler = TextEditingController();

  TextEditingController sourceControler = TextEditingController();
  TextEditingController locationControler = TextEditingController();
  TextEditingController controllerdate = TextEditingController();

  TextEditingController updateControler = TextEditingController();
  TextEditingController requremntControler = TextEditingController();
  TextEditingController interestControler = TextEditingController();
  TextEditingController brokerControler = TextEditingController();
  TextEditingController flatControler = TextEditingController();
  TextEditingController subSourceControler = TextEditingController();

  DateTime? selectedEndDatePopup;
  String searchText = '';
  String searchAreaText = '';
  String validatePhoneText = '';

  bool isModalOpen = false;
  bool isModalOpenArea = false;

  TextEditingController customRequirementInputControler =
      TextEditingController();
  // List<AreaRangeList>? locationTemp = [];
  int _seconds = 30;
  Timer? _timer;

  // @override
  // void dispose() {
  //   _timer?.cancel();
  //   super.dispose();
  // }

  Future<void> selectRevisitDatePopUp({
    required BuildContext context,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedRevisitDatePopup ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedRevisitDatePopup) {
      selectedRevisitDatePopup = picked;
      controllerRevisitdate.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  List<AreaRangeList>? filteredProjects() {
    if (searchText.isEmpty) {
      return widget.location;
    }
    return widget.location!.where((project) {
      return project.name!.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
  }

  List<RegionList>? filteredArea() {
    if (searchText.isEmpty) {
      return regionList;
    }
    return regionList!.where((project) {
      return project.name!
          .toLowerCase()
          .contains(areaControler.text.toLowerCase());
    }).toList();
  }

  List<BrokerList>? filteredBroker() {
    if (searchTextBroker.isEmpty) {
      return widget.brokerList;
    }
    return widget.brokerList!.where((project) {
      return project.companyName!
          .toLowerCase()
          .contains(searchTextBroker.toLowerCase());
    }).toList();
  }

  // Color getColor(Set<MaterialState> states) {
  //   const Set<MaterialState> interactiveStates = <MaterialState>{
  //     MaterialState.pressed,
  //     MaterialState.hovered,
  //     MaterialState.focused,
  //   };
  //   if (states.any(interactiveStates.contains)) {
  //     return Colors.white;
  //   }
  //   return Colors.white;
  // }
  Future<void> selectEndDatePopUp({
    required BuildContext context,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedEndDatePopup ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedEndDatePopup) {
      selectedEndDatePopup = picked;
      controllerdate.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  bool isValidEmail(String val) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(val);
  }

  Future addNewSalesLead() async {
    String flaginvestor = "0";
    if (buyerType == "End Buyer") {
      //End buyer
      flaginvestor = "0";
    } else {
      flaginvestor = "1";
    }

    String funding = "0";
    if (fundingType == "Self Funding") {
      funding = "0";
    } else if (fundingType == "Sell to Asset") {
      funding = "2";
    } else {
      funding = "1";
    }
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "buyer_type": flaginvestor,
      "funding_type": funding,
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId!,
      "lead_buyer_name": buyerControler.text,
      "lead_buyer_phone": phoneControler.text,
      "lead_buyer_email_id": emailControler.text,
      "lead_requirement": requremntControler.text,
      "lead_buyer_budget": budgetControler.text,
      "lead_buyer_source": sourceControler.text,
      "lead_buyer_intrest": selectedInterest,
      "lead_buyer_comment": updateControler.text,
      "broker_id": selectedBroker,
      "lead_buyer_flat": selectedRequirementFlats,
      "lead_source_manage": selectedSourceManager,
      "lead_closing_manager": selectedClosingManager,
      "email_verify": isEmailVerified,
      "sms_verify": isPhoneVerified,
      "bank_name": bankNameControler.text,
      "bank_account_holder_name": accountHolderControler.text,
      "bank_account_no": accountNoControler.text,
      "bank_ifsc": ifscCodeControler.text,
      "bank_branch": branchNameControler.text,
      "lead_buyer_location": locationControler.text,
      "lead_buyer_notify": controllerdate.text,
      'assignto_id': selectedAssignTo, //update
      "ethinicity_id": selectedethnicity,
      "mst_sales_lead_id": widget.dataEditBool == true
          ? ""
          : widget.dataEdit?.mstSalesLeadId ?? '',
      "sub_source_id": selectedSubSource,
      "revisit_date": controllerRevisitdate.text, //update
      "location_id": selectedlocation,
      "lead_stage_id": selectedLeadStage,
      "lost_reason_id": selectedLostReason,
      "area_range_name": reraAreaControler.text,
      "area_range_id": selectedReraArea,
      "lead_buyer_budget_id": selectedRequirementBudget,
      "lead_buyer_source_id": selectedRequirementSource,
      "lead_buyer_region": areaControler.text,
      "region_id": searchAreaText,
      "age": ageControler.text,
      "alternate_phone": jsonEncode(alternatePhone),
      "nationality": selectedNationality,
      "campaign": selectedcampaign,
      "current_owner": selectedCurrentOwner,
      "current_configuration": selectedCurrentConfiguration,
      "pincode": pincodeControler.text,
      "lead_created_date": _selectDateExcavationController.text,
    };
    print(data);

    var response =
        await apiNetworkHandler.post(AppUrl.webGetAddSalesLead, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = addLeadDetailsResponseFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {}
    }
    return null;
  }

  Future validatePhoneNumber({
    required String val,
  }) async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId!,
      "phone_no": val,
    };
    print(data);

    var response = await apiNetworkHandler.post(AppUrl.webleadPhoneExist, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = leadPhoneNumberResponseFromJson(response.body);
      if (dataModel.response?.errorCode == "2") {
        setState(() {
          validatePhoneText = dataModel.response?.msg ?? '';
        });
      }
    }
    return null;
  }

  @override
  void dispose() {
    buyerControler.clear();
    phoneControler.clear();
    emailControler.clear();
    budgetControler.clear();
    sourceControler.clear();
    updateControler.clear();
    requremntControler.clear();
    interestControler.clear();
    brokerControler.clear();
    customRequirementInputControler.clear();
    selectedRequirement = "";
    selectedInterest = "";
    selectedBroker = "";
    super.dispose();
  }

  Future<ResponseRegionListResponse?> getRegionList(
      {required String val}) async {
    CustomLoading.progressDialog(isLoading: true, context: context);
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId!,
      "location_id": val,
    };
    var response =
        await apiNetworkHandler.post(AppUrl.webGetLeadRegionList, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      CustomLoading.progressDialog(isLoading: false, context: context);
      final dataModel = regionListResponseFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          regionList = dataModel.response?.regionList;
          // selectedArea = '';
          // areaControler.clear();
        });
      }
    }
    return null;
  }

  Future<ResponseRegionListResponse?> addotherLeads(
      {required String typeId, required String type_name}) async {
    CustomLoading.progressDialog(isLoading: true, context: context);
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "type_id": typeId,
      "type_name": type_name
    };
    var response = await apiNetworkHandler.post(AppUrl.webleadOtherAdd, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      CustomLoading.progressDialog(isLoading: false, context: context);
      final dataModel = laedOtherAddFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          if (typeId == '6') {
            widget.lostReason?.add(AreaRangeList(
                id: dataModel.response?.id.toString(), name: type_name));

            selectedLostReason = dataModel.response?.id.toString() ?? '';
            lostReasonControler.text = type_name;
          } else {
            widget.areaRangeList?.add(AreaRangeList(
                id: dataModel.response?.id.toString(), name: type_name));
            selectedReraArea = dataModel.response?.id.toString() ?? '';
            reraAreaControler.text = type_name;
          }

          Navigator.of(context).pop();
          // regionList = dataModel.response?.regionList;
          // selectedArea = '';
          customReraControler.clear();
        });
      }
    }
    return null;
  }

  Future<ResponseRegionListResponse?> verifyPhoneOtp(
      {required String mobileNo}) async {
    // CustomLoading.progressDialog(isLoading: true, context: context);
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "mobile_no": mobileNo,
    };
    var response =
        await apiNetworkHandler.post(AppUrl.wsLeadSmsOtpRequest, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // CustomLoading.progressDialog(isLoading: false, context: context);
      // final dataModel = laedOtherAddFromJson(response.body);
      // if (dataModel.response?.errorCode == "0") {
      //   setState(() {});
      // }
    } else {
      // CustomLoading.progressDialog(isLoading: false, context: context);
    }
    return null;
  }

  Future<ResponseRegionListResponse?> resendOtp(
      {required String mobileNo}) async {
    // CustomLoading.progressDialog(isLoading: true, context: context);
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      // "user_id": userId!,
      "mobile_no": mobileNo,
    };
    var response = await apiNetworkHandler.post(AppUrl.wsResendOtp, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // CustomLoading.progressDialog(isLoading: false, context: context);
      // final dataModel = laedOtherAddFromJson(response.body);
      // if (dataModel.response?.errorCode == "0") {
      //   setState(() {});
      // }
    } else {
      // CustomLoading.progressDialog(isLoading: false, context: context);
    }
    return null;
  }

  Future<String?> validatePhoneOtp(
      {required String mobileNo, required String otp}) async {
    // CustomLoading.progressDialog(isLoading: true, context: context);
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "mobile_no": mobileNo,
      "code": otp,
      "lead_id": widget.dataEditBool == true
          ? ""
          : widget.dataEdit?.mstSalesLeadId ?? '',
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
    };
    var response = await apiNetworkHandler.post(AppUrl.wsLeadOtpVerify, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = verifyEmailOtpFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          isPhoneVerified = "1";
        });
        Navigator.of(context).pop();
      } else {
        return dataModel.response?.msg;
        // setState(() {
        //   isEmailVerifiedMesage = dataModel.response?.msg ?? '';
        // });
      }
      // CustomLoading.progressDialog(isLoading: false, context: context);
      // final dataModel = laedOtherAddFromJson(response.body);
      // if (dataModel.response?.errorCode == "0") {
      //   setState(() {});
      // }
    } else {
      // CustomLoading.progressDialog(isLoading: false, context: context);
    }
    return null;
  }

  Future<ResponseRegionListResponse?> verifyEmailOtp(
      {required String mobileNo}) async {
    // CustomLoading.progressDialog(isLoading: true, context: context);
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "email_id": mobileNo,
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
    };
    var response =
        await apiNetworkHandler.post(AppUrl.wsLeadEmailOtpRequest, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // CustomLoading.progressDialog(isLoading: false, context: context);
      // final dataModel = verifyEmailOtpFromJson(response.body);
      // if (dataModel.response?.errorCode == "0") {
      //   setState(() {});
      // }
    } else {
      // CustomLoading.progressDialog(isLoading: false, context: context);
    }
    return null;
  }

  Future<String?> validateEmailOtp(
      {required String mobileNo, required String otp}) async {
    // CustomLoading.progressDialog(isLoading: true, context: context);
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "code": otp,
      "email_id": mobileNo,
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
      "lead_id": widget.dataEditBool == true
          ? ""
          : widget.dataEdit?.mstSalesLeadId ?? '',
    };
    var response = await apiNetworkHandler.post(AppUrl.wsLeadEmailVerify, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = verifyEmailOtpFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          isEmailVerified = "1";
        });
        Navigator.of(context).pop();
      } else {
        return dataModel.response?.msg;
        // setState(() {
        //   isEmailVerifiedMesage = dataModel.response?.msg ?? '';
        // });
      }

      // CustomLoading.progressDialog(isLoading: false, context: context);
      // final dataModel = laedOtherAddFromJson(response.body);
      // if (dataModel.response?.errorCode == "0") {
      //   setState(() {});
      // }
    } else {
      // CustomLoading.progressDialog(isLoading: false, context: context);
    }
    return null;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.dataEditBool == false) {
        setState(() {
          if (widget.dataEdit?.buyerTypeIdFk == "0") {
            //End buyer
            buyerType = "End Buyer";
          } else {
            buyerType = "Investor";
          }

          // String funding = "0";
          if (widget.dataEdit?.fundingTypeIdFk == "0") {
            fundingType = "Self Funding";
          } else if (widget.dataEdit?.fundingTypeIdFk == "2") {
            fundingType = "Sell to Asset";
          } else {
            fundingType = "Bank Funding";
          }
          _selectExcavationdate = widget.dataEdit?.leadBuyerCreatedAt;
          _selectDateExcavationController.text = DateFormat('dd-MM-yyyy')
              .format(widget.dataEdit?.leadBuyerCreatedAt ?? DateTime.now());
          // widget.dataEdit?.leadBuyerCreatedAt != null
          //     ? DateFormat('dd-MM-yyyy')
          //         .format(widget.dataEdit?.leadBuyerCreatedAt ?? DateTime.now())
          //     // DateFormat('dd-MM-yyyy')
          //     //     .parse(widget.dataEdit!.leadBuyerCreatedAt)
          //     : null;
          pincodeControler.text = widget.dataEdit?.pincode ?? '';
          currentOwnerControler.text = widget.dataEdit?.currentOwner ?? '';
          currentConfigurationControler.text =
              widget.dataEdit?.currentConfiguration ?? '';
          currentCampaignControler.text = widget.dataEdit?.campaign ?? '';
          currentNationalityControler.text = widget.dataEdit?.nationality ?? '';

          selectedCurrentOwner = widget.dataEdit?.currentOwnerIdFk ?? '';
          selectedCurrentConfiguration =
              widget.dataEdit?.currentConfigurationIdFk ?? '';
          selectedNationality = widget.dataEdit?.nationalityIdFk ?? '';
          selectedcampaign = widget.dataEdit?.campaignIdFk ?? '';
          alternatePhone = widget.dataEdit?.alternatePhone ?? [];
          ageControler.text = widget.dataEdit?.age ?? '';
          bankNameControler.text = widget.dataEdit?.leadBankName ?? '';
          accountHolderControler.text =
              widget.dataEdit?.leadBankAccountHolderName ?? '';
          accountNoControler.text = widget.dataEdit?.leadBankAccountNo ?? '';
          ifscCodeControler.text = widget.dataEdit?.leadBankIfsc ?? '';
          branchNameControler.text = widget.dataEdit?.leadBankBranch ?? '';

          emailControler.text = widget.dataEdit?.leadBuyerEmail ?? '';
          phoneControler.text = widget.dataEdit?.leadBuyerPhone ?? '';

          selectedReraArea = widget.dataEdit?.areaRangeIdFk ?? '';
          reraAreaControler.text = widget.dataEdit?.areaRangeName ?? '';

          selectedRequirementBudget = widget.dataEdit?.leadBudgetIdFk ?? '';
          budgetControler.text = widget.dataEdit?.leadBudgetValue ?? '';

          selectedRequirementSource = widget.dataEdit?.leadSource ?? '';
          sourceControler.text = widget.dataEdit?.leadSource ?? '';

          selectedSubSource = widget.dataEdit?.subSourceIdFk ?? '';
          subSourceControler.text = widget.dataEdit?.subSourceName ?? '';

          selectedethnicity = widget.dataEdit?.ethinicityIdFk ?? '';
          ethnicityControler.text = widget.dataEdit?.ethinicityIdName ?? '';

          searchText = widget.dataEdit?.locationIdFk ?? '';
          locationControler.text = widget.dataEdit?.leadLocation ?? '';
          getRegionList(val: widget.dataEdit?.locationIdFk ?? '0');
          selectedlocation = widget.dataEdit?.locationIdFk ?? ' ';

          selectedSourceManager = widget.dataEdit?.leadSourceManagerId ?? '0';
          selectedClosingManager = widget.dataEdit?.leadClosingManagerId ?? '0';

          sourceManagerContoller.text =
              widget.dataEdit?.sourceManagerName ?? '';
          closingManagerContoller.text =
              widget.dataEdit?.closingManagerName ?? '';

          if (widget.dataEdit?.leadFlatIdFk != '0') {
            flatControler.text = widget.dataEdit?.leadRequirement ?? '';
            selectedRequirementFlats = widget.dataEdit?.leadFlatIdFk ?? '0';
          } else {
            requremntControler.text = widget.dataEdit?.leadRequirement ?? '';
            selectedRequirement = widget.dataEdit?.leadRequirement ?? '';
          }

          // requremntControler.text =
          //     ? ""
          //     : widget.dataEdit?.leadRequirement ?? '';

          // flatControler.text = widget.dataEdit?.leadFlatIdFk != '0'
          //     ? widget.dataEdit?.leadRequirement ?? ''
          //     : "";

          // areaControler.text =
          //     widget.dataEdit?.areaRangeName ?? ''; //areaControler,searchAreaText
          // searchAreaText = widget.dataEdit?.areaRangeIdFk ?? '';

          selectedLeadStage = widget.dataEdit?.leadStageIdFk ?? '';
          leadStageControler.text = widget.dataEdit?.leadStageIdName ?? '';
          for (int j = 0; j < widget.intrestFilters!.length; j++) {
            if (widget.dataEdit?.leadIntrested ==
                widget.intrestFilters?[j].name) {
              selectedInterest = widget.intrestFilters?[j].id ?? '';
            }
          }

          // selectedInterest = widget.dataEdit?.leadIntrested ?? ''; // id not come
          interestControler.text = widget.dataEdit?.leadIntrested ?? '';

          selectedBroker = widget.dataEdit?.brokerIdFk ?? '';
          brokerControler.text = widget.dataEdit?.brokerName ?? '';

          buyerControler.text = widget.dataEdit?.leadBuyerName ?? '';

          areaControler.text = widget.dataEdit?.regionName ?? '';
          searchAreaText = widget.dataEdit?.regionIdFk ?? '';

          selectedLostReason = widget.dataEdit?.lostReasonIdFk ?? '';
          lostReasonControler.text = widget.dataEdit?.lostReasonName ?? '';
          isPhoneVerified = widget.dataEdit?.smsVerify ?? '0';
          isEmailVerified = widget.dataEdit?.emailVerify ?? '0';
        });
      } else {
        setState(() {
          alternatePhone = [AlternatePhone(mobilenumber: '')];
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: InkWell(
        onTap: () {
          context.loaderOverlay.show();

          if (_formKey.currentState!.validate() &&
              (requremntControler.text.isNotEmpty ||
                  flatControler.text.isNotEmpty) &&
              validatePhoneText == '') {
            addNewSalesLead().then((value) => {
                  context.loaderOverlay.hide(),
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
                      desc: "Lead Added Successfully",
                      alertAnimation: fadeAlertAnimation,
                      buttons: [
                        DialogButton(
                          onPressed: () => {
                            Navigator.of(context).pop(),
                            Navigator.pop(context),
                            if (widget.dataEditBool == false)
                              {
                                Navigator.of(context).pop(),
                              }
                          },
                          color: Colors.black,
                          child: const Text(
                            "OKAY",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ]).show(),
                });
          } else {
            context.loaderOverlay.hide();

            Alert(
                closeIcon: const SizedBox(),
                padding: const EdgeInsets.only(top: 0.0),
                image: Image.asset('images/Icon-512.png',
                    height: 80, fit: BoxFit.fitWidth),
                style: const AlertStyle(
                    titleTextAlign: TextAlign.center,
                    descTextAlign: TextAlign.center,
                    descStyle:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                    isCloseButton: true),
                context: context,
                desc: "Please fill all mandatory field",
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
        },
        child: Container(
          height: 54,
          color: Colors.black,
          child: const Center(
            child: Text(
              "SAVE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (widget.dataEditBool == true) {
              Navigator.maybePop(context);
            } else {
              Navigator.pop(context);
              Navigator.pop(context);
            }

            //Navigator.of(context).pushReplacementNamed('/dashboard');
          },
        ),
        centerTitle: true,
        title: Text(
          '${widget.projectName!.toUpperCase()} ${widget.towarName!.isNotEmpty ? "-" : ""} ${widget.towarName!.toUpperCase()}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (isModalOpen == true) {
            setState(() {
              isModalOpen = false;
            });

            for (int l = 0; l < widget.location!.length; l++) {
              if (widget.location?[l].name?.toLowerCase() ==
                  locationControler.text.toLowerCase()) {
                locationControler.text = widget.location?[l].name ?? '';
                selectedlocation = widget.location?[l].id ?? '';
                // locationControler.text = filteredProjects()![index].name ?? '';
                selectedArea = '';
                areaControler.clear();
                getRegionList(val: widget.location?[l].id ?? '0');
              }
            }
          }
          if (isModalOpenArea == true) {
            setState(() {
              isModalOpenArea = false;
            });

            for (int l = 0; l < regionList!.length; l++) {
              if (regionList?[l].name?.toLowerCase() ==
                  areaControler.text.toLowerCase()) {
                areaControler.text = regionList?[l].name ?? '';
                searchAreaText = regionList?[l].id ?? '';
                // locationControler.text = filteredProjects()![index].name ?? '';
                // getRegionList(val: regionList?[l].id ?? '0');
              }
            }
          }
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              width: double.maxFinite,
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                  color: Colors.grey,
                )),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 108),
                  const Spacer(),
                  AppText(
                    title:
                        widget.dataEditBool == true ? "ADD LEAD" : 'EDIT LEAD',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    titleTextAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () async {
                      if (widget.clientAccess != '') {
                        final uri = Uri.parse(widget.clientAccess ?? '');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          throw 'Could not launch';
                        }
                      }
                    },
                    child: Container(
                      // margin: const EdgeInsets.symmetric(vertical: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        // color: Colors.black,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          "CLIENT FORM",
                          style: TextStyle(color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // const SizedBox(height: 10),
                    _buyersType(),
                    // verticalSpaceSmall15,
                    _fundingType(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 60),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'HelveticaNeue'),
                              children: [
                                TextSpan(
                                  text: 'Full Name',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'HelveticaNeue'),
                                ),
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
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.32,
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "(Full Name Cannot Be Empty)";
                              }
                            },
                            maxLines: 1,
                            style: const TextStyle(fontSize: 13),
                            controller: buyerControler,
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                )),
                                errorBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.red,
                                )),
                                contentPadding: const EdgeInsets.all(15.0),
                                hintText: 'Enter Full Name',
                                border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(7.0)))),
                          ),
                        ),
                        Container(
                            // padding: const EdgeInsets.only(left: 60),
                            width: MediaQuery.of(context).size.width * 0.1,
                            padding: const EdgeInsets.only(right: 40),
                            child: const Text(
                              "Age",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'HelveticaNeue'),
                            )),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.32,
                          child: TextFormField(
                            // validator: (value) {
                            //   if (value!.isEmpty) {
                            //     return "(Age Cannot Be Empty)";
                            //   }
                            // },
                            maxLines: 1,
                            style: const TextStyle(fontSize: 13),
                            controller: ageControler,
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                )),
                                errorBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.red,
                                )),
                                contentPadding: const EdgeInsets.all(15.0),
                                hintText: 'Enter Age',
                                border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(7.0)))),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // textAndInput(
                    //   maxLength: 10,
                    //   controllerText: phoneControler,
                    //   title: "Phone No ",
                    //   isRequired: true,
                    //   hintText: 'Enter Phone No',
                    //   inputFormatters: [
                    //     FilteringTextInputFormatter.digitsOnly,
                    //   ],
                    //   onChanged: (value) {
                    //     if (value.length == 10) {
                    //       print(value);
                    //       validatePhoneNumber(val: value);
                    //     } else {
                    // setState(() {
                    //   validatePhoneText = '';
                    // });
                    //     }
                    //   },
                    //   validator: (value) {
                    //     if (value!.isEmpty) {
                    //       return "(Phone No Cannot Be Empty)";
                    //     } else if (value.length < 10 || value.length > 10) {
                    //       return "(Enter Valid Phone Number)";
                    //     }
                    //   },
                    // ),
                    Row(
                      children: [
                        // Container(
                        //   padding: const EdgeInsets.only(left: 60),
                        //   width: MediaQuery.of(context).size.width * 0.2,
                        //   child: Text(
                        //     title,
                        //     style: const TextStyle(
                        //       fontSize: 16,
                        //     ),
                        //   ),
                        // ),
                        Container(
                          padding: const EdgeInsets.only(left: 60),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'HelveticaNeue'),
                              children: [
                                TextSpan(
                                  text: 'Phone No',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'HelveticaNeue'),
                                ),
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
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.74,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                // width: MediaQuery.of(context).size.width * 0.66,
                                child: TextFormField(
                                  onChanged: (value) {
                                    if (value.length == 10 &&
                                        widget.dataEdit?.leadBuyerPhone !=
                                            phoneControler.text) {
                                      validatePhoneNumber(val: value);
                                    } else {
                                      setState(() {
                                        validatePhoneText = '';
                                      });
                                    }

                                    if (widget.dataEdit?.leadBuyerPhone !=
                                        phoneControler.text) {
                                      setState(() {
                                        isPhoneVerified = "0";
                                      });
                                    } else if (widget
                                            .dataEdit?.leadBuyerPhone ==
                                        phoneControler.text) {
                                      setState(() {
                                        isPhoneVerified = "1";
                                      });
                                    }
                                  },
                                  maxLength: 10,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "(Phone No Cannot Be Empty)";
                                    } else if (value.length < 10 ||
                                        value.length > 10) {
                                      return "(Enter Valid Phone Number)";
                                    }
                                    return null;
                                  },
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 13),
                                  controller: phoneControler,
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      errorBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.red,
                                      )),
                                      contentPadding:
                                          const EdgeInsets.all(15.0),
                                      hintText: 'Enter Phone No',
                                      border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(7.0)))),
                                ),
                              ),
                              // Spacer(),
                              const SizedBox(width: 20),
                              isPhoneVerified == "0"
                                  // ||
                                  //         widget.dataEdit?.leadBuyerPhone !=
                                  //             phoneControler.text
                                  ? InkWell(
                                      onTap: () async {
                                        if (validatePhoneText == '') {
                                          textEditingController =
                                              TextEditingController();
                                          otpControler.clear();
                                          setState(() {
                                            isEmailVerifiedMesage = '';
                                            _seconds = 30;
                                          });
                                          if (phoneControler.text.length ==
                                              10) {
                                            verifyPhoneOtp(
                                                mobileNo: phoneControler.text);
                                            showDialog<void>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return StatefulBuilder(builder:
                                                    (context, setState1) {
                                                  void _startTimer() {
                                                    _timer = Timer.periodic(
                                                        const Duration(
                                                            seconds: 1),
                                                        (timer) {
                                                      print(_seconds);
                                                      if (_seconds > 0) {
                                                        setState1(() {
                                                          _seconds--;
                                                        });
                                                      } else {
                                                        _timer?.cancel();
                                                      }
                                                    });
                                                  }

                                                  void _resendCode() {
                                                    resendOtp(
                                                        mobileNo: phoneControler
                                                            .text);

                                                    setState1(() {
                                                      _seconds = 30;
                                                    });
                                                    _startTimer();
                                                  }

                                                  if (_seconds == 30) {
                                                    _startTimer();
                                                  }

                                                  return AlertDialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8)),
                                                    titlePadding:
                                                        EdgeInsets.zero,
                                                    actionsPadding:
                                                        EdgeInsets.zero,
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            0.0),
                                                    // title: Container(
                                                    //   padding: const EdgeInsets
                                                    //       .symmetric(vertical: 8),
                                                    //   decoration: const BoxDecoration(
                                                    //       color: Colors.black,
                                                    //       borderRadius:
                                                    //           BorderRadius.only(
                                                    //               topLeft: Radius
                                                    //                   .circular(
                                                    //                       8),
                                                    //               topRight: Radius
                                                    //                   .circular(
                                                    //                       8))),
                                                    //   child: const Text(
                                                    //       "Verify Otp",
                                                    //       style: TextStyle(
                                                    //           color: Colors.white,
                                                    //           fontSize: 16,
                                                    //           fontWeight:
                                                    //               FontWeight
                                                    //                   .w600),
                                                    //       textAlign:
                                                    //           TextAlign.center),
                                                    // ),
                                                    actions: <Widget>[
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: InkWell(
                                                                onTap: () {
                                                                  setState1(() {
                                                                    isEmailVerifiedMesage =
                                                                        '';
                                                                  });
                                                                  if (formKey
                                                                      .currentState!
                                                                      .validate()) {
                                                                    validatePhoneOtp(
                                                                            mobileNo: phoneControler
                                                                                .text,
                                                                            otp:
                                                                                currentText)
                                                                        .then(
                                                                            (value) {
                                                                      setState1(
                                                                          () {
                                                                        isEmailVerifiedMesage =
                                                                            value ??
                                                                                '';
                                                                      });
                                                                    });
                                                                  }
                                                                },
                                                                child: Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            8),
                                                                    decoration: const BoxDecoration(
                                                                        color: Colors
                                                                            .black,
                                                                        borderRadius: BorderRadius.only(
                                                                            bottomLeft: Radius.circular(
                                                                                8),
                                                                            bottomRight: Radius.circular(
                                                                                8))),
                                                                    child: const Text(
                                                                        "Verify OTP",
                                                                        style: TextStyle(
                                                                            fontSize: 16,
                                                                            fontWeight: FontWeight.w600,
                                                                            color: Colors.white),
                                                                        textAlign: TextAlign.center))),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                    content: StatefulBuilder(
                                                      builder:
                                                          (BuildContext context,
                                                              StateSetter
                                                                  setState) {
                                                        return Container(
                                                          height: 220,
                                                          width: 300,
                                                          decoration: const BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          8),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          8))),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      24),
                                                          child: Form(
                                                            key: formKey,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const Text(
                                                                  "Mobile Number Verification",
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 20),
                                                                const Text(
                                                                  "You will receive an SMS or Call shortly",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 6),
                                                                Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            10.0,
                                                                        horizontal:
                                                                            10),
                                                                    child:
                                                                        PinCodeTextField(
                                                                      appContext:
                                                                          context,
                                                                      pastedTextStyle:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .green
                                                                            .shade600,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                      length: 4,
                                                                      obscureText:
                                                                          false,
                                                                      obscuringCharacter:
                                                                          '*',
                                                                      blinkWhenObscuring:
                                                                          true,
                                                                      validator:
                                                                          (v) {
                                                                        if (v!.length <
                                                                            3) {
                                                                          return "Please enter OTP code.";
                                                                        } else {
                                                                          return null;
                                                                        }
                                                                      },
                                                                      pinTheme:
                                                                          PinTheme(
                                                                        shape: PinCodeFieldShape
                                                                            .box,
                                                                        borderRadius:
                                                                            BorderRadius.circular(5),
                                                                        fieldHeight:
                                                                            50,
                                                                        fieldWidth:
                                                                            50,
                                                                        activeFillColor:
                                                                            Colors.white,
                                                                        inactiveFillColor:
                                                                            Colors.white,
                                                                        selectedFillColor:
                                                                            Colors.white,
                                                                      ),
                                                                      cursorColor:
                                                                          Colors
                                                                              .black,
                                                                      animationDuration:
                                                                          const Duration(
                                                                              milliseconds: 300),
                                                                      enableActiveFill:
                                                                          true,
                                                                      errorAnimationController:
                                                                          errorController,
                                                                      controller:
                                                                          textEditingController,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      boxShadows: const [
                                                                        BoxShadow(
                                                                          offset: Offset(
                                                                              0,
                                                                              1),
                                                                          color:
                                                                              Colors.black12,
                                                                          blurRadius:
                                                                              10,
                                                                        )
                                                                      ],
                                                                      onCompleted:
                                                                          (v) {
                                                                        print(
                                                                            "Completed");
                                                                      },
                                                                      onChanged:
                                                                          (value) {
                                                                        print(
                                                                            value);

                                                                        setState(
                                                                            () {
                                                                          currentText =
                                                                              value;
                                                                          isEmailVerifiedMesage =
                                                                              "";
                                                                        });
                                                                      },
                                                                      beforeTextPaste:
                                                                          (text) {
                                                                        //print("Allowing to paste $text");
                                                                        return true;
                                                                      },
                                                                    )),
                                                                // TextFormField(
                                                                //   // onChanged: (value) {
                                                                //   //   if (value.length == 10) {
                                                                //   //     print(value);
                                                                //   //     validatePhoneNumber(val: value);
                                                                //   //   } else {
                                                                //   //     setState(() {
                                                                //   //       validatePhoneText = '';
                                                                //   //     });
                                                                //   //   }
                                                                //   // },
                                                                //   // maxLength: 10,
                                                                //   // inputFormatters: [
                                                                //   //   FilteringTextInputFormatter.digitsOnly,
                                                                //   // ],
                                                                //   validator:
                                                                //       (value) {
                                                                //     if (value!
                                                                //         .isEmpty) {
                                                                //       return "(OTP Cannot Be Empty)";
                                                                //     }
                                                                //     return null;
                                                                //   },
                                                                //   maxLines: 1,
                                                                //   style:
                                                                //       const TextStyle(
                                                                //           fontSize:
                                                                //               13),
                                                                //   controller:
                                                                //       otpControler,
                                                                //   decoration: InputDecoration(
                                                                //       enabledBorder: OutlineInputBorder(
                                                                //           borderSide: BorderSide(
                                                                //         color: Colors
                                                                //             .grey
                                                                //             .shade300,
                                                                //       )),
                                                                //       errorBorder: const OutlineInputBorder(
                                                                //           borderSide: BorderSide(
                                                                //         color: Colors
                                                                //             .red,
                                                                //       )),
                                                                //       contentPadding: const EdgeInsets.all(15.0),
                                                                //       hintText: 'Enter OTP',
                                                                //       border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(7.0)))),
                                                                // ),
                                                                const SizedBox(
                                                                    height: 6),

                                                                // Center(
                                                                //   child: RichText(
                                                                //     text:
                                                                //         TextSpan(
                                                                //       text:
                                                                //           "Didn't receive the code",
                                                                //       style: DefaultTextStyle.of(
                                                                //               context)
                                                                //           .style,
                                                                //       children: const <TextSpan>[
                                                                //         TextSpan(
                                                                //             text:
                                                                //                 '    Resend',
                                                                //             style: TextStyle(
                                                                //                 color: kcSecondaryLightBlueColor,
                                                                //                 fontWeight: FontWeight.bold,
                                                                //                 fontSize: 13)),
                                                                //       ],
                                                                //     ),
                                                                //   ),
                                                                // )
                                                                Center(
                                                                  child:
                                                                      RichText(
                                                                    text:
                                                                        TextSpan(
                                                                      text:
                                                                          // _seconds >
                                                                          //         0
                                                                          // ?
                                                                          "Didn't receive the code",
                                                                      // : "Resend",
                                                                      style: DefaultTextStyle.of(
                                                                              context)
                                                                          .style,
                                                                      children: _seconds ==
                                                                              0
                                                                          ? [
                                                                              TextSpan(
                                                                                text: ' Resend',
                                                                                style: const TextStyle(
                                                                                  color: Colors.blue, // Replace with kcSecondaryLightBlueColor
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontSize: 13,
                                                                                ),
                                                                                recognizer: TapGestureRecognizer()..onTap = _resendCode,
                                                                              ),
                                                                            ]
                                                                          : [
                                                                              TextSpan(
                                                                                text: ' $_seconds',
                                                                                style: const TextStyle(
                                                                                  color: Colors.black, // Replace with kcSecondaryLightBlueColor
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontSize: 13,
                                                                                ),
                                                                              )
                                                                            ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                if (isEmailVerifiedMesage !=
                                                                    '')
                                                                  Text(
                                                                    isEmailVerifiedMesage,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  );
                                                });
                                              },
                                            ).then((value) {
                                              _timer?.cancel();
                                            });
                                          } else {
                                            showDialog<String>(
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
                                                        AlertDialog(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8)),
                                                          titlePadding:
                                                              EdgeInsets.zero,
                                                          actionsPadding:
                                                              EdgeInsets.zero,
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .all(0.0),
                                                          content: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        20),
                                                            child: const Text(
                                                                'Mobile Number should be 10 digits.',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .normal,
                                                                    fontSize:
                                                                        17.0)),
                                                          ),
                                                          actions: <Widget>[
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      InkWell(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child: Container(
                                                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                                                              decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8))),
                                                                              child: const Text("CLOSE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.center))),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ));
                                          }
                                        }
                                      },
                                      child: Container(
                                        // margin: const EdgeInsets.symmetric(vertical: 12),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 11),
                                        decoration: BoxDecoration(
                                          // color: Colors.black,
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          "Verify",
                                          style: TextStyle(
                                              color: validatePhoneText == "" &&
                                                      phoneControler
                                                              .text.length ==
                                                          10
                                                  ? Colors.black
                                                  : Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: const Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.blue))
                            ],
                          ),
                        )
                        // SizedBox(width: 60),
                      ],
                    ),

                    for (int i = 0; i < alternatePhone!.length; i++)
                      Row(
                        children: [
                          // Container(
                          //   padding: const EdgeInsets.only(left: 60),
                          //   width: MediaQuery.of(context).size.width * 0.2,
                          //   child: Text(
                          //     title,
                          //     style: const TextStyle(
                          //       fontSize: 16,
                          //     ),
                          //   ),
                          // ),
                          Container(
                            padding: const EdgeInsets.only(left: 60),
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: i == 0
                                ? RichText(
                                    text: const TextSpan(
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'HelveticaNeue'),
                                      children: [
                                        TextSpan(
                                          text: 'Alternate Phone No',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'HelveticaNeue'),
                                        ),
                                        // TextSpan(
                                        //   text: "*", // The asterisk
                                        //   style: TextStyle(
                                        //     color: Colors
                                        //         .red, // Color for the asterisk
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.74,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  // width: MediaQuery.of(context).size.width * 0.66,
                                  child: TextFormField(
                                    maxLength: 10,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) {
                                      // if (value!.isEmpty) {
                                      //   return "(Alternate Phone No Cannot Be Empty)";
                                      // } else if (value.length < 10 ||
                                      //     value.length > 10) {
                                      //   return "(Enter Valid Alternate Phone Number)";
                                      // }
                                      // return null;
                                    },
                                    maxLines: 1,
                                    style: const TextStyle(fontSize: 13),
                                    controller: TextEditingController(
                                        text: alternatePhone?[i]
                                            .mobilenumber), //phoneControler,
                                    onChanged: (value) {
                                      alternatePhone?[i].mobilenumber = value;
                                    },
                                    decoration: InputDecoration(
                                        hintStyle: const TextStyle(
                                            color: Colors.black45),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        )),
                                        errorBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                          color: Colors.red,
                                        )),
                                        contentPadding:
                                            const EdgeInsets.all(15.0),
                                        hintText: 'Enter Alternate Phone No',
                                        border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(7.0)))),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                i == 0
                                    ? InkWell(
                                        onTap: () {
                                          setState(() {
                                            alternatePhone
                                                ?.add(AlternatePhone());
                                          });
                                        },
                                        child: Container(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: const Icon(
                                              Icons.add_circle_outline,
                                              color: Colors.black),
                                        ),
                                      )
                                    : InkWell(
                                        onTap: () {
                                          setState(() {
                                            alternatePhone?.removeAt(i);
                                          });
                                        },
                                        child: Container(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Colors.black),
                                        ),
                                      )
                              ],
                            ),
                          )
                          // SizedBox(width: 60),
                        ],
                      ),

                    const SizedBox(height: 10),

                    if (validatePhoneText != '')
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 60),
                            width: MediaQuery.of(context).size.width * 0.2,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            validatePhoneText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 221, 26, 0),
                            ),
                          ),
                        ],
                      ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 60),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'HelveticaNeue'),
                              children: [
                                TextSpan(
                                  text: 'Email',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'HelveticaNeue'),
                                ),
                                // TextSpan(
                                //   text: "*", // The asterisk
                                //   style: TextStyle(
                                //     color: Colors.red, // Color for the asterisk
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.74,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                // width: MediaQuery.of(context).size.width * 0.66,
                                child: TextFormField(
                                  onChanged: (value) {
                                    //   if (value.length == 10) {
                                    //     print(value);
                                    //     validatePhoneNumber(val: value);
                                    //   } else {
                                    //     setState(() {
                                    //       validatePhoneText = '';
                                    //     });
                                    //   }

                                    if (widget.dataEdit?.leadBuyerEmail !=
                                        emailControler.text) {
                                      setState(() {
                                        isEmailVerified = "0";
                                      });
                                    } else if (widget
                                            .dataEdit?.leadBuyerEmail ==
                                        emailControler.text) {
                                      setState(() {
                                        isEmailVerified = "1";
                                      });
                                    }
                                  },
                                  // maxLength: 10,
                                  // inputFormatters: [
                                  //   FilteringTextInputFormatter.digitsOnly,
                                  // ],
                                  // validator: (value) {
                                  //   if (value!.isEmpty) {
                                  //     return "(Email Address Cannot Be Empty)";
                                  //   } else if (!isValidEmail(value)) {
                                  //     return "Enter Valid Email-id";
                                  //   }
                                  //   return null;
                                  // },
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 13),
                                  controller: emailControler,
                                  decoration: InputDecoration(
                                      hintStyle: const TextStyle(
                                          color: Colors.black45),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      errorBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.red,
                                      )),
                                      contentPadding:
                                          const EdgeInsets.all(15.0),
                                      hintText:
                                          'Enter Email Address (Optional)',
                                      border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(7.0)))),
                                ),
                              ),
                              // Spacer(),
                              const SizedBox(width: 20),
                              // Container(
                              //     padding: const EdgeInsets.only(top: 8),
                              //     child: const Icon(Icons.check_circle_outline,
                              //         color: Colors.blue))
                              isEmailVerified == "0"
                                  // ||
                                  //         widget.dataEdit?.leadBuyerEmail !=
                                  //             emailControler.text
                                  ? InkWell(
                                      onTap: () async {
                                        otpControler.clear();
                                        textEditingController =
                                            TextEditingController();

                                        setState(() {
                                          isEmailVerifiedMesage = "";
                                          _seconds = 30;
                                        });
                                        if (emailControler.text.isNotEmpty) {
                                          verifyEmailOtp(
                                              mobileNo: emailControler.text);
                                          showDialog<void>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return StatefulBuilder(builder:
                                                  (context, setState1) {
                                                void _startTimer() {
                                                  _timer = Timer.periodic(
                                                      const Duration(
                                                          seconds: 1), (timer) {
                                                    print(_seconds);
                                                    if (_seconds > 0) {
                                                      setState1(() {
                                                        _seconds--;
                                                      });
                                                    } else {
                                                      _timer?.cancel();
                                                    }
                                                  });
                                                }

                                                void _resendCode() {
                                                  verifyEmailOtp(
                                                      mobileNo:
                                                          emailControler.text);

                                                  setState1(() {
                                                    _seconds = 30;
                                                  });
                                                  _startTimer();
                                                }

                                                if (_seconds == 30) {
                                                  _startTimer();
                                                }
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                  titlePadding: EdgeInsets.zero,
                                                  actionsPadding:
                                                      EdgeInsets.zero,
                                                  contentPadding:
                                                      const EdgeInsets.all(0.0),
                                                  // title: Container(
                                                  //   padding: const EdgeInsets
                                                  //       .symmetric(vertical: 8),
                                                  //   decoration: const BoxDecoration(
                                                  //       color: Colors.black,
                                                  //       borderRadius:
                                                  //           BorderRadius.only(
                                                  //               topLeft: Radius
                                                  //                   .circular(
                                                  //                       8),
                                                  //               topRight: Radius
                                                  //                   .circular(
                                                  //                       8))),
                                                  //   child: const Text(
                                                  //       "Verify Otp",
                                                  //       style: TextStyle(
                                                  //           color: Colors.white,
                                                  //           fontSize: 16,
                                                  //           fontWeight:
                                                  //               FontWeight
                                                  //                   .w600),
                                                  //       textAlign:
                                                  //           TextAlign.center),
                                                  // ),
                                                  actions: <Widget>[
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: InkWell(
                                                              onTap: () {
                                                                setState1(() {
                                                                  isEmailVerifiedMesage =
                                                                      '';
                                                                });
                                                                if (formKey
                                                                    .currentState!
                                                                    .validate()) {
                                                                  validateEmailOtp(
                                                                          mobileNo: emailControler
                                                                              .text,
                                                                          otp:
                                                                              currentText)
                                                                      .then(
                                                                          (value) {
                                                                    setState1(
                                                                        () {
                                                                      isEmailVerifiedMesage =
                                                                          value ??
                                                                              '';
                                                                    });
                                                                  });
                                                                }
                                                              },
                                                              child: Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          8),
                                                                  decoration: const BoxDecoration(
                                                                      color: Colors
                                                                          .black,
                                                                      borderRadius: BorderRadius.only(
                                                                          bottomLeft: Radius.circular(
                                                                              8),
                                                                          bottomRight: Radius.circular(
                                                                              8))),
                                                                  child: const Text(
                                                                      "Verify OTP",
                                                                      style: TextStyle(
                                                                          fontSize: 16,
                                                                          fontWeight: FontWeight.w600,
                                                                          color: Colors.white),
                                                                      textAlign: TextAlign.center))),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                  content: Container(
                                                    height: 220,
                                                    width: 300,
                                                    decoration: const BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        8),
                                                                topRight: Radius
                                                                    .circular(
                                                                        8))),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 24),
                                                    child: Form(
                                                      key: formKey,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Text(
                                                            "E-mail Verification",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 20),
                                                          const Text(
                                                            "You will receive an E-mail shortly",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 6),
                                                          // TextFormField(
                                                          //   onChanged: (value) {
                                                          //     //   if (value.length == 10) {
                                                          //     //     print(value);
                                                          //     //     validatePhoneNumber(val: value);
                                                          //     //   } else {
                                                          //     //     setState(() {
                                                          //     //       validatePhoneText = '';
                                                          //     //     });
                                                          //     //   }
                                                          //     setState1(() {
                                                          //       isEmailVerifiedMesage =
                                                          //           '';
                                                          //     });
                                                          //   },
                                                          //   // maxLength: 10,
                                                          //   // inputFormatters: [
                                                          //   //   FilteringTextInputFormatter.digitsOnly,
                                                          //   // ],
                                                          //   validator: (value) {
                                                          //     if (value!
                                                          //         .isEmpty) {
                                                          //       return "(OTP Cannot Be Empty)";
                                                          //     }
                                                          //     return null;
                                                          //   },
                                                          //   maxLines: 1,
                                                          //   style:
                                                          //       const TextStyle(
                                                          //           fontSize:
                                                          //               13),
                                                          //   controller:
                                                          //       otpControler,
                                                          //   decoration:
                                                          //       InputDecoration(
                                                          //           enabledBorder:
                                                          //               OutlineInputBorder(
                                                          //                   borderSide:
                                                          //                       BorderSide(
                                                          //             color: Colors
                                                          //                 .grey
                                                          //                 .shade300,
                                                          //           )),
                                                          //           errorBorder:
                                                          //               const OutlineInputBorder(
                                                          //                   borderSide:
                                                          //                       BorderSide(
                                                          //             color: Colors
                                                          //                 .red,
                                                          //           )),
                                                          //           contentPadding:
                                                          //               const EdgeInsets
                                                          //                   .all(
                                                          //                   15.0),
                                                          //           hintText:
                                                          //               'Enter OTP',
                                                          //           border: const OutlineInputBorder(
                                                          //               borderRadius:
                                                          //                   BorderRadius.all(Radius.circular(7.0)))),
                                                          // ),
                                                          Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          10.0,
                                                                      horizontal:
                                                                          10),
                                                              child:
                                                                  PinCodeTextField(
                                                                appContext:
                                                                    context,
                                                                pastedTextStyle:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .green
                                                                      .shade600,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                                length: 4,
                                                                obscureText:
                                                                    false,
                                                                obscuringCharacter:
                                                                    '*',
                                                                blinkWhenObscuring:
                                                                    true,
                                                                validator: (v) {
                                                                  if (v!.length <
                                                                      3) {
                                                                    return "Please enter OTP code.";
                                                                  } else {
                                                                    return null;
                                                                  }
                                                                },
                                                                pinTheme:
                                                                    PinTheme(
                                                                  shape:
                                                                      PinCodeFieldShape
                                                                          .box,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  fieldHeight:
                                                                      50,
                                                                  fieldWidth:
                                                                      50,
                                                                  activeFillColor:
                                                                      Colors
                                                                          .white,
                                                                  inactiveFillColor:
                                                                      Colors
                                                                          .white,
                                                                  selectedFillColor:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                                cursorColor:
                                                                    Colors
                                                                        .black,
                                                                animationDuration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            300),
                                                                enableActiveFill:
                                                                    true,
                                                                errorAnimationController:
                                                                    errorController,
                                                                controller:
                                                                    textEditingController,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                boxShadows: const [
                                                                  BoxShadow(
                                                                    offset:
                                                                        Offset(
                                                                            0,
                                                                            1),
                                                                    color: Colors
                                                                        .black12,
                                                                    blurRadius:
                                                                        10,
                                                                  )
                                                                ],
                                                                onCompleted:
                                                                    (v) {
                                                                  print(
                                                                      "Completed");
                                                                },
                                                                onChanged:
                                                                    (value) {
                                                                  print(value);

                                                                  setState(() {
                                                                    currentText =
                                                                        value;
                                                                    isEmailVerifiedMesage =
                                                                        "";
                                                                  });
                                                                },
                                                                beforeTextPaste:
                                                                    (text) {
                                                                  //print("Allowing to paste $text");
                                                                  return true;
                                                                },
                                                              )),
                                                          const SizedBox(
                                                              height: 6),
                                                          Center(
                                                            child: RichText(
                                                              text: TextSpan(
                                                                text:
                                                                    // _seconds >
                                                                    //         0
                                                                    // ?
                                                                    "Didn't receive the code",
                                                                // : "Resend",
                                                                style: DefaultTextStyle.of(
                                                                        context)
                                                                    .style,
                                                                children:
                                                                    _seconds ==
                                                                            0
                                                                        ? [
                                                                            TextSpan(
                                                                              text: ' Resend',
                                                                              style: const TextStyle(
                                                                                color: Colors.blue, // Replace with kcSecondaryLightBlueColor
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 13,
                                                                              ),
                                                                              recognizer: TapGestureRecognizer()..onTap = _resendCode,
                                                                            ),
                                                                          ]
                                                                        : [
                                                                            TextSpan(
                                                                              text: ' $_seconds',
                                                                              style: const TextStyle(
                                                                                color: Colors.black, // Replace with kcSecondaryLightBlueColor
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 13,
                                                                              ),
                                                                            )
                                                                          ],
                                                              ),
                                                            ),
                                                          ),
                                                          if (isEmailVerifiedMesage !=
                                                              '')
                                                            Text(
                                                              isEmailVerifiedMesage,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              });
                                            },
                                          ).then((value) {
                                            print(
                                                '--------------+-==========================');
                                            _timer?.cancel();
                                          });
                                        }
                                      },
                                      child: Container(
                                        // margin: const EdgeInsets.symmetric(vertical: 12),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 11),
                                        decoration: BoxDecoration(
                                          // color: Colors.black,
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          "Verify",
                                          style: TextStyle(color: Colors.black),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: const Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.blue),
                                    ),
                              // InkWell(
                              //   onTap: () async {},
                              //   child: Container(
                              //     // margin: const EdgeInsets.symmetric(vertical: 12),
                              //     padding: const EdgeInsets.symmetric(
                              //         horizontal: 20, vertical: 11),
                              //     decoration: BoxDecoration(
                              //       // color: Colors.black,
                              //       border:
                              //           Border.all(color: Colors.grey.shade300),
                              //       borderRadius: BorderRadius.circular(8),
                              //     ),
                              //     child: Text(
                              //       "Verify",
                              //       style: TextStyle(color: Colors.black),
                              //       textAlign: TextAlign.center,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        )
                        // SizedBox(width: 60),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // Container(
                        //   padding: const EdgeInsets.only(left: 60),
                        //   width: MediaQuery.of(context).size.width * 0.2,
                        //   child: const Text(
                        //     'Requirement ',
                        //     style: TextStyle(
                        //       fontSize: 16,
                        //     ),
                        //   ),
                        // ),
                        Container(
                          padding: const EdgeInsets.only(left: 60),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w200,
                                  fontFamily: 'HelveticaNeue'),
                              children: [
                                TextSpan(
                                  text: "Requirement ",
                                ),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      title: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                        ),
                                        child: const Text(
                                          "Select Requirement",
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
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                8), // Set radius to zero
                                                      ),
                                                      elevation: 0,
                                                      titlePadding:
                                                          EdgeInsets.zero,
                                                      actionsPadding:
                                                          const EdgeInsets.only(
                                                              bottom: 10,
                                                              left: 10,
                                                              right: 10),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 16),
                                                      actionsAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      title: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 6),
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.black,
                                                        ),
                                                        child: const Text(
                                                          "ADD CUSTOM",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Container(
                                                            width: 240,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        4),
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .black,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            7)),
                                                            child: const Text(
                                                              "CLOSE",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            if (_formKeyRequirement
                                                                .currentState!
                                                                .validate()) {
                                                              setState(() {
                                                                widget
                                                                    .requirementList
                                                                    ?.add(remarkControler
                                                                        .text);

                                                                selectedRequirement =
                                                                    remarkControler
                                                                        .text;
                                                                requremntControler
                                                                        .text =
                                                                    remarkControler
                                                                        .text;
                                                                selectedRequirementFlats =
                                                                    '';
                                                              });
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              remarkControler
                                                                  .clear();
                                                              flatControler
                                                                  .clear();
                                                            }
                                                          },
                                                          child: Container(
                                                            width: 240,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        4),
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .black,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            7)),
                                                            child: const Text(
                                                              "ADD",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                      content: StatefulBuilder(
                                                          builder: (BuildContext
                                                                  context,
                                                              StateSetter
                                                                  setState) {
                                                        return Form(
                                                            key:
                                                                _formKeyRequirement,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          40),
                                                              width: 400,
                                                              child:
                                                                  TextFormField(
                                                                validator:
                                                                    (value) {
                                                                  if (value!
                                                                      .isNotEmpty) {
                                                                    for (int u =
                                                                            0;
                                                                        u < widget.requirementList!.length;
                                                                        u++) {
                                                                      if (widget.requirementList?[u]
                                                                              .toLowerCase() ==
                                                                          remarkControler
                                                                              .text
                                                                              .toLowerCase()) {
                                                                        return "Entered Requirement has already exists.";
                                                                      }
                                                                    }
                                                                    // return "(From Date Cannot be Ready)"
                                                                  }
                                                                },
                                                                controller:
                                                                    remarkControler,
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        13.0),
                                                                decoration:
                                                                    const InputDecoration(
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              12.0),
                                                                  border: OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.black)),
                                                                  hintText:
                                                                      'Please Enter Remark',
                                                                  hintStyle:
                                                                      TextStyle(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            116,
                                                                            116,
                                                                            116),
                                                                    fontSize:
                                                                        13.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w200,
                                                                    fontFamily:
                                                                        'HelveticaNeue',
                                                                  ),
                                                                  // suffixIcon: Icon(
                                                                  //   Icons.calendar_month_outlined,
                                                                  // ),
                                                                ),
                                                              ),
                                                            ));
                                                      }));
                                                });
                                          },
                                          child: Container(
                                            width: 240,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            child: const Text(
                                              "ADD CUSTOM",
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
                                          },
                                          child: Container(
                                            width: 240,
                                            padding: const EdgeInsets.symmetric(
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
                                      content: StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return SizedBox(
                                          height: 340,
                                          width: 400,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                for (int j = 0;
                                                    j <
                                                        widget.requirementList!
                                                            .length;
                                                    j++)
                                                  Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                            border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                      color: Colors.grey,
                                                    ))),
                                                    child:
                                                        RadioListTile<String>(
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      title: Text(
                                                        widget.requirementList?[
                                                                j] ??
                                                            '',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      value:
                                                          widget.requirementList?[
                                                                  j] ??
                                                              '',
                                                      groupValue:
                                                          selectedRequirement,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedRequirement =
                                                              value ?? '';
                                                          requremntControler
                                                                  .text =
                                                              widget.requirementList?[
                                                                      j] ??
                                                                  '';

                                                          selectedRequirementFlats =
                                                              '';
                                                          flatControler.clear();
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      controlAffinity:
                                                          ListTileControlAffinity
                                                              .trailing,
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
                            width: MediaQuery.of(context).size.width / 2 * 0.69,
                            child: TextFormField(
                              enabled: false,
                              readOnly: true,
                              validator: (value) {
                                if (value!.isEmpty &&
                                    flatControler.text == "") {
                                  return "(Requirement Address Cannot Be Empty)";
                                }
                              },
                              controller: requremntControler,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 13.0),
                              decoration: const InputDecoration(
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.red,
                                  )),
                                  contentPadding: EdgeInsets.all(12.0),
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  hintText: 'Select BHK',
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 116, 116, 116),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'HelveticaNeue',
                                  ),
                                  suffixIcon: Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                  )),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(right: 34),
                          width: MediaQuery.of(context).size.width / 2 * 0.1,
                          child: const Text(
                            'Or ',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                      title: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                        ),
                                        child: const Text(
                                          "Select Flat",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      actions: <Widget>[
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Container(
                                            width: 480,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            child: const Text(
                                              "OKAY",
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
                                      content: StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return SizedBox(
                                          height: 340,
                                          width: 400,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                for (int j = 0;
                                                    j <
                                                        widget.flatDetails!
                                                            .length;
                                                    j++)
                                                  Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                            border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                      color: Colors.grey,
                                                    ))),
                                                    child:
                                                        RadioListTile<String>(
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      title: Text(
                                                        widget.flatDetails?[j]
                                                                .flatName ??
                                                            '',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      value: widget
                                                              .flatDetails?[j]
                                                              .flatId ??
                                                          '',
                                                      groupValue:
                                                          selectedRequirementFlats,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedRequirementFlats =
                                                              value ?? '';
                                                          flatControler
                                                              .text = widget
                                                                  .flatDetails?[
                                                                      j]
                                                                  .flatName ??
                                                              '';

                                                          selectedRequirement =
                                                              '';
                                                          requremntControler
                                                              .clear();
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      controlAffinity:
                                                          ListTileControlAffinity
                                                              .trailing,
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
                            width: MediaQuery.of(context).size.width / 2 * 0.69,
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty &&
                                    requremntControler.text == '') {
                                  return "(Flat Cannot Be Empty)";
                                }
                              },
                              enabled: false,
                              readOnly: true,
                              controller: flatControler,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 13.0),
                              decoration: const InputDecoration(
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.red,
                                  )),
                                  contentPadding: EdgeInsets.all(12.0),
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  hintText: 'Select Flat',
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 116, 116, 116),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'HelveticaNeue',
                                  ),
                                  suffixIcon: Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 60),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: const Text(
                            'Current Owner ',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'HelveticaNeue'),
                          ),
                        ),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                      title: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                        ),
                                        child: const Text(
                                          "Select Current Owner ",
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
                                            width: 440,
                                            padding: const EdgeInsets.symmetric(
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
                                      content: StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return SizedBox(
                                          height: 240,
                                          width: 400,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                for (int j = 0;
                                                    j <
                                                        widget.currentOwner!
                                                            .length;
                                                    j++)
                                                  Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                            border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                      color: Colors.grey,
                                                    ))),
                                                    child:
                                                        RadioListTile<String>(
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      title: Text(
                                                        widget.currentOwner?[j]
                                                                .name ??
                                                            '',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      value: widget
                                                              .currentOwner?[j]
                                                              .id ??
                                                          '',
                                                      groupValue:
                                                          selectedCurrentOwner,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedCurrentOwner =
                                                              value ?? '';
                                                          currentOwnerControler
                                                              .text = widget
                                                                  .currentOwner?[
                                                                      j]
                                                                  .name ??
                                                              '';

                                                          // selectedRequirementFlats =
                                                          //     '';
                                                          // flatControler.clear();
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      controlAffinity:
                                                          ListTileControlAffinity
                                                              .trailing,
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
                            width: MediaQuery.of(context).size.width * 0.74,
                            child: TextFormField(
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 13.0),
                              enabled: false,
                              readOnly: true,
                              // maxLength: maxLength,
                              // inputFormatters: inputFormatters,
                              // validator: (value) {
                              //   if (value!.isEmpty) {
                              //     return "(Ethnicity Cannot Be Empty)";
                              //   }
                              // },
                              // maxLines: maxLines,
                              controller: currentOwnerControler,
                              decoration: const InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.grey,
                                  )),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.red,
                                  )),
                                  contentPadding: EdgeInsets.all(15.0),
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 116, 116, 116),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'HelveticaNeue',
                                  ),
                                  hintText: 'Select Current Owner',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(7.0)))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 60),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: const Text(
                            'Current Configuration  ',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'HelveticaNeue'),
                          ),
                        ),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                      title: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                        ),
                                        child: const Text(
                                          "Select Current Configuration  ",
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
                                            width: 440,
                                            padding: const EdgeInsets.symmetric(
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
                                      content: StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return SizedBox(
                                          height: 240,
                                          width: 400,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                for (int j = 0;
                                                    j <
                                                        widget
                                                            .currentConfiguration!
                                                            .length;
                                                    j++)
                                                  Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                            border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                      color: Colors.grey,
                                                    ))),
                                                    child:
                                                        RadioListTile<String>(
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      title: Text(
                                                        widget.currentConfiguration?[j]
                                                                .name ??
                                                            '',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      value: widget
                                                              .currentConfiguration?[
                                                                  j]
                                                              .id ??
                                                          '',
                                                      groupValue:
                                                          selectedCurrentConfiguration,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedCurrentConfiguration =
                                                              value ?? '';
                                                          currentConfigurationControler
                                                              .text = widget
                                                                  .currentConfiguration?[
                                                                      j]
                                                                  .name ??
                                                              '';
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      controlAffinity:
                                                          ListTileControlAffinity
                                                              .trailing,
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
                            width: MediaQuery.of(context).size.width * 0.74,
                            child: TextFormField(
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 13.0),
                              enabled: false,
                              readOnly: true,
                              // maxLength: maxLength,
                              // inputFormatters: inputFormatters,
                              // validator: (value) {
                              //   if (value!.isEmpty) {
                              //     return "(Ethnicity Cannot Be Empty)";
                              //   }
                              // },
                              // maxLines: maxLines,
                              controller: currentConfigurationControler,
                              decoration: const InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.grey,
                                  )),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.red,
                                  )),
                                  contentPadding: EdgeInsets.all(15.0),
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 116, 116, 116),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'HelveticaNeue',
                                  ),
                                  hintText: 'Select Current Configuration ',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(7.0)))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // textAndInput(
                    //   controllerText: budgetControler,
                    //   title: "Budget *",
                    //   hintText: 'Enter Budget In Rupees',
                    // validator: (value) {
                    //   if (value!.isEmpty) {
                    //     return "(Budget Cannot Be Empty)";
                    //   }
                    // },
                    // ),
                    // const SizedBox(height: 20),
                    // textAndInput(
                    //   controllerText: budgetControler,
                    //   title: "Budget *",
                    //   hintText: 'Enter Budget In Rupees',
                    // validator: (value) {
                    //   if (value!.isEmpty) {
                    //     return "(Budget Cannot Be Empty)";
                    //   }
                    // },
                    // ),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 60),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: const Text(
                            'Carpet Area',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'HelveticaNeue'),
                          ),
                        ),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                      title: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                        ),
                                        child: const Text(
                                          "Select Carpet Area Req",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      actions: <Widget>[
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                8), // Set radius to zero
                                                      ),
                                                      elevation: 0,
                                                      titlePadding:
                                                          EdgeInsets.zero,
                                                      actionsPadding:
                                                          const EdgeInsets.only(
                                                              bottom: 10,
                                                              left: 10,
                                                              right: 10),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 16),
                                                      actionsAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      title: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 8),
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.black,
                                                        ),
                                                        child: const Text(
                                                          "ADD CUSTOM",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 16),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Container(
                                                            width: 240,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        4),
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .black,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            7)),
                                                            child: const Text(
                                                              "CLOSE",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            if (_formKeyRera
                                                                .currentState!
                                                                .validate()) {
                                                              addotherLeads(
                                                                  typeId: '7',
                                                                  type_name:
                                                                      customReraControler
                                                                          .text);
                                                            }
                                                          },
                                                          child: Container(
                                                            width: 240,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        4),
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .black,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            7)),
                                                            child: const Text(
                                                              "ADD",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                      content: StatefulBuilder(
                                                          builder: (BuildContext
                                                                  context,
                                                              StateSetter
                                                                  setState) {
                                                        return Form(
                                                          key: _formKeyRera,
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        40),
                                                            width: 400,
                                                            child:
                                                                TextFormField(
                                                              validator:
                                                                  (value) {
                                                                if (value!
                                                                    .isNotEmpty) {
                                                                  for (int u =
                                                                          0;
                                                                      u <
                                                                          widget
                                                                              .areaRangeList!
                                                                              .length;
                                                                      u++) {
                                                                    print(widget
                                                                            .areaRangeList?[
                                                                                u]
                                                                            .name
                                                                            ?.toLowerCase()
                                                                            .replaceAll('sqft',
                                                                                '')
                                                                            .trim() ==
                                                                        customReraControler
                                                                            .text
                                                                            .toLowerCase());
                                                                    if (widget
                                                                            .areaRangeList?[
                                                                                u]
                                                                            .name
                                                                            ?.toLowerCase()
                                                                            .replaceAll('sqft',
                                                                                '')
                                                                            .trim() ==
                                                                        customReraControler
                                                                            .text
                                                                            .toLowerCase()) {
                                                                      return "Entered Rera Area already exists.";
                                                                    }
                                                                  }
                                                                  // return "(From Date Cannot be Ready)"
                                                                }
                                                              },
                                                              controller:
                                                                  customReraControler,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      13.0),
                                                              decoration:
                                                                  const InputDecoration(
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            12.0),
                                                                border: OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Colors.black)),
                                                                hintText:
                                                                    'Please Enter Remark',
                                                                hintStyle:
                                                                    TextStyle(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          116,
                                                                          116,
                                                                          116),
                                                                  fontSize:
                                                                      13.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w200,
                                                                  fontFamily:
                                                                      'HelveticaNeue',
                                                                ),
                                                                // suffixIcon: Icon(
                                                                //   Icons.calendar_month_outlined,
                                                                // ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }));
                                                });
                                          },
                                          child: Container(
                                            width: 240,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            child: const Text(
                                              "ADD CUSTOM",
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
                                          },
                                          child: Container(
                                            width: 240,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            child: const Text(
                                              "OKAY",
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
                                      content: StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return SizedBox(
                                          height: 340,
                                          width: 400,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                for (int j = 0;
                                                    j <
                                                        widget.areaRangeList!
                                                            .length;
                                                    j++)
                                                  Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                            border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                      color: Colors.grey,
                                                    ))),
                                                    child:
                                                        RadioListTile<String>(
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      title: Text(
                                                        widget.areaRangeList?[j]
                                                                .name ??
                                                            '',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      value: widget
                                                              .areaRangeList?[j]
                                                              .id ??
                                                          '',
                                                      groupValue:
                                                          selectedReraArea,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedReraArea =
                                                              value ?? '';
                                                          reraAreaControler
                                                              .text = widget
                                                                  .areaRangeList?[
                                                                      j]
                                                                  .name ??
                                                              '';
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      controlAffinity:
                                                          ListTileControlAffinity
                                                              .trailing,
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
                            width: MediaQuery.of(context).size.width * 0.74,
                            child: TextFormField(
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 13.0),
                              enabled: false,
                              readOnly: true,
                              // maxLength: maxLength,
                              // inputFormatters: inputFormatters,
                              // validator: (value) {
                              //   if (value!.isEmpty) {
                              //     return "(Rera Area Cannot Be Empty)";
                              //   }
                              // },
                              // maxLines: maxLines,
                              // style: const TextStyle(fontSize: 13),
                              controller: reraAreaControler,
                              decoration: const InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.grey,
                                  )),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.red,
                                  )),
                                  contentPadding: EdgeInsets.all(15.0),
                                  hintText: 'Enter Carpet Area',
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 116, 116, 116),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'HelveticaNeue',
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(7.0)))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 60),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w200,
                                  fontFamily: 'HelveticaNeue'),
                              children: [
                                TextSpan(
                                  text: "Budget ",
                                ),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                      title: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                        ),
                                        child: const Text(
                                          "Select Budget",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      actions: <Widget>[
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Container(
                                            width: 480,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            child: const Text(
                                              "OKAY",
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
                                      content: StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return SizedBox(
                                          height: 340,
                                          width: 400,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                for (int j = 0;
                                                    j <
                                                        widget
                                                            .rangeList!.length;
                                                    j++)
                                                  Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                            border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                      color: Colors.grey,
                                                    ))),
                                                    child:
                                                        RadioListTile<String>(
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      title: Text(
                                                        widget.rangeList?[j]
                                                                .name ??
                                                            '',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      value: widget
                                                              .rangeList?[j]
                                                              .id ??
                                                          '',
                                                      groupValue:
                                                          selectedRequirementBudget,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedRequirementBudget =
                                                              value ?? '';
                                                          budgetControler
                                                              .text = widget
                                                                  .rangeList?[j]
                                                                  .name ??
                                                              '';
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      controlAffinity:
                                                          ListTileControlAffinity
                                                              .trailing,
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
                            width: MediaQuery.of(context).size.width * 0.74,
                            child: TextFormField(
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 13.0),
                              enabled: false,
                              readOnly: true,
                              // maxLength: maxLength,
                              // inputFormatters: inputFormatters,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "(Budget Cannot Be Empty)";
                                }
                              },
                              // maxLines: maxLines,
                              // style: const TextStyle(fontSize: 13),
                              controller: budgetControler,
                              decoration: const InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.grey,
                                  )),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.red,
                                  )),
                                  contentPadding: EdgeInsets.all(15.0),
                                  hintText: 'Enter Budget In Rupees',
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 116, 116, 116),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'HelveticaNeue',
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(7.0)))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 60),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w200,
                                  fontFamily: 'HelveticaNeue'),
                              children: [
                                TextSpan(
                                  text: "Source ",
                                ),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                      title: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                        ),
                                        child: const Text(
                                          "Select Source",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      actions: <Widget>[
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Container(
                                            width: 480,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            child: const Text(
                                              "OKAY",
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
                                      content: StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return SizedBox(
                                          height: 340,
                                          width: 400,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                for (int j = 0;
                                                    j <
                                                        widget
                                                            .sourceList!.length;
                                                    j++)
                                                  Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                            border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                      color: Colors.grey,
                                                    ))),
                                                    child:
                                                        RadioListTile<String>(
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      title: Text(
                                                        widget.sourceList?[j]
                                                                .name ??
                                                            '',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      value: widget
                                                              .sourceList?[j]
                                                              .name ??
                                                          '',
                                                      groupValue:
                                                          selectedRequirementSource,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedRequirementSource =
                                                              value ?? '';
                                                          sourceControler
                                                              .text = widget
                                                                  .sourceList?[
                                                                      j]
                                                                  .name ??
                                                              '';
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      controlAffinity:
                                                          ListTileControlAffinity
                                                              .trailing,
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
                            width: MediaQuery.of(context).size.width / 2 * 0.69,
                            child: TextFormField(
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 13.0),
                              enabled: false,
                              readOnly: true,
                              // maxLength: maxLength,
                              // inputFormatters: inputFormatters,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "(Source Cannot Be Empty)";
                                }
                              },
                              // maxLines: maxLines,
                              controller: sourceControler,
                              decoration: const InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.grey,
                                  )),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.red,
                                  )),
                                  contentPadding: EdgeInsets.all(15.0),
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 116, 116, 116),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'HelveticaNeue',
                                  ),
                                  hintText: 'Select Source',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(7.0)))),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(right: 24),
                          width: MediaQuery.of(context).size.width / 2 * 0.1,
                          child: const Text(
                            'Sub ',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                      title: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                        ),
                                        child: const Text(
                                          "Select Sub Source",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      actions: <Widget>[
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Container(
                                            width: 480,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            child: const Text(
                                              "OKAY",
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
                                      content: StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return SizedBox(
                                          height: 340,
                                          width: 400,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                for (int j = 0;
                                                    j <
                                                        widget
                                                            .subSources!.length;
                                                    j++)
                                                  Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                            border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                      color: Colors.grey,
                                                    ))),
                                                    child:
                                                        RadioListTile<String>(
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      title: Text(
                                                        widget.subSources?[j]
                                                                .name ??
                                                            '',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      value: widget
                                                              .subSources?[j]
                                                              .id ??
                                                          '',
                                                      groupValue:
                                                          selectedSubSource,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedSubSource =
                                                              value ?? '';
                                                          subSourceControler
                                                              .text = widget
                                                                  .subSources?[
                                                                      j]
                                                                  .name ??
                                                              '';

                                                          // selectedRequirement =
                                                          //     '';
                                                          // requremntControler
                                                          //     .clear();
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      controlAffinity:
                                                          ListTileControlAffinity
                                                              .trailing,
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
                            width: MediaQuery.of(context).size.width / 2 * 0.69,
                            child: TextFormField(
                              enabled: false,
                              readOnly: true,
                              controller: subSourceControler,
                              // validator: (value) {
                              //   if (value!.isEmpty) {
                              //     return "(Sub Source Cannot Be Empty)";
                              //   }
                              // },
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 13.0),

                              decoration: const InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.grey,
                                  )),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.red,
                                  )),
                                  contentPadding: EdgeInsets.all(15.0),
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 116, 116, 116),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'HelveticaNeue',
                                  ),
                                  hintText: 'Select Sub Source',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(7.0)))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 60),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: const Text(
                            'Campaign ',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'HelveticaNeue'),
                          ),
                        ),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                      title: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                        ),
                                        child: const Text(
                                          "Select Campaign",
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
                                            width: 440,
                                            padding: const EdgeInsets.symmetric(
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
                                      content: StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return SizedBox(
                                          height: 240,
                                          width: 400,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                for (int j = 0;
                                                    j < campaign!.length;
                                                    j++)
                                                  Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                            border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                      color: Colors.grey,
                                                    ))),
                                                    child:
                                                        RadioListTile<String>(
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      title: Text(
                                                        campaign?[j].name ?? '',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      value:
                                                          campaign?[j].id ?? '',
                                                      groupValue:
                                                          selectedcampaign,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedcampaign =
                                                              value ?? '';
                                                          currentCampaignControler
                                                                  .text =
                                                              campaign?[j]
                                                                      .name ??
                                                                  '';
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      controlAffinity:
                                                          ListTileControlAffinity
                                                              .trailing,
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
                            width: MediaQuery.of(context).size.width * 0.74,
                            child: TextFormField(
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 13.0),
                              enabled: false,
                              readOnly: true,
                              // maxLength: maxLength,
                              // inputFormatters: inputFormatters,
                              // validator: (value) {
                              //   if (value!.isEmpty) {
                              //     return "(Ethnicity Cannot Be Empty)";
                              //   }
                              // },
                              // maxLines: maxLines,
                              controller: currentCampaignControler,
                              decoration: const InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.grey,
                                  )),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.red,
                                  )),
                                  contentPadding: EdgeInsets.all(15.0),
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 116, 116, 116),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'HelveticaNeue',
                                  ),
                                  hintText: 'Select Campaign',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(7.0)))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 60),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: const Text(
                            'Ethnicity ',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'HelveticaNeue'),
                          ),
                        ),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                      title: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                        ),
                                        child: const Text(
                                          "Select Ethnicity",
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
                                            width: 440,
                                            padding: const EdgeInsets.symmetric(
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
                                      content: StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return SizedBox(
                                          height: 240,
                                          width: 400,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                for (int j = 0;
                                                    j <
                                                        widget
                                                            .ethnicity!.length;
                                                    j++)
                                                  Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                            border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                      color: Colors.grey,
                                                    ))),
                                                    child:
                                                        RadioListTile<String>(
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      title: Text(
                                                        widget.ethnicity?[j]
                                                                .name ??
                                                            '',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      value: widget
                                                              .ethnicity?[j]
                                                              .id ??
                                                          '',
                                                      groupValue:
                                                          selectedethnicity,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedethnicity =
                                                              value ?? '';
                                                          ethnicityControler
                                                              .text = widget
                                                                  .ethnicity?[j]
                                                                  .name ??
                                                              '';
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      controlAffinity:
                                                          ListTileControlAffinity
                                                              .trailing,
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
                            width: MediaQuery.of(context).size.width * 0.74,
                            child: TextFormField(
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 13.0),
                              enabled: false,
                              readOnly: true,
                              // maxLength: maxLength,
                              // inputFormatters: inputFormatters,
                              // validator: (value) {
                              //   if (value!.isEmpty) {
                              //     return "(Ethnicity Cannot Be Empty)";
                              //   }
                              // },
                              // maxLines: maxLines,
                              controller: ethnicityControler,
                              decoration: const InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.grey,
                                  )),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.red,
                                  )),
                                  contentPadding: EdgeInsets.all(15.0),
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 116, 116, 116),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'HelveticaNeue',
                                  ),
                                  hintText: 'Select Ethnicity',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(7.0)))),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 60),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: const Text(
                            'Nationality ',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'HelveticaNeue'),
                          ),
                        ),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                      title: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                        ),
                                        child: const Text(
                                          "Select Nationality ",
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
                                            width: 440,
                                            padding: const EdgeInsets.symmetric(
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
                                      content: StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return SizedBox(
                                          height: 240,
                                          width: 400,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                for (int j = 0;
                                                    j < nationality!.length;
                                                    j++)
                                                  Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                            border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                      color: Colors.grey,
                                                    ))),
                                                    child:
                                                        RadioListTile<String>(
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      title: Text(
                                                        nationality?[j].name ??
                                                            '',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      value:
                                                          nationality?[j].id ??
                                                              '',
                                                      groupValue:
                                                          selectedNationality,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedNationality =
                                                              value ?? '';
                                                          currentNationalityControler
                                                                  .text =
                                                              nationality?[j]
                                                                      .name ??
                                                                  '';
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      controlAffinity:
                                                          ListTileControlAffinity
                                                              .trailing,
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
                            width: MediaQuery.of(context).size.width * 0.74,
                            child: TextFormField(
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 13.0),
                              enabled: false,
                              readOnly: true,
                              // maxLength: maxLength,
                              // inputFormatters: inputFormatters,
                              // validator: (value) {
                              //   if (value!.isEmpty) {
                              //     return "(Ethnicity Cannot Be Empty)";
                              //   }
                              // },
                              // maxLines: maxLines,
                              controller: currentNationalityControler,
                              decoration: const InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.grey,
                                  )),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.red,
                                  )),
                                  contentPadding: EdgeInsets.all(15.0),
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 116, 116, 116),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'HelveticaNeue',
                                  ),
                                  hintText: 'Select Nationality',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(7.0)))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // textAndInput(
                    //   controllerText: locationControler,
                    //   title: "Location *",
                    //   hintText: 'Enter Location',
                    //   validator: (value) {
                    //     if (value!.isEmpty) {
                    //       return "(Location Cannot Be Empty)";
                    //     }
                    //   },
                    // ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 60, top: 14),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: const Text(
                            'City ',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'HelveticaNeue'),
                          ),
                        ),
                        // InkWell(
                        //   onTap: () {
                        //     showDialog(
                        //         context: context,
                        //         builder: (context) {
                        //           return AlertDialog(
                        //               shape: RoundedRectangleBorder(
                        //                 borderRadius: BorderRadius.circular(
                        //                     8), // Set radius to zero
                        //               ),
                        //               elevation: 0,
                        //               titlePadding: EdgeInsets.zero,
                        //               actionsPadding: const EdgeInsets.only(
                        //                   bottom: 10, left: 10, right: 10),
                        //               contentPadding:
                        //                   const EdgeInsets.symmetric(
                        //                       horizontal: 16),
                        //               title: Container(
                        //                 padding: const EdgeInsets.symmetric(
                        //                     vertical: 8),
                        //                 decoration: const BoxDecoration(
                        //                   color: Colors.black,
                        //                 ),
                        //                 child: const Text(
                        //                   "Select Location",
                        //                   style: TextStyle(
                        //                     color: Colors.white,
                        //                   ),
                        //                   textAlign: TextAlign.center,
                        //                 ),
                        //               ),
                        //               actionsAlignment:
                        //                   MainAxisAlignment.center,
                        //               actions: <Widget>[
                        //                 InkWell(
                        //                   onTap: () {
                        //                     Navigator.of(context).pop();
                        //                   },
                        //                   child: Container(
                        //                     width: 480,
                        //                     padding: const EdgeInsets.symmetric(
                        //                         vertical: 4),
                        //                     decoration: BoxDecoration(
                        //                         color: Colors.black,
                        //                         borderRadius:
                        //                             BorderRadius.circular(7)),
                        //                     child: const Text(
                        //                       "OKAY",
                        //                       style: TextStyle(
                        //                         fontSize: 16,
                        //                         fontWeight: FontWeight.w600,
                        //                         color: Colors.white,
                        //                       ),
                        //                       textAlign: TextAlign.center,
                        //                     ),
                        //                   ),
                        //                 ),
                        //               ],
                        //               content: StatefulBuilder(builder:
                        //                   (BuildContext context,
                        //                       StateSetter setState) {
                        //                 return SizedBox(
                        //                   height: 340,
                        //                   width: 400,
                        //                   child: SingleChildScrollView(
                        //                     child: Column(
                        //                       children: [
                        //                         for (int j = 0;
                        //                             j < widget.location!.length;
                        //                             j++)
                        //                           Container(
                        //                             decoration:
                        //                                 const BoxDecoration(
                        //                                     border: Border(
                        //                                         bottom:
                        //                                             BorderSide(
                        //                               color: Colors.grey,
                        //                             ))),
                        //                             child:
                        //                                 RadioListTile<String>(
                        //                               contentPadding:
                        //                                   EdgeInsets.zero,
                        //                               title: Text(
                        //                                 widget.location?[j]
                        //                                         .name ??
                        //                                     '',
                        //                                 style: const TextStyle(
                        //                                   fontSize: 16,
                        //                                 ),
                        //                               ),
                        //                               value: widget.location?[j]
                        //                                       .name ??
                        //                                   '',
                        //                               groupValue:
                        //                                   selectedlocation,
                        //                               onChanged: (value) {
                        //                                 setState(() {
                        //                                   selectedlocation =
                        //                                       value ?? '';
                        //                                   locationControler
                        //                                       .text = widget
                        //                                           .location?[j]
                        //                                           .name ??
                        //                                       '';
                        //                                 });
                        //                                 Navigator.of(context)
                        //                                     .pop();
                        //                                 getRegionList(
                        //                                     val: widget
                        //                                             .location?[
                        //                                                 j]
                        //                                             .id ??
                        //                                         '');
                        //                               },
                        //                               controlAffinity:
                        //                                   ListTileControlAffinity
                        //                                       .trailing,
                        //                             ),
                        //                           ),
                        //                       ],
                        //                     ),
                        //                   ),
                        //                 );
                        //               }));
                        //         });
                        //   },
                        // child:
                        Column(
                          children: [
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width / 2 * 0.6,
                              child: TextFormField(
                                onChanged: (value) {
                                  setState(() {
                                    searchText = value;
                                    isModalOpen = true;
                                    selectedArea = '';
                                    areaControler.clear();
                                    regionList?.clear();
                                    searchAreaText = '';
                                  });
                                },
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 13.0),
                                // enabled: false,
                                // readOnly: true,
                                // maxLength: maxLength,
                                // inputFormatters: inputFormatters,
                                // validator: (value) {
                                //   if (value!.isEmpty) {
                                //     return "(Location Cannot Be Empty)";
                                //   }
                                // },
                                // maxLines: maxLines,

                                controller: locationControler,
                                decoration: InputDecoration(
                                    // suffixIcon: Icon(
                                    //   Icons.keyboard_arrow_down_outlined,
                                    // ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    )),
                                    errorBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.red,
                                    )),
                                    contentPadding: const EdgeInsets.all(15.0),
                                    hintStyle: const TextStyle(
                                      color: Color.fromARGB(255, 116, 116, 116),
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w200,
                                      fontFamily: 'HelveticaNeue',
                                    ),
                                    hintText: 'Select City',
                                    border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(7.0)))),
                              ),
                            ),
                            if ((locationControler.text.length != 0 &&
                                    filteredProjects()!.length != 0) &&
                                isModalOpen == true)
                              Container(
                                height: 110,
                                width: MediaQuery.of(context).size.width /
                                    2 *
                                    0.69,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black45),
                                ),
                                child: ListView.separated(
                                  itemCount: filteredProjects()!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          isModalOpen = false;
                                        });
                                        selectedlocation =
                                            filteredProjects()![index].id ?? '';
                                        locationControler.text =
                                            filteredProjects()![index].name ??
                                                '';
                                        selectedArea = '';
                                        areaControler.clear();
                                        getRegionList(
                                            val:
                                                filteredProjects()![index].id ??
                                                    '0');
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Text(
                                          filteredProjects()![index].name ?? '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int i) {
                                    return const Divider();
                                  },
                                ),
                              )
                          ],
                        ),
                        // ),
                        Container(
                          padding: const EdgeInsets.only(right: 24, top: 16),
                          width: MediaQuery.of(context).size.width / 2 * 0.24,
                          child: const Text(
                            'Residential Area ',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            // InkWell(
                            //   onTap: () {
                            //     // showDialog(
                            //     //     context: context,
                            //     //     builder: (context) {
                            //     //       return AlertDialog(
                            //     //           shape: RoundedRectangleBorder(
                            //     //             borderRadius: BorderRadius.circular(
                            //     //                 8), // Set radius to zero
                            //     //           ),
                            //     //           elevation: 0,
                            //     //           titlePadding: EdgeInsets.zero,
                            //     //           actionsPadding: const EdgeInsets.only(
                            //     //               bottom: 10, left: 10, right: 10),
                            //     //           contentPadding:
                            //     //               const EdgeInsets.symmetric(
                            //     //                   horizontal: 16),
                            //     //           title: Container(
                            //     //             padding: const EdgeInsets.symmetric(
                            //     //                 vertical: 8),
                            //     //             decoration: const BoxDecoration(
                            //     //               color: Colors.black,
                            //     //             ),
                            //     //             child: const Text(
                            //     //               "Select Area",
                            //     //               style: TextStyle(
                            //     //                 color: Colors.white,
                            //     //               ),
                            //     //               textAlign: TextAlign.center,
                            //     //             ),
                            //     //           ),
                            //     //           actionsAlignment:
                            //     //               MainAxisAlignment.center,
                            //     //           actions: <Widget>[
                            //     //             InkWell(
                            //     //               onTap: () {
                            //     //                 Navigator.of(context).pop();
                            //     //               },
                            //     //               child: Container(
                            //     //                 width: 480,
                            //     //                 padding: const EdgeInsets.symmetric(
                            //     //                     vertical: 4),
                            //     //                 decoration: BoxDecoration(
                            //     //                     color: Colors.black,
                            //     //                     borderRadius:
                            //     //                         BorderRadius.circular(7)),
                            //     //                 child: const Text(
                            //     //                   "OKAY",
                            //     //                   style: TextStyle(
                            //     //                     fontSize: 16,
                            //     //                     fontWeight: FontWeight.w600,
                            //     //                     color: Colors.white,
                            //     //                   ),
                            //     //                   textAlign: TextAlign.center,
                            //     //                 ),
                            //     //               ),
                            //     //             ),
                            //     //           ],
                            //     //           content: StatefulBuilder(builder:
                            //     //               (BuildContext context,
                            //     //                   StateSetter setState) {
                            //     //             return SizedBox(
                            //     //               height: 340,
                            //     //               width: 400,
                            //     //               child: regionList!.length == 0
                            //     //                   ? Center(
                            //     //                       child: Text(
                            //     //                         "No Record Found",
                            //     //                         style: TextStyle(
                            //     //                             fontSize: 16,
                            //     //                             fontWeight:
                            //     //                                 FontWeight.w600),
                            //     //                       ),
                            //     //                     )
                            //     //                   : SingleChildScrollView(
                            //     //                       child: Column(
                            //     //                         children: [
                            //     //                           for (int j = 0;
                            //     //                               j <
                            //     //                                   regionList!
                            //     //                                       .length;
                            //     //                               j++)
                            //     //                             Container(
                            //     //                               decoration:
                            //     //                                   const BoxDecoration(
                            //     //                                       border: Border(
                            //     //                                           bottom: BorderSide(
                            //     //                                 color: Colors.grey,
                            //     //                               ))),
                            //     //                               child: RadioListTile<
                            //     //                                   String>(
                            //     //                                 contentPadding:
                            //     //                                     EdgeInsets.zero,
                            //     //                                 title: Text(
                            //     //                                   regionList?[j]
                            //     //                                           .name ??
                            //     //                                       '',
                            //     //                                   style:
                            //     //                                       const TextStyle(
                            //     //                                     fontSize: 16,
                            //     //                                   ),
                            //     //                                 ),
                            //     //                                 value:
                            //     //                                     regionList?[j]
                            //     //                                             .id ??
                            //     //                                         '',
                            //     //                                 groupValue:
                            //     //                                     selectedArea,
                            //     //                                 onChanged: (value) {
                            //     //                                   setState(() {
                            //     //                                     selectedArea =
                            //     //                                         value ?? '';
                            //     //                                     areaControler
                            //     //                                             .text =
                            //     //                                         regionList?[j]
                            //     //                                                 .name ??
                            //     //                                             '';

                            //     //                                     // selectedRequirement =
                            //     //                                     //     '';
                            //     //                                     // requremntControler
                            //     //                                     //     .clear();
                            //     //                                   });
                            //     //                                   Navigator.of(
                            //     //                                           context)
                            //     //                                       .pop();
                            //     //                                 },
                            //     //                                 controlAffinity:
                            //     //                                     ListTileControlAffinity
                            //     //                                         .trailing,
                            //     //                               ),
                            //     //                             ),
                            //     //                         ],
                            //     //                       ),
                            //     //                     ),
                            //     //             );
                            //     //           }));
                            //     //     });
                            //   },
                            // child:
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width / 2 * 0.6,
                              child: TextFormField(
                                onChanged: (value) {
                                  setState(() {
                                    searchAreaText = '0';
                                    isModalOpenArea = true;
                                    // selectedArea = '';
                                    // areaControler.clear();
                                    // regionList?.clear();
                                  });
                                },
                                // enabled: false,
                                // readOnly: true,
                                controller: areaControler,
                                // validator: (value) {
                                //   if (value!.isEmpty) {
                                //     return "(Area Cannot Be Empty)";
                                //   }
                                // },
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 13.0),
                                decoration: InputDecoration(
                                    // suffixIcon: const Icon(
                                    //   Icons.keyboard_arrow_down_outlined,
                                    // ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    )),
                                    errorBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.red,
                                    )),
                                    contentPadding: const EdgeInsets.all(15.0),
                                    hintStyle: const TextStyle(
                                      color: Color.fromARGB(255, 116, 116, 116),
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w200,
                                      fontFamily: 'HelveticaNeue',
                                    ),
                                    hintText: 'Select Residential Area',
                                    border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(7.0)))),
                              ),
                            ),
                            // ),
                            if ((areaControler.text.length != 0 &&
                                    filteredArea()!.length != 0) &&
                                isModalOpenArea == true)
                              Container(
                                height: 110,
                                width: MediaQuery.of(context).size.width /
                                    2 *
                                    0.69,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black45),
                                ),
                                child: ListView.separated(
                                  itemCount: filteredArea()!.length,
                                  itemBuilder:
                                      (BuildContext context, int index1) {
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          isModalOpenArea = false;
                                        });

                                        areaControler.text =
                                            filteredArea()![index1].name ?? '';
                                        searchAreaText =
                                            filteredArea()![index1].id ?? '';
                                        // getRegionList(
                                        //     val:
                                        //         filteredArea()![index].id ?? '0');
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Text(
                                          filteredArea()![index1].name ?? '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int i) {
                                    return const Divider();
                                  },
                                ),
                              )
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    textAndInput(
                      controllerText: pincodeControler,
                      title: "Pincode ",
                      isRequired: false,
                      hintText: 'Enter Pincode',
                      maxLines: 1,
                      // validator: (value) {
                      //   if (value!.isEmpty) {
                      //     return "(Pincode Cannot Be Empty)";
                      //   }
                      // },
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 60),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: const Text(
                            'Lead Stage',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'HelveticaNeue'),
                          ),
                        ),
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
                                    title: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                      ),
                                      child: const Text(
                                        "Select Lead Stage",
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
                                          width: 440,
                                          padding: const EdgeInsets.symmetric(
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
                                    content: StatefulBuilder(
                                      builder: (BuildContext context,
                                          StateSetter setState1) {
                                        return SizedBox(
                                          height: 340,
                                          width: 400,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                for (int j = 0;
                                                    j <
                                                        widget
                                                            .leadStage!.length;
                                                    j++)
                                                  InkWell(
                                                    onTap: () {
                                                      if (selectedLeadStage ==
                                                          widget.leadStage?[j]
                                                              .id) {
                                                        setState(() {
                                                          selectedLeadStage =
                                                              "0";
                                                          leadStageControler
                                                              .clear();
                                                        });
                                                      } else {
                                                        setState(() {
                                                          selectedLeadStage =
                                                              widget.leadStage?[j]
                                                                      .id ??
                                                                  '';

                                                          leadStageControler
                                                              .text = widget
                                                                  .leadStage?[j]
                                                                  .name ??
                                                              '';
                                                        });
                                                      }
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 7),
                                                        decoration:
                                                            const BoxDecoration(
                                                                border: Border(
                                                                    bottom:
                                                                        BorderSide(
                                                          color: Colors.grey,
                                                        ))),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              widget.leadStage?[j]
                                                                      .name ??
                                                                  '',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                            const Spacer(),
                                                            Icon(
                                                              selectedLeadStage ==
                                                                      widget
                                                                          .leadStage?[
                                                                              j]
                                                                          .id
                                                                  ? Icons
                                                                      .check_circle_outline
                                                                  : Icons
                                                                      .circle_outlined,
                                                              color: selectedLeadStage ==
                                                                      widget
                                                                          .leadStage?[
                                                                              j]
                                                                          .id
                                                                  ? Colors.green
                                                                  : Colors.grey,
                                                            )
                                                          ],
                                                        )
                                                        //     RadioListTile<String>(
                                                        //   contentPadding:
                                                        //       EdgeInsets.zero,
                                                        //   title:
                                                        // Text(
                                                        //     widget.leadStage?[j]
                                                        //             .name ??
                                                        //         '',
                                                        //     style: const TextStyle(
                                                        //       fontSize: 16,
                                                        //     ),
                                                        //   ),
                                                        //   value:
                                                        // widget
                                                        //           .leadStage?[j]
                                                        //           .id ??
                                                        //       '',
                                                        //   groupValue:
                                                        //       selectedLeadStage,
                                                        //   onChanged: (value) {
                                                        //     print(
                                                        //         '-----------------');
                                                        // setState(() {
                                                        //   selectedLeadStage =
                                                        //       value ?? '';
                                                        //   leadStageControler
                                                        //       .text = widget
                                                        //           .leadStage?[j]
                                                        //           .name ??
                                                        //       '';
                                                        // });
                                                        //     Navigator.of(context)
                                                        //         .pop();
                                                        //   },
                                                        //   controlAffinity:
                                                        //       ListTileControlAffinity
                                                        //           .trailing,
                                                        // ),
                                                        ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                });
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.74,
                            child: TextFormField(
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 13.0),
                              enabled: false,
                              readOnly: true,
                              // maxLength: maxLength,
                              // inputFormatters: inputFormatters,
                              // validator: (value) {
                              //   if (value!.isEmpty) {
                              //     return "(Lead Stage Cannot Be Empty)";
                              //   }
                              // },
                              // maxLines: maxLines,
                              controller: leadStageControler,
                              decoration: const InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.grey,
                                  )),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.red,
                                  )),
                                  contentPadding: EdgeInsets.all(15.0),
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 116, 116, 116),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'HelveticaNeue',
                                  ),
                                  hintText: 'Select Lead Stage',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(7.0)))),
                            ),
                          ),
                          // Container(
                          //   decoration: BoxDecoration(
                          //       border: Border.all(
                          //         color: Colors.grey,
                          //       ),
                          //       borderRadius: const BorderRadius.all(
                          //           Radius.circular(7.0))),
                          //   width: MediaQuery.of(context).size.width * 0.74,
                          //   height: 44,
                          //   child: TextField(
                          //     enabled: false,
                          //     readOnly: true,
                          //     controller: brokerControler,
                          //     style: const TextStyle(
                          //         color: Colors.black, fontSize: 15.0),
                          //     decoration: const InputDecoration(
                          //         contentPadding: EdgeInsets.all(12.0),
                          //         border: InputBorder.none,
                          //         hintText: 'Select Broker',
                          //         suffixIcon: Icon(
                          //           Icons.keyboard_arrow_down_outlined,
                          //         )),
                          //   ),
                          // ),
                        ),
                      ],
                    ),
                    if ((leadStageControler.text).toLowerCase() ==
                        'not interested')
                      const SizedBox(height: 20),
                    if ((leadStageControler.text).toLowerCase() ==
                        'not interested')
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 60),
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'HelveticaNeue'),
                                children: [
                                  TextSpan(
                                    text: "Lost Reason ",
                                  ),
                                  TextSpan(
                                    text: "*", // The asterisk
                                    style: TextStyle(
                                      color:
                                          Colors.red, // Color for the asterisk
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16),
                                        title: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                          ),
                                          child: const Text(
                                            "Select Lost Reason",
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
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  8), // Set radius to zero
                                                        ),
                                                        elevation: 0,
                                                        titlePadding:
                                                            EdgeInsets.zero,
                                                        actionsPadding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 10,
                                                                left: 10,
                                                                right: 10),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 16),
                                                        actionsAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        title: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 8),
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors.black,
                                                          ),
                                                          child: const Text(
                                                            "ADD CUSTOM",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        actions: <Widget>[
                                                          InkWell(
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Container(
                                                              width: 240,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          4),
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .black,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              7)),
                                                              child: const Text(
                                                                "CLOSE",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              if (_formKeyRera
                                                                  .currentState!
                                                                  .validate()) {
                                                                addotherLeads(
                                                                    typeId: '6',
                                                                    type_name:
                                                                        customReraControler
                                                                            .text);
                                                              }
                                                            },
                                                            child: Container(
                                                              width: 240,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          4),
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .black,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              7)),
                                                              child: const Text(
                                                                "ADD",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                        content: StatefulBuilder(
                                                            builder: (BuildContext
                                                                    context,
                                                                StateSetter
                                                                    setState) {
                                                          return Form(
                                                            key: _formKeyRera,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          40),
                                                              width: 400,
                                                              child:
                                                                  TextFormField(
                                                                validator:
                                                                    (value) {
                                                                  if (value!
                                                                      .isNotEmpty) {
                                                                    for (int u =
                                                                            0;
                                                                        u < widget.areaRangeList!.length;
                                                                        u++) {
                                                                      if (widget
                                                                              .areaRangeList?[
                                                                                  u]
                                                                              .name
                                                                              ?.toLowerCase() ==
                                                                          customReraControler
                                                                              .text
                                                                              .toLowerCase()) {
                                                                        return "Entered Lost Reason has already exists.";
                                                                      }
                                                                    }
                                                                    // return "(From Date Cannot be Ready)"
                                                                  }
                                                                },
                                                                controller:
                                                                    customReraControler,
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        13.0),
                                                                decoration:
                                                                    const InputDecoration(
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              12.0),
                                                                  border: OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.black)),
                                                                  hintText:
                                                                      'Please Enter Remark',
                                                                  hintStyle:
                                                                      TextStyle(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            116,
                                                                            116,
                                                                            116),
                                                                    fontSize:
                                                                        13.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w200,
                                                                    fontFamily:
                                                                        'HelveticaNeue',
                                                                  ),
                                                                  // suffixIcon: Icon(
                                                                  //   Icons.calendar_month_outlined,
                                                                  // ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }));
                                                  });
                                            },
                                            child: Container(
                                              width: 240,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(7)),
                                              child: const Text(
                                                "ADD CUSTOM",
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
                                            },
                                            child: Container(
                                              width: 240,
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
                                        content: StatefulBuilder(builder:
                                            (BuildContext context,
                                                StateSetter setState) {
                                          return SizedBox(
                                            height: 340,
                                            width: 400,
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  for (int j = 0;
                                                      j <
                                                          widget.lostReason!
                                                              .length;
                                                      j++)
                                                    Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                              border: Border(
                                                                  bottom:
                                                                      BorderSide(
                                                        color: Colors.grey,
                                                      ))),
                                                      child:
                                                          RadioListTile<String>(
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        title: Text(
                                                          widget.lostReason?[j]
                                                                  .name ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        value: widget
                                                                .lostReason?[j]
                                                                .id ??
                                                            '',
                                                        groupValue:
                                                            selectedLostReason,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            selectedLostReason =
                                                                value ?? '';
                                                            lostReasonControler
                                                                .text = widget
                                                                    .lostReason?[
                                                                        j]
                                                                    .name ??
                                                                '';
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        controlAffinity:
                                                            ListTileControlAffinity
                                                                .trailing,
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
                              width: MediaQuery.of(context).size.width * 0.74,
                              child: TextFormField(
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 13.0),
                                enabled: false,
                                readOnly: true,
                                // maxLength: maxLength,
                                // inputFormatters: inputFormatters,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "(Lost Reason Cannot Be Empty)";
                                  }
                                },
                                // maxLines: maxLines,
                                controller: lostReasonControler,
                                decoration: const InputDecoration(
                                    suffixIcon: Icon(
                                      Icons.keyboard_arrow_down_outlined,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.grey,
                                    )),
                                    errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.red,
                                    )),
                                    contentPadding: EdgeInsets.all(15.0),
                                    hintStyle: TextStyle(
                                      color: Color.fromARGB(255, 116, 116, 116),
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w200,
                                      fontFamily: 'HelveticaNeue',
                                    ),
                                    hintText: 'Select Lost Reason',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(7.0)))),
                              ),
                            ),
                            // Container(
                            //   decoration: BoxDecoration(
                            //       border: Border.all(
                            //         color: Colors.grey,
                            //       ),
                            //       borderRadius: const BorderRadius.all(
                            //           Radius.circular(7.0))),
                            //   width: MediaQuery.of(context).size.width * 0.74,
                            //   height: 44,
                            //   child: TextField(
                            //     enabled: false,
                            //     readOnly: true,
                            //     controller: brokerControler,
                            //     style: const TextStyle(
                            //         color: Colors.black, fontSize: 15.0),
                            //     decoration: const InputDecoration(
                            //         contentPadding: EdgeInsets.all(12.0),
                            //         border: InputBorder.none,
                            //         hintText: 'Select Broker',
                            //         suffixIcon: Icon(
                            //           Icons.keyboard_arrow_down_outlined,
                            //         )),
                            //   ),
                            // ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 60),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w200,
                                  fontFamily: 'HelveticaNeue'),
                              children: [
                                TextSpan(
                                  text: "Interest ",
                                ),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                      title: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                        ),
                                        child: const Text(
                                          "Select Interest",
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
                                            width: 440,
                                            padding: const EdgeInsets.symmetric(
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
                                      content: StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return SizedBox(
                                          height: 240,
                                          width: 400,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                for (int j = 0;
                                                    j <
                                                        widget.intrestFilters!
                                                            .length;
                                                    j++)
                                                  Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                            border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                      color: Colors.grey,
                                                    ))),
                                                    child:
                                                        RadioListTile<String>(
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      title: Text(
                                                        widget.intrestFilters?[j]
                                                                .name ??
                                                            '',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      value: widget
                                                              .intrestFilters?[
                                                                  j]
                                                              .id ??
                                                          '',
                                                      groupValue:
                                                          selectedInterest,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedInterest =
                                                              value ?? '';
                                                          interestControler
                                                              .text = widget
                                                                  .intrestFilters?[
                                                                      j]
                                                                  .name ??
                                                              '';
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      controlAffinity:
                                                          ListTileControlAffinity
                                                              .trailing,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }));
                                });
                          },
                          child:
                              // Container(
                              //   width: MediaQuery.of(context).size.width * 0.74,
                              //   decoration: BoxDecoration(
                              //       border: Border.all(
                              //         color: Colors.grey,
                              //       ),
                              //       borderRadius: const BorderRadius.all(
                              //           Radius.circular(7.0))),
                              //   height: 44,
                              //   child: TextFormField(
                              //     validator: (value) {
                              //       if (value!.isEmpty) {
                              //         return "(Interest Cannot Be Empty)";
                              //       }
                              //     },
                              //     enabled: false,
                              //     readOnly: true,
                              //     controller: interestControler,
                              //     style: const TextStyle(
                              //         color: Colors.black, fontSize: 15.0),
                              //     decoration: const InputDecoration(
                              //         contentPadding: EdgeInsets.all(12.0),
                              //         border: InputBorder.none,
                              //         hintText: 'Select Interest',
                              //         suffixIcon: Icon(
                              //           Icons.keyboard_arrow_down_outlined,
                              //         )),
                              //   ),
                              // ),
                              SizedBox(
                            width: MediaQuery.of(context).size.width * 0.74,
                            child: TextFormField(
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 13.0),
                              enabled: false,
                              readOnly: true,
                              // maxLength: maxLength,
                              // inputFormatters: inputFormatters,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "(Interest Cannot Be Empty)";
                                }
                              },
                              // maxLines: maxLines,
                              controller: interestControler,
                              decoration: const InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.grey,
                                  )),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.red,
                                  )),
                                  contentPadding: EdgeInsets.all(15.0),
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 116, 116, 116),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'HelveticaNeue',
                                  ),
                                  hintText: 'Select Interest',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(7.0)))),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // SizedBox(height: 20),
                    if (widget.brokerList?.length != 0)
                      const SizedBox(height: 20),
                    if (widget.brokerList?.length != 0)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 60),
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: const Text(
                              'Select CP',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'HelveticaNeue'),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                // filteredBroker();
                                searchTextBroker = "";
                                searchController.clear();
                              });
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
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16),
                                        title: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                          ),
                                          child: const Text(
                                            "Channel Partner's",
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
                                              width: 440,
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
                                        content: StatefulBuilder(builder:
                                            (BuildContext context,
                                                StateSetter setState) {
                                          return SizedBox(
                                            height: 340,
                                            width: 400,
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  const SizedBox(height: 10),
                                                  SizedBox(
                                                    height: 36,
                                                    child: TextField(
                                                      onChanged: (value) {
                                                        setState(() {
                                                          // filteredProjects();
                                                          searchTextBroker =
                                                              value;
                                                        });
                                                      },
                                                      style: const TextStyle(
                                                          fontSize: 13),
                                                      controller:
                                                          searchController,
                                                      decoration:
                                                          InputDecoration(
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      12.0),
                                                              labelText:
                                                                  "Search by Name",
                                                              hintText:
                                                                  "Search by Name",
                                                              prefixIcon:
                                                                  const Icon(Icons
                                                                      .search),
                                                              suffixIcon: searchController
                                                                          .text
                                                                          .length >
                                                                      0
                                                                  ? InkWell(
                                                                      onTap:
                                                                          () {
                                                                        searchController
                                                                            .clear();
                                                                        setState(
                                                                            () {
                                                                          // filteredBroker();
                                                                          searchTextBroker =
                                                                              "";
                                                                        });
                                                                        filteredBroker();
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                12),
                                                                        child: const Icon(
                                                                            Icons.close_rounded),
                                                                      ),
                                                                    )
                                                                  : const SizedBox
                                                                      .shrink(),
                                                              border: const OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              25.0)))),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  for (int j = 0;
                                                      j <
                                                          filteredBroker()!
                                                              .length;
                                                      j++)
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          if (selectedBroker ==
                                                              filteredBroker()?[
                                                                      j]
                                                                  .brokerId) {
                                                            selectedBroker = '';
                                                            brokerControler
                                                                .clear();
                                                          } else {
                                                            selectedBroker =
                                                                filteredBroker()?[
                                                                            j]
                                                                        .brokerId ??
                                                                    '';

                                                            brokerControler
                                                                    .text =
                                                                filteredBroker()?[
                                                                            j]
                                                                        .companyName ??
                                                                    '';
                                                          }
                                                        });
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 7),
                                                        decoration:
                                                            const BoxDecoration(
                                                                border: Border(
                                                                    bottom:
                                                                        BorderSide(
                                                          color: Colors.grey,
                                                        ))),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              filteredBroker()?[
                                                                          j]
                                                                      .companyName ??
                                                                  '',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                            ),
                                                            const Spacer(),
                                                            Icon(
                                                              selectedBroker ==
                                                                      filteredBroker()?[
                                                                              j]
                                                                          .brokerId
                                                                  ? Icons
                                                                      .check_circle_outline
                                                                  : Icons
                                                                      .circle_outlined,
                                                              color: selectedBroker ==
                                                                      filteredBroker()?[
                                                                              j]
                                                                          .brokerId
                                                                  ? Colors.green
                                                                  : Colors.grey,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  // Container(
                                                  //   decoration:
                                                  //       const BoxDecoration(
                                                  //           border: Border(
                                                  //               bottom:
                                                  //                   BorderSide(
                                                  //     color: Colors.grey,
                                                  //   ))),
                                                  //   child:
                                                  //       RadioListTile<String>(
                                                  //     contentPadding:
                                                  //         EdgeInsets.zero,
                                                  //     title: Text(
                                                  // filteredBroker()?[j]
                                                  //         .companyName ??
                                                  //     '',
                                                  //       style:
                                                  //           const TextStyle(
                                                  //         fontSize: 16,
                                                  //       ),
                                                  //     ),
                                                  //     value: widget
                                                  //             .brokerList?[j]
                                                  //             .brokerId ??
                                                  //         '',
                                                  //     groupValue:
                                                  //         selectedBroker,
                                                  //     onChanged: (value) {
                                                  //       setState(() {
                                                  //         selectedBroker =
                                                  //             value ?? '';
                                                  //         brokerControler
                                                  //             .text = widget
                                                  //                 .brokerList?[
                                                  //                     j]
                                                  //                 .companyName ??
                                                  //             '';
                                                  //       });
                                                  //       Navigator.of(context)
                                                  //           .pop();
                                                  //     },
                                                  //     controlAffinity:
                                                  //         ListTileControlAffinity
                                                  //             .trailing,
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }));
                                  });
                            },
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.74,
                              child: TextFormField(
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 13.0),
                                enabled: false,
                                readOnly: true,
                                // maxLength: maxLength,
                                // inputFormatters: inputFormatters,
                                // validator: (value) {
                                //   if (value!.isEmpty) {
                                //     return "(Broker Cannot Be Empty)";
                                //   }
                                // },
                                // maxLines: maxLines,
                                controller: brokerControler,
                                decoration: const InputDecoration(
                                    suffixIcon: Icon(
                                      Icons.keyboard_arrow_down_outlined,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.grey,
                                    )),
                                    errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.red,
                                    )),
                                    contentPadding: EdgeInsets.all(15.0),
                                    hintStyle: TextStyle(
                                      color: Color.fromARGB(255, 116, 116, 116),
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w200,
                                      fontFamily: 'HelveticaNeue',
                                    ),
                                    hintText: 'Select CP',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(7.0)))),
                              ),
                            ),
                            // Container(
                            //   decoration: BoxDecoration(
                            //       border: Border.all(
                            //         color: Colors.grey,
                            //       ),
                            //       borderRadius: const BorderRadius.all(
                            //           Radius.circular(7.0))),
                            //   width: MediaQuery.of(context).size.width * 0.74,
                            //   height: 44,
                            //   child: TextField(
                            //     enabled: false,
                            //     readOnly: true,
                            //     controller: brokerControler,
                            //     style: const TextStyle(
                            //         color: Colors.black, fontSize: 15.0),
                            //     decoration: const InputDecoration(
                            //         contentPadding: EdgeInsets.all(12.0),
                            //         border: InputBorder.none,
                            //         hintText: 'Select Broker',
                            //         suffixIcon: Icon(
                            //           Icons.keyboard_arrow_down_outlined,
                            //         )),
                            //   ),
                            // ),
                          ),
                        ],
                      ),
                    if (widget.dataEditBool == true) const SizedBox(height: 20),
                    if (widget.dataEditBool == true)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 60),
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: const Text(
                              "Revisit Date",
                              // widget.dataEdit?.mstSalesLeadId ?? '',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'HelveticaNeue'),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              selectRevisitDatePopUp(
                                context: context,
                              );
                            },
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.74,
                              child: SizedBox(
                                height: 44,
                                child: TextField(
                                  enabled: false,
                                  readOnly: true,
                                  controller: controllerRevisitdate,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 15.0),
                                  decoration: const InputDecoration(
                                      hintStyle: TextStyle(
                                        color:
                                            Color.fromARGB(255, 116, 116, 116),
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w200,
                                        fontFamily: 'HelveticaNeue',
                                      ),
                                      hintText: "Select Revisit Date",
                                      contentPadding: EdgeInsets.all(12.0),
                                      border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black)),
                                      suffixIcon: Icon(
                                        Icons.date_range,
                                      )),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (widget.dataEditBool == true) const SizedBox(height: 20),
                    if (widget.dataEditBool == true)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 60),
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: const Text(
                              "Assign To",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'HelveticaNeue'),
                            ),
                          ),
                          // horizontalSpaceMedium,
                          // const Center(
                          //     child: Icon(Icons.remove, color: Colors.black54)),
                          // horizontalSpaceLarge,
                          InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                        // titlePadding: EdgeInsets.zero,
                                        // title: Container(
                                        //   padding: const EdgeInsets.symmetric(
                                        //       vertical: 8),
                                        //   decoration: const BoxDecoration(
                                        //     color: Colors.black,
                                        //   ),
                                        //   child: const Text(
                                        //     "Lead Assign To",
                                        //     style: TextStyle(
                                        //       color: Colors.white,
                                        //     ),
                                        //     textAlign: TextAlign.center,
                                        //   ),
                                        // ),
                                        // actions: <Widget>[
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8), // Set radius to zero
                                        ),
                                        elevation: 0,
                                        titlePadding: EdgeInsets.zero,
                                        actionsPadding: const EdgeInsets.only(
                                            bottom: 10, left: 10, right: 10),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16),
                                        title: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                          ),
                                          child: const Text(
                                            "Lead Assign To",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                minimumSize:
                                                    const Size.fromHeight(50),
                                                backgroundColor: Colors.black,
                                                fixedSize:
                                                    const Size.fromWidth(100),
                                                padding:
                                                    const EdgeInsets.all(10),
                                                textStyle: const TextStyle(
                                                    color: Colors.white)),
                                            child: const Text('CLOSE',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 14.0,
                                                    color: Colors.white)),
                                            onPressed: () {
                                              setState(() {
                                                Navigator.pop(context);
                                              });
                                            },
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
                                                  for (int i = 0;
                                                      i <
                                                          widget.assingUserList!
                                                              .length;
                                                      i++)
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          if (selectedAssignTo ==
                                                              widget
                                                                  .assingUserList?[
                                                                      i]
                                                                  .transEmpId) {
                                                            selectedAssignTo =
                                                                '0';
                                                            assignToContoller
                                                                .clear();
                                                          } else {
                                                            selectedAssignTo = widget
                                                                    .assingUserList?[
                                                                        i]
                                                                    .transEmpId ??
                                                                '';
                                                            assignToContoller
                                                                .text = widget
                                                                    .assingUserList?[
                                                                        i]
                                                                    .transEmpName ??
                                                                '';
                                                          }
                                                          // Navigator.of(context)
                                                          //     .pop();
                                                        });
                                                      },
                                                      child: Container(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              vertical: 7),
                                                          decoration: const BoxDecoration(
                                                              border: Border(
                                                                  bottom: BorderSide(
                                                                      color: Colors
                                                                          .grey))),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                widget.assingUserList?[i]
                                                                        .transEmpName ??
                                                                    '',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 20,
                                                                ),
                                                              ),
                                                              const Spacer(),
                                                              Icon(
                                                                selectedAssignTo ==
                                                                        widget
                                                                            .assingUserList?[
                                                                                i]
                                                                            .transEmpId
                                                                    ? Icons
                                                                        .check_circle_outline
                                                                    : Icons
                                                                        .circle_outlined,
                                                                color: selectedAssignTo ==
                                                                        widget
                                                                            .assingUserList?[
                                                                                i]
                                                                            .transEmpId
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .grey,
                                                              )
                                                            ],
                                                          )
                                                          //     RadioListTile<String>(
                                                          //   contentPadding:
                                                          //       EdgeInsets.zero,
                                                          //   title: Text(
                                                          //     widget.assingUserList?[i]
                                                          //             .transEmpName ??
                                                          //         '',
                                                          //     style:
                                                          //         const TextStyle(
                                                          //       fontSize: 20,
                                                          //     ),
                                                          //   ),
                                                          //   value:
                                                          // widget
                                                          //           .assingUserList?[
                                                          //               i]
                                                          //           .transEmpId ??
                                                          //       '',
                                                          //   groupValue:
                                                          //       selectedAssignTo,
                                                          //   onChanged: (value) {
                                                          //     setState(() {
                                                          //       selectedAssignTo =
                                                          //           value ?? '';
                                                          //       assignToContoller
                                                          //           .text = widget
                                                          //               .assingUserList?[
                                                          //                   i]
                                                          //               .transEmpName ??
                                                          //           '';
                                                          //     });
                                                          //     Navigator.of(context)
                                                          //         .pop();
                                                          //   },
                                                          //   controlAffinity:
                                                          //       ListTileControlAffinity
                                                          //           .trailing,
                                                          // ),
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
                              width: MediaQuery.of(context).size.width * 0.74,
                              child: SizedBox(
                                height: 44,
                                child: TextField(
                                  enabled: false,
                                  readOnly: true,
                                  controller: assignToContoller,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 15.0),
                                  decoration: const InputDecoration(
                                      hintStyle: TextStyle(
                                        color:
                                            Color.fromARGB(255, 116, 116, 116),
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w200,
                                        fontFamily: 'HelveticaNeue',
                                      ),
                                      hintText: "Select Assign To",
                                      contentPadding: EdgeInsets.all(12.0),
                                      border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black)),
                                      suffixIcon: Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                      )),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 60),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: const Text(
                            "Src. Manager",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'HelveticaNeue'),
                          ),
                        ),
                        // horizontalSpaceMedium,
                        // const Center(
                        //     child: Icon(Icons.remove, color: Colors.black54)),
                        // horizontalSpaceLarge,
                        InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                      // titlePadding: EdgeInsets.zero,
                                      // title: Container(
                                      //   padding: const EdgeInsets.symmetric(
                                      //       vertical: 8),
                                      //   decoration: const BoxDecoration(
                                      //     color: Colors.black,
                                      //   ),
                                      //   child: const Text(
                                      //     "Lead Assign To",
                                      //     style: TextStyle(
                                      //       color: Colors.white,
                                      //     ),
                                      //     textAlign: TextAlign.center,
                                      //   ),
                                      // ),
                                      // actions: <Widget>[
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8), // Set radius to zero
                                      ),
                                      elevation: 0,
                                      titlePadding: EdgeInsets.zero,
                                      actionsPadding: const EdgeInsets.only(
                                          bottom: 10, left: 10, right: 10),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                      title: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                        ),
                                        child: const Text(
                                          "Lead Source Manager",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              minimumSize:
                                                  const Size.fromHeight(50),
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
                                      content: StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return SizedBox(
                                          height: 340,
                                          width: 400,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                for (int i = 0;
                                                    i <
                                                        widget.assingUserList!
                                                            .length;
                                                    i++)
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (selectedSourceManager ==
                                                            widget
                                                                .assingUserList?[
                                                                    i]
                                                                .transEmpId) {
                                                          selectedSourceManager =
                                                              '0';
                                                          sourceManagerContoller
                                                              .clear();
                                                        } else {
                                                          selectedSourceManager = widget
                                                                  .assingUserList?[
                                                                      i]
                                                                  .transEmpId ??
                                                              '';
                                                          sourceManagerContoller
                                                              .text = widget
                                                                  .assingUserList?[
                                                                      i]
                                                                  .transEmpName ??
                                                              '';
                                                        }
                                                        // Navigator.of(context)
                                                        //     .pop();
                                                      });
                                                    },
                                                    child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 7),
                                                        decoration: const BoxDecoration(
                                                            border: Border(
                                                                bottom: BorderSide(
                                                                    color: Colors
                                                                        .grey))),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              widget.assingUserList?[i]
                                                                      .transEmpName ??
                                                                  '',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 20,
                                                              ),
                                                            ),
                                                            const Spacer(),
                                                            Icon(
                                                              selectedSourceManager ==
                                                                      widget
                                                                          .assingUserList?[
                                                                              i]
                                                                          .transEmpId
                                                                  ? Icons
                                                                      .check_circle_outline
                                                                  : Icons
                                                                      .circle_outlined,
                                                              color: selectedSourceManager ==
                                                                      widget
                                                                          .assingUserList?[
                                                                              i]
                                                                          .transEmpId
                                                                  ? Colors.green
                                                                  : Colors.grey,
                                                            )
                                                          ],
                                                        )
                                                        //     RadioListTile<String>(
                                                        //   contentPadding:
                                                        //       EdgeInsets.zero,
                                                        //   title: Text(
                                                        //     widget.assingUserList?[i]
                                                        //             .transEmpName ??
                                                        //         '',
                                                        //     style:
                                                        //         const TextStyle(
                                                        //       fontSize: 20,
                                                        //     ),
                                                        //   ),
                                                        //   value:
                                                        // widget
                                                        //           .assingUserList?[
                                                        //               i]
                                                        //           .transEmpId ??
                                                        //       '',
                                                        //   groupValue:
                                                        //       selectedAssignTo,
                                                        //   onChanged: (value) {
                                                        //     setState(() {
                                                        //       selectedAssignTo =
                                                        //           value ?? '';
                                                        //       assignToContoller
                                                        //           .text = widget
                                                        //               .assingUserList?[
                                                        //                   i]
                                                        //               .transEmpName ??
                                                        //           '';
                                                        //     });
                                                        //     Navigator.of(context)
                                                        //         .pop();
                                                        //   },
                                                        //   controlAffinity:
                                                        //       ListTileControlAffinity
                                                        //           .trailing,
                                                        // ),
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
                            width: MediaQuery.of(context).size.width * 0.74,
                            child: SizedBox(
                              height: 44,
                              child: TextField(
                                enabled: false,
                                readOnly: true,
                                controller: sourceManagerContoller,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 15.0),
                                decoration: const InputDecoration(
                                    hintStyle: TextStyle(
                                      color: Color.fromARGB(255, 116, 116, 116),
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w200,
                                      fontFamily: 'HelveticaNeue',
                                    ),
                                    hintText: "Select Source Manager",
                                    contentPadding: EdgeInsets.all(12.0),
                                    border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black)),
                                    suffixIcon: Icon(
                                      Icons.keyboard_arrow_down_outlined,
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 60),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: const Text(
                            "Closing Manager",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'HelveticaNeue'),
                          ),
                        ),
                        // horizontalSpaceMedium,
                        // const Center(
                        //     child: Icon(Icons.remove, color: Colors.black54)),
                        // horizontalSpaceLarge,
                        InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                      // titlePadding: EdgeInsets.zero,
                                      // title: Container(
                                      //   padding: const EdgeInsets.symmetric(
                                      //       vertical: 8),
                                      //   decoration: const BoxDecoration(
                                      //     color: Colors.black,
                                      //   ),
                                      //   child: const Text(
                                      //     "Lead Assign To",
                                      //     style: TextStyle(
                                      //       color: Colors.white,
                                      //     ),
                                      //     textAlign: TextAlign.center,
                                      //   ),
                                      // ),
                                      // actions: <Widget>[
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8), // Set radius to zero
                                      ),
                                      elevation: 0,
                                      titlePadding: EdgeInsets.zero,
                                      actionsPadding: const EdgeInsets.only(
                                          bottom: 10, left: 10, right: 10),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                      title: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                        ),
                                        child: const Text(
                                          "Closing Manager",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              minimumSize:
                                                  const Size.fromHeight(50),
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
                                      content: StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return SizedBox(
                                          height: 340,
                                          width: 400,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                for (int i = 0;
                                                    i <
                                                        widget.assingUserList!
                                                            .length;
                                                    i++)
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (closingManagerContoller ==
                                                            widget
                                                                .assingUserList?[
                                                                    i]
                                                                .transEmpId) {
                                                          selectedClosingManager =
                                                              '0';
                                                          closingManagerContoller
                                                              .clear();
                                                        } else {
                                                          selectedClosingManager = widget
                                                                  .assingUserList?[
                                                                      i]
                                                                  .transEmpId ??
                                                              '';
                                                          closingManagerContoller
                                                              .text = widget
                                                                  .assingUserList?[
                                                                      i]
                                                                  .transEmpName ??
                                                              '';
                                                        }
                                                        // Navigator.of(context)
                                                        //     .pop();
                                                      });
                                                    },
                                                    child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 7),
                                                        decoration: const BoxDecoration(
                                                            border: Border(
                                                                bottom: BorderSide(
                                                                    color: Colors
                                                                        .grey))),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              widget.assingUserList?[i]
                                                                      .transEmpName ??
                                                                  '',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 20,
                                                              ),
                                                            ),
                                                            const Spacer(),
                                                            Icon(
                                                              selectedClosingManager ==
                                                                      widget
                                                                          .assingUserList?[
                                                                              i]
                                                                          .transEmpId
                                                                  ? Icons
                                                                      .check_circle_outline
                                                                  : Icons
                                                                      .circle_outlined,
                                                              color: selectedClosingManager ==
                                                                      widget
                                                                          .assingUserList?[
                                                                              i]
                                                                          .transEmpId
                                                                  ? Colors.green
                                                                  : Colors.grey,
                                                            )
                                                          ],
                                                        )
                                                        //     RadioListTile<String>(
                                                        //   contentPadding:
                                                        //       EdgeInsets.zero,
                                                        //   title: Text(
                                                        //     widget.assingUserList?[i]
                                                        //             .transEmpName ??
                                                        //         '',
                                                        //     style:
                                                        //         const TextStyle(
                                                        //       fontSize: 20,
                                                        //     ),
                                                        //   ),
                                                        //   value:
                                                        // widget
                                                        //           .assingUserList?[
                                                        //               i]
                                                        //           .transEmpId ??
                                                        //       '',
                                                        //   groupValue:
                                                        //       selectedAssignTo,
                                                        //   onChanged: (value) {
                                                        //     setState(() {
                                                        //       selectedAssignTo =
                                                        //           value ?? '';
                                                        //       assignToContoller
                                                        //           .text = widget
                                                        //               .assingUserList?[
                                                        //                   i]
                                                        //               .transEmpName ??
                                                        //           '';
                                                        //     });
                                                        //     Navigator.of(context)
                                                        //         .pop();
                                                        //   },
                                                        //   controlAffinity:
                                                        //       ListTileControlAffinity
                                                        //           .trailing,
                                                        // ),
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
                            width: MediaQuery.of(context).size.width * 0.74,
                            child: SizedBox(
                              height: 44,
                              child: TextField(
                                enabled: false,
                                readOnly: true,
                                controller: closingManagerContoller,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 15.0),
                                decoration: const InputDecoration(
                                    hintStyle: TextStyle(
                                      color: Color.fromARGB(255, 116, 116, 116),
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w200,
                                      fontFamily: 'HelveticaNeue',
                                    ),
                                    hintText: "Select Closing Manager",
                                    contentPadding: EdgeInsets.all(12.0),
                                    border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black)),
                                    suffixIcon: Icon(
                                      Icons.keyboard_arrow_down_outlined,
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (widget.dataEditBool == true) const SizedBox(height: 20),
                    if (widget.dataEditBool == true)
                      textAndInput(
                        controllerText: updateControler,
                        title: "Remark ",
                        isRequired: true,
                        hintText: '',
                        maxLines: 3,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "(Remark Cannot Be Empty)";
                          }
                        },
                      ),
                    if (widget.dataEditBool == true) const SizedBox(height: 20),
                    if (widget.dataEditBool == true)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 60),
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: const Text(
                              'Notify On',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'HelveticaNeue'),
                            ),
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.74,
                              child: Row(
                                children: [
                                  Checkbox(
                                    // checkColor: Colors.black,
                                    // fillColor:
                                    //     MaterialStateProperty.resolveWith(getColor),
                                    value: isChecked,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        isChecked = value!;
                                      });
                                    },
                                  ),
                                  if (isChecked)
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.71,
                                      child: InkWell(
                                        onTap: () {
                                          selectEndDatePopUp(
                                            context: context,
                                          );
                                        },
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "(Notify Cannot Be Empty)";
                                            }
                                          },
                                          enabled: false,
                                          readOnly: true,
                                          // maxLength: maxLength,
                                          // inputFormatters: inputFormatters,
                                          // validator: validator,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 13.0),
                                          controller: controllerdate,
                                          decoration: const InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                color: Colors.grey,
                                              )),
                                              errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                color: Colors.red,
                                              )),
                                              contentPadding:
                                                  EdgeInsets.all(15.0),
                                              hintText: 'Select Notify Date',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              7.0)))),
                                        ),
                                      ),
                                    )
                                ],
                              )),
                        ],
                      ),
                    const SizedBox(height: 20),

                    selectDateExcavation(),

                    if (widget.dataEditBool == true) const SizedBox(height: 20),
                    // widget.dataEditBool == true ? "ADD LEAD" : 'EDIT LEAD',
                    if (widget.dataEditBool == false) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.only(left: 60),
                        width: double.maxFinite,
                        child: const Text(
                          "Bank Details",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      textAndInput(
                        controllerText: bankNameControler,
                        // isRequired: true,
                        title: "Bank Name ",
                        hintText: 'Enter Bank Name',
                        // validator: (value) {
                        //   if (value!.isEmpty) {
                        //     return "(Buyer Name Cannot Be Empty)";
                        //   }
                        // },
                      ),
                      const SizedBox(height: 20),
                      textAndInput(
                        controllerText: accountHolderControler,
                        // isRequired: true,
                        title: "Account Holder ",
                        hintText: 'Enter Account Holder',
                        // validator: (value) {
                        //   if (value!.isEmpty) {
                        //     return "(Buyer Name Cannot Be Empty)";
                        //   }
                        // },
                      ),
                      const SizedBox(height: 20),
                      textAndInput(
                        controllerText: accountNoControler,
                        // isRequired: true,
                        title: "Account No. ",
                        hintText: 'Enter Account No.',
                        // validator: (value) {
                        //   if (value!.isEmpty) {
                        //     return "(Buyer Name Cannot Be Empty)";
                        //   }
                        // },
                      ),
                      const SizedBox(height: 20),
                      textAndInput(
                        controllerText: ifscCodeControler,
                        // isRequired: true,
                        title: "IFSC Code ",
                        hintText: 'Enter IFSC Code',
                        // validator: (value) {
                        //   if (value!.isEmpty) {
                        //     return "(Buyer Name Cannot Be Empty)";
                        //   }
                        // },
                      ),
                      const SizedBox(height: 20),
                      textAndInput(
                        controllerText: branchNameControler,
                        // isRequired: true,
                        title: "Branch Name ",
                        hintText: 'Enter Branch Name',
                        // validator: (value) {
                        //   if (value!.isEmpty) {
                        //     return "(Buyer Name Cannot Be Empty)";
                        //   }
                        // },
                      ),
                    ]
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget selectDateExcavation() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 60),
          width: MediaQuery.of(context).size.width * 0.2,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Date',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        // horizontalSpaceSmall,
        Container(
          width: MediaQuery.of(context).size.width * 0.74,
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(5.0))),
          child: InkWell(
            onTap: () {
              _selectExcavationDate(context);
            },
            child: TextFormField(
              enabled: false,
              controller: _selectDateExcavationController,
              style: const TextStyle(color: Colors.black, fontSize: 15.0),
              decoration: const InputDecoration(
                suffixIcon: Icon(
                  Icons.calendar_month_outlined,
                ),
                contentPadding: EdgeInsets.all(9.0),
                border: InputBorder.none,
                hintText: 'Please Select Date',
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buyersType() {
    return Container(
      padding: const EdgeInsets.only(left: 60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 13),
            width: MediaQuery.of(context).size.width * 0.16,
            height: 40.0,
            // child: Padding(
            //   padding: EdgeInsets.only(top: 15.0),
            //   child: Text('Owner Type',
            //       style: TextStyle(fontSize: 15, color: Colors.black)),
            // ),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'HelveticaNeue'),
                children: [
                  TextSpan(
                    text: 'Owner Type',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'HelveticaNeue'),
                  ),
                ],
              ),
            ),
          ),
          // horizontalSpaceSmall,
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
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _fundingType() {
    return Container(
      padding: const EdgeInsets.only(left: 60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 13),
            width: MediaQuery.of(context).size.width * 0.16,
            height: 40.0,
            // child: Padding(
            //   padding: EdgeInsets.only(top: 15.0),
            //   child: Text('Funding Type',
            //       style: TextStyle(fontSize: 15, color: Colors.black)),
            // ),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'HelveticaNeue'),
                children: [
                  TextSpan(
                    text: 'Funding Type',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'HelveticaNeue'),
                  ),
                ],
              ),
            ),
          ),
          // horizontalSpaceSmall,
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
      ),
    );
  }

  Widget textAndInput({
    required TextEditingController controllerText,
    required String title,
    required String hintText,
    final FormFieldValidator<String>? validator,
    final List<TextInputFormatter>? inputFormatters,
    final int? maxLength,
    int maxLines = 1,
    bool isRequired = false,
    ValueChanged<String>? onChanged,
  }) {
    return Row(
      children: [
        // Container(
        //   padding: const EdgeInsets.only(left: 60),
        //   width: MediaQuery.of(context).size.width * 0.2,
        //   child: Text(
        //     title,
        //     style: const TextStyle(
        //       fontSize: 16,
        //     ),
        //   ),
        // ),
        Container(
          padding: const EdgeInsets.only(left: 60),
          width: MediaQuery.of(context).size.width * 0.2,
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'HelveticaNeue'),
              children: [
                TextSpan(
                  text: title,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'HelveticaNeue'),
                ),
                if (isRequired == true)
                  const TextSpan(
                    text: "*", // The asterisk
                    style: TextStyle(
                      color: Colors.red, // Color for the asterisk
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.74,
          child: TextFormField(
            onChanged: onChanged,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            validator: validator,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 13),
            controller: controllerText,
            decoration: InputDecoration(
                hintStyle: const TextStyle(color: Colors.black45),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                  color: Colors.grey.shade300,
                )),
                errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                  color: Colors.red,
                )),
                contentPadding: const EdgeInsets.all(15.0),
                hintText: hintText,
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7.0)))),
          ),
        ),
      ],
    );
  }
}
