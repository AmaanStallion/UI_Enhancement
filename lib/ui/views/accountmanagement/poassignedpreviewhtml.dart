import 'package:stallion/ui/views/accountmanagement/account_management_preview.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_document.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_network.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_po_details_by_status.dart';
import 'package:stallion/models/wo_order_amend_pdf.dart';
import 'package:stallion/utils/remove_temp_file.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../utils/api_network_call.dart';
import '../../../../utils/app_url.dart';
import '../../../models/get_po_preview_html.dart';
import '../../../models/message_success.dart';
import '../../shared/ui_helpers.dart';
import '../../widgets/simple_button.dart';

class PoAssignedPreviewHtml extends StatefulWidget {
  const PoAssignedPreviewHtml(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.poOrderId,
      this.poOrderNo,
      this.flagRedirect,
      this.arrPoDoc});

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? poOrderId;
  final String? poOrderNo;
  final String? flagRedirect;
  final ArrPoDoc? arrPoDoc;

  @override
  State<PoAssignedPreviewHtml> createState() => _PoAssignedPreviewHtmlState();
}

class _PoAssignedPreviewHtmlState extends State<PoAssignedPreviewHtml> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  late PdfViewerController _pdfViewerController;
  final GlobalKey<FormState> _keyFormPOPup = GlobalKey<FormState>();
  RegExp regExp = RegExp(r'PO/(\d+)');

  bool isZoomed = false;
  String? kLocalExamplePage = '';
  bool flagcalled = false;
  String? strSignUploadMessage = '';
  String? strBudgetNotSetMessage = '';
  String? strBudgetOverMessage = '';
  String? strPoPdfPath = '';
  String? strPoPdfFileName = '';
  TextEditingController remarkControler = TextEditingController();
  String? filePath = '';
  String? fileName = '';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = AccountManagementPreviewNetwork();
  late ScrollController _scrollController;
  Timer? _timer;
  final double _scrollSpeed = 8.0; // Adjust scroll speed as needed

  late BuildContext dialogContext;
  String? authorizeFlag = '0';
  List<PriceStructure>? priceStructure = [];

  Future<ResponseGetPoPreviewHtml?> wsPurchaseOrderPreviewHtml() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    String? userType = (prefs.getString('userType') ??
        (useAccountManagementTestData ? '1' : null));

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }
    Map<String, String> data = {
      "user_id": userId!,
      "user_type": userType!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "order_id": widget.poOrderId!,
      "fluter": "1",
    };

    if (kDebugMode) {
      print(data);
    }
    var response =
        await apiNetworkHandler.post(AppUrl.wspostructurebyorder, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getPoPreviewHtmlFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response!);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          authorizeFlag = dataModel.response?.authorizeFlag;
          priceStructure = dataModel.response?.priceStructure;

          if (widget.arrPoDoc != null) {
            if (widget.arrPoDoc?.fileName != '' &&
                widget.arrPoDoc?.isPdf == "1") {
              filePath = widget.arrPoDoc!.filePath;
            } else {
              filePath = '${dataModel.response?.filePath}';

              // '${dataModel.response?.filePath}/${dataModel.response?.fileName}';
            }
          } else {
            print('ArrPoDoc is null');
          }

          flagcalled = true;
          kLocalExamplePage = dataModel.response?.poStructure?.content!;

          strPoPdfPath = dataModel.response?.po_pdf!;
          strPoPdfFileName = dataModel.response?.po_file_name!;

          if (dataModel.response?.signatureUpload! != null) {
            strSignUploadMessage = dataModel.response?.signatureUpload!;
          }

          if (dataModel.response?.budgetNotSetMsg! != null) {
            strBudgetNotSetMessage = dataModel.response?.budgetNotSetMsg!;
          }

          if (dataModel.response?.budgetOverBuget! != null) {
            strBudgetOverMessage = dataModel.response?.budgetOverBuget!;
          }
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

  // Future<ResponseGetPoPreviewHtml?> woOrderAmendPdf() async {
  //   final SharedPreferences prefs = await _prefs;

  //   Map<String, String> data = {
  //     "order_id": widget.poOrderId ?? '',
  //   };

  //   if (kDebugMode) {
  //     print(data);
  //   }
  //   var response = await apiNetworkHandler.post(AppUrl.poOrderAmendPdf, data);
  //   if (kDebugMode) {
  //     print(response.statusCode);
  //   }
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     final dataModel = woOrderAmendPdfFromJson(response.body);
  //     if (kDebugMode) {
  //       print(dataModel.response?.filePath);
  //     }
  //     if (dataModel.response?.errorCode == "0") {
  //       setState(() {
  //         filePath = dataModel.response?.filePath;
  //         //     fileName = dataModel.response?.filePath?.split('/').last;
  //       });
  //     }
  //   } else {
  //     if (kDebugMode) {
  //       print(response.body);
  //     }
  //     return null;
  //   }
  //   return null;
  // }

  late String _projId;
  late String _projName;

  Future<ResponseMessageSuccess?> wsPurchaseOrderSignDigitally() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "order_id": widget.poOrderId!,
      "po_status": '2',
      "order_status": '',
      "remark": '',
      "project_id": widget.projectId!,
      "towar_id": towerId,
    };

    if (kDebugMode) {
      print(data);
    }
    var response = await apiNetworkHandler.post(AppUrl.webChangePoStatus, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = messageSuccessFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response!);
      }
      if (dataModel.response?.errorCode == "0") {
        Future.delayed(Duration.zero).then((_) {
          Navigator.pop(dialogContext);
          Navigator.maybePop(context, true);
          showDialog<String>(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: const Text(''),
                    content: const Text(
                        'Purchase order status changed successfully.',
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
                          setState(() {
                            Navigator.pop(context);
                            Navigator.maybePop(context, true);
                          });
                        },
                      ),
                    ],
                  ));
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

  Future<ResponseMessageSuccess?> wsPurchaseOrderReject() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "order_id": widget.poOrderId!,
      "po_status": '3',
      "order_status": '',
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "flagoverbudget": "0",
      "remark": remarkControler.text,
    };

    if (kDebugMode) {
      print(data);
    }
    var response = await apiNetworkHandler.post(AppUrl.webChangePoStatus, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = messageSuccessFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response!);
      }
      if (dataModel.response?.errorCode == "0") {
        Future.delayed(Duration.zero).then((_) {
          Navigator.pop(dialogContext);
          Navigator.maybePop(context, true);
          showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: const Text(''),
                    content: const Text(
                        'Purchase order status changed successfully.',
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
                          setState(() {
                            Navigator.pop(context);
                            Navigator.maybePop(context, true);
                          });
                        },
                      ),
                    ],
                  ));
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
    wsPurchaseOrderPreviewHtml();
    _pdfViewerController = PdfViewerController();
    _scrollController = ScrollController();
    // _startAutoScroll();

    _projId = widget.projectId!;
    _projName = widget.projectName!;
    // setState(() {

    // });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      double newScrollOffset = _scrollController.offset + _scrollSpeed;
      if (newScrollOffset >= _scrollController.position.maxScrollExtent) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      } else {
        _scrollController.animateTo(newScrollOffset,
            duration: const Duration(milliseconds: 50), curve: Curves.linear);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
            '${widget.projectName!.toUpperCase()} - ${widget.poOrderNo!}',
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        actions: <Widget>[
          widget.flagRedirect == 'Issued'
              ? IconButton(
                  icon: const Icon(Icons.download, color: Colors.white),
                  onPressed: () {
                    //shareFile(widget.fileName);
                    //Save single pdf file
                    _launchURL();
                  },
                )
              : const SizedBox(),
          const SizedBox(width: 20),
          IconButton(
            icon: const Icon(
              Icons.zoom_in,
              color: Colors.white,
              size: 35,
            ),
            onPressed: () {
              setState(() {
                isZoomed = !isZoomed;
              });
              // _pdfViewerController.zoomLevel = 2;
            },
          ),
          const SizedBox(width: 30),
          IconButton(
            icon: const Icon(
              Icons.zoom_out,
              color: Colors.white,
              size: 35,
            ),
            onPressed: () {
              setState(() {
                isZoomed = !isZoomed;
              });
              // _pdfViewerController.zoomLevel = 0;
            },
          ),
          const SizedBox(
            width: 50,
          )
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (priceStructure!.length != 0 &&
                widget.flagRedirect == 'Assigned')
              const Text(
                "Price Changed(%)",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   child: Row(
            //     children: [
            //       for (int i = 0; i < priceStructure!.length; i++)
            //         Container(
            //           padding:
            //               EdgeInsets.symmetric(horizontal: 90, vertical: 7),
            //           decoration: BoxDecoration(
            //             border: Border(
            //               right: BorderSide(color: Colors.white),
            //             ),
            //           ),
            //           child: Text(
            //             '${priceStructure?[i].transGradeTypeName}  : ${priceStructure?[i].unitPriceDifference}%',
            //             style: TextStyle(
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.w400,
            //                 color: Colors.white),
            //           ),
            //         ),
            //     ],
            //   ),
            // ),
            if (priceStructure!.length != 0 &&
                widget.flagRedirect == 'Assigned')
              SizedBox(
                height: 30,
                child: priceStructure!.length != 0
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          final itemIndex = index % priceStructure!.length;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 90),
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Colors.white),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                    '${priceStructure![itemIndex].transGradeTypeName} : ${priceStructure![itemIndex].unitPricePercentage}%',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white)),
                                double.parse(priceStructure![itemIndex]
                                                .unitPriceDifference ??
                                            '0') >
                                        0
                                    ? const Icon(
                                        Icons.arrow_upward_outlined,
                                        color: Colors.red,
                                      )
                                    : const Icon(
                                        Icons.arrow_downward_outlined,
                                        color: Colors.green,
                                      ),
                                Text(
                                    'Avg: Rs ${priceStructure![itemIndex].averagePrice}, ',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white)),
                                // Text('${priceStructure![itemIndex].poNo}',
                                //     style: const TextStyle(
                                //         fontSize: 16,
                                //         fontWeight: FontWeight.w400,
                                //         color: Colors.white)),
                                Text(
                                  (() {
                                    final poNo =
                                        priceStructure![itemIndex].poNo ?? '';
                                    final match =
                                        RegExp(r'PO/(\d+)').firstMatch(poNo);
                                    return match != null
                                        ? '(PO-${match.group(1)})'
                                        : '';
                                  })(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                    : const SizedBox(),
              ),
            authorizeFlag == '0'
                ? const SizedBox()
                : Container(
                    // padding: const EdgeInsets.only(bottom: 10),
                    decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.white60))),
                    height: widget.flagRedirect == 'Assigned' ? 54 : 0,
                    child: widget.flagRedirect == 'Assigned'
                        ? Padding(
                            padding:
                                const EdgeInsets.only(left: 30.0, right: 30.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                horizontalSpaceSmall,
                                Flexible(
                                  child: SimpleButton(
                                    lblText: 'REJECT PURCHASE ORDER',
                                    color: kcPrimaryColor,
                                    onTap: () {
                                      showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                                title: const Text(''),
                                                // content: const Text(
                                                //     'Are you sure you want to reject this purchase order?',
                                                //     style: TextStyle(
                                                //         fontStyle: FontStyle
                                                //             .normal,
                                                //         fontSize: 17.0)),
                                                content: Form(
                                                  key: _keyFormPOPup,
                                                  child: SizedBox(
                                                    height: 106,
                                                    child: Column(
                                                      children: [
                                                        const Text(
                                                            'Are you sure you want to reject this purchase order?',
                                                            style: TextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                fontSize:
                                                                    17.0)),
                                                        const SizedBox(
                                                            height: 8),
                                                        TextFormField(
                                                          controller:
                                                              remarkControler,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      13.0),
                                                          decoration:
                                                              const InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    12.0),
                                                            border: OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .black)),
                                                            hintText:
                                                                'Please Enter Remark',
                                                            hintStyle:
                                                                TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      116,
                                                                      116,
                                                                      116),
                                                              fontSize: 13.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w200,
                                                              fontFamily:
                                                                  'HelveticaNeue',
                                                            ),
                                                            // suffixIcon: Icon(
                                                            //   Icons.calendar_month_outlined,
                                                            // ),
                                                          ),
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return "(Remark Cannot Be Empty)";
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                Colors.black,
                                                            fixedSize: const Size
                                                                .fromWidth(100),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            textStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                    child: const Text('NO',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize: 14.0,
                                                            color:
                                                                Colors.white)),
                                                    onPressed: () {
                                                      setState(() {
                                                        Navigator.pop(context);
                                                      });
                                                    },
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                Colors.black,
                                                            fixedSize: const Size
                                                                .fromWidth(100),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            textStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                    child: const Text('YES',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize: 14.0,
                                                            color:
                                                                Colors.white)),
                                                    onPressed: () {
                                                      if (_keyFormPOPup
                                                          .currentState!
                                                          .validate()) {
                                                        Navigator.pop(context);
                                                        showDialog(
                                                          context: context,
                                                          barrierDismissible:
                                                              false,
                                                          builder: (BuildContext
                                                              context) {
                                                            dialogContext =
                                                                context;
                                                            return const Center(
                                                              child: SizedBox(
                                                                height: 200,
                                                                width: 200,
                                                                child: Dialog(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      verticalSpaceSmall,
                                                                      CircularProgressIndicator(),
                                                                      verticalSpaceSmall,
                                                                      Text(
                                                                          "Loading"),
                                                                      verticalSpaceSmall,
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                        wsPurchaseOrderReject();
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ));
                                    },
                                  ),
                                ),
                                horizontalSpaceSmall,
                                Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                  ),
                                ),
                                Flexible(
                                  child: SimpleButton(
                                    lblText: 'SIGN PURCHASE ORDER DIGITALLY',
                                    color: kcPrimaryColor,
                                    onTap: () {
                                      if (strBudgetOverMessage != "" ||
                                          strBudgetNotSetMessage != "") {
                                        if (strBudgetOverMessage != "" &&
                                            strBudgetNotSetMessage != "") {
                                          showDialog<String>(
                                              context: context,
                                              builder:
                                                  (BuildContext context) =>
                                                      AlertDialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  8), // Set radius to zero
                                                        ),
                                                        titlePadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 0),
                                                        actionsPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 0),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 16),
                                                        actionsAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        title: Container(
                                                          height: 80,
                                                          // color: Colors.amber,
                                                          child: Image.asset(
                                                              'images/Icon-512.png',
                                                              // height: 80,
                                                              fit: BoxFit
                                                                  .contain),
                                                        ),
                                                        content: Container(
                                                          height: 150,
                                                          width: 400,
                                                          child: Center(
                                                            child: Text(
                                                                '$strBudgetNotSetMessage \n $strBudgetOverMessage',
                                                                style: const TextStyle(
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .normal,
                                                                    fontSize:
                                                                        17.0)),
                                                          ),
                                                        ),
                                                        actions: <Widget>[
                                                          Row(
                                                            children: [
                                                              InkWell(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: 225,
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          8),
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    color: Colors
                                                                        .black,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      // bottomRight: Radius.circular(8),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              8),
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      const Text(
                                                                    'Close',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 1),
                                                              InkWell(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  showDialog<
                                                                          String>(
                                                                      context:
                                                                          context,
                                                                      builder: (BuildContext
                                                                              context) =>
                                                                          AlertDialog(
                                                                            title:
                                                                                const Text(''),
                                                                            content:
                                                                                const Text('Are you sure you want to Sign Digitally?', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
                                                                            actions: <Widget>[
                                                                              ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, fixedSize: const Size.fromWidth(100), padding: const EdgeInsets.all(10), textStyle: const TextStyle(color: Colors.white)),
                                                                                child: const Text('NO', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14.0, color: Colors.white)),
                                                                                onPressed: () {
                                                                                  setState(() {
                                                                                    Navigator.pop(context);
                                                                                  });
                                                                                },
                                                                              ),
                                                                              ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, fixedSize: const Size.fromWidth(100), padding: const EdgeInsets.all(10), textStyle: const TextStyle(color: Colors.white)),
                                                                                child: const Text('YES', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14.0, color: Colors.white)),
                                                                                onPressed: () {
                                                                                  Navigator.pop(context);
                                                                                  showDialog(
                                                                                    context: context,
                                                                                    barrierDismissible: false,
                                                                                    builder: (BuildContext context) {
                                                                                      dialogContext = context;
                                                                                      return const Center(
                                                                                        child: SizedBox(
                                                                                          height: 200,
                                                                                          width: 200,
                                                                                          child: Dialog(
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
                                                                                  wsPurchaseOrderSignDigitally();
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ));
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: 225,
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          8),
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    color: Colors
                                                                        .black,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              8),
                                                                      // bottomLeft: Radius.circular(8),
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      const Text(
                                                                    'PROCEED',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ));
                                        } else if (strBudgetOverMessage != "") {
                                          showDialog<String>(
                                              context: context,
                                              builder:
                                                  (BuildContext context) =>
                                                      AlertDialog(
                                                        title: const Text(''),
                                                        content: Text(
                                                            '$strBudgetOverMessage',
                                                            style: const TextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                fontSize:
                                                                    17.0)),
                                                        actions: <Widget>[
                                                          ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .black,
                                                                fixedSize:
                                                                    const Size
                                                                        .fromWidth(
                                                                        100),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                textStyle: const TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                            child: const Text(
                                                                'CLOSE',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    fontSize:
                                                                        14.0,
                                                                    color: Colors
                                                                        .white)),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          ),
                                                          ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .black,
                                                                fixedSize:
                                                                    const Size
                                                                        .fromWidth(
                                                                        100),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                textStyle: const TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                            child: const Text(
                                                                'PROCEED',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    fontSize:
                                                                        14.0,
                                                                    color: Colors
                                                                        .white)),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                              showDialog<
                                                                      String>(
                                                                  context:
                                                                      context,
                                                                  builder: (BuildContext
                                                                          context) =>
                                                                      AlertDialog(
                                                                        title: const Text(
                                                                            ''),
                                                                        content: const Text(
                                                                            'Are you sure you want to Sign Digitally?',
                                                                            style:
                                                                                TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
                                                                        actions: <Widget>[
                                                                          ElevatedButton(
                                                                            style: ElevatedButton.styleFrom(
                                                                                backgroundColor: Colors.black,
                                                                                fixedSize: const Size.fromWidth(100),
                                                                                padding: const EdgeInsets.all(10),
                                                                                textStyle: const TextStyle(color: Colors.white)),
                                                                            child:
                                                                                const Text('NO', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14.0, color: Colors.white)),
                                                                            onPressed:
                                                                                () {
                                                                              setState(() {
                                                                                Navigator.pop(context);
                                                                              });
                                                                            },
                                                                          ),
                                                                          ElevatedButton(
                                                                            style: ElevatedButton.styleFrom(
                                                                                backgroundColor: Colors.black,
                                                                                fixedSize: const Size.fromWidth(100),
                                                                                padding: const EdgeInsets.all(10),
                                                                                textStyle: const TextStyle(color: Colors.white)),
                                                                            child:
                                                                                const Text('YES', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14.0, color: Colors.white)),
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                              showDialog(
                                                                                context: context,
                                                                                barrierDismissible: false,
                                                                                builder: (BuildContext context) {
                                                                                  dialogContext = context;
                                                                                  return const Center(
                                                                                    child: SizedBox(
                                                                                      height: 200,
                                                                                      width: 200,
                                                                                      child: Dialog(
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
                                                                              wsPurchaseOrderSignDigitally();
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ));
                                                            },
                                                          ),
                                                        ],
                                                      ));
                                        } else if (strBudgetNotSetMessage !=
                                            "") {
                                          showDialog<String>(
                                              context: context,
                                              builder:
                                                  (BuildContext context) =>
                                                      AlertDialog(
                                                        title: const Text(''),
                                                        content: Text(
                                                            '$strBudgetNotSetMessage',
                                                            style: const TextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                fontFamily:
                                                                    'RobotoMono',
                                                                fontSize:
                                                                    17.0)),
                                                        actions: <Widget>[
                                                          ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .black,
                                                                fixedSize:
                                                                    const Size
                                                                        .fromWidth(
                                                                        100),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                textStyle: const TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                            child: const Text(
                                                                'CLOSE',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    fontSize:
                                                                        14.0,
                                                                    color: Colors
                                                                        .white)),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          ),
                                                          ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .black,
                                                                fixedSize:
                                                                    const Size
                                                                        .fromWidth(
                                                                        100),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                textStyle: const TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                            child: const Text(
                                                                'PROCEED',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    fontSize:
                                                                        14.0,
                                                                    color: Colors
                                                                        .white)),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                              showDialog<
                                                                      String>(
                                                                  context:
                                                                      context,
                                                                  builder: (BuildContext
                                                                          context) =>
                                                                      AlertDialog(
                                                                        title: const Text(
                                                                            ''),
                                                                        content: const Text(
                                                                            'Are you sure you want to Sign Digitally?',
                                                                            style: TextStyle(
                                                                                fontStyle: FontStyle.normal,
                                                                                fontFamily: 'RobotoMono',
                                                                                fontSize: 17.0)),
                                                                        actions: <Widget>[
                                                                          ElevatedButton(
                                                                            style: ElevatedButton.styleFrom(
                                                                                backgroundColor: Colors.black,
                                                                                fixedSize: const Size.fromWidth(100),
                                                                                padding: const EdgeInsets.all(10),
                                                                                textStyle: const TextStyle(color: Colors.white)),
                                                                            child:
                                                                                const Text('NO', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14.0, color: Colors.white)),
                                                                            onPressed:
                                                                                () {
                                                                              setState(() {
                                                                                Navigator.pop(context);
                                                                              });
                                                                            },
                                                                          ),
                                                                          ElevatedButton(
                                                                            style: ElevatedButton.styleFrom(
                                                                                backgroundColor: Colors.black,
                                                                                fixedSize: const Size.fromWidth(100),
                                                                                padding: const EdgeInsets.all(10),
                                                                                textStyle: const TextStyle(color: Colors.white)),
                                                                            child:
                                                                                const Text('YES', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14.0, color: Colors.white)),
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                              showDialog(
                                                                                context: context,
                                                                                barrierDismissible: false,
                                                                                builder: (BuildContext context) {
                                                                                  dialogContext = context;
                                                                                  return const Center(
                                                                                    child: SizedBox(
                                                                                      height: 200,
                                                                                      width: 200,
                                                                                      child: Dialog(
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
                                                                              wsPurchaseOrderSignDigitally();
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ));
                                                            },
                                                          ),
                                                        ],
                                                      ));
                                        }
                                      } else {
                                        if (strSignUploadMessage == "1") {
                                          showDialog<String>(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  AlertDialog(
                                                    title: const Text(''),
                                                    content: const Text(
                                                        'Are you sure you want to Sign Digitally?',
                                                        style: TextStyle(
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            fontFamily:
                                                                'RobotoMono',
                                                            fontSize: 17.0)),
                                                    actions: <Widget>[
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.black,
                                                            fixedSize: const Size
                                                                .fromWidth(100),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            textStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                        child: const Text('NO',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 14.0,
                                                                color: Colors
                                                                    .white)),
                                                        onPressed: () {
                                                          setState(() {
                                                            Navigator.pop(
                                                                context);
                                                          });
                                                        },
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.black,
                                                            fixedSize: const Size
                                                                .fromWidth(100),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            textStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                        child: const Text('YES',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 14.0,
                                                                color: Colors
                                                                    .white)),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          showDialog(
                                                            context: context,
                                                            barrierDismissible:
                                                                false,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              dialogContext =
                                                                  context;
                                                              return const Center(
                                                                child: SizedBox(
                                                                  height: 200,
                                                                  width: 200,
                                                                  child: Dialog(
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        verticalSpaceSmall,
                                                                        CircularProgressIndicator(),
                                                                        verticalSpaceSmall,
                                                                        Text(
                                                                            "Loading"),
                                                                        verticalSpaceSmall,
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                          wsPurchaseOrderSignDigitally();
                                                        },
                                                      ),
                                                    ],
                                                  ));
                                        } else {
                                          showDialog<String>(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  AlertDialog(
                                                    title: const Text(''),
                                                    content: const Text(
                                                        'Kindly upload digital signature on backend.',
                                                        style: TextStyle(
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            fontFamily:
                                                                'RobotoMono',
                                                            fontSize: 17.0)),
                                                    actions: <Widget>[
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.black,
                                                            fixedSize: const Size
                                                                .fromWidth(100),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            textStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                        child: const Text(
                                                            'CLOSE',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 14.0,
                                                                color: Colors
                                                                    .white)),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ],
                                                  ));
                                        }
                                      }
                                    },
                                  ),
                                ),
                                horizontalSpaceSmall,
                              ],
                            ),
                          )
                        : verticalSpaceSmall,
                  ),
          ],
        ),
      ),
      body: filePath != ''
          ? Center(
              child: Container(
                width: isZoomed ? 940 : 700,
                child: (useAccountManagementTestData
                    ? const AccountManagementPreviewDocument()
                    : SfPdfViewer.network(
                        // onDocumentLoaded: (details) {
                        //   if (fileName?.trim() != '') {
                        //     RemoveTempFile()
                        //         .removeRecentTempFile(fileName: fileName ?? '');
                        //   }
                        // },
                        // initialZoomLevel: 1,
                        enableDoubleTapZooming: true,
                        filePath ?? '',
                        key: _pdfViewerKey,
                        controller: _pdfViewerController,
                        // pageLayoutMode: PdfPageLayoutMode.continuous,
                        initialZoomLevel: 0.75, // Or lower

                        // pageLayoutMode: PdfPageLayoutMode.single, // Ensures proper layout
                      )),
              ),
            )
          : const Center(child: CircularProgressIndicator()),

      //  Container(
      //   color: Colors.white,
      //   child: flagcalled == true
      //       ? Expanded(
      //           child: Container(
      //             color: Colors.white,
      //             child: Padding(
      //               padding: const EdgeInsets.all(20.0),
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.center,
      //                 children: [
      //                   HtmlWidget(kLocalExamplePage!),
      //                 ],
      //               ),
      //             ),
      //           ),
      //         )
      //       : const Center(child: CircularProgressIndicator()),
      // )
    );
  }

  _launchURL() async {
    if (useAccountManagementTestData) return;
    if (strPoPdfPath != "") {
      print(strPoPdfPath);
      final uri = Uri.parse(strPoPdfPath!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch';
      }
    }
  }
}
