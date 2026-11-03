import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stallion/models/exterior_finishing_model.dart';
import 'package:stallion/models/get_broker_details.dart' as sale;
import 'package:stallion/models/message_success.dart';
import 'package:stallion/ui/views/salesmanagement/paymentreceivedlistingview.dart';
import '../../../models/get_flat_list_by_project.dart';
import '../../../models/ws_get_buyer_payment_details.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../mycontracts/imagepreviewview.dart';
import '../rccstructure/pdfviewer.dart';
import 'bookingpreview.dart';

class BookingDetailsView extends StatefulWidget {
  BookingDetailsView(
      {super.key,
      this.projectName,
      this.projectId,
      this.towarId,
      this.towarName,
      this.flatBuyerRequest,
      this.navigationFlag,
      this.title = "",
      this.memberShipForm = "0",
      this.sales_plot_flag = "0",
      this.inventryFlatName,
      this.flat_buyer_id,
      this.flatTotalValue});

  final String? projectId;
  final String? title;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  sale.FlatBuyerRequest? flatBuyerRequest;
  final String? navigationFlag;
  final String? memberShipForm;
  final String? sales_plot_flag;
  final String? flat_buyer_id;
  final String? inventryFlatName;
  final String? flatTotalValue;

  @override
  State<BookingDetailsView> createState() => _BookingDetailsViewState();
}

class _BookingDetailsViewState extends State<BookingDetailsView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  bool _visible = false;
  double? topHeight = 5;
  bool flagcalled = false;
  List<BuyerPaymentDetail>? buyerPaymentDetails = [];
  List<List<CustomCharge>>? customCharges = [];
  List<CustomCharge> otherCharges = [];
  List<CustomCharge> otherChargesOneTime = [];
  List<ArrRegistrationDoc>? arrRegistrationDoc = [];
  List<FlatPaymentHistory>? flatPaymentHistory;
  String? flatPaymentAmount = '0';
  String? flatGstAmount = '0';
  String? totalGstPayable = '0';
  String? flatTdsAmount = '0';
  String? flatTotalAmountDue = '0';
  PaymentBottomBar? paymentBottomBar;
  String? strTotalGstPaid = '0';
  String? strTotalGstDue = '0';
  String? strTotalGstPayable = '0';
  String? strTotalGstGenerated = '0';
  ResponseGetBuyerPaymentsDetails? responseData;

  Future<ResponseMessageSuccess?> rejectReserveInventory() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId ?? '',
      "flat_buyer_id": widget.flatBuyerRequest?.flatBuyerId ?? '',
      "status": '4',
      "flat_id_fk": widget.flatBuyerRequest?.flatIdFk ?? '',
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(AppUrl.wssetflatStatus, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = messageSuccessFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
    return null;
  }

  Future<ResponseGetBuyerPaymentsDetails?> fetchBookingPaymentDetails() async {
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
      "flat_buyer_id": widget.flat_buyer_id ?? ''
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.wsgetbuyerpaymentsdetails, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getBuyerPaymentsDetailsFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        widget.flatBuyerRequest = dataModel.response?.flatBuyerDetails?[0];
        buyerPaymentDetails = dataModel.response?.buyerPaymentDetails!;
        customCharges = dataModel.response?.customCharges!;
        responseData = dataModel.response;
        flatPaymentAmount = dataModel.response?.flatPaymentAmount;
        flatGstAmount = dataModel.response?.flatGstAmount;
        totalGstPayable = dataModel.response?.totalGstPayable;
        flatTdsAmount = dataModel.response?.flatTdsAmount;
        flatTotalAmountDue = dataModel.response?.flatTotalAmountDue;
        paymentBottomBar = dataModel.response?.paymentBottomBar;
        flatPaymentHistory = dataModel.response?.flatPaymentHistory;
        arrRegistrationDoc = dataModel.response?.arrRegistrationDoc;

        strTotalGstPaid = dataModel.response?.totalGstPaid;
        strTotalGstDue = dataModel.response?.totalGstDue;
        strTotalGstPayable = dataModel.response?.totalGstPayable;
        strTotalGstGenerated = dataModel.response?.totalGstGeneratedHistry;

        otherCharges = [];
        if (customCharges!.isNotEmpty) {
          for (var i = 0; i < customCharges!.length; i++) {
            if (i == 0) {
              for (var j = 0; j < customCharges![i].length; j++) {
                otherCharges.add(customCharges![i][j]);
              }
            }
          }
        }

        otherChargesOneTime = [];
        if (customCharges!.isNotEmpty) {
          for (var i = 0; i < customCharges!.length; i++) {
            if (i != 0) {
              for (var j = 0; j < customCharges![i].length; j++) {
                otherChargesOneTime.add(customCharges![i][j]);
              }
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
    fetchBookingPaymentDetails();
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
      body: SafeArea(
          child: flagcalled == true
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          5.0, 10.0, 5.0, 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          horizontalSpaceMedium,
                          Text(
                            widget.title!.isEmpty
                                ? '${widget.flatBuyerRequest!.flatBuyerName} ${widget.inventryFlatName ?? ''} '
                                : widget.title!.toUpperCase(),
                            style: boldText,
                          ),
                          widget.navigationFlag! == "SoldInventory"
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: InkWell(
                                    onTap: () {
                                      if (arrRegistrationDoc!.isNotEmpty) {
                                        showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (BuildContext context) =>
                                                Dialog(
                                                  elevation: 0,
                                                  child: SizedBox(
                                                    height: 600,
                                                    width: 460.0,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10.0,
                                                                  bottom: 5),
                                                          child: Text(
                                                            'Flat Registration Document',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                        const Divider(
                                                          color: Colors.grey,
                                                          thickness: 1,
                                                        ),
                                                        SizedBox(
                                                          height: 490,
                                                          child:
                                                              SingleChildScrollView(
                                                            child: Wrap(
                                                              children: List.generate(
                                                                  growable:
                                                                      true,
                                                                  arrRegistrationDoc!
                                                                      .length,
                                                                  (index) {
                                                                return Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top: 10,
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10),
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        arrRegistrationDoc![index].flatDocName.toString().split(".").last ==
                                                                                'pdf'
                                                                            ? Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                  builder: (_) {
                                                                                    return PdfViewer(
                                                                                      fileName: arrRegistrationDoc![index].flatDocName.toString(),
                                                                                      fileUrl: '${AppUrl.globalFlatRegistrationDocURLMain}${arrRegistrationDoc![index].flatDocName.toString()}',
                                                                                    );
                                                                                  },
                                                                                ),
                                                                              )
                                                                            : Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                  builder: (_) {
                                                                                    return ImagePreviewViewer(
                                                                                      fileName: arrRegistrationDoc![index].flatDocName.toString(),
                                                                                      fileUrl: '${AppUrl.globalFlatRegistrationDocURLMain}${arrRegistrationDoc![index].flatDocName.toString()}',
                                                                                    );
                                                                                  },
                                                                                ),
                                                                              );
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            150,
                                                                        decoration: BoxDecoration(
                                                                            border:
                                                                                Border.all(color: Colors.grey),
                                                                            borderRadius: BorderRadius.circular(5)),
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            const SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            arrRegistrationDoc![index].flatDocName.toString().split(".").last == 'pdf'
                                                                                ? Image.asset(
                                                                                    'images/projectmanagement/pdf.png',
                                                                                    width: 100.0,
                                                                                    height: 100.0,
                                                                                    fit: BoxFit.cover,
                                                                                  )
                                                                                : Image.network(
                                                                                    '${AppUrl.globalFlatRegistrationDocURLMain}${arrRegistrationDoc![index].flatDocName.toString()}',
                                                                                    width: 100,
                                                                                    height: 100,
                                                                                  ),
                                                                            const SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            Text(
                                                                              arrRegistrationDoc![index].flatDocName.toString().capitalize(),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ));
                                                              }),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                border: Border
                                                                    .all(),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                color: Colors
                                                                    .black),
                                                            width: 240,
                                                            height: 40,
                                                            child:
                                                                const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top:
                                                                          10.0),
                                                              child: Text(
                                                                'Close',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        16),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ));
                                      } else {}
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1.0,
                                              color:
                                                  arrRegistrationDoc!.isNotEmpty
                                                      ? Colors.green
                                                      : Colors.red),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text( 
                                            arrRegistrationDoc!.isNotEmpty
                                                ? 'Reg. Doc.'
                                                : 'Not Reg.',
                                            style: arrRegistrationDoc!
                                                    .isNotEmpty
                                                ? const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0,
                                                    color: Colors.green)
                                                : const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0,
                                                    color: Colors.red)),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox()
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1.0,
                      thickness: 0.5,
                      indent: 1.0,
                      endIndent: 1.0,
                      color: Colors.black,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            child: Column(
                              children: [
                                IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      horizontalSpaceSmall,
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              const Text('FLAT AREA',
                                                  style: boldText),
                                              verticalSpaceSmall,
                                              Text(
                                                  '${widget.flatBuyerRequest?.flatArea} Sq.Ft.',
                                                  style: boldText13),
                                              verticalSpaceTiny,
                                              Text(
                                                  'No. of Parking - ${widget.flatBuyerRequest?.noOfParking}',
                                                  style: boldText13)
                                            ],
                                          ),
                                        ),
                                      ),
                                      const VerticalDivider(
                                        width: 1.0,
                                        thickness: 1.0,
                                        indent: 10.0,
                                        endIndent: 10.0,
                                        color: Colors.black54,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              const Text('RATE PER Sq.Ft.',
                                                  style: boldText),
                                              verticalSpaceSmall,
                                              Text(
                                                '\u{20B9}${widget.flatBuyerRequest!.flatRateCal.toString()}',
                                                style: boldText13,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      const VerticalDivider(
                                        width: 1.0,
                                        thickness: 1.0,
                                        indent: 10.0,
                                        endIndent: 10.0,
                                        color: Colors.black54,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              const Text('Total Value(100%)',
                                                  style: boldText),
                                              verticalSpaceTiny,
                                              Text(
                                                  widget.flatTotalValue == '' ||
                                                          widget.flatTotalValue ==
                                                              null
                                                      ? currencyFormat.format(
                                                          double.parse(widget
                                                                  .flatBuyerRequest
                                                                  ?.flatTotalWithoutGst ??
                                                              '0'))
                                                      : currencyFormat.format(
                                                          double.parse(widget
                                                                  .flatTotalValue ??
                                                              '0')),
                                                  style: boldText13),
                                              const Text('(Excl. G.S.T)',
                                                  style: normalText12),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          const Divider(
                            height: 1.0,
                            thickness: 0.5,
                            indent: 1.0,
                            endIndent: 1.0,
                            color: Colors.black,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: SizedBox(
                              height: 40,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    child: const Text(
                                      'Title',
                                      style: boldText13,
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    child: const Text(
                                      'Percentage',
                                      style: boldText13,
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    child: const Text(
                                      'Remarks/Date',
                                      style: boldText13,
                                    ),
                                  ),
                                  const Expanded(
                                    child: Text(
                                      'Amount',
                                      style: boldText13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(
                            height: 1.0,
                            thickness: 0.5,
                            indent: 1.0,
                            endIndent: 1.0,
                            color: Colors.black,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: buyerPaymentDetails!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return SizedBox(
                                  // height: 60,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      verticalSpaceSmall,
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4,
                                              child: Text(
                                                buyerPaymentDetails![index]
                                                    .flatPaymentTest!,
                                                style: normalText,
                                              ),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4,
                                              child: Text(
                                                '${buyerPaymentDetails![index].flatPaymentPercentage!}%',
                                                style: normalText,
                                              ),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4,
                                              child: Text(
                                                buyerPaymentDetails![index]
                                                    .flatPaymentTemplateRemark!,
                                                style: normalText,
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    currencyFormat.format(double
                                                        .parse(buyerPaymentDetails![
                                                                index]
                                                            .flatPaymentAmount!)),
                                                    style: normalText,
                                                  ),
                                                  widget.navigationFlag! ==
                                                          "SoldInventory"
                                                      ? buyerPaymentDetails![
                                                                      index]
                                                                  .flatPaymentDoneStatus ==
                                                              "1"
                                                          ? const Icon(
                                                              Icons
                                                                  .check_circle_rounded,
                                                              color:
                                                                  Colors.green,
                                                            )
                                                          : buyerPaymentDetails![
                                                                          index]
                                                                      .flatPaymentDoneStatus ==
                                                                  "2"
                                                              ? const Icon(
                                                                  Icons.circle,
                                                                  color: Colors
                                                                      .red,
                                                                )
                                                              : const Icon(
                                                                  Icons
                                                                      .circle_outlined,
                                                                  color: Colors
                                                                      .black,
                                                                )
                                                      : const SizedBox()
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      verticalSpaceSmall,
                                      verticalSpaceSmall,
                                      const Divider(
                                        height: 1.0,
                                        thickness: 0.5,
                                        indent: 1.0,
                                        endIndent: 1.0,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          widget.navigationFlag! == "SoldInventory"
                              ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      _visible = !_visible;
                                      topHeight = 30;
                                    });
                                  },
                                  child: SizedBox(
                                    height: _visible ? 205 : 85.0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AnimatedOpacity(
                                          opacity: _visible ? 1.0 : 0.0,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          child: SizedBox(
                                            height: _visible ? 194.0 : 0.0,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 40.0, right: 40.0),
                                              child: Column(
                                                children: [
                                                  const SizedBox(
                                                    height: 30.0,
                                                    child: Stack(
                                                      children: [
                                                        Divider(
                                                          height: 1.0,
                                                          thickness: 0.5,
                                                          indent: 1,
                                                          endIndent: 1,
                                                          color: Colors.black,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 18.0),
                                                          child: Center(
                                                            child: Text(
                                                                'VIEW LESS',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .black)),
                                                          ),
                                                        ),
                                                        Center(
                                                            child: Icon(
                                                                Icons
                                                                    .arrow_drop_down_outlined,
                                                                color: Colors
                                                                    .black,
                                                                size: 30)),
                                                      ],
                                                    ),
                                                  ),
                                                  verticalSpaceSmall,
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                          'A.  Sub Total',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                      horizontalSpaceMedium,
                                                      Text(
                                                          currencyFormat.format(
                                                              double.parse(
                                                                  flatPaymentAmount!)),
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black)),
                                                    ],
                                                  ),
                                                  verticalSpaceTiny,
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text('B.  T.D.S',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                      horizontalSpaceMedium,
                                                      Text(
                                                          currencyFormat.format(
                                                              double.parse(
                                                                  flatTdsAmount!)),
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black)),
                                                    ],
                                                  ),
                                                  verticalSpaceTiny,
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text('C. G.S.T',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                      horizontalSpaceMedium,
                                                      Text(
                                                          currencyFormat.format(
                                                              double.parse(
                                                                  flatGstAmount!)),
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black)),
                                                    ],
                                                  ),
                                                  verticalSpaceTiny,
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                          'D. G.S.T Payable)',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                      horizontalSpaceMedium,
                                                      Text(
                                                          currencyFormat.format(
                                                              double.parse(
                                                                  totalGstPayable!)),
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black)),
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
                                                  verticalSpaceTiny,
                                                  SizedBox(
                                                    height: 40.0,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        const Text(
                                                            'Total Amount - (A+D)\nIncl.G.S.T',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black)),
                                                        horizontalSpaceMedium,
                                                        Text(
                                                            currencyFormat.format(
                                                                double.parse(
                                                                    flatTotalAmountDue!)),
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: _visible ? 0.0 : 30.0,
                                          child: Stack(
                                            children: [
                                              const Divider(
                                                height: 1.0,
                                                thickness: 0.5,
                                                indent: 1,
                                                endIndent: 1,
                                                color: Colors.black,
                                              ),
                                              SizedBox(
                                                height: _visible ? 0.0 : 30.0,
                                                child: const Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 18.0),
                                                  child: Center(
                                                    child: Text('VIEW MORE',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 10,
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                  child: SizedBox(
                                                      height:
                                                          _visible ? 0.0 : 30.0,
                                                      child: Icon(
                                                          Icons
                                                              .arrow_drop_up_outlined,
                                                          color: _visible
                                                              ? Colors.white
                                                              : Colors.black,
                                                          size: 30))),
                                            ],
                                          ),
                                        ),
                                        verticalSpaceSmall,
                                        SizedBox(
                                          height: _visible ? 0.0 : 45.0,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 40.0,
                                                right: 40.0,
                                                top: 5.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                    'Total Amount - (A+D)\nIncl.G.S.T',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                                horizontalSpaceMedium,
                                                Text(
                                                    currencyFormat.format(
                                                        double.parse(
                                                            flatTotalAmountDue!)),
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          widget.navigationFlag! == "SoldInventory"
                              ? const Divider(
                                  height: 1,
                                  thickness: 0.5,
                                  indent: 1,
                                  endIndent: 1,
                                  color: Colors.black,
                                )
                              : const SizedBox(),
                          widget.navigationFlag! == "SoldInventory"
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (widget.memberShipForm == "0" &&
                                        responseData?.other_charges_flag == '1')
                                      InkWell(
                                        onTap: () {
                                          _OtherCharges();
                                        },
                                        child: Container(
                                            padding:
                                                const EdgeInsets.only(top: 13),
                                            height: 50,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            color: Colors.black,
                                            child: const Text(
                                              'OTHER CHARGES',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            )),
                                      ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (widget.memberShipForm == "0" &&
                                        responseData?.other_charges_flag == '1')
                                      InkWell(
                                        onTap: () {
                                          _OtherCharges();
                                        },
                                        child: Container(
                                            padding:
                                                const EdgeInsets.only(top: 13),
                                            height: 50,
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2) -
                                                1,
                                            color: Colors.black,
                                            child: const Text(
                                              'OTHER CHARGES',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            )),
                                      ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          var projectId = widget.projectId!;
                                          var projectName = widget.projectName!;
                                          var towarId = '';
                                          if (widget.towarId != null) {
                                            towarId = widget.towarId!;
                                          }
                                          if (widget.flatBuyerRequest
                                                  ?.buyerFlatStatus! ==
                                              "4") {
                                            rejectReserveInventoryModal();
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) {
                                                  return BookingPreview(
                                                    projectId: projectId,
                                                    projectName: projectName,
                                                    towarName: widget.towarName,
                                                    towarId: towarId,
                                                    flatBuyerRequest: widget
                                                        .flatBuyerRequest!,
                                                  );
                                                },
                                              ),
                                            ).then((value) => {});
                                          }
                                        },
                                        child: Container(
                                            padding:
                                                const EdgeInsets.only(top: 13),
                                            height: 50,
                                            decoration: const BoxDecoration(
                                              color: Colors.black,
                                              border: Border(
                                                  left: BorderSide(
                                                      color: Colors.white,
                                                      width: 1)),
                                            ),
                                            // width:
                                            //     (MediaQuery.of(context).size.width /
                                            //             2) -
                                            //         1,

                                            // width: widget.memberShipForm == "0"
                                            //     ? ((MediaQuery.of(context)
                                            //                 .size
                                            //                 .width /
                                            //             2) -
                                            //         1)
                                            //     : (MediaQuery.of(context)
                                            //         .size
                                            //         .width),
                                            child: Text(
                                              widget.flatBuyerRequest
                                                          ?.buyerFlatStatus! ==
                                                      "4"
                                                  ? "CANCEL BOOKING"
                                                  : 'PREVIEW BOOKING',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                          widget.navigationFlag! == "SoldInventory"
                              ? SizedBox(
                                  height: 75,
                                  child: IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        horizontalSpaceSmall,
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                const Text('Total(Incl. G.S.T)',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black)),
                                                verticalSpaceSmall,
                                                Text(
                                                    currencyFormat.format(double
                                                        .parse(paymentBottomBar!
                                                            .totalFlatAmount!)),
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                            onTap: () {
                                              var projectId = widget.projectId!;
                                              var projectName =
                                                  widget.projectName!;
                                              var towarId = '';
                                              if (widget.towarId != null) {
                                                towarId = widget.towarId!;
                                              }
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) {
                                                    return PaymentReceivedListingView(
                                                      projectId: projectId,
                                                      projectName: projectName,
                                                      towarId: towarId,
                                                      flatPaymentHistory:
                                                          flatPaymentHistory,
                                                      strTotalAmount:
                                                          paymentBottomBar
                                                              ?.received!,
                                                      strTotalGstPaid:
                                                          strTotalGstPaid!,
                                                      strTotalGstDue:
                                                          strTotalGstDue!,
                                                      strTotalGstPayable:
                                                          strTotalGstPayable!,
                                                      strTotalGstGenerated:
                                                          strTotalGstGenerated,
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  const Text('Received',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black)),
                                                  verticalSpaceSmall,
                                                  Text(
                                                      currencyFormat.format(
                                                          double.parse(
                                                              paymentBottomBar!
                                                                  .received!)),
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                                const Text('Balance',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black)),
                                                verticalSpaceSmall,
                                                Text(
                                                    currencyFormat.format(
                                                        double.parse(
                                                            paymentBottomBar!
                                                                .balance!)),
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black)),
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
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                const Text('Overdue',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black)),
                                                verticalSpaceSmall,
                                                Text(
                                                  currencyFormat.format(
                                                      double.parse(
                                                          paymentBottomBar!
                                                              .overdue!)),
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.red),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ],
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
    );
  }

  void _OtherCharges() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Center(child: Text('Other Charges')),
              actionsAlignment: MainAxisAlignment.center,
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(color: Colors.black12),
                        child: const Center(
                          child: Text(
                            'ADDED TO FLAT VALUE',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 75.0 * otherCharges.length,
                        child: ListView.builder(
                          itemCount: otherCharges.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              height: 75,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(otherCharges[index].name!),
                                  verticalSpaceTiny,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${currencyFormat.format(double.parse(otherCharges[index].value!))} ${otherCharges[index].unit!}',
                                      ),
                                      Text(currencyFormat.format(double.parse(
                                          otherCharges[index].totalValue!))),
                                    ],
                                  ),
                                  verticalSpaceTiny,
                                  const Divider(),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(color: Colors.black12),
                        child: const Center(
                          child: Text(
                            'ONE TIME CHARGES',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 75.0 * otherChargesOneTime.length,
                        child: ListView.builder(
                          itemCount: otherChargesOneTime.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            var value = otherChargesOneTime[index].value!;
                            var totalValue =
                                otherChargesOneTime[index].totalValue!;
                            return SizedBox(
                              height: 75,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(otherChargesOneTime[index].name!),
                                  verticalSpaceTiny,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${value != '' ? currencyFormat.format(double.parse(otherChargesOneTime[index].value!)) : '\u{20B9}0'} ${otherChargesOneTime[index].unit!}',
                                      ),
                                      Text(totalValue != ''
                                          ? currencyFormat.format(double.parse(
                                              otherChargesOneTime[index]
                                                  .totalValue!))
                                          : '\u{20B9}0'),
                                    ],
                                  ),
                                  verticalSpaceTiny,
                                  const Divider(),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      fixedSize: const Size.fromWidth(100),
                      padding: const EdgeInsets.all(10),
                      textStyle: const TextStyle(color: Colors.white)),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text('CLOSE', style: TextStyle(color: Colors.white)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
        });
  }

  rejectReserveInventoryModal() {
    return showDialog<void>(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 10),
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: const Text(
                "Are you sure you want to cancel this booking?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              content: const SizedBox(
                height: 20,
              ),
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Text(
                      "NO",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    rejectReserveInventory();
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Text(
                      'YES',
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
            );
          });
        });
  }
}
