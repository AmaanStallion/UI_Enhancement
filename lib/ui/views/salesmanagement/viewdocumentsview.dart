import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/tenantDocuments.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/salesmanagement/architect_certi_listing.dart';
import 'package:stallion/ui/views/salesmanagement/documentlistview.dart';
import 'package:stallion/ui/views/tenantManagement/rent_receipt.dart';
import '../../../models/get_document_list.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../rccstructure/pdfviewer.dart';

class ViewDocumentsView extends StatefulWidget {
  const ViewDocumentsView({
    super.key,
    this.projectName,
    this.projectId,
    this.towarId,
    this.towarName,
    this.flatBuyerID, // tenant_id
    this.flatFunding,
    this.flagFrom = "", // TENANAT
    this.titleName = '',
    this.sales_plot_flag = '0',
    this.tenantList = false,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? flatBuyerID;
  final String? flatFunding;
  final String? flagFrom;
  final String? titleName;
  final String? sales_plot_flag;
  final bool? tenantList;
  @override
  State<ViewDocumentsView> createState() => _ViewDocumentsViewState();
}

class _ViewDocumentsViewState extends State<ViewDocumentsView> {
  String? flatAllotLetterTenant = '';
  String? flatAllotPathTenant = '';

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  var strFunding = "Self";

  var icons = [
    "images/projectmanagement/saleallotment.png",
    "images/projectmanagement/custom3.png",
    "images/projectmanagement/demandnote.png",
    "images/projectmanagement/invoices.png",
    "images/projectmanagement/bankletter.png",
    "images/projectmanagement/Architeech-certificate.png",
    "images/projectmanagement/possesionletter.png",
  ];

  String? bankLetter = "";
  String? flatAllotLetter = "";
  List<FlatBuyer>? flatBuyerDemandNote = [];
  List<FlatBuyer>? flatBuyerInvoiceData = [];
  String? costomCharesLetter = "";
  List<ArchCertificate>? archCertificate = [];
  String? possessionLetter = '';

  //TENANAT view
  List<Consent>? consent;
  List<Consent>? paaa;
  List<Consent>? personal;
  List<Consent>? tot;

  Future<ResponseGetDocumentList?> fetchDocumentList() async {
    CustomLoading.progressDialog(isLoading: true, context: context);

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    if (widget.flagFrom == "TENANAT") {
      Map<String, String> data = {
        "user_id": userId!,
        "towar_id": widget.towarId!,
        "project_id": widget.projectId!,
        "tenant_id": widget.flatBuyerID!,
      };
      var response =
          await apiNetworkHandler.post(AppUrl.webGetProjectTenantDocs, data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = tenantDocumentsFromJson(response.body);
        if (dataModel.response?.errorCode == "0") {
          setState(() {
            consent = dataModel.response?.tenantDoc?.consent;
            paaa = dataModel.response?.tenantDoc?.paaa;
            personal = dataModel.response?.tenantDoc?.personal;
            tot = dataModel.response?.tenantDoc?.tot;
            //            String? flatAllotLetterTenant = '';
            // String? flatAllotPathTenant = '';
            flatAllotLetterTenant =
                dataModel.response?.tenantDoc?.flatAllotLetter;
            flatAllotPathTenant = dataModel.response?.tenantDoc?.flatAllotPath;
          });
        }
      }
    } else {
      Map<String, String> data = {
        "user_id": userId!,
        "flat_buyer_id": widget.flatBuyerID!,
        "towar_id": widget.towarId!,
        "project_id": widget.projectId!,
      };

      var response = await apiNetworkHandler.post(
          AppUrl.webGetFlatDemandInvoiceList, data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = getDocumentListFromJson(response.body);
        if (kDebugMode) {
          print(dataModel.response?.errorCode);
        }
        if (dataModel.response?.errorCode == "0") {
          bankLetter = dataModel.response?.bankLetter;
          flatAllotLetter = dataModel.response?.flatAllotLetter;
          flatBuyerDemandNote = dataModel.response?.flatBuyerDemandNote;
          flatBuyerInvoiceData = dataModel.response?.flatBuyerInvoiceData;
          costomCharesLetter = dataModel.response?.costomCharesLetter;
          possessionLetter = dataModel.response?.possessionLetter;
          archCertificate = dataModel.response?.archCertificate;
          setState(() {});
        }
      }
    }

    CustomLoading.progressDialog(isLoading: false, context: context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // fetchDocumentList();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchDocumentList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var arrList = widget.flagFrom == "TENANAT"
        ? [
            "Allotment Letter",
            "Consent",
            "PAAA",
            "Identity Proof",
            "TOT",
            "Compensation Receipt",
          ]
        : widget.sales_plot_flag == "1"
            ? [
                "Allotment Letter",
                "Demand Notes",
                "Invoices",
                // "Possession Letter",
              ]
            : [
                "Allotment Letter",
                "Custom Charges",
                "Demand Notes",
                "Invoices",
                "Bank Letter",
                "Architectural Certificate", //Listing page inside
                "Possession Letter",
              ];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            widget.towarName!.isNotEmpty
                ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                : widget.projectName!.toUpperCase(),
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
                    '${widget.titleName!.isNotEmpty ? '${widget.titleName?.toUpperCase()} -' : ""} VIEW DOCUMENTS',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center),
              ),
            ),
            const Divider(height: 1.0, color: Colors.black),
            Expanded(
              child: ListView.builder(
                  itemCount: arrList.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: 100,
                      child: InkWell(
                        onTap: () {
                          if (widget.flagFrom == "TENANAT") {
                            if (arrList[index] == 'Compensation Receipt') {
                              if (widget.tenantList == true) {
                                var projectId = widget.projectId!;
                                var projectName = widget.projectName!;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return RentREceiptScreen(
                                        projectId: projectId,
                                        towarId: widget.towarId!,
                                        projectName: projectName,
                                        towarName: widget.towarName!,
                                        tenantId: widget.flatBuyerID!,
                                      );
                                    },
                                  ),
                                );
                              }
                            } else {
                              if (arrList[index] == 'Allotment Letter') {
                                if (flatAllotLetterTenant != '' ||
                                    flatAllotLetterTenant != '') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return PdfViewer(
                                          fileName: flatAllotLetterTenant,
                                          fileUrl:
                                              '$flatAllotPathTenant$flatAllotLetterTenant',
                                        );
                                      },
                                    ),
                                  );
                                } else {}
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return DocumentListView(
                                        projectId: widget.projectId,
                                        projectName: widget.projectName,
                                        towarName: widget.towarName,
                                        towarId: widget.towarId,
                                        flagNavigation: widget.flagFrom,
                                        tenantDocList: index == 0
                                            ? consent
                                            : index == 1
                                                ? paaa
                                                : index == 2
                                                    ? personal
                                                    : tot,
                                        title: arrList[index],
                                      );
                                    },
                                  ),
                                );
                              }
                            }
                          } else if (widget.sales_plot_flag == "1") {
                            if (index == 0) {
                              if (flatAllotLetter!.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return PdfViewer(
                                        fileName: flatAllotLetter,
                                        fileUrl:
                                            '${AppUrl.globalFlatAllotmentLetterURLMain}$flatAllotLetter',
                                      );
                                    },
                                  ),
                                );
                              }
                            }
                          } else {
                            if (index == 0) {
                              if (flatAllotLetter!.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return PdfViewer(
                                        fileName: flatAllotLetter,
                                        fileUrl:
                                            '${AppUrl.globalFlatAllotmentLetterURLMain}$flatAllotLetter',
                                      );
                                    },
                                  ),
                                );
                              }
                              //else if (index == 1) {
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (_) {
                              //         return DocumentListView(
                              //             projectId: widget.projectId,
                              //             projectName: widget.projectName,
                              //             towarName: widget.towarName,
                              //             towarId: widget.towarId,
                              //             documentllist: flatBuyerDemandNote,
                              //             flagNavigation: "Demand");
                              //       },
                              //     ),
                              //   );
                              // } else if (index == 2) {
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (_) {
                              //         return DocumentListView(
                              //             projectId: widget.projectId,
                              //             projectName: widget.projectName,
                              //             towarName: widget.towarName,
                              //             towarId: widget.towarId,
                              //             documentllist: flatBuyerInvoiceData,
                              //             flagNavigation: "Invoice");
                              //       },
                              //     ),
                              //   );
                              // }
                            } else if (index == 1) {
                              if (flatAllotLetter!.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return PdfViewer(
                                        fileName: flatAllotLetter,
                                        fileUrl:
                                            '${AppUrl.globalFlatCustomChargesURLMain}$flatAllotLetter',
                                      );
                                    },
                                  ),
                                );
                              }
                            } else if (index == 2) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) {
                                    return DocumentListView(
                                        projectId: widget.projectId,
                                        projectName: widget.projectName,
                                        towarName: widget.towarName,
                                        towarId: widget.towarId,
                                        documentllist: flatBuyerDemandNote,
                                        flagNavigation: "Demand");
                                  },
                                ),
                              );
                            } else if (index == 3) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) {
                                    return DocumentListView(
                                        projectId: widget.projectId,
                                        projectName: widget.projectName,
                                        towarName: widget.towarName,
                                        towarId: widget.towarId,
                                        documentllist: flatBuyerInvoiceData,
                                        flagNavigation: "Invoice");
                                  },
                                ),
                              );
                            } else if (index == 4) {
                              if (widget.flatFunding! == '1') {
                                if (bankLetter!.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return PdfViewer(
                                          fileName: bankLetter,
                                          fileUrl: bankLetter,
                                        );
                                      },
                                    ),
                                  );
                                }
                              }
                            } else if (index == 5) {
                              if (archCertificate != null &&
                                  archCertificate!.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return ArchitectCertiListing(
                                          certificateList: archCertificate!);
                                    },
                                  ),
                                );
                              }
                            } else if (index == 6) {
                              if (flatAllotLetter!.isNotEmpty &&
                                  possessionLetter!.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return PdfViewer(
                                        fileName: flatAllotLetter,
                                        fileUrl: possessionLetter,
                                        // '${AppUrl.globalFlatCustomChargesURLMain}$flatAllotLetter',
                                      );
                                    },
                                  ),
                                );
                              }
                              ;
                            } else {
                              print("index${index}");
                            }
                          }
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 80.0, vertical: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: Image.asset(icons[index])),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(arrList[index],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: (arrList[index] ==
                                                        'Compensation Receipt' &&
                                                    widget.tenantList == true)
                                                ? Colors.black
                                                : index == 4
                                                    ? widget.flatFunding! != '1'
                                                        ? Colors.grey
                                                        : Colors.black
                                                    : Colors.black,
                                          ),
                                          textAlign: TextAlign.left),
                                    ],
                                  ),
                                  const Icon(
                                    Icons.arrow_right_outlined,
                                    size: 30,
                                  )
                                ],
                              ),
                            ),
                            const Divider(
                              height: 1.0,
                              color: Colors.black,
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
