import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_order_history.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/models/rcc_booking_details.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/PurchaseOrder/purchase_order_form.dart';
import 'package:stallion/ui/views/accountmanagement/grnlistingview.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/supplies/architech_certificate.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/views/rccstructure/supplies/upload_reports_screen.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/api_network_call.dart';

class OrderSuppliesScreen extends StatefulWidget {
  const OrderSuppliesScreen(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.towarName,
      this.slabId,
      this.title});
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? title;
  final String? slabId;

  @override
  State<OrderSuppliesScreen> createState() => _OrderSuppliesScreenState();
}

class _OrderSuppliesScreenState extends State<OrderSuppliesScreen> {
  bool isBookSelected = true;
  bool flagcalled = false;
  bool norecord = false;

  bool flagSortBy = true;

  List<RccBookingHistory>? rccBookingHistory = [];
  List<OrderList>? orderList = [];
  List<TowarList>? towarLists = [];
  String? strTowarName = "Select Tower";

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  String? offset = '0';
  String searchTermValue = '';
  TextEditingController editingController = TextEditingController();

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  List<BookingDetail>? bookingDetailsResponse = [];
  Future<ResponseRccBookingDetails?> fetchAllRccBookingDetails() async {
    String formatDate(DateTime dateTime) {
      // String formattedDate =
      //     DateFormat('yyyy-MM-dd HH:mm:ss').format(originalDate);
      // return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    }

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "slab_id": widget.slabId!,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.getRccBookingDetails, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = rccBookingDetailsFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          bookingDetailsResponse = dataModel.response?.bookingDetails;
        });
      } else {}
    }
  }

  Future<ResponseGetOrderHistory?> fetchOrderHistory() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    String? loginType = prefs.getString('loginType');

    // String towerId = "";
    // if (widget.towarId != null) {
    //   towerId = widget.towarId!;
    // }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId!,
      "limit": "20",
      "offset": offset!,
      "search_data": searchTermValue,
      "login_type": loginType!,
      "slab_id": widget.slabId ?? '',
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
  void initState() {
    super.initState();
    fetchAllRccBookingDetails();
    fetchOrderHistory();
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
      body: Column(
        children: [
          const SizedBox(height: 6),
          const Text(
            "R.C.C STRUCTURE BOOKING",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(
              color: Colors.black,
            ))),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isBookSelected = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      color: isBookSelected ? Colors.black : Colors.transparent,
                      child: Center(
                        child: Text(
                          "BOOK",
                          style: TextStyle(
                            fontSize: 16,
                            color: isBookSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isBookSelected = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      color: isBookSelected ? Colors.transparent : Colors.black,
                      child: Center(
                        child: Text(
                          "HISTORY",
                          style: TextStyle(
                            fontSize: 16,
                            color: isBookSelected ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          isBookSelected
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height - 390,
                      child: Column(
                        children: [
                          // for (int i = 0;
                          //     i < bookingDetailsResponse!.length;
                          //     i++)
                          InkWell(
                            onTap: () {
                              var projectId = widget.projectId!;
                              var projectName = widget.projectName!;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) {
                                    return RequestPurchaseOrderView(
                                      projectId: projectId,
                                      towarId: widget.towarId!,
                                      projectName: projectName,
                                      towarName: widget.towarName!,
                                      requirementFor: widget.title,
                                      requirementType: "Ready Mix Concrete",
                                      requirementTypeId: '186',
                                    );
                                  },
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: const BoxDecoration(
                                  // color: Colors.amber,
                                  border: Border(
                                      bottom: BorderSide(
                                color: Color.fromARGB(255, 202, 202, 202),
                              ))),
                              child: Row(
                                children: [
                                  const SizedBox(width: 40),
                                  Container(
                                    height: 50,
                                    width: 50,
                                    // color: Colors.grey,
                                    child: const Image(
                                        image: AssetImage(
                                            'images/projectmanagement/rmc_icon.png')),
                                  ),
                                  const SizedBox(width: 26),
                                  const Text(
                                    'RMC',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.keyboard_arrow_right),
                                  const SizedBox(width: 40),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              var projectId = widget.projectId!;
                              var projectName = widget.projectName!;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) {
                                    return RequestPurchaseOrderView(
                                      projectId: projectId,
                                      towarId: widget.towarId!,
                                      projectName: projectName,
                                      towarName: widget.towarName!,
                                      requirementFor: widget.title,
                                      requirementType: "Steel Bars",
                                      requirementTypeId: '187',
                                    );
                                  },
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: const BoxDecoration(
                                  // color: Colors.amber,
                                  border: Border(
                                      bottom: BorderSide(
                                color: Color.fromARGB(255, 202, 202, 202),
                              ))),
                              child: Row(
                                children: [
                                  const SizedBox(width: 40),
                                  Container(
                                    height: 50,
                                    width: 50,
                                    // color: Colors.grey,
                                    child: const Image(
                                        image: AssetImage(
                                            'images/projectmanagement/stell_icon.png')),
                                  ),
                                  const SizedBox(width: 26),
                                  const Text(
                                    'STEEL',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.keyboard_arrow_right),
                                  const SizedBox(width: 40),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              var projectId = widget.projectId!;
                              var projectName = widget.projectName!;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) {
                                    return RequestPurchaseOrderView(
                                      projectId: projectId,
                                      towarId: widget.towarId!,
                                      projectName: projectName,
                                      towarName: widget.towarName!,
                                      requirementFor: widget.title,
                                      requirementType: "Cement",
                                      requirementTypeId: "185",
                                    );
                                  },
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: const BoxDecoration(
                                  // color: Colors.amber,
                                  border: Border(
                                      bottom: BorderSide(
                                color: Color.fromARGB(255, 202, 202, 202),
                              ))),
                              child: Row(
                                children: [
                                  const SizedBox(width: 40),
                                  Container(
                                    height: 50,
                                    width: 50,
                                    // color: Colors.grey,
                                    child: const Image(
                                        image: AssetImage(
                                            'images/projectmanagement/cement_icon.png')),
                                  ),
                                  const SizedBox(width: 26),
                                  const Text(
                                    'CEMENT',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.keyboard_arrow_right),
                                  const SizedBox(width: 40),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // SizedBox(height: 300),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            var projectId = widget.projectId!;
                            var projectName = widget.projectName!;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return UploadReportsScreen(
                                    projectId: projectId,
                                    towarId: widget.towarId!,
                                    projectName: projectName,
                                    towarName: widget.towarName!,
                                    title: widget.title,
                                    slabId: widget.slabId,
                                  );
                                },
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            color: Colors.black,
                            child: const Text(
                              "UPLOAD REPORTS",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            var projectId = widget.projectId!;
                            var projectName = widget.projectName!;
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (_) {
                            //       return ArchitechCertificate(
                            //         projectId: projectId,
                            //         towarId: widget.towarId!,
                            //         projectName: projectName,
                            //         towarName: widget.towarName!,
                            //         title: widget.title,
                            //         slabId: widget.slabId,
                            //       );
                            //     },
                            //   ),
                            // );

                            Navigator.of(context).pushNamed(
                              '/architechCertificate',
                              arguments: NotificationArgs(
                                projectId: projectId,
                                projectName: projectName,
                                towarName: widget.towarName,
                                response: NotificationResponseData(
                                  towarId: widget.towarId,
                                  // slabNo: plist.slabNo,
                                  slabId: widget.slabId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            color: Colors.black,
                            child: const Text(
                              // "Architect CERTIFICATE",
                              "ARCHITECT CERTIFICATE",

                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Text(
                        "Total Quantity Delivered for ${widget.title} :",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              // color: Colors.cyan,
                              width: 400,
                              child: const Text(
                                "TYPE",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            // color: Colors.red,
                            width: 200,
                            child: const Text(
                              textAlign: TextAlign.center,
                              "EST.QTY",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            // color: Colors.blue,
                            width: 200,
                            child: const Text(
                              textAlign: TextAlign.center,
                              "DEL. QTY",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            // color: Colors.red,
                            width: 300,
                            child: const Text(
                              textAlign: TextAlign.center,
                              "CHANGE(%)",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.black,
                    ),
                    for (int i = 0; i < bookingDetailsResponse!.length; i++)
                      Container(
                        padding: const EdgeInsets.only(
                            left: 50, right: 50, bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                // color: Colors.cyan,
                                width: 400,
                                child: Text(
                                  '${bookingDetailsResponse?[i].name} (${bookingDetailsResponse?[i].unit})',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              // color: Colors.red,
                              width: 200,
                              child: Text(
                                textAlign: TextAlign.center,
                                bookingDetailsResponse?[i].estQunatity ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              // color: Colors.blue,
                              width: 200,
                              child: Text(
                                textAlign: TextAlign.center,
                                bookingDetailsResponse?[i].orderQuantity ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              // color: Colors.red,
                              width: 300,
                              child: Text(
                                textAlign: TextAlign.center,
                                '${bookingDetailsResponse?[i].gradePercentage}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: double.parse(bookingDetailsResponse?[i]
                                                      .gradePercentage ??
                                                  '') <
                                              0 ||
                                          double.parse(
                                                  bookingDetailsResponse?[i]
                                                          .gradePercentage ??
                                                      '') ==
                                              100
                                      ? Colors.blue
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                )
              : Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
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
                            ? Container(
                                padding: EdgeInsets.only(
                                    top: (MediaQuery.of(context).size.height /
                                            2) -
                                        100),
                                child: const Center(
                                    child: Text('No Record Found',
                                        style: normalText)),
                              )
                            : ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
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
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return StatefulBuilder(
                                              builder: (context, setState1) {
                                                return AlertDialog(
                                                    elevation: 0,
                                                    shadowColor: Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    titlePadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 0),
                                                    actionsPadding:
                                                        const EdgeInsets.only(
                                                            bottom: 0),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 0),
                                                    actionsAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    title: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 5),
                                                      decoration: const BoxDecoration(
                                                          color: Colors.black,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          8),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          8))),
                                                      child: const Text(
                                                        "PURCHASE ORDER'S",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      Row(
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Container(
                                                              width: 500,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          4),
                                                              decoration: const BoxDecoration(
                                                                  color: Colors
                                                                      .black,
                                                                  borderRadius: BorderRadius.only(
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              8),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              8))),
                                                              child: const Text(
                                                                "OK",
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
                                                      )
                                                    ],
                                                    content: StatefulBuilder(
                                                        builder: (BuildContext
                                                                context1,
                                                            StateSetter
                                                                setState) {
                                                      return SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.4,
                                                        child: Column(
                                                            children: [
                                                              for (int i = 0;
                                                                  i <
                                                                      rccBookingHistory![
                                                                              index]
                                                                          .arrPoDoc!
                                                                          .length;
                                                                  i++)
                                                                InkWell(
                                                                  onTap: () {
                                                                    // if (i == 0) {
                                                                    //   var projectId = rccBookingHistory![index].projectIdFk!;
                                                                    //   var projectName = rccBookingHistory![index].projectName!;
                                                                    //   Navigator.push(
                                                                    //     context,
                                                                    //     MaterialPageRoute(
                                                                    //       builder: (_) {
                                                                    //         return widget.flagRedirect! == 'Verified'
                                                                    //             ? PoDetails(projectId: projectId, towarId: rccBookingHistory![index].towar_id_fk!, projectName: projectName, poId: widget.flagRedirect!, orderDetails: rccBookingHistory![index])
                                                                    //             : widget.flagRedirect! == 'Assigned'
                                                                    //                 ? PoAssignedPreviewHtml(projectId: projectId, projectName: projectName, towarId: rccBookingHistory![index].towar_id_fk!, flagRedirect: widget.flagRedirect!, poOrderId: rccBookingHistory![index].orderId!, poOrderNo: rccBookingHistory![index].poNo!, arrPoDoc: rccBookingHistory![index].arrPoDoc?[i])
                                                                    //                 : PoAssignedPreviewHtml(
                                                                    //                     projectId: projectId,
                                                                    //                     projectName: projectName,
                                                                    //                     towarId: rccBookingHistory![index].towar_id_fk!,
                                                                    //                     flagRedirect: widget.flagRedirect!,
                                                                    //                     poOrderId: rccBookingHistory![index].orderId!,
                                                                    //                     poOrderNo: rccBookingHistory![index].poNo!,
                                                                    //                     arrPoDoc: rccBookingHistory![index].arrPoDoc?[i],
                                                                    //                   );
                                                                    //       },
                                                                    //     ),
                                                                    //   ).then((_) {
                                                                    //     // Navigator.of(context).pop();
                                                                    //     // Future.delayed(const Duration(seconds: 1), () {
                                                                    //     //   // setState(
                                                                    //     //   //     () {
                                                                    //     //   //   // Call setState to refresh the page.
                                                                    //     //   //   flagcalled = false;
                                                                    //     //   offset = '0';
                                                                    //     //   searchTermValue = '';
                                                                    //     //   woOrderList = [];
                                                                    //     //   searchTermValue = '';
                                                                    //     //   rccBookingHistory = [];
                                                                    //     //   fetchProjectPoRequested();
                                                                    //     //   // This block runs when you have returned back to the 1st Page from 2nd.
                                                                    //     // });
                                                                    //   });
                                                                    // } else {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (_) {
                                                                          return PdfViewer(
                                                                            fileName:
                                                                                rccBookingHistory![index].arrPoDoc?[i].fileName!,
                                                                            fileUrl:
                                                                                rccBookingHistory![index].arrPoDoc?[i].filePath,
                                                                            // AppUrl.globalPoinvoicePath +
                                                                            //     invoiceData![index].invoiceImage!,
                                                                          );
                                                                        },
                                                                      ),
                                                                    );
                                                                    // }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                            border:
                                                                                Border(bottom: BorderSide(color: Colors.black))),
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            24,
                                                                        vertical:
                                                                            8),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Container(
                                                                              decoration: const BoxDecoration(
                                                                                  border: Border(
                                                                                      bottom: BorderSide(
                                                                                color: Colors.blue,
                                                                              ))),
                                                                              child: Text(
                                                                                rccBookingHistory![index].arrPoDoc?[i].fileName ?? '',
                                                                                style: const TextStyle(
                                                                                  fontSize: 16,
                                                                                  fontWeight: FontWeight.w400,
                                                                                  color: Colors.blue,
                                                                                  // decoration: TextDecoration.underline,
                                                                                  // decorationColor: Colors.blue,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            // Text(
                                                                            //   '(${rccBookingHistory![index].arrPoDoc?[i].createdAt})',
                                                                            //   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black54),
                                                                            // )
                                                                          ],
                                                                        ),
                                                                        // Container(
                                                                        //   padding: const EdgeInsets
                                                                        //       .symmetric(
                                                                        //       horizontal: 20),
                                                                        //   decoration:
                                                                        //       BoxDecoration(
                                                                        //     borderRadius:
                                                                        //         BorderRadius.circular(8),
                                                                        //     border:
                                                                        //         Border.all(color: Colors.black),
                                                                        //   ),
                                                                        //   child:
                                                                        //       const Text(
                                                                        //     "View PO",
                                                                        //     style:
                                                                        //         TextStyle(
                                                                        //       fontSize: 16,
                                                                        //       fontWeight: FontWeight.w400,
                                                                        //     ),
                                                                        //   ),
                                                                        // )
                                                                        Text(
                                                                          '(${rccBookingHistory![index].arrPoDoc?[i].createdAt})',
                                                                          style: const TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: Colors.black54),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )
                                                            ]),
                                                      );
                                                    }));
                                              },
                                            );
                                          });
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
                                                        Spacer(),
                                                        true
                                                            ? InkWell(
                                                                onTap: () {
                                                                  List<OrderDetail>?
                                                                      orderDetails =
                                                                      rccBookingHistory![
                                                                              index]
                                                                          .orderDetails!;
                                                                  var totalOrderQty =
                                                                      0.0;
                                                                  var totalDeliveredQty =
                                                                      0.0;
                                                                  for (var i =
                                                                          0;
                                                                      i <
                                                                          orderDetails
                                                                              .length;
                                                                      i++) {
                                                                    var order =
                                                                        double.parse(
                                                                            orderDetails[i].orderQuantity!);
                                                                    var deliver =
                                                                        double.parse(
                                                                            orderDetails[i].deliveryQuantity!);
                                                                    totalOrderQty =
                                                                        totalOrderQty +
                                                                            order;
                                                                    totalDeliveredQty =
                                                                        totalDeliveredQty +
                                                                            deliver;
                                                                  }
                                                                  if (orderDetails
                                                                      .isNotEmpty) {
                                                                    showDialog(
                                                                        barrierDismissible:
                                                                            false,
                                                                        context:
                                                                            context,
                                                                        builder: (BuildContext
                                                                                context) =>
                                                                            Dialog(
                                                                              elevation: 0,
                                                                              child: SizedBox(
                                                                                height: 500,
                                                                                width: 450,
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    verticalSpaceSmall,
                                                                                    const Padding(
                                                                                      padding: EdgeInsets.only(top: 5.0, bottom: 5),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Text(
                                                                                            'ORDER DETAILS',
                                                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    Divider(
                                                                                      color: Colors.grey.shade500,
                                                                                      thickness: 1.5,
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                                                                                      child: SizedBox(
                                                                                        height: 30,
                                                                                        child: Row(
                                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                                          children: [
                                                                                            Container(
                                                                                                width: 130,
                                                                                                child: Text(
                                                                                                  'Grade',
                                                                                                  style: normalText,
                                                                                                )),
                                                                                            Container(
                                                                                                width: 130,
                                                                                                child: Text(
                                                                                                  'PO Qty',
                                                                                                  textAlign: TextAlign.center,
                                                                                                  style: normalText,
                                                                                                )),
                                                                                            Container(
                                                                                                width: 130,
                                                                                                child: Text(
                                                                                                  textAlign: TextAlign.end,
                                                                                                  'Delivered Qty',
                                                                                                  style: normalText,
                                                                                                ))
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Divider(
                                                                                      color: Colors.grey.shade500,
                                                                                      thickness: 1.5,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 310,
                                                                                      width: 430,
                                                                                      child: ListView.builder(
                                                                                          physics: NeverScrollableScrollPhysics(),
                                                                                          itemCount: orderDetails.length,
                                                                                          itemBuilder: (context, index) {
                                                                                            return Column(
                                                                                              children: [
                                                                                                Padding(
                                                                                                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                                                                                                  child: SizedBox(
                                                                                                    // height: 30,
                                                                                                    child: Row(
                                                                                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                      children: [
                                                                                                        Container(
                                                                                                            width: 130,
                                                                                                            child: Text(
                                                                                                              orderDetails[index].gradeTypeName!,
                                                                                                              style: normalText,
                                                                                                            )),
                                                                                                        Container(
                                                                                                            width: 130,
                                                                                                            child: Text(
                                                                                                              textAlign: TextAlign.center,
                                                                                                              '${orderDetails[index].orderQuantity!} ${orderDetails[index].castingUnitName!}',
                                                                                                              style: normalText,
                                                                                                            )),
                                                                                                        Container(
                                                                                                            width: 130,
                                                                                                            child: Text(
                                                                                                              textAlign: TextAlign.end,
                                                                                                              '${orderDetails[index].deliveryQuantity!} ${orderDetails[index].castingUnitName!}',
                                                                                                              style: normalText,
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
                                                                                      color: Colors.grey.shade500,
                                                                                      thickness: 1.5,
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                                                                                      child: SizedBox(
                                                                                        height: 30,
                                                                                        child: Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                                          children: [
                                                                                            const Center(
                                                                                                child: Text(
                                                                                              'Total',
                                                                                              style: normalText,
                                                                                            )),
                                                                                            Center(
                                                                                                child: Text(
                                                                                              '$totalOrderQty',
                                                                                              style: normalText,
                                                                                            )),
                                                                                            Center(
                                                                                                child: Text(
                                                                                              '$totalDeliveredQty',
                                                                                              style: normalText,
                                                                                            ))
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Expanded(
                                                                                      child: InkWell(
                                                                                        onTap: () {
                                                                                          Navigator.of(context).pop();
                                                                                        },
                                                                                        child: Container(
                                                                                          width: double.infinity,
                                                                                          color: Colors.black,
                                                                                          child: const Padding(
                                                                                            padding: EdgeInsets.only(top: 13.0),
                                                                                            child: Text(
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
                                                                            ));
                                                                  }
                                                                },
                                                                child:
                                                                    Container(
                                                                        height:
                                                                            35,
                                                                        width:
                                                                            100,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border.all(color: Colors.grey),
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                          color:
                                                                              Colors.white,
                                                                          shape:
                                                                              BoxShape.rectangle,
                                                                        ),
                                                                        child:
                                                                            const Center(
                                                                          child:
                                                                              Text(
                                                                            'Del. Qty.',
                                                                            style:
                                                                                TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
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
                                                            style: normalText),
                                                        Spacer(),
                                                        if (rccBookingHistory![
                                                                    index]
                                                                .poDocument
                                                                ?.length !=
                                                            0)
                                                          InkWell(
                                                            onTap: () {
                                                              viewDocs(
                                                                  poDocument: rccBookingHistory![
                                                                          index]
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
                                                                      BorderRadius
                                                                          .circular(
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
                                                                        : rccBookingHistory![index].poStatus! ==
                                                                                '2'
                                                                            ? const Color.fromRGBO(
                                                                                0,
                                                                                128,
                                                                                43,
                                                                                1.0)
                                                                            : const Color.fromRGBO(
                                                                                255,
                                                                                51,
                                                                                0,
                                                                                1.0), //red
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    left: 15.0,
                                                                    right: 15.0,
                                                                    top: 5.0,
                                                                    bottom:
                                                                        5.0),
                                                                child: Text(
                                                                    rccBookingHistory![index].poStatus! ==
                                                                            '0'
                                                                        ? 'Pending'
                                                                        : rccBookingHistory![index].poStatus! ==
                                                                                '1'
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
                                                                      widget
                                                                          .projectId!;
                                                                  var projectName =
                                                                      widget
                                                                          .projectName!;
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (_) {
                                                                        return GrnListingView(
                                                                            projectId:
                                                                                projectId,
                                                                            towarId: widget
                                                                                .towarId!,
                                                                            projectName:
                                                                                projectName,
                                                                            orderId:
                                                                                rccBookingHistory![index].orderId!);
                                                                      },
                                                                    ),
                                                                  );
                                                                },
                                                                child:
                                                                    Container(
                                                                        height:
                                                                            35,
                                                                        width:
                                                                            100,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border.all(color: Colors.grey),
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                          color:
                                                                              Colors.white,
                                                                          shape:
                                                                              BoxShape.rectangle,
                                                                        ),
                                                                        child:
                                                                            const Center(
                                                                          child:
                                                                              Text(
                                                                            'VIEW GRN',
                                                                            style:
                                                                                TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
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
                                                            style: normalText),
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
                                                            color: rccBookingHistory![index]
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
                                                                    ? Colors
                                                                        .yellow
                                                                    // const Color
                                                                    //     .fromRGBO(
                                                                    //     255,
                                                                    //     51,
                                                                    //     0,
                                                                    //     1.0) //red
                                                                    : rccBookingHistory![index].orderStatus! ==
                                                                            '1'
                                                                        ? const Color
                                                                            .fromRGBO(
                                                                            0,
                                                                            128,
                                                                            43,
                                                                            1.0) //green
                                                                        : rccBookingHistory![index].orderStatus! ==
                                                                                '2'
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
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                                14.0,
                                                                            color:
                                                                                Colors.white)),
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
                                                            style: normalText),
                                                      ],
                                                    ),
                                                  ),
                                                  if (rccBookingHistory![index]
                                                          .projectDelivered !=
                                                      '')
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
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
                                                                  Icons.remove,
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
                                                            style: normalText),
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
                                                          child: Text('Slab No',
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
                                                            style: normalText),
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
                                                            DateFormat(
                                                                    'dd MMM yyyy')
                                                                .format(DateFormat(
                                                                        'dd-MM-yyyy')
                                                                    .parse(rccBookingHistory![
                                                                            index]
                                                                        .castingDate!
                                                                        .toString())),
                                                            style: normalText),
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
                                                            style: normalText),
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
                                                                    left: 15.0,
                                                                    right: 15.0,
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
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            14.0,
                                                                        color: Colors
                                                                            .white)
                                                                    : rccBookingHistory![index].poApproveBy! !=
                                                                            '---'
                                                                        ? const TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                                14.0,
                                                                            color:
                                                                                Colors.white)
                                                                        : normalText),
                                                          ),
                                                        ),
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
                                                            style: normalText),
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
                                                            style: normalText),
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
                                                            style: normalText),
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
                                                          child: Text('Grades',
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
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
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
                                              '${AppUrl.poDocPath}${poDocument![i].toString()}',
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
                                        '${AppUrl.poDocPath}${poDocument![i].toString()}',
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
