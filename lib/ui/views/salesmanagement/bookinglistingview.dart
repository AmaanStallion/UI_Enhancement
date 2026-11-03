import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_broker_details.dart';
import 'package:stallion/ui/views/salesmanagement/lease_preview.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/penaltyScreen.dart';
import 'package:stallion/ui/views/salesmanagement/viewdocumentsview.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import '../../../models/get_sale_buyer_request.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import 'bookasaleview.dart';
import 'bookingdetailsview.dart';

class BookingListingView extends StatefulWidget {
  BookingListingView({
    Key? key,
    this.projectId = "",
    this.towarId = "",
    this.projectName = "",
    this.towarName = "",
    this.flagRedirect = "",
    this.cash_flow_gst = false,
    this.memberShipForm = "0",
    this.sales_plot_flag = "0",
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? flagRedirect;
  final bool? cash_flow_gst;
  final String? memberShipForm;
  final String? sales_plot_flag;

  @override
  State<BookingListingView> createState() => _BookingListingViewState();
}

class _BookingListingViewState extends State<BookingListingView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  bool flagcalled = false;
  bool norecord = false;

  List<FlatBuyerRequest>? flatBuyerRequest = [];
  String? totalSold = '';
  String? totalRegistered = '';
  String? totalUnregistered = '';
  String bottomType = 'sold';
  String? offset = '0';
  String searchTermValue = '';
  TextEditingController editingController = TextEditingController();
  // final List<String> filterArray = [
  //   "Price High to Low",
  //   "Price Low to High",
  // ];
  List<FlatBuyerInfo>? buyerContactDetails = [];
  String isFilterArray = '';
  List<OrderShort>? orderShort = [];
  Future<ResponseGetSaleBuyerRequest?> fetchSalesBookingRequested() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    String? loginType = prefs.getString('loginType');
    var status = '0';
    if (widget.flagRedirect! == "SalesRequest") {
      status = '0';
    } else if (widget.flagRedirect! == "SoldInventory") {
      status = '1';
    } else if (widget.flagRedirect! == "Reserve") {
      status = '3';
    }

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "status": status,
      "limit": "20",
      "offset": offset!,
      "search_data": searchTermValue,
      "type": bottomType,
      "order_status": isFilterArray,
      "gst_flag": widget.cash_flow_gst == false ? '1' : "0",
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.wsgetflatbuyerrequest, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getSaleBuyerRequestFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          // endBuyerByerControllers = [];
          buyerContactDetails = dataModel.response?.buyerContactDetails;

          totalSold = dataModel.response?.totalSold;
          totalRegistered = dataModel.response?.totalRegistered;
          totalUnregistered = dataModel.response?.totalUnregistered;
          orderShort = dataModel.response?.orderShort;
        });
        setState(() {
          if (searchTermValue.isEmpty) {
            offset = dataModel.response?.offset;
          } else {
            offset = '0';
            flatBuyerRequest = [];
          }
          List<FlatBuyerRequest>? flatBuyers = [];
          flatBuyers = dataModel.response?.flatBuyerRequest!;

          if (flatBuyerRequest!.isEmpty) {
            flatBuyerRequest = flatBuyers;
          } else {
            for (int i = 0; i < flatBuyers!.length; i++) {
              flatBuyerRequest?.add(flatBuyers![i]);
            }
          }

          if (flatBuyerRequest!.isEmpty) {
            norecord = true;
          } else {
            norecord = false;
          }

          flagcalled = true;
          flatBuyerRequest!.length;
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

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));

    offset = '0';
    searchTermValue = '';
    flatBuyerRequest = [];

    fetchSalesBookingRequested();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));
    fetchSalesBookingRequested();
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    fetchSalesBookingRequested();
  }

  @override
  void dispose() {
    super.dispose();
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
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.black),
            ),
          ),
          // color: Colors.black,
          height: 50,
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    bottomType = 'sold';
                    offset = '0';
                    searchTermValue = '';
                    flatBuyerRequest = [];
                  });
                  fetchSalesBookingRequested();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  decoration: BoxDecoration(
                    color: bottomType == "sold"
                        ? Colors.black
                        : Colors.transparent,
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Total Sold",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: bottomType == "sold"
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      Text(
                        totalSold ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: bottomType == "sold"
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    bottomType = 'registered';
                    offset = '0';
                    searchTermValue = '';
                    flatBuyerRequest = [];
                  });
                  fetchSalesBookingRequested();
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: const Border(
                      left: BorderSide(color: Colors.black),
                      right: BorderSide(color: Colors.black),
                    ),
                    color: bottomType == "registered"
                        ? Colors.black
                        : Colors.transparent,
                  ),
                  width: MediaQuery.of(context).size.width / 3,
                  child: Column(
                    children: [
                      Text(
                        "Registered",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: bottomType == "registered"
                              ? Colors.white
                              : Colors.green,
                        ),
                      ),
                      Text(
                        totalRegistered ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: bottomType == "registered"
                              ? Colors.white
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    bottomType = 'nonregistered';
                    offset = '0';
                    searchTermValue = '';
                    flatBuyerRequest = [];
                  });
                  fetchSalesBookingRequested();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: bottomType == "nonregistered"
                        ? Colors.black
                        : Colors.transparent,
                  ),
                  width: MediaQuery.of(context).size.width / 3,
                  child: Column(
                    children: [
                      Text(
                        "Non-Registered",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: bottomType == "nonregistered"
                              ? Colors.white
                              : Colors.red,
                        ),
                      ),
                      Text(
                        totalUnregistered ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: bottomType == "nonregistered"
                              ? Colors.white
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        body: Container(
          height: double.infinity,
          color: Colors.white,
          child: SafeArea(
              child: flagcalled == true
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 40,
                          child: Row(
                            children: [
                              const SizedBox(width: 20),
                              InkWell(
                                onTap: () {
                                  selectFilterModal();
                                },
                                child: Image.asset(
                                  'images/projectmanagement/filter-sort-icon.png',
                                  height: 20,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                  widget.flagRedirect! == 'SalesRequest'
                                      ? 'SALES REQUEST'
                                      : widget.flagRedirect! == 'SoldInventory'
                                          ? 'SOLD INVENTORY'
                                          : 'RESERVED INVENTORY',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center),
                              const Spacer(),
                              const SizedBox(width: 40),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1.0,
                          color: Colors.black,
                        ),
                        verticalSpaceSmall,
                        Padding(
                          padding: const EdgeInsets.only(left: 60.0, right: 60),
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              onChanged: (value) {
                                Future.delayed(const Duration(seconds: 1), () {
                                  if (value.isNotEmpty) {
                                    if (value.length > 2) {
                                      flatBuyerRequest = [];
                                      offset = '0';
                                      searchTermValue = value;
                                      searchTermValue =
                                          searchTermValue.replaceAll("  ", " ");
                                      searchTermValue = searchTermValue.trim();
                                      fetchSalesBookingRequested();
                                    }
                                  } else {
                                    offset = '0';
                                    searchTermValue = '';
                                    flatBuyerRequest = [];
                                    editingController.clear();
                                    fetchSalesBookingRequested();
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                  }
                                });
                              },
                              style: const TextStyle(fontSize: 13),
                              controller: editingController,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(12.0),
                                  labelText:
                                      "Search by Booking No. or Buyer's Name",
                                  hintText:
                                      "Search by Booking No. or Buyer's Name",
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
                        verticalSpaceSmall,
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
                                  onRefresh: searchTermValue.isEmpty
                                      ? _onRefresh
                                      : null,
                                  onLoading: searchTermValue.isEmpty
                                      ? _onLoading
                                      : null,
                                  footer: const ClassicFooter(
                                      loadStyle: LoadStyle.ShowWhenLoading),
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: ListView.builder(
                                    itemCount: flatBuyerRequest?.length,
                                    itemBuilder: (context, index) {
                                      var selectedParking = '';
                                      var parkinglist =
                                          flatBuyerRequest![index].parkingList!;
                                      for (int i = 0;
                                          i < parkinglist.length;
                                          i++) {
                                        if (i == 0) {
                                          selectedParking =
                                              parkinglist[i].parkingSerialNo!;
                                        } else {
                                          selectedParking =
                                              '$selectedParking, ${parkinglist[i].parkingSerialNo!}';
                                        }
                                      }

                                      return InkWell(
                                        onTap: () {
                                          var projectId = widget.projectId!;
                                          var projectName = widget.projectName!;
                                          var towarId = '';
                                          if (widget.towarId != null) {
                                            towarId = widget.towarId!;
                                          }

                                          if (widget.flagRedirect! ==
                                              'Reserve') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) {
                                                  return BookaSaleFormView(
                                                      customCharges:
                                                          flatBuyerRequest?[index]
                                                              .customCharges,
                                                      buyerContactDetails:
                                                          flatBuyerRequest?[index]
                                                              .buyerContactDetails,
                                                      towarName:
                                                          widget.towarName,
                                                      strBuyerID:
                                                          flatBuyerRequest?[index]
                                                              .flatBuyerId,
                                                      flatbuyerid:
                                                          flatBuyerRequest?[index]
                                                                  .flatBuyerId ??
                                                              '',
                                                      flatidfk:
                                                          flatBuyerRequest?[
                                                                      index]
                                                                  .flatIdFk ??
                                                              '',
                                                      projectId: projectId,
                                                      towarId: widget.towarId,
                                                      projectName: projectName,
                                                      flatBuyerRequest:
                                                          flatBuyerRequest?[
                                                              index],
                                                      flagRedirect:
                                                          widget.flagRedirect);
                                                },
                                              ),
                                            ).then((_) {
                                              // This block runs when you have returned back to the 1st Page from 2nd.
                                              setState(() {
                                                offset = '0';
                                                flatBuyerRequest = [];
                                                fetchSalesBookingRequested();
                                              });
                                            });
                                          } else {
                                            if (flatBuyerRequest![index]
                                                    .flatBookingType ==
                                                '1') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) {
                                                    return LeasePreview(
                                                      projectId: projectId,
                                                      projectName: projectName,
                                                      towarId: towarId,
                                                      towarName:
                                                          widget.towarName!,
                                                      flatBuyerId:
                                                          flatBuyerRequest![
                                                                  index]
                                                              .flatBuyerId,
                                                      navigationFlag:
                                                          widget.flagRedirect!,
                                                      memberShipForm:
                                                          widget.memberShipForm,
                                                      flatBuyerRequest:
                                                          flatBuyerRequest![
                                                              index],
                                                    );
                                                  },
                                                ),
                                              );
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) {
                                                    return BookingDetailsView(
                                                        flatTotalValue:
                                                            flatBuyerRequest![
                                                                    index]
                                                                .flatTotalWithoutGst,
                                                        // flatBuyerRequest![
                                                        //         index]
                                                        //     .flatTotalValue,
                                                        memberShipForm: widget
                                                            .memberShipForm,
                                                        projectId: projectId,
                                                        projectName:
                                                            projectName,
                                                        towarId: towarId,
                                                        towarName:
                                                            widget.towarName!,
                                                        flat_buyer_id:
                                                            flatBuyerRequest![
                                                                    index]
                                                                .flatBuyerId,
                                                        flatBuyerRequest:
                                                            flatBuyerRequest![
                                                                index],
                                                        sales_plot_flag: widget
                                                            .sales_plot_flag,
                                                        navigationFlag: widget
                                                            .flagRedirect!);
                                                  },
                                                ),
                                              ).then((_) {
                                                // This block runs when you have returned back to the 1st Page from 2nd.
                                                setState(() {
                                                  offset = '0';
                                                  flatBuyerRequest = [];
                                                  fetchSalesBookingRequested();
                                                });
                                              });
                                            }
                                          }
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 80, top: 10),
                                                child: Column(
                                                  children:
                                                      widget.memberShipForm ==
                                                              "1"
                                                          ? [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10.0),
                                                                child: Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                      width:
                                                                          200,
                                                                      child: Text(
                                                                          'Membership No.',
                                                                          style:
                                                                              normalText),
                                                                    ),
                                                                    horizontalSpaceMedium,
                                                                    const Center(
                                                                        child: Icon(
                                                                            Icons
                                                                                .remove,
                                                                            color:
                                                                                Colors.black54)),
                                                                    horizontalSpaceLarge,
                                                                    Text(
                                                                        flatBuyerRequest![index]
                                                                            .flatBuyerOrderNo!,
                                                                        style:
                                                                            boldText),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10.0),
                                                                child: Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                      width:
                                                                          200,
                                                                      child: Text(
                                                                          'Membership Name.',
                                                                          style:
                                                                              normalText),
                                                                    ),
                                                                    horizontalSpaceMedium,
                                                                    const Center(
                                                                        child: Icon(
                                                                            Icons
                                                                                .remove,
                                                                            color:
                                                                                Colors.black54)),
                                                                    horizontalSpaceLarge,
                                                                    Text(
                                                                        flatBuyerRequest![index]
                                                                            .flatBuyerName!,
                                                                        style:
                                                                            boldText),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10.0),
                                                                child: Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width:
                                                                          200,
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          const Text(
                                                                              'Membership Amt.',
                                                                              style: normalText),
                                                                          Text(
                                                                              widget.cash_flow_gst! == false ? '(Excl. GST)' : '(Incl. GST)',
                                                                              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13.0, color: Colors.grey)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    horizontalSpaceMedium,
                                                                    const Center(
                                                                        child: Icon(
                                                                            Icons
                                                                                .remove,
                                                                            color:
                                                                                Colors.black54)),
                                                                    horizontalSpaceLarge,
                                                                    Text(
                                                                        currencyFormat.format(widget.cash_flow_gst! ==
                                                                                false
                                                                            ? double.parse(flatBuyerRequest![index]
                                                                                .flatTotalWithoutGst!)
                                                                            : double.parse(flatBuyerRequest![index]
                                                                                .flatTotalValueWithGst!)),
                                                                        style:
                                                                            boldText),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10.0),
                                                                child: Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                      width:
                                                                          200,
                                                                      child: Text(
                                                                          'Unit.',
                                                                          style:
                                                                              normalText),
                                                                    ),
                                                                    horizontalSpaceMedium,
                                                                    const Center(
                                                                        child: Icon(
                                                                            Icons
                                                                                .remove,
                                                                            color:
                                                                                Colors.black54)),
                                                                    horizontalSpaceLarge,
                                                                    Text(
                                                                        flatBuyerRequest![index]
                                                                            .selectedFlat![
                                                                                0]
                                                                            .inventryFlatName!,
                                                                        style:
                                                                            boldText),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10.0),
                                                                child: Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                      width:
                                                                          200,
                                                                      child: Text(
                                                                          'Spouse Name.',
                                                                          style:
                                                                              normalText),
                                                                    ),
                                                                    horizontalSpaceMedium,
                                                                    const Center(
                                                                        child: Icon(
                                                                            Icons
                                                                                .remove,
                                                                            color:
                                                                                Colors.black54)),
                                                                    horizontalSpaceLarge,
                                                                    Text(
                                                                        flatBuyerRequest?[index].memberDetails?.length !=
                                                                                0
                                                                            ? '${flatBuyerRequest?[index].memberDetails![0].spouseName}'
                                                                            : "",
                                                                        style:
                                                                            boldText),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10.0),
                                                                child: Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                      width:
                                                                          200,
                                                                      child: Text(
                                                                          'Requested By',
                                                                          style:
                                                                              normalText),
                                                                    ),
                                                                    horizontalSpaceMedium,
                                                                    const Center(
                                                                        child: Icon(
                                                                            Icons
                                                                                .remove,
                                                                            color:
                                                                                Colors.black54)),
                                                                    horizontalSpaceLarge,
                                                                    Text(
                                                                        flatBuyerRequest![index]
                                                                            .flatRequestedByName!,
                                                                        style:
                                                                            boldText),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10.0),
                                                                child: Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                      width:
                                                                          200,
                                                                      child: Text(
                                                                          'Membership Period.',
                                                                          style:
                                                                              normalText),
                                                                    ),
                                                                    horizontalSpaceMedium,
                                                                    const Center(
                                                                        child: Icon(
                                                                            Icons
                                                                                .remove,
                                                                            color:
                                                                                Colors.black54)),
                                                                    horizontalSpaceLarge,
                                                                    Text(
                                                                        flatBuyerRequest?[index].memberDetails?.length !=
                                                                                0
                                                                            ? '${flatBuyerRequest?[index].memberDetails![0].memberShipPeriod}'
                                                                            : "",
                                                                        style:
                                                                            boldText),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10.0),
                                                                child: Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                      width:
                                                                          200,
                                                                      child: Text(
                                                                          'Remark.',
                                                                          style:
                                                                              normalText),
                                                                    ),
                                                                    horizontalSpaceMedium,
                                                                    const Center(
                                                                        child: Icon(
                                                                            Icons
                                                                                .remove,
                                                                            color:
                                                                                Colors.black54)),
                                                                    horizontalSpaceLarge,
                                                                    Text(
                                                                        flatBuyerRequest?[index].memberDetails?.length !=
                                                                                0
                                                                            ? '${flatBuyerRequest?[index].flatBookingRemark}'
                                                                            : "",
                                                                        style:
                                                                            boldText),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10.0),
                                                                child: Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                      width:
                                                                          200,
                                                                      child: Text(
                                                                          'Approved By.',
                                                                          style:
                                                                              normalText),
                                                                    ),
                                                                    horizontalSpaceMedium,
                                                                    const Center(
                                                                        child: Icon(
                                                                            Icons
                                                                                .remove,
                                                                            color:
                                                                                Colors.black54)),
                                                                    horizontalSpaceLarge,
                                                                    Text(
                                                                        flatBuyerRequest?[index].memberDetails?.length !=
                                                                                0
                                                                            ? '${flatBuyerRequest?[index].flatApprovedByName}'
                                                                            : "",
                                                                        style:
                                                                            boldText),
                                                                  ],
                                                                ),
                                                              ),
                                                            ]
                                                          : [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10.0),
                                                                child: Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                      width:
                                                                          200,
                                                                      child: Text(
                                                                          'Booking No.',
                                                                          style:
                                                                              normalText),
                                                                    ),
                                                                    horizontalSpaceMedium,
                                                                    const Center(
                                                                        child: Icon(
                                                                            Icons
                                                                                .remove,
                                                                            color:
                                                                                Colors.black54)),
                                                                    horizontalSpaceLarge,
                                                                    Text(
                                                                        flatBuyerRequest![index]
                                                                            .flatBuyerOrderNo!,
                                                                        style:
                                                                            boldText),
                                                                    horizontalSpaceSmall,
                                                                    Text(
                                                                        flatBuyerRequest![index].flatFundingType! ==
                                                                                '0'
                                                                            ? '(Self Funding)'
                                                                            : flatBuyerRequest![index].flatFundingType! == '2'
                                                                                ? "(Sell to Asset)"
                                                                                : '(Bank Funding)',
                                                                        style: normalText),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10.0),
                                                                child: Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                      width:
                                                                          200,
                                                                      child: Text(
                                                                          'Buyer\'s Name',
                                                                          style:
                                                                              normalText),
                                                                    ),
                                                                    horizontalSpaceMedium,
                                                                    const Center(
                                                                        child: Icon(
                                                                            Icons
                                                                                .remove,
                                                                            color:
                                                                                Colors.black54)),
                                                                    horizontalSpaceLarge,
                                                                    Text(
                                                                        flatBuyerRequest![index]
                                                                            .flatBuyerName!,
                                                                        style:
                                                                            normalText),
                                                                    const Spacer(),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return AlertDialog(
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(8), // Set radius to zero
                                                                                  ),
                                                                                  titlePadding: const EdgeInsets.symmetric(vertical: 0),
                                                                                  actionsPadding: const EdgeInsets.symmetric(horizontal: 0),
                                                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                                                                  actionsAlignment: MainAxisAlignment.center,
                                                                                  actions: <Widget>[
                                                                                    InkWell(
                                                                                      onTap: () {
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      child: Container(
                                                                                        width: 325,
                                                                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                                                                        decoration: const BoxDecoration(
                                                                                          color: Colors.black,
                                                                                          borderRadius: BorderRadius.only(
                                                                                            bottomRight: Radius.circular(8),
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
                                                                                  content: Container(
                                                                                    height: 220,
                                                                                    child: SingleChildScrollView(
                                                                                      child: Column(
                                                                                        children: [
                                                                                          Image.asset('images/Icon-512.png', height: 80, fit: BoxFit.fitWidth),
                                                                                          const Divider(),
                                                                                          Container(height: 18),
                                                                                          for (int p = 0; p < flatBuyerRequest![index].buyerContactDetails!.length; p++)
                                                                                            Container(
                                                                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                                                                              decoration: const BoxDecoration(
                                                                                                border: Border(bottom: BorderSide(color: Colors.black38)),
                                                                                                // color: Colors.black,
                                                                                                // borderRadius: BorderRadius.circular(7),
                                                                                              ),
                                                                                              // decoration:BoxDecoration(border:bi)
                                                                                              child: Row(
                                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                children: [
                                                                                                  AppText(
                                                                                                    title: flatBuyerRequest![index].buyerContactDetails?[p].buyerName ?? '',
                                                                                                    titleColor: Colors.black,
                                                                                                    fontSize: 16,
                                                                                                  ),
                                                                                                  AppText(
                                                                                                    title: flatBuyerRequest![index].buyerContactDetails?[p].mobileNumber ?? '',
                                                                                                    titleColor: Colors.black,
                                                                                                    fontSize: 16,
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ));
                                                                            });
                                                                      },
                                                                      child: SvgPicture
                                                                          .asset(
                                                                        'images/projectmanagement/whatsappIcon.svg',
                                                                        height:
                                                                            24,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            14),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return AlertDialog(
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(8), // Set radius to zero
                                                                                  ),
                                                                                  titlePadding: const EdgeInsets.symmetric(vertical: 0),
                                                                                  actionsPadding: const EdgeInsets.symmetric(horizontal: 0),
                                                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                                                                  actionsAlignment: MainAxisAlignment.center,
                                                                                  actions: <Widget>[
                                                                                    InkWell(
                                                                                      onTap: () {
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      child: Container(
                                                                                        width: 325,
                                                                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                                                                        decoration: const BoxDecoration(
                                                                                          color: Colors.black,
                                                                                          borderRadius: BorderRadius.only(
                                                                                            bottomRight: Radius.circular(8),
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
                                                                                  content: Container(
                                                                                    height: 220,
                                                                                    child: SingleChildScrollView(
                                                                                      child: Column(
                                                                                        children: [
                                                                                          Image.asset('images/Icon-512.png', height: 80, fit: BoxFit.fitWidth),
                                                                                          const Divider(),
                                                                                          Container(height: 18),
                                                                                          for (int p = 0; p < flatBuyerRequest![index].buyerContactDetails!.length; p++)
                                                                                            Container(
                                                                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                                                                              decoration: const BoxDecoration(
                                                                                                border: Border(bottom: BorderSide(color: Colors.black38)),
                                                                                                // color: Colors.black,
                                                                                                // borderRadius: BorderRadius.circular(7),
                                                                                              ),
                                                                                              child: Row(
                                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                children: [
                                                                                                  AppText(
                                                                                                    title: flatBuyerRequest![index].buyerContactDetails?[p].buyerName ?? '',
                                                                                                    titleColor: Colors.black,
                                                                                                    fontSize: 16,
                                                                                                  ),
                                                                                                  AppText(
                                                                                                    title: flatBuyerRequest![index].buyerContactDetails?[p].emailId ?? '',
                                                                                                    titleColor: Colors.black,
                                                                                                    fontSize: 16,
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ));
                                                                            });
                                                                      },
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .email_outlined,
                                                                        color: flatBuyerRequest![index].flatBuyerEmail!.isNotEmpty
                                                                            ? Colors.black
                                                                            : Colors.grey,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            60),
                                                                  ],
                                                                ),
                                                              ),
                                                              flatBuyerRequest![
                                                                          index]
                                                                      .brokerName!
                                                                      .isNotEmpty
                                                                  ? Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              10.0),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          const SizedBox(
                                                                            width:
                                                                                200,
                                                                            child:
                                                                                Text('Broker Name', style: normalText),
                                                                          ),
                                                                          horizontalSpaceMedium,
                                                                          const Center(
                                                                              child: Icon(Icons.remove, color: Colors.black54)),
                                                                          horizontalSpaceLarge,
                                                                          Text(
                                                                              flatBuyerRequest![index].brokerName!,
                                                                              style: normalText),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : const SizedBox(),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10.0),
                                                                child: Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width:
                                                                          200,
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                              flatBuyerRequest![index].flatBookingType == '1' ? 'Total Lease Value' : 'Total Flat Value',
                                                                              style: normalText),
                                                                          Text(
                                                                              widget.cash_flow_gst! == false && flatBuyerRequest![index].flatBookingType != '1' ? '(Excl. GST)' : '(Incl. GST)',
                                                                              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13.0, color: Colors.grey)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    horizontalSpaceMedium,
                                                                    const Center(
                                                                        child: Icon(
                                                                            Icons
                                                                                .remove,
                                                                            color:
                                                                                Colors.black54)),
                                                                    horizontalSpaceLarge,
                                                                    Text(
                                                                        currencyFormat.format(widget.cash_flow_gst! ==
                                                                                false
                                                                            ? double.parse(flatBuyerRequest![index]
                                                                                .flatTotalWithoutGst!)
                                                                            : double.parse(flatBuyerRequest![index]
                                                                                .flatTotalValueWithGst!)),
                                                                        style:
                                                                            normalText),
                                                                    horizontalSpaceLarge,
                                                                    if (flatBuyerRequest![index]
                                                                            .flatBookingType ==
                                                                        '1')
                                                                      Container(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                8,
                                                                            vertical:
                                                                                2),
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.orange,
                                                                            borderRadius: BorderRadius.circular(4)),
                                                                        child: const Text(
                                                                            "Lease",
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.normal,
                                                                                fontSize: 16.0,
                                                                                color: Colors.white)),
                                                                      ),
                                                                    if (flatBuyerRequest![index]
                                                                            .tenantIdFk !=
                                                                        '0')
                                                                      const Text(
                                                                          "(Tenant)",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.normal,
                                                                              fontSize: 16.0,
                                                                              color: Colors.grey)),
                                                                    const Spacer(),
                                                                    if (flatBuyerRequest![index]
                                                                            .penaltyFlag ==
                                                                        '1')
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (_) {
                                                                                return PenaltyScreen(
                                                                                  projectId: widget.projectId,
                                                                                  projectName: widget.projectName,
                                                                                  towarName: widget.towarName,
                                                                                  towarId: widget.towarId,
                                                                                  flatBuyerID: flatBuyerRequest![index].flatBuyerId ?? '',
                                                                                );
                                                                              },
                                                                            ),
                                                                          );
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          "Penalty",
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                Colors.red,
                                                                            decoration:
                                                                                TextDecoration.underline,
                                                                            decorationColor:
                                                                                Colors.red,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    const SizedBox(
                                                                        width:
                                                                            60)
                                                                  ],
                                                                ),
                                                              ),
                                                              widget.cash_flow_gst! ==
                                                                      true
                                                                  ? Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              10.0),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                200,
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(flatBuyerRequest![index].flatBookingType == '1' ? 'Lease Value' : 'Flat Value', style: normalText),
                                                                                Text('(As Per GST Payable)', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13.0, color: Colors.grey)),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          horizontalSpaceMedium,
                                                                          const Center(
                                                                              child: Icon(Icons.remove, color: Colors.black54)),
                                                                          horizontalSpaceLarge,
                                                                          Text(
                                                                              currencyFormat.format(double.parse(flatBuyerRequest![index].flatTotalValue!)),
                                                                              style: normalText),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : const SizedBox(),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10.0),
                                                                child: Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                      width:
                                                                          200,
                                                                      child: Text(
                                                                          'Unit',
                                                                          style:
                                                                              normalText),
                                                                    ),
                                                                    horizontalSpaceMedium,
                                                                    const Center(
                                                                        child: Icon(
                                                                            Icons
                                                                                .remove,
                                                                            color:
                                                                                Colors.black54)),
                                                                    horizontalSpaceLarge,
                                                                    // Text(
                                                                    //     '${flatBuyerRequest![index].inventryFlatName}  (${flatBuyerRequest![index].flatArea})',
                                                                    //     style:
                                                                    //         normalText),

                                                                    Row(
                                                                      children: [
                                                                        for (int i =
                                                                                0;
                                                                            i < flatBuyerRequest![index].selectedFlat!.length;
                                                                            i++)
                                                                          Text(
                                                                            '${flatBuyerRequest![index].selectedFlat?[i].inventryFlatName} (${flatBuyerRequest![index].selectedFlat?[i].flatArea} Sq.ft)${i == flatBuyerRequest![index].selectedFlat!.length - 1 ? "" : ", "}',
                                                                            style:
                                                                                normalText,
                                                                          )
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10.0),
                                                                child: Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                      width:
                                                                          200,
                                                                      child: Text(
                                                                          'No. of Parking',
                                                                          style:
                                                                              normalText),
                                                                    ),
                                                                    horizontalSpaceMedium,
                                                                    const Center(
                                                                        child: Icon(
                                                                            Icons
                                                                                .remove,
                                                                            color:
                                                                                Colors.black54)),
                                                                    horizontalSpaceLarge,
                                                                    Text(
                                                                        selectedParking !=
                                                                                ''
                                                                            ? '${flatBuyerRequest![index].noOfParking!} (${selectedParking})'
                                                                            : flatBuyerRequest![index]
                                                                                .noOfParking!,
                                                                        style:
                                                                            normalText),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10.0),
                                                                child: Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                      width:
                                                                          200,
                                                                      child: Text(
                                                                          'Requested By',
                                                                          style:
                                                                              normalText),
                                                                    ),
                                                                    horizontalSpaceMedium,
                                                                    const Center(
                                                                        child: Icon(
                                                                            Icons
                                                                                .remove,
                                                                            color:
                                                                                Colors.black54)),
                                                                    horizontalSpaceLarge,
                                                                    Text(
                                                                        '${flatBuyerRequest![index].flatRequestedByName} ${flatBuyerRequest![index].flatRequestDate == null ? '' : '(${DateFormat('dd MMM yyyy').format(flatBuyerRequest![index].flatRequestDate ?? DateTime.now()).toString()})'}',
                                                                        style:
                                                                            normalText),
                                                                  ],
                                                                ),
                                                              ),
                                                              if (flatBuyerRequest![
                                                                          index]
                                                                      .flatBookingType !=
                                                                  '1')
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          10.0),
                                                                  child: Row(
                                                                    children: [
                                                                      const SizedBox(
                                                                        width:
                                                                            200,
                                                                        child: Text(
                                                                            'Reserved By',
                                                                            style:
                                                                                normalText),
                                                                      ),
                                                                      horizontalSpaceMedium,
                                                                      const Center(
                                                                          child: Icon(
                                                                              Icons.remove,
                                                                              color: Colors.black54)),
                                                                      horizontalSpaceLarge,
                                                                      Text(
                                                                          '${flatBuyerRequest![index].flatReservedByName} ${flatBuyerRequest![index].reservedDate == null ? '' : '(${DateFormat('dd MMM yyyy').format(flatBuyerRequest![index].reservedDate ?? DateTime.now()).toString()})'}',
                                                                          style:
                                                                              normalText),
                                                                    ],
                                                                  ),
                                                                ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10.0),
                                                                child: Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                        width:
                                                                            200,
                                                                        child: Text(
                                                                            'Remark',
                                                                            style:
                                                                                normalText)),
                                                                    horizontalSpaceMedium,
                                                                    const Center(
                                                                        child: Icon(
                                                                            Icons
                                                                                .remove,
                                                                            color:
                                                                                Colors.black54)),
                                                                    horizontalSpaceLarge,
                                                                    Text(
                                                                        flatBuyerRequest![index]
                                                                            .flatBookingRemark!,
                                                                        style:
                                                                            normalText),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10.0),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        const SizedBox(
                                                                          width:
                                                                              200,
                                                                          child: Text(
                                                                              'Approved By',
                                                                              style: normalText),
                                                                        ),
                                                                        horizontalSpaceMedium,
                                                                        const Center(
                                                                            child:
                                                                                Icon(Icons.remove, color: Colors.black54)),
                                                                        horizontalSpaceLarge,
                                                                        Text(
                                                                            flatBuyerRequest![index].flatApprovedByName == '--'
                                                                                ? '--'
                                                                                : '${flatBuyerRequest![index].flatApprovedByName} ${flatBuyerRequest![index].flatApprovedDate == null ? '' : '(${DateFormat('dd MMM yyyy').format(flatBuyerRequest![index].flatApprovedDate ?? DateTime.now()).toString()})'}',
                                                                            style:
                                                                                normalText),
                                                                      ],
                                                                    ),
                                                                    widget.flagRedirect! ==
                                                                            "SoldInventory"
                                                                        ? SizedBox(
                                                                            width:
                                                                                110,
                                                                            height:
                                                                                33,
                                                                            child:
                                                                                Container(
                                                                              margin: const EdgeInsets.only(right: 40),
                                                                              width: double.infinity,
                                                                              height: 33,
                                                                              alignment: Alignment.center,
                                                                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: Colors.black)),
                                                                              child: InkWell(
                                                                                onTap: () {
                                                                                  var projectId = widget.projectId!;
                                                                                  var projectName = widget.projectName!;

                                                                                  Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                      builder: (_) {
                                                                                        return ViewDocumentsView(
                                                                                          projectId: projectId,
                                                                                          projectName: projectName,
                                                                                          towarName: widget.towarName,
                                                                                          towarId: widget.towarId,
                                                                                          flatBuyerID: flatBuyerRequest![index].flatBuyerId!,
                                                                                          flatFunding: flatBuyerRequest![index].flatFundingType!,
                                                                                          sales_plot_flag: widget.sales_plot_flag,
                                                                                        );
                                                                                      },
                                                                                    ),
                                                                                  );
                                                                                },
                                                                                child: const Text(
                                                                                  'View Docs',
                                                                                  style: TextStyle(
                                                                                    color: Colors.black,
                                                                                    fontStyle: FontStyle.normal,
                                                                                    fontSize: 13.0,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ))
                                                                        : const SizedBox()
                                                                  ],
                                                                ),
                                                              ),
                                                              flatBuyerRequest![
                                                                              index]
                                                                          .buyerFlatStatus! ==
                                                                      "4"
                                                                  ? const Padding(
                                                                      padding: EdgeInsets.only(
                                                                          bottom:
                                                                              10.0),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                200,
                                                                            child:
                                                                                Text('Status', style: normalText),
                                                                          ),
                                                                          horizontalSpaceMedium,
                                                                          Center(
                                                                              child: Icon(Icons.remove, color: Colors.black54)),
                                                                          horizontalSpaceLarge,
                                                                          Text(
                                                                              "Cancellation Request",
                                                                              style: TextStyle(color: Colors.red)),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : const SizedBox(),
                                                              (flatBuyerRequest![index]
                                                                              .requestCancelationRes
                                                                              ?.trim()
                                                                              .length !=
                                                                          0 &&
                                                                      flatBuyerRequest![index]
                                                                              .requestCancelationRes !=
                                                                          null)
                                                                  ? Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              10.0),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          const SizedBox(
                                                                            width:
                                                                                200,
                                                                            child:
                                                                                Text('Cancellation Reason', style: normalText),
                                                                          ),
                                                                          horizontalSpaceMedium,
                                                                          const Center(
                                                                              child: Icon(Icons.remove, color: Colors.black54)),
                                                                          horizontalSpaceLarge,
                                                                          Text(
                                                                              flatBuyerRequest![index].requestCancelationRes ?? '',
                                                                              style: normalText),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : const SizedBox(),
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
                            // 'assets/animation/chatbotfinallotiie.json',
                            repeat: true,
                          ),
                        ),
                      ),
                    )
              // const Center(child: CircularProgressIndicator()),
              ),
        ));
  }

  selectFilterModal() {
    return showDialog<void>(
        // barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState1) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 10),
              actionsPadding: const EdgeInsets.only(bottom: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: const Text(
                'FILTER',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              actions: [
                InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Center(
                      child: Text(
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
                ),
              ],
              content: SizedBox(
                width: 400,
                height: 304,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        itemCount: orderShort!.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                isFilterArray = orderShort?[index].id ?? '';
                                offset = '0';
                                searchTermValue = '';
                                flatBuyerRequest = [];
                              });
                              Navigator.of(context).pop();
                              fetchSalesBookingRequested();
                              // if (index == 0) {
                              //   setState(() {
                              //     if (widget.cash_flow_gst! == false) {
                              //       flatBuyerRequest?.sort((a, b) =>
                              //           double.parse(
                              //                   b.flatTotalWithoutGst ?? "0")
                              //               .compareTo(double.parse(
                              //                   a.flatTotalWithoutGst ?? '')));
                              //     } else {
                              //       flatBuyerRequest?.sort((a, b) => double
                              //               .parse(
                              //                   b.flatTotalValueWithGst ?? "0")
                              //           .compareTo(double.parse(
                              //               a.flatTotalValueWithGst ?? '')));
                              //     }
                              //   });
                              // } else if (index == 1) {
                              //   setState(() {
                              //     if (widget.cash_flow_gst! == false) {
                              //       flatBuyerRequest?.sort((a, b) =>
                              //           double.parse(
                              //                   a.flatTotalWithoutGst ?? "0")
                              //               .compareTo(double.parse(
                              //                   b.flatTotalWithoutGst ?? '')));
                              //     } else {
                              //       flatBuyerRequest?.sort((a, b) => double
                              //               .parse(
                              //                   a.flatTotalValueWithGst ?? "0")
                              //           .compareTo(double.parse(
                              //               b.flatTotalValueWithGst ?? '')));
                              //     }
                              //   });
                              // }
                              // fetchProjectPoRequested();
                            },
                            child: Row(
                              children: [
                                Text(
                                  orderShort?[index].name ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const Spacer(),
                                Icon(
                                  isFilterArray == orderShort?[index].id
                                      ? Icons.check_circle_outline_sharp
                                      : Icons.circle_outlined,
                                  color: isFilterArray == orderShort?[index].id
                                      ? Colors.green
                                      : Colors.grey,
                                )
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(
                          color: Colors.grey,
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
