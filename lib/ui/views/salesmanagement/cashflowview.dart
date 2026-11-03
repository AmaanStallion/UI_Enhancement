import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../models/get_cashflow_details.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'brokerManagement/individualBroketList.dart';

class CashFlowView extends StatefulWidget {
  const CashFlowView(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.cashflowgst,
      this.towarName})
      : super(key: key);
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final bool? cashflowgst;

  @override
  State<CashFlowView> createState() => _CashFlowViewState();
}

class _CashFlowViewState extends State<CashFlowView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
  }

  var overdueValue = 0.0;
  bool flagcalled = false;
  List<CashFlowList>? cashFlowList;
  SalesTotalBar? salesTotalBar;
  bool cash_flow_gst = false;

  Future<ResponseGetCashFlow?> fetchCashFlowListing() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    String gst = "0";
    if (cash_flow_gst == true) {
      gst = '1';
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "cash_flow_gst": gst,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.webGetCashFlowListing, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getCashFlowFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        //return dataModel.response;
        cashFlowList = dataModel.response?.cashFlowList!;
        salesTotalBar = dataModel.response?.salesTotalBar!;
        overdueValue = 0.0;
        for (int i = 0; i < cashFlowList!.length; i++) {
          if (cashFlowList![i].cashFlowPaymentType == "1") {
            if (cashFlowList![i].balance != "") {
              overdueValue =
                  overdueValue + double.parse(cashFlowList![i].balance!);
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

  @override
  void initState() {
    super.initState();
    setState(() {
      cash_flow_gst = widget.cashflowgst!;
    });
    fetchCashFlowListing();
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
            '${widget.projectName!.toUpperCase()} ${widget.towarName!.isNotEmpty ? "-" : ""} ${widget.towarName!.toUpperCase()}',
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.47,
                        ),
                        Container(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              5.0, 16.0, 5.0, 16.0),
                          child: const Text(
                            'CASH FLOW',
                            style: boldText,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Text('GST',
                                style: TextStyle(
                                    fontStyle: FontStyle.normal,
                                    fontSize: 17.0)),
                            Switch(
                              // thumb color (round icon)
                              activeColor: Colors.white,
                              activeTrackColor: Colors.green,
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: Colors.grey.shade400,
                              splashRadius: 40.0,
                              // boolean variable value
                              value: cash_flow_gst,
                              // changes the state of the switch
                              onChanged: (value) {
                                setState(() => cash_flow_gst = value);
                                fetchCashFlowListing();
                              },
                            ),
                            horizontalSpaceMedium
                          ],
                        ),
                      ],
                    ),
                    const Divider(
                      height: 1.0,
                      thickness: 0.5,
                      indent: 1.0,
                      endIndent: 1.0,
                      color: Colors.black,
                    ),
                    IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                                height: 40,
                                width: MediaQuery.of(context).size.width / 6,
                                child: const Center(
                                    child: Text(
                                  'TITLE',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ))),
                            const VerticalDivider(
                              color: Colors.black54,
                              width: 1.0,
                            ),
                            SizedBox(
                                height: 40,
                                width: MediaQuery.of(context).size.width / 6,
                                child: const Center(
                                    child: Text(
                                  'COLLECTABLE(\u{20B9})',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ))),
                            const VerticalDivider(
                              color: Colors.black54,
                              width: 1.0,
                            ),
                            SizedBox(
                                height: 40,
                                width: MediaQuery.of(context).size.width / 6,
                                child: const Center(
                                    child: Text(
                                  'COLLECTED(\u{20B9})',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ))),
                            const VerticalDivider(
                              color: Colors.black54,
                              width: 1.0,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                    height: 40,
                                    width:
                                        MediaQuery.of(context).size.width / 6,
                                    child: const Center(
                                        child: Text(
                                      'BALANCE(\u{20B9})',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ))),
                                const SizedBox(
                                  width: 35,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      height: 1.0,
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: cashFlowList!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                IntrinsicHeight(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 35.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                            height: 55,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                6,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  cashFlowList![index].name!,
                                                  textAlign: TextAlign.center,
                                                ),
                                                cashFlowList![index].endDate !=
                                                        null
                                                    ? Text(
                                                        '(Compl. ${formatDate(cashFlowList![index].endDate)})',
                                                        // cashFlowList![index].name!,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black45),
                                                      )
                                                    : cashFlowList![index]
                                                                .startDate !=
                                                            null
                                                        ? Text(
                                                            '(Est. ${formatDate(cashFlowList![index].startDate)})',
                                                            // cashFlowList![index].name!,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey),
                                                          )
                                                        : SizedBox(
                                                            height: 0,
                                                          ),
                                              ],
                                            )),
                                        const VerticalDivider(
                                          color: Colors.black54,
                                          width: 1.0,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) {
                                                  return IndividualBrokerList(
                                                    cashflowgst: cash_flow_gst,
                                                    collecteable:
                                                        cashFlowList![index]
                                                            .collectableBill!,
                                                    collected:
                                                        cashFlowList![index]
                                                            .collected!,
                                                    balance:
                                                        cashFlowList![index]
                                                            .balance!,
                                                    brokerName:
                                                        cashFlowList![index]
                                                            .name,
                                                    brokerId:
                                                        cashFlowList![index].id,
                                                    projectId: widget.projectId,
                                                    towarId: widget.towarId,
                                                    projectName:
                                                        widget.projectName,
                                                    towarName: widget.towarName,
                                                    flagFrom: 'CASHFLOW',
                                                    strSelectedFlag: "0",
                                                    selectTypeId:
                                                        cashFlowList![index]
                                                            .selectTypeId,
                                                  );
                                                },
                                              ),
                                            ).then((value) => {});
                                          },
                                          child: SizedBox(
                                              height: 55,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  6,
                                              child: Center(
                                                  child: Text(
                                                currencyFormatWothoutSymbol
                                                    .format(double.parse(
                                                        cashFlowList![index]
                                                            .collectableBill!)),
                                                textAlign: TextAlign.center,
                                              ))),
                                        ),
                                        const VerticalDivider(
                                          color: Colors.black54,
                                          width: 1.0,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) {
                                                  return IndividualBrokerList(
                                                    cashflowgst: cash_flow_gst,
                                                    collecteable:
                                                        cashFlowList![index]
                                                            .collectableBill!,
                                                    collected:
                                                        cashFlowList![index]
                                                            .collected!,
                                                    balance:
                                                        cashFlowList![index]
                                                            .balance!,
                                                    brokerName:
                                                        cashFlowList![index]
                                                            .name,
                                                    brokerId:
                                                        cashFlowList![index].id,
                                                    projectId: widget.projectId,
                                                    towarId: widget.towarId,
                                                    projectName:
                                                        widget.projectName,
                                                    towarName: widget.towarName,
                                                    flagFrom: 'CASHFLOW',
                                                    strSelectedFlag: "1",
                                                    selectTypeId:
                                                        cashFlowList![index]
                                                            .selectTypeId,
                                                  );
                                                },
                                              ),
                                            ).then((value) => {});
                                          },
                                          child: SizedBox(
                                              height: 55,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  6,
                                              child: Center(
                                                  child: Text(
                                                currencyFormatWothoutSymbol
                                                    .format(double.parse(
                                                        cashFlowList![index]
                                                            .collected!)),
                                                textAlign: TextAlign.center,
                                              ))),
                                        ),
                                        const VerticalDivider(
                                          color: Colors.black54,
                                          width: 1.0,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) {
                                                  return IndividualBrokerList(
                                                    cashflowgst: cash_flow_gst,
                                                    collecteable:
                                                        cashFlowList![index]
                                                            .collectableBill!,
                                                    collected:
                                                        cashFlowList![index]
                                                            .collected!,
                                                    balance:
                                                        cashFlowList![index]
                                                            .balance!,
                                                    brokerName:
                                                        cashFlowList![index]
                                                            .name,
                                                    brokerId:
                                                        cashFlowList![index].id,
                                                    projectId: widget.projectId,
                                                    towarId: widget.towarId,
                                                    projectName:
                                                        widget.projectName,
                                                    towarName: widget.towarName,
                                                    flagFrom: 'CASHFLOW',
                                                    strSelectedFlag: "2",
                                                    selectTypeId:
                                                        cashFlowList![index]
                                                            .selectTypeId,
                                                  );
                                                },
                                              ),
                                            ).then((value) => {});
                                          },
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                height: 55,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    6,
                                                child: Center(
                                                    child: Text(
                                                        currencyFormatWothoutSymbol
                                                            .format(double.parse(
                                                                cashFlowList![
                                                                        index]
                                                                    .balance!)),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: cashFlowList![
                                                                          index]
                                                                      .cashFlowPaymentType ==
                                                                  "1"
                                                              ? double.parse(cashFlowList![
                                                                              index]
                                                                          .balance!) >
                                                                      0
                                                                  ? Colors.red
                                                                  : Colors.black
                                                              : Colors.black,
                                                        ))),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              cashFlowList![index]
                                                          .cashFlowPaymentType ==
                                                      "1"
                                                  ? const Icon(
                                                      Icons.check_circle_sharp,
                                                      color: Colors.green,
                                                    )
                                                  : const Icon(
                                                      Icons.circle_outlined)
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(
                                  height: 1.0,
                                ),
                              ],
                            );
                          }),
                    ),
                    const Divider(
                      height: 0.5,
                      thickness: 0.5,
                      indent: 1,
                      endIndent: 1,
                      color: Colors.black,
                    ),
                    SizedBox(
                      // height: 85,
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            horizontalSpaceSmall,
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    const Text('Total Collectable',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black)),
                                    verticalSpaceSmall,
                                    Text(
                                        currencyFormat.format(double.parse(
                                            salesTotalBar!
                                                .totalCollectableBill!)),
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black))
                                  ],
                                ),
                              ),
                            ),
                            const VerticalDivider(
                              width: 1,
                              thickness: 1,
                              indent: 10,
                              endIndent: 0,
                              color: Colors.black54,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const Text('Total Collected',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black)),
                                      verticalSpaceSmall,
                                      Text(
                                          currencyFormat.format(double.parse(
                                              salesTotalBar!.totalCollected!)),
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const VerticalDivider(
                              width: 1,
                              thickness: 1,
                              indent: 10,
                              endIndent: 0,
                              color: Colors.black54,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    const Text('Total Balance',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black)),
                                    verticalSpaceTiny,
                                    Text(
                                        currencyFormat.format(double.parse(
                                            salesTotalBar!.totalBalance!)),
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black)),
                                    verticalSpaceTiny,
                                    Text(currencyFormat.format(overdueValue),
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.red)),
                                  ],
                                ),
                              ),
                            ),
                            const VerticalDivider(
                              width: 1,
                              thickness: 1,
                              indent: 10,
                              endIndent: 0,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    )
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
          //  const Center(child: CircularProgressIndicator())
          ),
    );
  }
}
