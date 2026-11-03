import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_broker_details.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/utils/remove_temp_file.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../models/get_sale_buyer_request.dart';
import '../../../models/get_template_flat_sell_after.dart';
import '../../../models/message_success.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';

class BookingPreview extends StatefulWidget {
  BookingPreview({
    Key? key,
    this.projectName,
    this.projectId,
    this.towarId,
    this.towarName,
    this.flatBuyerRequest,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  FlatBuyerRequest? flatBuyerRequest;

  @override
  State<BookingPreview> createState() => _BookingPreviewState();
}

class _BookingPreviewState extends State<BookingPreview> {
  bool isZoomed = false;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  TextEditingController remarkControler = TextEditingController();
  bool flagcalled = false;
  String? kLocalExamplePage = '';
  String? strStatusRejectApprove = '';
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  late PdfViewerController _pdfViewerController;
  String? filePath = '';
  String? fileName = '';
  String? parkingSoldMessage = '';
  Future<ResponseGetFlatTemplateAfter?> fetchBookingTemplate() async {
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
      "flat_buyer_id": widget.flatBuyerRequest!.flatBuyerId!,
      'fluter': "1",
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.wstemplateflatsellafter, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getFlatTemplateAfterFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          parkingSoldMessage = dataModel.response?.parkingSoldMessage;
          fileName = dataModel.response?.fileName;
          filePath =
              '${dataModel.response?.filePath}/${dataModel.response?.fileName}';

          kLocalExamplePage = dataModel.response?.afterTempSell!;
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

  Future<ResponseMessageSuccess?> fetchSetApproveReject() async {
    CustomLoading.progressDialog(isLoading: true, context: context);

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
      "flat_buyer_id": widget.flatBuyerRequest!.flatBuyerId!,
      "status": strStatusRejectApprove!,
      "flat_id_fk": widget.flatBuyerRequest!.flatIdFk!,
      "remark": remarkControler.text,
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(AppUrl.wsSetFlatStatus, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      CustomLoading.progressDialog(isLoading: false, context: context);

      final dataModel = getFlatTemplateAfterFromJson(response.body);
      remarkControler.clear();
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        context.loaderOverlay.hide();
        if (strStatusRejectApprove == '2') {
          Future.delayed(Duration.zero).then((_) {
            showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      title: const Text('Booking Status'),
                      content: const Text('Booking rejected successfully.',
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
                                  fontSize: 16.0,
                                  color: Colors.white)),
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.maybePop(context);
                            });
                          },
                        ),
                      ],
                    ));
          });
        } else {
          Future.delayed(Duration.zero).then((_) {
            showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      title: const Text('Booking Status'),
                      content: const Text('Booking approved successfully.',
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
                                  fontSize: 16.0,
                                  color: Colors.white)),
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.maybePop(context);
                            });
                          },
                        ),
                      ],
                    ));
          });
        }
      } else if (dataModel.response?.errorCode == "1") {
        // CustomLoading.progressDialog(isLoading: false, context: context);
        Future.delayed(Duration.zero).then((_) {
          showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: const Text('Booking Status'),
                    content: const Text("This flat is already booked.",
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
                                fontSize: 16.0,
                                color: Colors.white)),
                        onPressed: () {
                          // setState(() {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.maybePop(context);
                          // });
                        },
                      ),
                    ],
                  ));
        });

        if (kDebugMode) {
          print('Something went wrong');
        }
      }
    } else {
      CustomLoading.progressDialog(isLoading: false, context: context);

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
    fetchBookingTemplate();
    _pdfViewerController = PdfViewerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
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

          //no download
          actions: [
            IconButton(
              icon: const Icon(
                Icons.zoom_in,
                color: Colors.white,
                size: 35,
              ),
              onPressed: () {
                // _pdfViewerController.zoomLevel = 2;
                setState(() {
                  isZoomed = !isZoomed;
                });
              },
            ),
            const SizedBox(
              width: 30,
            ),
            IconButton(
              icon: const Icon(
                Icons.zoom_out,
                color: Colors.white,
                size: 35,
              ),
              onPressed: () {
                // _pdfViewerController.zoomLevel = 0;
                setState(() {
                  isZoomed = !isZoomed;
                });
              },
            ),
            const SizedBox(
              width: 50,
            )
          ],
        ),
        bottomNavigationBar: InkWell(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    strStatusRejectApprove = '2';
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                              title: const Text(''),
                              content: SizedBox(
                                height: 84,
                                child: Column(
                                  children: [
                                    const Text(
                                        'Are you sure you want to reject this booking?',
                                        style: TextStyle(
                                            fontStyle: FontStyle.normal,
                                            fontSize: 17.0)),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: remarkControler,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 13.0),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.all(12.0),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black)),
                                        hintText: 'Please Enter Remark',
                                        hintStyle: TextStyle(
                                          color: Color.fromARGB(
                                              255, 116, 116, 116),
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w200,
                                          fontFamily: 'HelveticaNeue',
                                        ),
                                        // suffixIcon: Icon(
                                        //   Icons.calendar_month_outlined,
                                        // ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      fixedSize: const Size.fromWidth(100),
                                      padding: const EdgeInsets.all(10),
                                      textStyle:
                                          const TextStyle(color: Colors.white)),
                                  child: const Text('NO',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14.0,
                                          color: Colors.white)),
                                  onPressed: () {
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
                                      textStyle:
                                          const TextStyle(color: Colors.white)),
                                  child: const Text('YES',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14.0,
                                          color: Colors.white)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    context.loaderOverlay.show();
                                    fetchSetApproveReject();
                                  },
                                ),
                              ],
                            ));
                  },
                  child: Container(
                      padding: const EdgeInsets.only(top: 13),
                      height: 50,
                      width: (MediaQuery.of(context).size.width / 2) - 1,
                      color: Colors.black,
                      child: const Text(
                        'REJECT BOOKING',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                ),
                InkWell(
                  onTap: () {
                    strStatusRejectApprove = '1';
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                              title: const Text(''),
                              actionsAlignment: MainAxisAlignment.center,
                              content: Text(
                                  '$parkingSoldMessage Are you sure you want to approve this booking?',
                                  style: const TextStyle(
                                      fontStyle: FontStyle.normal,
                                      fontSize: 17.0)),
                              actions: <Widget>[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      fixedSize: const Size.fromWidth(100),
                                      padding: const EdgeInsets.all(10),
                                      textStyle:
                                          const TextStyle(color: Colors.white)),
                                  child: const Text('NO',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14.0,
                                          color: Colors.white)),
                                  onPressed: () {
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
                                      textStyle:
                                          const TextStyle(color: Colors.white)),
                                  child: const Text('YES',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14.0,
                                          color: Colors.white)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    context.loaderOverlay.show();
                                    fetchSetApproveReject();
                                  },
                                ),
                              ],
                            ));
                  },
                  child: Container(
                      padding: const EdgeInsets.only(top: 13),
                      height: 50,
                      color: Colors.black,
                      width: (MediaQuery.of(context).size.width / 2) - 1,
                      child: const Text(
                        'APPROVE BOOKING',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                ),
              ],
            )),
        // body: SafeArea(
        //   child: flagcalled == true
        //       ? Column(
        //           children: [
        //             Padding(
        //               padding: const EdgeInsetsDirectional.fromSTEB(
        //                   5.0, 10.0, 5.0, 10.0),
        //               child: Text(
        //                 '${widget.flatBuyerRequest!.flatBuyerName!}, ${widget.flatBuyerRequest!.inventryFlatName!}',
        //                 style: boldText13,
        //               ),
        //             ),
        //             const Divider(
        //               height: 1.0,
        //               thickness: 0.5,
        //               indent: 1.0,
        //               endIndent: 1.0,
        //               color: Colors.black,
        //             ),
        //             Expanded(
        //                 child: Padding(
        //               padding: const EdgeInsets.all(10.0),
        //               child: SingleChildScrollView(
        //                   child: HtmlWidget(kLocalExamplePage!)),
        //             )),
        //           ],
        //         )
        //       : const Center(child: CircularProgressIndicator()),
// )
        backgroundColor: Colors.white70,
        body: filePath != ''
            ? Center(
                child: Container(
                  width: isZoomed ? 940 : 700,
                  child: SfPdfViewer.network(
                    // pageLayoutMode:
                    //     PdfPageLayoutMode.single, // Ensures proper layout

                    onDocumentLoaded: (details) {
                      if (fileName?.trim() != '') {
                        RemoveTempFile()
                            .removeRecentTempFile(fileName: fileName ?? '');
                      }
                    },
                    initialZoomLevel: 0.75,
                    enableDoubleTapZooming: true,
                    filePath ?? '',
                    // 'https://skrite.com/stallion-build-test//media/backend/images/temporary-docs/20240307025504.pdf',
                    key: _pdfViewerKey,
                    controller: _pdfViewerController,
                  ),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }
}
