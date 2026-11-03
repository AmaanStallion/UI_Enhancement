import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/dashboard/dashboard_screen.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/remove_temp_file.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../models/workorderpreview.dart';
import '../../../../utils/app_url.dart';
import '../../../shared/ui_helpers.dart';
import '../../../widgets/simple_button.dart';

class WorkOrderPercentagePreview extends StatefulWidget {
  WorkOrderPercentagePreview(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.selectedConsultantType,
      this.selectedConsultantCompany,
      this.inputRequirementFor,
      this.selectedRequirementDate,
      this.inputBu,
      this.inputRate,
      this.inputNote,
      this.selectedGST,
      required this.arrayFiles,
      this.totalPercentage,
      this.totalAmount,
      required this.arrayList});

  final String? projectId;
  final String? towarId;
  final String? projectName;
  String? selectedConsultantType;
  String? selectedConsultantCompany;
  String? inputRequirementFor;
  String? selectedRequirementDate;
  String? inputBu;
  String? inputRate;
  String? inputNote;
  String? selectedGST;
  var arrayFiles = [];
  double? totalPercentage = 0.0;
  double? totalAmount = 0.0;
  var arrayList = [];

  @override
  State<WorkOrderPercentagePreview> createState() =>
      _WorkOrderPercentagePreviewState();
}

class _WorkOrderPercentagePreviewState
    extends State<WorkOrderPercentagePreview> {
  bool isZoomed = false;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  late PdfViewerController _pdfViewerController;

  String? kLocalExamplePage = '';
  late String _projId;
  late String _projName;

  late BuildContext dialogContext;
  String? filePath = '';
  String? fileName = '';
  Future<ResponseWorkorderpreview?> wsworkorderpreview() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String dateStart = '${widget.selectedRequirementDate!}';
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
      "value_one": widget.inputBu!,
      "value_two": widget.inputRate!,
      "wo_arr_data": '${jsonEncode(widget.arrayList)}',
      'fluter': "1",
    };

    if (kDebugMode) {
      print(data);
    }
    var response =
        await apiNetworkHandler.post(AppUrl.getWsworkorderpreview, data);
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

  wsworkordersubmit() async {
    CustomLoading.progressDialog(isLoading: true, context: context);
    //for multipartrequest
    var request =
        http.MultipartRequest('POST', Uri.parse(AppUrl.setworkorderpercentage));

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
    request.fields["towar_id"] = widget.towarId!;
    request.fields["project_id"] = widget.projectId!;
    request.fields["value_total"] = '${widget.totalAmount!}';
    request.fields["estimation_date"] = dateRequired;
    request.fields["value_one"] = widget.inputBu!;
    request.fields["value_two"] = widget.inputRate!;
    request.fields["wo_arr_data"] = jsonEncode(widget.arrayList);
    request.fields['temporary_file_name'] = fileName ?? '';
    request.fields['draft_flag'] = '0';

    for (int i = 0; i < widget.arrayFiles.length!; i++) {
      PlatformFile file = widget.arrayFiles[i];
      print("FILE UPLOAD");
      print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.extension);
      print(file.path);
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
      Future.delayed(Duration.zero).then((_) {
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
            desc: 'Request submitted successfully',
            alertAnimation: fadeAlertAnimation,
            buttons: [
              // DialogButton(
              //   onPressed: () => Navigator.pop(context),
              //   color: Colors.black,
              //   child: const Text(
              //     "NO",
              //     style: TextStyle(color: Colors.white, fontSize: 15),
              //   ),
              // ),
              DialogButton(
                onPressed: () {
                  Navigator.pop(context);
                  RequestPurchaseOrderNavigate();
                  // context.loaderOverlay.show();
                  // CustomLoading.progressDialog(
                  //     isLoading: true, context: context);
                  // submitPurchaseOrder(context);
                },
                color: Colors.black,
                child: const Text(
                  "CLOSE",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ]).show();
      });
    } else {
      CustomLoading.progressDialog(isLoading: false, context: context);
      if (kDebugMode) {
        print("ERROR");
      }
    }
  }

  // final PageRouteBuilder _homeRoute = PageRouteBuilder(
  //   pageBuilder: (BuildContext context, _, __) {
  //     return const ProjectListScreen();
  //   },
  // );

  String url = "";

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();

    _projId = widget.projectId!;
    _projName = widget.projectName!;

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
      bottomNavigationBar: InkWell(
        onTap: () {
          // showDialog<String>(
          //     context: context,
          //     builder: (BuildContext context) => AlertDialog(
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
          //                   context.loaderOverlay.show();
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
                    // context.loaderOverlay.show();
                    wsworkordersubmit();
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
      body: filePath != ''
          ? Center(
              child: Container(
                width: isZoomed ? 940 : 700,
                child: SfPdfViewer.network(
                  // pageLayoutMode:
                  //     PdfPageLayoutMode.single, // Ensures proper layout

                  onDocumentLoaded: (details) {
                    // if (fileName?.trim() != '') {
                    //   RemoveTempFile()
                    //       .removeRecentTempFile(fileName: fileName ?? '');
                    // }
                  },
                  initialZoomLevel: 0.75, enableDoubleTapZooming: true,
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
              //  CircularProgressIndicator()
            ),
      backgroundColor: Colors.white70,
    );
  }

  void RequestPurchaseOrderNavigate() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('flagRedirectToWorkProgress', 'true');
    backToScreen();
  }

  void backToScreen() {
    Navigator.maybePop(context);
  }
}
