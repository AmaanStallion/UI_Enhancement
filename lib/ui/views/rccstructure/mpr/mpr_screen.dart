import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_mpr.dart';
import 'package:stallion/models/get_project_dpr_list.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class MprScreen extends StatefulWidget {
  const MprScreen(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.towarName})
      : super(key: key);
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;

  @override
  State<MprScreen> createState() => _MprScreenState();
}

class _MprScreenState extends State<MprScreen> {
  PlatformFile? arrayFiles;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Uint8List? arrayFilesBytes;
  TextEditingController _remarkController = TextEditingController();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<MonthlyReport>? monthlyReport = [];
  Future<GetProjectDprListResponse?> fetchGetAllMPRlist() async {
    String formatDate(DateTime dateTime) {
      // String formattedDate =
      //     DateFormat('yyyy-MM-dd HH:mm:ss').format(originalDate);
      // return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    }

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId ?? '',
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(AppUrl.getProjectMprList, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getProjectMprListFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          monthlyReport = dataModel.response?.monthlyReport;
        });
      } else {}
    }
  }

  setMprReport() async {
    var request = http.MultipartRequest('POST', Uri.parse(AppUrl.setMprList));
    request.headers.addAll({"Authorization": "Bearer token"});
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    request.fields["towar_id"] = widget.towarId!;
    request.fields["user_id"] = userId!;
    request.fields["project_id"] = widget.projectId!;
    request.fields["monthly_description"] = _remarkController.text;

    // for (int i = 0; i < arrayFiles.length; i++) {
    if (arrayFiles != null) {
      PlatformFile file = arrayFiles!;
      request.files.add(
        await http.MultipartFile.fromPath(
          "slab_month_document",
          file.path.toString(),
          contentType: MediaType('application/pdf', file.extension ?? ""),
        ),
      );
    }
    // }

    var response = await request.send();
    var responsed = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      // Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      showDialog<void>(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              actionsPadding:
                  const EdgeInsets.only(bottom: 10, left: 10, right: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: Text(
                'Monthly Progress Report Uploaded Successfully.',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              actions: [
                InkWell(
                  onTap: () {
                    setState(() {
                      arrayFiles = null;

                      arrayFilesBytes = null;
                      _remarkController.clear();
                    });
                    Navigator.of(context).pop();

                    fetchGetAllMPRlist();
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
    } else {}
  }

  @override
  void initState() {
    super.initState();

    fetchGetAllMPRlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: InkWell(
        onTap: () {
          if (_formKey.currentState!.validate()) {
            if (arrayFiles != null) {
              setMprReport();
            } else {
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
                      title: Text(
                        'Please attach Report.',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();

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
            }
          }
        },
        child: Container(
            color: Colors.black,
            // height: 40,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text(
              "Submit",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
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
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              width: double.maxFinite,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: const Text(
                "MONTHLY PROGRESS REPORT",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            addMPR(index: 1),
            const SizedBox(height: 6),
            const Divider(
              color: Colors.black,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (int i = 0; i < monthlyReport!.length; i++)
                      displayMPR(data: monthlyReport![i])
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget displayMPR({required MonthlyReport data}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () async {
                  if (data.slabMonDocument?.split(".").last == 'pdf') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          return PdfViewer(
                            // here
                            fileName: data.slabMonDocument,
                            fileUrl:
                                '${data.imagePath}/${data.slabMonDocument}',
                          );
                        },
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          return ImagePreviewViewer(
                            // here
                            fileName: data.slabMonDocument,
                            fileUrl:
                                '${data.imagePath}/${data.slabMonDocument}',
                          );
                        },
                      ),
                    );
                  }
                },
                child: SizedBox(
                    width: 140,
                    height: 140,
                    child: data.slabMonDocument?.split(".").last == 'pdf'
                        ? Image.asset(
                            'images/projectmanagement/pdf.png',
                            width: 100,
                            height: 100,
                          )
                        : Image.network(
                            '${data.imagePath}/${data.slabMonDocument}',
                            width: 100,
                            height: 100,
                          )),
              ),
              verticalSpaceMedium,
            ],
          ),
          const SizedBox(width: 100),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  const SizedBox(
                      width: 130, child: Text('Remarks : ', style: boldText13)),
                  SizedBox(
                    width: 550,
                    child: Text(
                      data.slabMonDescription ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  const SizedBox(
                      width: 130, child: Text('Date : ', style: boldText13)),
                  SizedBox(
                    width: 550,
                    child: Text(
                      data.createdOn ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget addMPR({required int index}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () async {
                if (arrayFiles == null) {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                  );
                  if (result != null) {
                    PlatformFile file = result.files.first;
                    Uint8List? fileBytes = result.files.first.bytes;
                    setState(() {
                      arrayFilesBytes = fileBytes;
                      arrayFiles = file;
                    });
                  } else {}
                } else {}
              },
              child: SizedBox(
                width: 140,
                height: 140,
                child: arrayFiles == null
                    ? Image.asset(
                        'images/projectmanagement/img5.png',
                        height: 140,
                        width: 140,
                      )
                    : arrayFiles?.extension == 'jpg' ||
                            arrayFiles?.extension == 'jpeg' ||
                            arrayFiles?.extension == 'png'
                        ? Image.file(
                            File(arrayFiles?.path ?? ''),
                            height: 140,
                            width: 140,
                          )
                        : arrayFiles?.extension == 'pdf'
                            ? Image.asset(
                                'images/projectmanagement/pdf.png',
                                width: 140.0,
                                height: 140.0,
                                fit: BoxFit.cover,
                              )
                            : const SizedBox.shrink(),
              ),
            ),
            Text('Attach Report',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                    color: Colors.black))
          ],
        ),
        const SizedBox(width: 100),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(
                    width: 130, child: Text('Remarks : ', style: boldText13)),
                SizedBox(
                  width: 550,
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "(Monthly Progress Report Review/ Comments Cannot Be Empty)";
                      }
                    },
                    maxLines: 4,
                    controller: _remarkController,
                    style: const TextStyle(color: Colors.black, fontSize: 13.0),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(12.0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      hintText: 'Add Monthly Progress Report Review/ Comments',
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 116, 116, 116),
                        fontSize: 13.0,
                        fontWeight: FontWeight.w200,
                        fontFamily: 'HelveticaNeue',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
