import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/get_contractor_payments.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';

class ContractAmtPaidView extends StatefulWidget {
  ContractAmtPaidView(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.woOrderId});

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? woOrderId;

  @override
  State<ContractAmtPaidView> createState() => _ContractAmtPaidViewState();
}

class _ContractAmtPaidViewState extends State<ContractAmtPaidView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  bool flagcalled = false;
  bool norecord = false;

  List<PaymentDetail>? paymentDetails = [];
  String? totalPaid;

  Future<ResponseGetContractorPayments?> fetchContractorPaymentslist() async {
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
      "wo_order_id": widget.woOrderId!,
    };

    if (kDebugMode) {
      print(data);
    }
    var response =
        await apiNetworkHandler.post(AppUrl.webgetcontractorpayement, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getContractorPaymentsFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          flagcalled = true;
          paymentDetails = dataModel.response?.paymentDetails!;

          if (paymentDetails!.isEmpty) {
            norecord = true;
          } else {
            norecord = false;
          }

          totalPaid = dataModel.response?.totalPaid!;
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
    fetchContractorPaymentslist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          title: Text('${widget.projectName!.toUpperCase()} - PAYMENTS',
              style: const TextStyle(
                  fontStyle: FontStyle.normal,
                  fontSize: 17.0,
                  color: Colors.white)),
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
                  ? norecord == true
                      ? const Center(
                          child: Text('No Record Found', style: normalText))
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: paymentDetails!.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 50,
                                              right: 10,
                                              top: 10,
                                              bottom: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 200,
                                                      child: Text(
                                                          'Transaction No.',
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
                                                        paymentDetails![index]
                                                            .transactionNo!,
                                                        style: normalText),
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
                                                      child: Text('Paid On',
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
                                                        paymentDetails![index]
                                                            .paymentDate!,
                                                        style: normalText),
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
                                                      child: Text('Amount Paid',
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
                                                        currencyFormat.format(
                                                            double.parse(
                                                                paymentDetails![
                                                                        index]
                                                                    .paymentAmount!)),
                                                        style: boldText),
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
                                                        paymentDetails![index]
                                                            .paymentMode!,
                                                        style: normalText),
                                                  ],
                                                ),
                                              ),
                                            ],
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
                                    ],
                                  );
                                },
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
                              height: 75,
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    horizontalSpaceSmall,
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text('Total Paid : ',
                                                style: boldText),
                                            verticalSpaceSmall,
                                            Text(
                                                currencyFormat.format(
                                                    double.parse(totalPaid!)),
                                                style: boldText)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                  : const Center(child: CircularProgressIndicator())),
        ));
  }
}
