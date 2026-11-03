import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_broker_details.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/salesmanagement/viewdocumentsview.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/get-project-buyer-list.dart';
import '../../../models/get_sale_buyer_request.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import 'bookasaleview.dart';
import 'bookingdetailsview.dart';

class SalesBuyersListingView extends StatefulWidget {
  SalesBuyersListingView({
    Key? key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    this.flagRedirect,
    this.cash_flow_gst,
    this.strTypeId,
    this.totalVal,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? flagRedirect;
  final bool? cash_flow_gst;
  final String? strTypeId;
  final String? totalVal;

  @override
  State<SalesBuyersListingView> createState() => _SalesBuyersListingViewState();
}

class _SalesBuyersListingViewState extends State<SalesBuyersListingView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  bool flagcalled = false;
  bool norecord = false;

  List<FlatBuyerRequest>? flatBuyerRequest = [];

  String? offset = '0';
  String searchTermValue = '';
  TextEditingController editingController = TextEditingController();

  Future<ResponseWsgetprojectbuyerlist?> fetchSalesBuyersList(
      {bool isFromSearch = false}) async {
    setState(() {
      flagcalled = false;
    });
    // CustomLoading.progressDialog(isLoading: true, context: context);

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
      "limit": "20",
      "offset": offset!,
      "search_data": searchTermValue,
      "type_id": widget.strTypeId!,
      "gst_flag": widget.cash_flow_gst == false ? '0' : '1',
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.webGetProjectBuyersList, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = wsgetprojectbuyerlistFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        if (isFromSearch) {
          setState(() {
            flatBuyerRequest = [];
          });
        }
        if (searchTermValue.isEmpty) {
          offset = dataModel.response?.offset;
        } else {
          offset = '0';
          flatBuyerRequest = [];
        }
        List<FlatBuyerRequest>? flatBuyers = [];
        flatBuyers = dataModel.response?.projectBuyerDetailsList!;

        if (flatBuyerRequest!.isEmpty) {
          flatBuyerRequest = flatBuyers;
        } else {
          for (int i = 0; i < flatBuyers!.length; i++) {
            flatBuyerRequest?.add(flatBuyers[i]);
          }
        }

        if (flatBuyerRequest!.isEmpty) {
          norecord = true;
        } else {
          norecord = false;
        }

        setState(() {
          flagcalled = true;
          flatBuyerRequest!.length;
        });
      }
      // CustomLoading.progressDialog(isLoading: false, context: context);
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      // CustomLoading.progressDialog(isLoading: false, context: context);

      return null;
    }
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));

    offset = '0';
    searchTermValue = '';
    flatBuyerRequest = [];

    fetchSalesBuyersList();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));
    fetchSalesBuyersList();
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchSalesBuyersList();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          color: Colors.black,
          // height: 50,
          child: Text(
              '${widget.strTypeId! == '1' ? 'TOTAL SOLD ' : widget.strTypeId! == '2' ? 'PAYMENT RECEIVED' : widget.strTypeId! == '3' ? 'PAYMENT OVERDUE' : 'PAYMENT TO RECEIVE'}  :  ${widget.totalVal}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
              textAlign: TextAlign.center),
        ),
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
        body: Container(
          height: double.infinity,
          color: Colors.white,
          child: SafeArea(
              child:
                  // flagcalled == true
                  //     ?
                  Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40,
                    child: Center(
                      child: Text(
                          widget.strTypeId! == '1'
                              ? 'TOTAL SOLD '
                              : widget.strTypeId! == '2'
                                  ? 'PAYMENT RECEIVED'
                                  : widget.strTypeId! == '3'
                                      ? 'PAYMENT OVERDUE'
                                      : 'PAYMENT TO RECEIVE',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center),
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
                                // flatBuyerRequest = [];
                                offset = '0';
                                searchTermValue = value;
                                searchTermValue =
                                    searchTermValue.replaceAll("  ", " ");
                                searchTermValue = searchTermValue.trim();
                                fetchSalesBuyersList(isFromSearch: true);
                              }
                            } else {
                              offset = '0';
                              searchTermValue = '';
                              // flatBuyerRequest = [];
                              editingController.clear();
                              fetchSalesBuyersList(isFromSearch: true);
                              FocusScope.of(context).requestFocus(FocusNode());
                            }
                          });
                        },
                        style: const TextStyle(fontSize: 13),
                        controller: editingController,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(12.0),
                            labelText: "Search by Booking No. or Buyer's Name",
                            hintText: "Search by Booking No. or Buyer's Name",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)))),
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
                              child:
                                  Text('No Record Found', style: normalText)),
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
                              // physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: flatBuyerRequest?.length,
                              itemBuilder: (context, index) {
                                var selectedParking = '';
                                var parkinglist =
                                    flatBuyerRequest?[index].parkingList;
                                for (int i = 0; i < parkinglist!.length; i++) {
                                  if (i == 0) {
                                    selectedParking =
                                        parkinglist[i].parkingSerialNo ?? '';
                                  } else {
                                    selectedParking =
                                        '$selectedParking, ${parkinglist[i].parkingSerialNo}';
                                  }
                                }

                                return InkWell(
                                  onTap: () {
                                    var projectId = widget.projectId;
                                    var projectName = widget.projectName!;
                                    var towarId = '';
                                    if (widget.towarId != null) {
                                      towarId = widget.towarId!;
                                    }

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return BookingDetailsView(
                                              flat_buyer_id:
                                                  flatBuyerRequest![index]
                                                      .flatBuyerId,
                                              projectId: projectId,
                                              projectName: projectName,
                                              towarName: widget.towarName,
                                              towarId: towarId,
                                              flatBuyerRequest:
                                                  flatBuyerRequest![index],
                                              navigationFlag:
                                                  widget.flagRedirect!);
                                        },
                                      ),
                                    ).then((_) {
                                      // This block runs when you have returned back to the 1st Page from 2nd.
                                      setState(() {
                                        offset = '0';
                                        flatBuyerRequest = [];
                                        fetchSalesBuyersList();
                                      });
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
                                                            'Booking No.',
                                                            style: normalText),
                                                      ),
                                                      horizontalSpaceMedium,
                                                      const Center(
                                                          child: Icon(
                                                              Icons.remove,
                                                              color: Colors
                                                                  .black54)),
                                                      horizontalSpaceLarge,
                                                      Text(
                                                          flatBuyerRequest?[
                                                                      index]
                                                                  .flatBuyerOrderNo ??
                                                              '',
                                                          style: boldText),
                                                      horizontalSpaceSmall,
                                                      Text(
                                                          flatBuyerRequest?[
                                                                          index]
                                                                      .flatFundingType ==
                                                                  '0'
                                                              ? '(Self Funding)'
                                                              : '(Bank Funding)',
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
                                                            'Buyer\'s Name',
                                                            style: normalText),
                                                      ),
                                                      horizontalSpaceMedium,
                                                      const Center(
                                                          child: Icon(
                                                              Icons.remove,
                                                              color: Colors
                                                                  .black54)),
                                                      horizontalSpaceLarge,
                                                      Text(
                                                          flatBuyerRequest?[
                                                                      index]
                                                                  .flatBuyerName ??
                                                              '',
                                                          style: normalText),
                                                      Spacer(),
                                                      InkWell(
                                                        onTap: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8), // Set radius to zero
                                                                    ),
                                                                    titlePadding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            0),
                                                                    actionsPadding:
                                                                        const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                0),
                                                                    contentPadding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            16),
                                                                    actionsAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    actions: <Widget>[
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              325,
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              vertical: 8),
                                                                          decoration:
                                                                              const BoxDecoration(
                                                                            color:
                                                                                Colors.black,
                                                                            borderRadius:
                                                                                BorderRadius.only(
                                                                              bottomRight: Radius.circular(8),
                                                                              bottomLeft: Radius.circular(8),
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              const Text(
                                                                            'Close',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 18,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: Colors.white,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                    content:
                                                                        Container(
                                                                      height:
                                                                          160,
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Image.asset(
                                                                              'images/Icon-512.png',
                                                                              height: 80,
                                                                              fit: BoxFit.fitWidth),
                                                                          Divider(),
                                                                          Container(
                                                                              height: 18),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              const AppText(
                                                                                title: 'Mobile Number : ',
                                                                                titleColor: Colors.black,
                                                                                fontSize: 16,
                                                                              ),
                                                                              AppText(
                                                                                title: flatBuyerRequest![index].flatBuyerNumber ?? '',
                                                                                titleColor: Colors.black,
                                                                                fontSize: 16,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ));
                                                              });
                                                        },
                                                        child: SvgPicture.asset(
                                                          'images/projectmanagement/whatsappIcon.svg',
                                                          height: 24,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 14),
                                                      InkWell(
                                                          onTap: () async {
                                                            if (flatBuyerRequest![
                                                                    index]
                                                                .flatBuyerEmail!
                                                                .isNotEmpty) {
                                                              final Uri
                                                                  emailUrl =
                                                                  Uri(
                                                                scheme:
                                                                    'mailto',
                                                                path: flatBuyerRequest![
                                                                        index]
                                                                    .flatBuyerEmail,
                                                              );

                                                              if (await canLaunchUrl(
                                                                  emailUrl)) {
                                                                launchUrl(
                                                                    emailUrl);
                                                              } else {
                                                                throw Exception(
                                                                    "couldnot launch url");
                                                              }
                                                            }
                                                          },
                                                          child: Icon(
                                                            Icons
                                                                .email_outlined,
                                                            color: flatBuyerRequest![
                                                                        index]
                                                                    .flatBuyerEmail!
                                                                    .isNotEmpty
                                                                ? Colors.black
                                                                : Colors.grey,
                                                          )
                                                          // SvgPicture
                                                          //     .asset(
                                                          //   'images/projectmanagement/emailIcon.svg',
                                                          //   height:
                                                          //       24,
                                                          // ),
                                                          ),
                                                      SizedBox(
                                                        width: 60,
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
                                                      SizedBox(
                                                        width: 200,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                                'Total Flat Value',
                                                                style:
                                                                    normalText),
                                                            Text(
                                                                widget.cash_flow_gst ==
                                                                        false
                                                                    ? '(Excl. GST)'
                                                                    : '(Incl. GST)',
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    fontSize:
                                                                        13.0,
                                                                    color: Colors
                                                                        .grey)),
                                                          ],
                                                        ),
                                                      ),
                                                      horizontalSpaceMedium,
                                                      const Center(
                                                          child: Icon(
                                                              Icons.remove,
                                                              color: Colors
                                                                  .black54)),
                                                      horizontalSpaceLarge,
                                                      Text(
                                                          widget.cash_flow_gst ==
                                                                  true
                                                              ? currencyFormat.format(
                                                                  double.parse(
                                                                      flatBuyerRequest?[index]
                                                                              .flatTotalValueWithGst ??
                                                                          ""))
                                                              : currencyFormat
                                                                  .format(double.parse(
                                                                      flatBuyerRequest?[index]
                                                                              .flatTotalWithoutGst ??
                                                                          '')),
                                                          style: normalText),
                                                    ],
                                                  ),
                                                ),
                                                widget.cash_flow_gst == true
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 10.0),
                                                        child: Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                      'Flat Value',
                                                                      style:
                                                                          normalText),
                                                                  Text(
                                                                      '(As Per GST Payable)',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .normal,
                                                                          fontSize:
                                                                              13.0,
                                                                          color:
                                                                              Colors.grey)),
                                                                ],
                                                              ),
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
                                                                currencyFormat.format(
                                                                    double.parse(
                                                                        flatBuyerRequest?[index].flatTotalValue ??
                                                                            '')),
                                                                style:
                                                                    normalText),
                                                          ],
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                                widget.strTypeId != '1'
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 10.0),
                                                        child: Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                  widget.strTypeId ==
                                                                          '2'
                                                                      ? 'Payment Received'
                                                                      : widget.strTypeId ==
                                                                              '3'
                                                                          ? 'Payment Overdue'
                                                                          : 'Payment to Receive',
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
                                                                currencyFormat.format(
                                                                    double.parse(
                                                                        flatBuyerRequest?[index].showValue ??
                                                                            '')),
                                                                style:
                                                                    normalText), // for error
                                                          ],
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 10.0),
                                                  child: Row(
                                                    children: [
                                                      const SizedBox(
                                                        width: 200,
                                                        child: Text('Unit',
                                                            style: normalText),
                                                      ),
                                                      horizontalSpaceMedium,
                                                      const Center(
                                                          child: Icon(
                                                              Icons.remove,
                                                              color: Colors
                                                                  .black54)),
                                                      horizontalSpaceLarge,
                                                      Text(
                                                          flatBuyerRequest![
                                                                  index]
                                                              .inventryFlatName!,
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
                                                            'No. of Parking',
                                                            style: normalText),
                                                      ),
                                                      horizontalSpaceMedium,
                                                      const Center(
                                                          child: Icon(
                                                              Icons.remove,
                                                              color: Colors
                                                                  .black54)),
                                                      horizontalSpaceLarge,
                                                      Text(
                                                          selectedParking != ''
                                                              ? '${flatBuyerRequest![index].noOfParking!} (${selectedParking})'
                                                              : flatBuyerRequest![
                                                                      index]
                                                                  .noOfParking!,
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
                                                            style: normalText),
                                                      ),
                                                      horizontalSpaceMedium,
                                                      const Center(
                                                          child: Icon(
                                                              Icons.remove,
                                                              color: Colors
                                                                  .black54)),
                                                      horizontalSpaceLarge,
                                                      Text(
                                                          flatBuyerRequest![
                                                                  index]
                                                              .flatRequestedByName!,
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
                                                        child: Text('Remark',
                                                            style: normalText),
                                                      ),
                                                      horizontalSpaceMedium,
                                                      const Center(
                                                          child: Icon(
                                                              Icons.remove,
                                                              color: Colors
                                                                  .black54)),
                                                      horizontalSpaceLarge,
                                                      Text(
                                                          flatBuyerRequest![
                                                                  index]
                                                              .flatBookingRemark!,
                                                          style: normalText),
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
                                                                'Approved By',
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
                                                              flatBuyerRequest![
                                                                      index]
                                                                  .flatApprovedByName!
                                                                  .toString(),
                                                              style:
                                                                  normalText),
                                                        ],
                                                      ),
                                                      widget.flagRedirect! ==
                                                              "SoldInventory"
                                                          ? SizedBox(
                                                              width: 110,
                                                              height: 33,
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                height: 33,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              17),
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                                child: InkWell(
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
                                                                          return ViewDocumentsView(
                                                                              projectId: projectId,
                                                                              projectName: projectName,
                                                                              towarName: widget.towarName,
                                                                              towarId: widget.towarId,
                                                                              flatBuyerID: flatBuyerRequest![index].flatBuyerId!,
                                                                              flatFunding: flatBuyerRequest![index].flatFundingType!);
                                                                        },
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'View Docs',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .normal,
                                                                      fontSize:
                                                                          13.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ))
                                                          : const SizedBox()
                                                    ],
                                                  ),
                                                ),
                                                flatBuyerRequest![index]
                                                            .buyerFlatStatus! ==
                                                        "4"
                                                    ? const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 10.0),
                                                        child: Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                  'Status',
                                                                  style:
                                                                      normalText),
                                                            ),
                                                            horizontalSpaceMedium,
                                                            Center(
                                                                child: Icon(
                                                                    Icons
                                                                        .remove,
                                                                    color: Colors
                                                                        .black54)),
                                                            horizontalSpaceLarge,
                                                            Text(
                                                                "Cancellation Request",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red)),
                                                          ],
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                                (flatBuyerRequest![index]
                                                            .requestCancelationRes
                                                            ?.trim()
                                                            .isNotEmpty ??
                                                        true &&
                                                            flatBuyerRequest![
                                                                        index]
                                                                    .requestCancelationRes !=
                                                                null &&
                                                            flatBuyerRequest![
                                                                        index]
                                                                    .requestCancelationRes !=
                                                                "")
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 10.0),
                                                        child: Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                  'Cancellation Reason',
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
                                                                flatBuyerRequest?[
                                                                            index]
                                                                        .requestCancelationRes ??
                                                                    '',
                                                                style:
                                                                    normalText),
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
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ],
              ),
              if (flagcalled == false)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 150,
                    child: Center(
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
                )
            ],
          )
              // : Center(
              //     child: SizedBox(
              //       height: 64,
              //       child: OverflowBox(
              //         minHeight: 100,
              //         maxHeight: 100,
              //         child: Lottie.asset(
              //           'assets/animation/running2.json',
              //           // 'assets/animation/chatbotfinallotiie.json',
              //           repeat: true,
              //         ),
              //       ),
              //     ),
              //   )
              ),
        ));
  }
}
