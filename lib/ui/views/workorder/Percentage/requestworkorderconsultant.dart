import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/views/PurchaseOrder/purchase_order_form.dart';
import 'package:stallion/ui/views/workorder/Percentage/requestwopercentage.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/get_default_workorder_create.dart';
import '../../../shared/ui_helpers.dart';
import '../../../widgets/simple_button.dart';

class RequestWorkOrderConsultant extends StatefulWidget {
  RequestWorkOrderConsultant({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.navigationFlag,
    this.consultantMagicLink,
    this.contractorMagicLink,
    this.vendMagicLink,
    this.towarName,
  });

  final String? projectId;
  final String? towarId;
  final String? towarName;
  final String? projectName;
  final String? navigationFlag;

  final String? contractorMagicLink;
  final String? vendMagicLink;
  final String? consultantMagicLink;

  @override
  State<RequestWorkOrderConsultant> createState() =>
      _RequestWorkOrderConsultantState();
}

class _RequestWorkOrderConsultantState
    extends State<RequestWorkOrderConsultant> {
  bool flagcalled = false;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  List<GradeList>? gradeList = [];
  List<GradeList>? gradeListOriginal = [];
  List<CompanyList>? companyList = [];
  List<CompanyList>? companyListOriginal = [];

  TextEditingController txtConsultantType = TextEditingController();
  TextEditingController txtConsultantCompany = TextEditingController();
  TextEditingController txtRequirementFor = TextEditingController();
  TextEditingController txtInputBU = TextEditingController();
  TextEditingController txtInputQuantity = TextEditingController();

  TextEditingController txtRate = TextEditingController();
  TextEditingController txtInputNote = TextEditingController();

  TextEditingController txtSearchConsultantType = TextEditingController();
  TextEditingController txtSearchConsultantCompany = TextEditingController();

  String? selectedConsultantType;
  String? selectedConsultantId;
  String? selectedConsultantCompany;
  String? selectedConsultantCompanyId;
  String? selectedRequirementDate;
  String? selectedGST;
  var arrayFiles = [];
  var arrayFilesBytes = [];
  bool isChecked = false;

  @override
  void initState() {
    selectedConsultantType = '';
    selectedConsultantCompany = '';
    selectedRequirementDate =
        DateFormat('dd MMM yyyy').format(DateTime.now()).toString();
    selectedGST = '0';

    super.initState();
    fetchDefaultWorkOrderCreate();
  }

  Future<ResponseWorkorderCreate?> fetchDefaultWorkOrderCreate() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    var type = '0';
    if (widget.navigationFlag! == "Consultant") {
      type = '1';
    }

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "type": type,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.getGetDefaultWoCreate, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getDefaultWorkorderCreateFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        //return dataModel.response;
        //return dataModel.response;

        setState(() {
          gradeList = dataModel.response?.gradeList;
          gradeListOriginal = dataModel.response?.gradeList;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        // foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            widget.towarName!.isNotEmpty
                ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                : widget.projectName!.toUpperCase(),
            style: const TextStyle(
                fontStyle: FontStyle.normal,
                fontSize: 17.0,
                color: Colors.white)),

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
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 280),
                      const Spacer(),
                      const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(5, 10, 5, 10),
                        child: Text(
                          ' REQUEST WORK ORDER - PERCENTAGE ',
                          style: boldText13,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () async {
                          if (widget.navigationFlag! == "Consultant") {
                            if (widget.consultantMagicLink! != "") {
                              print(widget.consultantMagicLink!);
                              final uri =
                                  Uri.parse(widget.consultantMagicLink!);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else {
                                throw 'Could not launch';
                              }
                            }
                          } else {
                            if (widget.contractorMagicLink! != "") {
                              print(widget.contractorMagicLink!);
                              final uri =
                                  Uri.parse(widget.contractorMagicLink!);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else {
                                throw 'Could not launch';
                              }
                            }
                          }
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black)),
                            child: Text(
                                widget.navigationFlag! == "Consultant"
                                    ? "INVITE CONSULTANT"
                                    : "INVITE CONTRACTOR",
                                style: const TextStyle(color: Colors.black))),
                      ),
                      const SizedBox(width: 64),
                    ],
                  ),
                  const Divider(
                      height: 1.0,
                      thickness: 0.5,
                      indent: 1.0,
                      endIndent: 1.0,
                      color: Colors.black),
                  Expanded(
                      child: Column(
                    children: [
                      Expanded(
                        child: Builder(builder: (context) {
                          return ListView.builder(
                              itemCount: 1,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10.0, left: 70.0, right: 70.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      verticalSpaceSmall15,
                                      _consultantType(),
                                      verticalSpaceSmall15,
                                      _consultantCompany(),
                                      verticalSpaceSmall15,
                                      _requirementFor(),
                                      verticalSpaceSmall15,
                                      _selectedReqDate(),
                                      verticalSpaceSmall15,
                                      _butextfield(),
                                      verticalSpaceSmall15,
                                      _ratetextfield(),
                                      verticalSpaceMedium,
                                      _addGst(),
                                      verticalSpaceSmall15,
                                      _notetextfield(),
                                      verticalSpaceSmall15,
                                      _uploadFile(),
                                    ],
                                  ),
                                );
                              });
                        }),
                      ),
                      verticalSpaceSmall,
                      Padding(
                        padding: const EdgeInsets.only(left: 70.0, right: 70.0),
                        child: SimpleButton(
                          lblText: 'NEXT',
                          color: kcPrimaryColor,
                          onTap: () {
                            if (selectedConsultantType == '') {
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
                                  desc: 'Please select consultant type.',
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
                            } else if (selectedConsultantCompany == '') {
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
                                  desc: 'Please select consultant company.',
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
                            } else if (txtRequirementFor.text == '') {
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
                                  desc: 'Please enter requirement for.',
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
                            } else if (selectedRequirementDate == '') {
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
                                  desc:
                                      'Please select estimated completion date.',
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
                            } else if (txtInputBU.text == '' &&
                                txtInputQuantity.text == '') {
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
                                  desc: 'Please enter B.U / Quantity',
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
                            } else if (txtRate.text == '') {
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
                                  desc: 'Please enter rate.',
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
                            } else {
                              var projectId = widget.projectId!;
                              var projectName = widget.projectName!;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) {
                                    return RequestWorkOrderPercentage(
                                      consultantMagicLink:
                                          widget.consultantMagicLink,
                                      contractorMagicLink:
                                          widget.contractorMagicLink,
                                      vendMagicLink: widget.vendMagicLink,
                                      projectId: projectId,
                                      towarId: widget.towarId!,
                                      projectName: projectName,
                                      selectedConsultantType:
                                          selectedConsultantId,
                                      selectedConsultantCompany:
                                          selectedConsultantCompanyId,
                                      selectedRequirementDate:
                                          selectedRequirementDate,
                                      selectedGST: selectedGST,
                                      inputBu: txtInputBU.text.isEmpty
                                          ? txtInputQuantity.text
                                          : txtInputBU.text,
                                      inputNote: txtInputNote.text,
                                      inputRate: txtRate.text,
                                      inputRequirementFor:
                                          txtRequirementFor.text,
                                      arrayFiles: arrayFiles,
                                      isBua: txtInputBU.text.isEmpty
                                          ? false
                                          : true,
                                    );
                                  },
                                ),
                              ).then((value) => {checkNavigation()});
                            }
                          },
                        ),
                      ),
                      verticalSpaceSmall,
                    ],
                  )),
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
                //  CircularProgressIndicator(),
              ),
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

  Widget _consultantType() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text(
                widget.navigationFlag! == "Consultant"
                    ? 'Consultant Type'
                    : 'Required Skill',
                style: const TextStyle(fontSize: 15, color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: InkWell(
            onTap: () {
              gradeList!.isNotEmpty
                  ? showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          surfaceTintColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Set radius to zero
                          ),
                          titlePadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          actionsPadding: const EdgeInsets.only(bottom: 10),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          actionsAlignment: MainAxisAlignment.center,
                          title: Text(
                            widget.navigationFlag == "Consultant"
                                ? "SELECT CONSULTANT TYPE"
                                : "SELECT REQUIRED SKILL",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: 500,
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
                          ],
                          content: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
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
                                          if (value.isNotEmpty) {
                                            if (value.length > 2) {
                                              var filteredList = gradeListOriginal
                                                  ?.where((element) => element
                                                      .graderName!
                                                      .toLowerCase()
                                                      .contains(
                                                          value.toLowerCase()))
                                                  .toList();
                                              setState(() {
                                                gradeList = filteredList;
                                              });
                                            }
                                          } else {
                                            setState(() {
                                              gradeList = gradeListOriginal;
                                            });
                                          }
                                        },
                                        style: const TextStyle(fontSize: 13),
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.all(12.0),
                                          labelText: widget.navigationFlag ==
                                                  "Consultant"
                                              ? "Search Consultant Type"
                                              : 'Search Required Skill',
                                          hintText: widget.navigationFlag ==
                                                  "Consultant"
                                              ? "Search Consultant Type"
                                              : 'Search Required Skill',
                                          prefixIcon: const Icon(Icons.search),
                                          border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(7.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    verticalSpaceTiny,
                                    Expanded(
                                      child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: gradeList!.length,
                                          itemBuilder: (context, int index) {
                                            return InkWell(
                                              onTap: () {
                                                txtConsultantCompany.clear();
                                                setState(() {
                                                  selectedConsultantType =
                                                      gradeList![index].gradeId;
                                                  txtConsultantType.text =
                                                      gradeList![index]
                                                          .graderName!;
                                                  selectedConsultantId =
                                                      gradeList![index]
                                                          .gradeId!;
                                                  companyList =
                                                      gradeList![index]
                                                          .companyList;
                                                  companyListOriginal =
                                                      gradeList![index]
                                                          .companyList;
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
                                                              gradeList![index]
                                                                  .graderName!,
                                                              style: normalText,
                                                            ),
                                                          ],
                                                        ),
                                                        selectedConsultantId ==
                                                                null
                                                            ? const Icon(
                                                                Icons
                                                                    .circle_outlined,
                                                                size: 25,
                                                                color:
                                                                    Colors.grey,
                                                              )
                                                            : selectedConsultantId ==
                                                                    gradeList![
                                                                            index]
                                                                        .gradeId
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
                                  ],
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
                    controller: txtConsultantType,
                    autofocus: false,
                    enabled: false,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: widget.navigationFlag == "Consultant"
                          ? 'Select Consultant Type'
                          : 'Select Required Skill',
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

  Widget _consultantCompany() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text(
                widget.navigationFlag! == "Consultant"
                    ? 'Consultant Company'
                    : 'Contractor Company',
                style: const TextStyle(fontSize: 15, color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: InkWell(
            onTap: () {
              companyList!.isNotEmpty
                  ? showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          surfaceTintColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Set radius to zero
                          ),
                          titlePadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          actionsPadding: const EdgeInsets.only(bottom: 10),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          actionsAlignment: MainAxisAlignment.center,
                          title: Text(
                            widget.navigationFlag! == "Consultant"
                                ? "SELECT CONSULTANT COMPANY"
                                : "SELECT CONTRACTOR COMPANY",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: 500,
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
                          ],
                          content: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
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
                                          if (value.isNotEmpty) {
                                            if (value.length > 2) {
                                              var filteredList =
                                                  companyListOriginal
                                                      ?.where((element) => element
                                                          .companyName!
                                                          .toLowerCase()
                                                          .contains(value
                                                              .toLowerCase()))
                                                      .toList();
                                              setState(() {
                                                companyList = filteredList;
                                              });
                                            }
                                          } else {
                                            setState(() {
                                              companyList = companyListOriginal;
                                            });
                                          }
                                        },
                                        style: const TextStyle(fontSize: 13),
                                        decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.all(12.0),
                                            labelText: widget.navigationFlag! ==
                                                    "Consultant"
                                                ? "Search Consultant Company"
                                                : 'Search Contractor Company',
                                            hintText:
                                                "Search Consultant Company",
                                            prefixIcon:
                                                const Icon(Icons.search),
                                            border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(7.0)))),
                                      ),
                                    ),
                                    verticalSpaceTiny,
                                    Expanded(
                                      child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: companyList!.length,
                                          itemBuilder: (context, int index) {
                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  selectedConsultantCompany =
                                                      companyList![index]
                                                          .companyName;
                                                  txtConsultantCompany.text =
                                                      companyList![index]
                                                          .companyName!;
                                                  selectedConsultantCompanyId =
                                                      companyList![index]
                                                          .companyId!;
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
                                                              companyList![
                                                                      index]
                                                                  .companyName!,
                                                              style: normalText,
                                                            ),
                                                          ],
                                                        ),
                                                        selectedConsultantCompanyId ==
                                                                null
                                                            ? const Icon(
                                                                Icons
                                                                    .circle_outlined,
                                                                size: 25,
                                                                color:
                                                                    Colors.grey,
                                                              )
                                                            : selectedConsultantCompanyId ==
                                                                    companyList![
                                                                            index]
                                                                        .companyId
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
                                  ],
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
                    controller: txtConsultantCompany,
                    autofocus: false,
                    enabled: false,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: widget.navigationFlag! == "Consultant"
                          ? 'Select Consultant Company'
                          : 'Select Contractor Company',
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

  Widget _requirementFor() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Requirement For',
                style: TextStyle(fontSize: 15, color: Colors.black)),
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
                controller: txtRequirementFor,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter Requirement For',
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _selectedReqDate() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Est. Completion Date ',
                style: TextStyle(fontSize: 15, color: Colors.black)),
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
                onTap: () async {
                  DateTime? newDateTime = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(DateTime.now().year + 20),
                  );

                  if (newDateTime != null) {
                    setState(() {
                      selectedRequirementDate = DateFormat('dd MMM yyyy')
                          .format(newDateTime)
                          .toString();
                    });
                  }
                },
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
                      hintText: 'Est. Completion Date'),
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

  Widget _butextfield() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('B.U. / Quantity',
                style: TextStyle(fontSize: 15.0, color: Colors.black)),
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
                controller: txtInputBU,
                // keyboardType: TextInputType.number,
                // inputFormatters: <TextInputFormatter>[
                //   FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                // ],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [DecimalTextInputFormatter(decimalPlaces: 3)],
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                onChanged: (value) {
                  txtInputQuantity.clear();
                },
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                    border: InputBorder.none,
                    hintText: 'Enter B.U.'),
              ),
            ),
          ),
        ),
        const Center(
          child: Text(' / ',
              style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w600)),
        ),
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
                controller: txtInputQuantity,
                // keyboardType: TextInputType.number,
                // inputFormatters: <TextInputFormatter>[
                //   FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                // ],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [DecimalTextInputFormatter(decimalPlaces: 3)],
                onChanged: (value) {
                  txtInputBU.clear();
                },
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                    border: InputBorder.none,
                    hintText: 'Enter Quantity'),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _ratetextfield() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Rate',
                style: TextStyle(fontSize: 15, color: Colors.black)),
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
                controller: txtRate,
                // keyboardType: TextInputType.number,
                // inputFormatters: <TextInputFormatter>[
                //   FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                // ],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [DecimalTextInputFormatter(decimalPlaces: 3)],
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                    border: InputBorder.none,
                    hintText: 'Enter Rate'),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _addGst() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
            width: 230,
            height: 40.0,
            child: Padding(
                padding: EdgeInsets.only(top: 15.0),
                child: Text('Add GST',
                    style: TextStyle(fontSize: 15, color: Colors.black)))),
        horizontalSpaceSmall,
        Transform.scale(
            scale: 2.0,
            child: Checkbox(
                checkColor: Colors.white,
                // fillColor: MaterialStateProperty.resolveWith(getColor),
                value: isChecked,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.0)),
                side: MaterialStateBorderSide.resolveWith((states) =>
                    const BorderSide(width: 0.7, color: Colors.black54)),
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value!;
                    if (value == true) {
                      selectedGST = '1';
                    } else {
                      selectedGST = '0';
                    }
                  });
                }))
      ],
    );
  }

  Widget _notetextfield() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Add Note',
                style: TextStyle(fontSize: 15, color: Colors.black)),
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
                controller: txtInputNote,
                maxLines: 4,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                    border: InputBorder.none, hintText: 'Add Note'),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _uploadFile() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230,
          height: 80.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Upload file \n(Attach Detailed Quotes)',
                style: TextStyle(fontSize: 15, color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: SizedBox(
              height: 100.0,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: arrayFiles.length + 1,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Container(
                        height: 80.0,
                        width: 100.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black54, // red as border color
                          ),
                        ),
                        child: index == 0
                            ? IconButton(
                                iconSize: 50,
                                icon: const Icon(
                                  Icons.add_circle_outlined,
                                ),
                                color: Colors.black,
                                onPressed: () async {
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: [
                                      'pdf',
                                      'jpg',
                                      'jpeg',
                                      'png'
                                    ],
                                  );
                                  if (result != null) {
                                    PlatformFile file = result.files.first;
                                    if (kDebugMode) {
                                      print("FILE SELECTED");
                                      print(file.name);
                                      print(file.bytes);
                                      print(file.size);
                                      print(file.extension);
                                      print(file.path);
                                    }

                                    Uint8List? fileBytes =
                                        result.files.first.bytes;
                                    //String fileName = result.files.first.name;
                                    setState(() {
                                      arrayFilesBytes.add(fileBytes);
                                      arrayFiles.add(file);
                                    });
                                  } else {
                                    // User canceled the picker
                                  }
                                },
                              )
                            : _imagePdf(arrayFiles[index - 1], index - 1),
                      ),
                    );
                  })),
        ),
      ],
    );
  }

  Widget _imagePdf(PlatformFile file, int index) {
    if (file.extension == 'pdf') {
      return Stack(children: [
        Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('images/projectmanagement/pdf.png'),
                    fit: BoxFit.cover))),
        Positioned(
          top: -10,
          left: 70,
          height: 30,
          width: 30,
          child: IconButton(
              onPressed: () {
                setState(() {
                  arrayFiles.removeAt(index);
                });
              },
              icon: const Icon(Icons.close, color: Colors.red)),
        ),
      ]);
    } else {
      return Stack(children: [
        Image.file(
          File(
            file.path!,
          ),
          width: 100.0,
          height: 100.0,
        ),
        Positioned(
          top: -10,
          left: 70,
          height: 30,
          width: 30,
          child: IconButton(
              onPressed: () {
                setState(() {
                  arrayFiles.removeAt(index);
                });
              },
              icon: const Icon(Icons.close, color: Colors.red)),
        ),
      ]);
    }
  }
}
