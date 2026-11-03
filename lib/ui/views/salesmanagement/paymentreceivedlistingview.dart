import 'package:flutter/material.dart';

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../models/get_sale_buyer_request.dart';
import '../../../models/ws_get_buyer_payment_details.dart';
import '../../shared/ui_helpers.dart';

class PaymentReceivedListingView extends StatefulWidget {
  PaymentReceivedListingView(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.flagRedirect,
      this.flatPaymentHistory,
      this.strTotalAmount,
      this.strTotalGstPaid,
      this.strTotalGstDue,
      this.strTotalGstPayable,
      this.strTotalGstGenerated});

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? flagRedirect;

  String? strTotalAmount;
  String? strTotalGstPaid;
  String? strTotalGstDue;
  String? strTotalGstPayable;
  String? strTotalGstGenerated;

  List<FlatPaymentHistory>? flatPaymentHistory;

  @override
  State<PaymentReceivedListingView> createState() =>
      _PaymentReceivedListingViewState();
}

class _PaymentReceivedListingViewState
    extends State<PaymentReceivedListingView> {
  bool flagcalled = true;
  bool norecord = false;
  List<FlatPaymentHistory>? flatPaymentHistoryOriginal;
  String? offset = '0';
  String searchTermValue = '';
  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    flatPaymentHistoryOriginal = widget.flatPaymentHistory;
    if (widget.flatPaymentHistory!.isEmpty) {
      norecord = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text('${widget.projectName!.toUpperCase()} - Payment Received',
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
              child: flagcalled == true
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        verticalSpaceSmall,
                        Padding(
                          padding: const EdgeInsets.only(left: 60.0, right: 60),
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  if (value.length > 2) {
                                    var filteredList =
                                        flatPaymentHistoryOriginal
                                            ?.where((element) => element.title!
                                                .toLowerCase()
                                                .contains(value.toLowerCase()))
                                            .toList();
                                    setState(() {
                                      widget.flatPaymentHistory = filteredList;
                                    });
                                  }
                                } else {
                                  setState(() {
                                    widget.flatPaymentHistory =
                                        flatPaymentHistoryOriginal;
                                  });
                                }
                              },
                              style: const TextStyle(fontSize: 13),
                              controller: editingController,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(12.0),
                                  labelText: "Search",
                                  hintText: "Search",
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
                                child: ListView.builder(
                                  itemCount: widget.flatPaymentHistory?.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
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
                                                          child: Text('Title',
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
                                                            widget
                                                                .flatPaymentHistory![
                                                                    index]
                                                                .title!,
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
                                                              'Demand No.',
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
                                                            widget
                                                                .flatPaymentHistory![
                                                                    index]
                                                                .demandNumber!,
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
                                                              'Payment On',
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
                                                                .format(DateTime
                                                                    .parse(widget
                                                                        .flatPaymentHistory![
                                                                            index]
                                                                        .paymentDate!))
                                                                .toString(),
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
                                                          child: Text('Amount',
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
                                                            currencyFormat.format(
                                                                double.parse(widget
                                                                    .flatPaymentHistory![
                                                                        index]
                                                                    .flatBuyerPaymentAmount!)),
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
                                                              'Payment Mode',
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
                                                            widget
                                                                .flatPaymentHistory![
                                                                    index]
                                                                .flatBuyerPayementMode!,
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
                                                              'Dated On',
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
                                                                .format(DateTime
                                                                    .parse(widget
                                                                        .flatPaymentHistory![
                                                                            index]
                                                                        .flatBuyerPaymentDate!))
                                                                .toString(),
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
                                                          child: Text('Remarks',
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
                                                            widget
                                                                .flatPaymentHistory![
                                                                    index]
                                                                .flatBuyerPaymentRemarks!,
                                                            style: normalText),
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
                                    );
                                  },
                                ),
                              ),
                        const Divider(
                          height: 0.5,
                          thickness: 0.5,
                          indent: 1,
                          endIndent: 1,
                          color: Colors.black,
                        ),
                        SizedBox(
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
                                        const Text('Total G.S.T',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black)),
                                        verticalSpaceSmall,
                                        Text(
                                            currencyFormat.format(double.parse(
                                                widget.strTotalGstGenerated!)),
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
                                          const Text('G.S.T(as per D.N)',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black)),
                                          verticalSpaceSmall,
                                          Text(
                                              currencyFormat.format(
                                                  double.parse(widget
                                                      .strTotalGstPayable!)),
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
                                        const Text('G.S.T Paid',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black)),
                                        verticalSpaceSmall,
                                        Text(
                                            currencyFormat.format(double.parse(
                                                widget.strTotalGstPaid!)),
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
                                        const Text('G.S.T Due',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black)),
                                        verticalSpaceSmall,
                                        Text(
                                            currencyFormat.format(double.parse(
                                                widget.strTotalGstDue!)),
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  : const Center(child: CircularProgressIndicator())),
        ));
  }
}
