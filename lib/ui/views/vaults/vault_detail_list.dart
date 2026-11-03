import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/aquisition_file_list.dart';
import 'package:stallion/models/project_permission.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/views/workprogess/pdfViewPage.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class VaultDetailList extends StatefulWidget {
  const VaultDetailList({
    super.key,
    required this.developerId,
    required this.acquisitionId,
  });
  final String developerId;
  final String acquisitionId;

  @override
  State<VaultDetailList> createState() => _VaultDetailListState();
}

class _VaultDetailListState extends State<VaultDetailList> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<AcquisitionList>? acquisitionList = [];
  List<PlatformFile> arrayFiles = [];
  List<Uint8List?> arrayFilesBytes = [];

  Future<File> downloadPdf(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/teams_file.pdf");
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw Exception("Failed to download PDF");
    }
  }

  uploadPermissionDoc({
    required AcquisitionList details,
  }) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse(AppUrl.wsAcquisitionFileUpload));

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
    });

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    request.fields['user_id'] = userId!;
    request.fields['acquisition_id'] = widget.acquisitionId;
    request.fields['plot_category_id'] = details.plotCategoryId ?? '';

    PlatformFile file = arrayFiles[0];
    request.files.add(await http.MultipartFile.fromPath(
      "acquisition_document",
      file.path.toString(),
      contentType: MediaType('application/pdf', file.extension ?? ""),
    ));

    var response = await request.send();

    var responsed = await http.Response.fromStream(response);
    final responseData = json.decode(responsed.body);

    if (response.statusCode == 200) {
      // final dataModel = uploadPermissionDiagraMResponseFromJson(responsed.body);
      // if (dataModel.response?.documentName != "") {
      //   print(dataModel.response?.documentName);
      // }
      print("SUCCESS");
      setState(() {
        arrayFiles = [];
        arrayFilesBytes = [];
        // details.subPermission?[0].subPermissionPdf
        //     ?.add(dataModel.response?.documentName ?? '');
        // details.uploadFlag = "1";

        // details.subPermission?[0].lastUpdateDate =
        //     DateFormat("d MMM yyyy").format(DateTime.now());
        // formatter.format(dateTime);
      });
      // getAllPermission();
      getAcquisitionList();
      if (kDebugMode) {
        print(responseData);
      }
    } else {
      print("ERROR");
    }
  }

  Future<dynamic?> getAcquisitionList() async {
    CustomLoading.progressDialog(isLoading: true, context: context);
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId ?? '',
      "acquisition_id": widget.acquisitionId,
      "developer_id": widget.developerId,
    };
    var response =
        await apiNetworkHandler.post(AppUrl.webcQuisitionFileList, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = aquisitionFileListFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          acquisitionList = dataModel.response?.acquisitionList;
        });
      }
    }
    CustomLoading.progressDialog(isLoading: false, context: context);
    return null;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getAcquisitionList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('PROJECTS VAULT',
            style: TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black54)),
              ),
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Category",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                  bottom: 10, top: 6, left: 80, right: 80),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black54))),
              child: const Row(
                children: [
                  Text(
                    "Category",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Spacer(),
                  Text(
                    "Action",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            for (int i = 0; i < acquisitionList!.length; i++)
              InkWell(
                onTap: () {
                  if (acquisitionList![i].documentList!.isNotEmpty) {
                    viewDocumentsModal(
                        title: acquisitionList?[i].plotCategory ?? '',
                        documentList: acquisitionList?[i].documentList,
                        index: i);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 12, bottom: 10, left: 80, right: 80),
                  decoration: const BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Colors.black45))),
                  child: Row(
                    children: [
                      Text(
                        acquisitionList?[i].plotCategory ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          // fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      acquisitionList![i].documentList!.isNotEmpty
                          ? const Icon(
                              Icons.check_circle_outline_outlined,
                              color: Colors.green,
                            )
                          : const Icon(
                              Icons.circle_outlined,
                              color: Colors.grey,
                            ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: [
                              'jpg',
                              'jpeg',
                              'png',
                              "pdf",
                            ],
                          );
                          if (result != null) {
                            PlatformFile file = result.files.first;
                            print("FILE SELECTED");
                            print(file.name);
                            print(file.bytes);
                            print(file.size);
                            print(file.extension);
                            print(file.path);
                            Uint8List? fileBytes = result.files.first.bytes;
                            setState(() {
                              arrayFilesBytes.add(fileBytes);
                              arrayFiles.add(file);
                            });

                            CustomLoading.progressDialog(
                                isLoading: true, context: context);
                            uploadPermissionDoc(
                              details: acquisitionList![i],
                            ).then((val) {
                              CustomLoading.progressDialog(
                                  isLoading: false, context: context);
                              // changeStatusModal(details: details).then((value) {
                              //   setState(() {
                              //     cnt = "";
                              //     selectedSortBy = details.status ?? '';
                              //   });
                              // });
                            });
                          } else {}
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Upload",
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget display({required DocumentList document}) {
    if (document.fileName!.split(".").last == 'pdf') {
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return PdfViewer(
                  // here
                  fileName: document.fileName,
                  fileUrl: '${AppUrl.vaultPath}${document.fileName}',
                );
              },
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          width: 140,
          child: Column(
            children: [
              Image.asset(
                'images/projectmanagement/pdf.png',
                width: 150,
                height: 150,
              ),
              AppText(
                title: document.fileName ?? '',
                fontSize: 14,
              )
            ],
          ),
        ),
      );
    } else if (document.status == "0") {
      String getTypeFromUrl(String url) {
        final lastSegment = url.split('/').last;

        if (lastSegment == "0") {
          return "Initial";
        } else if (lastSegment == "1") {
          return "Revised";
        } else {
          return "unknown";
        }
      }

      return InkWell(
        onTap: () async {
          // Navigator.push(
          // context,
          // MaterialPageRoute(
          //   builder: (_) {
          //     return PdfViewer(
          //       // here
          //       fileName: document.fileName,
          //       fileUrl: '${AppUrl.vaultPath}${document.fileName}',
          //     );
          //   },
          // ),
          // );

          final file = await downloadPdf('${document.fileName}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PdfViewPage(
                pdfFile: file,
                fileName: getTypeFromUrl(document.fileName ?? ''),
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          width: 140,
          child: Column(
            children: [
              Image.asset(
                'images/projectmanagement/pdf.png',
                width: 150,
                height: 150,
              ),
              AppText(
                title: getTypeFromUrl(document.fileName ?? ''),
                fontSize: 14,
              )
            ],
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return ImagePreviewViewer(
                  fileName: document.fileName,
                  fileUrl: '${AppUrl.vaultPath}${document.fileName}',
                );
              },
            ),
          );
        },
        child: Image.network(
          '${AppUrl.vaultPath}${document.fileName}',
          width: 100,
          height: 100,
        ),
      );
    }
  }

  viewDocumentsModal(
      {required List<DocumentList>? documentList,
      required int index,
      required String title}) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              content: SizedBox(
                height: 300,
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        direction: Axis.horizontal, // default
                        alignment: WrapAlignment.start, // default
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          for (int i = 0; i < documentList!.length; i++)
                            display(document: documentList[i]),
                          // documentList[i].fileName!.split(".").last == 'pdf'
                          //     ? InkWell(
                          //         onTap: () {
                          //           Navigator.push(
                          //             context,
                          //             MaterialPageRoute(
                          //               builder: (_) {
                          //                 return PdfViewer(
                          //                   // here
                          //                   fileName:
                          //                       documentList[i].fileName,
                          //                   fileUrl:
                          //                       '${AppUrl.vaultPath}${documentList[i].fileName}',
                          //                 );
                          //               },
                          //             ),
                          //           );
                          //         },
                          //         child: Container(
                          //           decoration: BoxDecoration(
                          //             border: Border.all(
                          //               color: Colors.grey,
                          //             ),
                          //             borderRadius: BorderRadius.circular(6),
                          //           ),
                          //           width: 140,
                          //           child: Column(
                          //             children: [
                          //               Image.asset(
                          //                 'images/projectmanagement/pdf.png',
                          //                 width: 150,
                          //                 height: 150,
                          //               ),
                          //               AppText(
                          //                 title:
                          //                     documentList[i].fileName ?? '',
                          //                 fontSize: 14,
                          //               )
                          //             ],
                          //           ),
                          //         ),
                          //       )
                          //     : InkWell(
                          //         onTap: () {
                          //           Navigator.push(
                          //             context,
                          //             MaterialPageRoute(
                          //               builder: (_) {
                          //                 return ImagePreviewViewer(
                          //                   fileName:
                          //                       documentList[i].fileName,
                          //                   fileUrl:
                          //                       '${AppUrl.vaultPath}${documentList[i].fileName}',
                          //                 );
                          //               },
                          //             ),
                          //           );
                          //         },
                          //         child: Image.network(
                          //           '${AppUrl.vaultPath}${documentList[i].fileName}',
                          //           width: 100,
                          //           height: 100,
                          //         ),
                          //       ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }
}
