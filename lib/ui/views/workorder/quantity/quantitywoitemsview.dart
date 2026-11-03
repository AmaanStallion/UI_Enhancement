import 'dart:convert';
import 'dart:developer';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/workorder/quantity/quantityworeviewview.dart';
import 'package:stallion/ui/widgets/border_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/add_custom_unit.dart';
import '../../../../models/get_default_qorkorder_qty_create.dart';
import '../../../../utils/api_network_call.dart';
import '../../../../utils/app_url.dart';
import '../../../shared/ui_helpers.dart';
import '../../../widgets/simple_button.dart';
import 'package:http/http.dart' as http;

class QuantityWoItemsView extends StatefulWidget {
  QuantityWoItemsView(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.selectedConsultantType,
      this.selectedConsultantCompany,
      this.inputRequirementFor,
      this.selectedRequirementDate,
      this.inputNote,
      this.selectedGST,
      required this.arrayFiles,
      this.gradeUnit,
      this.towarName,
      this.strGradeId,
      this.consultantMagicLink,
      this.contractorMagicLink,
      this.vendMagicLink,
      this.navigationFlag});

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? navigationFlag;
  final String? contractorMagicLink;
  final String? vendMagicLink;
  final String? consultantMagicLink;
  String? strGradeId;
  String? selectedConsultantType;
  String? selectedConsultantCompany;
  String? inputRequirementFor;
  String? selectedRequirementDate;
  String? inputNote;
  String? selectedGST;
  final String? towarName;
  var arrayFiles = [];
  List<GradeUnit>? gradeUnit = [];

  @override
  State<QuantityWoItemsView> createState() => _QuantityWoItemsViewState();
}

class _QuantityWoItemsViewState extends State<QuantityWoItemsView> {
  GlobalKey<FormState> _keyFormPOPup = GlobalKey<FormState>();
  GlobalKey<FormState> _keyAddCustomFormPOPup = GlobalKey<FormState>();

  GradeUnit? selectedGradeUnit = null;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  String searchText = '';
  List<GradeUnit>? filteredProjects() {
    if (searchText.isEmpty) {
      return widget.gradeUnit!;
    }
    return widget.gradeUnit!.where((project) {
      return project.unitName!.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
  }

  String? selectedUnitType;
  String? selectedUnitId;
  var selectedRow = 0;

  List<QtyWoItems?> arrayList = [];
  List<DropdownMenuItem> unitItems = [];

  QtyWoItems dataList = QtyWoItems(
      woUnit: "",
      castingUnit: "",
      woQuantity: "",
      woUnitPrice: "",
      totalAmount: "",
      woCastingFor: "",
      id: "0",
      controllerText: TextEditingController(),
      selectedUnitId: '');
  List<TextEditingController> _txtControllerDescription = [];
  List<TextEditingController> _txtControllerQuantity = [];
  List<TextEditingController> _txtControllerUnitPrice = [];
  List<TextEditingController> _txtControllerTotalPrice = [];

  TextEditingController _textFieldController = TextEditingController();
  Future<void> _displayTextInputDialog(
      {required BuildContext context, required int selectedInd}) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Custom Unit'),
            content: Form(
              key: _keyAddCustomFormPOPup,
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    valueText = value;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "(Custom Unit Cannot Be Empty)";
                  } else {
                    for (int f = 0; f < widget.gradeUnit!.length; f++) {
                      print(widget.gradeUnit?[f].unitName);
                      if (widget.gradeUnit?[f].unitName?.toLowerCase() ==
                          value.toLowerCase()) {
                        print('object--');

                        return "(Unit Already Exist)";
                      }
                    }
                  }
                },
                controller: _textFieldController,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  border: InputBorder.none,
                  hintText: 'Enter custom unit',
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
                // decoration: const InputDecoration(hintText: "Enter custom unit"),
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    fixedSize: const Size.fromWidth(100),
                    padding: const EdgeInsets.all(10),
                    textStyle: const TextStyle(color: Colors.white)),
                child: const Text('CANCEL',
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
                    fixedSize: const Size.fromWidth(100),
                    padding: const EdgeInsets.all(10),
                    textStyle: const TextStyle(color: Colors.white)),
                child: const Text('ADD UNIT',
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0,
                        color: Colors.white)),
                onPressed: () {
                  if (_keyAddCustomFormPOPup.currentState!.validate()) {
                    setState(() {
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
                                  mainAxisAlignment: MainAxisAlignment.center,
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

                      submitAddCustomUnit(selectedInd: selectedInd);
                    });
                  }
                },
              ),
            ],
          );
        });
  }

  String? valueText;
  late BuildContext dialogContext;

  Future<ResponseAddCustomUnit?> submitAddCustomUnit({
    required int selectedInd,
  }) async {
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
      "grade_id": widget.strGradeId!,
      "unit_name": valueText!,
      "type_grade": "1"
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.webServiceForAddCustomUnit, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = addCustomUnitFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        Future.delayed(Duration.zero).then((_) {
          Navigator.pop(dialogContext);

          if (dataModel.response?.gradeUnit! != null) {
            setState(() {
              widget.gradeUnit = dataModel.response?.gradeUnit;
              // arrayList[index]!.selectedUnitId = filteredProjects()![ind].unitId;
              arrayList[selectedInd]!.controllerText?.text = valueText ?? '';
              arrayList[selectedInd]!.woUnit = valueText ?? '';
            });
            for (int k = 0; k < dataModel.response!.gradeUnit!.length; k++) {
              if (dataModel.response!.gradeUnit?[k].unitName == valueText) {
                arrayList[selectedInd]!.selectedUnitId =
                    dataModel.response!.gradeUnit?[k].unitId;
                break;
              }
            }
            // if (gradearrUnit!.isNotEmpty) {
            //   unitItems = [];
            //   for (var i = 0; i < gradearrUnit.length; i++) {
            //     unitItems.add(DropdownMenuItem(
            //       value: gradearrUnit[i].unitName!,
            //       onTap: () {},
            //       child: Padding(
            //           padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            //           child: Text(gradearrUnit[i].unitName ?? '')),
            //     ));
            //   }
            // }
          }
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

  wsworkordersubmit() async {
    CustomLoading.progressDialog(isLoading: true, context: context);
    //for multipartrequest
    List<QtyWoItems?> arrActualListSent = [QtyWoItems()];
    // var arrActualListSent = [];
    // for (var i = 0; i < arrayList.length; i++) {
    //   var arrlist = arrayList[i]['inner_wo_data'];
    //   for (var j = 0; j < arrlist.length; j++) {
    //     var percentage = arrlist[j]['wo_percentage'].toString();
    //     if (percentage != '') {
    //       arrActualListSent.add(arrayList[i]);
    //       break;
    //     }
    //   }
    // }
    var totalAmount = 0.00;
    for (var i = 0; i < arrayList.length; i++) {
      var totAmount = arrayList[i]?.totalAmount.toString();
      if (totAmount != '') {
        totalAmount = totalAmount +
            double.parse(num.parse(totAmount ?? '0').toStringAsFixed(2));
      }
    }
    // Map<String, dynamic> dataSlabList = {
    //   "inner_wo_data": [
    //     {
    //       "wo_name": "",
    //       "wo_percentage": "100",
    //       "wo_amount": totalAmount ?? '',
    //       // '${(double.parse(widget.inputBu!) * double.parse(widget.inputRate!)).toStringAsFixed(2)}',
    //       "slab_id": "0",
    //       "block_id": "0"
    //     }
    //   ],
    //   "title": "",
    // };
    // if (arrActualListSent.isEmpty) {
    //   arrActualListSent = [dataSlabList];
    // }
    var request =
        http.MultipartRequest('POST', Uri.parse(AppUrl.setworkorderquantity));

    //for token
    request.headers.addAll({"Authorization": "Bearer token"});

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String dateStart = widget.selectedRequirementDate!;
    DateFormat inputFormat = DateFormat('dd MMM yyyy');
    DateTime input = inputFormat.parse(dateStart);
    String dateRequired = DateFormat('dd-MM-yyyy').format(input);

    //for image and videos and files
    request.fields['user_id'] = userId!;
    request.fields['grade_id'] = widget.selectedConsultantType!;
    request.fields['order_subject'] = widget.inputRequirementFor!;
    request.fields['gst_status'] = widget.selectedGST!;
    request.fields["company_id"] = widget.selectedConsultantCompany!;
    request.fields["remarks"] = widget.inputNote!;
    request.fields["towar_id"] = widget.towarId!;
    request.fields["project_id"] = widget.projectId!;
    request.fields["value_total"] = totalAmount.toString();
    // '${(double.parse(widget.inputBu!) * double.parse(widget.inputRate!)).toStringAsFixed(2)}';
    request.fields["estimation_date"] = dateRequired;
    // request.fields["value_one"] = widget.inputBu!;
    // request.fields["value_two"] = widget.inputRate!;
    request.fields["wo_arr_data"] = jsonEncode(arrayList);
    request.fields['temporary_file_name'] = '';
    request.fields['draft_flag'] = '1';

    for (int i = 0; i < widget.arrayFiles.length!; i++) {
      PlatformFile file = widget.arrayFiles[i];
      print("FILE UPLOAD");
      print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.extension);
      print(file.path);
      request.files.add(await http.MultipartFile.fromPath(
          "upload_note_image[]", file.path.toString()));
    }
    print(request);
    //for completeing the request
    var response = await request.send();

    //for getting and decoding the response into json format
    var responsed = await http.Response.fromStream(response);
    final responseData = json.decode(responsed.body);
    if (kDebugMode) {
      print(responseData);
    }
    if (response.statusCode == 200) {
      CustomLoading.progressDialog(isLoading: false, context: context);
      Future.delayed(Duration.zero).then((_) {
        Alert(
            closeIcon: const SizedBox(),
            padding: const EdgeInsets.only(top: 0.0, left: 24, right: 24),
            image: Image.asset('images/Icon-512.png',
                height: 80, fit: BoxFit.fitWidth),
            style: const AlertStyle(
                titleTextAlign: TextAlign.center,
                descTextAlign: TextAlign.center,
                descStyle:
                    TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                isCloseButton: true),
            context: context,
            desc: 'Request submitted successfully',
            alertAnimation: fadeAlertAnimation,
            buttons: [
              // DialogButton(
              //   onPressed: () => Navigator.pop(context),
              //   color: Colors.black,
              //   child: const Text(
              //     "NO",
              //     style: TextStyle(color: Colors.white, fontSize: 15),
              //   ),
              // ),
              DialogButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);

                  // RequestPurchaseOrderNavigate();
                  // context.loaderOverlay.show();
                  // CustomLoading.progressDialog(
                  //     isLoading: true, context: context);
                  // submitPurchaseOrder(context);
                },
                color: Colors.black,
                child: const Text(
                  "CLOSE",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ]).show();
      });
    } else {
      CustomLoading.progressDialog(isLoading: false, context: context);
      if (kDebugMode) {
        print("ERROR");
      }
    }
  }

  @override
  void initState() {
    selectedUnitType = '';
    super.initState();
    arrayList.add(dataList);
    if (widget.gradeUnit?.length != 0) {
      unitItems = [];
      for (var i = 0; i < widget.gradeUnit!.length; i++) {
        unitItems.add(DropdownMenuItem(
          value: widget.gradeUnit?[i].unitName!,
          onTap: () {},
          child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Text(widget.gradeUnit![i].unitName ?? '')),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Container(
          color: Colors.white,
          child: SafeArea(
              child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: Row(
                  children: [
                    const SizedBox(width: 140),
                    const Spacer(),
                    const Text(
                      'WORK ORDER QUANTITY',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    widget.navigationFlag! == "Consultant"
                        ? InkWell(
                            onTap: () async {
                              if (widget.consultantMagicLink! != "") {
                                print(widget.vendMagicLink!);
                                final uri =
                                    Uri.parse(widget.consultantMagicLink!);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                } else {
                                  throw 'Could not launch';
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black),
                              ),
                              child: const Text(
                                "INVITE CONSULTANT",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () async {
                              if (widget.contractorMagicLink! != "") {
                                print(widget.vendMagicLink!);
                                final uri =
                                    Uri.parse(widget.contractorMagicLink!);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                } else {
                                  throw 'Could not launch';
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black),
                              ),
                              child: const Text(
                                "INVITE CONTRACTOR",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 10.0, left: 100.0, right: 100.0),
                child: SizedBox(
                  height: 80,
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Container(
                              width: 30.0,
                              height: 30.0,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40.0,
                            child: Padding(
                              padding: EdgeInsets.only(top: 15.0),
                              child: Text('WO Type',
                                  style: TextStyle(
                                      backgroundColor: Colors.white,
                                      fontSize: 15,
                                      color: Colors.black)),
                            ),
                          ),
                        ],
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 35.0),
                          child: Divider(
                            height: 1,
                            thickness: 0.5,
                            indent: 1,
                            endIndent: 1,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Container(
                              width: 30.0,
                              height: 30.0,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40.0,
                            child: Padding(
                              padding: EdgeInsets.only(top: 15.0),
                              child: Text('Items Details',
                                  style: TextStyle(
                                      backgroundColor: Colors.white,
                                      fontSize: 15,
                                      color: Colors.black)),
                            ),
                          ),
                        ],
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 35.0),
                          child: Divider(
                            height: 1,
                            thickness: 0.5,
                            indent: 1,
                            endIndent: 1,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Container(
                              width: 30.0,
                              height: 30.0,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40.0,
                            child: Padding(
                              padding: EdgeInsets.only(top: 15.0),
                              child: Text('Review',
                                  style: TextStyle(
                                      backgroundColor: Colors.white,
                                      fontSize: 15,
                                      color: Colors.black)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 1,
                  endIndent: 1,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: Form(
                  key: _keyFormPOPup,
                  child: Builder(builder: (context) {
                    return ListView.builder(
                        shrinkWrap: true,
                        // physics: NeverScrollableScrollPhysics(),
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 10.0, left: 45.0, right: 45.0),
                            child: Column(
                              children: [
                                ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: arrayList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white,
                                            shape: BoxShape.rectangle,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 40.0,
                                                right: 40.0,
                                                bottom: 20.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                index != 0
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          IconButton(
                                                            iconSize: 30,
                                                            icon: const Icon(
                                                              Icons
                                                                  .close_rounded,
                                                            ),
                                                            color: Colors.black,
                                                            onPressed: () {
                                                              setState(() {
                                                                arrayList
                                                                    .removeAt(
                                                                        index);
                                                              });
                                                            },
                                                          ),
                                                        ],
                                                      )
                                                    : const SizedBox(
                                                        height: 15),
                                                _description(index),
                                                verticalSpaceSmall15,
                                                widget.navigationFlag! ==
                                                        "Consultant"
                                                    ? _quantityUnitConsultant(
                                                        index)
                                                    : _quantityUnit(index),
                                                verticalSpaceSmall15,
                                                _unitPrice(index),
                                                verticalSpaceSmall15,
                                                _totalPrice(index),
                                                verticalSpaceSmall15,
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ],
                            ),
                          );
                        });
                  }),
                ),
              ),
              verticalSpaceSmall,
              SizedBox(
                width: 220,
                height: 40,
                child: BorderButton(
                    lblText: 'ADD MORE REQUEST',
                    color: Colors.white,
                    onTap: () {
                      selectedRow++;
                      QtyWoItems dataList1 = QtyWoItems(
                          woUnit: "",
                          castingUnit: "",
                          woQuantity: "",
                          woUnitPrice: "",
                          totalAmount: "",
                          woCastingFor: "",
                          id: "0",
                          controllerText: TextEditingController(),
                          selectedUnitId: '');
                      setState(() {
                        arrayList.add(dataList1);
                      });
                    }),
              ),
              verticalSpaceSmall,
              // Padding(
              //   padding: const EdgeInsets.only(left: 70.0, right: 70.0),
              //   child: SimpleButton(
              //     lblText: 'REVIEW WORK ORDER',
              //     color: kcPrimaryColor,
              //     onTap: () {
              //       if (_keyFormPOPup.currentState!.validate()) {
              //         var totalAmount = 0.00;
              //         for (var i = 0; i < arrayList.length; i++) {
              //           var totAmount = arrayList[i]?.totalAmount.toString();
              //           if (totAmount != '') {
              //             totalAmount = totalAmount +
              //                 double.parse(num.parse(totAmount ?? '0')
              //                     .toStringAsFixed(2));
              //           }
              //         }

              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (_) {
              //               return QuantityWoReviewView(
              //                   consultantMagicLink: widget.consultantMagicLink,
              //                   contractorMagicLink: widget.contractorMagicLink,
              //                   vendMagicLink: widget.vendMagicLink,
              //                   projectId: widget.projectId!,
              //                   towarId: widget.towarId!,
              //                   projectName: widget.projectName!,
              //                   selectedConsultantType:
              //                       widget.selectedConsultantType,
              //                   selectedConsultantCompany:
              //                       widget.selectedConsultantCompany,
              //                   selectedRequirementDate:
              //                       widget.selectedRequirementDate,
              //                   selectedGST: widget.selectedGST,
              //                   inputNote: widget.inputNote,
              //                   inputRequirementFor: widget.inputRequirementFor,
              //                   arrayFiles: widget.arrayFiles,
              //                   totalAmount: totalAmount,
              //                   arrayList: arrayList);
              //             },
              //           ),
              //         ).then((value) => {
              //               checkNavigation(),
              //             });
              //       }
              //     },
              //   ),
              // ),
              // verticalSpaceSmall,
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Alert(
                            closeIcon: const SizedBox(),
                            padding: const EdgeInsets.only(
                                top: 0.0, left: 18, right: 18),
                            image: Image.asset('images/Icon-512.png',
                                height: 80, fit: BoxFit.fitWidth),
                            style: const AlertStyle(
                                titleTextAlign: TextAlign.center,
                                descTextAlign: TextAlign.center,
                                descStyle: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16),
                                isCloseButton: true),
                            context: context,
                            desc:
                                'Are you sure, you want to save the draft? \nYou can upload the saved draft on backend through excel.',
                            alertAnimation: fadeAlertAnimation,
                            buttons: [
                              DialogButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                color: Colors.black,
                                child: const Text(
                                  "CLOSE",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ),
                              DialogButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  wsworkordersubmit();
                                },
                                color: Colors.black,
                                child: const Text(
                                  "SUBMIT",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ),
                            ]).show();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(color: Colors.black),
                        child: Text(
                          "SAVE AS DRAFT",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        //   print(
                        //       '${totalPercentage}====== ${totalAmount} =====${TotalAmountActual}');
                        //   if (totalPercentage!.isBetween(99.98, 101)) {
                        //     if (totalAmount != TotalAmountActual) {
                        //       var diff = TotalAmountActual - totalAmount!;
                        //       print(
                        //           '${diff}******${(diff / 100).toStringAsFixed(2)}');
                        //       print('------------------------------------');

                        //       Alert(
                        //           closeIcon: const SizedBox(),
                        //           padding: const EdgeInsets.only(top: 0.0),
                        //           image: Image.asset('images/Icon-512.png',
                        //               height: 80, fit: BoxFit.fitWidth),
                        //           style: const AlertStyle(
                        //               titleTextAlign: TextAlign.center,
                        //               descTextAlign: TextAlign.center,
                        //               descStyle: TextStyle(
                        //                   fontWeight: FontWeight.normal,
                        //                   fontSize: 16),
                        //               isCloseButton: true),
                        //           context: context,
                        //           desc: 'Please match total percentage to 100.',
                        //           alertAnimation: fadeAlertAnimation,
                        //           buttons: [
                        //             DialogButton(
                        //               onPressed: () {
                        //                 Navigator.pop(context);
                        //               },
                        //               color: Colors.black,
                        //               child: const Text(
                        //                 "CLOSE",
                        //                 style: TextStyle(
                        //                     color: Colors.white, fontSize: 15),
                        //               ),
                        //             ),
                        //           ]).show();
                        //     } else {
                        //       var arrActualListSent = [];
                        //       for (var i = 0; i < arrayList.length; i++) {
                        //         var arrlist = arrayList[i]['inner_wo_data'];
                        //         for (var j = 0; j < arrlist.length; j++) {
                        //           var percentage =
                        //               arrlist[j]['wo_percentage'].toString();
                        //           if (percentage != '') {
                        //             arrActualListSent.add(arrayList[i]);
                        //             break;
                        //           }
                        //         }
                        //       }

                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (_) {
                        //             return WorkOrderPercentagePreview(
                        //                 projectId: widget.projectId!,
                        //                 towarId: widget.towarId!,
                        //                 projectName: widget.projectName!,
                        //                 selectedConsultantType:
                        //                     widget.selectedConsultantType,
                        //                 selectedConsultantCompany:
                        //                     widget.selectedConsultantCompany,
                        //                 selectedRequirementDate:
                        //                     widget.selectedRequirementDate,
                        //                 selectedGST: widget.selectedGST,
                        //                 inputBu: widget.inputBu,
                        //                 inputNote: widget.inputNote,
                        //                 inputRate: widget.inputRate,
                        //                 inputRequirementFor:
                        //                     widget.inputRequirementFor,
                        //                 arrayFiles: widget.arrayFiles,
                        //                 totalPercentage: totalPercentage!,
                        //                 totalAmount: totalAmount!,
                        //                 arrayList: arrActualListSent);
                        //           },
                        //         ),
                        //       ).then((value) => {
                        //             checkNavigation(),
                        //           });
                        //     }
                        //   } else if (totalPercentage != 100) {
                        //     Alert(
                        //         closeIcon: const SizedBox(),
                        //         padding: const EdgeInsets.only(top: 0.0),
                        //         image: Image.asset('images/Icon-512.png',
                        //             height: 80, fit: BoxFit.fitWidth),
                        //         style: const AlertStyle(
                        //             titleTextAlign: TextAlign.center,
                        //             descTextAlign: TextAlign.center,
                        //             descStyle: TextStyle(
                        //                 fontWeight: FontWeight.normal,
                        //                 fontSize: 16),
                        //             isCloseButton: true),
                        //         context: context,
                        //         desc: 'Please match total percentage to 100.',
                        //         alertAnimation: fadeAlertAnimation,
                        //         buttons: [
                        //           DialogButton(
                        //             onPressed: () {
                        //               Navigator.pop(context);
                        //             },
                        //             color: Colors.black,
                        //             child: const Text(
                        //               "CLOSE",
                        //               style: TextStyle(
                        //                   color: Colors.white, fontSize: 15),
                        //             ),
                        //           ),
                        //         ]).show();
                        //   } else {
                        //     bool errorflag = false;
                        //     var errorMessage = '';
                        //     if (txtLinkSlabMasonry.text.isNotEmpty) {
                        //       for (var i = 0; i < arrayList.length; i++) {
                        //         var arrlist = arrayList[i]['inner_wo_data'];
                        //         for (var j = 0; j < arrlist.length; j++) {
                        //           var title = arrlist[j]['wo_name'].toString();
                        //           var percentage =
                        //               arrlist[j]['wo_percentage'].toString();
                        //           if (percentage != '') {
                        //             if (title == '') {
                        //               errorflag = true;
                        //               errorMessage = 'Please enter subtitle.';
                        //             }
                        //           }
                        //         }
                        //       }
                        //     } else {
                        //       for (var i = 0; i < arrayList.length; i++) {
                        //         var arrlist = arrayList[i]['inner_wo_data'];
                        //         for (var j = 0; j < arrlist.length; j++) {
                        //           var title = arrlist[j]['wo_name'].toString();
                        //           var percentage =
                        //               arrlist[j]['wo_percentage'].toString();
                        //           if (title != '' || percentage != '') {
                        //             if (title == '') {
                        //               errorflag = true;
                        //               errorMessage = 'Please enter subtitle.';
                        //             } else if (percentage == '') {
                        //               errorflag = true;
                        //               errorMessage = 'Please enter percentage.';
                        //             }
                        //           }
                        //         }
                        //       }
                        //     }
                        //     if (errorflag == true) {
                        //       Alert(
                        //           closeIcon: const SizedBox(),
                        //           padding: const EdgeInsets.only(top: 0.0),
                        //           image: Image.asset('images/Icon-512.png',
                        //               height: 80, fit: BoxFit.fitWidth),
                        //           style: const AlertStyle(
                        //               titleTextAlign: TextAlign.center,
                        //               descTextAlign: TextAlign.center,
                        //               descStyle: TextStyle(
                        //                   fontWeight: FontWeight.normal,
                        //                   fontSize: 16),
                        //               isCloseButton: true),
                        //           context: context,
                        //           desc: errorMessage,
                        //           alertAnimation: fadeAlertAnimation,
                        //           buttons: [
                        //             DialogButton(
                        //               onPressed: () => Navigator.pop(context),
                        //               color: Colors.black,
                        //               child: const Text(
                        //                 "CLOSE",
                        //                 style: TextStyle(
                        //                     color: Colors.white, fontSize: 15),
                        //               ),
                        //             ),
                        //           ]).show();
                        //     } else {
                        //       if (kDebugMode) {
                        //         print('NEXT PAGE');
                        //       }
                        //       var arrActualListSent = [];
                        //       for (var i = 0; i < arrayList.length; i++) {
                        //         var arrlist = arrayList[i]['inner_wo_data'];
                        //         for (var j = 0; j < arrlist.length; j++) {
                        //           var percentage =
                        //               arrlist[j]['wo_percentage'].toString();
                        //           if (percentage != '') {
                        //             arrActualListSent.add(arrayList[i]);
                        //             break;
                        //           }
                        //         }
                        //       }
                        //       if (kDebugMode) {
                        //         print('----arrActualListSent-----');
                        //         print('arrActualListSent');
                        //       }

                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (_) {
                        //             return WorkOrderPercentagePreview(
                        //                 projectId: widget.projectId!,
                        //                 towarId: widget.towarId!,
                        //                 projectName: widget.projectName!,
                        //                 selectedConsultantType:
                        //                     widget.selectedConsultantType,
                        //                 selectedConsultantCompany:
                        //                     widget.selectedConsultantCompany,
                        //                 selectedRequirementDate:
                        //                     widget.selectedRequirementDate,
                        //                 selectedGST: widget.selectedGST,
                        //                 inputBu: widget.inputBu,
                        //                 inputNote: widget.inputNote,
                        //                 inputRate: widget.inputRate,
                        //                 inputRequirementFor:
                        //                     widget.inputRequirementFor,
                        //                 arrayFiles: widget.arrayFiles,
                        //                 totalPercentage: totalPercentage!,
                        //                 totalAmount: totalAmount!,
                        //                 arrayList: arrActualListSent);
                        //           },
                        //         ),
                        //       ).then((value) => {
                        //             checkNavigation(),
                        //           });
                        //     }
                        //   }

                        if (_keyFormPOPup.currentState!.validate()) {
                          var totalAmount = 0.00;
                          for (var i = 0; i < arrayList.length; i++) {
                            var totAmount =
                                arrayList[i]?.totalAmount.toString();
                            if (totAmount != '') {
                              totalAmount = totalAmount +
                                  double.parse(num.parse(totAmount ?? '0')
                                      .toStringAsFixed(2));
                            }
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) {
                                return QuantityWoReviewView(
                                    consultantMagicLink:
                                        widget.consultantMagicLink,
                                    contractorMagicLink:
                                        widget.contractorMagicLink,
                                    vendMagicLink: widget.vendMagicLink,
                                    projectId: widget.projectId!,
                                    towarId: widget.towarId!,
                                    projectName: widget.projectName!,
                                    selectedConsultantType:
                                        widget.selectedConsultantType,
                                    selectedConsultantCompany:
                                        widget.selectedConsultantCompany,
                                    selectedRequirementDate:
                                        widget.selectedRequirementDate,
                                    selectedGST: widget.selectedGST,
                                    inputNote: widget.inputNote,
                                    inputRequirementFor:
                                        widget.inputRequirementFor,
                                    arrayFiles: widget.arrayFiles,
                                    totalAmount: totalAmount,
                                    arrayList: arrayList);
                              },
                            ),
                          ).then((value) => {
                                checkNavigation(),
                              });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            border:
                                Border(left: BorderSide(color: Colors.white))),
                        child: Text(
                          "PREVIEW WORK ORDER",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ))),
    );
  }

  void checkNavigation() async {
    final SharedPreferences prefs = await _prefs;
    String? flagRedirect = prefs.getString('flagRedirectToWorkProgress');
    if (flagRedirect == 'true') {
      backToScreen();
    }
  }

  void backToScreen() {
    Navigator.maybePop(context);
  }

  Widget _description(int index) {
    _txtControllerDescription.add(TextEditingController());
    _txtControllerDescription[index].text =
        arrayList[index]!.woCastingFor.toString();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Add Description',
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
              validator: (value) {
                if (value!.isEmpty) {
                  return "(Description Cannot Be Empty)";
                }
              },
              maxLines: 3,
              style: const TextStyle(color: Colors.black, fontSize: 15.0),
              decoration: InputDecoration(
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
                    color: (Colors.red),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (String str) {
                arrayList[index]?.woCastingFor = str;
              },
            ),
          ),
        )
      ],
    );
  }

  Widget _quantityUnitConsultant(int index) {
    _txtControllerQuantity.add(TextEditingController());
    _txtControllerQuantity[index].text = arrayList[index]?.woQuantity ?? '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Quantity',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        // SizedBox(width: 10),
        Expanded(
          child: Container(
            // height: 45,
            // decoration: BoxDecoration(
            //     color: kcTextFieldColor,
            //     border: Border.all(
            //       color: Colors.grey,
            //     ),
            //     borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Container(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 0, bottom: 0),
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "(Quantity Cannot Be Empty)";
                  }
                },
                // style: const TextStyle(color: Colors.black, fontSize: 15),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  border: InputBorder.none,
                  hintText: 'Enter Quantity',
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
                      color: (Colors.red),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // decoration: const InputDecoration(
                //     contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                //     border: InputBorder.none,
                //     hintText: 'Enter Quantity'),
                onChanged: (String str) {
                  setState(() {
                    arrayList[index]?.woQuantity = str;
                    if (arrayList[index]?.woUnitPrice.toString() != '' &&
                        arrayList[index]?.woQuantity.toString() != '') {
                      var amount = ((double.parse(
                                  arrayList[index]!.woQuantity.toString()) *
                              double.parse(
                                  arrayList[index]!.woUnitPrice.toString())))
                          .toStringAsFixed(2);
                      arrayList[index]?.totalAmount = amount;
                    } else {
                      arrayList[index]?.totalAmount = '';
                    }
                  });
                },
              ),
            ),
          ),
        ),
        // horizontalSpaceMedium,
        Expanded(
          child: Container(
            // height: 45,
            // decoration: BoxDecoration(
            //     color: kcTextFieldColor,
            //     border: Border.all(
            //       color: Colors.grey,
            //     ),
            //     borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 0, bottom: 0),
              child: TextFormField(
                controller: TextEditingController.fromValue(TextEditingValue(
                    text: arrayList[index]!.woUnit.toString(),
                    selection: TextSelection.collapsed(
                        offset: arrayList[index]!.woUnit.toString().length))),
                // style: const TextStyle(color: Colors.black, fontSize: 15),
                // decoration: const InputDecoration(
                //     contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                //     border: InputBorder.none,
                //     hintText: 'Enter Unit Type'),
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "(Unit Type Cannot Be Empty)";
                  }
                },
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    Icons.keyboard_arrow_down_outlined,
                  ),
                  contentPadding: const EdgeInsets.all(10),
                  border: InputBorder.none,
                  hintText: 'Enter Unit Type',
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
                      color: (Colors.red),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (String str) {
                  setState(() {
                    arrayList[index]?.woUnit = str;
                  });
                },
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget _quantityUnit(int index) {
    _txtControllerQuantity.add(TextEditingController());
    _txtControllerQuantity[index].text =
        arrayList[index]!.woQuantity.toString();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Quantity',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 10.0, right: 10.0, top: 0, bottom: 0),
            child: TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return "(Quantity Cannot Be Empty)";
                }
              },
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: const TextStyle(color: Colors.black, fontSize: 15.0),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                border: InputBorder.none,
                hintText: 'Enter Quantity',
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
                    color: (Colors.red),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (String str) {
                setState(() {
                  arrayList[index]?.woQuantity = str;
                  if (arrayList[index]?.woUnitPrice.toString() != '' &&
                      arrayList[index]?.woQuantity.toString() != '') {
                    var amount = ((double.parse(
                                arrayList[index]!.woQuantity.toString()) *
                            double.parse(
                                arrayList[index]!.woUnitPrice.toString())))
                        .toStringAsFixed(2);
                    arrayList[index]?.totalAmount = amount;
                  } else {
                    arrayList[index]?.totalAmount = '';
                  }
                });
              },
            ),
          ),
        ),
        const SizedBox(width: 40.0),
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                searchText = '';
              });
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    surfaceTintColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    titlePadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    actionsPadding:
                        const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    actionsAlignment: MainAxisAlignment.center,
                    title: const Text(
                      "Select Unit Type",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                searchText = "";
                                _textFieldController.clear();
                                Navigator.of(context).pop();
                                _displayTextInputDialog(
                                    context: context, selectedInd: index);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(7)),
                                child: const Center(
                                  child: Text(
                                    "ADD CUSTOM UNIT",
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
                          ),
                          const SizedBox(width: 30),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
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
                          ),
                        ],
                      ),
                    ],
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState1) {
                        return Container(
                          width: 500,
                          height: 404,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              verticalSpaceTiny,
                              SizedBox(
                                height: 40,
                                child: TextField(
                                  onChanged: (value) {
                                    setState1(() {
                                      searchText = value;
                                    });
                                  },
                                  style: const TextStyle(fontSize: 13),
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.all(12.0),
                                      labelText: 'Search Unit Type',
                                      hintText: "Search Unit Type",
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(7.0)))),
                                ),
                              ),
                              verticalSpaceTiny,
                              Expanded(
                                child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: filteredProjects()!.length,
                                    itemBuilder: (context, int ind) {
                                      return InkWell(
                                        onTap: () {
                                          setState1(() {
                                            if (arrayList[index]!
                                                    .selectedUnitId ==
                                                filteredProjects()![ind]
                                                    .unitId) {
                                              arrayList[index]!.selectedUnitId =
                                                  "";
                                              arrayList[index]!
                                                  .controllerText
                                                  ?.text = '';
                                              arrayList[index]!.woUnit = "";
                                            } else {
                                              arrayList[index]!.selectedUnitId =
                                                  filteredProjects()![ind]
                                                      .unitId;
                                              arrayList[index]!
                                                      .controllerText
                                                      ?.text =
                                                  filteredProjects()![ind]
                                                          .unitName ??
                                                      '';
                                              arrayList[index]!.woUnit =
                                                  filteredProjects()![ind]
                                                          .unitName ??
                                                      '';
                                            }
                                            inspect(filteredProjects()![ind]);
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0, vertical: 7.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        filteredProjects()![ind]
                                                                .unitName ??
                                                            '',
                                                        style: normalText,
                                                      ),
                                                    ],
                                                  ),
                                                  arrayList[index]!
                                                              .selectedUnitId ==
                                                          filteredProjects()![
                                                                  ind]
                                                              .unitId
                                                      ? const Icon(
                                                          Icons.circle,
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
                                                  height: 1.0,
                                                  color: Colors.black),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 0, bottom: 0),
              child: TextFormField(
                autofocus: false,
                enabled: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "(Unit Type Cannot Be Empty)";
                  }
                },
                controller: arrayList[index]!.controllerText,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    Icons.keyboard_arrow_down_outlined,
                  ),
                  contentPadding: const EdgeInsets.all(10),
                  border: InputBorder.none,
                  hintText: 'Enter Unit Type',
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF5F5C5C)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: (Colors.red),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBorder: OutlineInputBorder(
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
      ],
    );
  }

  Widget _unitPrice(int index) {
    _txtControllerUnitPrice.add(TextEditingController());
    _txtControllerUnitPrice[index].text =
        arrayList[index]!.woUnitPrice.toString();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Unit Price',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 10.0, right: 10.0, top: 0, bottom: 0),
            child: TextFormField(
              controller: TextEditingController.fromValue(TextEditingValue(
                  text: arrayList[index]!.woUnitPrice.toString(),
                  selection: TextSelection.collapsed(
                      offset: arrayList[index]!.woUnitPrice!.length))),
              style: const TextStyle(color: Colors.black, fontSize: 15),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                border: InputBorder.none,
                hintText: 'Enter Unit Price (Optional)',
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
                    color: (Colors.red),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (String str) {
                setState(() {
                  arrayList[index]!.woUnitPrice = str;
                  if (arrayList[index]?.woUnitPrice.toString() != '' &&
                      arrayList[index]!.woQuantity.toString() != '') {
                    var amount = ((double.parse(
                                arrayList[index]!.woQuantity.toString()) *
                            double.parse(
                                arrayList[index]!.woUnitPrice.toString())))
                        .toStringAsFixed(2);
                    arrayList[index]?.totalAmount = amount;
                  } else {
                    arrayList[index]?.totalAmount = '';
                  }
                });
              },
            ),
          ),
        )
      ],
    );
  }

  Widget _totalPrice(int index) {
    _txtControllerTotalPrice.add(TextEditingController());
    _txtControllerTotalPrice[index].text =
        arrayList[index]!.totalAmount.toString();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Total Price',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(
                left: 10.0, right: 10.0, top: 0, bottom: 0),
            child: TextFormField(
              controller: TextEditingController.fromValue(TextEditingValue(
                text: arrayList[index]!.totalAmount == ""
                    ? "0"
                    : arrayList[index]!.totalAmount.toString(),
              )),
              readOnly: true,
              style: const TextStyle(color: Colors.black, fontSize: 15),
              decoration: InputDecoration(
                filled: true,
                fillColor: kcTextFieldGreyColor,
                contentPadding: const EdgeInsets.all(10),
                border: InputBorder.none,
                hintText: 'Total Price',
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF5F5C5C)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
