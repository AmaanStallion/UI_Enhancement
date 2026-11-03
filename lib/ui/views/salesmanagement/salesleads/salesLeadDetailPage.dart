import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:stallion/models/get_all_sales_lead.dart';
import 'package:stallion/models/sales_lead_default_filter.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/views/salesmanagement/bookasaleview.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/addSalesLeadPage.dart';
import 'package:stallion/ui/views/tenantManagement/tenant_pdf_view.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:url_launcher/url_launcher.dart';

class SalesLeadDeatilsPage extends StatefulWidget {
  final SalesLead salesLeadData;
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? navigationFlag;
  final String? towarName;
  final String? clientAccess;
  final List<AreaRangeList>? intrestFilters;
  final ResponseGetAllSalesLead? responseGetAllSalesLead;
  const SalesLeadDeatilsPage(
      {super.key,
      required this.salesLeadData,
      this.projectId,
      this.towarId,
      this.projectName,
      this.navigationFlag,
      this.towarName,
      this.responseGetAllSalesLead,
      this.clientAccess,
      required this.intrestFilters});

  @override
  State<SalesLeadDeatilsPage> createState() => _SalesLeadDeatilsState();
}

List<FlatDetail>? flatDetails = [];
List<SalesLead> salesLeadList = [];
List<AreaRangeList>? intrestFilters = [];
List<AreaRangeList>? location = [];
List<AreaRangeList>? leadStage = [];

List<AreaRangeList>? rangeList = [];
List<AreaRangeList>? sourceList = [];
List<AreaRangeList>? subSources = [];
List<AreaRangeList>? ethnicity = [];

List<String>? requirementFilter = [];
List<BrokerList>? brokerFilters = [];
List<AreaRangeList>? areaRangeList = [];
List<AssingUserList>? assingUserList = [];
List<AreaRangeList>? lostReason = [];
List<AreaRangeList>? currentOwner = [];
List<AreaRangeList>? currentConfiguration = [];
List<AreaRangeList>? campaign = [];
List<AreaRangeList>? nationality = [];

String selectedOption = "";
String selectedStatus = "";
String selectedAssignTo = '0';
TextEditingController updateController = TextEditingController();
bool isChecked = false;
DateTime? selectedEndDatePopup;
TextEditingController controllerdate = TextEditingController();

DateTime? selectedRevisitDatePopup;
TextEditingController controllerRevisitdate = TextEditingController();

List<AreaRangeList>? intrestFilter = [
  AreaRangeList(id: "0", name: "Opened"),
  AreaRangeList(id: "1", name: "Approved"),
  AreaRangeList(id: "2", name: "Cancelled"),
];

String getOrdinalSuffix(int number) {
  if (number % 10 == 1 && number % 100 != 11) {
    return 'st';
  } else if (number % 10 == 2 && number % 100 != 12) {
    return 'nd';
  } else if (number % 10 == 3 && number % 100 != 13) {
    return 'rd';
  } else {
    return 'th';
  }
}

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
NetworkHandler apiNetworkHandler = NetworkHandler();

enum Groceries { one, two, three }

class _SalesLeadDeatilsState extends State<SalesLeadDeatilsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController intrestContoller = TextEditingController();
  TextEditingController statusContoller = TextEditingController();
  TextEditingController assignToContoller = TextEditingController();

  Future<ResponseGetAllSalesLead?> updateLeadDetails() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId!,
      "lead_buyer_comment": updateController.text,
      "sales_lead_id": widget.salesLeadData.mstSalesLeadId ?? '',
      "lead_buyer_intrest": selectedOption,
      "lead_buyer_status": selectedStatus,
      'lead_notify': isChecked == true ? controllerdate.text : '',
      "assignto_id": selectedAssignTo,
      "revisit_date": controllerRevisitdate.text,
    };
    var response =
        await apiNetworkHandler.post(AppUrl.webUpdateSalesLead, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = salesLeadDefaultFilterFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        print("success");
        controllerdate.clear();
      }
    }
    return null;
  }

  // get all sales lead filter
  Future<ResponseGetAllSalesLead?> getAllSalesLeadFilter() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId!,
    };
    var response =
        await apiNetworkHandler.post(AppUrl.webGetAllSalesLeadFilter, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = salesLeadDefaultFilterFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          nationality = dataModel.response?.nationality;
          currentOwner = dataModel.response?.currentOwner;
          campaign = dataModel.response?.campaign;
          currentConfiguration = dataModel.response?.currentConfiguration;
          flatDetails = dataModel.response?.flatDetails;
          rangeList = dataModel.response?.rangeList;
          subSources = dataModel.response?.subSources;
          ethnicity = dataModel.response?.ethnicity;
          assingUserList = dataModel.response?.assingUserList;
          lostReason = dataModel.response?.lostReason;
          sourceList = dataModel.response?.sourceList;
          areaRangeList = dataModel.response?.areaRangeList;
          intrestFilters = dataModel.response?.invenster;
          location = dataModel.response?.location;
          brokerFilters = dataModel.response?.brokerList;
          leadStage = dataModel.response?.leadStage;
          requirementFilter = dataModel.response?.requirement;
          // invensterFilter = [
          //   ...?invensterFilter,
          //   ...?dataModel.response?.invenster
          // ];
        });
        //inspect(invensterFilter);
      }
    }
    return null;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    intrestContoller.clear();
    updateController.clear();
    controllerRevisitdate.clear();
    selectedOption = '';
    selectedAssignTo = '';
    selectedRevisitDatePopup = null;
    isChecked = false;
    super.dispose();
  }

  @override
  void initState() {
    intrestContoller.text = widget.salesLeadData.leadIntrested ?? '';
    controllerdate.text =
        widget.salesLeadData.details?[widget.salesLeadData.details!.length - 1]
                ['sales_notify'] ??
            '';
    if (widget.salesLeadData.details?[widget.salesLeadData.details!.length - 1]
            ['sales_notify'] !=
        "") {
      isChecked = true;
      selectedEndDatePopup = DateFormat('dd-MM-yyyy').parse(widget.salesLeadData
                  .details?[widget.salesLeadData.details!.length - 1]
              ['sales_notify'] ??
          '');
    }

    getAllSalesLeadFilter();
    statusContoller.text = "one";

    setState(() {
      selectedOption = widget.salesLeadData.leadIntrested == "Lucrative"
          ? '0'
          : widget.salesLeadData.leadIntrested == "Enquiry"
              ? '1'
              : widget.salesLeadData.leadIntrested == "Potential"
                  ? '2'
                  : "";
      selectedStatus = widget.salesLeadData.leadBuyerStatus ?? '';
      statusContoller.text =
          intrestFilter?[int.parse(widget.salesLeadData.leadBuyerStatus ?? '')]
                  .name ??
              '';
    });
    super.initState();
  }

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

  String parseDateString(String dateString) {
    List<String> parts = dateString.split("-");
    // Rearrange the parts to form a string in "yyyy-mm-dd" format
    String formattedDate = "${parts[2]}-${parts[1]}-${parts[0]}";
    return formattedDate;
  }

  @override
  Widget build(BuildContext contextMain) {
    return Scaffold(
      bottomNavigationBar: widget.salesLeadData.editFlag == "1"
          ? Row(
              children: [
                InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      updateLeadDetails();
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
                          desc: "Successfully updated a lead details",
                          alertAnimation: fadeAlertAnimation,
                          buttons: [
                            DialogButton(
                              onPressed: () => {
                                Navigator.pop(context),
                                Navigator.pop(context)
                              },
                              color: Colors.black,
                              child: const Text(
                                "CLOSE",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ]).show();

                      // Alert(
                      //     closeIcon: const SizedBox(),
                      //     padding: const EdgeInsets.only(top: 0.0),
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
                      //     desc: "Please fill update field",
                      //     alertAnimation: fadeAlertAnimation,
                      //     buttons: [
                      //       DialogButton(
                      //         onPressed: () => Navigator.pop(context),
                      //         color: Colors.black,
                      //         child: const Text(
                      //           "CLOSE",
                      //           style: TextStyle(
                      //               color: Colors.white, fontSize: 15),
                      //         ),
                      //       ),
                      //     ]).show();
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: const BoxDecoration(
                        color: Colors.black,
                        border: Border(right: BorderSide(color: Colors.white))),
                    child: const Text(
                      "UPDATE",
                      style: TextStyle(color: Colors.white, fontSize: 17),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    print(widget.salesLeadData.brokerName);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          return BookaSaleFormView(
                            emailId: widget
                                        .responseGetAllSalesLead?.maskContact ==
                                    '2'
                                ? widget.salesLeadData.leadBuyerEmail!.length >
                                        3
                                    ? "*" *
                                            (widget.salesLeadData
                                                    .leadBuyerEmail!.length -
                                                4) +
                                        widget.salesLeadData.leadBuyerEmail!
                                            .substring(widget.salesLeadData
                                                    .leadBuyerEmail!.length -
                                                4)
                                    : widget.salesLeadData.leadBuyerEmail!
                                                .length <=
                                            3
                                        ? widget.salesLeadData.leadBuyerEmail ??
                                            ''
                                        : "--"
                                : widget.salesLeadData.leadBuyerEmail ?? '',
                            buyerName: widget.salesLeadData.leadBuyerName ?? '',
                            mobileNumber:
                                widget.responseGetAllSalesLead?.maskContact ==
                                        '2'
                                    ? "*" *
                                            (widget.salesLeadData
                                                    .leadBuyerPhone!.length -
                                                4) +
                                        widget.salesLeadData.leadBuyerPhone!
                                            .substring(widget.salesLeadData
                                                    .leadBuyerPhone!.length -
                                                4)
                                    : widget.salesLeadData.leadBuyerPhone ?? '',
                            projectId: widget.projectId,
                            towarId: widget.towarId!,
                            projectName: widget.projectName,
                            flagRedirect: 'BookNewSale',
                            salesLeadData: widget.salesLeadData,
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: Colors.black,
                    child: const Text(
                      "PROCEED FOR BOOKING",
                      style: TextStyle(color: Colors.white, fontSize: 17),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )
          : const SizedBox(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          '${widget.projectName!.toUpperCase()} ${widget.towarName!.isNotEmpty ? "-" : ""} ${widget.towarName!.toUpperCase()}',
        ),
        actions: [
          if (widget.salesLeadData.editFlag == "1" &&
              widget.responseGetAllSalesLead?.maskContact != '2')
            InkWell(
              onTap: () {
                print('0000000000000000000000');

                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return AddSalesLeadPage(
                    nationality: nationality,
                    currentOwner: currentOwner,
                    campaign: campaign,
                    currentConfiguration: currentConfiguration,
                    clientAccess: widget.clientAccess ?? '',
                    dataEditBool: false,
                    dataEdit: widget.salesLeadData,
                    projectId: widget.projectId,
                    towarId: widget.towarId,
                    projectName: widget.projectName,
                    towarName: widget.towarName,

                    ethnicity: ethnicity,
                    flatDetails: flatDetails,
                    brokerList: brokerFilters,
                    requirementList: requirementFilter,
                    intrestFilters: intrestFilters,
                    // projectId: widget.projectId,
                    // towarId: widget.towarId,
                    // projectName: widget.projectName,
                    navigationFlag: widget.navigationFlag,
                    // towarName: widget.towarName,
                    rangeList: rangeList,
                    sourceList: sourceList,
                    areaRangeList: areaRangeList,
                    subSources: subSources,
                    location: location,
                    leadStage: leadStage,
                    assingUserList: assingUserList,
                    lostReason: lostReason,
                  );
                }));
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                // decoration: BoxDecoration(
                //   color: Colors.white,
                //   borderRadius: BorderRadius.circular(8),
                // ),
                child: const Center(
                  child: Text(
                    "Edit",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 50)
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black))),
              padding: EdgeInsets.symmetric(horizontal: 60, vertical: 6),
              child: Row(
                children: [
                  Spacer(),
                  Container(
                    // padding: const EdgeInsets.symmetric(vertical: 12),
                    // width: double.maxFinite,
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                      color: Colors.grey,
                    ))),
                    child: const AppText(
                      title: 'LEAD DETAILS',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      titleTextAlign: TextAlign.center,
                    ),
                  ),
                  Spacer(),
                  if (widget.salesLeadData.editFlag == "1" &&
                      widget.responseGetAllSalesLead?.maskContact != '2')
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              return TenantPdfView(
                                leadId: widget.salesLeadData.mstSalesLeadId,
                                // towarId: widget.towarId,
                                // poAssingTo: woOrderList![index]
                                //     .woAssingTo,
                                // projectId: woOrderList![index]
                                //     .projectId!,
                                // projectName: woOrderList![index]
                                //     .projectName!,
                                // workOrderId: woOrderList![index]
                                //     .woOrderId!,
                                // workOrderNo: woOrderList![index]
                                //     .woOrderNo!
                                //     .toUpperCase(),
                                // flagRedirect:
                                //     widget.flagRedirect!
                              );
                            },
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.download,
                        size: 30,
                      ),
                    ),
                ],
              ),
            ),
            _salesLeadCard(context: contextMain),
            const SizedBox(
              height: 18,
            ),
            const Divider(
              color: Colors.black,
            ),
            for (int index = 0;
                index < widget.salesLeadData.details!.length;
                index++)
              Container(
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                  color: Color.fromARGB(255, 207, 207, 207),
                ))),
                padding: const EdgeInsets.symmetric(
                  horizontal: 0,
                ),
                child: Column(
                  children: [
                    _rowTwoText(
                      context: context,
                      title:
                          '${index + 1}${getOrdinalSuffix(index + 1)} Update',
                      titleValue: widget.salesLeadData.details?[index]
                              ['sales_lead_comment'] ??
                          '',
                      isStatus: false,
                    ),
                    _rowThreeText(
                      title: "Dated On",
                      titleValue: widget.salesLeadData.details?[index]
                              ['trans_lead_updated_at'] ??
                          '',
                      subTitleValue: widget.salesLeadData.details?[index]
                              ['approved_user'] ??
                          '',
                    ),
                    // if (widget.salesLeadData.details?[index]['sales_notify'] !=
                    //     "")
                    _rowThreeText(
                      title: "Notify On",
                      titleValue: widget.salesLeadData.details?[index]
                              ['sales_notify'] ??
                          '',
                      subTitleValue: '',
                      textColor: widget.salesLeadData.details?[index]
                                  ['sales_notify'] !=
                              ""
                          ? DateTime.parse(parseDateString(widget.salesLeadData
                                          .details?[index]['sales_notify'] ??
                                      ''))
                                  .isBefore(DateTime.now())
                              ? Colors.red
                              : Colors.black
                          : Colors.black,
                    ),
                    _rowThreeText(
                      title: "Revisit On",
                      titleValue: widget.salesLeadData.details?[index]
                              ['revisit_date'] ??
                          '',
                      subTitleValue: '',
                      textColor: Colors.black,
                    ),
                    _rowThreeText(
                      title: "Assign To",
                      titleValue: widget.salesLeadData.details?[index]
                              ['assignto_name'] ??
                          '',
                      subTitleValue: '',
                      textColor: Colors.black,
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _salesLeadCard({
    required BuildContext context,
  }) {
    return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 22, top: 10),
                width: MediaQuery.of(context).size.width - 90,
                child: Row(
                  children: [
                    Text(
                      widget.salesLeadData.leadBuyerName ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    if (widget.salesLeadData.leadIntrested != null)
                      _statusCapsule(
                        context: context,
                        title: widget.salesLeadData.leadIntrested ?? '',
                        backgroundColor:
                            const Color.fromARGB(255, 118, 233, 122),
                      )
                  ],
                ),
              ),

              _rowTwoText(
                context: context,
                title: 'Created Date',
                titleValue: DateFormat('dd-MM-yyyy').format(
                    widget.salesLeadData.leadBuyerCreatedAt ?? DateTime.now()),
                isStatus: false,
              ),

              _rowTwoText(
                context: context,
                title: 'Last Followed',
                titleValue: widget.salesLeadData.leadBuyerUpdatedAt ?? '',
                isStatus: widget.salesLeadData.leadSource!.isNotEmpty,
                leadSourceSttus: widget.salesLeadData.leadSource,
                isTimerIcon: true,
              ),
              _rowEmailContact(
                icon: 'images/projectmanagement/whatsappIcon.svg',
                context: context,
                title: "Contact No",
                titleValue: widget.responseGetAllSalesLead?.maskContact == '2'
                    ? "*" * (widget.salesLeadData.leadBuyerPhone!.length - 4) +
                        widget.salesLeadData.leadBuyerPhone!.substring(
                            widget.salesLeadData.leadBuyerPhone!.length - 4)
                    : widget.salesLeadData.leadBuyerPhone ?? '',
                isVerified: widget.salesLeadData.smsVerify ?? '0',
              ),
              _rowEmailContact(
                icon: 'images/projectmanagement/emailIcon.svg',
                context: context,
                title: "Email",
                titleValue: widget.responseGetAllSalesLead?.maskContact == '2'
                    ? widget.salesLeadData.leadBuyerEmail!.length > 3
                        ? "*" *
                                (widget.salesLeadData.leadBuyerEmail!.length -
                                    4) +
                            widget.salesLeadData.leadBuyerEmail!.substring(
                                widget.salesLeadData.leadBuyerEmail!.length - 4)
                        : widget.salesLeadData.leadBuyerEmail!.length <= 3
                            ? widget.salesLeadData.leadBuyerEmail ?? ''
                            : "--"
                    : widget.salesLeadData.leadBuyerEmail ?? '',
                onTap: widget.responseGetAllSalesLead?.maskContact != '2'
                    ? () async {
                        final Uri emailUrl = Uri(
                          scheme: 'mailto',
                          path: widget.salesLeadData.leadBuyerEmail,
                        );

                        if (await canLaunchUrl(emailUrl)) {
                          launchUrl(emailUrl);
                        } else {
                          throw Exception("couldnot launch url");
                        }
                      }
                    : () {},
                isVerified: widget.salesLeadData.emailVerify ?? '0',
              ),
              const SizedBox(height: 2),
              _rowTwoText(
                context: context,
                title: 'Requirement',
                titleValue: widget.salesLeadData.leadRequirement ?? '',
                isStatus: false,
              ),
              const SizedBox(height: 5),
              _rowTwoText(
                context: context,
                title: 'Current Owner',
                titleValue: widget.salesLeadData.currentOwner ?? '',
                isStatus: false,
              ),
              const SizedBox(height: 5),
              _rowTwoText(
                context: context,
                title: 'Current Configuration',
                titleValue: widget.salesLeadData.currentConfiguration ?? '',
                isStatus: false,
              ),
              const SizedBox(height: 5),
              _rowTwoText(
                context: context,
                title: 'Carpet Area',
                titleValue: widget.salesLeadData.areaRangeName ?? '',
                isStatus: false,
              ),
              const SizedBox(height: 5),
              _rowTwoText(
                context: context,
                title: 'Budget',
                titleValue: widget.salesLeadData.leadBudgetValue ?? '',
                isStatus: false,
              ),
              const SizedBox(height: 5),
              _rowTwoText(
                context: context,
                title: 'Source',
                titleValue: widget.salesLeadData.leadSource ?? '',
                isStatus: false,
              ),
              const SizedBox(height: 5),
              _rowTwoText(
                context: context,
                title: 'Sub Source',
                titleValue: widget.salesLeadData.subSourceName ?? '',
                isStatus: false,
              ),
              const SizedBox(height: 5),
              _rowTwoText(
                context: context,
                title: 'Campaign',
                titleValue: widget.salesLeadData.campaign ?? '',
                isStatus: false,
              ),
              const SizedBox(height: 5), //
              _rowTwoText(
                context: context,
                title: 'Ethnicity',
                titleValue: widget.salesLeadData.ethinicityIdName ?? '',
                isStatus: false,
              ),
              const SizedBox(height: 5),
              _rowTwoText(
                context: context,
                title: 'Nationality',
                titleValue: widget.salesLeadData.nationality ?? '',
                isStatus: false,
              ),
              const SizedBox(height: 5),
              _rowTwoText(
                context: context,
                title: 'City',
                titleValue: widget.salesLeadData.leadLocation ?? '',
                isStatus: false,
              ),
              const SizedBox(height: 5),
              _rowTwoText(
                context: context,
                title: 'Residential Area',
                titleValue: widget.salesLeadData.regionName ?? '',
                isStatus: false,
              ),
              const SizedBox(height: 5),
              _rowTwoText(
                context: context,
                title: 'Pincode',
                titleValue: widget.salesLeadData.pincode ?? '',
                isStatus: false,
              ),
              const SizedBox(height: 5),
              _rowTwoText(
                context: context,
                title: 'Lead Stage',
                titleValue: widget.salesLeadData.leadStageIdName ?? '',
                isStatus: false,
              ),
              if (widget.salesLeadData.leadStageIdName == "Not interested")
                const SizedBox(height: 5),
              if (widget.salesLeadData.leadStageIdName == "Not interested")
                _rowTwoText(
                  context: context,
                  title: 'Lost Reason',
                  titleValue: widget.salesLeadData.lostReasonName ?? '',
                  isStatus: false,
                ),
              const SizedBox(height: 5),
              _rowTwoText(
                context: context,
                title: 'Src. Manger',
                titleValue: widget.salesLeadData.sourceManagerName ?? '',
                isStatus: false,
              ),
              const SizedBox(height: 5),
              _rowTwoText(
                context: context,
                title: 'Closing Manger',
                titleValue: widget.salesLeadData.closingManagerName ?? '',
                isStatus: false,
              ),

              Container(
                padding: const EdgeInsets.only(top: 10, left: 22),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 300,
                      child: Text(
                        "Interest",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    horizontalSpaceMedium,
                    const Center(
                        child: Icon(Icons.remove, color: Colors.black54)),
                    horizontalSpaceLarge,
                    InkWell(
                      onTap: () {
                        if (widget.salesLeadData.editFlag == "1") {
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
                                                  child: RadioListTile<String>(
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    title: Text(
                                                      widget.intrestFilters?[j]
                                                              .name ??
                                                          '',
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    value: widget
                                                            .intrestFilters?[j]
                                                            .id ??
                                                        '',
                                                    groupValue: selectedOption,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        selectedOption =
                                                            value ?? '';
                                                        intrestContoller
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
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width - 840,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 4),
                        child: SizedBox(
                          height: 44,
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "(Interest Cannot Be Empty)";
                              }
                            },
                            enabled: false,
                            readOnly: true,
                            controller: intrestContoller,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 15.0),
                            decoration: const InputDecoration(
                                hintText: 'Please Select Interest',
                                hintStyle: TextStyle(
                                  color: Color.fromARGB(255, 116, 116, 116),
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w200,
                                  fontFamily: 'HelveticaNeue',
                                ),
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
              ),
              Container(
                padding: const EdgeInsets.only(top: 10, left: 22),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 300,
                      child: Text(
                        "Status",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    horizontalSpaceMedium,
                    const Center(
                        child: Icon(Icons.remove, color: Colors.black54)),
                    horizontalSpaceLarge,
                    InkWell(
                      onTap: () {
                        if (widget.salesLeadData.editFlag == "1") {
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
                                        "Select Status",
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
                                              for (int i = 0;
                                                  i < intrestFilter!.length;
                                                  i++)
                                                Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                  child: RadioListTile<String>(
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    title: Text(
                                                      intrestFilter?[i].name ??
                                                          '',
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    value:
                                                        intrestFilter?[i].id ??
                                                            '',
                                                    groupValue: selectedStatus,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        selectedStatus =
                                                            value ?? '';
                                                        statusContoller.text =
                                                            intrestFilter?[i]
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
                        }
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 840,
                        child: SizedBox(
                          height: 44,
                          child: TextField(
                            enabled: false,
                            readOnly: true,
                            controller: statusContoller,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 15.0),
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(12.0),
                                border: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black)),
                                hintText: selectedOption,
                                suffixIcon: const Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 10, left: 22),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 300,
                      child: Text(
                        "Revisit Date",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    horizontalSpaceMedium,
                    const Center(
                        child: Icon(Icons.remove, color: Colors.black54)),
                    horizontalSpaceLarge,
                    InkWell(
                      onTap: () {
                        if (widget.salesLeadData.editFlag == "1") {
                          selectRevisitDatePopUp(
                            context: context,
                          );
                        }
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 840,
                        child: SizedBox(
                          // height: 44,
                          child: TextFormField(
                            // validator: (value) {
                            //   if (value!.isEmpty) {
                            //     return "(Revist Date Cannot be empty)";
                            //   }
                            // },
                            enabled: false,
                            readOnly: true,
                            controller: controllerRevisitdate,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 15.0),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                )),
                                errorBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.red,
                                )),
                                hintStyle: const TextStyle(
                                  color: Color.fromARGB(255, 116, 116, 116),
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w200,
                                  fontFamily: 'HelveticaNeue',
                                ),
                                hintText: "Select Revisit Date",
                                contentPadding: const EdgeInsets.all(12.0),
                                border: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black)),
                                suffixIcon: const Icon(
                                  Icons.date_range,
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 10, left: 22),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 300,
                      child: Text(
                        "Assign To",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    horizontalSpaceMedium,
                    const Center(
                        child: Icon(Icons.remove, color: Colors.black54)),
                    horizontalSpaceLarge,
                    InkWell(
                      onTap: () {
                        if (widget.salesLeadData.editFlag == "1") {
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
                                        "Lead Assign To",
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
                                              for (int i = 0;
                                                  i < assingUserList!.length;
                                                  i++)
                                                Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                  child: RadioListTile<String>(
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    title: Text(
                                                      assingUserList?[i]
                                                              .transEmpName ??
                                                          '',
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    value: assingUserList?[i]
                                                            .transEmpId ??
                                                        '',
                                                    groupValue:
                                                        selectedAssignTo,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        selectedAssignTo =
                                                            value ?? '';
                                                        assignToContoller.text =
                                                            assingUserList?[i]
                                                                    .transEmpName ??
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
                        }
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 840,
                        child: SizedBox(
                          // height: 44,
                          child: TextFormField(
                            // validator: (value) {
                            //   if (value!.isEmpty) {
                            //     return "(Assign To Cannot Be Empty)";
                            //   }
                            // },
                            enabled: false,
                            readOnly: true,
                            controller: assignToContoller,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 15.0),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                )),
                                errorBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.red,
                                )),
                                hintStyle: const TextStyle(
                                  color: Color.fromARGB(255, 116, 116, 116),
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w200,
                                  fontFamily: 'HelveticaNeue',
                                ),
                                hintText: "Select Assign To",
                                contentPadding: const EdgeInsets.all(12.0),
                                border: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black)),
                                suffixIcon: const Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 10, left: 22),
                width: MediaQuery.of(context).size.width - 120,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 300,
                      child: Text(
                        "Remark",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    horizontalSpaceMedium,
                    const Center(
                        child: Icon(Icons.remove, color: Colors.black54)),
                    horizontalSpaceLarge,
                    Container(
                      width: MediaQuery.of(context).size.width - 840,
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22)),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "(Remark Cannot Be Empty)";
                          }
                        },
                        controller: updateController,
                        decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.black45),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            )),
                            errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Colors.red,
                            )),
                            hintText: 'Remark...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.circular(8))),
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 22),
                    width: 320,
                    child: const Text(
                      'Notify On',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  horizontalSpaceMedium,
                  const Center(
                      child: Icon(Icons.remove, color: Colors.black54)),
                  horizontalSpaceLarge,
                  SizedBox(
                      // width: MediaQuery.of(context).size.width * 0.74,
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
                          print(isChecked);
                        },
                      ),
                      if (isChecked)
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.21,
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
                                  fontSize: 13, color: Colors.black),
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
                                  contentPadding: EdgeInsets.all(15.0),
                                  hintText: 'Select Notify Date',
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 116, 116, 116),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'HelveticaNeue',
                                  ),
                                  labelStyle: TextStyle(
                                      color: Colors.black, fontSize: 16.0),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(7.0)))),
                            ),
                          ),
                        )
                    ],
                  )),
                ],
              ),
              // Container(
              //   padding: const EdgeInsets.only(top: 10, left: 22),
              //   width: MediaQuery.of(context).size.width - 120,
              //   child: Row(
              //     children: [
              //       const SizedBox(
              //         width: 300,
              //       ),
              //       horizontalSpaceMedium,
              //       const SizedBox(
              //         width: 22,
              //       ),
              //       horizontalSpaceLarge,
              //       Container(
              //         width: 400,
              //         margin: const EdgeInsets.only(top: 6),
              //         padding: const EdgeInsets.symmetric(
              //             vertical: 3, horizontal: 0),
              //         decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(22)),
              //         child: ElevatedButton(
              //           style: ElevatedButton.styleFrom(
              //               minimumSize: const Size.fromHeight(50),
              //               backgroundColor: Colors.black,
              //               fixedSize: const Size.fromWidth(100),
              //               padding: const EdgeInsets.all(10),
              //               textStyle: const TextStyle(color: Colors.white)),
              //           child: const Text('Update',
              //               style: TextStyle(
              //                   fontWeight: FontWeight.normal,
              //                   fontSize: 14.0,
              //                   color: Colors.white)),
              //           onPressed: () {
              //             if (_formKey.currentState!.validate()) {
              //               updateLeadDetails();
              //               Alert(
              //                   closeIcon: const SizedBox(),
              //                   padding: const EdgeInsets.only(top: 0.0),
              //                   image: Image.asset('images/Icon-512.png',
              //                       height: 80, fit: BoxFit.fitWidth),
              //                   style: const AlertStyle(
              //                       titleTextAlign: TextAlign.center,
              //                       descTextAlign: TextAlign.center,
              //                       descStyle: TextStyle(
              //                           fontWeight: FontWeight.normal,
              //                           fontSize: 16),
              //                       isCloseButton: true),
              //                   context: context,
              //                   desc: "Successfully updated a lead details",
              //                   alertAnimation: fadeAlertAnimation,
              //                   buttons: [
              //                     DialogButton(
              //                       onPressed: () => {
              //                         Navigator.pop(context),
              //                         Navigator.pop(context)
              //                       },
              //                       color: Colors.black,
              //                       child: const Text(
              //                         "CLOSE",
              //                         style: TextStyle(
              //                             color: Colors.white, fontSize: 15),
              //                       ),
              //                     ),
              //                   ]).show();

              //               // Alert(
              //               //     closeIcon: const SizedBox(),
              //               //     padding: const EdgeInsets.only(top: 0.0),
              //               //     image: Image.asset('images/Icon-512.png',
              //               //         height: 80, fit: BoxFit.fitWidth),
              //               //     style: const AlertStyle(
              //               //         titleTextAlign: TextAlign.center,
              //               //         descTextAlign: TextAlign.center,
              //               //         descStyle: TextStyle(
              //               //             fontWeight: FontWeight.normal,
              //               //             fontSize: 16),
              //               //         isCloseButton: true),
              //               //     context: context,
              //               //     desc: "Please fill update field",
              //               //     alertAnimation: fadeAlertAnimation,
              //               //     buttons: [
              //               //       DialogButton(
              //               //         onPressed: () => Navigator.pop(context),
              //               //         color: Colors.black,
              //               //         child: const Text(
              //               //           "CLOSE",
              //               //           style: TextStyle(
              //               //               color: Colors.white, fontSize: 15),
              //               //         ),
              //               //       ),
              //               //     ]).show();
              //             }
              //           },
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ));
  }

  Widget _rowTwoText({
    required BuildContext context,
    required String title,
    required String titleValue,
    bool isStatus = false,
    bool isTimerIcon = false,
    String? leadSourceSttus,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 22),
      width: MediaQuery.of(context).size.width - 90,
      child: Row(
        children: [
          SizedBox(
            width: 300,
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          horizontalSpaceMedium,
          const Center(child: Icon(Icons.remove, color: Colors.black54)),
          horizontalSpaceLarge,
          if (isTimerIcon)
            Container(
                padding: const EdgeInsets.only(right: 10),
                child: const Icon(Icons.timer_outlined)),
          Text(
            titleValue,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          if (isStatus)
            _statusCapsule(
              context: context,
              title: leadSourceSttus ?? '',
              backgroundColor: const Color.fromARGB(255, 223, 205, 49),
            ),
        ],
      ),
    );
  }

  Widget _rowThreeText({
    required String title,
    required String titleValue,
    required String subTitleValue,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 22),
      width: MediaQuery.of(context).size.width - 90,
      child: Row(
        children: [
          SizedBox(
            width: 300,
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          horizontalSpaceMedium,
          const Center(child: Icon(Icons.remove, color: Colors.black54)),
          horizontalSpaceLarge,
          Text(
            titleValue,
            style: TextStyle(
              fontSize: 16,
              color: textColor ?? Colors.black,
            ),
          ),
          const Spacer(),
          Text(
            subTitleValue,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCapsule({
    required BuildContext context,
    required String title,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: backgroundColor,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _rowEmailContact({
    required BuildContext context,
    required String title,
    required String titleValue,
    required String icon,
    required String isVerified,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 22),
      width: MediaQuery.of(context).size.width - 120,
      child: Row(
        children: [
          SizedBox(
            width: 300,
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          horizontalSpaceMedium,
          const Center(child: Icon(Icons.remove, color: Colors.black54)),
          horizontalSpaceLarge,
          InkWell(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.grey,
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    icon,
                    height: 20,
                    fit: BoxFit.fitWidth,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    titleValue,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10),
          if (isVerified == "1")
            Icon(
              Icons.check_circle_outline,
              color: Colors.blue,
            ),
        ],
      ),
    );
  }
}
