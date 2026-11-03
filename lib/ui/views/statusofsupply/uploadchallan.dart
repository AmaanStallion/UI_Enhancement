import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';

import '../../../models/get_challan_po_order_list.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import '../rccstructure/pdfviewer.dart';

class UploadChallanofPo extends StatefulWidget {
  UploadChallanofPo({
    Key? key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.orderId,
    this.navigationFlag,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? orderId;
  final String? navigationFlag;

  @override
  State<UploadChallanofPo> createState() => _UploadChallanofPoState();
}

class _UploadChallanofPoState extends State<UploadChallanofPo> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  late BuildContext dialogContext;
  String strChallanRemarks = '';
  bool flagcalled = false;

  List<ChallanReportList>? challanReportList;

  int count = 0;

  var arrayFiles = [];
  var arrayFilesBytes = [];
  TextEditingController _txtRemarkController = TextEditingController();

  Future<ResponseGetPoChallanList?> wsGetPoChallanOrderList() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

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
        await apiNetworkHandler.post(AppUrl.webgetPoChallanListFromJson, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getPoChallanListFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          flagcalled = true;
          challanReportList = dataModel.response?.challanReportList!;
          count = challanReportList!.length! + 1;
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
  }

  submitUploadChallan() async {
    //for multipartrequest
    var request =
        http.MultipartRequest('POST', Uri.parse(AppUrl.webUploadPoChallan));

    //for token
    request.headers.addAll({"Authorization": "Bearer token"});

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    //for image and videos and files
    request.fields['user_id'] = userId!;
    request.fields['order_id'] = widget.orderId!;
    request.fields['report_remark'] = strChallanRemarks;

    for (int i = 0; i < arrayFiles.length!; i++) {
      PlatformFile file = arrayFiles[i];
      print("FILE UPLOAD");
      print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.extension);
      print(file.path);
      request.files.add(await http.MultipartFile.fromPath(
          "chalanreport", file.path.toString()));
    }
    //for completeing the request
    var response = await request.send();

    //for getting and decoding the response into json format
    var responsed = await http.Response.fromStream(response);
    final responseData = json.decode(responsed.body);
    if (kDebugMode) {
      print(responseData);
    }
    if (response.statusCode == 200) {
      Future.delayed(Duration.zero).then((_) {
        Navigator.pop(dialogContext);
        showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: const Text(''),
                  content: const Text('Uploaded successfully',
                      style: TextStyle(
                          fontStyle: FontStyle.normal, fontSize: 17.0)),
                  actions: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          fixedSize: const Size.fromWidth(100),
                          padding: const EdgeInsets.all(10),
                          textStyle: const TextStyle(color: Colors.white)),
                      child: const Text('CLOSE',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14.0,
                              color: Colors.white)),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                          Navigator.maybePop(context);
                        });
                      },
                    ),
                  ],
                ));
      });
    } else {
      if (kDebugMode) {
        print("ERROR");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    wsGetPoChallanOrderList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.projectName!.toUpperCase(),
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
          child: flagcalled == true
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 12, bottom: 12),
                      child: Center(child: Text('UPLOAD CHALLAN')),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 1,
                      endIndent: 1,
                      color: Colors.black,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30),
                        child: ListView.builder(
                            itemCount: count,
                            itemBuilder: (context, index) {
                              String dateRequired = '';
                              if (index != 0) {
                                String dateStart = challanReportList![index - 1]
                                    .poChallanCretatedAt!
                                    .toString();
                                DateFormat inputFormat =
                                    DateFormat('yyyy-MM-dd hh:mm:ss');
                                DateTime input = inputFormat.parse(dateStart);
                                dateRequired =
                                    DateFormat('dd MMM yyyy').format(input);
                              }

                              return index == 0
                                  ? Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0),
                                              child: Column(
                                                children: [
                                                  const Center(
                                                      child: Text(
                                                    'Attach Challan',
                                                    style: boldText,
                                                  )),
                                                  verticalSpaceSmall,
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10.0,
                                                            left: 10.0),
                                                    child: Container(
                                                      height: 120,
                                                      width: 120,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: Colors.white,
                                                        border: Border.all(
                                                          color: Colors
                                                              .black54, // red as border color
                                                        ),
                                                      ),
                                                      child: arrayFiles.isEmpty
                                                          ? IconButton(
                                                              iconSize: 50,
                                                              icon: const Icon(
                                                                Icons
                                                                    .add_circle_outlined,
                                                              ),
                                                              color:
                                                                  Colors.black,
                                                              onPressed:
                                                                  () async {
                                                                FilePickerResult?
                                                                    result =
                                                                    await FilePicker
                                                                        .platform
                                                                        .pickFiles(
                                                                  type: FileType
                                                                      .custom,
                                                                  allowedExtensions: [
                                                                    'pdf',
                                                                    'jpg',
                                                                    'jpeg',
                                                                    'png'
                                                                  ],
                                                                );
                                                                if (result !=
                                                                    null) {
                                                                  PlatformFile
                                                                      file =
                                                                      result
                                                                          .files
                                                                          .first;
                                                                  print(
                                                                      "FILE SELECTED");
                                                                  print(file
                                                                      .name);
                                                                  print(file
                                                                      .bytes);
                                                                  print(file
                                                                      .size);
                                                                  print(file
                                                                      .extension);
                                                                  print(file
                                                                      .path);
                                                                  Uint8List?
                                                                      fileBytes =
                                                                      result
                                                                          .files
                                                                          .first
                                                                          .bytes;
                                                                  String
                                                                      fileName =
                                                                      result
                                                                          .files
                                                                          .first
                                                                          .name;
                                                                  setState(() {
                                                                    arrayFilesBytes
                                                                        .add(
                                                                            fileBytes);
                                                                    arrayFiles
                                                                        .add(
                                                                            file);
                                                                  });
                                                                } else {
                                                                  // User canceled the picker
                                                                }
                                                              },
                                                            )
                                                          : _imagePdf(
                                                              arrayFiles[index],
                                                              index - 1),
                                                    ),
                                                  ),
                                                  verticalSpaceSmall,
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0, right: 10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Remarks',
                                                      style: boldText,
                                                    ),
                                                    verticalSpaceSmall,
                                                    Container(
                                                      height: 120.0,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              kcTextFieldColor,
                                                          border: Border.all(
                                                            color: Colors.grey,
                                                          ),
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          5.0))),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10.0,
                                                                right: 10.0),
                                                        child: TextField(
                                                            maxLines: 10,
                                                            enabled: true,
                                                            controller:
                                                                _txtRemarkController,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        15.0),
                                                            decoration:
                                                                const InputDecoration(
                                                              contentPadding:
                                                                  EdgeInsets.symmetric(
                                                                      vertical:
                                                                          18.0),
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              hintText:
                                                                  'Add Challan Review/Comments',
                                                            ),
                                                            onChanged:
                                                                (String str) {
                                                              strChallanRemarks =
                                                                  str;
                                                            }),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        verticalSpaceSmall,
                                        const Divider(
                                          height: 0.5,
                                          thickness: 0.5,
                                          indent: 1,
                                          endIndent: 1,
                                          color: Colors.black,
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            challanReportList![index - 1]
                                                        .poChallanReport!
                                                        .split(".")
                                                        .last ==
                                                    'pdf'
                                                ? Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) {
                                                        return PdfViewer(
                                                          fileName:
                                                              challanReportList![
                                                                      index - 1]
                                                                  .poChallanReport!,
                                                          fileUrl:
                                                              '${AppUrl.globalPoChallanUrl}${challanReportList![index - 1].poChallanReport!}',
                                                        );
                                                      },
                                                    ),
                                                  )
                                                : Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) {
                                                        return ImagePreviewViewer(
                                                          fileName:
                                                              challanReportList![
                                                                      index - 1]
                                                                  .poChallanReport!,
                                                          fileUrl:
                                                              '${AppUrl.globalPoChallanUrl}${challanReportList![index - 1].poChallanReport!}',
                                                        );
                                                      },
                                                    ),
                                                  );
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10.0),
                                                child: Column(
                                                  children: [
                                                    verticalSpaceSmall,
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 10.0,
                                                                left: 10.0),
                                                        child: Container(
                                                          height: 120,
                                                          width: 120,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            color: Colors.white,
                                                            border: Border.all(
                                                              color: Colors
                                                                  .black54, // red as border color
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child:
                                                                _imagePdfFromUrl(
                                                                    index),
                                                          ),
                                                        )),
                                                    verticalSpaceSmall,
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 20.0,
                                                          left: 10.0,
                                                          right: 10),
                                                  child: IntrinsicHeight(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'Remarks',
                                                              style: boldText,
                                                            ),
                                                            Text(dateRequired,
                                                                style:
                                                                    normalText),
                                                          ],
                                                        ),
                                                        verticalSpaceSmall,
                                                        Text(
                                                            challanReportList![
                                                                    index - 1]
                                                                .poChallanRemarks!,
                                                            maxLines: 5,
                                                            style: normalText),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        verticalSpaceSmall,
                                        const Divider(
                                          height: 0.5,
                                          thickness: 0.5,
                                          indent: 1,
                                          endIndent: 1,
                                          color: Colors.black,
                                        ),
                                      ],
                                    );
                            }),
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          if (arrayFiles.isEmpty) {
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                      title: const Text(''),
                                      content: const Text(
                                          'Please upload delivery challan file.',
                                          style: TextStyle(
                                              fontStyle: FontStyle.normal,
                                              fontSize: 17.0)),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              fixedSize:
                                                  const Size.fromWidth(100),
                                              padding: const EdgeInsets.all(10),
                                              textStyle: const TextStyle(
                                                  color: Colors.white)),
                                          child: const Text('CLOSE',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14.0,
                                                  color: Colors.white)),
                                          onPressed: () {
                                            setState(() {
                                              Navigator.pop(context);
                                            });
                                          },
                                        ),
                                      ],
                                    ));
                          } else if (strChallanRemarks == '') {
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                      title: const Text(''),
                                      content: const Text(
                                          'Please fill challan remark/comments field.',
                                          style: TextStyle(
                                              fontStyle: FontStyle.normal,
                                              fontSize: 17.0)),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              fixedSize:
                                                  const Size.fromWidth(100),
                                              padding: const EdgeInsets.all(10),
                                              textStyle: const TextStyle(
                                                  color: Colors.white)),
                                          child: const Text('CLOSE',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14.0,
                                                  color: Colors.white)),
                                          onPressed: () {
                                            setState(() {
                                              Navigator.pop(context);
                                            });
                                          },
                                        ),
                                      ],
                                    ));
                          } else {
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                      title: const Text('Upload Challan'),
                                      content: const Text(
                                          'Are you sure you want to submit this delivery challan?',
                                          style: TextStyle(
                                              fontStyle: FontStyle.normal,
                                              fontSize: 17.0)),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              fixedSize:
                                                  const Size.fromWidth(100),
                                              padding: const EdgeInsets.all(10),
                                              textStyle: const TextStyle(
                                                  color: Colors.white)),
                                          child: const Text('NO',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16.0,
                                                  color: Colors.white)),
                                          onPressed: () {
                                            setState(() {
                                              Navigator.pop(context);
                                            });
                                          },
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              fixedSize:
                                                  const Size.fromWidth(100),
                                              padding: const EdgeInsets.all(10),
                                              textStyle: const TextStyle(
                                                  color: Colors.white)),
                                          child: const Text('YES',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14.0,
                                                  color: Colors.white)),
                                          onPressed: () {
                                            setState(() {
                                              Navigator.pop(context);

                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder:
                                                    (BuildContext context) {
                                                  dialogContext = context;
                                                  return Center(
                                                    child: SizedBox(
                                                      height: 200,
                                                      width: 200,
                                                      child: Dialog(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: const [
                                                            verticalSpaceSmall,
                                                            CircularProgressIndicator(),
                                                            verticalSpaceSmall,
                                                            Text("Loading"),
                                                            verticalSpaceSmall,
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );

                                              submitUploadChallan();
                                            });
                                          },
                                        ),
                                      ],
                                    ));
                          }
                        },
                        child: Container(
                            padding: const EdgeInsets.only(top: 13),
                            height: 50,
                            width: double.infinity,
                            color: Colors.black,
                            child: const Text(
                              'SUBMIT',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ))),
                  ],
                )
              : const Center(child: CircularProgressIndicator())),
    );
  }

  Widget _imagePdf(PlatformFile file, int index) {
    if (file.extension == 'pdf') {
      return Stack(children: [
        Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('images/projectmanagement/pdf.png'),
                    fit: BoxFit.cover))),
        Positioned(
          top: -10,
          left: 70,
          height: 30,
          width: 30,
          child: IconButton(
              onPressed: () {
                setState(() {
                  arrayFiles.removeAt(index);
                });
              },
              icon: const Icon(Icons.close, color: Colors.red)),
        ),
      ]);
    } else {
      return Stack(children: [
        Image.file(
          File(
            file.path!,
          ),
          width: 100.0,
          height: 100.0,
        ),
        Positioned(
          top: -10,
          left: 70,
          height: 30,
          width: 30,
          child: IconButton(
              onPressed: () {
                setState(() {
                  arrayFiles.removeAt(index);
                });
              },
              icon: const Icon(Icons.close, color: Colors.red)),
        ),
      ]);
    }
  }

  Widget _imagePdfFromUrl(int index) {
    String file = challanReportList![index - 1].poChallanReport ?? '';
    if (file.contains('.pdf')) {
      return Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/projectmanagement/pdf.png'),
                  fit: BoxFit.cover)));
    } else {
      return Image.network(
          '${AppUrl.globalPoChallanUrl}${challanReportList![index - 1].poChallanReport}');
    }
  }
}
