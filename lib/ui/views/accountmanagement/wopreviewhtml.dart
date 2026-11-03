import 'package:stallion/ui/views/accountmanagement/account_management_preview.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_document.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_network.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_po_requistion_vendor_list.dart';
import 'package:stallion/models/get_project_wo_request.dart';
import 'package:stallion/models/wo_order_amend_pdf.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/utils/remove_temp_file.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../utils/api_network_call.dart';
import '../../../../utils/app_url.dart';
import '../../../models/get_wo_preview_html.dart';
import '../../../models/set_workorder_status.dart';
import '../../shared/ui_helpers.dart';
import '../../widgets/simple_button.dart';

class WoPreviewHtml extends StatefulWidget {
  const WoPreviewHtml({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.workOrderId,
    this.workOrderNo,
    this.flagRedirect,
    this.poAssingTo,
    this.arrPoDoc,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? workOrderId;
  final String? workOrderNo;
  final String? flagRedirect;
  final String? poAssingTo;
  final ArrWoDoc? arrPoDoc;

  @override
  State<WoPreviewHtml> createState() => _WoPreviewHtmlState();
}

class _WoPreviewHtmlState extends State<WoPreviewHtml> {
  bool isZoomed = false;

  String url = "";
  GlobalKey<FormState> _keyFormPOPup = GlobalKey<FormState>();
  List<AssingToList>? assingToList = [];
  String? purchaseUserTrack = '';
  String? kLocalExamplePage = '';
  TextEditingController remarkControler = TextEditingController();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  late PdfViewerController _pdfViewerController;

  bool flagcalled = false;
  String? filePath = '';
  String? fileName = '';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = AccountManagementPreviewNetwork();

  late BuildContext dialogContext;

  // String? strPoPdfPath = '';
  // String? strPoPdfFileName = '';
  String? authorizeFlag = '0';
  String selectedAssignToId = '';
  String searchText = '';
  List<AssingToList>? filteredAssignTo() {
    if (searchText.isEmpty) {
      return assingToList;
    }
    return assingToList!.where((project) {
      return project.transEmpName!
          .toLowerCase()
          .contains(searchText.toLowerCase());
    }).toList();
  }

  Future<AssingToList?> setWoAssignTo() async {
    CustomLoading.progressDialog(isLoading: true, context: context);
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
      "work_order_id": widget.workOrderId ?? '',
      "assign_to_id": selectedAssignToId,
    };

    var response = await apiNetworkHandler.post(AppUrl.webSetWoAssignTo, data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      CustomLoading.progressDialog(isLoading: false, context: context);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } else {
      CustomLoading.progressDialog(isLoading: false, context: context);
    }
    // return null;
  }

  chooseAssignToModal() {
    return showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context1, setState3) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 0),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 0),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  "Select Assign To",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: <Widget>[
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        print('----------------------');
                        Navigator.pop(context);
                        updateConfirmationModal();
                        // String temp = '';
                        // for (int i = 0; i < tenentList!.length; i++) {
                        //   if (tenentList?[i].isSelected == true) {
                        //     if (temp == "") {
                        //       temp = '${tenentList?[i].name}';
                        //     } else {
                        //       temp = '$temp, ${tenentList?[i].name}';
                        //     }
                        //   }
                        // }

                        // chooseTenantController.text = temp;
                      },
                      child: Container(
                        width: 460,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            // bottomRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'SUBMIT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // const SizedBox(width: 10),
                    // InkWell(
                    //   onTap: () {
                    //     // changeProjectPermissionAssign(
                    //     //     transProjectPerId: transProjectPerId,
                    //     //     assignTo: transEmpId);
                    //     // Navigator.pop(context);
                    //   },
                    //   child: Container(
                    //     width: 225,
                    //     padding: const EdgeInsets.symmetric(vertical: 8),
                    //     decoration: const BoxDecoration(
                    //       color: Colors.black,
                    //       borderRadius: BorderRadius.only(
                    //         bottomRight: Radius.circular(8),
                    //         // bottomLeft: Radius.circular(8),
                    //       ),
                    //     ),
                    //     child: const Text(
                    //       'Submit',
                    //       textAlign: TextAlign.center,
                    //       style: TextStyle(
                    //         fontSize: 18,
                    //         fontWeight: FontWeight.w600,
                    //         color: Colors.white,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                )
              ],
              content: SizedBox(
                height: 300,
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      TextFormField(
                        onChanged: (value) {
                          setState3(() {
                            searchText = value;
                          });
                        },
                        // validator: (value) {
                        //   if (value!.isEmpty) {
                        //     return "No. Of. Parking Cannot Be Empty";
                        //   }
                        //   return null;
                        // },
                        // controller: _workTypeController,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400),
                        decoration: InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black38),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: (Colors.black38),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: (Colors.black38),
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
                              color: (Colors.black38),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(12.0),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          hintText: 'Search',
                          hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 116, 116, 116),
                            fontSize: 13.0,
                            fontWeight: FontWeight.w200,
                            fontFamily: 'HelveticaNeue',
                          ),
                          // suffixIcon: Icon(
                          //   Icons.keyboard_arrow_down_rounded,
                          // ),
                        ),
                      ),
                      for (int i = 0; i < filteredAssignTo()!.length; i++)
                        InkWell(
                          onTap: () {
                            setState3(() {
                              selectedAssignToId =
                                  filteredAssignTo()?[i].transEmpId ?? '';
                              // if (filteredAssignTo()?[i].isSelected == true) {
                              //   filteredAssignTo()?[i].isSelected = false;
                              // } else {
                              //   filteredAssignTo()?[i].isSelected = true;
                              // }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                              color: Colors.grey,
                            ))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  filteredAssignTo()?[i].transEmpName ?? '',
                                  style: const TextStyle(
                                    fontSize: 19,
                                  ),
                                ),
                                Icon(
                                  // filteredAssignTo()?[i].isSelected == true
                                  selectedAssignToId ==
                                          filteredAssignTo()?[i].transEmpId
                                      ? Icons.check_circle_outline_outlined
                                      : Icons.circle_outlined,
                                  color:
                                      // filteredAssignTo()?[i].isSelected == true
                                      selectedAssignToId ==
                                              filteredAssignTo()?[i].transEmpId
                                          ? Colors.green
                                          : Colors.grey,
                                )
                              ],
                            ),
                          ),
                        ),
                      // Row(
                      //   children: [
                      //     Text(tenentList?[i].name ?? ''),
                      //   ],
                      // )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  Future<ResponseGetWoPreviewHtml?> wsworkorderpreview() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }
    Map<String, String> data = {
      "user_id": userId!,
      "wo_order_id": widget.workOrderId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "fluter": "1",
    };

    if (kDebugMode) {
      print(data);
    }
    var response =
        await apiNetworkHandler.post(AppUrl.getprojectwopreview, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getWoPreviewHtmlFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response!);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          assingToList = dataModel.response?.assingToList;
          purchaseUserTrack = dataModel.response?.workUserTrack;

          authorizeFlag = dataModel.response?.authorizeFlag;

          if (widget.arrPoDoc != null) {
            if (widget.arrPoDoc?.fileName != '' &&
                widget.arrPoDoc?.isPdf == "1") {
              filePath = widget.arrPoDoc!.filePath;
            } else {
              filePath =
                  '${dataModel.response?.filePath}/${dataModel.response?.fileName}';
            }
          } else {
            print('ArrPoDoc is null');
            filePath =
                '${dataModel.response?.filePath}/${dataModel.response?.fileName}';
          }
          flagcalled = true;
          kLocalExamplePage = dataModel.response?.woOrderHtml!;
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
    return null;
  }

  // Future<dynamic?> woOrderAmendPdf() async {
  //   final SharedPreferences prefs = await _prefs;

  //   Map<String, String> data = {
  //     "work_order_id": widget.workOrderId ?? '',
  //   };

  //   if (kDebugMode) {
  //     print(data);
  //   }
  //   var response = await apiNetworkHandler.post(AppUrl.woOrderAmendPdf, data);
  //   if (kDebugMode) {
  //     print(response.statusCode);
  //   }
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     final dataModel = woOrderAmendPdfFromJson(response.body);
  //     if (kDebugMode) {
  //       print(dataModel.response?.filePath);
  //     }
  //     if (dataModel.response?.errorCode == "0") {
  //       setState(() {
  //         filePath = dataModel.response?.filePath;
  //         //     fileName = dataModel.response?.filePath?.split('/').last;
  //       });
  //     }
  //   } else {
  //     if (kDebugMode) {
  //       print(response.body);
  //     }
  //     return null;
  //   }
  //   return null;
  // }

  late String _projId;
  late String _projName;

  Future<ResponseSetWorkOrderStatus?> wsWorkOrderSignDigitally() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "wo_order_id": widget.workOrderId!,
      "wo_status": '1',
      "order_status": '',
      "remark": '',
      "project_id": widget.projectId!,
      "towar_id": towerId,
    };

    if (kDebugMode) {
      print(data);
    }
    var response =
        await apiNetworkHandler.post(AppUrl.setprojectwostatus, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 504) {
      Navigator.pop(dialogContext);
      Navigator.maybePop(context);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getSetWorkOrderStatusFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response!);
      }
      if (dataModel.response?.errorCode == "0") {
        Future.delayed(Duration.zero).then((_) {
          Navigator.pop(dialogContext);
          Navigator.maybePop(context);

          showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: const Text(''),
                    content: const Text('Work order issued successfully.',
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
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ],
                  ));
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
    return null;
  }

  Future<ResponseSetWorkOrderStatus?> wsWorkOrderReject() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "wo_order_id": widget.workOrderId!,
      "wo_status": '2',
      "order_status": '',
      "remark": remarkControler.text,
      "project_id": widget.projectId!,
      "towar_id": towerId,
    };

    if (kDebugMode) {
      print(data);
    }
    var response =
        await apiNetworkHandler.post(AppUrl.setprojectwostatus, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getSetWorkOrderStatusFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response!);
      }
      if (dataModel.response?.errorCode == "0") {
        Future.delayed(Duration.zero).then((_) {
          context.loaderOverlay.hide();
          showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: const Text(''),
                    content: const Text('Work order rejected successfully.',
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
                          Navigator.pop(context);
                          Navigator.maybePop(context);
                        },
                      ),
                    ],
                  ));
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();

    _projId = widget.projectId!;
    _projName = widget.projectName!;

    wsworkorderpreview();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
            '${widget.projectName!.toUpperCase()} - ${widget.workOrderNo!}',
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        actions: <Widget>[
          widget.flagRedirect == 'Issued' || widget.flagRedirect == "project"
              ? IconButton(
                  icon: const Icon(Icons.download, color: Colors.white),
                  onPressed: () {
                    //shareFile(widget.fileName);
                    //Save single pdf file
                    _launchURL();
                  },
                )
              : const SizedBox(),
          const SizedBox(
            width: 20,
          ),
          IconButton(
            icon: const Icon(
              Icons.zoom_in,
              color: Colors.white,
              size: 35,
            ),
            onPressed: () {
              // _pdfViewerController.zoomLevel = 2;
              setState(() {
                isZoomed = !isZoomed;
              });
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
              // _pdfViewerController.zoomLevel = 0;
              setState(() {
                isZoomed = !isZoomed;
              });
            },
          ),
          const SizedBox(
            width: 50,
          )
        ],
      ),
      bottomNavigationBar: Container(
        child: widget.flagRedirect == 'Assigned' && authorizeFlag == '1'
            ? Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    horizontalSpaceSmall,
                    Flexible(
                      child: SimpleButton(
                        lblText: 'REJECT WORK ORDER',
                        color: kcPrimaryColor,
                        onTap: () {
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: const Text(''),
                                    // content: const Text(
                                    //     'Are you sure you want to reject this work order?',
                                    //     style: TextStyle(
                                    //         fontStyle: FontStyle
                                    //             .normal,
                                    //         fontSize: 17.0)),

                                    content: Form(
                                      key: _keyFormPOPup,
                                      child: SizedBox(
                                        height: 104,
                                        child: Column(
                                          children: [
                                            const Text(
                                                'Are you sure you want to reject this work order?',
                                                style: TextStyle(
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: 17.0)),
                                            const SizedBox(height: 8),
                                            TextFormField(
                                              controller: remarkControler,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13.0),
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.all(12.0),
                                                border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.black)),
                                                hintText: 'Please Enter Remark',
                                                hintStyle: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 116, 116, 116),
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.w200,
                                                  fontFamily: 'HelveticaNeue',
                                                ),
                                                // suffixIcon: Icon(
                                                //   Icons.calendar_month_outlined,
                                                // ),
                                              ),
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return "(Remark Cannot Be Empty)";
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
                                                fontSize: 14.0,
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
                                          if (_keyFormPOPup.currentState!
                                              .validate()) {
                                            Navigator.pop(context);
                                            context.loaderOverlay.show();
                                            wsWorkOrderReject();
                                          }
                                        },
                                      ),
                                    ],
                                  ));
                        },
                      ),
                    ),
                    horizontalSpaceSmall,
                    Flexible(
                      child: SimpleButton(
                        lblText: 'SIGN WORK ORDER DIGITALLY',
                        color: kcPrimaryColor,
                        onTap: () {
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: const Text(''),
                                    content: const Text(
                                        'Are you sure you want to issue this work order?',
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
                                                fontSize: 14.0,
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
                                          Navigator.pop(context);
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              dialogContext = context;
                                              return const Center(
                                                child: SizedBox(
                                                  height: 200,
                                                  width: 200,
                                                  child: Dialog(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
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
                                          wsWorkOrderSignDigitally();
                                        },
                                      ),
                                    ],
                                  ));
                        },
                      ),
                    ),
                    horizontalSpaceSmall,
                  ],
                ),
              )
            : widget.flagRedirect == "Requested"
                ? InkWell(
                    onTap: () {
                      if (
                          // (widget.poAssingTo == "0" ||
                          //       widget.poAssingTo == "") &&
                          purchaseUserTrack != '0') {
                        chooseAssignToModal();
                      }
                    },
                    child: Container(
                      width: double.maxFinite,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      color:
                          //(widget?.poAssingTo == "0" ||
                          //             widget?.poAssingTo == "") &&
                          purchaseUserTrack != '0' ? Colors.black : Colors.grey,
                      child: Text(
                        "ASSIGN TO",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  )
                : SizedBox(),
      ),
      backgroundColor: Colors.white70,

      body: filePath != ''
          ? Center(
              child: Container(
                width: isZoomed ? 940 : 700,
                child: (useAccountManagementTestData
                    ? const AccountManagementPreviewDocument()
                    : SfPdfViewer.network(
                        // pageLayoutMode:
                        //     PdfPageLayoutMode.single, // Ensures proper layout

                        onDocumentLoaded: (details) {
                          // if (fileName?.trim() != '') {
                          //   RemoveTempFile()
                          //       .removeRecentTempFile(fileName: fileName ?? '');
                          // }
                        },
                        initialZoomLevel: 0.75,
                        enableDoubleTapZooming: true,
                        filePath ?? '',
                        // strPoPdfPath ?? '',
                        // 'https://skrite.com/stallion-build-test//media/backend/images/temporary-docs/20240307025504.pdf',
                        key: _pdfViewerKey,
                        controller: _pdfViewerController,
                      )),
              ),
            )
          : Center(
              child: SizedBox(
                height: 64,
                child: OverflowBox(
                  minHeight: 100,
                  maxHeight: 100,
                  child: Lottie.asset(
                    'assets/animation/running2.json',
                    // 'assets/animation/chatbotfinallotiie.json',
                    repeat: true,
                  ),
                ),
              ),
            ),
      // const Center(child: CircularProgressIndicator()),
    );
  }

  _launchURL() async {
    if (useAccountManagementTestData) return;
    print(filePath);
    if (filePath != "") {
      final uri = Uri.parse(filePath ?? '');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch';
      }
    }
  }

  updateConfirmationModal() {
    return showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context1, setState2) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 0),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 0),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  "Are you sure you want to assign this WO?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: <Widget>[
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 170,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            // bottomRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'NO',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        setWoAssignTo();
                      },
                      child: Container(
                        width: 170,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(8),
                            // bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'YES',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
              // content: SizedBox(
              //   height: 300,
              //   width: 400,
              // ),
            );
          });
        });
  }
}
