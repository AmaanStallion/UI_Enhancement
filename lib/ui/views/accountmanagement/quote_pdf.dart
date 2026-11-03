import 'package:stallion/ui/views/accountmanagement/account_management_preview.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_document.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/po_vendor_quotation_pdf.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class QuotePdf extends StatefulWidget {
  const QuotePdf({
    Key? key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    this.orderId,
  }) : super(key: key);
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? orderId;

  @override
  State<QuotePdf> createState() => _QuotePdfState();
}

class _QuotePdfState extends State<QuotePdf> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool isZoomed = false;

  late PdfViewerController _pdfViewerController;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String? quoteFileName = '';
  String? quoteFilePath = '';

  Future<List<dynamic>?> fetchPoVendorQuotationPdf() async {
    Map<String, String> data = {
      "order_id": widget.orderId ?? '',
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await AccountManagementPreviewNetwork()
        .post(AppUrl.getPoVendorQuotationPdf, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = poVendorQuotationPdfFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          quoteFileName = dataModel.response?.quoteFileName;
          quoteFilePath = dataModel.response?.quoteFilePath;
        });
      } else {}
    } else {}
    return null;
  }

  @override
  void initState() {
    fetchPoVendorQuotationPdf();
    _pdfViewerController = PdfViewerController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(quoteFileName ?? '',
            // widget.towarName!.isNotEmpty
            //     ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
            //     : widget.projectName!.toUpperCase(),
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              //shareFile(widget.fileName);
              //Save single pdf file
              _launchURL();
            },
          ),
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
      body: quoteFilePath != ''
          ? Center(
              child: Container(
                width: isZoomed ? 940 : 700,
                child: (useAccountManagementTestData
                    ? const AccountManagementPreviewDocument()
                    : SfPdfViewer.network(
                        // pageLayoutMode:
                        //     PdfPageLayoutMode.single, // Ensures proper layout

                        initialZoomLevel: 0.75, // Or lower
                        enableDoubleTapZooming: true,
                        quoteFilePath ?? '',
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
    if (quoteFilePath != "") {
      print(quoteFilePath);
      final uri = Uri.parse(quoteFilePath!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch';
      }
    }
  }
}
