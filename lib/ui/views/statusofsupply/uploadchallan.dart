import 'supply_preview.dart';
import 'supply_style.dart';
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
    if (useSupplyTestData) {
      setState(() {
        flagcalled = true;
        challanReportList = [];
        count = 1;
      });
      return null;
    }
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

    var response = await apiNetworkHandler.post(
      AppUrl.webgetPoChallanListFromJson,
      data,
    );
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
    if (supplyPreviewAction(context)) return;
    //for multipartrequest
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppUrl.webUploadPoChallan),
    );

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
      request.files.add(
        await http.MultipartFile.fromPath("chalanreport", file.path.toString()),
      );
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
        showSupplyDialog<String>(
          context: context,
          builder: (BuildContext context) => SupplyConfirmationDialog(
            actionsAlignment: MainAxisAlignment.center,
            title: const Text('Upload Challan'),
            content: const Text(
              'Uploaded successfully',
              style: TextStyle(
                  fontFamily: supplyFontFamily,
                  fontStyle: FontStyle.normal,
                  fontSize: 13,
                  height: 1.4),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  fixedSize: const Size.fromWidth(100),
                  padding: const EdgeInsets.all(10),
                  textStyle: const TextStyle(
                      fontFamily: supplyFontFamily, color: Colors.white),
                ),
                child: const Text(
                  'CLOSE',
                  style: TextStyle(
                    fontFamily: supplyFontFamily,
                    fontWeight: FontWeight.normal,
                    fontSize: 14.0,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                    Navigator.maybePop(context);
                  });
                },
              ),
            ],
          ),
        );
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
  void dispose() {
    _txtRemarkController.dispose();
    super.dispose();
  }

  Future<void> _pickChallan() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || !mounted) return;
    setState(() {
      arrayFilesBytes.add(result.files.first.bytes);
      arrayFiles.add(result.files.first);
    });
  }

  Widget _formPanel(Widget child) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: EdgeInsets.all(supplyCompact(context) ? 12 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffe1e5e9)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x10000000), blurRadius: 10, offset: Offset(0, 3))
          ],
        ),
        child: child,
      );

  Widget _uploadForm() {
    final compact = supplyCompact(context);
    final tileSize = compact ? 96.0 : 120.0;
    final labelStyle = TextStyle(
        fontFamily: supplyFontFamily,
        fontSize: compact ? 12 : 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87);
    return _formPanel(
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
          width: tileSize,
          child: Column(children: [
            Text('Attach Challan', style: labelStyle),
            const SizedBox(height: 10),
            Container(
              width: tileSize,
              height: tileSize,
              decoration: BoxDecoration(
                  color: const Color(0xfff8f9fa),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffdce1e6))),
              child: arrayFiles.isEmpty
                  ? IconButton(
                      key: const ValueKey('challan-attach'),
                      tooltip: 'Attach Challan',
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      iconSize: compact ? 32 : 40,
                      color: Colors.black,
                      onPressed: _pickChallan,
                    )
                  : _imagePdf(arrayFiles.first, 0),
            ),
          ])),
      SizedBox(width: compact ? 12 : 20),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Remarks', style: labelStyle),
        const SizedBox(height: 10),
        SizedBox(
            height: 120,
            child: TextField(
              key: const ValueKey('challan-remarks'),
              controller: _txtRemarkController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(
                  fontFamily: supplyFontFamily,
                  fontSize: compact ? 12 : 14,
                  color: Colors.black87),
              onChanged: (value) => strChallanRemarks = value,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: const Color(0xfff8f9fa),
                hintText: 'Add Challan Review/Comments',
                hintStyle: TextStyle(
                    fontFamily: supplyFontFamily,
                    fontSize: compact ? 12 : 14,
                    color: const Color(0xff9ca3ab),
                    fontWeight: FontWeight.w400),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xffe1e5e9))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xffe1e5e9))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xffb8bec5))),
              ),
            )),
      ])),
    ]));
  }

  Widget _savedChallan(int index) {
    final report = challanReportList![index - 1];
    final compact = supplyCompact(context);
    final tileSize = compact ? 80.0 : 120.0;
    final date = report.poChallanCretatedAt;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        final file = report.poChallanReport ?? '';
        if (file.split('.').last == 'pdf') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => PdfViewer(
                      fileName: file,
                      fileUrl: '${AppUrl.globalPoChallanUrl}$file')));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ImagePreviewViewer(
                      fileName: file,
                      fileUrl: '${AppUrl.globalPoChallanUrl}$file')));
        }
      },
      child: _formPanel(
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: tileSize,
            height: tileSize,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xfff8f9fa),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffe1e5e9))),
            child: _imagePdfFromUrl(index)),
        SizedBox(width: compact ? 12 : 20),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Text('Remarks',
                    style: TextStyle(
                        fontFamily: supplyFontFamily,
                        fontSize: compact ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87))),
            const SizedBox(width: 6),
            Flexible(
                child: Text(
                    date == null ? '' : DateFormat('dd MMM yyyy').format(date),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontFamily: supplyFontFamily,
                        fontSize: compact ? 11 : 13,
                        color: Colors.black54))),
          ]),
          const SizedBox(height: 10),
          Text(report.poChallanRemarks ?? '',
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: supplyFontFamily,
                  fontSize: compact ? 12 : 14,
                  color: Colors.black87)),
        ])),
      ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = supplyCompact(context);
    return SupplySurface(
        child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.projectName!.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: supplyFontFamily,
                fontSize: compact ? 14 : 17,
                fontWeight: FontWeight.w600)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.maybePop(context)),
      ),
      body: SafeArea(
          child: flagcalled
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                        height: 40,
                        child: Center(
                            child: Text('UPLOAD CHALLAN',
                                style: TextStyle(
                                    fontFamily: supplyFontFamily,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)))),
                    Expanded(
                        child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: compact ? 12 : 40, vertical: 12),
                      itemCount: count,
                      itemBuilder: (context, index) =>
                          index == 0 ? _uploadForm() : _savedChallan(index),
                    )),
                    GestureDetector(
                      key: const ValueKey('challan-submit'),
                      onTap: () {
                        if (arrayFiles.isEmpty) {
                          showSupplyDialog<String>(
                            context: context,
                            builder: (BuildContext context) =>
                                SupplyConfirmationDialog(
                              actionsAlignment: MainAxisAlignment.center,
                              title: const Text('Upload Challan'),
                              content: const Text(
                                'Please upload delivery challan file.',
                                style: TextStyle(
                                  fontFamily: supplyFontFamily,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    fixedSize: const Size(100, 32),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.standard,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    textStyle: const TextStyle(
                                      fontFamily: supplyFontFamily,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: const Text(
                                    'CLOSE',
                                    style: TextStyle(
                                      fontFamily: supplyFontFamily,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      Navigator.pop(context);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        } else if (strChallanRemarks == '') {
                          showSupplyDialog<String>(
                            context: context,
                            builder: (BuildContext context) =>
                                SupplyConfirmationDialog(
                              actionsAlignment: MainAxisAlignment.center,
                              title: const Text('Upload Challan'),
                              content: const Text(
                                'Please fill challan remark/comments field.',
                                style: TextStyle(
                                  fontFamily: supplyFontFamily,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    fixedSize: const Size.fromWidth(100),
                                    padding: const EdgeInsets.all(10),
                                    textStyle: const TextStyle(
                                      fontFamily: supplyFontFamily,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: const Text(
                                    'CLOSE',
                                    style: TextStyle(
                                      fontFamily: supplyFontFamily,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      Navigator.pop(context);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        } else {
                          showSupplyDialog<String>(
                            context: context,
                            builder: (BuildContext context) =>
                                SupplyConfirmationDialog(
                              title: const Text('Upload Challan'),
                              content: const Text(
                                'Are you sure you want to submit this delivery challan?',
                                style: TextStyle(
                                  fontFamily: supplyFontFamily,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    fixedSize: const Size.fromWidth(100),
                                    padding: const EdgeInsets.all(10),
                                    textStyle: const TextStyle(
                                      fontFamily: supplyFontFamily,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: const Text(
                                    'NO',
                                    style: TextStyle(
                                      fontFamily: supplyFontFamily,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      Navigator.pop(context);
                                    });
                                  },
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    fixedSize: const Size.fromWidth(100),
                                    padding: const EdgeInsets.all(10),
                                    textStyle: const TextStyle(
                                      fontFamily: supplyFontFamily,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: const Text(
                                    'YES',
                                    style: TextStyle(
                                      fontFamily: supplyFontFamily,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    if (useSupplyTestData) {
                                      Navigator.pop(context);
                                      supplyPreviewAction(this.context);
                                      return;
                                    }

                                    setState(() {
                                      Navigator.pop(context);

                                      showSupplyDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          dialogContext = context;
                                          return Center(
                                            child: SizedBox(
                                              height: 200,
                                              width: 200,
                                              child: Dialog(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
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
                            ),
                          );
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: 42,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(999)),
                        child: const Text(
                          'SUBMIT',
                          style: TextStyle(
                            fontFamily: supplyFontFamily,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(child: CircularProgressIndicator())),
    ));
  }

  Widget _imagePdf(PlatformFile file, int index) =>
      LayoutBuilder(builder: (context, constraints) {
        final pdf = file.extension?.toLowerCase() == 'pdf';
        return Stack(fit: StackFit.expand, children: [
          Padding(
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: pdf
                    ? Image.asset('images/projectmanagement/pdf.png',
                        fit: BoxFit.contain)
                    : file.bytes != null
                        ? Image.memory(file.bytes!, fit: BoxFit.cover)
                        : Image.file(File(file.path!), fit: BoxFit.cover),
              )),
          Positioned(
              top: 0,
              right: 0,
              width: 28,
              height: 28,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xffe1e5e9))),
                child: IconButton(
                  key: const ValueKey('challan-remove'),
                  tooltip: 'Remove attachment',
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.close_rounded,
                      size: 17, color: Colors.black87),
                  onPressed: () => setState(() {
                    arrayFiles.removeAt(index);
                    if (index < arrayFilesBytes.length)
                      arrayFilesBytes.removeAt(index);
                  }),
                ),
              )),
        ]);
      });

  Widget _imagePdfFromUrl(int index) {
    String file = challanReportList![index - 1].poChallanReport ?? '';
    if (file.contains('.pdf')) {
      return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/projectmanagement/pdf.png'),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Image.network(
        '${AppUrl.globalPoChallanUrl}${challanReportList![index - 1].poChallanReport}',
      );
    }
  }
}
