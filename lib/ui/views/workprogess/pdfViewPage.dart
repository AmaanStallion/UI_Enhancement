import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewPage extends StatefulWidget {
  final File pdfFile;
  final String? fileName;

  PdfViewPage({required this.pdfFile, required this.fileName});

  @override
  State<PdfViewPage> createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  bool isZoomed = false;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  late PdfViewerController _pdfViewerController;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
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
        title: Text(widget.fileName!,
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
      body: Center(
        child: Container(
          width: isZoomed ? 940 : 700,
          child: SfPdfViewer.file(
            // initialZoomLevel: 1,
            // enableDoubleTapZooming: true,
            widget.pdfFile,
            // key: _pdfViewerKey,
            // controller: _pdfViewerController,
            // pageLayoutMode: PdfPageLayoutMode.single, // Ensures proper layout
            enableDoubleTapZooming: true,
            initialZoomLevel: 0.75,
            key: _pdfViewerKey,
            controller: _pdfViewerController,
          ),
        ),
      ),
    );
  }
}
