import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/GetBrokerList.dart';
import 'package:stallion/models/message_success.dart';
// import 'package:stallion/models/get_broker_list.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/app_url.dart';

class PaymentCp extends StatefulWidget {
  const PaymentCp({
    super.key,
    this.projectName,
    this.projectId,
    this.towarId,
    this.towarName,
    this.brokerName,
    this.flatBuyerId,
    this.brokerId,
  });
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? brokerName;
  final String? flatBuyerId;
  final String? brokerId;
  @override
  State<PaymentCp> createState() => _PaymentCpState();
}

class _PaymentCpState extends State<PaymentCp> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  // List<BrokerList>? brokerList = [];
  List<BrokerPayment>? brokerPayment = [];

  // get all broker list
  Future<dynamic?> getAllBrokerPayment() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId!,
      "broker_id": '',
      "flat_buyer_id": "",
    };
    var response =
        await apiNetworkHandler.post(AppUrl.wsgetbrokerpayment, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getBrokerListFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          brokerPayment = dataModel.response?.brokerPayment;
        });
      }
    }
    return null;
  }

  Future<dynamic?> submitApprovePayment({
    required String paymentStatus,
    required String brokerPaymentId,
  }) async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
      "user_id": userId ?? '',
      // "flat_buyer_id": widget.flatBuyerID ?? '',
      "broker_payment_id": brokerPaymentId,
      "payment_status": paymentStatus,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.brokerpaymentacceptdate, data);
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
                      : paymentStatus == '2'
                          ? const Text('Payment has been declined.',
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
                        getAllBrokerPayment();
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

  initState() {
    super.initState();
    getAllBrokerPayment();
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
          SizedBox(
            height: 40,
            child: Center(
              child: Text(widget.brokerName ?? '',
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
          Expanded(
            child: brokerPayment!.length == 0
                ? Center(
                    child: Text(
                      'No Payment Request Found',
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : ListView.separated(
                    itemCount: brokerPayment!.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          if (brokerPayment![index].flatBrokerPaymentStatus !=
                              '1') {
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) => Dialog(
                                      elevation: 0,
                                      child: SizedBox(
                                        height: 280,
                                        width: 390.0,
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0, bottom: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const SizedBox(width: 30.0),
                                                  const Text(
                                                    'Approve Payment',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    icon: const Icon(
                                                        Icons.cancel_rounded),
                                                    color: Colors.black,
                                                  )
                                                ],
                                              ),
                                            ),
                                            Divider(
                                              color: Colors.grey.shade500,
                                              thickness: 1.5,
                                            ),
                                            SizedBox(
                                              height: 169,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                            'You are paying ${currencyFormat.format(double.parse(brokerPayment?[index].paymentAmount ?? '0'))} to ${widget.brokerName} \n \n (This cannot be undone)',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .black)),
                                                      ),
                                                    ],
                                                  ),
                                                  // const Text('(This cannot be undone)')
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
                                                      submitApprovePayment(
                                                          paymentStatus: '2',
                                                          brokerPaymentId:
                                                              brokerPayment![
                                                                      index]
                                                                  .brokerPaymentId!);
                                                      // penaltyDetails![index]
                                                      //     .penaltyGenerateId!);
                                                    },
                                                    child: Container(
                                                      height: double.infinity,
                                                      width: 194,
                                                      color:
                                                          Colors.red.shade700,
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 10.0),
                                                        child: Text(
                                                          'DECLINE',
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
                                                  InkWell(
                                                    onTap: () {
                                                      // submitApprovePayment(
                                                      //     penaltyStatus: '1',
                                                      //     penaltyGenerateId:
                                                      //         penaltyDetails![index]
                                                      //             .penaltyGenerateId!);
                                                      submitApprovePayment(
                                                          paymentStatus: '1',
                                                          brokerPaymentId:
                                                              brokerPayment![
                                                                      index]
                                                                  .brokerPaymentId!);
                                                    },
                                                    child: Container(
                                                      width: 194,
                                                      height: double.infinity,
                                                      color:
                                                          Colors.green.shade600,
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 10.0),
                                                        child: Text(
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
                          }
                        },
                        child: Column(
                          children: [
                            _rowTwoText(
                              context: context,
                              title: "Invoice No",
                              titleValue:
                                  brokerPayment?[index].invoiceNo ?? '---',
                            ),
                            _rowTwoText(
                              context: context,
                              title: " Amount",
                              titleValue: currencyFormat.format(double.parse(
                                  brokerPayment?[index].paymentAmount ?? '0')),

                              // brokerPayment?[index].paymentAmount ?? '---',
                            ),
                            _rowTwoText(
                              context: context,
                              title: "Paymnet Mode",
                              titleValue:
                                  brokerPayment?[index].paymentMode ?? '---',
                            ),
                            _rowTwoText(
                              context: context,
                              title: "Requested On",
                              titleValue: DateFormat("dd MMM yyyy").format(
                                  brokerPayment?[index].createdAt ??
                                      DateTime.now()),
                            ),
                            _rowTwoText(
                              context: context,
                              title: "Approved By",
                              titleValue:
                                  brokerPayment?[index].approvedByName ?? '---',
                              status: brokerPayment?[index]
                                      .flatBrokerPaymentStatus ??
                                  '',
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                  ),
          )
        ],
      ),
    );
  }

  Widget _rowTwoText({
    BuildContext? context,
    String? title,
    String? titleValue,
    // FlatBuyerRequest? brokerData,
    String? subTitle = '',
    String? status = '',
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 22),
      width: MediaQuery.of(context!).size.width - 120,
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: subTitle!.isEmpty
                ? Text(
                    title ?? '',
                    style: const TextStyle(fontSize: 16),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                      AppText(
                        title: subTitle,
                        fontSize: 14,
                        titleColor: Colors.grey,
                      ),
                    ],
                  ),
          ),
          horizontalSpaceMedium,
          const Center(child: Icon(Icons.remove, color: Colors.black54)),
          horizontalSpaceLarge,
          Text(
            titleValue ?? '',
            style: const TextStyle(fontSize: 16),
          ),
          Spacer(),
          if (status != "")
            Text(
              status == "0"
                  ? "Pending"
                  : status == "1"
                      ? "Approved"
                      : "Rejected",
              style: TextStyle(
                  fontSize: 16,
                  color: status == "0"
                      ? Colors.orange
                      : status == "1"
                          ? Colors.green
                          : Colors.red),
            ),
        ],
      ),
    );
  }
}
