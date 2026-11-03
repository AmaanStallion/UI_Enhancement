import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/views/accountmanagement/worequested.dart';
import 'package:stallion/ui/views/salesmanagement/availableInventory/availableInventory.dart';
import 'package:stallion/ui/views/salesmanagement/brochure/salesBrochure.dart';
import 'package:stallion/ui/views/salesmanagement/brokerManagement/brokerManagementList.dart';
import 'package:stallion/ui/views/salesmanagement/cashflowview.dart';
import 'package:stallion/ui/views/salesmanagement/membershipform.dart';
import 'package:stallion/ui/views/salesmanagement/plotdisplayview.dart';
import 'package:stallion/ui/views/salesmanagement/salesbuyerslisting.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/salesleadPage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/get_sale_management_main.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import 'bookasaleview.dart';
import 'bookinglistingview.dart';

class SalesManagementView extends StatefulWidget {
  SalesManagementView({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    this.navigationFlag,
  });

  String? projectId;
  String? towarId;
  String? projectName;
  String? navigationFlag;
  String? towarName;
  @override
  State<SalesManagementView> createState() => _SalesManagementViewState();
}

class _SalesManagementViewState extends State<SalesManagementView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  String? downloadLink = '';

  bool cash_flow_gst = false;
  bool flagcalled = false;
  ProjectBuyerList? projectBuyerList;
  String? strAvailableInventory = '';
  String? strSaleRequest = '';
  String? strSoldinventory = '';
  String? strReservedInventory = '';
  String? strTotalSold = '';
  String? strTotalSoldSqFt = '';
  String? strTotalAvailableFlatArea = '';
  String? strTotalSoldPerAmt = '';
  String? strPaymentReceived = '';
  String? strPaymentToReceive = '';
  String? strPaymentOverdue = '';
  String? strUnsoldInventoryTotalAmt = '';
  String? strUnsoldInventorySqft = '';
  String? strUnsoldInventoryPerAmt = '';
  String? strTowarName = "All Tower";
  List<TowarList>? orderList;
  String? member_ship_form = "0";
  String? sales_plot_flag = "0";
  String? saleAccTab = '0';
  String? showLeads = '';
  List<FlatConfigurationAvg>? flatConfigurationAvg = [];

  Future<ResponseGetProjectBuyerInventory?> fetchProjectSalesManagment() async {
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
      "gst_flag": gst,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.webgetprojectbuyerinventory, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getProjectBuyerInventoryFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        downloadLink = dataModel.response?.downloadLink;

        showLeads = dataModel.response?.showLeads;
        var projects = dataModel.response?.orderList!;

        member_ship_form = dataModel.response?.member_ship_form!;
        sales_plot_flag = dataModel.response?.sales_plot_flag!;

        orderList = [];

        if (projects!.isNotEmpty) {
          var dict = TowarList(towarId: "", towarName: "All Towers");
          orderList!.add(dict);

          for (int i = 0; i < projects.length; i++) {
            if (projects[i].id == widget.projectId) {
              var towar = projects[i].towarList!;
              for (int j = 0; j < towar.length; j++) {
                if (towar[j].towarId == widget.towarId) {
                  strTowarName = towar[j].towarName!;
                }
                orderList!.add(towar[j]);
              }
              break;
            }
          }
        }
        setState(() {
          saleAccTab = dataModel.response?.saleAccTab;
          flagcalled = true;
          strTotalSold = '${dataModel.response?.projectBuyerList?.totalSold}';
          strPaymentReceived =
              '${dataModel.response?.projectBuyerList?.totalReceive}';
          var totalReceived =
              double.parse(strTotalSold!) - double.parse(strPaymentReceived!);
          strPaymentToReceive = '$totalReceived';
          strPaymentOverdue =
              '${dataModel.response?.projectBuyerList?.paymentToCollect}';
          strAvailableInventory =
              '${dataModel.response?.projectBuyerList?.avaliableInventory}';
          strSoldinventory =
              '${dataModel.response?.projectBuyerList?.inventrySold}';
          strSaleRequest =
              '${dataModel.response?.projectBuyerList?.flatRequest}';
          strReservedInventory =
              '${dataModel.response?.projectBuyerList?.flatReserved}';
          strTotalSoldSqFt =
              '${dataModel.response?.projectBuyerList?.totalSoldFlatArea}';
          strTotalAvailableFlatArea =
              '${dataModel.response?.projectBuyerList?.totalAviFlatArea}';
          strUnsoldInventoryTotalAmt =
              '${dataModel.response?.projectBuyerList?.unsoldInventory}';
          strUnsoldInventorySqft =
              '${dataModel.response?.projectBuyerList?.totalSoldFlatArea}';
          strUnsoldInventoryPerAmt =
              '${dataModel.response?.projectBuyerList?.avgFlatRate}';
          strTotalSoldPerAmt =
              '${dataModel.response?.projectBuyerList?.newAvgFlatRate}';
          flatConfigurationAvg =
              dataModel.response?.projectBuyerList?.flatConfigurationAvg;
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
    fetchProjectSalesManagment();
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
            widget.towarName != ''
                ? '${widget.projectName?.toUpperCase()} - ${widget.towarName?.toUpperCase()}'
                : widget.projectName?.toUpperCase() ?? '',
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: widget.navigationFlag! == 'SideMenu'
            ? const SizedBox()
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.maybePop(context);
                },
              ),
        actions: [
          if (showLeads != '0')
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return SalesLeadPage(
                        projectId: widget.projectId,
                        towarId: widget.towarId,
                        projectName: widget.projectName,
                        navigationFlag: widget.navigationFlag,
                        towarName: widget.towarName,
                      );
                    },
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    "LEADS",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 28),
          InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return SalesBrochure(
                        projectId: widget.projectId,
                        towarId: widget.towarId,
                        projectName: widget.projectName,
                        towarName: widget.towarName,
                      );
                    },
                  ),
                );
              },
              child: Image.asset(
                'images/projectmanagement/planbrocher.png',
                height: 30,
                width: 30,
              )
              // const Icon(Icons.catching_pokemon),
              ),
          const SizedBox(width: 32),
        ],
      ),
      body: Container(
        child: flagcalled == true
            ? Builder(builder: (context) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      verticalSpaceTiny,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 24),
                          InkWell(
                            onTap: () async {
                              if (downloadLink != null &&
                                  downloadLink!.isNotEmpty) {
                                final uri = Uri.parse(downloadLink!);
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
                                  horizontal: 20, vertical: 4),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              // decoration: BoxDecoration(
                              //   color: Colors.white,
                              //   borderRadius: BorderRadius.circular(8),
                              // ),
                              child: const Center(
                                child: Text(
                                  "Overview",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          horizontalSpaceLarge,
                          horizontalSpaceLarge,
                          horizontalSpaceLarge,
                          const Center(
                            child: Text('SALES MANAGEMENT',
                                style: TextStyle(
                                    fontStyle: FontStyle.normal,
                                    fontSize: 17.0)),
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
                                  fetchProjectSalesManagment();
                                },
                              ),
                              horizontalSpaceMedium
                            ],
                          ),
                        ],
                      ),
                      verticalSpaceTiny,
                      const Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 1,
                        endIndent: 1,
                        color: Colors.black,
                      ),
                      widget.navigationFlag! != 'SideMenu'
                          ? orderList!.length >= 2
                              ? InkWell(
                                  onTap: () {
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder:
                                            (BuildContext context) => Dialog(
                                                  elevation: 0,
                                                  child: SizedBox(
                                                    height: 400,
                                                    width: 360.0,
                                                    child: Column(
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 5.0,
                                                                  bottom: 5),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                'SELECT TOWER',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Divider(
                                                          color: Colors
                                                              .grey.shade500,
                                                          thickness: 1.5,
                                                        ),
                                                        SizedBox(
                                                          height: 310,
                                                          width: 360,
                                                          child:
                                                              ListView.builder(
                                                                  itemCount:
                                                                      orderList
                                                                          ?.length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return Column(
                                                                      children: [
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            widget.towarId =
                                                                                orderList![index].towarId!;
                                                                            setState(() {
                                                                              strTowarName = orderList![index].towarName!;
                                                                            });
                                                                            widget.towarName =
                                                                                orderList![index].towarName!;
                                                                            fetchProjectSalesManagment();
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 10.0, bottom: 20.0, top: 15.0),
                                                                                  child: Text(orderList![index].towarName!),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(right: 10.0),
                                                                                  child: Icon(
                                                                                    widget.towarId == orderList![index].towarId! ? Icons.check_circle_outline_sharp : Icons.circle_outlined,
                                                                                    color: widget.towarId == orderList![index].towarId! ? Colors.green : Colors.grey,
                                                                                    size: 26,
                                                                                  ),
                                                                                ),
                                                                              ]),
                                                                        ),
                                                                        const Divider(
                                                                          height:
                                                                              1,
                                                                          thickness:
                                                                              0.5,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ],
                                                                    );
                                                                  }),
                                                        ),
                                                        Expanded(
                                                          child: InkWell(
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              color:
                                                                  Colors.black,
                                                              child:
                                                                  const Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            13.0),
                                                                child: Text(
                                                                  'OK',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          15),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ));
                                  },
                                  child: SizedBox(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(strTowarName!.toUpperCase(),
                                            style: const TextStyle(
                                                fontStyle: FontStyle.normal,
                                                fontSize: 17.0)),
                                        horizontalSpaceSmall,
                                        IconButton(
                                          icon: const Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.black),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox()
                          : const SizedBox(),
                      widget.navigationFlag! != 'SideMenu'
                          ? orderList!.length >= 2
                              ? const Divider(
                                  height: 1,
                                  thickness: 0.5,
                                  indent: 1,
                                  endIndent: 1,
                                  color: Colors.black,
                                )
                              : const SizedBox()
                          : const SizedBox(),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, left: 70.0, right: 70.0),
                        child: Stack(children: [
                          Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: _salesStatus())),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(17),
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                              ),
                              height: 35.0,
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(' SALES MANAGEMENT ',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.black)),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 70.0, right: 70.0),
                        child: _bookasale(),
                      ),
                    ],
                  ),
                );
              })
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
              ),
      ),
      bottomNavigationBar: saleAccTab == '1'
          ? SizedBox(
              height: 280,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(child: SizedBox()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                                          "Average Price (Units Sold)", //"Configuration Average Price",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
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
                                            width: 380,
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
                                          height: 240,
                                          width: 300,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                for (var item
                                                    in flatConfigurationAvg!)
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          color: Colors.grey
                                                              .withOpacity(0.5),
                                                          width: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          item.name ?? '',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                        Text(
                                                          currencyFormat.format(
                                                              double.parse(
                                                                  item.newAvgFlatRate ??
                                                                      '0')),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black),
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
                          child: Text(
                              'Next Price To Achieve Average : ${currencyFormat.format(double.parse(strTotalSoldPerAmt!))}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: Colors.black,
                                decoration: TextDecoration.underline,
                              )),
                        ),
                        SizedBox(width: 10),
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
                                          "Average Price Calculation",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
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
                                            height: 200,
                                            width: 200,
                                            child: Center(
                                              child: Text(
                                                "Total Valuation - Total Sold Value = Remaing Value divide by unsold area",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ));
                                      }));
                                });
                          },
                          child: Icon(Icons.info_outline,
                              size: 18, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    verticalSpaceSmall,
                    const Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 1,
                        endIndent: 1,
                        color: Colors.black),
                    SizedBox(
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                        child: InkWell(
                          onTap: () {
                            var projectId = widget.projectId! == ''
                                ? ""
                                : widget.projectId!;
                            var projectName = widget.projectName! == ''
                                ? ""
                                : widget.projectName!;
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return SalesBuyersListingView(
                                  projectId: projectId,
                                  towarId: widget.towarId!,
                                  projectName: projectName,
                                  towarName: widget.towarName!,
                                  cash_flow_gst: cash_flow_gst,
                                  totalVal: currencyFormat
                                      .format(double.parse(strTotalSold!)),
                                  strTypeId: "1",
                                  flagRedirect: 'SoldInventory');
                            })).then((_) {
                              setState(() {
                                flagcalled == false;
                              });
                              fetchProjectSalesManagment();
                            });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              horizontalSpaceMedium,
                              Text(
                                  'Total Sold ${strUnsoldInventorySqft != "0" ? '(${strUnsoldInventorySqft!} Sq.Ft. X ${currencyFormat.format(double.parse(strTotalSold!) / double.parse(strTotalSoldSqFt!))})' : ""} ',
                                  style: const TextStyle(
                                      backgroundColor: Colors.white,
                                      fontSize: 15,
                                      color: Colors.black)),
                              const Expanded(child: horizontalSpaceMedium),
                              Text(
                                  currencyFormat
                                      .format(double.parse(strTotalSold!)),
                                  style: const TextStyle(
                                      backgroundColor: Colors.white,
                                      fontSize: 15,
                                      color: Colors.black)),
                              IconButton(
                                iconSize: 30,
                                icon: const Icon(
                                  Icons.keyboard_arrow_right_rounded,
                                ),
                                color: Colors.black,
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 1,
                      endIndent: 1,
                      color: Colors.black,
                    ),
                    SizedBox(
                        height: 50,
                        child: Padding(
                            padding:
                                const EdgeInsets.only(left: 40.0, right: 40.0),
                            child: InkWell(
                                onTap: () {
                                  var projectId = widget.projectId! == ''
                                      ? ""
                                      : widget.projectId!;
                                  var projectName = widget.projectName! == ''
                                      ? ""
                                      : widget.projectName!;
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                    return SalesBuyersListingView(
                                        projectId: projectId,
                                        towarId: widget.towarId!,
                                        projectName: projectName,
                                        towarName: widget.towarName!,
                                        cash_flow_gst: cash_flow_gst,
                                        totalVal: currencyFormat.format(
                                            double.parse(strPaymentReceived!)),
                                        strTypeId: "2",
                                        flagRedirect: 'SoldInventory');
                                  })).then((_) {
                                    setState(() {
                                      flagcalled == false;
                                    });
                                    fetchProjectSalesManagment();
                                  });
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    horizontalSpaceMedium,
                                    const Text('Payment Received',
                                        style: TextStyle(
                                            backgroundColor: Colors.white,
                                            fontSize: 15,
                                            color: Colors.black)),
                                    const Expanded(
                                        child: horizontalSpaceMedium),
                                    Text(
                                        currencyFormat.format(
                                            double.parse(strPaymentReceived!)),
                                        style: const TextStyle(
                                            backgroundColor: Colors.white,
                                            fontSize: 15,
                                            color: Colors.black)),
                                    IconButton(
                                        iconSize: 30,
                                        icon: const Icon(
                                            Icons.keyboard_arrow_right_rounded),
                                        color: Colors.black,
                                        onPressed: () {})
                                  ],
                                )))),
                    const Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 1,
                        endIndent: 1,
                        color: Colors.black),
                    SizedBox(
                        height: 50,
                        child: Padding(
                            padding:
                                const EdgeInsets.only(left: 40.0, right: 40.0),
                            child: InkWell(
                                onTap: () {
                                  var projectId = widget.projectId! == ''
                                      ? ""
                                      : widget.projectId!;
                                  var projectName = widget.projectName! == ''
                                      ? ""
                                      : widget.projectName!;
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                    return SalesBuyersListingView(
                                        projectId: projectId,
                                        towarId: widget.towarId!,
                                        projectName: projectName,
                                        towarName: widget.towarName!,
                                        cash_flow_gst: cash_flow_gst,
                                        strTypeId: "4",
                                        totalVal: currencyFormat.format(
                                            double.parse(strPaymentToReceive!)),
                                        flagRedirect: 'SoldInventory');
                                  })).then((_) {
                                    setState(() {
                                      flagcalled == false;
                                    });
                                    fetchProjectSalesManagment();
                                  });
                                },
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      horizontalSpaceMedium,
                                      const Text('Payment to Receive ',
                                          style: TextStyle(
                                              backgroundColor: Colors.white,
                                              fontSize: 15,
                                              color: Colors.black)),
                                      const Expanded(
                                          child: horizontalSpaceMedium),
                                      Text(
                                          currencyFormat.format(double.parse(
                                              strPaymentToReceive!)),
                                          style: const TextStyle(
                                              backgroundColor: Colors.white,
                                              fontSize: 15,
                                              color: Colors.black)),
                                      IconButton(
                                          iconSize: 30,
                                          icon: const Icon(
                                            Icons.keyboard_arrow_right_rounded,
                                          ),
                                          color: Colors.black,
                                          onPressed: () {})
                                    ])))),
                    const Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 1,
                        endIndent: 1,
                        color: Colors.black),
                    SizedBox(
                        height: 50,
                        child: Padding(
                            padding:
                                const EdgeInsets.only(left: 40.0, right: 40.0),
                            child: InkWell(
                                onTap: () {
                                  var projectId = widget.projectId! == ''
                                      ? ""
                                      : widget.projectId!;
                                  var projectName = widget.projectName! == ''
                                      ? ""
                                      : widget.projectName!;
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                    return SalesBuyersListingView(
                                        projectId: projectId,
                                        towarId: widget.towarId!,
                                        projectName: projectName,
                                        towarName: widget.towarName!,
                                        cash_flow_gst: cash_flow_gst,
                                        strTypeId: "3",
                                        totalVal: currencyFormat.format(
                                            double.parse(strPaymentOverdue!)),
                                        flagRedirect: 'SoldInventory');
                                  })).then((_) {
                                    setState(() {
                                      flagcalled == false;
                                    });
                                    fetchProjectSalesManagment();
                                  });
                                },
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      horizontalSpaceMedium,
                                      const Text('Payment Overdue ',
                                          style: TextStyle(
                                              backgroundColor: Colors.white,
                                              fontSize: 15,
                                              color: Colors.black)),
                                      const Expanded(
                                          child: horizontalSpaceMedium),
                                      Text(
                                          currencyFormat.format(
                                              double.parse(strPaymentOverdue!)),
                                          style: const TextStyle(
                                              backgroundColor: Colors.white,
                                              fontSize: 15,
                                              color: Colors.black)),
                                      IconButton(
                                          iconSize: 30,
                                          icon: const Icon(
                                            Icons.keyboard_arrow_right_rounded,
                                          ),
                                          color: Colors.black,
                                          onPressed: () {})
                                    ])))),
                    const Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 1,
                        endIndent: 1,
                        color: Colors.black),
                    Container(
                        color: Colors.black,
                        height: 40,
                        child: Padding(
                            padding:
                                const EdgeInsets.only(left: 40.0, right: 40.0),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  horizontalSpaceMedium,
                                  Text(
                                      'Unsold Inventory (${strTotalAvailableFlatArea} Sq.Ft X ${currencyFormat.format(double.parse(strUnsoldInventoryPerAmt!))})',
                                      style: const TextStyle(
                                          backgroundColor: Colors.black,
                                          fontSize: 15,
                                          color: Colors.white)),
                                  const Expanded(child: horizontalSpaceMedium),
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(right: 45.0),
                                      child: Text(
                                          currencyFormat.format(double.parse(
                                              strUnsoldInventoryTotalAmt!)),
                                          style: const TextStyle(
                                              backgroundColor: Colors.black,
                                              fontSize: 15,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)))
                                ])))
                  ]))
          : SizedBox(),
    );
  }

  Widget _salesStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: 35.0, right: 35.0, top: 25.0, bottom: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              verticalSpaceMedium,
              InkWell(
                  onTap: () {
                    var projectId =
                        widget.projectId! == '' ? "" : widget.projectId!;
                    var projectName =
                        widget.projectName! == '' ? "" : widget.projectName!;

                    if (sales_plot_flag == "1") {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return PlotDisplayView(
                          projectId: projectId,
                          towarId: widget.towarId!,
                          projectName: projectName,
                          towarName: widget.towarName!,
                          member_ship_form: member_ship_form,
                        );
                      })).then((_) {
                        setState(() {
                          flagcalled == false;
                        });
                        fetchProjectSalesManagment();
                      });
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return AvailableInventory(
                          saleAccTab: saleAccTab,
                          projectId: projectId,
                          towarId: widget.towarId!,
                          projectName: projectName,
                          towarName: widget.towarName!,
                          member_ship_form: member_ship_form,
                        );
                      })).then((_) {
                        setState(() {
                          flagcalled == false;
                        });
                        fetchProjectSalesManagment();
                      });
                    }
                  },
                  child: Container(
                      height: 100,
                      width: 170,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(
                                  0, 2), // changes position of shadow
                            ),
                          ],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10.0))),
                      child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Center(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                const Text('Available Inventory',
                                    style: TextStyle(
                                        backgroundColor: Colors.white,
                                        fontSize: 17,
                                        color: Colors.black)),
                                verticalSpaceSmall,
                                Text('$strAvailableInventory',
                                    style: const TextStyle(
                                        backgroundColor: Colors.white,
                                        fontSize: 22,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold))
                              ]))))),
              verticalSpaceMedium,
              InkWell(
                  onTap: () {
                    var projectId =
                        widget.projectId! == '' ? "" : widget.projectId!;
                    var projectName =
                        widget.projectName! == '' ? "" : widget.projectName!;
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return BookingListingView(
                          memberShipForm: member_ship_form,
                          projectId: projectId,
                          towarId: widget.towarId!,
                          projectName: projectName,
                          towarName: widget.towarName!,
                          cash_flow_gst: cash_flow_gst,
                          sales_plot_flag: sales_plot_flag,
                          flagRedirect: 'SalesRequest');
                    })).then((_) {
                      setState(() {
                        flagcalled == false;
                      });
                      fetchProjectSalesManagment();
                    });
                  },
                  child: Container(
                      height: 100,
                      width: 170,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(
                                  0, 2), // changes position of shadow
                            )
                          ],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10.0))),
                      child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Center(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                const Text('Sales Request',
                                    style: TextStyle(
                                        backgroundColor: Colors.white,
                                        fontSize: 17,
                                        color: Colors.black)),
                                verticalSpaceSmall,
                                Text('$strSaleRequest',
                                    style: const TextStyle(
                                        backgroundColor: Colors.white,
                                        fontSize: 22,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold))
                              ]))))),
              verticalSpaceMedium,
              if (saleAccTab == '1')
                InkWell(
                    onTap: () {
                      var projectId =
                          widget.projectId! == '' ? "" : widget.projectId!;
                      var projectName =
                          widget.projectName! == '' ? "" : widget.projectName!;
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return BookingListingView(
                            memberShipForm: member_ship_form,
                            projectId: projectId,
                            towarId: widget.towarId!,
                            projectName: projectName,
                            towarName: widget.towarName,
                            cash_flow_gst: cash_flow_gst,
                            sales_plot_flag: sales_plot_flag,
                            flagRedirect: 'SoldInventory');
                      })).then((_) {
                        setState(() {
                          flagcalled == false;
                        });
                        fetchProjectSalesManagment();
                      });
                    },
                    child: Container(
                        height: 100,
                        width: 170,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2))
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0))),
                        child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Center(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                  const Text('Sold Inventory',
                                      style: TextStyle(
                                          backgroundColor: Colors.white,
                                          fontSize: 17,
                                          color: Colors.black)),
                                  verticalSpaceSmall,
                                  Text('$strSoldinventory',
                                      style: const TextStyle(
                                          backgroundColor: Colors.white,
                                          fontSize: 22,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold))
                                ]))))),
              verticalSpaceMedium,
              InkWell(
                onTap: () {
                  var projectId =
                      widget.projectId! == '' ? "" : widget.projectId!;
                  var projectName =
                      widget.projectName! == '' ? "" : widget.projectName!;
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return BookingListingView(
                        memberShipForm: member_ship_form,
                        projectId: projectId,
                        towarId: widget.towarId!,
                        projectName: projectName,
                        towarName: widget.towarName,
                        cash_flow_gst: cash_flow_gst,
                        sales_plot_flag: sales_plot_flag,
                        flagRedirect: 'Reserve');
                  })).then((_) {
                    setState(() {
                      flagcalled == false;
                    });
                    fetchProjectSalesManagment();
                  });
                },
                child: Container(
                  height: 100,
                  width: 170,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset:
                              const Offset(0, 2), // changes position of shadow
                        ),
                      ],
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0))),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Reserved Inventory',
                              style: TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 17,
                                  color: Colors.black)),
                          verticalSpaceSmall,
                          Text('$strReservedInventory',
                              style: const TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 22,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              verticalSpaceMedium,
            ],
          ),
        ),
      ],
    );
  }

  Widget _bookasale() {
    return Container(
      padding: const EdgeInsets.only(
          left: 35.0, right: 35.0, top: 25.0, bottom: 18.0),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () {
              var projectId = widget.projectId!;
              var projectName = widget.projectName!;
              if (member_ship_form == "1") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return MembershipFormView(
                          memberShipform: member_ship_form,
                          projectId: projectId,
                          towarId: widget.towarId!,
                          projectName: projectName,
                          flagRedirect: 'BookNewSale');
                    },
                  ),
                ).then((_) {
                  setState(() {
                    flagcalled == false;
                  });
                  fetchProjectSalesManagment();
                });
              } else {
                if (sales_plot_flag == "1") {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return PlotDisplayView(
                      projectId: projectId,
                      towarId: widget.towarId!,
                      projectName: projectName,
                      towarName: widget.towarName!,
                      member_ship_form: member_ship_form,
                    );
                  })).then((_) {
                    setState(() {
                      flagcalled == false;
                    });
                    fetchProjectSalesManagment();
                  });
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return BookaSaleFormView(
                            projectId: projectId,
                            towarId: widget.towarId!,
                            projectName: projectName,
                            flagRedirect: 'BookNewSale');
                      },
                    ),
                  ).then((_) {
                    setState(() {
                      flagcalled == false;
                    });
                    fetchProjectSalesManagment();
                  });
                }
              }
            },
            child: Container(
              height: 70,
              width: 200,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2), // changes position of shadow
                    ),
                  ],
                  borderRadius: const BorderRadius.all(Radius.circular(10.0))),
              child: const Padding(
                padding: EdgeInsets.all(15.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('BOOK A SALE', style: boldText),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (saleAccTab == '1')
            InkWell(
              onTap: () {
                var projectId = widget.projectId!;
                var projectName = widget.projectName!;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return CashFlowView(
                        projectId: projectId,
                        projectName: projectName,
                        towarId: widget.towarId!,
                        towarName: widget.towarName!,
                        cashflowgst: cash_flow_gst,
                      );
                    },
                  ),
                ).then((_) {
                  setState(() {
                    flagcalled == false;
                  });
                  fetchProjectSalesManagment();
                });
              },
              child: Container(
                height: 70,
                width: 200,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset:
                            const Offset(0, 2), // changes position of shadow
                      ),
                    ],
                    borderRadius:
                        const BorderRadius.all(Radius.circular(10.0))),
                child: const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('CASH FLOW', style: boldText),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (saleAccTab == '1' && member_ship_form != "1")
            InkWell(
              onTap: () {
                var projectId = widget.projectId!;
                var projectName = widget.projectName!;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return BrokerManagementList(
                          towarId: widget.towarId,
                          towarName: widget.towarName,
                          projectId: projectId,
                          projectName: projectName,
                          flagRedirect: 'CashFlow');
                    },
                  ),
                ).then((_) {
                  setState(() {
                    flagcalled == false;
                  });
                  // fetchPSrojectAccountManagment();
                });
              },
              child: Container(
                height: 70,
                width: 200,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset:
                            const Offset(0, 2), // changes position of shadow
                      ),
                    ],
                    borderRadius:
                        const BorderRadius.all(Radius.circular(10.0))),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('CP MANAGEMENT', style: boldText),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stallion/ui/views/accountmanagement/worequested.dart';
// import 'package:stallion/ui/views/salesmanagement/availableInventory/availableInventory.dart';
// import 'package:stallion/ui/views/salesmanagement/brochure/salesBrochure.dart';
// import 'package:stallion/ui/views/salesmanagement/brokerManagement/brokerManagementList.dart';
// import 'package:stallion/ui/views/salesmanagement/cashflowview.dart';
// import 'package:stallion/ui/views/salesmanagement/membershipform.dart';
// import 'package:stallion/ui/views/salesmanagement/plotdisplayview.dart';
// import 'package:stallion/ui/views/salesmanagement/salesbuyerslisting.dart';
// import 'package:stallion/ui/views/salesmanagement/salesleads/salesleadPage.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../../models/get_sale_management_main.dart';
// import '../../../utils/api_network_call.dart';
// import '../../../utils/app_url.dart';
// import '../../shared/ui_helpers.dart';
// import 'bookasaleview.dart';
// import 'bookinglistingview.dart';

// class SalesManagementView extends StatefulWidget {
//   SalesManagementView({
//     super.key,
//     this.projectId,
//     this.towarId,
//     this.projectName,
//     this.towarName,
//     this.navigationFlag,
//   });

//   String? projectId;
//   String? towarId;
//   String? projectName;
//   String? navigationFlag;
//   String? towarName;
//   @override
//   State<SalesManagementView> createState() => _SalesManagementViewState();
// }

// class _SalesManagementViewState extends State<SalesManagementView> {
//   final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
//   NetworkHandler apiNetworkHandler = NetworkHandler();
//   String? downloadLink = '';

//   bool cash_flow_gst = false;
//   bool flagcalled = false;
//   ProjectBuyerList? projectBuyerList;
//   String? strAvailableInventory = '';
//   String? strSaleRequest = '';
//   String? strSoldinventory = '';
//   String? strReservedInventory = '';
//   String? strTotalSold = '';
//   String? strTotalSoldSqFt = '';
//   String? strTotalAvailableFlatArea = '';
//   String? strTotalSoldPerAmt = '';
//   String? strPaymentReceived = '';
//   String? strPaymentToReceive = '';
//   String? strPaymentOverdue = '';
//   String? strUnsoldInventoryTotalAmt = '';
//   String? strUnsoldInventorySqft = '';
//   String? strUnsoldInventoryPerAmt = '';
//   String? strTowarName = "All Tower";
//   List<TowarList>? orderList;
//   String? member_ship_form = "0";
//   String? sales_plot_flag = "0";
//   String? saleAccTab = '0';
//   String? showLeads = '';

//   Future<ResponseGetProjectBuyerInventory?> fetchProjectSalesManagment() async {
//     final SharedPreferences prefs = await _prefs;
//     String? userId = prefs.getString('mobileNo');

//     String towerId = "";
//     if (widget.towarId != null) {
//       towerId = widget.towarId!;
//     }

//     String gst = "0";
//     if (cash_flow_gst == true) {
//       gst = '1';
//     }

//     Map<String, String> data = {
//       "user_id": userId!,
//       "project_id": widget.projectId!,
//       "towar_id": towerId,
//       "gst_flag": gst,
//     };

//     if (kDebugMode) {
//       print(data);
//     }

//     var response =
//         await apiNetworkHandler.post(AppUrl.webgetprojectbuyerinventory, data);
//     if (kDebugMode) {
//       print(response.statusCode);
//     }
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final dataModel = getProjectBuyerInventoryFromJson(response.body);
//       if (kDebugMode) {
//         print(dataModel.response?.errorCode);
//       }
//       if (dataModel.response?.errorCode == "0") {
//         downloadLink = dataModel.response?.downloadLink;

//         showLeads = dataModel.response?.showLeads;
//         var projects = dataModel.response?.orderList!;

//         member_ship_form = dataModel.response?.member_ship_form!;
//         sales_plot_flag = dataModel.response?.sales_plot_flag!;

//         orderList = [];

//         if (projects!.isNotEmpty) {
//           var dict = TowarList(towarId: "", towarName: "All Towers");
//           orderList!.add(dict);

//           for (int i = 0; i < projects.length; i++) {
//             if (projects[i].id == widget.projectId) {
//               var towar = projects[i].towarList!;
//               for (int j = 0; j < towar.length; j++) {
//                 if (towar[j].towarId == widget.towarId) {
//                   strTowarName = towar[j].towarName!;
//                 }
//                 orderList!.add(towar[j]);
//               }
//               break;
//             }
//           }
//         }
//         setState(() {
//           saleAccTab = dataModel.response?.saleAccTab;
//           flagcalled = true;
//           strTotalSold = '${dataModel.response?.projectBuyerList?.totalSold}';
//           strPaymentReceived =
//               '${dataModel.response?.projectBuyerList?.totalReceive}';
//           var totalReceived =
//               double.parse(strTotalSold!) - double.parse(strPaymentReceived!);
//           strPaymentToReceive = '$totalReceived';
//           strPaymentOverdue =
//               '${dataModel.response?.projectBuyerList?.paymentToCollect}';
//           strAvailableInventory =
//               '${dataModel.response?.projectBuyerList?.avaliableInventory}';
//           strSoldinventory =
//               '${dataModel.response?.projectBuyerList?.inventrySold}';
//           strSaleRequest =
//               '${dataModel.response?.projectBuyerList?.flatRequest}';
//           strReservedInventory =
//               '${dataModel.response?.projectBuyerList?.flatReserved}';
//           strTotalSoldSqFt =
//               '${dataModel.response?.projectBuyerList?.totalSoldFlatArea}';
//           strTotalAvailableFlatArea =
//               '${dataModel.response?.projectBuyerList?.totalAviFlatArea}';
//           strUnsoldInventoryTotalAmt =
//               '${dataModel.response?.projectBuyerList?.unsoldInventory}';
//           strUnsoldInventorySqft =
//               '${dataModel.response?.projectBuyerList?.totalSoldFlatArea}';
//           strUnsoldInventoryPerAmt =
//               '${dataModel.response?.projectBuyerList?.avgFlatRate}';
//           strTotalSoldPerAmt =
//               '${dataModel.response?.projectBuyerList?.newAvgFlatRate}';
//         });
//       }
//     } else {
//       if (kDebugMode) {
//         print(response.body);
//       }
//       return null;
//     }
//     return null;
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchProjectSalesManagment();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: Text(
//             widget.towarName != ''
//                 ? '${widget.projectName?.toUpperCase()} - ${widget.towarName?.toUpperCase()}'
//                 : widget.projectName?.toUpperCase() ?? '',
//             style:
//                 const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
//         leading: widget.navigationFlag! == 'SideMenu'
//             ? const SizedBox()
//             : IconButton(
//                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//                 onPressed: () {
//                   Navigator.maybePop(context);
//                 },
//               ),
//         actions: [
//           if (showLeads != '0')
//             InkWell(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) {
//                       return SalesLeadPage(
//                         projectId: widget.projectId,
//                         towarId: widget.towarId,
//                         projectName: widget.projectName,
//                         navigationFlag: widget.navigationFlag,
//                         towarName: widget.towarName,
//                       );
//                     },
//                   ),
//                 );
//               },
//               child: Container(
//                 margin: const EdgeInsets.symmetric(vertical: 12),
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.white, width: 2),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 // decoration: BoxDecoration(
//                 //   color: Colors.white,
//                 //   borderRadius: BorderRadius.circular(8),
//                 // ),
//                 child: const Center(
//                   child: Text(
//                     "LEADS",
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ),
//           const SizedBox(width: 28),
//           InkWell(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) {
//                       return SalesBrochure(
//                         projectId: widget.projectId,
//                         towarId: widget.towarId,
//                         projectName: widget.projectName,
//                         towarName: widget.towarName,
//                       );
//                     },
//                   ),
//                 );
//               },
//               child: Image.asset(
//                 'images/projectmanagement/planbrocher.png',
//                 height: 30,
//                 width: 30,
//               )
//               // const Icon(Icons.catching_pokemon),
//               ),
//           const SizedBox(width: 32),
//         ],
//       ),
//       body: Container(
//         child: flagcalled == true
//             ? Builder(builder: (context) {
//                 return SingleChildScrollView(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       verticalSpaceTiny,
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           SizedBox(width: 24),
//                           InkWell(
//                             onTap: () async {
//                               if (downloadLink != null &&
//                                   downloadLink!.isNotEmpty) {
//                                 final uri = Uri.parse(downloadLink!);
//                                 if (await canLaunchUrl(uri)) {
//                                   await launchUrl(uri);
//                                 } else {
//                                   throw 'Could not launch';
//                                 }
//                               }
//                             },
//                             child: Container(
//                               // margin: const EdgeInsets.symmetric(vertical: 12),
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 4),
//                               decoration: BoxDecoration(
//                                 border:
//                                     Border.all(color: Colors.black, width: 1),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               // decoration: BoxDecoration(
//                               //   color: Colors.white,
//                               //   borderRadius: BorderRadius.circular(8),
//                               // ),
//                               child: const Center(
//                                 child: Text(
//                                   "Overview",
//                                   style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w400),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const Spacer(),
//                           horizontalSpaceLarge,
//                           horizontalSpaceLarge,
//                           horizontalSpaceLarge,
//                           const Center(
//                             child: Text('SALES MANAGEMENT',
//                                 style: TextStyle(
//                                     fontStyle: FontStyle.normal,
//                                     fontSize: 17.0)),
//                           ),
//                           const Spacer(),
//                           Row(
//                             children: [
//                               const Text('GST',
//                                   style: TextStyle(
//                                       fontStyle: FontStyle.normal,
//                                       fontSize: 17.0)),
//                               Switch(
//                                 // thumb color (round icon)
//                                 activeColor: Colors.white,
//                                 activeTrackColor: Colors.green,
//                                 inactiveThumbColor: Colors.white,
//                                 inactiveTrackColor: Colors.grey.shade400,
//                                 splashRadius: 40.0,
//                                 // boolean variable value
//                                 value: cash_flow_gst,
//                                 // changes the state of the switch
//                                 onChanged: (value) {
//                                   setState(() => cash_flow_gst = value);
//                                   fetchProjectSalesManagment();
//                                 },
//                               ),
//                               horizontalSpaceMedium
//                             ],
//                           ),
//                         ],
//                       ),
//                       verticalSpaceTiny,
//                       const Divider(
//                         height: 1,
//                         thickness: 0.5,
//                         indent: 1,
//                         endIndent: 1,
//                         color: Colors.black,
//                       ),
//                       widget.navigationFlag! != 'SideMenu'
//                           ? orderList!.length >= 2
//                               ? InkWell(
//                                   onTap: () {
//                                     showDialog(
//                                         barrierDismissible: false,
//                                         context: context,
//                                         builder:
//                                             (BuildContext context) => Dialog(
//                                                   elevation: 0,
//                                                   child: SizedBox(
//                                                     height: 400,
//                                                     width: 360.0,
//                                                     child: Column(
//                                                       children: [
//                                                         const Padding(
//                                                           padding:
//                                                               EdgeInsets.only(
//                                                                   top: 5.0,
//                                                                   bottom: 5),
//                                                           child: Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .center,
//                                                             children: [
//                                                               Text(
//                                                                 'SELECT TOWER',
//                                                                 style: TextStyle(
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .bold),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                         Divider(
//                                                           color: Colors
//                                                               .grey.shade500,
//                                                           thickness: 1.5,
//                                                         ),
//                                                         SizedBox(
//                                                           height: 310,
//                                                           width: 360,
//                                                           child:
//                                                               ListView.builder(
//                                                                   itemCount:
//                                                                       orderList
//                                                                           ?.length,
//                                                                   itemBuilder:
//                                                                       (context,
//                                                                           index) {
//                                                                     return Column(
//                                                                       children: [
//                                                                         InkWell(
//                                                                           onTap:
//                                                                               () {
//                                                                             widget.towarId =
//                                                                                 orderList![index].towarId!;
//                                                                             setState(() {
//                                                                               strTowarName = orderList![index].towarName!;
//                                                                             });
//                                                                             widget.towarName =
//                                                                                 orderList![index].towarName!;
//                                                                             fetchProjectSalesManagment();
//                                                                             Navigator.of(context).pop();
//                                                                           },
//                                                                           child: Row(
//                                                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                                               children: [
//                                                                                 Padding(
//                                                                                   padding: const EdgeInsets.only(left: 10.0, bottom: 20.0, top: 15.0),
//                                                                                   child: Text(orderList![index].towarName!),
//                                                                                 ),
//                                                                                 Padding(
//                                                                                   padding: const EdgeInsets.only(right: 10.0),
//                                                                                   child: Icon(
//                                                                                     widget.towarId == orderList![index].towarId! ? Icons.check_circle_outline_sharp : Icons.circle_outlined,
//                                                                                     color: widget.towarId == orderList![index].towarId! ? Colors.green : Colors.grey,
//                                                                                     size: 26,
//                                                                                   ),
//                                                                                 ),
//                                                                               ]),
//                                                                         ),
//                                                                         const Divider(
//                                                                           height:
//                                                                               1,
//                                                                           thickness:
//                                                                               0.5,
//                                                                           color:
//                                                                               Colors.black,
//                                                                         ),
//                                                                       ],
//                                                                     );
//                                                                   }),
//                                                         ),
//                                                         Expanded(
//                                                           child: InkWell(
//                                                             onTap: () {
//                                                               Navigator.of(
//                                                                       context)
//                                                                   .pop();
//                                                             },
//                                                             child: Container(
//                                                               width: double
//                                                                   .infinity,
//                                                               color:
//                                                                   Colors.black,
//                                                               child:
//                                                                   const Padding(
//                                                                 padding: EdgeInsets
//                                                                     .only(
//                                                                         top:
//                                                                             13.0),
//                                                                 child: Text(
//                                                                   'OK',
//                                                                   style: TextStyle(
//                                                                       color: Colors
//                                                                           .white,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .bold,
//                                                                       fontSize:
//                                                                           15),
//                                                                   textAlign:
//                                                                       TextAlign
//                                                                           .center,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ));
//                                   },
//                                   child: SizedBox(
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Text(strTowarName!.toUpperCase(),
//                                             style: const TextStyle(
//                                                 fontStyle: FontStyle.normal,
//                                                 fontSize: 17.0)),
//                                         horizontalSpaceSmall,
//                                         IconButton(
//                                           icon: const Icon(
//                                               Icons.arrow_drop_down,
//                                               color: Colors.black),
//                                           onPressed: () {},
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 )
//                               : const SizedBox()
//                           : const SizedBox(),
//                       widget.navigationFlag! != 'SideMenu'
//                           ? orderList!.length >= 2
//                               ? const Divider(
//                                   height: 1,
//                                   thickness: 0.5,
//                                   indent: 1,
//                                   endIndent: 1,
//                                   color: Colors.black,
//                                 )
//                               : const SizedBox()
//                           : const SizedBox(),
//                       Padding(
//                         padding: const EdgeInsets.only(
//                             top: 15.0, left: 70.0, right: 70.0),
//                         child: Stack(children: [
//                           Padding(
//                               padding: const EdgeInsets.only(top: 15.0),
//                               child: Container(
//                                   decoration: BoxDecoration(
//                                     border: Border.all(color: Colors.grey),
//                                     borderRadius: BorderRadius.circular(10),
//                                     color: Colors.white,
//                                     shape: BoxShape.rectangle,
//                                   ),
//                                   child: _salesStatus())),
//                           Padding(
//                             padding: const EdgeInsets.only(left: 15.0),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.black),
//                                 borderRadius: BorderRadius.circular(17),
//                                 color: Colors.white,
//                                 shape: BoxShape.rectangle,
//                               ),
//                               height: 35.0,
//                               child: const Padding(
//                                 padding: EdgeInsets.all(8.0),
//                                 child: Text(' SALES MANAGEMENT ',
//                                     style: TextStyle(
//                                         fontSize: 13, color: Colors.black)),
//                               ),
//                             ),
//                           ),
//                         ]),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 70.0, right: 70.0),
//                         child: _bookasale(),
//                       ),
//                     ],
//                   ),
//                 );
//               })
//             : Center(
//                 child: SizedBox(
//                   height: 64,
//                   child: OverflowBox(
//                     minHeight: 100,
//                     maxHeight: 100,
//                     child: Lottie.asset(
//                       'assets/animation/running2.json',
//                       // 'assets/animation/chatbotfinallotiie.json',
//                       repeat: true,
//                     ),
//                   ),
//                 ),
//               ),
//       ),
//       bottomNavigationBar: saleAccTab == '1'
//           ? SizedBox(
//               height: 280,
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const Expanded(child: SizedBox()),
//                     Text(
//                         'Next Price To Achieve Average : ${currencyFormat.format(double.parse(strTotalSoldPerAmt!))}',
//                         style: boldText),
//                     verticalSpaceSmall,
//                     const Divider(
//                         height: 1,
//                         thickness: 0.5,
//                         indent: 1,
//                         endIndent: 1,
//                         color: Colors.black),
//                     SizedBox(
//                       height: 50,
//                       child: Padding(
//                         padding: const EdgeInsets.only(left: 40.0, right: 40.0),
//                         child: InkWell(
//                           onTap: () {
//                             var projectId = widget.projectId! == ''
//                                 ? ""
//                                 : widget.projectId!;
//                             var projectName = widget.projectName! == ''
//                                 ? ""
//                                 : widget.projectName!;
//                             Navigator.push(context,
//                                 MaterialPageRoute(builder: (_) {
//                               return SalesBuyersListingView(
//                                   projectId: projectId,
//                                   towarId: widget.towarId!,
//                                   projectName: projectName,
//                                   towarName: widget.towarName!,
//                                   cash_flow_gst: cash_flow_gst,
//                                   totalVal: currencyFormat
//                                       .format(double.parse(strTotalSold!)),
//                                   strTypeId: "1",
//                                   flagRedirect: 'SoldInventory');
//                             })).then((_) {
//                               setState(() {
//                                 flagcalled == false;
//                               });
//                               fetchProjectSalesManagment();
//                             });
//                           },
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               horizontalSpaceMedium,
//                               Text(
//                                   'Total Sold ${strUnsoldInventorySqft != "0" ? '(${strUnsoldInventorySqft!} Sq.Ft. X ${currencyFormat.format(double.parse(strTotalSold!) / double.parse(strTotalSoldSqFt!))})' : ""} ',
//                                   style: const TextStyle(
//                                       backgroundColor: Colors.white,
//                                       fontSize: 15,
//                                       color: Colors.black)),
//                               const Expanded(child: horizontalSpaceMedium),
//                               Text(
//                                   currencyFormat
//                                       .format(double.parse(strTotalSold!)),
//                                   style: const TextStyle(
//                                       backgroundColor: Colors.white,
//                                       fontSize: 15,
//                                       color: Colors.black)),
//                               IconButton(
//                                 iconSize: 30,
//                                 icon: const Icon(
//                                   Icons.keyboard_arrow_right_rounded,
//                                 ),
//                                 color: Colors.black,
//                                 onPressed: () {},
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     const Divider(
//                       height: 1,
//                       thickness: 0.5,
//                       indent: 1,
//                       endIndent: 1,
//                       color: Colors.black,
//                     ),
//                     SizedBox(
//                         height: 50,
//                         child: Padding(
//                             padding:
//                                 const EdgeInsets.only(left: 40.0, right: 40.0),
//                             child: InkWell(
//                                 onTap: () {
//                                   var projectId = widget.projectId! == ''
//                                       ? ""
//                                       : widget.projectId!;
//                                   var projectName = widget.projectName! == ''
//                                       ? ""
//                                       : widget.projectName!;
//                                   Navigator.push(context,
//                                       MaterialPageRoute(builder: (_) {
//                                     return SalesBuyersListingView(
//                                         projectId: projectId,
//                                         towarId: widget.towarId!,
//                                         projectName: projectName,
//                                         towarName: widget.towarName!,
//                                         cash_flow_gst: cash_flow_gst,
//                                         totalVal: currencyFormat.format(
//                                             double.parse(strPaymentReceived!)),
//                                         strTypeId: "2",
//                                         flagRedirect: 'SoldInventory');
//                                   })).then((_) {
//                                     setState(() {
//                                       flagcalled == false;
//                                     });
//                                     fetchProjectSalesManagment();
//                                   });
//                                 },
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     horizontalSpaceMedium,
//                                     const Text('Payment Received',
//                                         style: TextStyle(
//                                             backgroundColor: Colors.white,
//                                             fontSize: 15,
//                                             color: Colors.black)),
//                                     const Expanded(
//                                         child: horizontalSpaceMedium),
//                                     Text(
//                                         currencyFormat.format(
//                                             double.parse(strPaymentReceived!)),
//                                         style: const TextStyle(
//                                             backgroundColor: Colors.white,
//                                             fontSize: 15,
//                                             color: Colors.black)),
//                                     IconButton(
//                                         iconSize: 30,
//                                         icon: const Icon(
//                                             Icons.keyboard_arrow_right_rounded),
//                                         color: Colors.black,
//                                         onPressed: () {})
//                                   ],
//                                 )))),
//                     const Divider(
//                         height: 1,
//                         thickness: 0.5,
//                         indent: 1,
//                         endIndent: 1,
//                         color: Colors.black),
//                     SizedBox(
//                         height: 50,
//                         child: Padding(
//                             padding:
//                                 const EdgeInsets.only(left: 40.0, right: 40.0),
//                             child: InkWell(
//                                 onTap: () {
//                                   var projectId = widget.projectId! == ''
//                                       ? ""
//                                       : widget.projectId!;
//                                   var projectName = widget.projectName! == ''
//                                       ? ""
//                                       : widget.projectName!;
//                                   Navigator.push(context,
//                                       MaterialPageRoute(builder: (_) {
//                                     return SalesBuyersListingView(
//                                         projectId: projectId,
//                                         towarId: widget.towarId!,
//                                         projectName: projectName,
//                                         towarName: widget.towarName!,
//                                         cash_flow_gst: cash_flow_gst,
//                                         strTypeId: "4",
//                                         totalVal: currencyFormat.format(
//                                             double.parse(strPaymentToReceive!)),
//                                         flagRedirect: 'SoldInventory');
//                                   })).then((_) {
//                                     setState(() {
//                                       flagcalled == false;
//                                     });
//                                     fetchProjectSalesManagment();
//                                   });
//                                 },
//                                 child: Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [
//                                       horizontalSpaceMedium,
//                                       const Text('Payment to Receive ',
//                                           style: TextStyle(
//                                               backgroundColor: Colors.white,
//                                               fontSize: 15,
//                                               color: Colors.black)),
//                                       const Expanded(
//                                           child: horizontalSpaceMedium),
//                                       Text(
//                                           currencyFormat.format(double.parse(
//                                               strPaymentToReceive!)),
//                                           style: const TextStyle(
//                                               backgroundColor: Colors.white,
//                                               fontSize: 15,
//                                               color: Colors.black)),
//                                       IconButton(
//                                           iconSize: 30,
//                                           icon: const Icon(
//                                             Icons.keyboard_arrow_right_rounded,
//                                           ),
//                                           color: Colors.black,
//                                           onPressed: () {})
//                                     ])))),
//                     const Divider(
//                         height: 1,
//                         thickness: 0.5,
//                         indent: 1,
//                         endIndent: 1,
//                         color: Colors.black),
//                     SizedBox(
//                         height: 50,
//                         child: Padding(
//                             padding:
//                                 const EdgeInsets.only(left: 40.0, right: 40.0),
//                             child: InkWell(
//                                 onTap: () {
//                                   var projectId = widget.projectId! == ''
//                                       ? ""
//                                       : widget.projectId!;
//                                   var projectName = widget.projectName! == ''
//                                       ? ""
//                                       : widget.projectName!;
//                                   Navigator.push(context,
//                                       MaterialPageRoute(builder: (_) {
//                                     return SalesBuyersListingView(
//                                         projectId: projectId,
//                                         towarId: widget.towarId!,
//                                         projectName: projectName,
//                                         towarName: widget.towarName!,
//                                         cash_flow_gst: cash_flow_gst,
//                                         strTypeId: "3",
//                                         totalVal: currencyFormat.format(
//                                             double.parse(strPaymentOverdue!)),
//                                         flagRedirect: 'SoldInventory');
//                                   })).then((_) {
//                                     setState(() {
//                                       flagcalled == false;
//                                     });
//                                     fetchProjectSalesManagment();
//                                   });
//                                 },
//                                 child: Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [
//                                       horizontalSpaceMedium,
//                                       const Text('Payment Overdue ',
//                                           style: TextStyle(
//                                               backgroundColor: Colors.white,
//                                               fontSize: 15,
//                                               color: Colors.black)),
//                                       const Expanded(
//                                           child: horizontalSpaceMedium),
//                                       Text(
//                                           currencyFormat.format(
//                                               double.parse(strPaymentOverdue!)),
//                                           style: const TextStyle(
//                                               backgroundColor: Colors.white,
//                                               fontSize: 15,
//                                               color: Colors.black)),
//                                       IconButton(
//                                           iconSize: 30,
//                                           icon: const Icon(
//                                             Icons.keyboard_arrow_right_rounded,
//                                           ),
//                                           color: Colors.black,
//                                           onPressed: () {})
//                                     ])))),
//                     const Divider(
//                         height: 1,
//                         thickness: 0.5,
//                         indent: 1,
//                         endIndent: 1,
//                         color: Colors.black),
//                     Container(
//                         color: Colors.black,
//                         height: 40,
//                         child: Padding(
//                             padding:
//                                 const EdgeInsets.only(left: 40.0, right: 40.0),
//                             child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 mainAxisAlignment: MainAxisAlignment.end,
//                                 children: [
//                                   horizontalSpaceMedium,
//                                   Text(
//                                       'Unsold Inventory (${strTotalAvailableFlatArea} Sq.Ft X ${currencyFormat.format(double.parse(strUnsoldInventoryPerAmt!))})',
//                                       style: const TextStyle(
//                                           backgroundColor: Colors.black,
//                                           fontSize: 15,
//                                           color: Colors.white)),
//                                   const Expanded(child: horizontalSpaceMedium),
//                                   Padding(
//                                       padding:
//                                           const EdgeInsets.only(right: 45.0),
//                                       child: Text(
//                                           currencyFormat.format(double.parse(
//                                               strUnsoldInventoryTotalAmt!)),
//                                           style: const TextStyle(
//                                               backgroundColor: Colors.black,
//                                               fontSize: 15,
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.bold)))
//                                 ])))
//                   ]))
//           : SizedBox(),
//     );
//   }

//   Widget _salesStatus() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(
//               left: 35.0, right: 35.0, top: 25.0, bottom: 20.0),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               verticalSpaceMedium,
//               InkWell(
//                   onTap: () {
//                     var projectId =
//                         widget.projectId! == '' ? "" : widget.projectId!;
//                     var projectName =
//                         widget.projectName! == '' ? "" : widget.projectName!;

//                     if (sales_plot_flag == "1") {
//                       Navigator.push(context, MaterialPageRoute(builder: (_) {
//                         return PlotDisplayView(
//                           projectId: projectId,
//                           towarId: widget.towarId!,
//                           projectName: projectName,
//                           towarName: widget.towarName!,
//                           member_ship_form: member_ship_form,
//                         );
//                       })).then((_) {
//                         setState(() {
//                           flagcalled == false;
//                         });
//                         fetchProjectSalesManagment();
//                       });
//                     } else {
//                       Navigator.push(context, MaterialPageRoute(builder: (_) {
//                         return AvailableInventory(
//                           saleAccTab: saleAccTab,
//                           projectId: projectId,
//                           towarId: widget.towarId!,
//                           projectName: projectName,
//                           towarName: widget.towarName!,
//                           member_ship_form: member_ship_form,
//                         );
//                       })).then((_) {
//                         setState(() {
//                           flagcalled == false;
//                         });
//                         fetchProjectSalesManagment();
//                       });
//                     }
//                   },
//                   child: Container(
//                       height: 100,
//                       width: 170,
//                       decoration: BoxDecoration(
//                           color: Colors.white,
//                           border: Border.all(color: Colors.grey),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.5),
//                               spreadRadius: 1,
//                               blurRadius: 3,
//                               offset: const Offset(
//                                   0, 2), // changes position of shadow
//                             ),
//                           ],
//                           borderRadius:
//                               const BorderRadius.all(Radius.circular(10.0))),
//                       child: Padding(
//                           padding: const EdgeInsets.all(15.0),
//                           child: Center(
//                               child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                 const Text('Available Inventory',
//                                     style: TextStyle(
//                                         backgroundColor: Colors.white,
//                                         fontSize: 17,
//                                         color: Colors.black)),
//                                 verticalSpaceSmall,
//                                 Text('$strAvailableInventory',
//                                     style: const TextStyle(
//                                         backgroundColor: Colors.white,
//                                         fontSize: 22,
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.bold))
//                               ]))))),
//               verticalSpaceMedium,
//               InkWell(
//                   onTap: () {
//                     var projectId =
//                         widget.projectId! == '' ? "" : widget.projectId!;
//                     var projectName =
//                         widget.projectName! == '' ? "" : widget.projectName!;
//                     Navigator.push(context, MaterialPageRoute(builder: (_) {
//                       return BookingListingView(
//                           memberShipForm: member_ship_form,
//                           projectId: projectId,
//                           towarId: widget.towarId!,
//                           projectName: projectName,
//                           towarName: widget.towarName!,
//                           cash_flow_gst: cash_flow_gst,
//                           sales_plot_flag: sales_plot_flag,
//                           flagRedirect: 'SalesRequest');
//                     })).then((_) {
//                       setState(() {
//                         flagcalled == false;
//                       });
//                       fetchProjectSalesManagment();
//                     });
//                   },
//                   child: Container(
//                       height: 100,
//                       width: 170,
//                       decoration: BoxDecoration(
//                           color: Colors.white,
//                           border: Border.all(color: Colors.grey),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.5),
//                               spreadRadius: 1,
//                               blurRadius: 3,
//                               offset: const Offset(
//                                   0, 2), // changes position of shadow
//                             )
//                           ],
//                           borderRadius:
//                               const BorderRadius.all(Radius.circular(10.0))),
//                       child: Padding(
//                           padding: const EdgeInsets.all(15.0),
//                           child: Center(
//                               child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                 const Text('Sales Request',
//                                     style: TextStyle(
//                                         backgroundColor: Colors.white,
//                                         fontSize: 17,
//                                         color: Colors.black)),
//                                 verticalSpaceSmall,
//                                 Text('$strSaleRequest',
//                                     style: const TextStyle(
//                                         backgroundColor: Colors.white,
//                                         fontSize: 22,
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.bold))
//                               ]))))),
//               verticalSpaceMedium,
//               if (saleAccTab == '1')
//                 InkWell(
//                     onTap: () {
//                       var projectId =
//                           widget.projectId! == '' ? "" : widget.projectId!;
//                       var projectName =
//                           widget.projectName! == '' ? "" : widget.projectName!;
//                       Navigator.push(context, MaterialPageRoute(builder: (_) {
//                         return BookingListingView(
//                             memberShipForm: member_ship_form,
//                             projectId: projectId,
//                             towarId: widget.towarId!,
//                             projectName: projectName,
//                             towarName: widget.towarName,
//                             cash_flow_gst: cash_flow_gst,
//                             sales_plot_flag: sales_plot_flag,
//                             flagRedirect: 'SoldInventory');
//                       })).then((_) {
//                         setState(() {
//                           flagcalled == false;
//                         });
//                         fetchProjectSalesManagment();
//                       });
//                     },
//                     child: Container(
//                         height: 100,
//                         width: 170,
//                         decoration: BoxDecoration(
//                             color: Colors.white,
//                             border: Border.all(
//                               color: Colors.grey,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                   color: Colors.grey.withOpacity(0.5),
//                                   spreadRadius: 1,
//                                   blurRadius: 3,
//                                   offset: const Offset(0, 2))
//                             ],
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(10.0))),
//                         child: Padding(
//                             padding: const EdgeInsets.all(15.0),
//                             child: Center(
//                                 child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                   const Text('Sold Inventory',
//                                       style: TextStyle(
//                                           backgroundColor: Colors.white,
//                                           fontSize: 17,
//                                           color: Colors.black)),
//                                   verticalSpaceSmall,
//                                   Text('$strSoldinventory',
//                                       style: const TextStyle(
//                                           backgroundColor: Colors.white,
//                                           fontSize: 22,
//                                           color: Colors.black,
//                                           fontWeight: FontWeight.bold))
//                                 ]))))),
//               verticalSpaceMedium,
//               InkWell(
//                 onTap: () {
//                   var projectId =
//                       widget.projectId! == '' ? "" : widget.projectId!;
//                   var projectName =
//                       widget.projectName! == '' ? "" : widget.projectName!;
//                   Navigator.push(context, MaterialPageRoute(builder: (_) {
//                     return BookingListingView(
//                         memberShipForm: member_ship_form,
//                         projectId: projectId,
//                         towarId: widget.towarId!,
//                         projectName: projectName,
//                         towarName: widget.towarName,
//                         cash_flow_gst: cash_flow_gst,
//                         sales_plot_flag: sales_plot_flag,
//                         flagRedirect: 'Reserve');
//                   })).then((_) {
//                     setState(() {
//                       flagcalled == false;
//                     });
//                     fetchProjectSalesManagment();
//                   });
//                 },
//                 child: Container(
//                   height: 100,
//                   width: 170,
//                   decoration: BoxDecoration(
//                       color: Colors.white,
//                       border: Border.all(
//                         color: Colors.grey,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.5),
//                           spreadRadius: 1,
//                           blurRadius: 3,
//                           offset:
//                               const Offset(0, 2), // changes position of shadow
//                         ),
//                       ],
//                       borderRadius:
//                           const BorderRadius.all(Radius.circular(10.0))),
//                   child: Padding(
//                     padding: const EdgeInsets.all(15.0),
//                     child: Center(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text('Reserved Inventory',
//                               style: TextStyle(
//                                   backgroundColor: Colors.white,
//                                   fontSize: 17,
//                                   color: Colors.black)),
//                           verticalSpaceSmall,
//                           Text('$strReservedInventory',
//                               style: const TextStyle(
//                                   backgroundColor: Colors.white,
//                                   fontSize: 22,
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.bold)),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               verticalSpaceMedium,
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _bookasale() {
//     return Container(
//       padding: const EdgeInsets.only(
//           left: 35.0, right: 35.0, top: 25.0, bottom: 18.0),
//       child: Row(
//         // crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           InkWell(
//             onTap: () {
//               var projectId = widget.projectId!;
//               var projectName = widget.projectName!;
//               if (member_ship_form == "1") {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) {
//                       return MembershipFormView(
//                           memberShipform: member_ship_form,
//                           projectId: projectId,
//                           towarId: widget.towarId!,
//                           projectName: projectName,
//                           flagRedirect: 'BookNewSale');
//                     },
//                   ),
//                 ).then((_) {
//                   setState(() {
//                     flagcalled == false;
//                   });
//                   fetchProjectSalesManagment();
//                 });
//               } else {
//                 if (sales_plot_flag == "1") {
//                   Navigator.push(context, MaterialPageRoute(builder: (_) {
//                     return PlotDisplayView(
//                       projectId: projectId,
//                       towarId: widget.towarId!,
//                       projectName: projectName,
//                       towarName: widget.towarName!,
//                       member_ship_form: member_ship_form,
//                     );
//                   })).then((_) {
//                     setState(() {
//                       flagcalled == false;
//                     });
//                     fetchProjectSalesManagment();
//                   });
//                 } else {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) {
//                         return BookaSaleFormView(
//                             projectId: projectId,
//                             towarId: widget.towarId!,
//                             projectName: projectName,
//                             flagRedirect: 'BookNewSale');
//                       },
//                     ),
//                   ).then((_) {
//                     setState(() {
//                       flagcalled == false;
//                     });
//                     fetchProjectSalesManagment();
//                   });
//                 }
//               }
//             },
//             child: Container(
//               height: 70,
//               width: 200,
//               decoration: BoxDecoration(
//                   color: Colors.white,
//                   border: Border.all(
//                     color: Colors.grey,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.5),
//                       spreadRadius: 1,
//                       blurRadius: 3,
//                       offset: const Offset(0, 2), // changes position of shadow
//                     ),
//                   ],
//                   borderRadius: const BorderRadius.all(Radius.circular(10.0))),
//               child: const Padding(
//                 padding: EdgeInsets.all(15.0),
//                 child: Center(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text('BOOK A SALE', style: boldText),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           if (saleAccTab == '1')
//             InkWell(
//               onTap: () {
//                 var projectId = widget.projectId!;
//                 var projectName = widget.projectName!;
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) {
//                       return CashFlowView(
//                         projectId: projectId,
//                         projectName: projectName,
//                         towarId: widget.towarId!,
//                         towarName: widget.towarName!,
//                         cashflowgst: cash_flow_gst,
//                       );
//                     },
//                   ),
//                 ).then((_) {
//                   setState(() {
//                     flagcalled == false;
//                   });
//                   fetchProjectSalesManagment();
//                 });
//               },
//               child: Container(
//                 height: 70,
//                 width: 200,
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     border: Border.all(
//                       color: Colors.grey,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         spreadRadius: 1,
//                         blurRadius: 3,
//                         offset:
//                             const Offset(0, 2), // changes position of shadow
//                       ),
//                     ],
//                     borderRadius:
//                         const BorderRadius.all(Radius.circular(10.0))),
//                 child: const Padding(
//                   padding: EdgeInsets.all(15.0),
//                   child: Center(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text('CASH FLOW', style: boldText),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           if (saleAccTab == '1' && member_ship_form != "1")
//             InkWell(
//               onTap: () {
//                 var projectId = widget.projectId!;
//                 var projectName = widget.projectName!;
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) {
//                       return BrokerManagementList(
//                           towarId: widget.towarId,
//                           towarName: widget.towarName,
//                           projectId: projectId,
//                           projectName: projectName,
//                           flagRedirect: 'CashFlow');
//                     },
//                   ),
//                 ).then((_) {
//                   setState(() {
//                     flagcalled == false;
//                   });
//                   // fetchPSrojectAccountManagment();
//                 });
//               },
//               child: Container(
//                 height: 70,
//                 width: 200,
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     border: Border.all(
//                       color: Colors.grey,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         spreadRadius: 1,
//                         blurRadius: 3,
//                         offset:
//                             const Offset(0, 2), // changes position of shadow
//                       ),
//                     ],
//                     borderRadius:
//                         const BorderRadius.all(Radius.circular(10.0))),
//                 child: Padding(
//                   padding: const EdgeInsets.all(15.0),
//                   child: Center(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const [
//                         Text('CP MANAGEMENT', style: boldText),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
