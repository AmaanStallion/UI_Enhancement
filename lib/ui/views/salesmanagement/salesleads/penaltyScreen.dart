import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_buyer_penalty_list.dart';
import 'package:stallion/models/message_success.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/app_url.dart';

class PenaltyScreen extends StatefulWidget {
  const PenaltyScreen({
    super.key,
    this.projectName,
    this.projectId,
    this.towarId,
    this.towarName,
    this.flatBuyerID,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? flatBuyerID;

  @override
  State<PenaltyScreen> createState() => _PenaltyScreenState();
}

class _PenaltyScreenState extends State<PenaltyScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<PenaltyDetail>? penaltyDetails = [];

  Future<List<PenaltyDetail>?> getBuyerPenaltyList() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
      "user_id": userId ?? '',
      "flat_buyer_id": widget.flatBuyerID ?? '',
    };
    var response =
        await apiNetworkHandler.post(AppUrl.wsGetBuyerPenaltyList, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getBuyerPenaltyListFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          penaltyDetails = dataModel.response?.penaltyDetails;
        });
      }
    }

    return null;
  }

  Future<dynamic?> submitApprovePayment({
    required String penaltyStatus,
    required String penaltyGenerateId,
  }) async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
      "user_id": userId ?? '',
      "flat_buyer_id": widget.flatBuyerID ?? '',
      "penalty_generate_id": penaltyGenerateId,
      "penalty_status": penaltyStatus,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.webBuyerPenaltyUpdate, data);
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
                  content: penaltyStatus == '1'
                      ? const Text('Payment approved successfully.',
                          style: TextStyle(
                              fontStyle: FontStyle.normal, fontSize: 17.0))
                      : penaltyStatus == '2'
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
                        getBuyerPenaltyList();
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
    getBuyerPenaltyList();
    // TODO: implement initState
    super.initState();
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
          const SizedBox(
            height: 40,
            child: Center(
              child: Text("PENALTY",
                  style: TextStyle(
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
            child: ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    if (penaltyDetails?[index].penaltyStatus != '3' &&
                        penaltyDetails?[index].penaltyStatus != '1') {
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
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const SizedBox(width: 30.0),
                                            const Text(
                                              'Approve Payment',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
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
                                                  MainAxisAlignment.center,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                      'You are paying penality ${currencyFormat.format(double.parse(penaltyDetails![index].penaltyGrandTotAmt ?? '0'))} against ${penaltyDetails![index].flatPaymentTest}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      // poWoPayment![index]
                                                      //             .amountRequest! !=
                                                      //         ""
                                                      //     ? 'You are paying ${currencyFormat.format(double.parse(poWoPayment![index].amountRequest!))} to ${poWoPayment![index].venderName!}'
                                                      //     : 'You are paying \u{20B9} 0 to ${poWoPayment![index].venderName!}',
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black)),
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
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                // Navigator.pop(context);
                                                // paymentStatus = "2";
                                                // paymentVenderId =
                                                //     poWoPayment![index]
                                                //         .paymentVenderId!;
                                                // showDialog(
                                                //   context: context,
                                                //   barrierDismissible: false,
                                                //   builder:
                                                //       (BuildContext context) {
                                                //     dialogContext = context;
                                                //     return const Center(
                                                //       child: SizedBox(
                                                //         height: 200,
                                                //         width: 200,
                                                //         child: Dialog(
                                                //           child: Column(
                                                //             mainAxisAlignment:
                                                //                 MainAxisAlignment
                                                //                     .center,
                                                //             children: [
                                                //               verticalSpaceSmall,
                                                //               CircularProgressIndicator(),
                                                //               verticalSpaceSmall,
                                                //               Text("Loading"),
                                                //               verticalSpaceSmall,
                                                //             ],
                                                //           ),
                                                //         ),
                                                //       ),
                                                //     );
                                                //   },
                                                // );

                                                submitApprovePayment(
                                                    penaltyStatus: '3',
                                                    penaltyGenerateId:
                                                        penaltyDetails![index]
                                                            .penaltyGenerateId!);
                                              },
                                              child: Container(
                                                height: double.infinity,
                                                width: 130,
                                                color: Colors.red.shade700,
                                                child: const Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10.0),
                                                  child: Text(
                                                    'DECLINE',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                // Navigator.pop(context);
                                                // paymentStatus = "3";
                                                // paymentVenderId =
                                                //     poWoPayment![index]
                                                //         .paymentVenderId!;
                                                // showDialog(
                                                //   context: context,
                                                //   barrierDismissible: false,
                                                //   builder:
                                                //       (BuildContext context) {
                                                //     dialogContext = context;
                                                //     return const Center(
                                                //       child: SizedBox(
                                                //         height: 200,
                                                //         width: 200,
                                                //         child: Dialog(
                                                //           child: Column(
                                                //             mainAxisAlignment:
                                                //                 MainAxisAlignment
                                                //                     .center,
                                                //             children: [
                                                //               verticalSpaceSmall,
                                                //               CircularProgressIndicator(),
                                                //               verticalSpaceSmall,
                                                //               Text("Loading"),
                                                //               verticalSpaceSmall,
                                                //             ],
                                                //           ),
                                                //         ),
                                                //       ),
                                                //     );
                                                //   },
                                                // );

                                                submitApprovePayment(
                                                    penaltyStatus: '2',
                                                    penaltyGenerateId:
                                                        penaltyDetails![index]
                                                            .penaltyGenerateId!);
                                              },
                                              child: Container(
                                                height: double.infinity,
                                                width: 130,
                                                color: Colors.yellow.shade700,
                                                child: const Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10.0),
                                                  child: Text(
                                                    'HOLD',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                //   Navigator.pop(context);
                                                //   paymentStatus = "1";
                                                //   paymentVenderId =
                                                //       poWoPayment![index]
                                                //           .paymentVenderId!;
                                                //   showDialog(
                                                //     context: context,
                                                //     barrierDismissible: false,
                                                //     builder:
                                                //         (BuildContext context) {
                                                //       dialogContext = context;
                                                //       return const Center(
                                                //         child: SizedBox(
                                                //           height: 200,
                                                //           width: 200,
                                                //           child: Dialog(
                                                //             child: Column(
                                                //               mainAxisAlignment:
                                                //                   MainAxisAlignment
                                                //                       .center,
                                                //               children: [
                                                //                 verticalSpaceSmall,
                                                //                 CircularProgressIndicator(),
                                                //                 verticalSpaceSmall,
                                                //                 Text("Loading"),
                                                //                 verticalSpaceSmall,
                                                //               ],
                                                //             ),
                                                //           ),
                                                //         ),
                                                //       );
                                                //     },
                                                //   );

                                                submitApprovePayment(
                                                    penaltyStatus: '1',
                                                    penaltyGenerateId:
                                                        penaltyDetails![index]
                                                            .penaltyGenerateId!);
                                              },
                                              child: Container(
                                                width: 130,
                                                height: double.infinity,
                                                color: Colors.green.shade600,
                                                child: const Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10.0),
                                                  child: Text(
                                                    'APPROVE',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15),
                                                    textAlign: TextAlign.center,
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
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _rowTwoText(
                          context: context,
                          title: 'Title ',
                          titleValue: penaltyDetails?[index].flatPaymentTest),
                      if (penaltyDetails?[index].penaltyWavierPerc != '')
                        _rowTwoText(
                            context: context,
                            title: 'Waved Off',
                            titleValue:
                                '${penaltyDetails?[index].penaltyWavierPerc}%'),
                      _rowTwoText(
                        context: context,
                        title: 'Amount Due',
                        titleValue: currencyFormat.format(
                          double.parse(
                              penaltyDetails?[index].penaltyGrandTotAmt ?? '0'),
                        ),
                        isPending: penaltyDetails?[index].penaltyStatus == '0'
                            ? true
                            : false,
                        isApproved: penaltyDetails?[index].penaltyStatus == '1'
                            ? true
                            : false,
                        isHold: penaltyDetails?[index].penaltyStatus == '2'
                            ? true
                            : false,
                        isReject: penaltyDetails?[index].penaltyStatus == '3'
                            ? true
                            : false,
                      ),
                      _rowTwoText(
                        context: context,
                        title: 'Date',
                        titleValue: DateFormat('dd MMM yyyy').format(
                            penaltyDetails?[index].createdAt ?? DateTime.now()),
                        isDocument: true,
                        demandNote: penaltyDetails?[index].demandNoteName,
                      ),
                      _rowTwoText(
                          context: context,
                          title: 'Remark',
                          titleValue: penaltyDetails?[index].penaltyRemark),
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  height: 1.0,
                  color: Colors.black,
                );
              },
              itemCount: penaltyDetails!.length,
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
    String? demandNote,
    // FlatBuyerRequest? brokerData,
    String? subTitle = '',
    String? flatBuyerId = '',
    String? flatFundingType = '',
    isDocument = false,
    isPending = false,
    isApproved = false,
    isHold = false,
    isReject = false,
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
          const Spacer(),
          if (isPending)
            const Text(
              'Pending',
              style: TextStyle(fontSize: 16, color: Colors.orange),
            ),
          if (isApproved)
            const Text(
              'Approved',
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
          if (isHold)
            const Text(
              'Hold',
              style: TextStyle(fontSize: 16, color: Colors.orange),
            ),
          if (isReject)
            const Text(
              'Rejected',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          if (demandNote != null && demandNote.isNotEmpty && isDocument)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return PdfViewer(
                        fileName: demandNote,
                        fileUrl:
                            '${AppUrl.regenerateDemandNotePath}$demandNote',
                      );
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(6)),
                child: const AppText(
                  title: 'View PDF',
                  lineHeight: 1,
                  fontSize: 16,
                ),
              ),
            )
        ],
      ),
    );
  }
}
