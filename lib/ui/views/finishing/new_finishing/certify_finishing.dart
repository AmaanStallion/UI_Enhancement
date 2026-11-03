import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/finishing_flat_listing.dart';
import 'package:stallion/models/finishing_qty_list.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CertifyFinishingScreen extends StatefulWidget {
  CertifyFinishingScreen({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    required this.isInterior,
    required this.finishingId,
    required this.floorId,
    required this.finishingMaterial,
    required this.floorName,
    required this.totalQty,
    required this.certifiedQty,
  });
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String isInterior;
  final String finishingId;
  final String floorId;
  final String floorName;
  final double totalQty;
  double certifiedQty;
  final String finishingMaterial;

  @override
  State<CertifyFinishingScreen> createState() => _CertifyFinishingScreenState();
}

class _CertifyFinishingScreenState extends State<CertifyFinishingScreen> {
  FinishingConsumeDetail? isFinishingConsumeDetailEdit;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<CompanyDetail>? contrctorList = [];
  TextEditingController _contractorNameController = TextEditingController();
  TextEditingController _workCompleteController = TextEditingController();
  TextEditingController _unitNameController = TextEditingController();
  List<PlatformFile> arrayFiles = [];
  List<Uint8List?> arrayFilesBytes = [];
  TextEditingController _remarkController = TextEditingController();

  String isSelectedUnitListMstFinishingUnitId = '-';

  String? isSelectedContrctorListCompanyId = '-';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<FinishingUnit>? finishingUnit = [];
  List<FinishingConsumeDetail>? finishingConsumeDetailsData = [];

  String? pathData = '';

  setFinishing() async {
    CustomLoading.progressDialog(isLoading: true, context: context);
    var request =
        http.MultipartRequest('POST', Uri.parse(AppUrl.setFinishingQty));
    request.headers.addAll({"Authorization": "Bearer token"});
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    request.fields["user_id"] = userId ?? '';

    request.fields["project_id"] = widget.projectId ?? '';
    request.fields["towar_id"] = widget.towarId ?? '';
    request.fields["finishing_id"] = widget.finishingId;
    request.fields["floor_id"] = widget.floorId;
    request.fields["company_id"] = isSelectedContrctorListCompanyId ?? '';
    request.fields["remark"] = _remarkController.text;
    request.fields["quantity"] = _workCompleteController.text;
    request.fields["unit_id"] = isSelectedUnitListMstFinishingUnitId;
    request.fields["consume_id"] =
        isFinishingConsumeDetailEdit?.mstFinishingConsumeId ?? '0';

    for (int i = 0; i < arrayFiles.length; i++) {
      PlatformFile file = arrayFiles[i];
      request.files.add(
        await http.MultipartFile.fromPath(
          "finishing_document[]",
          file.path.toString(),
          contentType: MediaType('application/pdf', file.extension ?? ""),
        ),
      );
    }
    var response = await request.send();
    var responsed = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      // Navigator.of(context).pop();
      // List<PlatformFile> arrayFiles = [];
      // List<Uint8List?> arrayFilesBytes = [];
      // List<ContrctorList>? contrctorList = [];
      // ContrctorList? isSelectedContrctorList;
      // final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
      // TextEditingController _contractorNameController = TextEditingController();
      // TextEditingController _workCompleteController = TextEditingController();

      // TextEditingController _remarkController = TextEditingController();
      setState(() {
        // widget.finishingDetails?.consumeQty =
        //     (double.parse(widget.finishingDetails?.consumeQty ?? '') +
        //             double.parse(_workCompleteController.text))
        //         .toString();
        if (isFinishingConsumeDetailEdit == null) {
          widget.certifiedQty =
              widget.certifiedQty + double.parse(_workCompleteController.text);
        } else {
          if (double.parse(
                  isFinishingConsumeDetailEdit?.finishingConsumQty ?? '0') >
              double.parse(_workCompleteController.text)) {
            widget.certifiedQty = widget.certifiedQty -
                (double.parse(
                        isFinishingConsumeDetailEdit?.finishingConsumQty ??
                            '0') -
                    double.parse(_workCompleteController.text));
          } else {
            widget.certifiedQty = widget.certifiedQty +
                (double.parse(_workCompleteController.text) -
                    double.parse(
                        isFinishingConsumeDetailEdit?.finishingConsumQty ??
                            '0'));
          }
        }

        arrayFiles = [];
        arrayFilesBytes = [];
        isSelectedContrctorListCompanyId = '-';
        _contractorNameController.clear();
        _workCompleteController.clear();
        _unitNameController.clear();
        _remarkController.clear();
        isFinishingConsumeDetailEdit = null;
      });
      getFinishingList(isfromUpdate: true).then((value) {
        CustomLoading.progressDialog(isLoading: false, context: context);
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
                title: const Text(
                  "You have Successfully Certified.",
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
      }).onError((error, stackTrace) {
        CustomLoading.progressDialog(isLoading: false, context: context);
      });
      // Navigator.pop(context);
      //   // ignore: use_build_context_synchronously
      //   // showDialog<void>(
      //   //     barrierDismissible: true,
      //   //     context: context,
      //   //     builder: (context) {
      //   //       return AlertDialog(
      //   //         shape: RoundedRectangleBorder(
      //   //           borderRadius: BorderRadius.circular(8), // Set radius to zero
      //   //         ),
      //   //         titlePadding:
      //   //             const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      //   //         actionsPadding:
      //   //             const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      //   //         contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      //   //         actionsAlignment: MainAxisAlignment.center,
      //   //         title: Text(
      //   //           'Checklist ${saveStatus == "0" ? 'Saved' : 'Submitted'} Successfully.',
      //   //           style: const TextStyle(
      //   //             fontSize: 16,
      //   //             fontWeight: FontWeight.w600,
      //   //           ),
      //   //           textAlign: TextAlign.center,
      //   //         ),
      //   //         actions: [
      //   //           InkWell(
      //   //             onTap: () {
      //   //               Navigator.of(context).pop();

      //   //               Navigator.of(context).pop();
      //   //             },
      //   //             child: Container(
      //   //               width: 250,
      //   //               padding: const EdgeInsets.symmetric(vertical: 4),
      //   //               decoration: BoxDecoration(
      //   //                   color: Colors.black,
      //   //                   borderRadius: BorderRadius.circular(7)),
      //   //               child: const Text(
      //   //                 "Okay",
      //   //                 style: TextStyle(
      //   //                   fontSize: 16,
      //   //                   fontWeight: FontWeight.w600,
      //   //                   color: Colors.white,
      //   //                 ),
      //   //                 textAlign: TextAlign.center,
      //   //               ),
      //   //             ),
      //   //           ),
      //   //         ],
      //   //       );
      //   //     });
    } else {}
  }

  Future<List<FinishingList>?> getFinishingList({
    bool isfromUpdate = false,
  }) async {
    try {
      if (isfromUpdate == false) {
        CustomLoading.progressDialog(isLoading: true, context: context);
      }
      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "project_id": widget.projectId ?? '',
        "towar_id": widget.towarId ?? '',
        "finishing_id": widget.finishingId,
        "floor_id": widget.floorId,
        "finishing_type": widget.isInterior,
      };

      if (kDebugMode) {
        print(data);
      }

      var response = await apiNetworkHandler.post(AppUrl.getFinishingInd, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = finishingQtyListFromJson(response.body);
        if (dataModel.response?.errorCode == "0") {
          setState(() {
            finishingUnit = dataModel.response?.finishingUnit;
            finishingConsumeDetailsData =
                dataModel.response?.finishingConsumeDetails;
            pathData = dataModel.response?.path;
            contrctorList = dataModel.response?.companyDetails;
          });
        }
      } else {}
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
    } finally {
      if (isfromUpdate == false) {
        CustomLoading.progressDialog(isLoading: false, context: context);
      }
    }
    return null;
  }

  Future<List<FinishingList>?> deleteDocument({
    required final String documentId,
    required DocumentList dataa,
  }) async {
    try {
      CustomLoading.progressDialog(isLoading: true, context: context);
      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "project_id": widget.projectId ?? '',
        "towar_id": widget.towarId ?? '',
        "document_id": documentId,
      };

      if (kDebugMode) {
        print(data);
      }

      var response =
          await apiNetworkHandler.post(AppUrl.wsConsumeDocumentRemove, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          isFinishingConsumeDetailEdit!.documentList?.remove(dataa);
        });
        // final dataModel = finishingQtyListFromJson(response.body);
        // if (dataModel.response?.errorCode == "0") {}
      } else {}
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
    } finally {
      CustomLoading.progressDialog(isLoading: false, context: context);
    }
    return null;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getFinishingList();
      // fetchGetAllDprlist();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
            const SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      // color: const Color.fromARGB(255, 83, 83, 83),
                      // height: 100,
                      margin: const EdgeInsets.only(right: 30, top: 13),
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black),
                      ),
                      width: MediaQuery.of(context).size.width * 0.38,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 200,
                                child: const Text(
                                  "Finishing Material :",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                widget.finishingMaterial,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (widget.isInterior != "1")
                            const SizedBox(height: 22),
                          if (widget.isInterior != "1")
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 200,
                                  child: const Text(
                                    "Floor Name :	",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  widget.floorName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 200,
                                child: const Text(
                                  "Total Quantity :	",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                widget.totalQty.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 200,
                                child: const Text(
                                  "Certified Quantity :	",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                widget.certifiedQty.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 200,
                                child: const Text(
                                  "Remaining Quantity:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                (widget.totalQty - widget.certifiedQty)
                                    .toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(left: 20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(color: Colors.black54),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "(1.) Estimated Quantity",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        )),
                  ],
                ),
                Stack(
                  children: [
                    Form(
                      key: _formKey,
                      child: Container(
                        margin: const EdgeInsets.only(top: 13),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black),
                        ),
                        // height: 200,
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Column(
                          children: [
                            Row(
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 110.0, // height: 40.0,
                                  child: Text(
                                    'Contractor Name',
                                    // textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                Container(
                                  width: 360,
                                  child: InkWell(
                                    onTap: () {
                                      selectContractorModal();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 10.0),
                                      child: TextFormField(
                                        // validator: validator,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "(Contractor Name Cannot Be Empty)";
                                          }
                                        },
                                        enabled: false,
                                        controller: _contractorNameController,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0),
                                        decoration: InputDecoration(
                                          suffixIcon: const Icon(
                                            Icons.keyboard_arrow_down_sharp,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.all(10),
                                          border: InputBorder.none,
                                          hintText: 'Select Contractor Name',
                                          disabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Color(0xFF5F5C5C)),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: (Color(0xFF5F5C5C)),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: (Colors.red),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: (Color(0xFF5F5C5C)),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 110.0,
                                  // height: 40.0,
                                  child: Text('Work Complete',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          backgroundColor: Colors.white,
                                          fontSize: 15,
                                          color: Colors.black)),
                                ),
                                horizontalSpaceSmall,
                                Container(
                                  width: 160,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: TextFormField(
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d+\.?\d{0,2}')),
                                      ],
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "(Completed Work Cannot Be Empty)";
                                        } else if (value.isNotEmpty) {
                                          if (double.parse(value) == 0) {
                                            return "(Enter Greater than 0)";
                                          }
                                        }
                                      },
                                      // validator: validator,
                                      // enabled: false,
                                      controller: _workCompleteController,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 15.0),
                                      decoration: InputDecoration(
                                        // suffixIcon: const Icon(
                                        //   Icons.keyboard_arrow_down_sharp,
                                        // ),
                                        contentPadding:
                                            const EdgeInsets.all(10),
                                        border: InputBorder.none,
                                        hintText: 'Enter Completed Work',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Color(0xFF5F5C5C)),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: (Color(0xFF5F5C5C)),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: (Colors.red),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: (Color(0xFF5F5C5C)),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 40.0,
                                  // height: 40.0,
                                  child: Text('Unit',
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          backgroundColor: Colors.white,
                                          fontSize: 15,
                                          color: Colors.black)),
                                ),
                                InkWell(
                                  onTap: () {
                                    selectUnitModal();
                                  },
                                  child: Container(
                                    width: 160,
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: TextFormField(
                                      // validator: validator,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "(Unit Name Cannot Be Empty)";
                                        }
                                      },
                                      enabled: false,
                                      controller: _unitNameController,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 15.0),
                                      decoration: InputDecoration(
                                        suffixIcon: const Icon(
                                          Icons.keyboard_arrow_down_sharp,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.all(10),
                                        border: InputBorder.none,
                                        hintText: 'Unit Name',
                                        disabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Color(0xFF5F5C5C)),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: (Color(0xFF5F5C5C)),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: (Colors.red),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: (Color(0xFF5F5C5C)),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Text(
                                //     isFinishingConsumeDetailEdit == null
                                //         ? (widget.totalQty -
                                //                 widget.certifiedQty)
                                //             .toStringAsFixed(2)
                                //         : (widget.totalQty -
                                //                 widget.certifiedQty +
                                //                 double.parse(
                                //                     isFinishingConsumeDetailEdit
                                //                             ?.finishingConsumQty ??
                                //                         '0'))
                                //             .toStringAsFixed(2),
                                //     // '/ ${(double.parse(widget.finishingDetails?.boqQuantity ?? '0') - double.parse(widget.finishingDetails?.cetifyQuantity ?? '0')).toStringAsFixed(2)}',
                                //     style: TextStyle(
                                //         backgroundColor: Colors.white,
                                //         fontSize: 16,
                                //         color: Colors.black,
                                //         fontWeight: FontWeight.w600,
                                //         height: 2)),
                                // const SizedBox(width: 90),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 110.0,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 15.0),
                                    child: Text(
                                      'Remark',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10.0),
                                  width: 360,
                                  child: TextFormField(
                                    maxLines: 3,
                                    // validator: (value) {
                                    //   if (value!.isEmpty) {
                                    //     return "(Remark Cannot Be Empty)";
                                    //   }
                                    // },
                                    // validator: validator,
                                    // enabled: false,
                                    controller: _remarkController,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15.0),
                                    decoration: InputDecoration(
                                      // suffixIcon: const Icon(
                                      //   Icons.keyboard_arrow_down_sharp,
                                      // ),
                                      contentPadding: const EdgeInsets.all(10),
                                      border: InputBorder.none,
                                      hintText: 'Enter Remark',
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Color(0xFF5F5C5C)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: (Color(0xFF5F5C5C)),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: (Colors.red),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: (Color(0xFF5F5C5C)),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 110.0,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 15.0),
                                    child: Text(
                                      'Upload',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                uploadDocument(),
                              ],
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  if (
                                      // double.parse(
                                      // widget.finishingDetails?.finishingQty ?? '0')
                                      widget.totalQty - widget.certifiedQty <
                                              double.parse(
                                                  _workCompleteController
                                                      .text) &&
                                          isFinishingConsumeDetailEdit ==
                                              null) {
                                    exceedValueModal();
                                  } else if (isFinishingConsumeDetailEdit !=
                                          null &&
                                      (widget.totalQty -
                                              widget.certifiedQty +
                                              double.parse(
                                                  isFinishingConsumeDetailEdit
                                                          ?.finishingConsumQty ??
                                                      '0')) <
                                          double.parse(
                                              _workCompleteController.text)) {
                                    exceedValueModal();
                                  } else {
                                    setFinishing();
                                  }
                                }
                              },
                              child: Center(
                                child: Container(
                                  // margin: const EdgeInsets.only(left: 330, top: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.black,
                                  ),
                                  // padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: const Text('CERTIFY',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(
                          left: 20,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(color: Colors.black54),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "(2.) Quantity to Certify",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        )),
                  ],
                )
              ],
            ),
            const SizedBox(height: 40),
            Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  margin: const EdgeInsets.only(top: 13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black87),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.25,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black12),
                                left: BorderSide(color: Colors.black12),
                                top: BorderSide(color: Colors.black12),
                              ),
                            ),
                            child: const Text(
                              "Contractor Name",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.13,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black12),
                                left: BorderSide(color: Colors.black12),
                                top: BorderSide(color: Colors.black12),
                              ),
                            ),
                            child: const Text(
                              "Certified",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.13,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black12),
                                left: BorderSide(color: Colors.black12),
                                top: BorderSide(color: Colors.black12),
                              ),
                            ),
                            child: const Text(
                              "Remark",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.13,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black12),
                                left: BorderSide(color: Colors.black12),
                                top: BorderSide(color: Colors.black12),
                              ),
                            ),
                            child: const Text(
                              "Created By",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.1,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black12),
                                left: BorderSide(color: Colors.black12),
                                top: BorderSide(color: Colors.black12),
                              ),
                            ),
                            child: const Text(
                              "Completed At",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.1,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black12),
                                left: BorderSide(color: Colors.black12),
                                right: BorderSide(color: Colors.black12),
                                top: BorderSide(color: Colors.black12),
                              ),
                            ),
                            child: const Text(
                              "Action",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      for (int i = 0;
                          i < finishingConsumeDetailsData!.length;
                          i++)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.black12),
                                  left: BorderSide(color: Colors.black12),
                                ),
                              ),
                              child: Text(
                                finishingConsumeDetailsData?[i].companyName ??
                                    '',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.13,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.black12),
                                  left: BorderSide(color: Colors.black12),
                                ),
                              ),
                              child: Text(
                                '${finishingConsumeDetailsData?[i].finishingConsumQty} / ${widget.totalQty.toStringAsFixed(2)}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.13,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.black12),
                                  left: BorderSide(color: Colors.black12),
                                ),
                              ),
                              child: Text(
                                finishingConsumeDetailsData?[i]
                                        .finishingConsumRemark ??
                                    '',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.13,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.black12),
                                  left: BorderSide(color: Colors.black12),
                                ),
                              ),
                              child: Text(
                                finishingConsumeDetailsData?[i].userName ?? '',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.1,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.black12),
                                  left: BorderSide(color: Colors.black12),
                                ),
                              ),
                              child: Text(
                                DateFormat('dd-MM-yyyy').format(
                                    finishingConsumeDetailsData?[i]
                                            .finishingConsumCreatedAt ??
                                        DateTime.now()),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.1,
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.black12),
                                  left: BorderSide(color: Colors.black12),
                                  right: BorderSide(color: Colors.black12),
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    isFinishingConsumeDetailEdit =
                                        finishingConsumeDetailsData?[i];

                                    _contractorNameController.text =
                                        finishingConsumeDetailsData?[i]
                                                .companyName ??
                                            '';
                                    _workCompleteController.text =
                                        finishingConsumeDetailsData?[i]
                                                .finishingConsumQty ??
                                            '';
                                    _unitNameController.text =
                                        finishingConsumeDetailsData?[i]
                                                .unitName ??
                                            '';
                                    _remarkController.text =
                                        finishingConsumeDetailsData?[i]
                                                .finishingConsumRemark ??
                                            '';
                                    isSelectedContrctorListCompanyId =
                                        finishingConsumeDetailsData?[i]
                                                .companyIdFk ??
                                            '';
                                    isSelectedUnitListMstFinishingUnitId =
                                        finishingConsumeDetailsData?[i]
                                                .finishingConsumeUnitId ??
                                            '';
                                  });
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 3),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    "Edit/View",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(
                      left: 20,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "(3.) Past Certified",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget uploadDocument() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.35,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 10),
            InkWell(
              onTap: () async {
                // if (arrayFiles.length != 4) {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: [
                    'jpg',
                    'jpeg',
                    'png',
                    // "mp4",
                    "pdf",
                  ],
                );
                if (result != null) {
                  PlatformFile file = result.files.first;
                  Uint8List? fileBytes = result.files.first.bytes;
                  String fileName = result.files.first.name;
                  setState(() {
                    arrayFilesBytes.add(fileBytes);
                    arrayFiles.add(file);
                  });

                  //inspect(arrayFiles[0]);
                } else {
                  // User canceled the picker
                }
                // }
              },
              child: Image.asset(
                'images/projectmanagement/img5.png',
                height: 100,
                width: 100,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(width: 10),
            for (int j = 0; j < arrayFiles.length; j++)
              Row(
                children: [
                  arrayFiles[j].extension == 'jpg' ||
                          arrayFiles[j].extension == 'jpeg' ||
                          arrayFiles[j].extension == 'png'
                      ? Container(
                          padding: const EdgeInsets.only(right: 10),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Image.file(
                                File(arrayFiles[j].path ?? ''),
                                height: 100,
                                width: 100,
                                fit: BoxFit.fill,
                              ),
                              Positioned(
                                right: -10,
                                top: -10,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      arrayFiles.remove(arrayFiles[j]);
                                      arrayFilesBytes
                                          .remove(arrayFilesBytes[j]);
                                    });
                                  },
                                  child: const Icon(Icons.close),
                                ),
                              )
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.only(right: 10),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return PdfViewer(
                                          isLocalFileUpload: true,
                                          localFiles: arrayFiles[j].path,
                                          fileName: arrayFiles[j].name,
                                          fileUrl: arrayFiles[j].path,
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
                                  // width: 100,
                                  child: Image.asset(
                                    'images/projectmanagement/pdf.png',
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: -10,
                                top: -10,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      arrayFiles.remove(arrayFiles[j]);
                                      arrayFilesBytes
                                          .remove(arrayFilesBytes[j]);
                                    });
                                  },
                                  child: const Icon(Icons.close),
                                ),
                              )
                            ],
                          ),
                        ),
                ],
              ),
            // const SizedBox(width: 80),
            const SizedBox(width: 10),
            for (int i = 0;
                i <
                    (isFinishingConsumeDetailEdit?.documentList != null
                        ? isFinishingConsumeDetailEdit!.documentList!.length
                        : 0);
                i++)

              // for (int i = 0; i < dataa.documentList!.length; i++)
              isFinishingConsumeDetailEdit!.documentList![i].documentName!
                      .contains('.pdf')
                  ? Stack(
                      clipBehavior: Clip.none,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return PdfViewer(
                                    fileName: isFinishingConsumeDetailEdit!
                                        .documentList?[i].documentName,
                                    fileUrl:
                                        '${AppUrl.globalFinishingPath}${isFinishingConsumeDetailEdit!.documentList?[i].documentName}',
                                  );
                                },
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 10),
                                child: Image.asset(
                                  'images/projectmanagement/pdf.png',
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                              Container(
                                width: 80,
                                child: Text(
                                  isFinishingConsumeDetailEdit!
                                          .documentList?[i].documentName ??
                                      '',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: -10,
                          top: -10,
                          child: InkWell(
                            onTap: () {
                              // setState(() {
                              // arrayFiles.remove(arrayFiles[j]);
                              // arrayFilesBytes.remove(arrayFilesBytes[j]);
                              // });

                              deleteDocument(
                                  documentId: isFinishingConsumeDetailEdit!
                                          .documentList?[i].documentId ??
                                      '',
                                  dataa: isFinishingConsumeDetailEdit!
                                      .documentList![i]);
                            },
                            child: const Icon(Icons.close),
                          ),
                        )
                      ],
                    )
                  : Stack(
                      clipBehavior: Clip.none,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return ImagePreviewViewer(
                                    fileName: isFinishingConsumeDetailEdit!
                                        .documentList?[i].documentName,
                                    fileUrl:
                                        '${AppUrl.globalFinishingPath}${isFinishingConsumeDetailEdit!.documentList?[i].documentName}',
                                  );
                                },
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 10),
                                child: Image.network(
                                  '${AppUrl.globalFinishingPath}${isFinishingConsumeDetailEdit!.documentList?[i].documentName}',
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                              Container(
                                width: 80,
                                child: Text(
                                  isFinishingConsumeDetailEdit!
                                          .documentList?[i].documentName ??
                                      '',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: -10,
                          top: -10,
                          child: InkWell(
                            onTap: () {
                              // setState(() {
                              // arrayFiles.remove(arrayFiles[j]);
                              // arrayFilesBytes.remove(arrayFilesBytes[j]);
                              // });
                              deleteDocument(
                                  documentId: isFinishingConsumeDetailEdit!
                                          .documentList?[i].documentId ??
                                      '',
                                  dataa: isFinishingConsumeDetailEdit!
                                      .documentList![i]);
                            },
                            child: const Icon(Icons.close),
                          ),
                        )
                      ],
                    ),
          ],
        ),
      ),
    );
  }

  selectUnitModal() {
    return showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState1) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 10),
              actionsPadding: const EdgeInsets.only(bottom: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: const Text(
                'SELECT UNIT NAME',
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
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Center(
                      child: Text(
                        "CLOSE",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Center(
                      child: Text(
                        "ADD",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
              content: SizedBox(
                width: 500,
                height: 404,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 340,
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: finishingUnit?.length,
                            itemBuilder: (context, int indexFor) {
                              return InkWell(
                                onTap: () {
                                  setState1(() {
                                    _unitNameController.text =
                                        finishingUnit?[indexFor]
                                                .mstFinishingUnitName ??
                                            '';
                                    isSelectedUnitListMstFinishingUnitId =
                                        finishingUnit?[indexFor]
                                                .mstFinishingUnitId ??
                                            '';
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 13.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            finishingUnit?[indexFor]
                                                    .mstFinishingUnitName ??
                                                '',
                                            style: normalText,
                                          ),
                                          // slabDetails![indexFor].selected == '1'
                                          // true
                                          isSelectedUnitListMstFinishingUnitId ==
                                                  finishingUnit?[indexFor]
                                                      .mstFinishingUnitId
                                              ? const Icon(
                                                  Icons
                                                      .check_circle_outline_outlined,
                                                  size: 25,
                                                  color: Colors.green,
                                                )
                                              : const Icon(
                                                  Icons.circle_outlined,
                                                  size: 25,
                                                  color: Colors.grey,
                                                )
                                        ],
                                      ),
                                      verticalSpaceSmall,
                                      const Divider(
                                          height: 1.0, color: Colors.black),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  selectContractorModal() {
    return showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState1) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 10),
              actionsPadding: const EdgeInsets.only(bottom: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: const Text(
                'SELECT CONTRACTOR',
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
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Center(
                      child: Text(
                        "CLOSE",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Center(
                      child: Text(
                        "ADD",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
              content: SizedBox(
                width: 500,
                height: 404,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 340,
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: contrctorList?.length,
                            itemBuilder: (context, int indexFor) {
                              return InkWell(
                                onTap: () {
                                  setState1(() {
                                    _contractorNameController.text =
                                        contrctorList?[indexFor].companyName ??
                                            '';
                                    isSelectedContrctorListCompanyId =
                                        contrctorList?[indexFor].companyId;
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 13.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            contrctorList?[indexFor]
                                                    .companyName ??
                                                '',
                                            style: normalText,
                                          ),
                                          // slabDetails![indexFor].selected == '1'
                                          // true
                                          isSelectedContrctorListCompanyId ==
                                                  contrctorList?[indexFor]
                                                      .companyId
                                              ? const Icon(
                                                  Icons
                                                      .check_circle_outline_outlined,
                                                  size: 25,
                                                  color: Colors.green,
                                                )
                                              : const Icon(
                                                  Icons.circle_outlined,
                                                  size: 25,
                                                  color: Colors.grey,
                                                )
                                        ],
                                      ),
                                      verticalSpaceSmall,
                                      const Divider(
                                          height: 1.0, color: Colors.black),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  exceedValueModal() {
    return showDialog<void>(
        // barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Set radius to zero
            ),
            titlePadding: const EdgeInsets.symmetric(vertical: 10),
            actionsPadding: const EdgeInsets.only(bottom: 10),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            actionsAlignment: MainAxisAlignment.center,
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                isFinishingConsumeDetailEdit == null
                    ? 'Certified Value Cannot Exceed more than ${widget.totalQty - widget.certifiedQty}'
                    : 'Certified Value Cannot Exceed more than ${(widget.totalQty - widget.certifiedQty + double.parse(isFinishingConsumeDetailEdit?.finishingConsumQty ?? '0')).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            actions: [
              InkWell(
                onTap: () async {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 240,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(7)),
                  child: const Center(
                    child: Text(
                      "OKAY",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }
}
