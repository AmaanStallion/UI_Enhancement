import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/finishing_flat_listing.dart';
// import 'package:stallion/models/finishing_flat_listing.dart';
import 'package:stallion/models/finishing_listing.dart';
import 'package:stallion/models/finishing_qty_list.dart';
import 'package:stallion/models/get_finishing_interior_new.dart';
// import 'package:stallion/models/get_project_dpr_contractor.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AddFinishingWork extends StatefulWidget {
  const AddFinishingWork(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      // required this.slabName,
      this.finishingListData,
      this.towarName,
      this.floorId,
      this.floorName,
      this.finishingDetails,
      this.title,
      required this.isInterior,
      this.flatDetailsListSelected})
      : super(key: key);
  final String? projectId;
  final String? towarId;
  final String? floorId;
  final String? floorName;
  final String? title;

  final String? projectName;
  final String? towarName;
  // final String? slabName;
  final FinishingList? finishingListData;
  final FlatDetail? flatDetailsListSelected;
  final BodyPart? finishingDetails;
  final String isInterior;
  @override
  State<AddFinishingWork> createState() => _AddFinishingWorkState();
}

class _AddFinishingWorkState extends State<AddFinishingWork> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _unitNameController = TextEditingController();
  List<FinishingUnit>? finishingUnit = [];
  FinishingUnit? isSelectedUnitList;

  List<PlatformFile> arrayFiles = [];
  List<Uint8List?> arrayFilesBytes = [];
  List<CompanyDetail>? contrctorList = [];
  CompanyDetail? isSelectedContrctorList;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController _contractorNameController = TextEditingController();
  TextEditingController _workCompleteController = TextEditingController();

  TextEditingController _remarkController = TextEditingController();

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
    request.fields["finishing_id"] = widget.finishingDetails?.id ?? '';
    request.fields["floor_id"] = widget.floorId ?? '';
    request.fields["company_id"] = isSelectedContrctorList?.companyId ?? '';
    request.fields["remark"] = _remarkController.text;
    request.fields["quantity"] = _workCompleteController.text;
    request.fields["unit_id"] = isSelectedUnitList?.mstFinishingUnitId ?? '';

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
    inspect(request.fields);
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
        widget.finishingDetails?.consumeQty =
            (double.parse(widget.finishingDetails?.consumeQty ?? '') +
                    double.parse(_workCompleteController.text))
                .toString();
        arrayFiles = [];
        arrayFilesBytes = [];
        isSelectedContrctorList = null;
        _contractorNameController.clear();
        _workCompleteController.clear();
        _remarkController.clear();
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

  // Future<ResponseGetProjectDprContractor?> getFinishingCompanyList() async {
  //   // String formatDate(DateTime dateTime) {
  //   //   // String formattedDate =
  //   //   //     DateFormat('yyyy-MM-dd HH:mm:ss').format(originalDate);
  //   //   // return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  //   //   return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  //   // }

  //   final SharedPreferences prefs = await _prefs;
  //   String? userId = prefs.getString('mobileNo');

  //   Map<String, String> data = {
  //     "towar_id": widget.towarId ?? '',
  //     "project_id": widget.projectId ?? '',
  //     "user_id": userId ?? '',
  //     "finishing_type": widget.isInterior,
  //     "finishing_id": widget.finishingDetails?.id ?? '',
  //     // 'slab_id': widget.slabId ?? '',
  //   };

  //   if (kDebugMode) {
  //     print(data);
  //   }

  //   var response =
  //       await apiNetworkHandler.post(AppUrl.getFinishingCompanyList, data);

  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     final dataModel = getProjectDprContractorFromJson(response.body);

  //     if (dataModel.response?.errorCode == "0") {
  //       setState(() {
  //         // responseGetProjectDprContractor = dataModel.response;
  //         contrctorList = dataModel.response?.contrctorList;
  //         // customType = dataModel.response?.customType;
  //         // orderDeliveredListResponse = dataModel.response?.orderDeliveredList;
  //         // dprYesterdayActivity = dataModel.response?.dprYesterdayActivity;
  //         //   projctDprListResponse = dataModel.response?.projctDprList;
  //         //   offset = dataModel.response?.offset ?? '';
  //         //   responseWebService = dataModel.response;
  //       });
  //     } else {}
  //   }
  //   return null;
  // }

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
        "finishing_id": widget.finishingDetails?.id ?? '',
        "floor_id": widget.finishingDetails?.floorId ?? '',
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

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getFinishingList();
      // getFinishingCompanyList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    inspect(widget.finishingDetails);
    return Scaffold(
      // bottomNavigationBar: Container(
      //   color: Colors.black,
      //   padding: const EdgeInsets.symmetric(vertical: 10),
      //   child: const Text('SUBMIT',
      //       style: TextStyle(
      //         fontSize: 15,
      //         fontWeight: FontWeight.w500,
      //         color: Colors.white,
      //       ),
      //       textAlign: TextAlign.center),
      // ),
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
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(
            //   height: 40,
            //   child: Row(
            //     children: [
            //       SizedBox(width: 200),
            //       Spacer(),
            //       Text('FINISHING - ${widget.slabName}',
            //           style: TextStyle(
            //             fontSize: 15,
            //             fontWeight: FontWeight.w500,
            //           ),
            //           textAlign: TextAlign.center),
            //       Spacer(),
            //       Text('',
            //           style: TextStyle(
            //               backgroundColor: Colors.white,
            //               fontSize: 16,
            //               color: Colors.black,
            //               fontWeight: FontWeight.w600,
            //               height: 2)),
            //       SizedBox(width: 90),
            //     ],
            //   ),
            // ),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                    'INTERIOR FINISHING - ${widget.floorName?.toUpperCase()}',
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
            const SizedBox(height: 14),
            Row(
              children: [
                const SizedBox(width: 80),
                SizedBox(
                  // width: 230.0,
                  height: 52.0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Text(widget.title ?? '',
                        style: const TextStyle(
                            backgroundColor: Colors.white,
                            fontSize: 15,
                            color: Colors.black)),
                  ),
                ),
                horizontalSpaceSmall,
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Text(
                        // '',
                        '(${double.parse(widget.finishingDetails?.consumeQty ?? '0').toStringAsFixed(2)} / ${widget.finishingDetails?.finishingQty} ) - Remaining  ',

                        // '(${widget.finishingListData?.consumQty} ${widget.finishingListData?.unitName} / ${widget.finishingListData?.totalQty} ${widget.finishingListData?.unitName} ) - Remaining ${widget.finishingListData?.remaingQty} ${widget.finishingListData?.unitName} ',
                        // 'iNTERNAL - 500 Sq.Ft (Completed 400 Sq.Ft) Remaining 100 Sq.Ft',
                        style: const TextStyle(
                            backgroundColor: Colors.white,
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            height: 2)),
                  ),
                ),
                const SizedBox(width: 80),
              ],
            ),
            const SizedBox(height: 10),
            // remarkWidget(),
            percentageCompleteWidget(),
            const SizedBox(height: 14),
            // percentageCompleteWidget(),
            remarkWidget(),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 80),
              child: Text("Upload Documents", style: TextStyle(fontSize: 14)),
            ), //
            uploadDocument(),

            InkWell(
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  if (
                      // double.parse(
                      // widget.finishingDetails?.finishingQty ?? '0')
                      double.parse(widget.finishingDetails?.finishingQty ??
                                  '0') -
                              double.parse(
                                  widget.finishingDetails?.consumeQty ?? '0') <
                          double.parse(_workCompleteController.text)) {
                    exceedValueModal();
                  } else {
                    setFinishing();
                  }
                }
              },
              child: Center(
                child: Container(
                  // margin: const EdgeInsets.only(left: 330, top: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
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
            const Divider(),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: finishingConsumeDetailsData?.length ?? 0,
                itemBuilder: (context, index) {
                  return indCard(dataa: finishingConsumeDetailsData![index]);
                },
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget remarkWidget() {
    return Row(
      children: [
        const SizedBox(width: 80),
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Remark',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: TextFormField(
              // validator: (value) {
              //   if (value!.isEmpty) {
              //     return "(Remark Cannot Be Empty)";
              //   }
              // },
              // validator: validator,
              // enabled: false,
              controller: _remarkController,
              style: const TextStyle(color: Colors.black, fontSize: 15.0),
              decoration: InputDecoration(
                // suffixIcon: const Icon(
                //   Icons.keyboard_arrow_down_sharp,
                // ),
                contentPadding: const EdgeInsets.all(10),
                border: InputBorder.none,
                hintText: 'Enter Remark',
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF5F5C5C)),
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
        ),
        const SizedBox(width: 80),
      ],
    );
  }

  Widget percentageCompleteWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 80),
        const SizedBox(
          width: 240.0,
          // height: 40.0,
          child: Text('Contractor Name',
              // textAlign: TextAlign.center,
              style: TextStyle(
                  backgroundColor: Colors.white,
                  fontSize: 15,
                  color: Colors.black)),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              selectContractorModal();
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: TextFormField(
                // validator: validator,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "(Contractor Name Cannot Be Empty)";
                  }
                },
                enabled: false,
                controller: _contractorNameController,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: InputDecoration(
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down_sharp,
                  ),
                  contentPadding: const EdgeInsets.all(10),
                  border: InputBorder.none,
                  hintText: 'Contractor Name',
                  disabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF5F5C5C)),
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
          ),
        ),
        const SizedBox(width: 10),
        const SizedBox(
          width: 40.0,
          // height: 40.0,
          child: Text('Unit',
              // textAlign: TextAlign.center,
              style: TextStyle(
                  backgroundColor: Colors.white,
                  fontSize: 15,
                  color: Colors.black)),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              selectUnitModal();
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: TextFormField(
                // validator: validator,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "(Unit Name Cannot Be Empty)";
                  }
                },
                enabled: false,
                controller: _unitNameController,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: InputDecoration(
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down_sharp,
                  ),
                  contentPadding: const EdgeInsets.all(10),
                  border: InputBorder.none,
                  hintText: 'Unit Name',
                  disabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF5F5C5C)),
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
          ),
        ),

        const SizedBox(
          width: 110.0,
          // height: 40.0,
          child: Text('Work Complete',
              textAlign: TextAlign.end,
              style: TextStyle(
                  backgroundColor: Colors.white,
                  fontSize: 15,
                  color: Colors.black)),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: TextFormField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value!.isEmpty) {
                  return "(Completed Work Cannot Be Empty)";
                }
              },
              // validator: validator,
              // enabled: false,
              controller: _workCompleteController,
              style: const TextStyle(color: Colors.black, fontSize: 15.0),
              decoration: InputDecoration(
                // suffixIcon: const Icon(
                //   Icons.keyboard_arrow_down_sharp,
                // ),
                contentPadding: const EdgeInsets.all(10),
                border: InputBorder.none,
                hintText: 'Completed Work',
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF5F5C5C)),
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
        ),
        // Text('/',
        //     style: TextStyle(
        //         backgroundColor: Colors.white,
        //         fontSize: 34,
        //         color: Colors.black,
        //         // fontWeight: FontWeight.w600,
        //         height: 1)),
        Text(
            // '/ ${widget.finishingDetails?.finishingQty}', //widget.finishingDetails?.consumeQty} / ${widget.finishingDetails?.finishingQty
            '/ ${(double.parse(widget.finishingDetails?.finishingQty ?? '0') - double.parse(widget.finishingDetails?.consumeQty ?? '0')).toStringAsFixed(2)}',
            style: const TextStyle(
                backgroundColor: Colors.white,
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                height: 2)),
        const SizedBox(width: 90),
      ],
    );
  }

  Widget uploadDocument() {
    return Row(
      children: [
        const SizedBox(width: 80),
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
                                  arrayFilesBytes.remove(arrayFilesBytes[j]);
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
                                  arrayFilesBytes.remove(arrayFilesBytes[j]);
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
        const SizedBox(width: 80),
      ],
    );
  }

  Widget indCard({required FinishingConsumeDetail dataa}) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 80),
            const SizedBox(
              width: 220.0,
              child: Text('Contractor Name',
                  style: TextStyle(
                      backgroundColor: Colors.white,
                      fontSize: 15,
                      color: Colors.black)),
            ),
            horizontalSpaceSmall,
            Expanded(child: Text('-     ${dataa.companyName}')),
            const SizedBox(width: 80),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const SizedBox(width: 80),
            const SizedBox(
              width: 220.0,
              child: Text('Completed Work',
                  style: TextStyle(
                      backgroundColor: Colors.white,
                      fontSize: 15,
                      color: Colors.black)),
            ),
            horizontalSpaceSmall,
            Expanded(child: Text('-     ${dataa.finishingConsumQty}')),
            const SizedBox(width: 80),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const SizedBox(width: 80),
            const SizedBox(
              width: 220.0,
              child: Text('Unit.',
                  style: TextStyle(
                      backgroundColor: Colors.white,
                      fontSize: 15,
                      color: Colors.black)),
            ),
            horizontalSpaceSmall,
            Expanded(child: Text('-     ${dataa.unitName}')),
            const SizedBox(width: 80),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const SizedBox(width: 80),
            const SizedBox(
              width: 220.0,
              child: Text('Certified by',
                  style: TextStyle(
                      backgroundColor: Colors.white,
                      fontSize: 15,
                      color: Colors.black)),
            ),
            horizontalSpaceSmall,
            Expanded(
                child: Row(
              children: [
                Text('-     ${dataa.userName}'),
                const Spacer(),
                if (dataa.documentList?.length != 0)
                  InkWell(
                    onTap: () {
                      viewDocsModal(dataa: dataa);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black),
                      ),
                      child: const Text('View Documents'),
                    ),
                  ),
              ],
            )),
            const SizedBox(width: 80),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const SizedBox(width: 80),
            const SizedBox(
              width: 220.0,
              child: Text('Certified Date',
                  style: TextStyle(
                      backgroundColor: Colors.white,
                      fontSize: 15,
                      color: Colors.black)),
            ),
            horizontalSpaceSmall,
            Expanded(
                child: Text(
                    '-     ${DateFormat('dd-MM-yyyy').format(dataa.finishingConsumCreatedAt ?? DateTime.now())}')),
            const SizedBox(width: 80),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const SizedBox(width: 80),
            const SizedBox(
              width: 220.0,
              child: Text('Remark',
                  style: TextStyle(
                      backgroundColor: Colors.white,
                      fontSize: 15,
                      color: Colors.black)),
            ),
            horizontalSpaceSmall,
            Expanded(child: Text('-     ${dataa.finishingConsumRemark}')),
            const SizedBox(width: 80),
          ],
        ),
        // SizedBox(height: 14),
        // Row(
        //   children: [
        //     SizedBox(width: 80),
        //     SizedBox(
        //       width: 230.0,
        //       child: Text('Documents',
        //           style: TextStyle(
        //               backgroundColor: Colors.white,
        //               fontSize: 15,
        //               color: Colors.black)),
        //     ),
        //     horizontalSpaceSmall,
        //     Expanded(
        //         child: SingleChildScrollView(
        //       scrollDirection: Axis.horizontal,
        //       child: Row(
        //         children: [
        //           for (int i = 0; i < dataa.documentList!.length; i++)
        //             dataa.documentList![i].documentName!.contains('.pdf')
        //                 ? InkWell(
        //                     onTap: () {
        //                       Navigator.push(
        //                         context,
        //                         MaterialPageRoute(
        //                           builder: (_) {
        //                             return PdfViewer(
        //                               fileName:
        //                                   dataa.documentList?[i].documentName,
        //                               fileUrl:
        //                                   '${AppUrl.globalFinishingPath}${dataa.documentList?[i].documentName}',
        //                             );
        //                           },
        //                         ),
        //                       );
        //                     },
        //                     child: Container(
        //                       padding: EdgeInsets.only(right: 10),
        //                       child: Image.asset(
        //                         'images/projectmanagement/pdf.png',
        //                         width: 100,
        //                         height: 100,
        //                       ),
        //                     ),
        //                   )
        //                 : InkWell(
        //                     onTap: () {
        //                       Navigator.push(
        //                         context,
        //                         MaterialPageRoute(
        //                           builder: (_) {
        //                             return ImagePreviewViewer(
        //                               fileName:
        //                                   dataa.documentList?[i].documentName,
        //                               fileUrl:
        //                                   '${AppUrl.globalFinishingPath}${dataa.documentList?[i].documentName}',
        //                             );
        //                           },
        //                         ),
        //                       );
        //                     },
        //                     child: Container(
        //                       padding: EdgeInsets.only(right: 10),
        //                       child: Image.network(
        //                         '${AppUrl.globalFinishingPath}${dataa.documentList?[i].documentName}',
        //                         width: 100,
        //                         height: 100,
        //                       ),
        //                     ),
        //                   )
        //           // Container(
        //           //   width: 50,
        //           //   height: 50,
        //           //   // decoration: BoxDecoration(
        //           //   //     border: Border.all(
        //           //   //   color: Colors.black,
        //           //   // )),
        //           //   // padding: const EdgeInsets.symmetric(horizontal: 80),
        //           //   child: InkWell(
        //           //     onTap: () {
        //           // Navigator.push(
        //           //   context,
        //           //   MaterialPageRoute(
        //           //     builder: (_) {
        //           //       return ImagePreviewViewer(
        //           //         fileName: dataa.documentList?[i].documentName,
        //           //         fileUrl:
        //           //             '$pathData/${dataa.documentList?[i].documentName}',
        //           //       );
        //           //     },
        //           //   ),
        //           //       );
        //           //     },
        //           //     child: Container(
        //           //       decoration: BoxDecoration(
        //           //           border: Border.all(
        //           //             color: Colors.black,
        //           //           ),
        //           //           borderRadius: BorderRadius.circular(8)),
        //           //       margin: const EdgeInsets.only(right: 20),
        //           //       padding: const EdgeInsets.all(8),
        //           //       child: Image.network(
        //           //         '$pathData/${dataa.documentList?[i].documentName}',
        //           //         width: 100,
        //           //         height: 100,
        //           //         fit: BoxFit.cover,
        //           //       ),
        //           //     ),
        //           //   ),
        //           // ),
        //         ],
        //       ),
        //     )),
        //     SizedBox(width: 80),
        //   ],
        // ),
      ],
    );
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
                        height: 390,
                        child: contrctorList?.length != 0
                            ? ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: contrctorList?.length,
                                itemBuilder: (context, int indexFor) {
                                  return InkWell(
                                    onTap: () {
                                      setState1(() {
                                        _contractorNameController.text =
                                            contrctorList?[indexFor]
                                                    .companyName ??
                                                '';
                                        isSelectedContrctorList =
                                            contrctorList?[indexFor];
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
                                              isSelectedContrctorList
                                                          ?.companyId ==
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
                                })
                            : const Center(
                                child: Text(
                                  "No Record Found",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
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
                                    isSelectedUnitList =
                                        finishingUnit?[indexFor];
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
                                          isSelectedUnitList
                                                      ?.mstFinishingUnitId ==
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
                'Certified Value Cannot Exceed more than ${double.parse(widget.finishingDetails?.finishingQty ?? '0') - double.parse(widget.finishingDetails?.consumeQty ?? '0')}',
                style: const TextStyle(
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

  viewDocsModal({required FinishingConsumeDetail dataa}) {
    return showDialog<void>(
        // barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Set radius to zero
            ),
            titlePadding: const EdgeInsets.symmetric(vertical: 0),
            actionsPadding: const EdgeInsets.only(bottom: 10),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            actionsAlignment: MainAxisAlignment.center,
            title: Container(
              decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  )),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: const Text(
                'VIEW DOCUMENTS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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
                  width: 450,
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
            content: Container(
              height: 300,
              width: 450,
              padding: const EdgeInsets.only(top: 10),
              child: SingleChildScrollView(
                child: Wrap(
                  runSpacing: 20,
                  children: [
                    for (int i = 0; i < dataa.documentList!.length; i++)
                      dataa.documentList![i].documentName!.contains('.pdf')
                          ? InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return PdfViewer(
                                        fileName:
                                            dataa.documentList?[i].documentName,
                                        fileUrl:
                                            '${AppUrl.globalFinishingPath}${dataa.documentList?[i].documentName}',
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Image.asset(
                                      'images/projectmanagement/pdf.png',
                                      width: 100,
                                      height: 100,
                                    ),
                                  ),
                                  Container(
                                    width: 100,
                                    child: Text(
                                      dataa.documentList?[i].documentName ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return ImagePreviewViewer(
                                        fileName:
                                            dataa.documentList?[i].documentName,
                                        fileUrl:
                                            '${AppUrl.globalFinishingPath}${dataa.documentList?[i].documentName}',
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Image.network(
                                      '${AppUrl.globalFinishingPath}${dataa.documentList?[i].documentName}',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    width: 100,
                                    child: Text(
                                      dataa.documentList?[i].documentName ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
