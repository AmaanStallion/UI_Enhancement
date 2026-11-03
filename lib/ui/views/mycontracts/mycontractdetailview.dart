import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/ui/views/mycontracts/contractamtpaidview.dart';
import 'package:stallion/ui/views/mycontracts/workorderquantification.dart';
import '../../../models/get_work_order_details.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import '../rccstructure/pdfviewer.dart';
import 'imagepreviewview.dart';
import 'package:lottie/lottie.dart';

// class MyContractsDetailView extends StatefulWidget {
//   MyContractsDetailView(
//       {Key? key,
//       this.projectId,
//       this.towarId,
//       this.projectName,
//       this.companyId,
//       this.gradeId,
//       this.workorderId,
//       this.workId,
//       this.contractorName});

//   final String? projectId;
//   final String? towarId;
//   final String? projectName;
//   final String? companyId;
//   final String? gradeId;
//   final String? workorderId;
//   final String? workId;
//   final String? contractorName;

//   @override
//   State<MyContractsDetailView> createState() => _MyContractsDetailViewState();
// }
class MyContractsDetailView extends StatefulWidget {
  const MyContractsDetailView({super.key});

  @override
  State<MyContractsDetailView> createState() => _MyContractsDetailViewState();
}

class _MyContractsDetailViewState extends State<MyContractsDetailView> {
  late NotificationArgs args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context)!.settings.arguments as NotificationArgs;
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  bool flagcalled = false;

  List<DiscountArr>? discountArr = [];
  HeaderPart? headerPart;
  List<ContractorDetail>? contractorDetails = [];
  TotalBar? totalBar;
  List<Map<String, List<ContractorDetail>?>>? listArrayMain = [];

  double? totalPercentage = 0.0;
  double? percentage = 0.0;
  double grossTotal = 0.0;
  double subTotal = 0.0;
  double gstAmount = 0.0;
  double? discountAmt = 0.0;
  double? costToComplete = 0.0;
  Future<ResponseGetWorkOrderDetails?> fetchProjectWorkOrderDetails() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId!,
      "wo_order_id": args.response?.woOrderId ?? '',
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.getprojectworkorderdetails, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getWorkOrderDetailsFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        contractorDetails = dataModel.response?.contractorDetails!;
        String? intKey = '';
        for (int i = 0; i < contractorDetails!.length; i++) {
          totalPercentage = totalPercentage! +
              double.parse(contractorDetails![i].percentage!);
          percentage = percentage! +
              double.parse(contractorDetails![i].percentageCompleted!);

          var key = contractorDetails![i].key;
          if (intKey == '') {
            intKey = key;
            List<ContractorDetail>? keylist = [];
            keylist.add(contractorDetails![i]);
            Map<String, List<ContractorDetail>?> dddata = {
              "contract": keylist,
            };
            listArrayMain!.add(dddata);
          } else if (intKey == key) {
            var index = listArrayMain!.length - 1;
            var arrData = listArrayMain![index]["contract"];
            arrData?.add(contractorDetails![i]);
            listArrayMain![index]["contract"] = arrData;
          } else {
            intKey = key;
            List<ContractorDetail>? keylist = [];
            keylist.add(contractorDetails![i]);
            Map<String, List<ContractorDetail>?> dddata = {
              "contract": keylist,
            };
            listArrayMain!.add(dddata);
          }
        }
        if (kDebugMode) {
          print('===listArrayMain===');
          print(listArrayMain);
        }

        discountArr = dataModel.response?.discountArr!;
        headerPart = dataModel.response?.headerPart!;
        totalBar = dataModel.response?.totalBar!;
        subTotal = double.parse(headerPart!.subTotal!);
        gstAmount = double.parse(headerPart!.gstAmount!);
        if (headerPart!.discountAmount!.isNotEmpty) {
          discountAmt = double.parse(headerPart!.discountAmount!);
        }
        grossTotal = (subTotal + gstAmount) - discountAmt!;
        costToComplete = double.parse(totalBar!.totalAmount!) -
            (double.parse(totalBar!.totalPaid!) + discountAmt!);
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
  }

  bool _visible = false;
  double? topHeight = 5;

  @override
  void initState() {
    super.initState();
    fetchProjectWorkOrderDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text('${args.projectName!.toUpperCase()}',
              // - ${args.contractorName?.toUpperCase()}',
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
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 5),
                          child: Center(
                              child: Text(args.response?.woOrderNo ?? '')),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.only(left: 25, right: 60.0),
                          child: SizedBox(
                            height: 85,
                            child: IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text('B.U.A',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black)),
                                        verticalSpaceSmall,
                                        Text(headerPart!.valueOne!)
                                      ],
                                    ),
                                  ),
                                  const VerticalDivider(
                                    width: 1,
                                    thickness: 1,
                                    indent: 10,
                                    endIndent: 10,
                                    color: Colors.black54,
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text('Rate',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black)),
                                        verticalSpaceSmall,
                                        Text(headerPart?.valueTwo?.trim() != ""
                                            ? currencyFormat.format(
                                                double.parse(
                                                    headerPart?.valueTwo ??
                                                        '0'))
                                            : "0")
                                      ],
                                    ),
                                  ),
                                  const VerticalDivider(
                                    width: 1,
                                    thickness: 1,
                                    indent: 10,
                                    endIndent: 10,
                                    color: Colors.black54,
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text('Total Value(100%)',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black)),
                                        verticalSpaceSmall,
                                        Text(currencyFormat.format(double.parse(
                                            headerPart!.valueTotal!))),
                                        verticalSpaceTiny,
                                        const Text('Tax Inc.')
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
                        verticalSpaceSmall,
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 25.0, right: 60.0),
                          child: IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Center(
                                    child: Text('CONTRACT',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            backgroundColor: Colors.white,
                                            fontSize: 15,
                                            color: Colors.black)),
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
                                  child: Column(
                                    children: [
                                      Text(
                                          headerPart!.woTypeOrder! == '0'
                                              ? 'CONTRACT %'
                                              : 'CONTRACT QTY',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              backgroundColor: Colors.white,
                                              fontSize: 15,
                                              color: Colors.black)),
                                      verticalSpaceSmall,
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            left: 80.0, right: 80.0),
                                        child: Divider(
                                          height: 1,
                                          thickness: 0.5,
                                          indent: 1,
                                          endIndent: 1,
                                          color: Colors.black,
                                        ),
                                      ),
                                      verticalSpaceSmall,
                                      const Text('CONTRACT COST',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              backgroundColor: Colors.white,
                                              fontSize: 15,
                                              color: Colors.black)),
                                    ],
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
                                  child: Column(
                                    children: [
                                      Text(
                                          headerPart!.woTypeOrder! == '0'
                                              ? 'COMPLETED %'
                                              : 'COMPLETED QTY',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              backgroundColor: Colors.white,
                                              fontSize: 15,
                                              color: Colors.black)),
                                      verticalSpaceSmall,
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            left: 80.0, right: 80.0),
                                        child: Divider(
                                          height: 1,
                                          thickness: 0.5,
                                          indent: 1,
                                          endIndent: 1,
                                          color: Colors.black,
                                        ),
                                      ),
                                      verticalSpaceSmall,
                                      const Text('COMPLETED COST',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              backgroundColor: Colors.white,
                                              fontSize: 15,
                                              color: Colors.black)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        verticalSpaceSmall,
                        const Divider(
                          height: 1,
                          thickness: 0.5,
                          indent: 1,
                          endIndent: 1,
                          color: Colors.black,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemBuilder: (BuildContext context, int index) =>
                                MyExpandableWidget(
                                    listArrayMain![index],
                                    args.projectName ?? '',
                                    args.projectId ?? '',
                                    args.response?.towarId ?? '',
                                    args.response?.woOrderNo ?? '',
                                    headerPart?.woTypeOrder ?? ''),
                            itemCount: listArrayMain?.length,
                          ),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 0.5,
                          indent: 1,
                          endIndent: 1,
                          color: Colors.black,
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _visible = !_visible;
                              topHeight = 30;
                            });
                          },
                          child: SizedBox(
                            height: _visible ? 275 : 85.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedOpacity(
                                  opacity: _visible ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 500),
                                  child: SizedBox(
                                    height: _visible ? 260.0 : 0.0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 40.0, right: 40.0, top: 5.0),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 30.0,
                                            child: Stack(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 20.0),
                                                  child: Center(
                                                    child: Text('VIEW LESS',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 10,
                                                            color:
                                                                Colors.black)),
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
                                              const Text('Sub Total',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                              horizontalSpaceMedium,
                                              Text(
                                                  currencyFormat.format(
                                                      double.parse(headerPart!
                                                          .subTotal!)),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            ],
                                          ),
                                          verticalSpaceSmall,
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text('Retention',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                              horizontalSpaceMedium,
                                              Text(
                                                  currencyFormat.format(
                                                      double.parse(headerPart!
                                                          .retentionAmount!)),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 15,
                                                      color: Colors.red)),
                                            ],
                                          ),
                                          verticalSpaceSmall,
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const Text('Debit',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 15,
                                                          color: Colors.black)),
                                                  horizontalSpaceMedium,
                                                  discountArr!.isNotEmpty
                                                      ? SizedBox(
                                                          width: 110,
                                                          height: 28,
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            height: 28,
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
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
                                                            child: InkWell(
                                                              onTap: () {
                                                                if (discountArr!
                                                                    .isNotEmpty) {
                                                                  var discount =
                                                                      0.0;
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          discountArr!
                                                                              .length;
                                                                      i++) {
                                                                    discount = discount +
                                                                        double.parse(
                                                                            discountArr![i].discountAmountt!);
                                                                  }
                                                                  showDialog(
                                                                      barrierDismissible:
                                                                          false,
                                                                      context:
                                                                          context,
                                                                      builder: (BuildContext
                                                                              context) =>
                                                                          Dialog(
                                                                            elevation:
                                                                                0,
                                                                            child:
                                                                                SizedBox(
                                                                              height: 450,
                                                                              width: 450,
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  verticalSpaceSmall,
                                                                                  const Padding(
                                                                                    padding: EdgeInsets.only(top: 5.0, bottom: 5),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          'Total Debit Value',
                                                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  Divider(
                                                                                    color: Colors.grey.shade500,
                                                                                    thickness: 1.5,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 310,
                                                                                    width: 430,
                                                                                    child: ListView.builder(
                                                                                        itemCount: discountArr!.length,
                                                                                        itemBuilder: (context, index) {
                                                                                          return Column(
                                                                                            children: [
                                                                                              Padding(
                                                                                                padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10, bottom: 10),
                                                                                                child: SizedBox(
                                                                                                  height: 30,
                                                                                                  child: Row(
                                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                    children: [
                                                                                                      Center(
                                                                                                          child: Text(
                                                                                                        discountArr![index].discountDescription!,
                                                                                                        style: normalText,
                                                                                                      )),
                                                                                                      horizontalSpaceSmall,
                                                                                                      SizedBox(
                                                                                                          width: 110,
                                                                                                          height: 33,
                                                                                                          child: Container(
                                                                                                            width: double.infinity,
                                                                                                            height: 33,
                                                                                                            alignment: Alignment.center,
                                                                                                            decoration: BoxDecoration(
                                                                                                              color: Colors.white,
                                                                                                              borderRadius: BorderRadius.circular(17),
                                                                                                              border: Border.all(
                                                                                                                color: Colors.black,
                                                                                                              ),
                                                                                                            ),
                                                                                                            child: InkWell(
                                                                                                              onTap: () {
                                                                                                                discountArr![index].discountImage.toString().split(".").last == 'pdf'
                                                                                                                    ? Navigator.push(
                                                                                                                        context,
                                                                                                                        MaterialPageRoute(
                                                                                                                          builder: (_) {
                                                                                                                            return PdfViewer(
                                                                                                                              fileName: discountArr![index].discountImage.toString(),
                                                                                                                              fileUrl: '${AppUrl.globalDebitDocumentUrl}${discountArr![index].discountImage.toString()}',
                                                                                                                            );
                                                                                                                          },
                                                                                                                        ),
                                                                                                                      )
                                                                                                                    : Navigator.push(
                                                                                                                        context,
                                                                                                                        MaterialPageRoute(
                                                                                                                          builder: (_) {
                                                                                                                            return ImagePreviewViewer(
                                                                                                                              fileName: discountArr![index].discountImage.toString(),
                                                                                                                              fileUrl: '${AppUrl.globalDebitDocumentUrl}${discountArr![index].discountImage.toString()}',
                                                                                                                            );
                                                                                                                          },
                                                                                                                        ),
                                                                                                                      );
                                                                                                              },
                                                                                                              child: const Text(
                                                                                                                'VIEW DOCUMENT',
                                                                                                                style: TextStyle(
                                                                                                                  color: Colors.black,
                                                                                                                  fontStyle: FontStyle.normal,
                                                                                                                  fontSize: 13.0,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          )),
                                                                                                      Center(
                                                                                                          child: Text(
                                                                                                        currencyFormat.format(double.parse(discountArr![index].discountAmountt!)),
                                                                                                        style: normalText,
                                                                                                      ))
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              Divider(
                                                                                                color: Colors.grey.shade500,
                                                                                                thickness: 0.5,
                                                                                              ),
                                                                                            ],
                                                                                          );
                                                                                        }),
                                                                                  ),
                                                                                  Divider(
                                                                                    color: Colors.grey.shade500,
                                                                                    thickness: 1.5,
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                                                                                    child: SizedBox(
                                                                                      height: 30,
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                          const Center(
                                                                                              child: Text(
                                                                                            'Total Debit',
                                                                                            style: normalText,
                                                                                          )),
                                                                                          Center(
                                                                                              child: Text(
                                                                                            currencyFormat.format(discount),
                                                                                            style: normalText,
                                                                                          ))
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: InkWell(
                                                                                      onTap: () {
                                                                                        Navigator.of(context).pop();
                                                                                      },
                                                                                      child: Container(
                                                                                        width: double.infinity,
                                                                                        color: Colors.black,
                                                                                        child: const Padding(
                                                                                          padding: EdgeInsets.only(top: 13.0),
                                                                                          child: Text(
                                                                                            'OK',
                                                                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                                                                            textAlign: TextAlign.center,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ));
                                                                }
                                                              },
                                                              child: const Text(
                                                                'VIEW DETAILS',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .normal,
                                                                  fontSize:
                                                                      12.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ))
                                                      : const SizedBox(),
                                                ],
                                              ),
                                              horizontalSpaceMedium,
                                              Text(
                                                  currencyFormat
                                                      .format(discountAmt),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 15,
                                                      color: Colors.red)),
                                            ],
                                          ),
                                          verticalSpaceSmall,
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  'GST (${headerPart!.gstPercentage}%)',
                                                  style: normalText),
                                              horizontalSpaceMedium,
                                              Text(
                                                  currencyFormat.format(
                                                      double.parse(headerPart!
                                                          .gstAmount!)),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            ],
                                          ),
                                          verticalSpaceSmall,
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  'TDS (${headerPart!.woTdsPercentage!}%)',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                              horizontalSpaceMedium,
                                              Text(
                                                  currencyFormat.format(
                                                      double.parse(
                                                          headerPart!.woTds!)),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            ],
                                          ),
                                          verticalSpaceSmall,
                                          const Divider(
                                            height: 1,
                                            thickness: 0.5,
                                            indent: 1,
                                            endIndent: 1,
                                            color: Colors.black,
                                          ),
                                          verticalSpaceSmall,
                                          SizedBox(
                                            height: 30.0,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text('Gross Total',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                                horizontalSpaceMedium,
                                                Text(
                                                    headerPart!.woTypeOrder! ==
                                                            '0'
                                                        ? '${percentage!.toStringAsFixed(2)}/${totalPercentage!.toStringAsFixed(2)}%'
                                                        : '${percentage!.toStringAsFixed(2)}/${totalPercentage!.toStringAsFixed(2)} Qty',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                                horizontalSpaceMedium,
                                                Text(
                                                    //"Rs.500",
                                                    currencyFormat
                                                        .format(grossTotal),
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                      Container(
                                        height: _visible ? 0.0 : 30.0,
                                        child: const Padding(
                                          padding: EdgeInsets.only(top: 20.0),
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
                                  height: _visible ? 0.0 : 30.0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 40.0, right: 40.0, top: 5.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Gross Total',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15,
                                                color: Colors.black)),
                                        horizontalSpaceMedium,
                                        Text(
                                            headerPart!.woTypeOrder! == '0'
                                                ? '${percentage!.toStringAsFixed(2)}/${totalPercentage!.toStringAsFixed(2)}%'
                                                : '${percentage!.toStringAsFixed(2)}/${totalPercentage!.toStringAsFixed(2)} Qty',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15,
                                                color: Colors.black)),
                                        horizontalSpaceMedium,
                                        Text(currencyFormat.format(grossTotal),
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
                                    child: Column(
                                      children: [
                                        const Text('Total',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black)),
                                        verticalSpaceSmall,
                                        Text(currencyFormat.format(double.parse(
                                            totalBar!.totalAmount!)))
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
                                        const Text('Work Done',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black)),
                                        verticalSpaceSmall,
                                        Text(currencyFormat.format(
                                            double.parse(totalBar!.workDone!)))
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
                                    child: InkWell(
                                      onTap: () {
                                        var projectId = args.projectId!;
                                        var projectName = args.projectName!;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) {
                                              return ContractAmtPaidView(
                                                projectId: projectId,
                                                towarId:
                                                    args.response?.towarId!,
                                                projectName: projectName,
                                                woOrderId:
                                                    args.response?.woOrderId!,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          const Text('Total Paid',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black)),
                                          verticalSpaceSmall,
                                          Text(currencyFormat.format(
                                              double.parse(
                                                  totalBar!.totalPaid!))),
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
                                        const Text('Amount Due',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black)),
                                        verticalSpaceSmall,
                                        Text(
                                            currencyFormat.format(double.parse(
                                                totalBar!.payables!)),
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.red)),
                                      ],
                                    ),
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
                        SizedBox(
                            height: 50,
                            child: Center(
                              child: Text(
                                  'Cost to Complete: ${currencyFormat.format(costToComplete!)}',
                                  style: const TextStyle(
                                      backgroundColor: Colors.white,
                                      fontSize: 15,
                                      color: Colors.black)),
                            )),
                      ],
                    )
                  : SizedBox(
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
            // const Center(child: CircularProgressIndicator())),
            ));
  }
}

class MyExpandableWidget extends StatelessWidget {
  Map<String, List<ContractorDetail>?>? details;

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? workId;
  final String? woTypeOrder;

  MyExpandableWidget(this.details, this.projectName, this.projectId,
      this.towarId, this.workId, this.woTypeOrder);

  @override
  Widget build(BuildContext context) {
    var isExpanded = false;
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    if (details!["contract"]!.isEmpty) {
      return const ListTile(title: Text('No Record'));
    }
    var percentage_completed =
        double.parse(details!["contract"]![0].percentageCompleted!);
    var percentage = double.parse(details!["contract"]![0].percentage!);
    //var calPercentage = (percentage_completed * percentage) / 100;
    var actualPer = (percentage_completed / percentage);
    double totPercentage = 0.0;
    double totCompPercentage = 0.0;
    double totAmount = 0.0;
    double totCompAmount = 0.0;
    double totCalPercentage = 0.0;
    double totactualPer = 0.0;
    if (details!["contract"]!.length > 1) {
      for (int i = 0; i < details!["contract"]!.length; i++) {
        totPercentage =
            totPercentage + double.parse(details!["contract"]![i].percentage!);
        totCompPercentage = totCompPercentage +
            double.parse(details!["contract"]![i].percentageCompleted!);
        totAmount = totAmount + double.parse(details!["contract"]![i].amount!);
        totCompAmount = totCompAmount +
            double.parse(details!["contract"]![i].amountCompleted!);
        totCalPercentage = totCalPercentage +
            ((double.parse(details!["contract"]![i].percentageCompleted!) *
                double.parse(details!["contract"]![i].percentage!) /
                100));
      }
      totactualPer = (totCalPercentage / totPercentage);
    }

    Widget iconCircle(String valu) {
      if (valu == "1") {
        return const Icon(
          Icons.circle_outlined,
          color: Colors.black,
        );
      } else if (valu == "2") {
        return const Icon(
          Icons.circle,
          color: Colors.red,
        );
      } else if (valu == "3") {
        return const Icon(
          Icons.check_circle,
          color: Colors.green,
        );
      } else {
        return const Icon(
          Icons.circle,
          color: Colors.transparent,
        );
      }
    }

    return Theme(
      data: theme,
      child: ExpansionTile(
        onExpansionChanged: (bool val) {
          if (details!["contract"]!.length == 1) {
            var projectId = this.projectId!;
            var projectName = this.projectName!;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) {
                  return WorkOrderQuantification(
                      projectId: projectId,
                      towarId: towarId,
                      projectName: projectName,
                      tranWorkId: details!["contract"]![0].transId!,
                      workId: workId,
                      details: details!["contract"]![0],
                      woTypeOrder: woTypeOrder!);
                },
              ),
            );
          } else {
            setState() {
              isExpanded = val;
            }
          }
        },
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalSpaceSmall,
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                          details!["contract"]!.length == 1
                              ? details!["contract"]![0].name!.capitalize()
                              : details!["contract"]![0].headerName!,
                          style: const TextStyle(
                              backgroundColor: Colors.white,
                              fontSize: 15,
                              color: Colors.black)),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 1,
                      indent: 10,
                      endIndent: 0,
                      color: Colors.black54,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                              details!["contract"]!.length == 1
                                  ? woTypeOrder! == '0'
                                      ? '${double.parse(details!["contract"]![0].percentage!).toStringAsFixed(2)}%'
                                      : '${double.parse(details!["contract"]![0].percentage!).toStringAsFixed(2)} ${details!["contract"]![0].woUnitName}'
                                  : woTypeOrder! == '0'
                                      ? '${totPercentage.toStringAsFixed(2)}%'
                                      : '${totPercentage.toStringAsFixed(2)} ${details!["contract"]![0].woUnitName}',
                              style: const TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                          verticalSpaceSmall,
                          const Padding(
                            padding: EdgeInsets.only(left: 80.0, right: 80.0),
                            child: Divider(
                              height: 1,
                              thickness: 0.5,
                              indent: 1,
                              endIndent: 1,
                              color: Colors.black,
                            ),
                          ),
                          verticalSpaceSmall,
                          Text(
                              details!["contract"]!.length == 1
                                  ? currencyFormat.format(double.parse(
                                      details!["contract"]![0].amount!))
                                  : currencyFormat.format(totAmount),
                              style: const TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ],
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
                      child: Column(
                        children: [
                          Text(
                              details!["contract"]!.length == 1
                                  ? woTypeOrder! == '0'
                                      ? '${percentage_completed.toStringAsFixed(2)}%'
                                      : '${percentage_completed.toStringAsFixed(2)} ${details!["contract"]![0].woUnitName}'
                                  : woTypeOrder! == '0'
                                      ? '${totCompPercentage.toStringAsFixed(2)}%'
                                      : '${totCompPercentage.toStringAsFixed(2)} ${details!["contract"]![0].woUnitName}',
                              style: const TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                          verticalSpaceSmall,
                          const Padding(
                            padding: EdgeInsets.only(left: 80.0, right: 80.0),
                            child: Divider(
                              height: 1,
                              thickness: 0.5,
                              indent: 1,
                              endIndent: 1,
                              color: Colors.black,
                            ),
                          ),
                          verticalSpaceSmall,
                          Text(
                              details!["contract"]!.length == 1
                                  ? currencyFormat.format(double.parse(
                                      details!["contract"]![0]
                                          .amountCompleted!))
                                  : currencyFormat.format(totCompAmount),
                              style: const TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ],
                      ),
                    ),
                    iconCircle(details!["contract"]![0].dueFlag ?? '0')
                    // Icon(
                    //   // Icons.circle_outlined,
                    //   // Icons.circle,
                    //   Icons.check_circle,
                    //   color: Colors.black,
                    // ),
                    // Text(details!["contract"]![0].dueFlag ?? ''),
                  ],
                ),
              ),
            ),
            verticalSpaceSmall,
            details!["contract"]!.length == 1
                ? Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 10, bottom: 10),
                    child: SizedBox(
                      height: 32,
                      width: 400,
                      child: RoundedProgressBar(
                          style: RoundedProgressBarStyle(
                              widthShadow: 0,
                              colorBorder: Colors.white,
                              backgroundProgress: Colors.grey,
                              colorProgress: Colors.black,
                              colorProgressDark: Colors.black),
                          height: 20,
                          percent: details!["contract"]!.length == 1
                              ? actualPer * 100
                              : totactualPer * 100),
                    ),
                  )
                : const SizedBox(height: 15),
            // details!["contract"]!.length == 1
            details!["contract"]![0].partialFlag == '1'
                ? actualPer > 0
                    ? const Text(
                        // '${actualPer}',
                        "(Partially Certified)",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    : SizedBox()
                : SizedBox(),
            const Divider(
              height: 1,
              thickness: 0.5,
              indent: 1,
              endIndent: 1,
              color: Colors.black,
            ),
          ],
        ),
        children: details!["contract"]!.length == 1
            ? []
            : details!["contract"]!
                .map<Widget>((club) => showClubs(club, context, projectId!,
                    towarId!, projectName!, workId, woTypeOrder))
                .toList(),
        trailing: const SizedBox(),
      ),
    );
  }
}

showClubs(ContractorDetail details, BuildContext context, String? projectId,
    String? towarId, String? projectName, String? workId, String? woTypeOrder) {
  final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);

  double percentage_completed = 0.0;
  double percentage = 0.0;
  double actualPer = 0.0;
  if (woTypeOrder == '0') {
    //Percentage
    percentage_completed = double.parse(details.percentageCompleted!);
    percentage = double.parse(details.percentage!);
    actualPer = (percentage_completed / percentage);
  } else {
    //Qty
    percentage_completed = double.parse(details.percentageCompleted!);
    percentage = double.parse(details.percentage!);
    actualPer = (percentage_completed / percentage);
  }

  return Theme(
    data: theme,
    child: ExpansionTile(
      trailing: const SizedBox(),
      key: PageStorageKey<ContractorDetail?>(details),
      title: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return WorkOrderQuantification(
                  projectId: projectId,
                  towarId: towarId,
                  projectName: projectName,
                  tranWorkId: details.transId!,
                  workId: workId,
                  details: details,
                  woTypeOrder: woTypeOrder!,
                );
              },
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalSpaceSmall,
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(details.name!,
                          style: const TextStyle(
                              backgroundColor: Colors.white,
                              fontSize: 15,
                              color: Colors.black)),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 1,
                      indent: 10,
                      endIndent: 0,
                      color: Colors.black54,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                              woTypeOrder! == '0'
                                  ? '${double.parse(details.percentage!).toStringAsFixed(2)}%'
                                  : '${double.parse(details.percentage!).toStringAsFixed(2)} ${details.woUnitName}',
                              style: const TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                          verticalSpaceSmall,
                          const Padding(
                            padding: EdgeInsets.only(left: 80.0, right: 80.0),
                            child: Divider(
                              height: 1,
                              thickness: 0.5,
                              indent: 1,
                              endIndent: 1,
                              color: Colors.black,
                            ),
                          ),
                          verticalSpaceSmall,
                          Text(
                              currencyFormat
                                  .format(double.parse(details.amount!)),
                              style: const TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ],
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
                      child: Column(
                        children: [
                          Text(
                              woTypeOrder == '0'
                                  ? '${percentage_completed.toStringAsFixed(2)}%'
                                  : '${percentage_completed.toStringAsFixed(2)} ${details.woUnitName}',
                              style: const TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                          verticalSpaceSmall,
                          const Padding(
                            padding: EdgeInsets.only(left: 80.0, right: 80.0),
                            child: Divider(
                              height: 1,
                              thickness: 0.5,
                              indent: 1,
                              endIndent: 1,
                              color: Colors.black,
                            ),
                          ),
                          verticalSpaceSmall,
                          Text(
                              currencyFormat.format(
                                  double.parse(details.amountCompleted!)),
                              style: const TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            verticalSpaceSmall,
            Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 10, bottom: 10),
              child: SizedBox(
                height: 32,
                width: 400,
                child: RoundedProgressBar(
                  style: RoundedProgressBarStyle(
                      widthShadow: 0,
                      colorBorder: Colors.white,
                      backgroundProgress: Colors.grey,
                      colorProgress: Colors.black,
                      colorProgressDark: Colors.black),
                  height: 20,
                  percent: actualPer * 100,
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
        ),
      ),
    ),
  );
}
