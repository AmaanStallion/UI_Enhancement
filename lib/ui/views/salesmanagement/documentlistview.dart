import 'package:flutter/material.dart';
import 'package:stallion/models/tenantDocuments.dart';
import 'package:stallion/ui/widgets/app_text.dart';

import '../../../models/get_document_list.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import '../mycontracts/imagepreviewview.dart';
import '../rccstructure/pdfviewer.dart';

class DocumentListView extends StatefulWidget {
  DocumentListView({
    super.key,
    this.projectName,
    this.projectId,
    this.towarId,
    this.towarName,
    this.documentllist,
    this.flagNavigation = '',
    this.tenantDocList,
    this.title = '',
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? flagNavigation;
  final List<FlatBuyer>? documentllist;
  final List<Consent>? tenantDocList;
  final String? title;

  @override
  State<DocumentListView> createState() => _DocumentListViewState();
}

class _DocumentListViewState extends State<DocumentListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            widget.towarName!.isNotEmpty
                ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                : '${widget.projectName!.toUpperCase()}',
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: Center(
                child: Text(
                    widget.flagNavigation == 'TENANAT'
                        ? widget.title ?? ''
                        : widget.flagNavigation == 'Demand'
                            ? 'DEMAND NOTES'
                            : 'INVOICES',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center),
              ),
            ),
            const Divider(
              height: 1.0,
              color: Colors.black,
            ),
            Expanded(
              child: (widget.flagNavigation == 'TENANAT' &&
                          widget.tenantDocList!.isNotEmpty) ||
                      ((widget.flagNavigation == 'Demand' ||
                              widget.flagNavigation == 'Invoice') &&
                          widget.documentllist!.isNotEmpty)
                  ? ListView.separated(
                      itemCount: widget.flagNavigation == 'TENANAT'
                          ? widget.tenantDocList!.length
                          : widget.documentllist!.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            if (widget.flagNavigation == 'TENANAT') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) {
                                    return PdfViewer(
                                        fileName: widget.tenantDocList![index]
                                            .documentName!,
                                        fileUrl: AppUrl.globalTenantDocuments +
                                            widget.tenantDocList![index]
                                                .documentName!);
                                  },
                                ),
                              );
                            } else {
                              widget.documentllist![index].viewPdf!
                                          .split(".")
                                          .last ==
                                      'pdf'
                                  ? Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return PdfViewer(
                                            fileName: widget
                                                .documentllist![index].viewPdf!,
                                            fileUrl: widget.flagNavigation ==
                                                    "Demand"
                                                ? AppUrl.globalSaleDemandNoteUrl +
                                                    widget.documentllist![index]
                                                        .viewPdf!
                                                : AppUrl.globalSaleInvoiceUrl +
                                                    widget.documentllist![index]
                                                        .viewPdf!,
                                          );
                                        },
                                      ),
                                    )
                                  : Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return ImagePreviewViewer(
                                            fileName: widget
                                                .documentllist![index].viewPdf!,
                                            fileUrl:
                                                '${AppUrl.globalPoinvoicePath}${widget.documentllist![index].viewPdf!}',
                                          );
                                        },
                                      ),
                                    );
                            }
                          },
                          child: widget.flagNavigation == 'TENANAT'
                              ? Container(
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 60.0),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'images/projectmanagement/pdf.png',
                                        width: 100,
                                        height: 100,
                                      ),
                                      Text(
                                        widget.tenantDocList![index]
                                            .documentName!,
                                        style: normalText,
                                      ),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 60.0),
                                  child: Row(
                                    children: [
                                      Column(
                                        children: [
                                          widget.documentllist![index].viewPdf!
                                                  .contains('.pdf')
                                              ? Image.asset(
                                                  'images/projectmanagement/pdf.png',
                                                  width: 100,
                                                  height: 100,
                                                )
                                              : Image.network(
                                                  '${AppUrl.globalPoinvoicePath}${widget.documentllist![index].viewPdf!}',
                                                  width: 100,
                                                  height: 100,
                                                )
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 50.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            verticalSpaceSmall,
                                            Row(
                                              children: [
                                                const SizedBox(
                                                  width: 150,
                                                  child: Text('Title.',
                                                      style: normalText),
                                                ),
                                                horizontalSpaceSmall,
                                                Text(
                                                  widget.documentllist![index]
                                                      .title!,
                                                  style: normalText,
                                                ),
                                              ],
                                            ),
                                            verticalSpaceSmall,
                                            Row(
                                              children: [
                                                const SizedBox(
                                                  width: 150,
                                                  child: Text('Amount Due',
                                                      style: normalText),
                                                ),
                                                horizontalSpaceSmall,
                                                Text(
                                                    currencyFormat.format(
                                                        double.parse(widget
                                                            .documentllist![
                                                                index]
                                                            .amountDue!)),
                                                    style: normalText),
                                              ],
                                            ),
                                            verticalSpaceSmall,
                                            Row(
                                              children: [
                                                const SizedBox(
                                                  width: 150,
                                                  child: Text('Date',
                                                      style: normalText),
                                                ),
                                                horizontalSpaceSmall,
                                                Text(
                                                    widget.documentllist![index]
                                                        .dueDate!,
                                                    style: normalText),
                                              ],
                                            ),
                                            verticalSpaceSmall,
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        );
                      },
                      separatorBuilder: (context1, index) => const Divider(),
                    )
                  : const Center(
                      child: AppText(
                        title: "No Record Found",
                        fontSize: 20,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
