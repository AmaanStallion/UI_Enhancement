import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/utils/remove_temp_file.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/workorderpreview.dart';
import '../../../../utils/api_network_call.dart';
import '../../../../utils/app_url.dart';
import '../../../widgets/simple_button.dart';
import '../../dashboard/dashboard_screen.dart'; 

class QuantityWoReviewView extends StatefulWidget {
  QuantityWoReviewView({
    super.key,
    this.projectId,
    this.towarId, 
    this.projectName,
    this.selectedConsultantType,
    this.selectedConsultantCompany,
    this.inputRequirementFor,
    this.selectedRequirementDate,
    this.inputNote,
    this.selectedGST,
    this.totalAmount,
    this.consultantMagicLink,
    this.contractorMagicLink,
    this.vendMagicLink,
    required this.arrayFiles,
    required this.arrayList,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  String? selectedConsultantType;
  String? selectedConsultantCompany;
  String? inputRequirementFor;
  String? selectedRequirementDate;
  String? inputNote;
  String? selectedGST;
  double? totalAmount = 0.0;
  var arrayFiles = [];
  var arrayList = [];
  final String? contractorMagicLink;
  final String? vendMagicLink;
  final String? consultantMagicLink;

  @override
  State<QuantityWoReviewView> createState() => _QuantityWoReviewViewState();
}

class _QuantityWoReviewViewState extends State<QuantityWoReviewView> {
  bool isZoomed = false;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  late PdfViewerController _pdfViewerController;

  String url = "";
  String? kLocalExamplePage = '';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  String? filePath = '';
  String? fileName = '';
  late BuildContext dialogContext;

  Future<ResponseWorkorderpreview?> wsworkorderpreview() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String dateStart = widget.selectedRequirementDate!;
    DateFormat inputFormat = DateFormat('dd MMM yyyy');
    DateTime input = inputFormat.parse(dateStart);
    String dateRequired = DateFormat('dd-MM-yyyy').format(input);

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {  
      "user_id": userId!,
      "grade_id": widget.selectedConsultantType!,
      "order_subject": widget.inputRequirementFor!,
      "gst_status": widget.selectedGST!,
      "company_id": widget.selectedConsultantCompany!,
      "remarks": widget.inputNote!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "value_total": '${widget.totalAmount!}',
      "estimation_date": dateRequired,
      "wo_arr_data": jsonEncode(widget.arrayList),
      'fluter': "1",
    };

    if (kDebugMode) {
      print(data);
    }
    var response =
        await apiNetworkHandler.post(AppUrl.setworkorderquantitypreview, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = workorderpreviewFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response!);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          fileName = dataModel.response?.fileName;
          filePath =
              '${dataModel.response?.filePath}/${dataModel.response?.fileName}';

          kLocalExamplePage = dataModel.response?.woPreView!;
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

  Future<dynamic> wsworkordersubmit() async {
    CustomLoading.progressDialog(isLoading: true, context: context);
    //for multipartrequest
    var request =
        http.MultipartRequest('POST', Uri.parse(AppUrl.setworkorderquantity));

    //for token
    request.headers.addAll({"Authorization": "Bearer token"});

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String dateStart = widget.selectedRequirementDate!;
    DateFormat inputFormat = DateFormat('dd MMM yyyy');
    DateTime input = inputFormat.parse(dateStart);
    String dateRequired = DateFormat('dd-MM-yyyy').format(input);

    //for image and videos and files
    request.fields['user_id'] = userId!;
    request.fields['grade_id'] = widget.selectedConsultantType!;
    request.fields['order_subject'] = widget.inputRequirementFor!;
    request.fields['gst_status'] = widget.selectedGST!;
    request.fields["company_id"] = widget.selectedConsultantCompany!;
    request.fields["remarks"] = widget.inputNote!;
    request.fields["project_id"] = widget.projectId!;
    request.fields["towar_id"] = widget.towarId!;
    request.fields["value_total"] = '${widget.totalAmount!}';
    request.fields["estimation_date"] = dateRequired;
    request.fields["wo_arr_data"] = jsonEncode(widget.arrayList);
    request.fields['draft_flag'] = '0';

    for (int i = 0; i < widget.arrayFiles.length; i++) {
      PlatformFile file = widget.arrayFiles[i];
      request.files.add(await http.MultipartFile.fromPath(
          "upload_note_image[]", file.path.toString()));
    }
    //for completeing the request
    var response = await request.send();

    //for getting and decoding the response into json format
    var responsed = await http.Response.fromStream(response);
    final responseData = json.decode(responsed.body);
    if (kDebugMode) {
      print(responseData);
    }
    if (response.statusCode == 200) {
      CustomLoading.progressDialog(isLoading: false, context: context);

      // Future.delayed(Duration(seconds: 10)).then((_) {
      //   Navigator.pop(dialogContext);

      // });
    } else {
      CustomLoading.progressDialog(isLoading: false, context: context);

      if (kDebugMode) {
        print("ERROR");
      }
    }
  }

  void RequestPurchaseOrderNavigate() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('flagRedirectToWorkProgress', 'true');
    backToScreen();
  }

  void backToScreen() {
    Navigator.maybePop(context);
  }

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    wsworkorderpreview();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.projectName!.toUpperCase(),
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        actions: <Widget>[
          // IconButton(
          //   icon: const Icon(Icons.download, color: Colors.white),
          //   onPressed: () {
          //     //shareFile(widget.fileName);
          //     //Save single pdf file
          //     _launchURL();
          //   },
          // ),
          // const SizedBox(
          //   width: 30,
          // ),
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
          const SizedBox(width: 50)
        ],
      ),
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
              // CircularProgressIndicator()
            ),
      backgroundColor: Colors.white70,
      bottomNavigationBar: InkWell(
        onTap: () {
          // showDialog<String>(
          //     context: context,
          //     builder: (BuildContext context) => AlertDialog(
          //           title: const Text(''),
          //           content: const Text(
          //               'Are you sure you want to request this work order?',
          //               style: TextStyle(
          //                   fontStyle: FontStyle.normal, fontSize: 17.0)),
          //           actions: <Widget>[
          //             ElevatedButton(
          //               style: ElevatedButton.styleFrom(
          //                   backgroundColor: Colors.black,
          //                   fixedSize: const Size.fromWidth(100),
          //                   padding: const EdgeInsets.all(10),
          //                   textStyle: const TextStyle(color: Colors.white)),
          //               child: const Text('NO',
          //                   style: TextStyle(
          //                       fontWeight: FontWeight.normal,
          //                       fontSize: 14.0,
          //                       color: Colors.white)),
          //               onPressed: () {
          //                 setState(() {
          //                   Navigator.pop(context);
          //                 });
          //               },
          //             ),
          //             ElevatedButton(
          //               style: ElevatedButton.styleFrom(
          //                   backgroundColor: Colors.black,
          //                   fixedSize: const Size.fromWidth(100),
          //                   padding: const EdgeInsets.all(10),
          //                   textStyle: const TextStyle(color: Colors.white)),
          //               child: const Text('YES',
          //                   style: TextStyle(
          //                       fontWeight: FontWeight.normal,
          //                       fontSize: 14.0,
          //                       color: Colors.white)),
          //               onPressed: () {
          //                 setState(() {
          //                   Navigator.pop(context);
          //                   showDialog(
          //                     context: context,
          //                     barrierDismissible: false,
          //                     builder: (BuildContext context) {
          //                       dialogContext = context;
          //                       return const Center(
          //                         child: SizedBox(
          //                           height: 200,
          //                           width: 200,
          //                           child: Dialog(
          //                             child: Column(
          //                               mainAxisAlignment:
          //                                   MainAxisAlignment.center,
          //                               children: [
          //                                 verticalSpaceSmall,
          //                                 CircularProgressIndicator(),
          //                                 verticalSpaceSmall,
          //                                 Text("Loading"),
          //                                 verticalSpaceSmall,
          //                               ],
          //                             ),
          //                           ),
          //                         ),
          //                       );
          //                     },
          //                   );
          //                   wsworkordersubmit();
          //                 });
          //               },
          //             ),
          //           ],
          //         ));
          Alert(
              closeIcon: const SizedBox(),
              padding: const EdgeInsets.only(top: 0.0, left: 24, right: 24),
              image: Image.asset('images/Icon-512.png',
                  height: 80, fit: BoxFit.fitWidth),
              style: const AlertStyle(
                  titleTextAlign: TextAlign.center,
                  descTextAlign: TextAlign.center,
                  descStyle:
                      TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                  isCloseButton: true),
              context: context,
              desc: 'Are you sure you want to request this work order?',
              alertAnimation: fadeAlertAnimation,
              buttons: [
                DialogButton(
                  onPressed: () => Navigator.pop(context),
                  color: Colors.black,
                  child: const Text(
                    "NO",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
                DialogButton(
                  onPressed: () {
                    Navigator.pop(context);
                    wsworkordersubmit().then((value) => {
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: const Text(''),
                                    content: const Text(
                                        'Request submitted successfully.',
                                        style: TextStyle(
                                            fontStyle: FontStyle.normal,
                                            fontSize: 17.0)),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            fixedSize:
                                                const Size.fromWidth(100),
                                            padding: const EdgeInsets.all(10),
                                            textStyle: const TextStyle(
                                                color: Colors.white)),
                                        child: const Text('CLOSE',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14.0,
                                                color: Colors.white)),
                                        onPressed: () {
                                          setState(() {
                                            Navigator.pop(context);
                                            RequestPurchaseOrderNavigate();
                                          });
                                        },
                                      ),
                                    ],
                                  ))
                        });

                    // .then(() {
                    //   showDialog<String>(
                    //       context: context,
                    //       builder: (BuildContext context) => AlertDialog(
                    //             title: const Text(''),
                    //             content: const Text(
                    //                 'Request submitted successfully.',
                    //                 style: TextStyle(
                    //                     fontStyle: FontStyle.normal,
                    //                     fontSize: 17.0)),
                    //             actions: <Widget>[
                    //               ElevatedButton(
                    //                 style: ElevatedButton.styleFrom(
                    //                     backgroundColor: Colors.black,
                    //                     fixedSize: const Size.fromWidth(100),
                    //                     padding: const EdgeInsets.all(10),
                    //                     textStyle: const TextStyle(
                    //                         color: Colors.white)),
                    //                 child: const Text('CLOSE',
                    //                     style: TextStyle(
                    //                         fontWeight: FontWeight.normal,
                    //                         fontSize: 14.0,
                    //                         color: Colors.white)),
                    //                 onPressed: () {
                    //                   setState(() {
                    //                     Navigator.pop(context);
                    //                     RequestPurchaseOrderNavigate();
                    //                   });
                    //                 },
                    //               ),
                    //             ],
                    //           ));
                    // });
                    // context.loaderOverlay.show();
                    // CustomLoading.progressDialog(
                    //     isLoading: true, context: context);
                    // submitPurchaseOrder(context);
                  },
                  color: Colors.black,
                  child: const Text(
                    "YES",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ]).show();
        },
        child: Container(
          height: 40,
          color: Colors.black,
          child: const Center(
            child: Text(
              "REQUEST WORK ORDER",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
