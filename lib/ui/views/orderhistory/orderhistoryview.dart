import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/widgets/app_text.dart';

import '../../../models/get_order_history.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import '../accountmanagement/grnlistingview.dart';

// class OrderHistoryView extends StatefulWidget {
//   OrderHistoryView(
//       {Key? key,
//       this.projectId,
//       this.towarId,
//       this.projectName,
//       this.navigationFlag});

//   String? projectId;
//   String? towarId;
//   String? projectName;
//   final String? navigationFlag;

//   @override
//   State<OrderHistoryView> createState() => _OrderHistoryViewState();
// }
class OrderHistoryView extends StatefulWidget {
  const OrderHistoryView({super.key});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  late NotificationArgs args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is NotificationArgs) {
      args = routeArgs;
    } else {
      args = NotificationArgs(
        projectId: '',
        projectName: 'ALL PROJECT',
        towarName: '',
        response: NotificationResponseData(
          projectId: '',
          towarId: '',
          navigationFlag: 'SideMenu',
        ),
      );
    }
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  bool flagcalled = false;
  bool norecord = false;

  bool flagSortBy = true;

  List<RccBookingHistory>? rccBookingHistory = [];
  List<OrderList>? orderList = [];
  List<TowarList>? towarLists = [];
  String? strTowarName = "Select Tower";

  String? offset = '0';
  String searchTermValue = '';
  TextEditingController editingController = TextEditingController();

  Future<ResponseGetOrderHistory?> fetchOrderHistory() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    String? loginType = prefs.getString('loginType');

    String towerId = "";
    if (args.response?.towarId != null) {
      towerId = args.response?.towarId ?? '';
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": args.projectId ?? '',
      "towar_id": towerId,
      "limit": "20",
      "offset": offset!,
      "search_data": searchTermValue,
      "login_type": loginType!
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.webOrderHistoryall, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getOrderHistoryFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      //context.loaderOverlay.hide();
      if (dataModel.response?.errorCode == "0") {
        if (searchTermValue.isEmpty) {
          offset = dataModel.response?.offset;
        } else {
          offset = '0';
          rccBookingHistory = [];
        }
        List<RccBookingHistory>? actualList = [];
        actualList = dataModel.response?.rccBookingHistory!;

        if (rccBookingHistory!.isEmpty) {
          rccBookingHistory = actualList;
        } else {
          for (int i = 0; i < actualList!.length; i++) {
            rccBookingHistory?.add(actualList![i]);
          }
        }
        if (orderList!.isEmpty) {
          orderList = dataModel.response?.orderList!;
        }

        if (rccBookingHistory!.isEmpty) {
          norecord = true;
        } else {
          norecord = false;
        }

        setState(() {
          flagcalled = true;
          rccBookingHistory!.length;
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    offset = '0';
    searchTermValue = '';
    rccBookingHistory = [];
    orderList = [];
    if (kDebugMode) {
      print('CALLED');
    }
    // if (args.response?.navigationFlag == "SideMenu") {
    //   // args.projectName = "ALL PROJECTS";
    //   args?.response?.projectId = "";
    // }
    fetchOrderHistory();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 500));

    offset = '0';
    searchTermValue = '';
    rccBookingHistory = [];

    fetchOrderHistory();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 500));
    fetchOrderHistory();
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text('ORDER HISTORY',
              style: TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
          leading: args.response?.navigationFlag == 'SideMenu'
              ? const SizedBox()
              : IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                ),
        ),
        body: Container(
          height: double.infinity,
          color: Colors.white,
          child: SafeArea(
            child: flagcalled == true
                ? Column(
                    children: [
                      const Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Colors.white,
                      ),
                      args.response?.navigationFlag! == 'SideMenu'
                          ? SizedBox(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
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
                                                                  'SELECT PROJECT',
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
                                                            height: 300,
                                                            width: 360,
                                                            child: ListView
                                                                .builder(
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
                                                                              setState(() {
                                                                                args.response?.projectId = orderList![index].id!;
                                                                                // args?.projectName = orderList![index].name!;
                                                                                var arrTowar = orderList![index].towarList!;
                                                                                towarLists = [];
                                                                                strTowarName = "ALL TOWER";
                                                                                args.response?.towarId = '';
                                                                                if (arrTowar.isNotEmpty) {
                                                                                  towarLists?.add(TowarList(towarId: '', towarName: 'All Tower'));
                                                                                  for (int i = 0; i < arrTowar.length; i++) {
                                                                                    towarLists?.add(arrTowar[i]);
                                                                                  }
                                                                                }
                                                                                offset = '0';
                                                                                rccBookingHistory = [];
                                                                                searchTermValue = '';
                                                                              });
                                                                              context.loaderOverlay.show();
                                                                              fetchOrderHistory();
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            child:
                                                                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 10.0, bottom: 20.0, top: 15.0),
                                                                                child: Text(orderList![index].name!),
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(right: 10.0),
                                                                                child: Icon(
                                                                                  args.projectId == orderList![index].id! ? Icons.check_circle_outline_sharp : Icons.circle_outlined,
                                                                                  color: args.projectId == orderList![index].id! ? const Color.fromRGBO(0, 128, 43, 1.0) : Colors.grey,
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
                                                                color: Colors
                                                                    .black,
                                                                child:
                                                                    const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .only(
                                                                              top: 13.0),
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
                                          Text(args.projectName!.toUpperCase(),
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
                                  ),
                                  const Divider(
                                    height: 0.5,
                                    thickness: 0.5,
                                    indent: 1,
                                    endIndent: 1,
                                    color: Colors.black,
                                  ),
                                  towarLists!.isNotEmpty
                                      ? InkWell(
                                          onTap: () {
                                            towarLists!.isNotEmpty
                                                ? showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder:
                                                        (BuildContext
                                                                context) =>
                                                            Dialog(
                                                              elevation: 0,
                                                              child: SizedBox(
                                                                height: 400,
                                                                width: 360.0,
                                                                child: Column(
                                                                  children: [
                                                                    const Padding(
                                                                      padding: EdgeInsets.only(
                                                                          top:
                                                                              5.0,
                                                                          bottom:
                                                                              5),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                            'SELECT TOWER',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Divider(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade500,
                                                                      thickness:
                                                                          1.5,
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          300,
                                                                      width:
                                                                          360,
                                                                      child: ListView.builder(
                                                                          itemCount: towarLists?.length,
                                                                          itemBuilder: (context, index) {
                                                                            return Column(
                                                                              children: [
                                                                                InkWell(
                                                                                  onTap: () {
                                                                                    setState(() {
                                                                                      // widget.towarId = towarLists![index].towarId!;
                                                                                      strTowarName = towarLists![index].towarName!;
                                                                                      offset = '0';
                                                                                      rccBookingHistory = [];
                                                                                      searchTermValue = '';
                                                                                    });
                                                                                    context.loaderOverlay.show();
                                                                                    fetchOrderHistory();
                                                                                    Navigator.of(context).pop();
                                                                                  },
                                                                                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 10.0, bottom: 20.0, top: 15.0),
                                                                                      child: Text(towarLists![index].towarName!),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(right: 10.0),
                                                                                      child: Icon(
                                                                                        args.response?.towarId == towarLists![index].towarId! ? Icons.check_circle_outline_sharp : Icons.circle_outlined,
                                                                                        color: args.response?.towarId == towarLists![index].towarId! ? Colors.green : Colors.grey,
                                                                                        size: 26,
                                                                                      ),
                                                                                    ),
                                                                                  ]),
                                                                                ),
                                                                                const Divider(
                                                                                  height: 1,
                                                                                  thickness: 0.5,
                                                                                  color: Colors.black,
                                                                                ),
                                                                              ],
                                                                            );
                                                                          }),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              double.infinity,
                                                                          color:
                                                                              Colors.black,
                                                                          child:
                                                                              const Padding(
                                                                            padding:
                                                                                EdgeInsets.only(top: 13.0),
                                                                            child:
                                                                                Text(
                                                                              'OK',
                                                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ))
                                                : Alert(
                                                    closeIcon: const SizedBox(),
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 0.0,
                                                            left: 18,
                                                            right: 18),
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
                                                                FontWeight
                                                                    .normal,
                                                            fontSize: 16),
                                                        isCloseButton: true),
                                                    context: context,
                                                    desc:
                                                        'Please select project.',
                                                    alertAnimation:
                                                        fadeAlertAnimation,
                                                    buttons: [
                                                        DialogButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          color: Colors.black,
                                                          child: const Text(
                                                            "CLOSE",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15),
                                                          ),
                                                        ),
                                                      ]).show();
                                          },
                                          child: SizedBox(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                    strTowarName!.toUpperCase(),
                                                    style: const TextStyle(
                                                        fontStyle:
                                                            FontStyle.normal,
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
                                      : const SizedBox(),
                                ],
                              ),
                            )
                          : const SizedBox(),
                      const Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 1,
                        endIndent: 1,
                        color: Colors.black,
                      ),
                      verticalSpaceSmall,
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 60.0, right: 60, top: 5.0),
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            onChanged: (value) {
                              Future.delayed(const Duration(seconds: 1), () {
                                if (value.isNotEmpty) {
                                  if (value.length > 2) {
                                    rccBookingHistory = [];
                                    offset = '0';
                                    searchTermValue = value;
                                    searchTermValue =
                                        searchTermValue.replaceAll("  ", " ");
                                    searchTermValue = searchTermValue.trim();
                                    fetchOrderHistory();
                                  }
                                } else {
                                  offset = '0';
                                  searchTermValue = '';
                                  rccBookingHistory = [];
                                  editingController.clear();
                                  fetchOrderHistory();
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                }
                              });
                            },
                            style: const TextStyle(fontSize: 13),
                            controller: editingController,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(12.0),
                                labelText: "Search by PO.No or Vendor Name",
                                hintText: "Search by PO.No or Vendor Name",
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(25.0)))),
                          ),
                        ),
                      ),
                      verticalSpaceSmall,
                      const Divider(
                        height: 0.5,
                        thickness: 0.5,
                        indent: 1,
                        endIndent: 1,
                        color: Colors.black,
                      ),
                      norecord == true
                          ? const Expanded(
                              child: Center(
                                  child: Text('No Record Found',
                                      style: normalText)),
                            )
                          : Expanded(
                              child: SmartRefresher(
                                enablePullDown:
                                    searchTermValue.isEmpty ? true : false,
                                enablePullUp:
                                    searchTermValue.isEmpty ? true : false,
                                controller: _refreshController,
                                onRefresh:
                                    searchTermValue.isEmpty ? _onRefresh : null,
                                onLoading:
                                    searchTermValue.isEmpty ? _onLoading : null,
                                footer: const ClassicFooter(
                                    loadStyle: LoadStyle.ShowWhenLoading),
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: ListView.builder(
                                  itemCount: rccBookingHistory?.length,
                                  itemBuilder: (context, index) {
                                    List<OrderDetail>? orderDetails =
                                        rccBookingHistory![index].orderDetails!;
                                    double actualQty = 0.0;
                                    double deliveredQty = 0.0;
                                    String units = "";
                                    String deliver = "";
                                    String grades = "";
                                    for (int i = 0;
                                        i < orderDetails.length;
                                        i++) {
                                      actualQty = double.parse(
                                          orderDetails[i].orderQuantity!);
                                      deliveredQty = double.parse(
                                          orderDetails[i].deliveryQuantity!);
                                      if (i == 0) {
                                        units =
                                            '${actualQty.toStringAsFixed(2)} ${orderDetails[i].castingUnitName!}';
                                        deliver =
                                            '${deliveredQty.toStringAsFixed(2)} ${orderDetails[i].castingUnitName!}';
                                        grades = orderDetails[i].gradeTypeName!;
                                      } else {
                                        units =
                                            '$units, ${actualQty.toStringAsFixed(2)} ${orderDetails[i].castingUnitName!}';
                                        deliver =
                                            '$deliver, ${deliveredQty.toStringAsFixed(2)} ${orderDetails[i].castingUnitName!}';
                                        grades =
                                            '$grades, ${orderDetails[i].gradeTypeName!}';
                                      }
                                    }
                                    return InkWell(
                                      onTap: () {
                                        List<OrderDetail>? orderDetails =
                                            rccBookingHistory![index]
                                                .orderDetails!;
                                        var totalOrderQty = 0.0;
                                        var totalDeliveredQty = 0.0;
                                        for (var i = 0;
                                            i < orderDetails.length;
                                            i++) {
                                          var order = double.parse(
                                              orderDetails[i].orderQuantity!);
                                          var deliver = double.parse(
                                              orderDetails[i]
                                                  .deliveryQuantity!);
                                          totalOrderQty = totalOrderQty + order;
                                          totalDeliveredQty =
                                              totalDeliveredQty + deliver;
                                        }
                                        if (orderDetails.isNotEmpty) {
                                          showDialog(
                                              barrierDismissible: true,
                                              context: context,
                                              builder:
                                                  (BuildContext context) =>
                                                      Dialog(
                                                        elevation: 0,
                                                        child: SizedBox(
                                                          height: 500,
                                                          width: 450,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              verticalSpaceSmall,
                                                              const Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            5.0,
                                                                        bottom:
                                                                            5),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      'ORDER DETAILS',
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Divider(
                                                                color: Colors
                                                                    .grey
                                                                    .shade500,
                                                                thickness: 1.5,
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            15.0,
                                                                        right:
                                                                            15.0),
                                                                child: SizedBox(
                                                                  height: 30,
                                                                  child: Row(
                                                                    // mainAxisAlignment:
                                                                    //     MainAxisAlignment
                                                                    //         .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Container(
                                                                          width:
                                                                              210,
                                                                          child:
                                                                              Text(
                                                                            'Grade',
                                                                            style:
                                                                                normalText,
                                                                          )),
                                                                      Container(
                                                                          width:
                                                                              100,
                                                                          child:
                                                                              Text(
                                                                            'PO Qty',
                                                                            style:
                                                                                normalText,
                                                                          )),
                                                                      Container(
                                                                          width:
                                                                              100,
                                                                          child:
                                                                              Text(
                                                                            'Delivered Qty',
                                                                            style:
                                                                                normalText,
                                                                          ))
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Divider(
                                                                color: Colors
                                                                    .grey
                                                                    .shade500,
                                                                thickness: 1.5,
                                                              ),
                                                              SizedBox(
                                                                height: 286,
                                                                width: 430,
                                                                child: ListView
                                                                    .builder(
                                                                        itemCount:
                                                                            orderDetails
                                                                                .length,
                                                                        itemBuilder:
                                                                            (context,
                                                                                index) {
                                                                          return Column(
                                                                            children: [
                                                                              Container(
                                                                                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                                                                                child: SizedBox(
                                                                                  child: Row(
                                                                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                      Container(
                                                                                          width: 200,
                                                                                          child: Text(
                                                                                            orderDetails[index].gradeTypeName!,
                                                                                            style: normalText,
                                                                                          )),
                                                                                      Container(
                                                                                          width: 100,
                                                                                          child: Text(
                                                                                            '${orderDetails[index].orderQuantity!} ${orderDetails[index].castingUnitName!}',
                                                                                            style: normalText,
                                                                                          )),
                                                                                      Container(
                                                                                          width: 100,
                                                                                          child: Text(
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            '${orderDetails[index].deliveryQuantity!} ${orderDetails[index].castingUnitName!}',
                                                                                            style: TextStyle(
                                                                                              fontWeight: FontWeight.normal,
                                                                                              fontSize: 16.0,
                                                                                              color: Colors.black,
                                                                                            ),
                                                                                            textAlign: TextAlign.center,
                                                                                          ))
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Divider(
                                                                                color: Colors.grey.shade500,
                                                                                thickness: 0.5,
                                                                              ),
                                                                            ],
                                                                          );
                                                                        }),
                                                              ),
                                                              Divider(
                                                                color: Colors
                                                                    .grey
                                                                    .shade500,
                                                                thickness: 1.5,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            15.0,
                                                                        right:
                                                                            15.0),
                                                                child: SizedBox(
                                                                  height: 30,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      const Center(
                                                                          child:
                                                                              Text(
                                                                        'Total',
                                                                        style:
                                                                            normalText,
                                                                      )),
                                                                      Center(
                                                                          child:
                                                                              Text(
                                                                        '$totalOrderQty',
                                                                        style:
                                                                            normalText,
                                                                      )),
                                                                      Center(
                                                                          child:
                                                                              Text(
                                                                        '$totalDeliveredQty',
                                                                        style:
                                                                            normalText,
                                                                      ))
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            15),
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      "Remark : ",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                    ),
                                                                    Text(
                                                                      rccBookingHistory![index]
                                                                              .orderRemark ??
                                                                          '',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: double
                                                                        .infinity,
                                                                    color: Colors
                                                                        .black,
                                                                    child:
                                                                        const Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                              top: 13.0),
                                                                      child:
                                                                          Text(
                                                                        'OK',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: 15),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ));
                                        }
                                      },
                                      child: ListTile(
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 50, top: 10),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'P.O. No.',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .poNo!,
                                                              style: boldText),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'P.O. Created Date',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .poCreatedAt!,
                                                              style:
                                                                  normalText),
                                                          const Spacer(),
                                                          if (rccBookingHistory![
                                                                      index]
                                                                  .poDocument
                                                                  ?.length !=
                                                              0)
                                                            InkWell(
                                                              onTap: () {
                                                                viewDocs(
                                                                    poDocument:
                                                                        rccBookingHistory![index]
                                                                            .poDocument);
                                                              },
                                                              child: Container(
                                                                  height: 35,
                                                                  width: 100,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    color: Colors
                                                                        .white,
                                                                    shape: BoxShape
                                                                        .rectangle,
                                                                  ),
                                                                  child:
                                                                      const Center(
                                                                    child: Text(
                                                                      'VIEW DOCS',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  )),
                                                            )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const SizedBox(
                                                                width: 200,
                                                                child: Text(
                                                                    'P.O. Status',
                                                                    style:
                                                                        normalText),
                                                              ),
                                                              horizontalSpaceMedium,
                                                              const Center(
                                                                  child: Icon(
                                                                      Icons
                                                                          .remove,
                                                                      color: Colors
                                                                          .black54)),
                                                              horizontalSpaceLarge,
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: rccBookingHistory![index]
                                                                              .poStatus! ==
                                                                          '0'
                                                                      ? const Color
                                                                          .fromRGBO(
                                                                          255,
                                                                          51,
                                                                          0,
                                                                          1.0) //red
                                                                      : rccBookingHistory![index].poStatus! ==
                                                                              '1'
                                                                          ? const Color
                                                                              .fromRGBO(
                                                                              255,
                                                                              51,
                                                                              0,
                                                                              1.0) //red
                                                                          : rccBookingHistory![index].poStatus! == '2'
                                                                              ? const Color.fromRGBO(0, 128, 43, 1.0)
                                                                              : const Color.fromRGBO(255, 51, 0, 1.0), //red
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5.0),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          15.0,
                                                                      right:
                                                                          15.0,
                                                                      top: 5.0,
                                                                      bottom:
                                                                          5.0),
                                                                  child: Text(
                                                                      rccBookingHistory![index].poStatus! ==
                                                                              '0'
                                                                          ? 'Pending'
                                                                          : rccBookingHistory![index].poStatus! == '1'
                                                                              ? 'Assigned'
                                                                              : rccBookingHistory![index].poStatus! == '2'
                                                                                  ? 'Issued'
                                                                                  : rccBookingHistory![index].poStatus! == '3'
                                                                                      ? 'Dispute'
                                                                                      : '---',
                                                                      style: rccBookingHistory![index].poStatus! == '0'
                                                                          ? boldText
                                                                          : rccBookingHistory![index].poStatus! == '1'
                                                                              ? boldText
                                                                              : const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.white)),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          rccBookingHistory![
                                                                          index]
                                                                      .grn_active ==
                                                                  '1'
                                                              ? InkWell(
                                                                  onTap: () {
                                                                    var projectId =
                                                                        args.projectId!;
                                                                    var projectName =
                                                                        args.projectName!;
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (_) {
                                                                          return GrnListingView(
                                                                              projectId: projectId,
                                                                              towarId: args.response?.towarId!,
                                                                              projectName: projectName,
                                                                              orderId: rccBookingHistory![index].orderId!);
                                                                        },
                                                                      ),
                                                                    );
                                                                  },
                                                                  child: Container(
                                                                      height: 35,
                                                                      width: 100,
                                                                      decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.grey),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        color: Colors
                                                                            .white,
                                                                        shape: BoxShape
                                                                            .rectangle,
                                                                      ),
                                                                      child: const Center(
                                                                        child:
                                                                            Text(
                                                                          'VIEW GRN',
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w400),
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                      )),
                                                                )
                                                              : const SizedBox(),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Booking Type',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .gradeName!,
                                                              style:
                                                                  normalText),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Status Delivery',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: rccBookingHistory![
                                                                              index]
                                                                          .orderStatus! ==
                                                                      '0'
                                                                  ? const Color
                                                                      .fromRGBO(
                                                                      255,
                                                                      51,
                                                                      0,
                                                                      1.0) //red
                                                                  : rccBookingHistory![index].orderStatus! ==
                                                                              '1' ||
                                                                          rccBookingHistory![index].orderStatus! ==
                                                                              '4'
                                                                      ? const Color.fromRGBO(
                                                                          255,
                                                                          51,
                                                                          0,
                                                                          1.0) //red
                                                                      : rccBookingHistory![index].orderStatus! ==
                                                                              '1'
                                                                          ? const Color.fromRGBO(
                                                                              0,
                                                                              128,
                                                                              43,
                                                                              1.0) //green
                                                                          : rccBookingHistory![index].orderStatus! == '2'
                                                                              ? const Color.fromRGBO(0, 128, 43, 1.0) //green
                                                                              : const Color.fromRGBO(255, 51, 0, 1.0), //red
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                  rccBookingHistory![index]
                                                                              .orderStatus! ==
                                                                          '0'
                                                                      ? 'Order Pending'
                                                                      : rccBookingHistory![index].orderStatus! ==
                                                                              '1'
                                                                          ? 'Order Processed'
                                                                          : rccBookingHistory![index].orderStatus! ==
                                                                                  '2'
                                                                              ? 'Order Delivered'
                                                                              : rccBookingHistory![index].orderStatus! ==
                                                                                      '4'
                                                                                  ? 'Partially Delivered'
                                                                                  : 'Order Cancelled',
                                                                  style: rccBookingHistory![index]
                                                                              .orderStatus! ==
                                                                          '0'
                                                                      ? boldText
                                                                      : rccBookingHistory![index].orderStatus! == '1' ||
                                                                              rccBookingHistory![index].orderStatus! ==
                                                                                  '4'
                                                                          ? const TextStyle(
                                                                              fontWeight: FontWeight
                                                                                  .bold,
                                                                              fontSize:
                                                                                  14.0,
                                                                              color: Colors
                                                                                  .black)
                                                                          : const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 14.0,
                                                                              color: Colors.white)),
                                                            ),
                                                          ),
                                                          horizontalSpaceSmall,
                                                          Text(
                                                              rccBookingHistory![
                                                                              index]
                                                                          .orderStatus! ==
                                                                      '2'
                                                                  ? '( ${rccBookingHistory![index].orderDeliverDate!} )'
                                                                  : '',
                                                              style:
                                                                  normalText),
                                                        ],
                                                      ),
                                                    ),
                                                    if (rccBookingHistory![
                                                                    index]
                                                                .projectDelivered
                                                                ?.trim() !=
                                                            '' &&
                                                        rccBookingHistory![
                                                                    index]
                                                                .projectDelivered !=
                                                            null)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 10.0),
                                                        child: Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                  'Delivered To',
                                                                  style:
                                                                      normalText),
                                                            ),
                                                            horizontalSpaceMedium,
                                                            const Center(
                                                                child: Icon(
                                                                    Icons
                                                                        .remove,
                                                                    color: Colors
                                                                        .black54)),
                                                            horizontalSpaceLarge,
                                                            Text(
                                                                rccBookingHistory![
                                                                            index]
                                                                        .projectDelivered ??
                                                                    '',
                                                                style:
                                                                    normalText),
                                                          ],
                                                        ),
                                                      ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Vendor Name',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .venderName!,
                                                              style: boldText),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Project Name',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .projectName!,
                                                              style:
                                                                  normalText),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Slab No',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .slabName!,
                                                              style:
                                                                  normalText),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Requirement Date',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(
                                                              DateFormat('dd MMM yyyy').format(DateFormat(
                                                                      'dd-MM-yyyy')
                                                                  .parse(rccBookingHistory![
                                                                          index]
                                                                      .castingDate!
                                                                      .toString())),
                                                              style:
                                                                  normalText),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Requested By',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .raisedBy!,
                                                              style:
                                                                  normalText),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Verified By',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: rccBookingHistory![
                                                                              index]
                                                                          .poApproveBy! !=
                                                                      ''
                                                                  ? const Color
                                                                      .fromRGBO(
                                                                      0,
                                                                      122,
                                                                      204,
                                                                      1.0) //blue
                                                                  : rccBookingHistory![index]
                                                                              .poApproveBy! !=
                                                                          '---'
                                                                      ? const Color
                                                                          .fromRGBO(
                                                                          0,
                                                                          122,
                                                                          204,
                                                                          1.0) //blue
                                                                      : null,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          15.0,
                                                                      right:
                                                                          15.0,
                                                                      top: 5.0,
                                                                      bottom:
                                                                          5.0),
                                                              child: Text(
                                                                  rccBookingHistory![
                                                                          index]
                                                                      .poApproveBy!,
                                                                  style: rccBookingHistory![index]
                                                                              .poApproveBy! !=
                                                                          ''
                                                                      ? const TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              14.0,
                                                                          color: Colors
                                                                              .white)
                                                                      : rccBookingHistory![index].poApproveBy! !=
                                                                              '---'
                                                                          ? const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 14.0,
                                                                              color: Colors.white)
                                                                          : normalText),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (rccBookingHistory![
                                                                index]
                                                            .poCheckedBy !=
                                                        "")
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 10.0),
                                                        child: Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                  'Checked By',
                                                                  style:
                                                                      normalText),
                                                            ),
                                                            horizontalSpaceMedium,
                                                            const Center(
                                                                child: Icon(
                                                                    Icons
                                                                        .remove,
                                                                    color: Colors
                                                                        .black54)),
                                                            horizontalSpaceLarge,
                                                            Text(
                                                                rccBookingHistory![
                                                                            index]
                                                                        .poCheckedBy ??
                                                                    '',
                                                                style:
                                                                    normalText),
                                                            if (rccBookingHistory![
                                                                        index]
                                                                    .poCheckedByDate !=
                                                                '')
                                                              Text(
                                                                '  (${rccBookingHistory![index].poCheckedByDate})',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                ),
                                                              )
                                                          ],
                                                        ),
                                                      ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Received By',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .checkedBy!,
                                                              style:
                                                                  normalText),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'PO Quantity',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(units,
                                                              style:
                                                                  normalText),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Delivered Quantity',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(deliver,
                                                              style:
                                                                  normalText),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Grades',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Flexible(
                                                            child: Text(grades,
                                                                style:
                                                                    normalText),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                            verticalSpaceSmall15,
                                            const Divider(
                                              height: 1,
                                              thickness: 0.5,
                                              color: Colors.black,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
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
                          repeat: true,
                        ),
                      ),
                    ),
                  ),
          ),
        ));
  }

  viewDocs({List<String>? poDocument}) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 0),
              actionsPadding: EdgeInsets.zero,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              actionsAlignment: MainAxisAlignment.center,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7),
                    )),
                child: const Text(
                  "View Documents",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
                    width: 500,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(7),
                          bottomRight: Radius.circular(7),
                        )),
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
              content: SizedBox(
                height: 320,
                width: 400,
                child: SingleChildScrollView(
                  child: Wrap(
                    direction: Axis.horizontal, // default
                    alignment: WrapAlignment.start, // default
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      for (int i = 0; i < poDocument!.length; i++)
                        poDocument[i].split(".").last == 'pdf'
                            ? InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return PdfViewer(
                                          // here
                                          fileName: poDocument[i],
                                          fileUrl:
                                              '${AppUrl.poDocPath}${poDocument[i].toString()}',
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  width: 140,
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/projectmanagement/pdf.png',
                                        width: 100,
                                        height: 100,
                                      ),
                                      AppText(
                                        title: poDocument[i],
                                        fontSize: 14,
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return ImagePreviewViewer(
                                          // here
                                          fileName: poDocument[i],
                                          fileUrl:
                                              '${AppUrl.poDocPath}${poDocument[i].toString()}',
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  width: 140,
                                  child: Column(
                                    children: [
                                      Image.network(
                                        '${AppUrl.poDocPath}${poDocument[i].toString()}',
                                        width: 100,
                                        height: 100,
                                      ),
                                      AppText(
                                        title: poDocument[i],
                                        fontSize: 14,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }
}
