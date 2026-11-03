import 'package:stallion/ui/views/accountmanagement/account_management_preview.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_document.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/get_payment_details_by_status.dart';
import '../../../models/message_success.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import '../mycontracts/imagepreviewview.dart';
import '../rccstructure/pdfviewer.dart';

class PaymentRequestedView extends StatefulWidget {
  const PaymentRequestedView(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.flagRedirect});
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? flagRedirect;

  @override
  State<PaymentRequestedView> createState() => _PaymentRequestedViewState();
}

class _PaymentRequestedViewState extends State<PaymentRequestedView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = AccountManagementPreviewNetwork();
  TextEditingController editingController = TextEditingController();

  bool flagcalled = false;
  int isSelectedVenderList = -1;
  String? paymentStatus;
  String? paymentVenderId;

  List<PoWoPayment>? poWoPayment = [];

  Future<ResponseGetPaymentDetailsStatus?> fetchProjectPaymentRequest() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));
    var status = '0';
    if (widget.flagRedirect! == "Requested") {
      status = '0';
    } else if (widget.flagRedirect! == "Approved") {
      status = '1';
    }

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "payment_status": status,
      "search_data": editingController.text,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.wspaymentdetailsbystatus, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getPaymentDetailsStatusFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        //return dataModel.response;
        setState(() {
          flagcalled = true;
          poWoPayment = dataModel.response?.poWoPayment!;
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

  late BuildContext dialogContext;

  Future<ResponseMessageSuccess?> submitApprovePayment() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    Map<String, String> data = {
      "user_id": userId!,
      "payment_vender_id": paymentVenderId!,
      "payment_status": paymentStatus!,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.webServiceForApproveDecline, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = messageSuccessFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        // Future.delayed(Duration.zero).then((_) {
        Navigator.of(context).pop();

        showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: const Text(''),
                  content: paymentStatus == '1'
                      ? const Text('Payment approved successfully.',
                          style: TextStyle(
                              fontStyle: FontStyle.normal, fontSize: 17.0))
                      : paymentStatus == '3'
                          ? const Text('Payment has been hold.',
                              style: TextStyle(
                                  fontStyle: FontStyle.normal, fontSize: 17.0))
                          : const Text('Payment has been declined.',
                              style: TextStyle(
                                  fontStyle: FontStyle.normal, fontSize: 17.0)),
                  actions: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          fixedSize: const Size.fromWidth(100),
                          padding: const EdgeInsets.all(10),
                          textStyle: const TextStyle(color: Colors.white)),
                      child: const Text('CLOSE',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14.0,
                              color: Colors.white)),
                      onPressed: () {
                        Navigator.pop(context);
                        fetchProjectPaymentRequest();
                      },
                    ),
                  ],
                ));
        // });
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
    fetchProjectPaymentRequest();
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
              widget.flagRedirect! == 'Requested'
                  ? '${widget.projectName!.toUpperCase()} - REQUESTED PAYMENTS'
                  : '${widget.projectName!.toUpperCase()} - APPROVED PAYMENTS',
              style:
                  const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.maybePop(context);
            },
          ),
          actions: [
            // if (widget.flagRedirect! != 'Requested' &&
            //     widget.flagRedirect! != 'Assigned')
            InkWell(
                onTap: () {
                  selectFilterModal();
                  // selectFilterVenderModal();
                },
                child: Image.asset(
                  // 'images/projectmanagement/filter-sort-icon-white.png',
                  'images/projectmanagement/filter-sort-icon-white.png',
                  height: 20,
                )),
            const SizedBox(width: 80)
          ],
        ),
        body: Container(
          height: double.infinity,
          color: Colors.white,
          child: flagcalled == true
              ? Column(
                  children: [
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
                                  // woOrderList = [];
                                  // offset = '0';
                                  // searchTermValue = value;
                                  // searchTermValue =
                                  //     searchTermValue.replaceAll("  ", " ");
                                  // searchTermValue = searchTermValue.trim();
                                  fetchProjectPaymentRequest();
                                }
                              } else {
                                // offset = '0';
                                // searchTermValue = '';
                                // woOrderList = [];
                                // editingController.clear();
                                fetchProjectPaymentRequest();
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                              }
                            });
                          },
                          style: const TextStyle(fontSize: 13),
                          controller: editingController,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(12.0),
                              // labelText: "Search by WO.No, Skills or Company Name",
                              hintText: "Search by PO.No or Vendor Name",
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)))),
                        ),
                      ),
                    ),
                    verticalSpaceSmall,
                    Expanded(
                      child: poWoPayment!.length == 0
                          ? const Center(
                              child: Text('No Data Found',
                                  style: TextStyle(
                                      fontStyle: FontStyle.normal,
                                      fontSize: 17.0)))
                          : ListView.builder(
                              itemCount: poWoPayment!.length,
                              itemBuilder: (context, index) {
                                var arrUploadImg =
                                    poWoPayment?[index].poInvoiceImage;
                                return InkWell(
                                  onTap: () {
                                    // widget.flagRedirect! == "Requested"
                                    //     ?
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder:
                                            (BuildContext context) => Dialog(
                                                  elevation: 0,
                                                  child: SizedBox(
                                                    height: 280,
                                                    width: 390.0,
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 10.0,
                                                                  bottom: 5),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              const SizedBox(
                                                                  width: 30.0),
                                                              const Text(
                                                                'Approve Payment',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              IconButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                icon: const Icon(
                                                                    Icons
                                                                        .cancel_rounded),
                                                                color: Colors
                                                                    .black,
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Divider(
                                                          color: Colors
                                                              .grey.shade500,
                                                          thickness: 1.5,
                                                        ),
                                                        SizedBox(
                                                          height: 169,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Flexible(
                                                                    child: Text(
                                                                        poWoPayment![index].amountRequest! !=
                                                                                ""
                                                                            ? 'You are paying ${currencyFormat.format(double.parse(poWoPayment![index].amountRequest!))} to ${poWoPayment![index].venderName!}'
                                                                            : 'You are paying \u{20B9} 0 to ${poWoPayment![index].venderName!}',
                                                                        style: const TextStyle(
                                                                            backgroundColor:
                                                                                Colors.white,
                                                                            fontSize: 15,
                                                                            color: Colors.black)),
                                                                  ),
                                                                ],
                                                              ),
                                                              const Text(
                                                                  '(This cannot be undone)')
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 40,
                                                          width: 390,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              InkWell(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  paymentStatus =
                                                                      "2";
                                                                  paymentVenderId =
                                                                      poWoPayment![
                                                                              index]
                                                                          .paymentVenderId!;
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    barrierDismissible:
                                                                        false,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      dialogContext =
                                                                          context;
                                                                      return const Center(
                                                                        child:
                                                                            SizedBox(
                                                                          height:
                                                                              200,
                                                                          width:
                                                                              200,
                                                                          child:
                                                                              Dialog(
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                verticalSpaceSmall,
                                                                                CircularProgressIndicator(),
                                                                                verticalSpaceSmall,
                                                                                Text("Loading"),
                                                                                verticalSpaceSmall,
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  );

                                                                  submitApprovePayment();
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: double
                                                                      .infinity,
                                                                  width: widget
                                                                              .flagRedirect! ==
                                                                          "Requested"
                                                                      ? 130
                                                                      : 195,
                                                                  color: Colors
                                                                      .red
                                                                      .shade700,
                                                                  child:
                                                                      const Padding(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                10.0),
                                                                    child: Text(
                                                                      'DECLINE',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              15),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  paymentStatus =
                                                                      "3";
                                                                  paymentVenderId =
                                                                      poWoPayment![
                                                                              index]
                                                                          .paymentVenderId!;
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    barrierDismissible:
                                                                        false,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      dialogContext =
                                                                          context;
                                                                      return const Center(
                                                                        child:
                                                                            SizedBox(
                                                                          height:
                                                                              200,
                                                                          width:
                                                                              200,
                                                                          child:
                                                                              Dialog(
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                verticalSpaceSmall,
                                                                                CircularProgressIndicator(),
                                                                                verticalSpaceSmall,
                                                                                Text("Loading"),
                                                                                verticalSpaceSmall,
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  );

                                                                  submitApprovePayment();
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: double
                                                                      .infinity,
                                                                  width: widget
                                                                              .flagRedirect! ==
                                                                          "Requested"
                                                                      ? 130
                                                                      : 195,
                                                                  color: Colors
                                                                      .yellow
                                                                      .shade700,
                                                                  child:
                                                                      const Padding(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                10.0),
                                                                    child: Text(
                                                                      'HOLD',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              15),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              if (widget
                                                                      .flagRedirect! ==
                                                                  "Requested")
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                    paymentStatus =
                                                                        "1";
                                                                    paymentVenderId =
                                                                        poWoPayment![index]
                                                                            .paymentVenderId!;
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      barrierDismissible:
                                                                          false,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        dialogContext =
                                                                            context;
                                                                        return const Center(
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                200,
                                                                            width:
                                                                                200,
                                                                            child:
                                                                                Dialog(
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  verticalSpaceSmall,
                                                                                  CircularProgressIndicator(),
                                                                                  verticalSpaceSmall,
                                                                                  Text("Loading"),
                                                                                  verticalSpaceSmall,
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    );

                                                                    submitApprovePayment();
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 130,
                                                                    height: double
                                                                        .infinity,
                                                                    color: Colors
                                                                        .green
                                                                        .shade600,
                                                                    child:
                                                                        const Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                              top: 10.0),
                                                                      child:
                                                                          Text(
                                                                        'APPROVE',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 15),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ));
                                    // : const SizedBox();
                                  },
                                  child: ListTile(
                                    trailing: const Padding(
                                      padding: EdgeInsets.only(top: 70.0),
                                      child: Icon(Icons.keyboard_arrow_right),
                                    ),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // InkWell(
                                        // onTap: () {
                                        //   if (widget.flagRedirect! !=
                                        //       'Requested') {
                                        //     showDialog<void>(
                                        //         barrierDismissible: true,
                                        //         context: context,
                                        //         builder: (context1) {
                                        //           return AlertDialog(
                                        //             shape:
                                        //                 RoundedRectangleBorder(
                                        //               borderRadius:
                                        //                   BorderRadius.circular(
                                        //                       8), // Set radius to zero
                                        //             ),
                                        //             titlePadding:
                                        //                 const EdgeInsets
                                        //                     .symmetric(
                                        //                     vertical: 10,
                                        //                     horizontal: 20),
                                        //             actionsPadding:
                                        //                 const EdgeInsets.only(
                                        //                     bottom: 10,
                                        //                     left: 10,
                                        //                     right: 10),
                                        //             contentPadding:
                                        //                 const EdgeInsets
                                        //                     .symmetric(
                                        //                     horizontal: 16),
                                        //             actionsAlignment:
                                        //                 MainAxisAlignment
                                        //                     .center,
                                        //             title: const Text(
                                        //               "Are you sure you want to hold this payment?.",
                                        //               style: TextStyle(
                                        //                 fontSize: 16,
                                        //                 fontWeight:
                                        //                     FontWeight.w600,
                                        //               ),
                                        //               textAlign:
                                        //                   TextAlign.center,
                                        //             ),
                                        //             actions: [
                                        //               InkWell(
                                        //                 onTap: () {
                                        //                   // Navigator.of(context).pop();

                                        //                   Navigator.of(
                                        //                           context)
                                        //                       .pop();
                                        //                 },
                                        //                 child: Container(
                                        //                   width: 150,
                                        //                   padding:
                                        //                       const EdgeInsets
                                        //                           .symmetric(
                                        //                           vertical:
                                        //                               4),
                                        //                   decoration: BoxDecoration(
                                        //                       color: Colors
                                        //                           .black,
                                        //                       borderRadius:
                                        //                           BorderRadius
                                        //                               .circular(
                                        //                                   7)),
                                        //                   child: const Text(
                                        //                     "No",
                                        //                     style: TextStyle(
                                        //                       fontSize: 16,
                                        //                       fontWeight:
                                        //                           FontWeight
                                        //                               .w600,
                                        //                       color: Colors
                                        //                           .white,
                                        //                     ),
                                        //                     textAlign:
                                        //                         TextAlign
                                        //                             .center,
                                        //                   ),
                                        //                 ),
                                        //               ),
                                        //               InkWell(
                                        //                 onTap: () {
                                        //                   // Navigator.of(context).pop();

                                        //                   // Navigator.of(context)
                                        //                   //     .pop();

                                        //                   paymentStatus = "3";
                                        //                   paymentVenderId =
                                        //                       poWoPayment![
                                        //                               index]
                                        //                           .paymentVenderId!;
                                        //                   submitApprovePayment();
                                        //                   fetchProjectPaymentRequest();
                                        //                 },
                                        //                 child: Container(
                                        //                   width: 150,
                                        //                   padding:
                                        //                       const EdgeInsets
                                        //                           .symmetric(
                                        //                           vertical:
                                        //                               4),
                                        //                   decoration: BoxDecoration(
                                        //                       color: Colors
                                        //                           .black,
                                        //                       borderRadius:
                                        //                           BorderRadius
                                        //                               .circular(
                                        //                                   7)),
                                        //                   child: const Text(
                                        //                     "Yes",
                                        //                     style: TextStyle(
                                        //                       fontSize: 16,
                                        //                       fontWeight:
                                        //                           FontWeight
                                        //                               .w600,
                                        //                       color: Colors
                                        //                           .white,
                                        //                     ),
                                        //                     textAlign:
                                        //                         TextAlign
                                        //                             .center,
                                        //                   ),
                                        //                 ),
                                        //               ),
                                        //             ],
                                        //           );
                                        //         });
                                        //   }
                                        // },
                                        // child:
                                        Container(
                                          // color: Colors.lightGreen,
                                          padding: const EdgeInsets.only(
                                              left: 50, top: 10),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 200,
                                                      child: Text('WO. No.',
                                                          style: TextStyle(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        poWoPayment![index]
                                                                .poNo ??
                                                            '',
                                                        style: const TextStyle(
                                                            backgroundColor:
                                                                Colors.white,
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black)),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 200,
                                                      child: Text('Invoice No.',
                                                          style: TextStyle(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        poWoPayment![index]
                                                                .invoiceNo ??
                                                            '',
                                                        style: const TextStyle(
                                                            backgroundColor:
                                                                Colors.white,
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black)),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 200,
                                                      child: Text(
                                                          poWoPayment![index]
                                                                      .poWoFlag ==
                                                                  '1'
                                                              ? 'Contractor'
                                                              : 'Vendor',
                                                          style: const TextStyle(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        poWoPayment![index]
                                                                .venderName ??
                                                            '',
                                                        style: const TextStyle(
                                                            backgroundColor:
                                                                Colors.white,
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black)),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 200,
                                                      child: Text('Project',
                                                          style: TextStyle(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        poWoPayment![index]
                                                                .requestBy ??
                                                            '',
                                                        style: const TextStyle(
                                                            backgroundColor:
                                                                Colors.white,
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black)),
                                                    Spacer(),
                                                    poWoPayment![index]
                                                                    .holdStatus! ==
                                                                '1' ||
                                                            widget.flagRedirect! !=
                                                                'Requested'
                                                        ? Container(
                                                            width: 90,
                                                            height: 30,
                                                            decoration:
                                                                BoxDecoration(
                                                              // color: widget
                                                              //             .flagRedirect! !=
                                                              //         'Requested'
                                                              //     ? Colors
                                                              //         .yellow
                                                              //         .shade600
                                                              //     : Colors
                                                              //         .transparent,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 3.0),
                                                              child: Center(
                                                                child: Text(
                                                                    widget.flagRedirect! !=
                                                                            'Requested'
                                                                        ? 'Hold'
                                                                        : "On Hold",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      color: widget.flagRedirect! !=
                                                                              'Requested'
                                                                          ? Colors
                                                                              .yellow
                                                                              .shade600
                                                                          : Colors
                                                                              .transparent,

                                                                      // color: widget.flagRedirect! !=
                                                                      //         'Requested'
                                                                      //     ? Colors
                                                                      //         .black
                                                                      //     : Colors
                                                                      //         .yellow
                                                                      //         .shade600,
                                                                    )),
                                                              ),
                                                            ),
                                                          )
                                                        : const SizedBox(),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 200,
                                                      child: Text(
                                                          'Payment Requested',
                                                          style: TextStyle(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        poWoPayment![index]
                                                                    .amountRequest !=
                                                                ""
                                                            ? currencyFormat.format(
                                                                double.parse(
                                                                    poWoPayment![index]
                                                                            .amountRequest ??
                                                                        '0'))
                                                            : "\u{20B9} 0",
                                                        style: const TextStyle(
                                                            backgroundColor:
                                                                Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black)),
                                                    Text(
                                                        poWoPayment![index]
                                                                .paymentMode ??
                                                            '',
                                                        style: const TextStyle(
                                                            backgroundColor:
                                                                Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black)),
                                                    Spacer(),
                                                    // poWoPayment![index]
                                                    //             .documentImg !=
                                                    //         ""
                                                    //     ?
                                                    if (poWoPayment![index]
                                                        .documentImg!
                                                        .isNotEmpty)
                                                      SizedBox(
                                                          width: 110,
                                                          height: 33,
                                                          child: InkWell(
                                                            onTap: () {
                                                              // poWoPayment![index].documentImg.toString().split(".").last ==
                                                              //             'pdf' ||
                                                              //         poWoPayment![index].documentImg.toString().split(".").last ==
                                                              //             'PDF'
                                                              poWoPayment![
                                                                          index]
                                                                      .documentImg!
                                                                      .toString()
                                                                      .toLowerCase()
                                                                      .endsWith(
                                                                          '.pdf')
                                                                  ? Navigator
                                                                      .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (_) {
                                                                          return (useAccountManagementTestData
                                                                              ? const AccountManagementPreviewDocumentScreen()
                                                                              : PdfViewer(
                                                                                  fileName: (Uri.parse(poWoPayment![index].documentImg ?? '').pathSegments.last).replaceAll('.pdf', ''),
                                                                                  fileUrl: poWoPayment![index].documentImg,
                                                                                  // '${AppUrl.globalPoinvoicePath}${arrUploadImg.toString()}',
                                                                                ));
                                                                        },
                                                                      ),
                                                                    )
                                                                  : Navigator
                                                                      .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (_) {
                                                                          return (useAccountManagementTestData
                                                                              ? const AccountManagementPreviewDocumentScreen()
                                                                              : ImagePreviewViewer(
                                                                                  fileName: 'Requested Document',
                                                                                  // poWoPayment![index].documentImg,
                                                                                  fileUrl: poWoPayment![index].documentImg,
                                                                                  // '${AppUrl.globalPoinvoicePath}${arrUploadImg.toString()}',
                                                                                ));
                                                                        },
                                                                      ),
                                                                    );
                                                            },
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
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              child: const Text(
                                                                'VIEW DOC',
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
                                                    // : const SizedBox()
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(
                                                      width: 200,
                                                      child: Text(
                                                          'Requested On',
                                                          style: TextStyle(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        poWoPayment![index]
                                                                .invoicePaymentCreatedAt ??
                                                            '',
                                                        style: const TextStyle(
                                                            backgroundColor:
                                                                Colors.white,
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black)),
                                                    const Expanded(
                                                        child:
                                                            horizontalSpaceLarge),
                                                    arrUploadImg!.isNotEmpty
                                                        ? SizedBox(
                                                            width: 110,
                                                            height: 33,
                                                            child: InkWell(
                                                              onTap: () {
                                                                arrUploadImg
                                                                            .toString()
                                                                            .split(
                                                                                ".")
                                                                            .last ==
                                                                        'pdf'
                                                                    ? Navigator
                                                                        .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder:
                                                                              (_) {
                                                                            return (useAccountManagementTestData
                                                                                ? const AccountManagementPreviewDocumentScreen()
                                                                                : PdfViewer(
                                                                                    fileName: arrUploadImg.toString(),
                                                                                    fileUrl: '${AppUrl.globalPoinvoicePath}${arrUploadImg.toString()}',
                                                                                  ));
                                                                          },
                                                                        ),
                                                                      )
                                                                    : Navigator
                                                                        .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder:
                                                                              (_) {
                                                                            return (useAccountManagementTestData
                                                                                ? const AccountManagementPreviewDocumentScreen()
                                                                                : ImagePreviewViewer(
                                                                                    fileName: arrUploadImg.toString(),
                                                                                    fileUrl: '${AppUrl.globalPoinvoicePath}${arrUploadImg.toString()}',
                                                                                  ));
                                                                          },
                                                                        ),
                                                                      );
                                                              },
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
                                                                child:
                                                                    const Text(
                                                                  'VIEW INVOICE',
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
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 200,
                                                      child: Text(
                                                          'Payment Mode',
                                                          style: TextStyle(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        poWoPayment![index]
                                                                .paymentMode ??
                                                            '',
                                                        style: const TextStyle(
                                                            backgroundColor:
                                                                Colors.white,
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black)),
                                                  ],
                                                ),
                                              ),
                                              poWoPayment![index].approvedBy !=
                                                      '--'
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Approved By',
                                                                style: TextStyle(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .black)),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(
                                                              poWoPayment![index]
                                                                      .approvedBy ??
                                                                  '',
                                                              style: const TextStyle(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black)),
                                                        ],
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 200,
                                                      child: Text(
                                                          'Advance Adjusted',
                                                          style: TextStyle(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        currencyFormat.format(double
                                                            .parse(poWoPayment![
                                                                        index]
                                                                    .advanceAmount ??
                                                                '0')),
                                                        style:
                                                            const TextStyle(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black)),
                                                  ],
                                                ),
                                              ),
                                              if (poWoPayment![index]
                                                      .documentRemark !=
                                                  '')
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 10.0),
                                                  child: Row(
                                                    children: [
                                                      const SizedBox(
                                                        width: 200,
                                                        child: Text('Remark',
                                                            style: TextStyle(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black)),
                                                      ),
                                                      horizontalSpaceMedium,
                                                      const Center(
                                                          child: Icon(
                                                              Icons.remove,
                                                              color: Colors
                                                                  .black54)),
                                                      horizontalSpaceLarge,
                                                      Text(
                                                          poWoPayment![index]
                                                                  .documentRemark ??
                                                              '',
                                                          style: const TextStyle(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                    ],
                                                  ),
                                                )
                                            ],
                                          ),
                                          // ),
                                        ),
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
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
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
                    width: 240,
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
                width: 200,
                height: 144,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState1(() {
                            isSelectedVenderList = -1;
                            // offset = '0';
                            // searchTermValue = '';
                            // woOrderList = [];
                            // rccBookingHistory = [];
                          });
                          Navigator.of(context).pop();
                          // fetchProjectWoRequested();
                        },
                        child: Row(
                          children: [
                            const Text(
                              'Latest',
                              style: TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            Icon(
                              isSelectedVenderList == -1
                                  ? Icons.check_circle_outline_sharp
                                  : Icons.circle_outlined,
                              color: isSelectedVenderList == -1
                                  ? Colors.green
                                  : Colors.grey,
                            )
                          ],
                        ),
                      ),
                      const Divider(color: Colors.grey),
                      InkWell(
                        onTap: () {
                          setState1(() {
                            isSelectedVenderList = 0;
                            // offset = '0';
                            // searchTermValue = '';
                            // woOrderList = [];
                            // rccBookingHistory = [];
                            // List<PoWoPayment>? poWoPayment = [];
                            poWoPayment?.sort((a, b) =>
                                a.venderName!.compareTo(b.venderName ?? ''));
                          });

                          Navigator.of(context).pop();
                          // fetchProjectWoRequested();
                        },
                        child: Row(
                          children: [
                            const Text(
                              'Company A-Z',
                              style: TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            Icon(
                              isSelectedVenderList == 0
                                  ? Icons.check_circle_outline_sharp
                                  : Icons.circle_outlined,
                              color: isSelectedVenderList == 0
                                  ? Colors.green
                                  : Colors.grey,
                            )
                          ],
                        ),
                      ),
                      // Divider(color: Colors.grey),
                      // InkWell(
                      //   onTap: () {
                      //     setState1(() {
                      //       isSelectedVenderList = 1;
                      //       // offset = '0';
                      //       // searchTermValue = '';
                      //       // woOrderList = [];
                      //       // rccBookingHistory = [];
                      //     });
                      //     Navigator.of(context).pop();
                      //     // fetchProjectWoRequested();
                      //   },
                      //   child: Row(
                      //     children: [
                      //       Text(
                      //         'Uploaded Invoices',
                      //         style: TextStyle(fontSize: 16),
                      //       ),
                      //       Spacer(),
                      //       Icon(
                      //         isSelectedVenderList == 1
                      //             ? Icons.check_circle_outline_sharp
                      //             : Icons.circle_outlined,
                      //         color: isSelectedVenderList == 1
                      //             ? Colors.green
                      //             : Colors.grey,
                      //       )
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }
}
