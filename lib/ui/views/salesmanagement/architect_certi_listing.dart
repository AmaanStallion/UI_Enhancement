import 'package:flutter/material.dart';
import 'package:stallion/models/get_document_list.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';

class ArchitectCertiListing extends StatefulWidget {
  const ArchitectCertiListing({super.key, required this.certificateList});
  final List<ArchCertificate> certificateList;
  @override
  State<ArchitectCertiListing> createState() => _ArchitectCertiListingState();
}

class _ArchitectCertiListingState extends State<ArchitectCertiListing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: const CustomAppBar(
      //   title: "Architect Certificates",
      //   isBackgroundDark: true,
      // ),

      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Architect Certificates',
            style: TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),

      // appBar: AppBar(title: const Text('Architect Certificates')),
      body: widget.certificateList == null || widget.certificateList!.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: widget.certificateList!.length,
              itemBuilder: (context, index) {
                final slab = widget.certificateList![index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80.0, vertical: 6),
                  child: Column(
                    children: [
                      ExpansionTile(
                        // collapsedShape:
                        //     const Border(), // No border when collapsed
                        // shape: const Border(), // No border when expanded
                        collapsedShape: const Border(
                          bottom: BorderSide(
                              color: Colors.grey,
                              width: 1), // collapsed bottom border
                        ),
                        shape: const Border(
                          bottom: BorderSide(
                              color: Colors.transparent,
                              width: 1), // expanded bottom border
                        ),
                        title: Text(
                          slab.slabName ?? "No Slab Name",
                          style: const TextStyle(fontSize: 18),
                        ),

                        children: slab.details?.map((report) {
                              return Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                      // bottom: BorderSide(
                                      //     color: Colors.grey,
                                      //     width: 0.5), // bottom border
                                      ),
                                ),
                                child: ListTile(
                                  leading: Image.asset(
                                    'images/projectmanagement/pdf.png',
                                    height: 40,
                                  ),
                                  title: Text(
                                    report.title ?? "No File Name",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return PdfViewer(
                                            fileName: report.title,
                                            fileUrl: report.viewPdf,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList() ??
                            [
                              const ListTile(
                                title: Text("No certificates found"),
                              ),
                            ],

                        //  slab.details?.map((report) {
                        //       return ListTile(
                        //         leading: Image.asset(
                        //           'images/projectmanagement/pdf.png',
                        //           height: 40,
                        //         ),

                        //         // const Icon(Icons.picture_as_pdf),
                        //         title: Text(
                        //           report.title ?? "No File Name",
                        //           style: TextStyle(
                        //             fontSize: 14,
                        //             fontWeight: FontWeight.w500,
                        //           ),
                        //         ),
                        //         // subtitle: Text(
                        //         //   report.architechCertificateRemark ?? "",
                        //         //   style: TextStyle(
                        //         //     fontSize: 12,
                        //         //     fontWeight: FontWeight.w400,
                        //         //   ),
                        //         //   // const TextStyle(color: Colors.grey),
                        //         // ),
                        //         onTap: () {
                        //           Navigator.push(
                        //             context,
                        //             MaterialPageRoute(
                        //               builder: (_) {
                        //                 return PdfViewer(
                        //                   fileName: report.title,
                        //                   fileUrl: report.viewPdf,
                        //                 );
                        //               },
                        //             ),
                        //           );
                        //           // Navigator.push(
                        //           //   context,
                        //           //   MaterialPageRoute(
                        //           //     builder: (context) => PdfViewerPage(
                        //           //       pdfUrl: report.fileUrl ?? '',
                        //           //       pdfName: Uri.parse(
                        //           //         report.fileName ?? '',
                        //           //       ).pathSegments.last,
                        //           //     ),
                        //           //   ),
                        //           // );
                        //         },
                        //       );
                        //     }).toList() ??
                        // [
                        //   const ListTile(
                        //     title: Text("No certificates found"),
                        //   ),
                        // ],
                      ),
                      if (index != widget.certificateList!.length - 1)
                        const Divider(
                          height: 1,
                          thickness: 0.8,
                          indent: 16,
                          endIndent: 16,
                          color: Colors.grey,
                        ),
                      // const Divider(
                      //   height: 1,
                      //   thickness: 1,
                      // ), // Divider between slabs
                    ],
                  ),
                );
              },
            ),
    );
  }
}
