import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stallion/models/case_flow_buyer_list.dart';
import 'package:stallion/models/get_broker_details.dart';
import 'package:stallion/models/get_broker_list.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/salesmanagement/bookingdetailsview.dart';
import 'package:stallion/ui/views/salesmanagement/payments_cp.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/salesLeadDetailPage.dart';
import 'package:stallion/ui/views/salesmanagement/viewdocumentsview.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/utils/app_url.dart';

class IndividualBrokerList extends StatefulWidget {
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  // final GetBrokerListResponse? getAllBrokerListResponse;
  final TotalBar? totalBar;
  final String? brokerId;
  final String? brokerName;
  final String? strSelectedFlag;
  final String? selectTypeId;
  final String? flagFrom;
  final bool? cashflowgst;
  final String? collecteable;
  final String? collected;
  final String? balance;

  const IndividualBrokerList({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    // this.getAllBrokerListResponse,
    this.totalBar,
    this.cashflowgst,
    this.brokerId,
    this.flagFrom = '',
    this.strSelectedFlag = '',
    this.selectTypeId = '',
    this.brokerName,
    this.collecteable = '',
    this.collected = '',
    this.balance = '',
  });

  @override
  State<IndividualBrokerList> createState() => _IndividualBrokerListState();
}

class _IndividualBrokerListState extends State<IndividualBrokerList> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? offset = '0';
  GetBrokerDetailsResponse? getBrokerDetailsResponse;
  CaseFlowBuyerListResponse? caseFlowBuyerListResponse;
  List<FlatBuyerRequest>? projectBuyerDetailsList;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<FlatBuyerRequest>? flatBuyerRequest;
  bool cash_flow_gst = false;

  TextEditingController searchController = TextEditingController();

  // get all brker list
  Future<GetBrokerListResponse?> getBrokerDetails() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    if (widget.flagFrom == "BROKERMANAGEMENT") {
      Map<String, String> data = {
        "user_id": userId!,
        "project_id": widget.projectId!,
        "towar_id": widget.towarId!,
        "offset": offset ?? '',
        "limit": "20",
        'broker_id': widget.brokerId!,
        "broker_search":
            searchController.text.length > 2 ? searchController.text : "",
      };
      var response =
          await apiNetworkHandler.post(AppUrl.webGetAllBrokerDetails, data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = getBrokerDetailsFromJson(response.body);
        if (dataModel.response?.errorCode == "0") {
          setState(() {
            offset = dataModel.response?.offset;
            getBrokerDetailsResponse = dataModel.response;
            flatBuyerRequest = dataModel.response?.flatBuyerRequest;
          });
        }
      }
    } else if (widget.flagFrom == "CASHFLOW") {
      String gst = "0";
      if (cash_flow_gst == true) {
        gst = '1';
      }
      Map<String, String> data = {
        'masnory_id': widget.brokerId ?? '',
        "project_id": widget.projectId ?? '',
        'str_selected_flag': widget.strSelectedFlag ?? '',
        "offset": offset ?? '',
        "towar_id": widget.towarId ?? '',
        "limit": "20",
        "user_id": userId ?? '',
        'select_type_id': widget.selectTypeId ?? '',
        "cash_flow_gst": gst,
        "search_data":
            searchController.text.length > 2 ? searchController.text : "",
      };
      var response =
          await apiNetworkHandler.post(AppUrl.wsGetCaseFlowBuyerList, data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = caseFlowBuyerListFromJson(response.body);
        if (dataModel.response?.errorCode == "0") {
          setState(() {
            offset = dataModel.response?.offset;
            caseFlowBuyerListResponse = dataModel.response;
            projectBuyerDetailsList =
                dataModel.response?.projectBuyerDetailsList;
          });
        }
      }
    }

    return null;
  }

  Future<GetBrokerListResponse?> getBrokerDetailsPagination() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    if (widget.flagFrom == "BROKERMANAGEMENT") {
      Map<String, String> data = {
        "user_id": userId ?? '',
        "project_id": widget.projectId ?? '',
        "towar_id": widget.towarId ?? '',
        "offset": offset ?? '',
        "limit": "20",
        'broker_id': widget.brokerId ?? '',
        "broker_search":
            searchController.text.length > 2 ? searchController.text : "",
      };
      var response =
          await apiNetworkHandler.post(AppUrl.webGetAllBrokerDetails, data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = getBrokerDetailsFromJson(response.body);
        if (dataModel.response?.errorCode == "0") {
          setState(() {
            if (offset == "0") {
              flatBuyerRequest = dataModel.response?.flatBuyerRequest;
            } else {
              flatBuyerRequest = [
                ...?flatBuyerRequest,
                ...?dataModel.response?.flatBuyerRequest
              ];
            }
            offset = dataModel.response?.offset;
          });
        }
      }
    } else if (widget.flagFrom == "CASHFLOW") {
      Map<String, String> data = {
        'broker_id': widget.brokerId ?? '',
        'masnory_id': "",
        "project_id": widget.projectId ?? "",
        'str_selected_flag': "",
        "offset": offset ?? '',
        "towar_id": widget.towarId ?? '',
        "limit": "20",
        "user_id": userId ?? '',
        'select_type_id': '',
        "search_data":
            searchController.text.length > 2 ? searchController.text : "",
      };
      var response =
          await apiNetworkHandler.post(AppUrl.wsGetCaseFlowBuyerList, data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = caseFlowBuyerListFromJson(response.body);
        if (dataModel.response?.errorCode == "0") {
          setState(() {
            caseFlowBuyerListResponse = dataModel.response;
            if (offset == '0') {
              projectBuyerDetailsList = [
                ...?projectBuyerDetailsList,
                ...?dataModel.response?.projectBuyerDetailsList
              ];
            } else {
              projectBuyerDetailsList =
                  dataModel.response?.projectBuyerDetailsList;
            }
            offset = dataModel.response?.offset;
          });
        }
      }
    }

    return null;
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));

    offset = '0';

    getBrokerDetailsPagination();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));

    getBrokerDetailsPagination();
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      cash_flow_gst = widget.cashflowgst!;
    });
    getBrokerDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: widget.flagFrom == "BROKERMANAGEMENT"
          ? Container(
              decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(
                color: Colors.black,
              ))),
              height: 50,
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    decoration: const BoxDecoration(
                        border: Border(
                            right: BorderSide(
                      color: Colors.black,
                    ))),
                    child: Column(
                      children: [
                        const AppText(
                          title: "Total Amount",
                          fontSize: 14,
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          title: currencyFormat.format(
                              double.parse(widget.totalBar?.totalAmount ?? '')),
                          fontSize: 14,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    decoration: const BoxDecoration(
                        border: Border(
                            right: BorderSide(
                      color: Colors.black,
                    ))),
                    child: Column(
                      children: [
                        const AppText(
                          title: "Total Paid",
                          fontSize: 14,
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          title: currencyFormat.format(
                              double.parse(widget.totalBar?.totalPaid ?? '')),
                          fontSize: 14,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    decoration: const BoxDecoration(
                        border: Border(
                            right: BorderSide(
                      color: Colors.black,
                    ))),
                    child: Column(
                      children: [
                        const AppText(
                          title: "Total Balance",
                          fontSize: 14,
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          title: currencyFormat.format(double.parse(
                              widget.totalBar?.totalBalance ?? '')),
                          fontSize: 14,
                          titleColor: Colors.red,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          : widget.flagFrom == "CASHFLOW"
              ? Container(
                  decoration: const BoxDecoration(
                    border: Border(
                        top: BorderSide(
                      color: Colors.black,
                    )),
                  ),
                  height: 50,
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 3,
                        decoration: BoxDecoration(
                            color: widget.strSelectedFlag == "0"
                                ? Colors.black
                                : Colors.transparent,
                            border: Border(
                                right: BorderSide(
                              color: Colors.black,
                            ))),
                        child: Column(
                          children: [
                            AppText(
                              title: "Total Collecteable",
                              fontSize: 14,
                              titleColor: widget.strSelectedFlag == "0"
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            const SizedBox(height: 2),
                            AppText(
                              title: currencyFormat.format(
                                  double.parse(widget.collecteable ?? '')),
                              titleColor: widget.strSelectedFlag == "0"
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 14,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 3,
                        decoration: BoxDecoration(
                            color: widget.strSelectedFlag == "1"
                                ? Colors.black
                                : Colors.transparent,
                            border: Border(
                                right: BorderSide(
                              color: Colors.black,
                            ))),
                        child: Column(
                          children: [
                            AppText(
                              title: "Total Collected",
                              titleColor: widget.strSelectedFlag == "1"
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 14,
                            ),
                            const SizedBox(height: 2),
                            AppText(
                              title: currencyFormat
                                  .format(double.parse(widget.collected ?? '')),
                              titleColor: widget.strSelectedFlag == "1"
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 14,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 3,
                        decoration: BoxDecoration(
                            color: widget.strSelectedFlag == "2"
                                ? Colors.black
                                : Colors.transparent,
                            border: Border(
                                right: BorderSide(
                              color: Colors.black,
                            ))),
                        child: Column(
                          children: [
                            AppText(
                              title: "Total Balance",
                              titleColor: widget.strSelectedFlag == "2"
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 14,
                            ),
                            const SizedBox(height: 2),
                            AppText(
                              title: currencyFormat
                                  .format(double.parse(widget.balance ?? '')),
                              fontSize: 14,
                              titleColor: widget.strSelectedFlag == "2"
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              : SizedBox.shrink(),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            '${widget.projectName?.toUpperCase()} ${widget.towarName!.isNotEmpty ? "-" : ""} ${widget.towarName!.toUpperCase()}',
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.56,
                child: AppText(
                  title: widget.flagFrom == "BROKERMANAGEMENT"
                      ? (widget.brokerName)?.toUpperCase() ?? ''
                      : widget.flagFrom == "CASHFLOW"
                          ? '${(widget.brokerName)?.toUpperCase() ?? ''} ${widget.strSelectedFlag == "0" ? "- COLLECTABLE" : widget.strSelectedFlag == "1" ? "- COLLECTED" : widget.strSelectedFlag == "0" ? "- BALANCE" : ""}'
                          : "",
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  titleTextAlign: TextAlign.right,
                ),
              ),
              if (widget.flagFrom == "CASHFLOW") Spacer(),
              if (widget.flagFrom == "CASHFLOW")
                Row(
                  children: [
                    const Text('GST',
                        style: TextStyle(
                            fontStyle: FontStyle.normal, fontSize: 17.0)),
                    Switch(
                      // thumb color (round icon)
                      activeColor: Colors.green,
                      activeTrackColor: Colors.green,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey.shade400,
                      splashRadius: 40.0,
                      // boolean variable value
                      value: cash_flow_gst,
                      // changes the state of the switch
                      onChanged: (value) {
                        setState(() => cash_flow_gst = value);
                        getBrokerDetails();
                      },
                    ),
                    horizontalSpaceMedium
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 60.0, right: 60),
            child: SizedBox(
              height: 40,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    offset = '0';
                  });
                  getBrokerDetails();
                },
                style: const TextStyle(fontSize: 13),
                controller: searchController,
                decoration: InputDecoration(
                    suffixIcon: searchController.text.length > 0
                        ? InkWell(
                            onTap: () {
                              searchController.clear();
                              setState(() {
                                offset = '0';
                              });
                              getBrokerDetails();
                            },
                            child: Container(
                              padding: const EdgeInsets.only(right: 12),
                              child: const Icon(Icons.close_rounded),
                            ),
                          )
                        : const SizedBox.shrink(),
                    contentPadding: const EdgeInsets.all(12.0),
                    labelText: "Search by Buyer Name",
                    hintText: "Search by Buyer Name",
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          Expanded(
            child: (widget.flagFrom == "BROKERMANAGEMENT"
                    ? getBrokerDetailsResponse == null
                    : widget.flagFrom == "CASHFLOW"
                        ? caseFlowBuyerListResponse == null
                        : false)
                ? Center(
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
                // const Center(child: CircularProgressIndicator())
                : (widget.flagFrom == "BROKERMANAGEMENT"
                        ? flatBuyerRequest?.length != 0
                        : widget.flagFrom == "CASHFLOW"
                            ? projectBuyerDetailsList?.length != 0
                            : false)
                    ? SmartRefresher(
                        enablePullDown: true,
                        enablePullUp: true,
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        onLoading: _onLoading,
                        footer: const ClassicFooter(
                            loadStyle: LoadStyle.ShowWhenLoading),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context1, index) {
                            return widget.flagFrom == "BROKERMANAGEMENT"
                                ? _brokercard(
                                    brokerData: flatBuyerRequest?[index],
                                  )
                                : widget.flagFrom == "CASHFLOW"
                                    ? _cashFlowcard(
                                        brokerDataa:
                                            projectBuyerDetailsList?[index])
                                    : SizedBox.shrink();
                          },
                          itemCount: widget.flagFrom == "BROKERMANAGEMENT"
                              ? flatBuyerRequest?.length ?? 0
                              : widget.flagFrom == "CASHFLOW"
                                  ? projectBuyerDetailsList?.length ?? 0
                                  : 0,
                          separatorBuilder: (context1, index) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 66,
                            ),
                            child: const Divider(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )
                    : const Center(
                        child: Text(
                          "No Record Found",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _brokercard({FlatBuyerRequest? brokerData}) {
    print("here11");
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return BookingDetailsView(
                flat_buyer_id: brokerData?.flatBuyerId ?? '',
                projectId: widget.projectId,
                projectName: widget.projectName,
                towarId: widget.towarId,
                towarName: widget.towarName!,
                flatBuyerRequest: brokerData,
                navigationFlag: 'SoldInventory',
              );
            },
          ),
        );
      },
      child: Container(
          padding: const EdgeInsets.only(left: 50),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _rowTwoText(
                    // brokerData: brokerData,
                    flatBuyerId: brokerData?.flatBuyerId ?? '',
                    flatFundingType: brokerData?.flatFundingType ?? '',
                    isDocument: true,
                    context: context,
                    title: 'Booking No.',
                    titleValue: brokerData?.flatBuyerOrderNo ?? '',
                  ),
                  _rowTwoText(
                    // brokerData: brokerData,
                    context: context,
                    title: "Buyer's Name",
                    titleValue: brokerData?.flatBuyerName ?? '',
                  ),
                  _rowTwoText(
                    // brokerData: brokerData,
                    isPayment: true,
                    context: context,
                    title: 'Total Flat Value',
                    subTitle: "(Inc. G.S.T)",
                    titleValue: currencyFormat.format(
                      double.parse(brokerData?.gstFlatTotalValue ?? ''),
                    ),
                  ),
                  _rowTwoText(
                    // brokerData: brokerData,
                    context: context,
                    title: 'Total Brokerage',
                    subTitle: "(Inc. G.S.T)",
                    titleValue: currencyFormat
                        .format(double.parse(brokerData?.brokerTotal ?? '')),
                  ),
                  // _rowTwoText(
                  //   // brokerData: brokerData,
                  //   context: context,
                  //   title: 'Brokerage Paid',
                  //   subTitle: "(Inc. G.S.T)",
                  //   titleValue: currencyFormat.format(
                  //       double.parse(brokerData?.brokerTotalPaid ?? '')),
                  // ),
                  Container(
                    padding: const EdgeInsets.only(top: 10, left: 22),
                    width: MediaQuery.of(context).size.width - 120,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Brokerage Paid',
                                style: TextStyle(fontSize: 16),
                              ),
                              AppText(
                                title: '(Inc. G.S.T)',
                                fontSize: 14,
                                titleColor: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        horizontalSpaceMedium,
                        const Center(
                            child: Icon(Icons.remove, color: Colors.black54)),
                        horizontalSpaceLarge,
                        Text(
                          currencyFormat.format(
                              double.parse(brokerData?.brokerTotalPaid ?? '')),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        if (double.parse(brokerData?.brokerTotalPaid ?? '') > 0)
                          Text(
                            '(Bal. : ${currencyFormat.format(double.parse(brokerData?.brokerTotal ?? '0') - double.parse(brokerData?.brokerTotalPaid ?? '0'))})',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  _rowTwoText(
                    // brokerData: brokerData,
                    context: context,
                    title: "Unit",
                    titleValue: brokerData?.inventryFlatName ?? '',
                  ),
                ],
              ),
              const Icon(Icons.keyboard_arrow_right)
            ],
          )),
    );
  }

  Widget _cashFlowcard({FlatBuyerRequest? brokerDataa}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return BookingDetailsView(
                flat_buyer_id: brokerDataa?.flatBuyerId ?? '',
                projectId: widget.projectId,
                projectName: widget.projectName,
                towarId: widget.towarId,
                towarName: widget.towarName!,
                flatBuyerRequest: brokerDataa,
                navigationFlag: 'SoldInventory',
              );
            },
          ),
        );
      },
      child: Container(
          padding: const EdgeInsets.only(left: 50),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _rowTwoText(
                    context: context,
                    title: 'Booking No.',
                    titleValue: brokerDataa?.flatBuyerOrderNo ?? '',
                  ),
                  _rowTwoText(
                    context: context,
                    title: "Buyer's Name",
                    titleValue: brokerDataa?.flatBuyerName ?? '',
                  ),
                  _rowTwoText(
                    context: context,
                    title: 'Total Flat Value',
                    subTitle: cash_flow_gst ? "(Inc. G.S.T)" : "(Excl. G.S.T)",
                    titleValue: currencyFormat.format(double.parse(cash_flow_gst
                            ? brokerDataa?.flatTotalValueWithGst ?? ''
                            : brokerDataa?.flatTotalValue ?? ''

                        // brokerDataa?.flatTotalValue ?? ''
                        )),
                  ),
                  if (cash_flow_gst)
                    _rowTwoText(
                      context: context,
                      title: 'Flat Value',
                      subTitle: "(As Per GST Payable)",
                      titleValue: currencyFormat.format(
                          double.parse(brokerDataa?.flatTotalValue ?? '')),
                    ),
                  _rowTwoText(
                    context: context,
                    title: "Unit",
                    titleValue: brokerDataa?.inventryFlatName ?? '',
                  ),
                  _rowTwoText(
                    context: context,
                    title: "No. of Parking",
                    titleValue: brokerDataa?.noOfParking ?? '',
                  ),
                  _rowTwoText(
                    context: context,
                    title: "Requested By",
                    titleValue: brokerDataa?.flatRequestedByName ?? '',
                  ),
                  _rowTwoText(
                    context: context,
                    title: "Remark",
                    titleValue: brokerDataa?.flatBookingRemark ?? '',
                  ),
                  _rowTwoText(
                    flatBuyerId: brokerDataa?.flatBuyerId ?? '',
                    flatFundingType: brokerDataa?.flatFundingType ?? '',
                    isDocument: true,
                    context: context,
                    title: "Approved By",
                    titleValue: brokerDataa?.flatApprovedByName ?? '',
                  ),
                ],
              ),
              const Icon(Icons.keyboard_arrow_right)
            ],
          )),
    );
  }

  Widget _rowTwoText({
    BuildContext? context,
    String? title,
    String? titleValue,
    // FlatBuyerRequest? brokerData,
    String? subTitle = '',
    String? flatBuyerId = '',
    String? flatFundingType = '',
    isDocument = false,
    isPayment = false,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 22),
      width: MediaQuery.of(context!).size.width - 120,
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: subTitle!.isEmpty
                ? Text(
                    title ?? '',
                    style: const TextStyle(fontSize: 16),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                      AppText(
                        title: subTitle,
                        fontSize: 14,
                        titleColor: Colors.grey,
                      ),
                    ],
                  ),
          ),
          horizontalSpaceMedium,
          const Center(child: Icon(Icons.remove, color: Colors.black54)),
          horizontalSpaceLarge,
          Text(
            titleValue ?? '',
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          if (isDocument)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return ViewDocumentsView(
                          projectId: widget.projectId,
                          projectName: widget.projectName,
                          towarName: widget.towarName,
                          towarId: widget.towarId,
                          flatBuyerID: flatBuyerId ?? '',
                          flatFunding: flatFundingType ?? '');
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(6)),
                child: const AppText(
                  title: 'Documents',
                  lineHeight: 1,
                  fontSize: 16,
                ),
              ),
            ),
          if (isPayment)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return PaymentCp(
                        projectId: widget.projectId,
                        projectName: widget.projectName,
                        towarName: widget.towarName,
                        towarId: widget.towarId,
                        brokerName: widget.brokerName,
                        flatBuyerId: flatBuyerId ?? '',
                        brokerId: widget.brokerId ?? '',
                      );
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 27,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(6)),
                child: const AppText(
                  title: 'Payment',
                  lineHeight: 1,
                  fontSize: 16,
                ),
              ),
            )
        ],
      ),
    );
  }
}
