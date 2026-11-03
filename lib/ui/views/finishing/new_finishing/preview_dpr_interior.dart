import 'dart:convert';
import 'dart:developer';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/dprPreviewHtml.dart';
import 'package:stallion/models/get_project_dpr_contractor.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/remove_temp_file.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

class PreviewDPRScreenInterior extends StatefulWidget {
  final String? projectId;
  final String? towarName;
  final String? projectName;
  final String? towarId;
  final List<CustomType>? customType;
  final List<WorkProgress>? workProgressList;
  final String? slabId;
  final String? slabNo;
  final String? dprDate;
  final String? workType;
  final List<Skill>? skillResponse;
  final String visitors;
  final List<ContrctorList>? contrctorList;
  final String? worktype;
  List<PlatformFile> arrayFiles = [];
  List<Uint8List?> arrayFilesBytes = [];
  List<OrderDeliveredList>? orderDeliveredList;
  List<DprYesterdayActivity>? dprYesterdayActivity;
  List<DprYesterdayActivity>? todaysPlanActivitySelected = [];
  String dificultiesNrequirements;
  final String dpr_difficulti_requirement;
  String? project_dpr_id = '';
  List<ContractProgress>? contractProgress;
  List<DprStaffList>? dprStaffList = [];
  final List<DprStockList>? dprStockList;

  PreviewDPRScreenInterior({
    super.key,
    this.projectId,
    this.towarName,
    this.projectName,
    this.towarId,
    this.contrctorList,
    this.customType,
    this.workProgressList,
    this.slabId,
    this.slabNo,
    this.dprDate,
    this.workType,
    this.skillResponse,
    this.worktype,
    required this.arrayFiles,
    required this.arrayFilesBytes,
    this.orderDeliveredList,
    required this.dpr_difficulti_requirement,
    required this.dprYesterdayActivity,
    required this.todaysPlanActivitySelected,
    required this.dificultiesNrequirements,
    this.project_dpr_id = '',
    this.contractProgress,
    required this.visitors,
    this.dprStaffList,
    this.dprStockList,
  });

  @override
  State<PreviewDPRScreenInterior> createState() => _PreviewDPRScreenState();
}

class _PreviewDPRScreenState extends State<PreviewDPRScreenInterior> {
  bool isZoomed = false;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  late PdfViewerController _pdfViewerController;
  String? filePath = '';
  String? fileName = '';

  String? kLocalExamplePage = '';
  String? strPoPdfPath = '';
  String? strPoPdfFileName = '';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  Future<ResponseDprPreviewHtml?> wsdprpreview() async {
    List<ContrctorList>? filteredContractorList = widget.contrctorList
        ?.where((element) => element.isSelected == true)
        .toList();

    List<Skill>? filteredskillResponseList = widget.skillResponse
        ?.where((element) => element.isSelected == true)
        .toList();

    int total = 0;

    for (CustomType item in widget.customType!) {
      if (item.value is String && item.value!.isNotEmpty) {
        total += int.tryParse(item.value ?? '') ?? 0;
      }
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
      "remark": "",
      "consultant_json": jsonEncode(filteredContractorList),
      "total_man_power": total.toString(),
      "drp_work_json": jsonEncode(widget.workProgressList),
      "drp_labour_json": json.encode(widget.customType),
      "slab_id": widget.slabId ?? '',
      "slab_no": widget.slabNo ?? '',
      "dpr_date": widget.dprDate ?? '',
      "dpr_activity_json": jsonEncode(filteredskillResponseList),
      "work_type": widget.workType ?? '',
      "drp_order_delivered_json": jsonEncode(widget.orderDeliveredList),
      "dpr_difficulti_requirement": widget.dpr_difficulti_requirement,
      "dpr_today_activity": jsonEncode(widget.todaysPlanActivitySelected),
      "dpr_yesterday_activity": jsonEncode(widget.dprYesterdayActivity),
      "dpr_difficulti_requirement ": widget.dpr_difficulti_requirement ?? '',
      'fluter': "1",
      "drp_contract_progress_json": jsonEncode(widget.contractProgress),
      "visitors": widget.visitors,
      "dpr_staff": jsonEncode(widget.dprStaffList),
      "dpr_stock_list": jsonEncode(widget.dprStockList)
    };

    if (kDebugMode) {
      print(data);
      print('------------');
    }
    var response = await apiNetworkHandler.post(AppUrl.getdprpreviewhtml, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = dprPreviewHtmlFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          fileName = dataModel.response?.fileName;
          filePath =
              '${dataModel.response?.filePath}/${dataModel.response?.fileName}';
          kLocalExamplePage = dataModel.response?.dprHtml!;
          print(kLocalExamplePage);
        });
      }
    } else {
      return null;
    }
  }

  // Future<ResponseDprPreviewHtml?> wsSetdprpreview() async {
  //   List<ContrctorList>? filteredContractorList = widget.contrctorList
  //       ?.where((element) => element.isSelected == true)
  //       .toList();

  //   List<Skill>? filteredskillResponseList = widget.skillResponse
  //       ?.where((element) => element.isSelected == true)
  //       .toList();

  //   int total = 0;

  //   for (CustomType item in widget.customType!) {
  //     if (item.value is String && item.value!.isNotEmpty) {
  //       total += int.tryParse(item.value ?? '') ?? 0;
  //     }
  //   }

  //   final SharedPreferences prefs = await _prefs;
  //   String? userId = prefs.getString('mobileNo');

  //   String towerId = "";
  //   if (widget.towarId != null) {
  //     towerId = widget.towarId!;
  //   }
  //   Map<String, String> data = {
  //     "user_id": userId!,
  //     "project_id": widget.projectId!,
  //     "towar_id": towerId,
  //     "remark": "",
  //     "consultant_json": jsonEncode(filteredContractorList),
  //     "total_man_power": total.toString(),
  //     "drp_work_json": jsonEncode(widget.workProgressList),
  //     "drp_labour_json": json.encode(widget.customType),
  //     "slab_id": widget.slabId ?? '',
  //     "slab_no": widget.slabNo ?? '',
  //     "dpr_date": widget.dprDate ?? '',
  //     "drp_activity_json": jsonEncode(filteredskillResponseList),
  //     "work_type": widget.workType ?? '',
  //   };

  //   if (kDebugMode) {
  //     print(data);
  //   }
  //   var response = await apiNetworkHandler.post(AppUrl.setdprpreviewhtml, data);

  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     final dataModel = dprPreviewHtmlFromJson(response.body);

  //     if (dataModel.response?.errorCode == "0") {
  //       setState(() {
  //         kLocalExamplePage = dataModel.response?.dprHtml!;
  //         print(kLocalExamplePage);
  //       });
  //     }
  //   } else {
  //     return null;
  //   }
  // }

  Future<ResponseDprPreviewHtml?> wsSetdprpreview() async {
    List<ContrctorList>? filteredContractorList = widget.contrctorList
        ?.where((element) => element.isSelected == true)
        .toList();

    List<Skill>? filteredskillResponseList = widget.skillResponse
        ?.where((element) => element.isSelected == true)
        .toList();

    int total = 0;

    for (CustomType item in widget.customType!) {
      if (item.value is String && item.value!.isNotEmpty) {
        total += int.tryParse(item.value ?? '') ?? 0;
      }
    }

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    var request =
        http.MultipartRequest('POST', Uri.parse(AppUrl.setProjectFinishingDpr));

    request.headers.addAll({'Content-Type': 'multipart/form-data'});
    request.fields['project_dpr_id'] = widget.project_dpr_id ?? '';

    request.fields['user_id'] = userId!;

    request.fields['project_id'] = widget.projectId!;
    request.fields['towar_id'] = towerId!;
    request.fields['remark'] = '';
    request.fields['consultant_json'] = jsonEncode(filteredContractorList);
    request.fields['total_man_power'] = total.toString();
    request.fields['drp_work_json'] = jsonEncode(widget.workProgressList);
    request.fields['drp_labour_json'] = json.encode(widget.customType);
    request.fields['slab_id'] = widget.slabId ?? '';
    request.fields['slab_no'] = widget.slabNo ?? '';
    request.fields['dpr_date'] = widget.dprDate ?? '';
    request.fields['drp_activity_json'] = jsonEncode(filteredskillResponseList);
    request.fields['work_type'] = widget.workType ?? '';
    request.fields['drp_order_delivered_json'] =
        jsonEncode(widget.orderDeliveredList);
    request.fields['dpr_difficulti_requirement'] =
        widget.dpr_difficulti_requirement;

    request.fields['dpr_today_activity'] =
        jsonEncode(widget.todaysPlanActivitySelected);
    request.fields['dpr_yesterday_activity'] =
        jsonEncode(widget.dprYesterdayActivity);
    request.fields['dpr_difficulti_requirement'] =
        widget.dpr_difficulti_requirement;
    request.fields['temporary_file_name'] = fileName ?? '';
    request.fields['drp_contract_progress_json'] =
        jsonEncode(widget.contractProgress);
    request.fields['dpr_staff'] = jsonEncode(widget.dprStaffList);
    request.fields['visitors'] = widget.visitors;
    for (int i = 0; i < widget.arrayFiles.length; i++) {
      if (widget.arrayFiles[i] != null &&
          widget.arrayFiles[i]?.extension == "mp4") {
        PlatformFile file = widget.arrayFiles[i];
        request.files.add(await http.MultipartFile.fromPath(
          "drpuploadvedio[]",
          file.path.toString(),
          contentType: MediaType('application/pdf', file.extension ?? ""),
        ));
      } else {
        PlatformFile file = widget.arrayFiles[i];
        request.files.add(await http.MultipartFile.fromPath(
          "drpuploadimg[]",
          file.path.toString(),
          contentType: MediaType('application/pdf', file.extension ?? ""),
        ));
      }
    }

    var response = await request.send();
    var responsed = await http.Response.fromStream(response);
    final responseData = json.decode(responsed.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return null;
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();

    wsdprpreview();
  }

  @override
  Widget build(BuildContext context1) {
    return Scaffold(
      backgroundColor: Colors.white70,

      bottomNavigationBar: InkWell(
        onTap: () {
          showDialog<void>(
              barrierDismissible: true,
              context: context1,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8), // Set radius to zero
                  ),
                  titlePadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  actionsPadding:
                      const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  actionsAlignment: MainAxisAlignment.center,
                  title: const Text(
                    "Are you sure you want to generate D.P.R?",
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
                        width: 150,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(7)),
                        child: const Text(
                          "No",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        // setSlabReport();
                        Navigator.of(context).pop();
                        Future.delayed(Duration(milliseconds: 100), () {
// code to be executed after 2 seconds
                          CustomLoading.progressDialog(
                              isLoading: true, context: context1);
                        });
                        wsSetdprpreview().then((value) {
                          CustomLoading.progressDialog(
                              isLoading: false, context: context1);
                          Navigator.of(context1).pop();
                          Navigator.of(context1).pop();
                        });
                        // Navigator.of(context).pop();

                        // deleteProjectPms(
                        //     projectPmsId: projectPmsDetailsResponse?[k]
                        //             .mstProjectPmsId ??
                        //         '');
                        // getProjectPms(
                        //     projectId:
                        //         widget.projectId,
                        //     towarId: widget.towarId);
                      },
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(7)),
                        child: const Text(
                          'Yes',
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

          // if (workProgressList?.length != 0) {
          //   String formatDate(DateTime dateTime) {
          //     // Format the DateTime as "yyyy-MM-dd" (e.g., "2023-09-01")
          //     return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
          //   }

          //   // Navigator.push(
          //   //   context,
          //   //   MaterialPageRoute(
          //   //     builder: (_) {
          //   //       return PreviewDPRScreenInterior(
          //   //         projectId: widget.projectId!,
          //   //         projectName: widget.projectName!,
          //   //         towarName: widget.towarName!,
          //   //         towarId: widget.towarId,
          //   //         contrctorList: contrctorList,
          //   //         customType: customType,
          //   //         workProgressList: workProgressList,
          //   //         slabId: widget.slabId,
          //   //         slabNo: widget.slabNumber,
          //   //         dprDate: formatDate(_selectedFormDate ?? DateTime.now()),
          //   //         skillResponse: skillResponse,
          //   //         workType: _workTypeController.text,
          //   //       );
          //   //     },
          //   //   ),
          //   // );
          // } else {
          //   // commonAleertModal(
          //   //     textTitle: 'Please enter atleast 1 work progress.');
          // }
        },
        child: Container(
          height: 40,
          color: Colors.black,
          child: const Center(
            child: Text(
              "GENERATE DPR",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
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
        actions: <Widget>[
          // IconButton(
          //   icon: const Icon(Icons.download, color: Colors.white),
          //   onPressed: () {
          //     //shareFile(widget.fileName);
          //     //Save single pdf file
          //     _launchURL();
          //   },
          // ),
          // const SizedBox(
          //   width: 30,
          // ),
          IconButton(
            icon: const Icon(
              Icons.zoom_in,
              color: Colors.white,
              size: 35,
            ),
            onPressed: () {
              setState(() {
                isZoomed = !isZoomed;
              });
              // _pdfViewerController.zoomLevel = 2;
            },
          ),
          const SizedBox(
            width: 30,
          ),
          IconButton(
            icon: const Icon(
              Icons.zoom_out,
              color: Colors.white,
              size: 35,
            ),
            onPressed: () {
              setState(() {
                isZoomed = !isZoomed;
              });
              // _pdfViewerController.zoomLevel = 0;
            },
          ),
          const SizedBox(
            width: 50,
          )
        ],
      ),
      // body: Html(
      //   data: kLocalExamplePagetE,
      //   //      '''
      //   //   <div>
      //   //     <h1>Hello, HTML Content!</h1>
      //   //     <p>This is some HTML content rendered in Flutter.</p>
      //   //   </div>
      //   // ''',
      // ),
      // body: HtmlWidget(kLocalExamplePagetE),
      body: filePath != ''
          ? Center(
              child: Container(
                width: isZoomed ? 940 : 700,
                child: SfPdfViewer.network(
                  onDocumentLoaded: (details) {
                    if (fileName?.trim() != '') {
                      RemoveTempFile()
                          .removeRecentTempFile(fileName: fileName ?? '');
                    }
                  },
                  initialZoomLevel: 0.75, enableDoubleTapZooming: true,
                  filePath ?? '',
                  // 'https://skrite.com/stallion-build-test//media/backend/images/temporary-docs/20240307025504.pdf',
                  key: _pdfViewerKey,
                  controller: _pdfViewerController,
                  // pageLayoutMode:
                  //     PdfPageLayoutMode.single, // Ensures proper layout
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
