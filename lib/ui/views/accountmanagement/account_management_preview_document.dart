import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// An actual PDF generated in memory, so document previews work offline too.
class AccountManagementPreviewDocument extends StatelessWidget {
  const AccountManagementPreviewDocument({super.key});

  static final Future<Uint8List> _bytes = _createDocument();

  static Future<Uint8List> _createDocument() async {
    final document = pdf.Document();
    document.addPage(pdf.Page(
        build: (_) => pdf.Column(
              crossAxisAlignment: pdf.CrossAxisAlignment.start,
              children: [
                pdf.Text('STALLION',
                    style: pdf.TextStyle(
                        fontSize: 24, fontWeight: pdf.FontWeight.bold)),
                pdf.SizedBox(height: 24),
                pdf.Text('Sample Purchase / Work Order',
                    style: const pdf.TextStyle(fontSize: 18)),
                pdf.SizedBox(height: 16),
                pdf.Text(
                    'Order: PREVIEW-001\nProject: Sample Project - Tower A\nVendor: Sample Supplies Pvt Ltd\nDate: 03 November 2026'),
                pdf.SizedBox(height: 24),
                pdf.TableHelper.fromTextArray(
                  headers: ['Description', 'Quantity', 'Rate', 'Amount'],
                  data: [
                    ['Steel FE500', '100 MT', '1,250.00', '125,000.00'],
                    ['Concrete M25', '50 m3', '5,000.00', '250,000.00']
                  ],
                ),
                pdf.SizedBox(height: 24),
                pdf.Text('Total: INR 375,000.00',
                    style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold)),
                pdf.SizedBox(height: 36),
                pdf.Text(
                    'Local sample document for UI review. No order has been submitted.'),
              ],
            )));
    return document.save();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
        future: _bytes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text('Unable to render sample document'));
          }
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.black));
          }
          return SfPdfViewer.memory(snapshot.data!);
        },
      );
}

class AccountManagementPreviewDocumentScreen extends StatelessWidget {
  const AccountManagementPreviewDocumentScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('SAMPLE DOCUMENT'),
            centerTitle: true),
        body: const AccountManagementPreviewDocument(),
      );
}
