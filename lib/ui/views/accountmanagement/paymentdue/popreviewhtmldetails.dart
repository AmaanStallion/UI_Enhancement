import 'package:stallion/ui/views/accountmanagement/account_management_preview.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_document.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/get_po_preview_html.dart';
import '../../../../utils/api_network_call.dart';
import '../../../../utils/app_url.dart';

class PoPreviewHtml extends StatefulWidget {
  const PoPreviewHtml(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.orderId,
      this.poNo});

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? orderId;
  final String? poNo;

  @override
  State<PoPreviewHtml> createState() => _PoPreviewHtmlState();
}

class _PoPreviewHtmlState extends State<PoPreviewHtml> {
  bool isZoomed = false;

  String url = "";
  String? kLocalExamplePage = '';
  bool flagcalled = false;
  PoStructure? poStructure;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  late PdfViewerController _pdfViewerController;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = AccountManagementPreviewNetwork();

  late BuildContext dialogContext;
  String? strPoPdfPath = '';
  String? strPoPdfFileName = '';
  String? filePath = '';
  String? fileName = '';

  Future<ResponseGetPoPreviewHtml?> wspurchaseorderpreview() async {
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
      "order_id": widget.orderId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "user_type": userType!,
      "mask_flag": "1",
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
          fileName = dataModel.response?.fileName;
          filePath = '${dataModel.response?.filePath}';

          flagcalled = true;
          poStructure = dataModel.response?.poStructure!;
          kLocalExamplePage = poStructure?.content;
          strPoPdfPath = dataModel.response?.po_pdf!;
          strPoPdfFileName = dataModel.response?.po_file_name!;
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
    _pdfViewerController = PdfViewerController();

    wspurchaseorderpreview();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text('${widget.projectName!.toUpperCase()} - ${widget.poNo!}',
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              //shareFile(widget.fileName);
              //Save single pdf file
              _launchURL();
            },
          ),
          const SizedBox(
            width: 30,
          ),
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
      // body: Container(
      //   color: Colors.white,
      //   child: SafeArea(
      //       child: flagcalled == true
      //           ? Column(
      //               children: [
      //                 Expanded(
      //                   child: SingleChildScrollView(
      //                     child: Container(
      //                       color: Colors.white,
      //                       child: Padding(
      //                         padding: const EdgeInsets.all(20.0),
      //                         child: Column(
      //                           crossAxisAlignment: CrossAxisAlignment.center,
      //                           children: [
      //                             HtmlWidget(kLocalExamplePage!),
      //                           ],
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //                 verticalSpaceSmall,
      //               ],
      //             )
      //           : const Center(child: CircularProgressIndicator())),
      // )
      backgroundColor: Colors.white70,

      body: filePath != ''
          ? Center(
              child: Container(
                width: isZoomed ? 940 : 700,
                child: (useAccountManagementTestData
                    ? const AccountManagementPreviewDocument()
                    : SfPdfViewer.network(
                        // pageLayoutMode:
                        //     PdfPageLayoutMode.single, // Ensures proper layout

                        onDocumentLoaded: (details) {
                          if (fileName?.trim() != '') {
                            // RemoveTempFile()
                            //     .removeRecentTempFile(fileName: fileName ?? '');
                          }
                        },
                        initialZoomLevel: 0.75, // Or lower
                        enableDoubleTapZooming: true,
                        filePath ?? '',
                        // strPoPdfPath ?? '',
                        // 'https://skrite.com/stallion-build-test//media/backend/images/temporary-docs/20240307025504.pdf',
                        key: _pdfViewerKey,
                        controller: _pdfViewerController,
                      )),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  _launchURL() async {
    if (useAccountManagementTestData) return;
    print(filePath);
    if (filePath != "") {
      final uri = Uri.parse(filePath!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch';
      }
    }
  }
}
