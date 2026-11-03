import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/acquisition_list.dart';
import 'package:stallion/models/get_acquisition_list.dart';
import 'package:stallion/models/message_success.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/views/vaults/vault_detail_list.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/app_url.dart';

class VaultsScreen extends StatefulWidget {
  const VaultsScreen({super.key});

  @override
  State<VaultsScreen> createState() => _VaultsScreenState();
}

class _VaultsScreenState extends State<VaultsScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<AcquisitionListElement>? acquisitionList = [];
  List<PlotPayemntList>? plotPayemntList = [];

  bool isMyProjects = true;
  bool isPendingHold = true;

  Future<dynamic?> getAcquisitionList() async {
    CustomLoading.progressDialog(isLoading: true, context: context);
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId ?? '',
    };
    var response =
        await apiNetworkHandler.post(AppUrl.webAcquisitionList, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = acquisitionListFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          acquisitionList = dataModel.response?.acquisitionList;
        });
      }
    }
    CustomLoading.progressDialog(isLoading: false, context: context);
    return null;
  }

  Future<dynamic?> getPlotPaymentList() async {
    CustomLoading.progressDialog(isLoading: true, context: context);
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId ?? '',
      'payment_type': isPendingHold == true ? '0' : '1',
    };
    var response =
        await apiNetworkHandler.post(AppUrl.webPlotPaymentList, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getAcquisitionListFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          plotPayemntList = dataModel.response?.plotPayemntList;
        });
      }
    }
    CustomLoading.progressDialog(isLoading: false, context: context);
    return null;
  }

  Future<dynamic?> submitApprovePayment({
    required String penaltyStatus,
    // required String penaltyGenerateId,
    required String paymentid,
    required String developerId,
  }) async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      // "project_id": widget.projectId ?? '',
      // "towar_id": widget.towarId ?? '',
      "user_id": userId ?? '',
      // "flat_buyer_id": widget.flatBuyerID ?? '',
      // "penalty_generate_id": penaltyGenerateId,
      "status": penaltyStatus,
      "payment_id": paymentid,
      "developer_id": developerId
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.plotPaymentChangeStatus, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = messageSuccessFromJson(response.body);

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
                        getPlotPaymentList();
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getAcquisitionList();
    });
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
        title: const Text('PROJECTS VAULT',
            style: TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      isMyProjects = true;
                    });
                    getAcquisitionList();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isMyProjects ? Colors.black : Colors.white,
                      border: Border.all(color: Colors.black),
                    ),
                    child: Text(
                      "MY PROJECTS",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isMyProjects ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      isMyProjects = false;
                    });
                    getPlotPaymentList();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isMyProjects ? Colors.white : Colors.black,
                      border: Border.all(color: Colors.black),
                    ),
                    child: Text(
                      "PAYMENTS",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isMyProjects ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          if (isMyProjects == false)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isPendingHold = true;
                      });
                      getPlotPaymentList();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isPendingHold ? Colors.black : Colors.white,
                        // border: Border.all(color: Colors.black),
                        border: Border(
                            left: BorderSide(color: Colors.black, width: 1),
                            bottom: BorderSide(color: Colors.black, width: 1)),
                      ),
                      child: Text(
                        "Pending/Hold",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isPendingHold ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isPendingHold = false;
                      });
                      getPlotPaymentList();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isPendingHold ? Colors.white : Colors.black,
                        border: Border.all(color: Colors.black),
                      ),
                      child: Text(
                        "Approved/Rejected",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isPendingHold ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          if (isMyProjects == true) ...[
            acquisitionList!.length == 0
                ? const Center(
                    child: Text(
                      'No Record Found',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        for (int i = 0; i < acquisitionList!.length; i++)
                          Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.black)),
                            ),
                            padding: const EdgeInsets.only(
                                top: 12, bottom: 2, left: 40, right: 40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            acquisitionList?[i].acquisition ??
                                                '',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            acquisitionList?[i].developerName ??
                                                '',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              // fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            acquisitionList?[i].address ?? '',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              // fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) {
                                              return VaultDetailList(
                                                acquisitionId:
                                                    acquisitionList?[i]
                                                            .acquisitionId ??
                                                        '',
                                                developerId: acquisitionList?[i]
                                                        .developerIdFk ??
                                                    '',
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black54),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          "View",
                                          style: TextStyle(
                                            fontSize: 16,
                                            // fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //   children: [
                                // Text(
                                //   "Acquistion 1",
                                //   style: TextStyle(
                                //     fontSize: 16,
                                //     fontWeight: FontWeight.w600,
                                //   ),
                                // ),
                                // Container(
                                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                                //   decoration: BoxDecoration(
                                //     border: Border.all(color: Colors.black54),
                                //     borderRadius: BorderRadius.circular(8),
                                //   ),
                                //   child: const Text(
                                //     "View",
                                //     style: TextStyle(
                                //       fontSize: 16,
                                //       // fontWeight: FontWeight.w600,
                                //     ),
                                //     textAlign: TextAlign.center,
                                //   ),
                                // ),
                                //   ],
                                // ),
                                // SizedBox(height: 6),
                                // Text(
                                //   "Vaibhav Developer LLP",
                                //   style: TextStyle(
                                //     fontSize: 16,
                                //     // fontWeight: FontWeight.w600,
                                //   ),
                                // ),
                                // SizedBox(height: 4),
                                // Text(
                                //   "Address",
                                //   style: TextStyle(
                                //     fontSize: 16,
                                //     // fontWeight: FontWeight.w600,
                                //   ),
                                // ),
                              ],
                            ),
                          )
                      ],
                    ),
                  ),
          ] else ...[
            Expanded(
              child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      // if (plotPayemntList?[index].plotPaymentStatus == '3' &&
                      //         plotPayemntList?[index].plotPaymentStatus == '1'
                      //     // penaltyDetails?[index].penaltyStatus != '3' &&
                      //     //   penaltyDetails?[index].penaltyStatus != '1'
                      //     ) {
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
                                                      'You are paying ${currencyFormat.format(
                                                        double.parse(
                                                            plotPayemntList?[
                                                                        index]
                                                                    .plotPaymentAmount ??
                                                                '0'),
                                                      )} for ${plotPayemntList?[index].plotPaymentTitle}',
                                                      // ${currencyFormat.format(double.parse('penaltyDetails![index].penaltyGrandTotAmt' ?? '0'))} against ${'penaltyDetails![index].flatPaymentTest'}
                                                      // ',
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
                                                  paymentid:
                                                      plotPayemntList?[index]
                                                              .id ??
                                                          '',
                                                  developerId:
                                                      plotPayemntList?[index]
                                                              .developerIdFk ??
                                                          '',
                                                  // penaltyGenerateId:
                                                  //     penaltyDetails![index]
                                                  //         .penaltyGenerateId!,
                                                );
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
                                                  paymentid:
                                                      plotPayemntList?[index]
                                                              .id ??
                                                          '',
                                                  developerId:
                                                      plotPayemntList?[index]
                                                              .developerIdFk ??
                                                          '',
                                                  // penaltyGenerateId:
                                                  //     penaltyDetails![index]
                                                  //         .penaltyGenerateId!
                                                );
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
                                                  paymentid:
                                                      plotPayemntList?[index]
                                                              .id ??
                                                          '',
                                                  developerId:
                                                      plotPayemntList?[index]
                                                              .developerIdFk ??
                                                          '',
                                                  // penaltyGenerateId:
                                                  //     penaltyDetails![index]
                                                  //         .penaltyGenerateId!
                                                );
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
                      // }
                    },
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _rowTwoText(
                            context: context,
                            title: 'Title ',
                            titleValue: plotPayemntList?[index].plotPaymentTitle
                            // penaltyDetails?[index].flatPaymentTest,
                            ),
                        // if (penaltyDetails?[index].penaltyWavierPerc != '')
                        _rowTwoText(
                          context: context,
                          title: 'Payment Request',
                          titleValue: currencyFormat.format(
                            double.parse(
                                plotPayemntList?[index].plotPaymentAmount ??
                                    '0'),
                          ),

                          // titleValue:
                          //     plotPayemntList?[index].plotPaymentAmount
                        ),
                        _rowTwoText(
                          context: context,
                          title: 'Requested On',
                          // titleValue:
                          titleValue: DateFormat('dd MMM yyyy').format(
                              plotPayemntList?[index].createdAt ??
                                  DateTime.now()),
                          isPending:
                              plotPayemntList?[index].plotPaymentStatus == '0'
                                  ? true
                                  : false,
                          isApproved:
                              plotPayemntList?[index].plotPaymentStatus == '1'
                                  ? true
                                  : false,
                          isHold:
                              plotPayemntList?[index].plotPaymentStatus == '2'
                                  ? true
                                  : false,
                          isReject:
                              plotPayemntList?[index].plotPaymentStatus == '3'
                                  ? true
                                  : false,
                        ),
                        _rowTwoText(
                          context: context,
                          title: 'Dated On',
                          // titleValue:
                          titleValue: DateFormat('dd MMM yyyy').format(
                              plotPayemntList?[index].plotPaymentDate ??
                                  DateTime.now()),

                          isDocument: true,
                          demandNote:
                              plotPayemntList?[index].plotPaymentDocument,
                        ),
                        _rowTwoText(
                            context: context,
                            title: 'Remark',
                            titleValue:
                                plotPayemntList?[index].plotPaymentRemark),
                        // _rowTwoText(
                        //   context: context,
                        //   title: 'Amount Due',
                        //   titleValue: currencyFormat.format(
                        //     double.parse(
                        //         penaltyDetails?[index].penaltyGrandTotAmt ??
                        //             '0'),
                        //   ),
                        //   isPending: penaltyDetails?[index].penaltyStatus == '0'
                        //       ? true
                        //       : false,
                        //   isApproved:
                        //       penaltyDetails?[index].penaltyStatus == '1'
                        //           ? true
                        //           : false,
                        //   isHold: penaltyDetails?[index].penaltyStatus == '2'
                        //       ? true
                        //       : false,
                        //   isReject: penaltyDetails?[index].penaltyStatus == '3'
                        //       ? true
                        //       : false,
                        // ),
                        // _rowTwoText(
                        //   context: context,
                        //   title: 'Date',
                        //   titleValue: DateFormat('dd MMM yyyy').format(
                        //       penaltyDetails?[index].createdAt ??
                        //           DateTime.now()),
                        //   isDocument: true,
                        //   demandNote: penaltyDetails?[index].demandNoteName,
                        // ),
                        // _rowTwoText(
                        //     context: context,
                        //     title: 'Remark',
                        //     titleValue: penaltyDetails?[index].penaltyRemark),
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
                itemCount: plotPayemntList!.length,
              ),
            )
          ],
        ],
      ),
    );
  }
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
    padding: const EdgeInsets.only(top: 10, left: 22, right: 22),
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
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) {
              //       return PdfViewer(
              //         fileName: demandNote,
              //         fileUrl:
              //             '${AppUrl.regenerateplotPaymentDetailsPath}$demandNote',
              //       );
              //     },
              //   ),
              // );

              demandNote.toString().split(".").last == 'pdf'
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          return PdfViewer(
                            fileName: demandNote,
                            fileUrl:
                                '${AppUrl.regenerateplotPaymentDetailsPath}$demandNote',
                            // '${AppUrl.globalPoinvoicePath}${arrUploadImg.toString()}',
                          );
                        },
                      ),
                    )
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          return ImagePreviewViewer(
                            fileName: demandNote,
                            // poWoPayment![index].documentImg,
                            fileUrl:
                                '${AppUrl.regenerateplotPaymentDetailsPath}$demandNote',
                            // '${AppUrl.globalPoinvoicePath}${arrUploadImg.toString()}',
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
                title: 'View Docs',
                lineHeight: 1,
                fontSize: 16,
              ),
            ),
          )
      ],
    ),
  );
}
