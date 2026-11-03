import 'package:stallion/ui/views/accountmanagement/account_management_preview.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_document.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../models/get_po_invoice_list.dart';
import '../../../../utils/api_network_call.dart';
import '../../../../utils/app_url.dart';
import '../../../shared/ui_helpers.dart';
import '../../mycontracts/imagepreviewview.dart';
import '../../rccstructure/pdfviewer.dart';

class InvoiceList extends StatefulWidget {
  const InvoiceList(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.orderId});
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? orderId;

  @override
  State<InvoiceList> createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = AccountManagementPreviewNetwork();

  bool flagcalled = false;
  List<InvoiceDatum>? invoiceData;

  Future<ResponseGetInvoiceList?> wsvenderpoinvoicelist() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "order_id": widget.orderId!,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.wsvenderpoinvoicelist, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getInvoiceListFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          flagcalled = true;
          invoiceData = dataModel.response?.invoiceData!;
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
    wsvenderpoinvoicelist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('${widget.projectName!.toUpperCase()} - INVOICE',
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
        child: flagcalled == true
            ? Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 106,
                    child: invoiceData!.isNotEmpty
                        ? ListView.builder(
                            itemCount: invoiceData!.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  invoiceData![index]
                                              .invoiceImage!
                                              .split(".")
                                              .last ==
                                          'pdf'
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) {
                                              return (useAccountManagementTestData
                                                  ? const AccountManagementPreviewDocumentScreen()
                                                  : PdfViewer(
                                                      fileName:
                                                          invoiceData![index]
                                                              .invoiceImage!,
                                                      fileUrl: AppUrl
                                                              .globalPoinvoicePath +
                                                          invoiceData![index]
                                                              .invoiceImage!,
                                                    ));
                                            },
                                          ),
                                        )
                                      : Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) {
                                              return (useAccountManagementTestData
                                                  ? const AccountManagementPreviewDocumentScreen()
                                                  : ImagePreviewViewer(
                                                      fileName:
                                                          invoiceData![index]
                                                              .invoiceImage!,
                                                      fileUrl:
                                                          '${AppUrl.globalPoinvoicePath}${invoiceData![index].invoiceImage!}',
                                                    ));
                                            },
                                          ),
                                        );
                                },
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 60.0),
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              invoiceData![index]
                                                      .invoiceImage!
                                                      .contains('.pdf')
                                                  ? Image.asset(
                                                      'images/projectmanagement/pdf.png',
                                                      width: 100,
                                                      height: 100,
                                                    )
                                                  : (useAccountManagementTestData
                                                      ? const Icon(
                                                          Icons
                                                              .description_outlined,
                                                          size: 48,
                                                          color: Colors.black54)
                                                      : Image.network(
                                                          '${AppUrl.globalPoinvoicePath}${invoiceData![index].invoiceImage!}',
                                                          width: 100,
                                                          height: 100,
                                                        ))
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 50.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                verticalSpaceSmall,
                                                Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 150,
                                                      child: Text('Invoice No.',
                                                          style: normalText),
                                                    ),
                                                    horizontalSpaceSmall,
                                                    Text(
                                                      invoiceData![index]
                                                          .invoiceNo!,
                                                      style: boldText,
                                                    ),
                                                  ],
                                                ),
                                                verticalSpaceSmall,
                                                Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 150,
                                                      child: Text(
                                                          'Total Amount',
                                                          style: normalText),
                                                    ),
                                                    horizontalSpaceSmall,
                                                    Text(
                                                        currencyFormat.format(
                                                            double.parse(
                                                                invoiceData![
                                                                        index]
                                                                    .totalAmount!)),
                                                        style: boldText),
                                                  ],
                                                ),
                                                verticalSpaceSmall,
                                                Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 150,
                                                      child: Text('Total Paid',
                                                          style: normalText),
                                                    ),
                                                    horizontalSpaceSmall,
                                                    Text(
                                                        currencyFormat.format(
                                                            double.parse(
                                                                invoiceData![
                                                                        index]
                                                                    .totalPaid!)),
                                                        style: boldText),
                                                  ],
                                                ),
                                                verticalSpaceSmall,
                                                Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 150,
                                                      child: Text('Uploaded On',
                                                          style: normalText),
                                                    ),
                                                    horizontalSpaceSmall,
                                                    Text(
                                                        invoiceData![index]
                                                            .invoiceDate!,
                                                        style: boldText),
                                                  ],
                                                ),
                                                verticalSpaceSmall,
                                                Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 150,
                                                      child: Text('Status',
                                                          style: normalText),
                                                    ),
                                                    horizontalSpaceSmall,
                                                    Text(
                                                        invoiceData![index]
                                                                    .status! ==
                                                                '0'
                                                            ? 'Unpaid'
                                                            : invoiceData![index]
                                                                        .status! ==
                                                                    '1'
                                                                ? 'Paid'
                                                                : 'Partially Paid',
                                                        style: invoiceData![
                                                                        index]
                                                                    .status! ==
                                                                '0'
                                                            ? boldText
                                                            : invoiceData![index]
                                                                        .status! ==
                                                                    '1'
                                                                ? const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        13.0,
                                                                    color: Colors
                                                                        .green)
                                                                : const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        13.0,
                                                                    color: Colors
                                                                        .red)),
                                                  ],
                                                ),
                                                verticalSpaceSmall,
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(),
                                  ],
                                ),
                              );
                            })
                        : Center(
                            child: Text(
                              "No Record Found",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  )
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
