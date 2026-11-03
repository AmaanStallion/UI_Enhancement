import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_all_slab_reports.dart';
import 'package:stallion/models/rcc_booking_details.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:http/http.dart' as http;

class UploadReportsScreen extends StatefulWidget {
  const UploadReportsScreen(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.towarName,
      this.slabId,
      this.title});
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? title;
  final String? slabId;
  @override
  State<UploadReportsScreen> createState() => _UploadReportsScreenState();
}

class _UploadReportsScreenState extends State<UploadReportsScreen> {
  PlatformFile? arrayFiles;

  Uint8List? arrayFilesBytes;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  TextEditingController remarkController = TextEditingController();

  List<LabReportList>? labReportList = [];
  Future<GetAllSlabReportResponse?> fetchAllSlabReport() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "slab_id": widget.slabId!,
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(AppUrl.getLabSlabReport, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getAllSlabReportFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          labReportList = dataModel.response?.labReportList;
        });
      } else {}
    }
  }

  setuploadReport({required BuildContext contextModal}) async {
    var request =
        http.MultipartRequest('POST', Uri.parse(AppUrl.wsSetSlabReport));

    // request.headers.addAll({
    //   'Content-Type': 'multipart/form-data',
    // });
    request.headers.addAll({"Authorization": "Bearer token"});

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    request.fields['user_id'] = userId ?? '';
    request.fields['slab_id'] = widget.slabId ?? '';
    request.fields['report_remark'] = remarkController.text;
    // request.fields['message'] = commentsList[isSelectedComment!];
    // request.fields['reason'] = textControler.text;

    // for (int i = 0; i < arrayFiles.length; i++) {
    PlatformFile? file = arrayFiles;
    request.files.add(
      await http.MultipartFile.fromPath(
        "labreport",
        file!.path.toString(),
      ),
    );
    // }

    var response = await request.send();

    var responsed = await http.Response.fromStream(response);
    // final responseData = json.decode(responsed.body);

    // if (response.statusCode == 200) {
    //   if (kDebugMode) {
    //     print("SUCCESS");
    //     fetchAllSlabReport();

    //     setState(() {
    //       arrayFiles = null;
    //       arrayFilesBytes = null;
    //       remarkController.clear();
    //     });
    //   }
    //   if (kDebugMode) {
    //     print(responseData);
    //   }
    // } else {
    //   print("ERROR");
    // }
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchAllSlabReport();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: InkWell(
        onTap: () {
          if (arrayFiles == null) {
            showDialog<void>(
                barrierDismissible: true,
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // Set radius to zero
                    ),
                    titlePadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    actionsPadding:
                        const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    actionsAlignment: MainAxisAlignment.center,
                    title: const Text(
                      "Please upload report file.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      InkWell(
                        onTap: () {
                          // Navigator.of(context).pop();

                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 250,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(7)),
                          child: const Text(
                            "Okay",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  );
                });
          } else {
            CustomLoading.progressDialog(isLoading: true, context: context);
            setuploadReport(contextModal: context).then((_) {
              setState(() {
                arrayFiles = null;
                arrayFilesBytes = null;
                remarkController.clear();
              });
              fetchAllSlabReport();
              CustomLoading.progressDialog(isLoading: false, context: context);

              showDialog<void>(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Set radius to zero
                      ),
                      titlePadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      actionsPadding: const EdgeInsets.only(
                          bottom: 10, left: 10, right: 10),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      actionsAlignment: MainAxisAlignment.center,
                      title: const Text(
                        "Uploaded Report Successfully.",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            // Navigator.of(context).pop()
                            // Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 250,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(7)),
                            child: const Text(
                              "Okay",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    );
                  });
            });
          }
        },
        child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Center(
              child: Text(
                "Submit",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            )),
      ),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 12),
            Text(
              "UPLOAD REPORTS",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Divider(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 140, vertical: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
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
                        String fileName = result.files.first.name;
                        setState(() {
                          arrayFiles = file;

                          arrayFilesBytes = fileBytes;

                          // datIssueController[index].arrayFilesBytes?.add(fileBytes);
                          // datIssueController[index].arrayFiles = file;
                        });
                      } else {}
                    },
                    child: SizedBox(
                      width: 140,
                      height: 140,
                      child: arrayFiles != null
                          ? arrayFiles?.extension == "pdf"
                              ? Image.asset(
                                  'images/projectmanagement/pdf.png',
                                  width: 140.0,
                                  height: 140.0,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(arrayFiles?.path ?? ''),
                                  height: 140,
                                  width: 140,
                                )
                          : Image.asset(
                              'images/projectmanagement/img5.png',
                              height: 140,
                              width: 140,
                            ),
                    ),
                  ),
                  SizedBox(width: 60),
                  SizedBox(
                      width: 130, child: Text('Remarks : ', style: boldText13)),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5.0))),
                      child: Padding(
                        padding: EdgeInsets.only(right: 22.0),
                        child: TextFormField(
                          controller: remarkController,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(12.0),
                            border: InputBorder.none,
                            hintText: 'Add Report Review/Comments',
                          ),
                          keyboardType: TextInputType.multiline,
                          minLines: 5, //Normal textInputField will be displayed
                          maxLines:
                              6, // when user presses enter it will adapt to it
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            for (int k = 0; k < labReportList!.length; k++)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 150),
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey))),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        labReportList?[k].labTestingReport?.split(".").last ==
                                'pdf'
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) {
                                    return PdfViewer(
                                      fileName: labReportList?[k]
                                          .labTestingReport
                                          .toString(),
                                      fileUrl:
                                          '${AppUrl.globalLabReport}${labReportList?[k].labTestingReport!}',
                                    );
                                  },
                                ),
                              )
                            : Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) {
                                    return ImagePreviewViewer(
                                      fileName: labReportList?[k]
                                          .labTestingReport
                                          .toString(),
                                      fileUrl:
                                          '${AppUrl.globalLabReport}${labReportList?[k].labTestingReport!}',
                                    );
                                  },
                                ),
                              );
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: 140,
                        height: 140,
                        child:
                            // datIssueController[index].arrayFiles != null
                            //     ? Image.file(
                            //         File(datIssueController[index].arrayFiles?.path ?? ''),
                            //         height: 140,
                            //         width: 140,
                            //       )
                            //     :
                            //     Image.asset(
                            //   'images/projectmanagement/img5.png',
                            //   height: 140,
                            //   width: 140,
                            // ),
                            //     Image.network(
                            //   '${AppUrl.globalLabReport}${labReportList?[k].labTestingReport!}',
                            //   width: 100,
                            //   height: 100,
                            // ),

                            labReportList?[k]
                                        .labTestingReport
                                        ?.split(".")
                                        .last ==
                                    'pdf'
                                ? Image.asset(
                                    'images/projectmanagement/pdf.png',
                                    width: 100.0,
                                    height: 100.0,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    '${AppUrl.globalLabReport}${labReportList?[k].labTestingReport!}',
                                    width: 100,
                                    height: 100,
                                  ),
                      ),
                    ),
                    SizedBox(width: 60),
                    SizedBox(
                        width: 130,
                        child: Text('Remarks : ', style: boldText13)),
                    Text(labReportList?[k].labTestingRemarks ?? ''),
                    Spacer(),
                    Text(DateFormat('dd MMM yyyy').format(
                        labReportList![k].labTestingReportCreatedAt ??
                            DateTime.now())),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
