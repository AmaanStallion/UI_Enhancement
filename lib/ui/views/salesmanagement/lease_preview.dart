import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_flat_list_by_project.dart';
import 'package:stallion/models/get_lease_sales.dart';
import 'package:stallion/models/message_success.dart';
import 'package:stallion/models/ws_get_buyer_payment_details.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
// import 'package:stallion/models/ws_get_buyer_payment_details.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/salesmanagement/bookingpreview.dart';
import 'package:stallion/ui/views/salesmanagement/paymentreceivedlistingview.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/models/get_broker_details.dart' as sale;

class LeasePreview extends StatefulWidget {
  LeasePreview({
    super.key,
    this.projectName,
    this.projectId,
    this.towarId,
    this.towarName,
    this.flatBuyerId,
    this.navigationFlag,
    this.memberShipForm = "0",
    this.flatBuyerRequest,

    // summary fields
    // this.flatArea,
    // this.paymentType,
    // this.totalValue,
    // this.subTotal,
    // this.tds,
    // this.gstTotal,
    // this.gstPayable,
    // this.totalAmountInclGst,
    // this.received,
    // this.balance,
    // this.overdue,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? flatBuyerId;
  final String? navigationFlag;
  final String? memberShipForm;
  sale.FlatBuyerRequest? flatBuyerRequest;

  // Summary values (nullable – fall back to mock data when null)
  // final String? flatArea;
  // final String? paymentType;
  // final String? totalValue;
  // final String? subTotal;
  // final String? tds;
  // final String? gstTotal;
  // final String? gstPayable;
  // final String? totalAmountInclGst;
  // final String? received;
  // final String? balance;
  // final String? overdue;

  @override
  State<LeasePreview> createState() => _LeasePreviewState();
}

class _LeasePreviewState extends State<LeasePreview> {
  bool _tableExpanded = true;

  // ── helpers ─────────────────────────────────────────────────────────────────
  // String get _flatArea => widget.flatArea ?? '605.0 SqFt';
  // String get _paymentType => widget.paymentType ?? 'Monthly';
  // String get _totalValue => widget.totalValue ?? '₹ 22,48,440';
  // String get _subTotal => widget.subTotal ?? '₹ 19,47,831';
  // String get _tds => widget.tds ?? '₹ 0';
  // String get _gstTotal => widget.gstTotal ?? '₹ 3,50,609';
  // String get _gstPayable => widget.gstPayable ?? '₹ 3,50,609';
  // String get _totalInclGst => widget.totalAmountInclGst ?? '₹ 22,98,440';
  // String get _received => widget.received ?? '₹ 0';
  // String get _balance => widget.balance ?? '₹ 22,98,440';
  // String get _overdue => widget.overdue ?? '₹ 23,60,856';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<BuyerPaymentDetail>? buyerPaymentDetails = [];
  String? flatArea = '';
  String? flatPaymentStructureType = '';
  String? flatValue = '0';
  FlatBuyerDetail? flatBuyerDetails = FlatBuyerDetail();
  bool _visible = false;
  double? topHeight = 5;
  String? flatPaymentAmount = '0';
  String? flatTdsAmount = '0';
  String? flatGstAmount = '0';
  String? totalGstPayable = '0';
  String? flatTotalAmountDue = '0';
  LeasePreviewResponse? responseData;
  List<CustomCharge> otherCharges = [];
  List<CustomCharge> otherChargesOneTime = [];
  List<List<CustomCharge>>? customCharges = [];
  PaymentBottomBar? paymentBottomBar;
  List<FlatPaymentHistory>? flatPaymentHistory;
  String? strTotalGstPaid = '0';
  String? strTotalGstDue = '0';
  String? strTotalGstPayable = '0';
  String? strTotalGstGenerated = '0';

  Future<LeasePreviewResponse?> fetchBookingPaymentDetails() async {
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
      "flat_buyer_id": widget.flatBuyerId ?? ''
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
      final dataModel = leasePreviewFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          buyerPaymentDetails = dataModel.response?.buyerPaymentDetails;
          flatArea = dataModel.response?.flatArea;
          flatPaymentStructureType =
              dataModel.response?.flatBuyerDetails?[0].flatPaymentStructureType;
          flatBuyerDetails = dataModel.response?.flatBuyerDetails?[0];
          flatValue =
              dataModel.response?.flatBuyerDetails?[0].flatTotalWithoutGst ??
                  '0';
          flatPaymentAmount = dataModel.response?.flatPaymentAmount;
          flatTdsAmount = dataModel.response?.flatTdsAmount;
          flatGstAmount = dataModel.response?.flatGstAmount;
          totalGstPayable = dataModel.response?.totalGstPayable;
          flatTotalAmountDue = dataModel.response?.flatTotalAmountDue;
          responseData = dataModel.response;
          customCharges = dataModel.response?.customCharges;
          paymentBottomBar = dataModel.response?.paymentBottomBar;
          flatPaymentHistory = dataModel.response?.flatPaymentHistory;
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
        });
        //   widget.flatBuyerRequest = dataModel.response?.flatBuyerDetails?[0];
        //   buyerPaymentDetails = dataModel.response?.buyerPaymentDetails!;
        //   responseData = dataModel.response;
        //   flatPaymentAmount = dataModel.response?.flatPaymentAmount;
        //   flatGstAmount = dataModel.response?.flatGstAmount;
        //   totalGstPayable = dataModel.response?.totalGstPayable;
        //   flatTdsAmount = dataModel.response?.flatTdsAmount;
        //   flatTotalAmountDue = dataModel.response?.flatTotalAmountDue;
        //   paymentBottomBar = dataModel.response?.paymentBottomBar;
        //   flatPaymentHistory = dataModel.response?.flatPaymentHistory;
        //   arrRegistrationDoc = dataModel.response?.arrRegistrationDoc;

        //   strTotalGstPaid = dataModel.response?.totalGstPaid;
        //   strTotalGstDue = dataModel.response?.totalGstDue;
        //   strTotalGstPayable = dataModel.response?.totalGstPayable;
        //   strTotalGstGenerated = dataModel.response?.totalGstGeneratedHistry;

        //   setState(() {
        //     flagcalled = true;
        //   });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
    return null;
  }

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

  void _OtherCharges() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Center(
                  child: Text(
                'OTHER CHARGES',
                style: TextStyle(fontSize: 16, color: Colors.black),
              )),
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

  @override
  void initState() {
    super.initState();
    fetchBookingPaymentDetails();
  }

  // ── build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final isDesktop = screenW >= 900;

    // Content is placed inside a centred max-width card on desktop
    final content = _buildContent(context, isDesktop);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Lease Preview',
            style: TextStyle(
                fontStyle: FontStyle.normal,
                fontSize: 17.0,
                fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        body: content,
        bottomNavigationBar:
            // Container(
            //   height: _tableExpanded ? 437 : 192,
            //   child: Column(
            //     children: [
            //       // ── Sub-totals ───────────────────────────────────────────
            //       if (_tableExpanded)
            //         _SummaryLine(label: 'A.  Sub Total', value: _subTotal),
            //       if (_tableExpanded) _SummaryLine(label: 'B.  T.D.S', value: _tds),
            //       if (_tableExpanded)
            //         _SummaryLine(label: 'C.  G.S.T', value: _gstTotal),
            //       if (_tableExpanded)
            //         _SummaryLine(label: 'D.  G.S.T Payable', value: _gstPayable),
            //       if (_tableExpanded) const Divider(height: 1),
            //       if (_tableExpanded) _TotalAmountBar(value: _totalInclGst),
            //       // ── View more/less toggle ────────────────────────────────
            //       InkWell(
            //         onTap: () => setState(() => _tableExpanded = !_tableExpanded),
            //         child: Padding(
            //           padding: const EdgeInsets.symmetric(vertical: 12),
            //           child: Column(
            //             children: [
            //               Icon(
            //                 _tableExpanded
            //                     ? Icons.arrow_drop_down
            //                     : Icons.arrow_drop_up,
            //                 color: Colors.grey.shade600,
            //               ),
            //               Text(
            //                 _tableExpanded ? 'VIEW LESS' : 'VIEW MORE',
            //                 style: TextStyle(
            //                   fontSize: 12,
            //                   fontWeight: FontWeight.w600,
            //                   letterSpacing: 1.2,
            //                   color: Colors.grey.shade600,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //       // ── Other Charges header ─────────────────────────────────────────
            //       Container(
            //         color: Colors.black,
            //         padding: const EdgeInsets.symmetric(vertical: 14),
            //         alignment: Alignment.center,
            //         child: const Text(
            //           'Other Charges',
            //           style: TextStyle(
            //             color: Colors.white,
            //             fontSize: 16,
            //             fontWeight: FontWeight.w600,
            //             letterSpacing: 0.5,
            //           ),
            //         ),
            //       ),

            //       // ── Bottom totals ─────────────────────────────────────────────────
            //       _BottomTotalsBar(
            //         totalInclGst: _totalInclGst,
            //         received: _received,
            //         balance: _balance,
            //         overdue: _overdue,
            //         isDesktop: isDesktop,
            //       ),
            //       // const SizedBox(height: 24),
            //     ],
            //   ),
            // ),
            Container(
          height: widget.navigationFlag! == "SoldInventory"
              ? _visible
                  ? 331
                  : 211
              : 50,
          child: Column(
            children: [
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedOpacity(
                              opacity: _visible ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 500),
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
                                                  EdgeInsets.only(top: 18.0),
                                              child: Center(
                                                child: Text('VIEW LESS',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 10,
                                                        color: Colors.black)),
                                              ),
                                            ),
                                            Center(
                                                child: Icon(
                                                    Icons
                                                        .arrow_drop_down_outlined,
                                                    color: Colors.black,
                                                    size: 30)),
                                          ],
                                        ),
                                      ),
                                      verticalSpaceSmall,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('A.  Sub Total',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15,
                                                  color: Colors.black)),
                                          horizontalSpaceMedium,
                                          Text(
                                              currencyFormat.format(
                                                  double.parse(
                                                      flatPaymentAmount ??
                                                          '0')),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15,
                                                  color: Colors.black)),
                                        ],
                                      ),
                                      verticalSpaceTiny,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('B.  T.D.S',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15,
                                                  color: Colors.black)),
                                          horizontalSpaceMedium,
                                          Text(
                                              currencyFormat.format(
                                                  double.parse(flatTdsAmount!)),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15,
                                                  color: Colors.black)),
                                        ],
                                      ),
                                      verticalSpaceTiny,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('C. G.S.T',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15,
                                                  color: Colors.black)),
                                          horizontalSpaceMedium,
                                          Text(
                                              currencyFormat.format(
                                                  double.parse(flatGstAmount!)),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15,
                                                  color: Colors.black)),
                                        ],
                                      ),
                                      verticalSpaceTiny,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('D. G.S.T Payable)',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15,
                                                  color: Colors.black)),
                                          horizontalSpaceMedium,
                                          Text(
                                              currencyFormat.format(
                                                  double.parse(
                                                      totalGstPayable!)),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15,
                                                  color: Colors.black)),
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
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                                'Total Amount - (A+D)\nIncl.G.S.T',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15,
                                                    color: Colors.black)),
                                            horizontalSpaceMedium,
                                            Text(
                                                currencyFormat.format(
                                                    double.parse(
                                                        flatTotalAmountDue!)),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15,
                                                    color: Colors.black)),
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
                                      padding: EdgeInsets.only(top: 18.0),
                                      child: Center(
                                        child: Text('VIEW MORE',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 10,
                                                color: Colors.black)),
                                      ),
                                    ),
                                  ),
                                  Center(
                                      child: SizedBox(
                                          height: _visible ? 0.0 : 30.0,
                                          child: Icon(
                                              Icons.arrow_drop_up_outlined,
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
                                    left: 40.0, right: 40.0, top: 5.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                        'Total Amount - (A+D)\nIncl.G.S.T',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.black)),
                                    horizontalSpaceMedium,
                                    Text(
                                        currencyFormat.format(
                                            double.parse(flatTotalAmountDue!)),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.memberShipForm == "0" &&
                            responseData?.otherChargesFlag == '1')
                          InkWell(
                            onTap: () {
                              _OtherCharges();
                            },
                            child: Container(
                                padding: const EdgeInsets.only(top: 13),
                                height: 50,
                                width: MediaQuery.of(context).size.width,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.memberShipForm == "0" &&
                            responseData?.otherChargesFlag == '1')
                          InkWell(
                            onTap: () {
                              _OtherCharges();
                            },
                            child: Container(
                                padding: const EdgeInsets.only(top: 13),
                                height: 50,
                                width:
                                    (MediaQuery.of(context).size.width / 2) - 1,
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
                              if (widget.flatBuyerRequest?.buyerFlatStatus! ==
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
                                        flatBuyerRequest:
                                            widget.flatBuyerRequest!,
                                      );
                                    },
                                  ),
                                ).then((value) => {});
                              }
                            },
                            child: Container(
                                padding: const EdgeInsets.only(top: 13),
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  border: Border(
                                      left: BorderSide(
                                          color: Colors.white, width: 1)),
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
                                  widget.flatBuyerRequest?.buyerFlatStatus! ==
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
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black)),
                                    verticalSpaceSmall,
                                    Text(
                                        currencyFormat.format(double.parse(
                                            paymentBottomBar?.totalFlatAmount ??
                                                '0')),
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
                                onTap: () {
                                  var projectId = widget.projectId!;
                                  var projectName = widget.projectName!;
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
                                              paymentBottomBar?.received!,
                                          strTotalGstPaid: strTotalGstPaid!,
                                          strTotalGstDue: strTotalGstDue!,
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
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const Text('Received',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black)),
                                      verticalSpaceSmall,
                                      Text(
                                          currencyFormat.format(double.parse(
                                              paymentBottomBar?.received ??
                                                  '0')),
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
                                    const Text('Balance',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black)),
                                    verticalSpaceSmall,
                                    Text(
                                        currencyFormat.format(double.parse(
                                            paymentBottomBar?.balance ?? '0')),
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
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
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black)),
                                    verticalSpaceSmall,
                                    Text(
                                      currencyFormat.format(double.parse(
                                          paymentBottomBar?.overdue ?? '0')),
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
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
        ));
  }

  Widget _buildContent(BuildContext context, bool isDesktop) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                              const Text('FLAT AREA', style: boldText),
                              verticalSpaceSmall,
                              Text(flatArea ?? '', style: boldText13),
                              // verticalSpaceTiny,
                              // Text(
                              //     'No. of Parking - ${widget.flatBuyerRequest?.noOfParking}',
                              //     style: boldText13)
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
                              const Text('PAYMENT TYPE', style: boldText),
                              verticalSpaceSmall,
                              Text(
                                flatPaymentStructureType == '1'
                                    ? 'Monthly'
                                    : 'Yearly',
                                // flatPaymentStructureType ?? '',
                                // '\u{20B9}${widget.flatBuyerRequest!.flatRateCal.toString()}',
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
                              const Text('Total Value', style: boldText),
                              verticalSpaceTiny,
                              Text(
                                  currencyFormat
                                      .format(double.parse(flatValue ?? '0')),
                                  style: boldText13),
                              const Text('(Excl. G.S.T)', style: normalText12),
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

          Divider(),
          // const SizedBox(height: 12),

          // ── Lease schedule table card ────────────────────────────────────
          // _SectionCard(
          //   child: Column(
          //     children: [
          //       // _TableHeader(isDesktop: isDesktop),
          //       // const Divider(height: 1),
          //       // AnimatedCrossFade(
          //       //   duration: const Duration(milliseconds: 300),
          //       //   crossFadeState:
          //       //       //  _tableExpanded
          //       //       //     ?
          //       //       CrossFadeState.showFirst
          //       //   // : CrossFadeState.showSecond
          //       //   ,
          //       //   firstChild: Column(
          //       //     children: buyerPaymentDetails!
          //       //         .map((r) => _LeaseRowTile(
          //       //             row: r,
          //       //             isDesktop: isDesktop,
          //       //             navigationFlag: widget.navigationFlag ?? '',
          //       //             flatPaymentDoneStatus:
          //       //                 r.flatPaymentDoneStatus ?? ''))
          //       //         .toList(),
          //       //   ),
          //       //   secondChild: const SizedBox.shrink(),
          //       // ),
          //       // const Divider(height: 1),
          //     ],
          //   ),
          // ),
          _buildScheduleTable(buyerPaymentDetails),

          // const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildScheduleTable(
    List<BuyerPaymentDetail>? schedule,
  ) {
    print('schedule length: ${schedule?.length}');
    print(schedule);
    double totalAmount = 0;
    double totalGst = 0;
    double totalGrandTotal = 0;
    for (final row in schedule!) {
      totalAmount += double.parse(row.flatPaymentAmount ?? '0');
      totalGst += double.parse(row.flatPaymentGstAmount ?? '0');
      totalGrandTotal += double.parse(row.flatPaymentAmount ?? '0') +
          double.parse(row.flatPaymentGstAmount ?? '0');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Table(
        border: const TableBorder(
          top: BorderSide.none,
          left: BorderSide.none,
          right: BorderSide.none,
          bottom: BorderSide.none,
          // verticalInside: BorderSide.none,
          horizontalInside: BorderSide(color: Colors.black26, width: 0.5),
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(1.8),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(1.8),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
            children: [
              // _tableCell(durationUnit == 'Monthly' ? 'Month' : 'Year',
              //     isHeader: true),
              _tableCell(
                flatPaymentStructureType == '1' ? 'Monthly' : 'Yearly',
                isHeader: true,
                showRightDivider: true,
              ),

              _tableCell('Date Range', isHeader: true, showRightDivider: true),
              _tableCell(flatPaymentStructureType == '1' ? 'Monthly' : 'Yearly',
                  isHeader: true, showRightDivider: true),
              _tableCell(
                  'G.S.T (${flatBuyerDetails?.flatGstPercentage ?? '18'}%)',
                  isHeader: true,
                  showRightDivider: true),
              _tableCell('Grand Total', isHeader: true),
            ],
          ),
          ...schedule!.map(
            (row) => TableRow(
              children: [
                _tableCell(row.flatPaymentOrder ?? '', showRightDivider: true),
                _tableCell(
                    '${DateFormat('dd MMM yy').format(row.flatPaymentDate ?? DateTime.now())}-${DateFormat('dd MMM yy').format(row.flatPaymentEndDate ?? DateTime.now())}',
                    showRightDivider: true),
                _tableCell(
                    _formatINR(double.parse(row.flatPaymentAmount ?? '0')),
                    showRightDivider: true),
                _tableCell(
                    _formatINR(double.parse(row.flatPaymentGstAmount ?? '0')),
                    showRightDivider: true),
                _tableCell(_formatINR(
                    double.parse(row.flatPaymentAmount ?? '0') +
                        double.parse(row.flatPaymentGstAmount ?? '0'))),
              ],
            ),
          ),
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
            children: [
              _tableCell('Total', isHeader: true, showRightDivider: true),
              _tableCell('', isHeader: true, showRightDivider: true),
              _tableCell(_formatINR(totalAmount),
                  isHeader: true, showRightDivider: true),
              _tableCell(_formatINR(totalGst),
                  isHeader: true, showRightDivider: true),
              _tableCell(_formatINR(totalGrandTotal), isHeader: true),
            ],
          ),
        ],
      ),
    );
  }

  String _formatINR(double value) {
    final f = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );
    return f.format(value);
  }

  Widget _tableCell(
    String text, {
    bool isHeader = false,
    bool showRightDivider = false,
  }) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
        if (showRightDivider)
          Positioned(
            top: 6, // 👈 adjust gap from top
            bottom: 6, // 👈 adjust gap from bottom
            right: 0,
            child: Container(
              width: 0.5,
              color: Colors.black45,
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 12),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(8),
      //   border: Border.all(color: Colors.grey.shade300),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.05),
      //       blurRadius: 4,
      //       offset: const Offset(0, 2),
      //     )
      //   ],
      // ),
      child: child,
    );
  }
}

// ── Top summary bar ──────────────────────────────────────────────────────────
class _TopSummaryBar extends StatelessWidget {
  final String flatArea;
  final String paymentType;
  final String totalValue;
  final bool isDesktop;

  const _TopSummaryBar({
    required this.flatArea,
    required this.paymentType,
    required this.totalValue,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final labelSize = isDesktop ? 14.0 : 13.0;
    final valueSize = isDesktop ? 20.0 : 16.0;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 20 : 14,
        horizontal: 12,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
                child: _SummaryCell(
                    label: 'Flat Area',
                    value: flatArea,
                    labelSize: labelSize,
                    valueSize: valueSize)),
            VerticalDivider(color: Colors.grey.shade300, width: 1),
            Expanded(
                child: _SummaryCell(
                    label: 'Payment Type',
                    value: paymentType == '1' ? 'Monthly' : 'Yearly',
                    labelSize: labelSize,
                    valueSize: valueSize)),
            VerticalDivider(color: Colors.grey.shade300, width: 1),
            Expanded(
              child: _SummaryCell(
                label: 'Total Value',
                value: currencyFormat.format(double.parse(totalValue ?? '0')),
                //  totalValue,
                subtitle: '(Excl. G.S.T)',
                labelSize: labelSize,
                valueSize: valueSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final double labelSize;
  final double valueSize;

  const _SummaryCell({
    required this.label,
    required this.value,
    this.subtitle,
    required this.labelSize,
    required this.valueSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: labelSize,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: valueSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
              textAlign: TextAlign.center),
          if (subtitle != null)
            Text(subtitle!,
                style: TextStyle(
                    fontSize: labelSize - 1, color: Colors.grey.shade500),
                textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Table header row ─────────────────────────────────────────────────────────
class _TableHeader extends StatelessWidget {
  final bool isDesktop;
  const _TableHeader({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final fs = isDesktop ? 14.0 : 12.0;
    const style = TextStyle(fontWeight: FontWeight.w700, color: Colors.black87);

    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: isDesktop ? 14 : 10, horizontal: 12),
      child: Row(
        children: [
          _headerCell('Year', 0.08, fs, style, TextAlign.center),
          _headerCell('Date Range', 0.22, fs, style, TextAlign.center),
          _headerCell('Yearly', 0.2, fs, style, TextAlign.center),
          _headerCell('G.S.T (18%)', 0.2, fs, style, TextAlign.center),
          _headerCell('Grand Total', 0.22, fs, style, TextAlign.center),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _headerCell(
      String text, double flex, double fs, TextStyle base, TextAlign align) {
    return Expanded(
      flex: (flex * 100).round(),
      child: Text(text, style: base.copyWith(fontSize: fs), textAlign: align),
    );
  }
}

// ── Individual lease table row ───────────────────────────────────────────────
class _LeaseRowTile extends StatelessWidget {
  final BuyerPaymentDetail row;
  final bool isDesktop;
  final String navigationFlag;
  final String? flatPaymentDoneStatus;
  const _LeaseRowTile(
      {required this.row,
      required this.isDesktop,
      required this.flatPaymentDoneStatus,
      required this.navigationFlag});

  @override
  Widget build(BuildContext context) {
    final fs = isDesktop ? 14.0 : 12.5;
    const cellStyle = TextStyle(color: Colors.black87);

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      padding:
          EdgeInsets.symmetric(vertical: isDesktop ? 14 : 10, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Text(row.flatPaymentOrder ?? '',
                style: cellStyle.copyWith(fontSize: fs),
                textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 22,
            child: Text(row.flatPaymentTest ?? '',
                style: cellStyle.copyWith(fontSize: fs),
                textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 20,
            child: Text(
                currencyFormat
                    .format(double.parse(row.flatPaymentAmount ?? '')),
                style: cellStyle.copyWith(fontSize: fs),
                textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 20,
            child: Text(
                currencyFormat
                    .format(double.parse(row.flatPaymentGstAmount ?? '')),
                // row.flatPaymentGstAmount ?? '',
                style: cellStyle.copyWith(fontSize: fs),
                textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 22,
            child: Text(
                currencyFormat.format(
                    double.parse(row.flatPaymentAmount ?? '0') +
                        double.parse(row.flatPaymentGstAmount ?? '0')),
                style: cellStyle.copyWith(fontSize: fs),
                textAlign: TextAlign.center),
          ),
          // Container(
          //   width: 16,
          //   height: 16,
          //   margin: const EdgeInsets.only(left: 6),
          //   decoration: BoxDecoration(
          //     color: Colors.red,
          //     shape: BoxShape.circle,
          //   ),
          // ),
          navigationFlag == "SoldInventory"
              ? flatPaymentDoneStatus == "1"
                  ? const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.green,
                    )
                  : flatPaymentDoneStatus == "2"
                      ? const Icon(
                          Icons.circle,
                          color: Colors.red,
                        )
                      : const Icon(
                          Icons.circle_outlined,
                          color: Colors.black,
                        )
              : const SizedBox(),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

// ── Summary line ─────────────────────────────────────────────────────────────
class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87)),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87)),
        ],
      ),
    );
  }
}

// ── Total amount highlighted bar ─────────────────────────────────────────────
class _TotalAmountBar extends StatelessWidget {
  final String value;
  const _TotalAmountBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Amount - (A + D)\nIncl. G.S.T',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          Text(
            value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

// ── Bottom totals bar ─────────────────────────────────────────────────────────
class _BottomTotalsBar extends StatelessWidget {
  final String totalInclGst;
  final String received;
  final String balance;
  final String overdue;
  final bool isDesktop;

  const _BottomTotalsBar({
    required this.totalInclGst,
    required this.received,
    required this.balance,
    required this.overdue,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final labelFs = isDesktop ? 13.0 : 11.5;
    final valueFs = isDesktop ? 16.0 : 13.0;

    return Container(
      color: Colors.white,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
                child: _BottomCell(
                    label: 'Total (Incl. G.S.T)',
                    value: totalInclGst,
                    labelFs: labelFs,
                    valueFs: valueFs,
                    valueColor: Colors.black)),
            VerticalDivider(color: Colors.grey.shade300, width: 1),
            Expanded(
                child: _BottomCell(
                    label: 'Received',
                    value: received,
                    labelFs: labelFs,
                    valueFs: valueFs,
                    valueColor: Colors.black)),
            VerticalDivider(color: Colors.grey.shade300, width: 1),
            Expanded(
                child: _BottomCell(
                    label: 'Balance',
                    value: balance,
                    labelFs: labelFs,
                    valueFs: valueFs,
                    valueColor: Colors.black)),
            VerticalDivider(color: Colors.grey.shade300, width: 1),
            Expanded(
                child: _BottomCell(
                    label: 'Overdue',
                    value: overdue,
                    labelFs: labelFs,
                    valueFs: valueFs,
                    valueColor: const Color(0xFFCC0000))),
          ],
        ),
      ),
    );
  }
}

class _BottomCell extends StatelessWidget {
  final String label;
  final String value;
  final double labelFs;
  final double valueFs;
  final Color valueColor;

  const _BottomCell({
    required this.label,
    required this.value,
    required this.labelFs,
    required this.valueFs,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: labelFs,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400)),
          const SizedBox(height: 5),
          Text(value,
              style: TextStyle(
                  fontSize: valueFs,
                  fontWeight: FontWeight.w700,
                  color: valueColor)),
        ],
      ),
    );
  }
}
