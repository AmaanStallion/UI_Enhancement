import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/slaseLeadPdf.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/remove_temp_file.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class TenantPdfView extends StatefulWidget {
  const TenantPdfView({super.key, this.leadId});
  final String? leadId;

  @override
  State<TenantPdfView> createState() => _TenantPdfViewState();
}

class _TenantPdfViewState extends State<TenantPdfView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool isZoomed = false;
  late PdfViewerController _pdfViewerController;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  String? filePath = '';
  String? fileName = '';

  Future<dynamic?> wsworkorderpreview() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    // String towerId = "";
    // if (widget.towarId != null) {
    //   towerId = widget.towarId!;
    // }
    Map<String, String> data = {
      "user_id": userId!,
      // "wo_order_id": widget.workOrderId!,
      // "project_id": widget.projectId!,
      // "towar_id": towerId,
      "fluter": "1",
      "lead_id": widget.leadId ?? '',
    };

    if (kDebugMode) {
      print(data);
    }
    var response = await apiNetworkHandler.post(AppUrl.slaseLeadPdf, data);
    // if (kDebugMode) {
    //   print(response.statusCode);
    // }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = slaseLeadPdfFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response!);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          filePath = dataModel.response?.filename?.filePath;
          fileName = dataModel.response?.filename?.fileName;
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
    _pdfViewerController = PdfViewerController();

    wsworkorderpreview();
    // TODO: implement initState
    super.initState();
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
        title: Text(fileName ?? '',
            // '--------------',
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        actions: <Widget>[
          // widget.flagRedirect == 'Issued' || widget.flagRedirect == "project"
          // ?
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () async {
              //shareFile(widget.fileName);
              //Save single pdf file
              // _launchURL();
              final uri = Uri.parse('${filePath}/${fileName}');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                throw 'Could not launch';
              }
            },
          ),
          // : const SizedBox(),
          const SizedBox(
            width: 20,
          ),
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
      body: filePath != ''
          ? Center(
              child: Container(
                width: isZoomed ? 940 : 700,
                child: SfPdfViewer.network(
                  // pageLayoutMode:
                  //     PdfPageLayoutMode.single, // Ensures proper layout

                  // onDocumentLoaded: (details) {
                  //   if (fileName?.trim() != '') {
                  //     RemoveTempFile()
                  //         .removeRecentTempFile(fileName: fileName ?? '');
                  //   }
                  // },
                  initialZoomLevel: 0.75,
                  enableDoubleTapZooming: true,
                  '${filePath}/${fileName}' ?? '',
                  // strPoPdfPath ?? '',
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
            ),
    );
  }
}
