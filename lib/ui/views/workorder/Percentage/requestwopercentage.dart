import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/salesmanagement/setpaymenttermsview.dart';
import 'package:stallion/ui/views/workorder/Percentage/workorderpercentagepreview.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/remove_temp_file.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/wsslabmasonrystructure.dart';
import '../../../../utils/app_url.dart';
import '../../../shared/ui_helpers.dart';
import '../../../widgets/simple_button.dart';
import 'package:http/http.dart' as http;

class RequestWorkOrderPercentage extends StatefulWidget {
  RequestWorkOrderPercentage(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.selectedConsultantType,
      this.selectedConsultantCompany,
      this.inputRequirementFor,
      this.selectedRequirementDate,
      this.inputBu,
      this.inputRate,
      this.inputNote,
      this.selectedGST,
      this.consultantMagicLink,
      this.contractorMagicLink,
      this.vendMagicLink,
      required this.isBua,
      required this.arrayFiles});

  final String? projectId;
  final String? towarId;
  final String? projectName;
  String? selectedConsultantType;
  String? selectedConsultantCompany;
  String? inputRequirementFor;
  String? selectedRequirementDate;
  String? inputBu;
  String? inputRate;
  String? inputNote;
  String? selectedGST;
  final bool isBua;
  var arrayFiles = [];
  final String? contractorMagicLink;
  final String? vendMagicLink;
  final String? consultantMagicLink;

  @override
  State<RequestWorkOrderPercentage> createState() =>
      _RequestWorkOrderPercentageState();
}

class _RequestWorkOrderPercentageState
    extends State<RequestWorkOrderPercentage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  bool flagcalled = false;
  bool flagcenterAddbutton = false;
  List<String?> selecteditemId = [];
  final List<TextEditingController> _controllerstxtHeaderTitle = [];
  final List<TextEditingController> _controllerstxtBlockName = [];
  final List<TextEditingController> _controllerstxtPercentage = [];
  final List<TextEditingController> _controllerstxtAmount = [];

  TextEditingController txtLinkSlabMasonry = TextEditingController();

  Future<ResponseWsslabmasonrystructure?> wsslabmasonrystructure() async {
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
      "type": '1',
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.getWsslabmasonrystructure, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = wsslabmasonrystructureFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        slabMasonryList = dataModel.response?.list;
        if (slabMasonryList!.isNotEmpty) {
          slabMasonryItems = [];
          for (var i = 0; i < slabMasonryList!.length; i++) {
            slabMasonryItems.add(DropdownMenuItem(
              value: slabMasonryList![i].name,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text(slabMasonryList![i].name ?? ''),
              ),
            ));
          }
          setState(() {
            flagcalled = true;
          });
        }
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
  }

  wsworkordersubmit() async {
    CustomLoading.progressDialog(isLoading: true, context: context);
    //for multipartrequest
    var arrActualListSent = [];
    for (var i = 0; i < arrayList.length; i++) {
      var arrlist = arrayList[i]['inner_wo_data'];
      for (var j = 0; j < arrlist.length; j++) {
        var percentage = arrlist[j]['wo_percentage'].toString();
        if (percentage != '') {
          arrActualListSent.add(arrayList[i]);
          break;
        }
      }
    }

    Map<String, dynamic> dataSlabList = {
      "inner_wo_data": [
        {
          "wo_name": "",
          "wo_percentage": "100",
          "wo_amount":
              '${(double.parse(widget.inputBu!) * double.parse(widget.inputRate!)).toStringAsFixed(2)}',
          "slab_id": "0",
          "block_id": "0"
        }
      ],
      "title": "",
    };
    if (arrActualListSent.isEmpty) {
      arrActualListSent = [dataSlabList];
    }
    var request =
        http.MultipartRequest('POST', Uri.parse(AppUrl.setworkorderpercentage));

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
    request.fields["value_total"] =
        '${(double.parse(widget.inputBu!) * double.parse(widget.inputRate!)).toStringAsFixed(2)}';
    request.fields["estimation_date"] = dateRequired;
    request.fields["value_one"] = widget.inputBu!;
    request.fields["value_two"] = widget.inputRate!;
    request.fields["wo_arr_data"] = jsonEncode(arrActualListSent);
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

  List<DropdownMenuItem> items = [];

  double? totalPercentage = 0.0;
  double? totalAmount = 0.0;
  var arrayList = [];

  List<ListElement>? slabMasonryList = [];
  List<DropdownMenuItem> slabMasonryItems = [];

  Map<String, dynamic> dataSlabList = {
    "inner_wo_data": [
      {
        "wo_name": "",
        "wo_percentage": "",
        "wo_amount": "",
        "slab_id": "0",
        "block_id": "0"
      }
    ],
    "title": "",
  };

  var TotalAmountActual = 0.0;

  @override
  void initState() {
    super.initState();
    arrayList.add(dataSlabList);

    TotalAmountActual =
        double.parse(widget.inputBu!) * double.parse(widget.inputRate!);

    updateContent();
    wsslabmasonrystructure();
  }

  void updateContent() {
    setState(() {
      _contents = List.generate(arrayList.length, (index) {
        _controllerstxtHeaderTitle.add(TextEditingController());
        _controllerstxtHeaderTitle[index].text =
            arrayList[index]['title'].toString();
        return DragAndDropList(
          header: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 10.0, bottom: 10.0),
                child: // Generated code for this Column Widget...
                    Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    // radius of 10
                    color: Colors.white,
                    border: Border.all(
                        color: Colors.black,
                        width: 1.0), // green as background color
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 80.0, right: 80.0, top: 15.0),
                              child: SizedBox(
                                height: 40.0,
                                child: TextFormField(
                                  onChanged: (String str) {
                                    arrayList[index]['title'] = str;
                                  },
                                  controller: TextEditingController.fromValue(
                                      TextEditingValue(
                                          text: arrayList[index]['title']
                                              .toString(),
                                          selection: TextSelection.collapsed(
                                              offset: arrayList[index]['title']
                                                  .length))),
                                  style: normalText,
                                  obscureText: false,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: kcTextFieldColor,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 15.0),
                                    hintText: 'Heading Title',
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black54,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(4.0),
                                        topRight: Radius.circular(4.0),
                                        bottomLeft: Radius.circular(4.0),
                                        bottomRight: Radius.circular(4.0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black54,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(4.0),
                                        topRight: Radius.circular(4.0),
                                        bottomLeft: Radius.circular(4.0),
                                        bottomRight: Radius.circular(4.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 10.0, 0.0),
                            child: IconButton(
                              iconSize: 30.0,
                              icon: const Icon(
                                Icons.add_circle_outline_outlined,
                                color: Colors.black,
                                size: 30.0,
                              ),
                              onPressed: () {
                                if (kDebugMode) {
                                  print('Header Add Clicked');
                                  print(index);
                                }

                                Map<String, dynamic> dataSlabList = {
                                  "inner_wo_data": [
                                    {
                                      "wo_name": "",
                                      "wo_percentage": "",
                                      "wo_amount": "",
                                      "slab_id": "0",
                                      "block_id": "0"
                                    }
                                  ],
                                  "title": "",
                                };

                                setState(() {
                                  arrayList.insert(index + 1, dataSlabList);
                                  updateContent();
                                });
                              },
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 25.0, 0.0),
                              child: IconButton(
                                iconSize: 30.0,
                                icon: const Icon(
                                  Icons.remove_circle_outline_outlined,
                                  color: Colors.black,
                                  size: 30.0,
                                ),
                                onPressed: () {
                                  if (kDebugMode) {
                                    print('Header Remove Clicked');
                                  }

                                  _controllerstxtHeaderTitle.removeAt(index);
                                  _controllerstxtBlockName.removeAt(index);
                                  _controllerstxtPercentage.removeAt(index);
                                  _controllerstxtAmount.removeAt(index);

                                  arrayList.remove(arrayList[index]);
                                  updateContent();
                                  setState(() {
                                    if (arrayList.isEmpty) {
                                      flagcenterAddbutton = true;
                                    }
                                  });
                                },
                              )),
                        ],
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: arrayList[index]['inner_wo_data'].length,
                          itemBuilder: (BuildContext context, int innerindex) {
                            _controllerstxtBlockName
                                .add(TextEditingController());
                            _controllerstxtPercentage
                                .add(TextEditingController());
                            _controllerstxtAmount.add(TextEditingController());

                            _controllerstxtBlockName[innerindex].text =
                                arrayList[index]['inner_wo_data'][innerindex]
                                        ['wo_name']
                                    .toString();

                            _controllerstxtPercentage[innerindex].text =
                                arrayList[index]['inner_wo_data'][innerindex]
                                        ['wo_percentage']
                                    .toString();

                            _controllerstxtAmount[innerindex].text =
                                arrayList[index]['inner_wo_data'][innerindex]
                                        ['wo_amount']
                                    .toString();

                            return Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  10.0, 5.0, 10.0, 5.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  txtLinkSlabMasonry.text.isNotEmpty
                                      ? Expanded(
                                          child: SizedBox(
                                            height: 40.0,
                                            child: TextFormField(
                                              readOnly: arrayList[index][
                                                                      'inner_wo_data']
                                                                  [innerindex]
                                                              ['slab_id'] !=
                                                          '0' ||
                                                      arrayList[index][
                                                                      'inner_wo_data']
                                                                  [innerindex]
                                                              ['block_id'] !=
                                                          '0'
                                                  ? true
                                                  : false,
                                              onChanged: (String str) {
                                                arrayList[index]
                                                            ['inner_wo_data']
                                                        [innerindex]
                                                    ['wo_name'] = str;
                                              },
                                              style: normalText,
                                              controller: TextEditingController
                                                  .fromValue(TextEditingValue(
                                                      text: arrayList[index]
                                                                      ['inner_wo_data']
                                                                  [innerindex]
                                                              ['wo_name']
                                                          .toString(),
                                                      selection: TextSelection.collapsed(
                                                          offset: arrayList[index]
                                                                          ['inner_wo_data']
                                                                      [innerindex]
                                                                  ['wo_name']
                                                              .length))),
                                              obscureText: false,
                                              decoration: arrayList[index][
                                                                      'inner_wo_data']
                                                                  [innerindex]
                                                              ['slab_id'] !=
                                                          '0' ||
                                                      arrayList[index][
                                                                      'inner_wo_data']
                                                                  [innerindex]
                                                              ['block_id'] !=
                                                          '0'
                                                  ? const InputDecoration(
                                                      filled: true,
                                                      fillColor:
                                                          kcTextFieldGreyColor,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 15.0,
                                                              horizontal: 15.0),
                                                      hintText: 'Sub Title',
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.black54,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  4.0),
                                                          topRight:
                                                              Radius.circular(
                                                                  4.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  4.0),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  4.0),
                                                        ),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.black54,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  4.0),
                                                          topRight:
                                                              Radius.circular(
                                                                  4.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  4.0),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  4.0),
                                                        ),
                                                      ),
                                                    )
                                                  : const InputDecoration(
                                                      filled: true,
                                                      fillColor:
                                                          kcTextFieldColor,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 15.0,
                                                              horizontal: 15.0),
                                                      hintText: 'Sub Title',
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.black54,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  4.0),
                                                          topRight:
                                                              Radius.circular(
                                                                  4.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  4.0),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  4.0),
                                                        ),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.black54,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  4.0),
                                                          topRight:
                                                              Radius.circular(
                                                                  4.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  4.0),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  4.0),
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        )
                                      : Expanded(
                                          child: SizedBox(
                                            height: 40.0,
                                            child: TextFormField(
                                              onChanged: (String str) {
                                                arrayList[index]
                                                            ['inner_wo_data']
                                                        [innerindex]
                                                    ['wo_name'] = str;
                                              },
                                              style: normalText,
                                              controller: TextEditingController
                                                  .fromValue(TextEditingValue(
                                                      text: arrayList[index]
                                                                      ['inner_wo_data']
                                                                  [innerindex]
                                                              ['wo_name']
                                                          .toString(),
                                                      selection: TextSelection.collapsed(
                                                          offset: arrayList[index]
                                                                          ['inner_wo_data']
                                                                      [innerindex]
                                                                  ['wo_name']
                                                              .length))),
                                              obscureText: false,
                                              decoration: const InputDecoration(
                                                filled: true,
                                                fillColor: kcTextFieldColor,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 15.0,
                                                        horizontal: 15.0),
                                                hintText: 'Sub Title',
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.black54,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(4.0),
                                                    topRight:
                                                        Radius.circular(4.0),
                                                    bottomLeft:
                                                        Radius.circular(4.0),
                                                    bottomRight:
                                                        Radius.circular(4.0),
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.black54,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(4.0),
                                                    topRight:
                                                        Radius.circular(4.0),
                                                    bottomLeft:
                                                        Radius.circular(4.0),
                                                    bottomRight:
                                                        Radius.circular(4.0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                  horizontalSpaceTiny,
                                  Expanded(
                                    child: SizedBox(
                                      height: 40.0,
                                      child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d+\.?\d{0,2}')),
                                        ],
                                        onChanged: (text) {
                                          if (kDebugMode) {
                                            print(text);
                                          }
                                          var value = '';
                                          if (text == '') {
                                            value = '0';
                                          } else {
                                            value = text;
                                          }
                                          setState(() {
                                            arrayList[index]['inner_wo_data']
                                                    [innerindex]
                                                ['wo_percentage'] = text;
                                            var amount = (((double.parse(widget
                                                                .inputBu!) *
                                                            double.parse(widget
                                                                .inputRate!)) *
                                                        double.parse(value)) /
                                                    100.0)
                                                .toStringAsFixed(2);
                                            arrayList[index]['inner_wo_data']
                                                    [innerindex]['wo_amount'] =
                                                amount;

                                            double totPercentage = 0.00;
                                            double totAmount = 0.00;
                                            for (var i = 0;
                                                i < arrayList.length;
                                                i++) {
                                              var arrlist =
                                                  arrayList[i]['inner_wo_data'];
                                              for (var j = 0;
                                                  j < arrlist.length;
                                                  j++) {
                                                var totPer = arrlist[j]
                                                        ['wo_percentage']
                                                    .toString();
                                                String totAmt = arrlist[j]
                                                        ['wo_amount']
                                                    .toString();
                                                if (totPer != '') {
                                                  totPercentage =
                                                      totPercentage +
                                                          double.parse(totPer);
                                                  // .toStringAsFixed(
                                                  //     2));
                                                }
                                                if (totAmt != '') {
                                                  totAmount = totAmount +
                                                      double.parse(totAmt);
                                                }
                                              }
                                            }

                                            totalPercentage = double.parse(
                                                totPercentage
                                                    .toStringAsFixed(2));
                                            totalAmount = double.parse(
                                                totAmount.toStringAsFixed(2));
                                            // totalAmount = totAmount;
                                            updateContent();
                                          });
                                        },
                                        controller: TextEditingController
                                            .fromValue(TextEditingValue(
                                                text: arrayList[index]
                                                                ['inner_wo_data']
                                                            [innerindex]
                                                        ['wo_percentage']
                                                    .toString(),
                                                selection: TextSelection.collapsed(
                                                    offset: arrayList[index]
                                                                    ['inner_wo_data']
                                                                [innerindex]
                                                            ['wo_percentage']
                                                        .length))),
                                        style: normalText,
                                        obscureText: false,
                                        decoration: const InputDecoration(
                                          filled: true,
                                          fillColor: kcTextFieldColor,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 15.0, horizontal: 15.0),
                                          hintText: 'Percentage',
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.black54,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4.0),
                                              topRight: Radius.circular(4.0),
                                              bottomLeft: Radius.circular(4.0),
                                              bottomRight: Radius.circular(4.0),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.black54,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4.0),
                                              topRight: Radius.circular(4.0),
                                              bottomLeft: Radius.circular(4.0),
                                              bottomRight: Radius.circular(4.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  horizontalSpaceTiny,
                                  Expanded(
                                    child: SizedBox(
                                      height: 40.0,
                                      child: TextFormField(
                                        readOnly: true,
                                        onChanged: (text) {
                                          setState(() {
                                            arrayList[index]['inner_wo_data']
                                                    [innerindex]['wo_amount'] =
                                                text;
                                          });
                                          if (kDebugMode) {
                                            print(arrayList);
                                          }
                                        },
                                        style: normalText,
                                        controller: TextEditingController
                                            .fromValue(TextEditingValue(
                                                text: arrayList[index]
                                                                ['inner_wo_data']
                                                            [innerindex]
                                                        ['wo_amount']
                                                    .toString(),
                                                selection: TextSelection.collapsed(
                                                    offset: arrayList[index]
                                                                    ['inner_wo_data']
                                                                [innerindex]
                                                            ['wo_amount']
                                                        .length))),
                                        obscureText: false,
                                        decoration: const InputDecoration(
                                          filled: true,
                                          fillColor: kcTextFieldGreyColor,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 15.0, horizontal: 15.0),
                                          hintText: 'Approve Amount',
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.black54,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4.0),
                                              topRight: Radius.circular(4.0),
                                              bottomLeft: Radius.circular(4.0),
                                              bottomRight: Radius.circular(4.0),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.black54,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4.0),
                                              topRight: Radius.circular(4.0),
                                              bottomLeft: Radius.circular(4.0),
                                              bottomRight: Radius.circular(4.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  horizontalSpaceTiny,
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 5.0, 0.0),
                                        child: IconButton(
                                          iconSize: 30.0,
                                          icon: const Icon(
                                            Icons.add_circle_outline_outlined,
                                            color: Colors.black,
                                            size: 30.0,
                                          ),
                                          onPressed: () {
                                            if (kDebugMode) {
                                              print('Sublist Add clicked');
                                            }

                                            Map<String, String> dataSlabList = {
                                              "wo_name": "",
                                              "wo_percentage": "",
                                              "wo_amount": "",
                                              "slab_id": "0",
                                              "block_id": "0"
                                            };

                                            setState(() {
                                              arrayList[index]['inner_wo_data']
                                                  .insert(innerindex + 1,
                                                      dataSlabList);
                                              updateContent();
                                            });
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 5.0, 0.0),
                                        child: innerindex != 0
                                            ? IconButton(
                                                iconSize: 30.0,
                                                icon: const Icon(
                                                  Icons
                                                      .remove_circle_outline_outlined,
                                                  color: Colors.black,
                                                  size: 30.0,
                                                ),
                                                onPressed: () {
                                                  if (kDebugMode) {
                                                    print(
                                                        'Sublist remove pressed');
                                                  }
                                                  //setState(() {
                                                  arrayList[index]
                                                          ['inner_wo_data']
                                                      .removeAt(innerindex);
                                                  //});
                                                  updateContent();
                                                },
                                              )
                                            : const SizedBox(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          })
                    ],
                  ),
                ),
              ),
            ],
          ),
          children: <DragAndDropItem>[
            DragAndDropItem(
              child: const SizedBox(),
            ),
          ],
        );
      });
    });
  }

  late List<DragAndDropList> _contents;

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
        body: Container(
          color: Colors.white,
          child: SafeArea(
              child: flagcalled == true
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Row(
                        //   children: [
                        //     const Padding(
                        //       padding: EdgeInsetsDirectional.fromSTEB(
                        //           5.0, 10.0, 5.0, 10.0),
                        //       child: Text(
                        //         'REQUEST WORK ORDER - PERCENTAGE',
                        //         style: boldText13,
                        //       ),
                        //     ),
                        //     // InkWell(
                        //     //   onTap: () async {
                        //     //     if (widget.vendMagicLink! != "") {
                        //     //       print(widget.vendMagicLink!);
                        //     //       final uri = Uri.parse(widget.vendMagicLink!);
                        //     //       if (await canLaunchUrl(uri)) {
                        //     //         await launchUrl(uri);
                        //     //       } else {
                        //     //         throw 'Could not launch';
                        //     //       }
                        //     //     }
                        //     //   },
                        //     //   child: Container(
                        //     //     padding: const EdgeInsets.symmetric(
                        //     //         horizontal: 16, vertical: 4),
                        //     //     decoration: BoxDecoration(
                        //     //       borderRadius: BorderRadius.circular(8),
                        //     //       border: Border.all(color: Colors.black),
                        //     //     ),
                        //     //     child: const Text(
                        //     //       "INVITE VENDOR",
                        //     //       style: TextStyle(
                        //     //         color: Colors.black,
                        //     //       ),
                        //     //     ),
                        //     //   ),
                        //     // ),
                        //   ],
                        // ),
                        Center(
                          child: const Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                5.0, 10.0, 5.0, 10.0),
                            child: Text(
                              'REQUEST WORK ORDER - PERCENTAGE',
                              style: boldText13,
                            ),
                          ),
                        ),
                        const Divider(
                          height: 1.0,
                          thickness: 0.5,
                          indent: 1.0,
                          endIndent: 1.0,
                          color: Colors.black,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _linkSlabMasonryType(slabMasonryList),
                              verticalSpaceSmall,
                              const Divider(
                                height: 1.0,
                                thickness: 0.5,
                                indent: 1.0,
                                endIndent: 1.0,
                                color: Colors.black,
                              ),
                              SizedBox(
                                height: 70.0,
                                child: Column(
                                  children: [
                                    IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          horizontalSpaceSmall,
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  Text(
                                                      widget.isBua
                                                          ? 'B.U.A'
                                                          : 'Quantity',
                                                      style: boldText),
                                                  verticalSpaceSmall,
                                                  Text(widget.inputBu!,
                                                      style: boldText13)
                                                ],
                                              ),
                                            ),
                                          ),
                                          const VerticalDivider(
                                            width: 1.0,
                                            thickness: 1.0,
                                            indent: 10.0,
                                            endIndent: 0.0,
                                            color: Colors.black54,
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  const Text('Rate',
                                                      style: boldText),
                                                  verticalSpaceSmall,
                                                  Text(
                                                    '\u{20B9} ${widget.inputRate!}',
                                                    style: boldText13,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          const VerticalDivider(
                                            width: 1.0,
                                            thickness: 1.0,
                                            indent: 10.0,
                                            endIndent: 0.0,
                                            color: Colors.black54,
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  const Text(
                                                      'Total Value(100%)',
                                                      style: boldText),
                                                  verticalSpaceSmall,
                                                  Text(
                                                      '\u{20B9} ${(double.parse(widget.inputBu!) * double.parse(widget.inputRate!)).toStringAsFixed(2)}',
                                                      style: boldText13)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 1.0,
                                thickness: 0.5,
                                indent: 1.0,
                                endIndent: 1.0,
                                color: Colors.black,
                              ),
                              flagcenterAddbutton == true
                                  ? Center(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 100.0),
                                        child: InkWell(
                                          onTap: () {
                                            Map<String, dynamic> dataSlabList =
                                                {
                                              "inner_wo_data": [
                                                {
                                                  "wo_name": "",
                                                  "wo_percentage": "",
                                                  "wo_amount": "",
                                                  "slab_id": "0",
                                                  "block_id": "0"
                                                }
                                              ],
                                              "title": "",
                                            };

                                            setState(() {
                                              arrayList.insert(0, dataSlabList);
                                              flagcenterAddbutton = false;
                                              updateContent();
                                            });
                                          },
                                          child: SizedBox(
                                            width: 150,
                                            height: 150,
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Center(
                                                    child: IconButton(
                                                        onPressed: () {
                                                          Map<String, dynamic>
                                                              dataSlabList = {
                                                            "inner_wo_data": [
                                                              {
                                                                "wo_name": "",
                                                                "wo_percentage":
                                                                    "",
                                                                "wo_amount": "",
                                                                "slab_id": "0",
                                                                "block_id": "0"
                                                              }
                                                            ],
                                                            "title": "",
                                                          };

                                                          setState(() {
                                                            arrayList.insert(0,
                                                                dataSlabList);
                                                            flagcenterAddbutton =
                                                                false;
                                                            updateContent();
                                                          });
                                                        },
                                                        icon: const Icon(
                                                          Icons
                                                              .add_circle_outline_outlined,
                                                          size: 60,
                                                        )),
                                                  ),
                                                  verticalSpaceMedium,
                                                  verticalSpaceMedium,
                                                  const Center(
                                                      child: Text(
                                                    '         ADD TEMPLATE',
                                                    style: normalText,
                                                  ))
                                                ]),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      child: DragAndDropLists(
                                        children: _contents,
                                        onItemReorder: _onItemReorder,
                                        onListReorder: _onListReorder,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        verticalSpaceSmall,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(
                              height: 1.0,
                              thickness: 0.5,
                              indent: 1.0,
                              endIndent: 1.0,
                              color: Colors.black,
                            ),
                            verticalSpaceSmall,
                            SizedBox(
                              height: 40.0,
                              child: Column(
                                children: [
                                  IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        const Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.all(5.0),
                                            child: Center(
                                                child: Text('Total',
                                                    style: boldText13)),
                                          ),
                                        ),
                                        const VerticalDivider(
                                          width: 1.0,
                                          thickness: 1.0,
                                          indent: 5.0,
                                          endIndent: 0.0,
                                          color: Colors.black54,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Center(
                                                child: Text(
                                                    '${totalPercentage!.toStringAsFixed(2)} %',
                                                    style: boldText13)),
                                          ),
                                        ),
                                        const VerticalDivider(
                                          width: 1.0,
                                          thickness: 1.0,
                                          indent: 5.0,
                                          endIndent: 0.0,
                                          color: Colors.black54,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Center(
                                                child: Text(
                                                    '\u{20B9} ${totalAmount!.toStringAsFixed(2)}',
                                                    style: boldText13)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const Divider(
                              height: 1.0,
                              thickness: 0.5,
                              indent: 1.0,
                              endIndent: 1.0,
                              color: Colors.black,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Alert(
                                          closeIcon: const SizedBox(),
                                          padding: const EdgeInsets.only(
                                              top: 0.0, left: 18, right: 18),
                                          image: Image.asset(
                                              'images/Icon-512.png',
                                              height: 80,
                                              fit: BoxFit.fitWidth),
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
                                                    color: Colors.white,
                                                    fontSize: 15),
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
                                                    color: Colors.white,
                                                    fontSize: 15),
                                              ),
                                            ),
                                          ]).show();
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      decoration:
                                          BoxDecoration(color: Colors.black),
                                      child: Text(
                                        "SAVE AS DRAFT",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      print(
                                          '${totalPercentage}====== ${totalAmount} =====${TotalAmountActual}');
                                      if (totalPercentage!
                                          .isBetween(99.98, 101)) {
                                        if (totalAmount != TotalAmountActual) {
                                          var diff =
                                              TotalAmountActual - totalAmount!;
                                          print(
                                              '${diff}******${(diff / 100).toStringAsFixed(2)}');
                                          print(
                                              '------------------------------------');

                                          //   Alert(
                                          //       closeIcon: const SizedBox(),
                                          //       padding: const EdgeInsets.symmetric(
                                          //           horizontal: 20.0, vertical: 10.0),
                                          //       image: Image.asset(
                                          //           'images/Icon-512.png',
                                          //           height: 80,
                                          //           fit: BoxFit.fitWidth),
                                          //       style: const AlertStyle(
                                          //           titleTextAlign: TextAlign.center,
                                          //           descTextAlign: TextAlign.center,
                                          //           descStyle: TextStyle(
                                          //               fontWeight: FontWeight.normal,
                                          //               fontSize: 16),
                                          //           isCloseButton: true),
                                          //       context: context,
                                          //       desc:
                                          //           'The difference amount of \u{20B9} ${diff.toStringAsFixed(2)} will be \nadjusted in your final payment template',
                                          //       alertAnimation: fadeAlertAnimation,
                                          //       buttons: [
                                          //         DialogButton(
                                          //           onPressed: () {
                                          //             var arrlist = arrayList[
                                          //                     arrayList.length - 1]
                                          //                 ['inner_wo_data'];
                                          //             arrayList[arrayList.length - 1][
                                          //                             'inner_wo_data']
                                          //                         [arrlist.length - 1]
                                          //                     ["wo_amount"] =
                                          //                 '${(double.parse(arrayList[arrayList.length - 1]['inner_wo_data'][arrlist.length - 1]["wo_amount"]) + diff).toStringAsFixed(2)}';

                                          //             //if (flagSelectedTab == 'Custom') {
                                          //             //arrayList[arrayList.length - 1]
                                          //             //  .payment_amount =
                                          //             //'${double.parse(arrayList[arrayList.length - 1].payment_amount!) + diff}';
                                          //             // }
                                          //             double totPercentage1 = 0.00;
                                          //             double totAmount = 0.00;

                                          //             for (var i = 0;
                                          //                 i < arrayList.length;
                                          //                 i++) {
                                          //               var arrlist = arrayList[i]
                                          //                   ['inner_wo_data'];
                                          //               for (var j = 0;
                                          //                   j < arrlist.length;
                                          //                   j++) {
                                          //                 var totPer = arrlist[j]
                                          //                         ['wo_percentage']
                                          //                     .toString();
                                          //                 String totAmt =
                                          //                     double.parse(arrlist[j]
                                          //                             ['wo_amount'])
                                          //                         .toStringAsFixed(2);
                                          //                 if (totPer != '') {
                                          //                   totPercentage1 =
                                          //                       totPercentage1 +
                                          //                           double.parse(num
                                          //                                   .parse(
                                          //                                       totPer)
                                          //                               .toStringAsFixed(
                                          //                                   2));
                                          //                 }
                                          //                 // print(
                                          //                 //     '${totPercentage1}-----------------------');
                                          //                 if (totAmt != '') {
                                          //                   totAmount = totAmount +
                                          //                       double.parse(num
                                          //                               .parse(totAmt)
                                          //                           .toStringAsFixed(
                                          //                               2));
                                          //                 }
                                          //               }
                                          //             }
                                          //             // setState(() {
                                          //             //   totalPercentage = double
                                          //             //       .parse(totPercentage1
                                          //             //           .toStringAsFixed(2));
                                          //             //   totalAmount = totAmount;
                                          //             // });

                                          //             updateContent();
                                          //             Navigator.pop(context);
                                          //           },
                                          //           color: Colors.black,
                                          //           child: const Text(
                                          //             "CLOSE",
                                          //             style: TextStyle(
                                          //                 color: Colors.white,
                                          //                 fontSize: 15),
                                          //           ),
                                          //         ),
                                          //       ]).show();

                                          Alert(
                                              closeIcon: const SizedBox(),
                                              padding: const EdgeInsets.only(
                                                  top: 0.0),
                                              image: Image.asset(
                                                  'images/Icon-512.png',
                                                  height: 80,
                                                  fit: BoxFit.fitWidth),
                                              style: const AlertStyle(
                                                  titleTextAlign:
                                                      TextAlign.center,
                                                  descTextAlign:
                                                      TextAlign.center,
                                                  descStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 16),
                                                  isCloseButton: true),
                                              context: context,
                                              desc:
                                                  'Please match total percentage to 100.',
                                              alertAnimation:
                                                  fadeAlertAnimation,
                                              buttons: [
                                                DialogButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  color: Colors.black,
                                                  child: const Text(
                                                    "CLOSE",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15),
                                                  ),
                                                ),
                                              ]).show();
                                        } else {
                                          var arrActualListSent = [];
                                          for (var i = 0;
                                              i < arrayList.length;
                                              i++) {
                                            var arrlist =
                                                arrayList[i]['inner_wo_data'];
                                            for (var j = 0;
                                                j < arrlist.length;
                                                j++) {
                                              var percentage = arrlist[j]
                                                      ['wo_percentage']
                                                  .toString();
                                              if (percentage != '') {
                                                arrActualListSent
                                                    .add(arrayList[i]);
                                                break;
                                              }
                                            }
                                          }
                                          int errTxt = 0;
                                          for (var i = 0;
                                              i < arrayList.length;
                                              i++) {
                                            var arrlist =
                                                arrayList[i]['inner_wo_data'];
                                            for (var j = 0;
                                                j < arrlist.length;
                                                j++) {
                                              String tttt = arrlist[j]
                                                      ['wo_name']
                                                  .toString();
                                              print(tttt);
                                              if (tttt == '') {
                                                errTxt++;
                                                // arrActualListSent
                                                //     .add(arrayList[i]);

                                                break;
                                              }
                                            }
                                          }
                                          if (errTxt != 0) { 
                                            Alert(
                                                closeIcon: const SizedBox(),
                                                padding: const EdgeInsets.only(
                                                    top: 0.0),
                                                image: Image.asset(
                                                    'images/Icon-512.png',
                                                    height: 80,
                                                    fit: BoxFit.fitWidth),
                                                style: const AlertStyle(
                                                    titleTextAlign:
                                                        TextAlign.center,
                                                    descTextAlign:
                                                        TextAlign.center,
                                                    descStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 16),
                                                    isCloseButton: true),
                                                context: context,
                                                desc: 'Please Enter Subtitle',
                                                alertAnimation:
                                                    fadeAlertAnimation,
                                                buttons: [
                                                  DialogButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    color: Colors.black,
                                                    child: const Text(
                                                      "CLOSE",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                ]).show();
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) {
                                                  return WorkOrderPercentagePreview(
                                                      projectId:
                                                          widget.projectId!,
                                                      towarId: widget.towarId!,
                                                      projectName:
                                                          widget.projectName!,
                                                      selectedConsultantType: widget
                                                          .selectedConsultantType,
                                                      selectedConsultantCompany:
                                                          widget
                                                              .selectedConsultantCompany,
                                                      selectedRequirementDate:
                                                          widget
                                                              .selectedRequirementDate,
                                                      selectedGST:
                                                          widget.selectedGST,
                                                      inputBu: widget.inputBu,
                                                      inputNote:
                                                          widget.inputNote,
                                                      inputRate:
                                                          widget.inputRate,
                                                      inputRequirementFor: widget
                                                          .inputRequirementFor,
                                                      arrayFiles:
                                                          widget.arrayFiles,
                                                      totalPercentage:
                                                          totalPercentage!,
                                                      totalAmount: totalAmount!,
                                                      arrayList:
                                                          arrActualListSent);
                                                },
                                              ),
                                            ).then((value) => {
                                                  checkNavigation(),
                                                });
                                          }
                                        }
                                      } else if (totalPercentage != 100) {
                                        Alert(
                                            closeIcon: const SizedBox(),
                                            padding:
                                                const EdgeInsets.only(top: 0.0),
                                            image: Image.asset(
                                                'images/Icon-512.png',
                                                height: 80,
                                                fit: BoxFit.fitWidth),
                                            style: const AlertStyle(
                                                titleTextAlign:
                                                    TextAlign.center,
                                                descTextAlign: TextAlign.center,
                                                descStyle: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 16),
                                                isCloseButton: true),
                                            context: context,
                                            desc:
                                                'Please match total percentage to 100.',
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
                                                      color: Colors.white,
                                                      fontSize: 15),
                                                ),
                                              ),
                                            ]).show();
                                      } else {
                                        bool errorflag = false;
                                        var errorMessage = '';
                                        if (txtLinkSlabMasonry
                                            .text.isNotEmpty) {
                                          for (var i = 0;
                                              i < arrayList.length;
                                              i++) {
                                            var arrlist =
                                                arrayList[i]['inner_wo_data'];
                                            for (var j = 0;
                                                j < arrlist.length;
                                                j++) {
                                              var title = arrlist[j]['wo_name']
                                                  .toString();
                                              var percentage = arrlist[j]
                                                      ['wo_percentage']
                                                  .toString();
                                              if (percentage != '') {
                                                if (title == '') {
                                                  errorflag = true;
                                                  errorMessage =
                                                      'Please enter subtitle.';
                                                }
                                              }
                                            }
                                          }
                                        } else {
                                          for (var i = 0;
                                              i < arrayList.length;
                                              i++) {
                                            var arrlist =
                                                arrayList[i]['inner_wo_data'];
                                            for (var j = 0;
                                                j < arrlist.length;
                                                j++) {
                                              var title = arrlist[j]['wo_name']
                                                  .toString();
                                              var percentage = arrlist[j]
                                                      ['wo_percentage']
                                                  .toString();
                                              if (title != '' ||
                                                  percentage != '') {
                                                if (title == '') {
                                                  errorflag = true;
                                                  errorMessage =
                                                      'Please enter subtitle.';
                                                } else if (percentage == '') {
                                                  errorflag = true;
                                                  errorMessage =
                                                      'Please enter percentage.';
                                                }
                                              }
                                            }
                                          }
                                        }
                                        if (errorflag == true) {
                                          Alert(
                                              closeIcon: const SizedBox(),
                                              padding: const EdgeInsets.only(
                                                  top: 0.0),
                                              image: Image.asset(
                                                  'images/Icon-512.png',
                                                  height: 80,
                                                  fit: BoxFit.fitWidth),
                                              style: const AlertStyle(
                                                  titleTextAlign:
                                                      TextAlign.center,
                                                  descTextAlign:
                                                      TextAlign.center,
                                                  descStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 16),
                                                  isCloseButton: true),
                                              context: context,
                                              desc: errorMessage,
                                              alertAnimation:
                                                  fadeAlertAnimation,
                                              buttons: [
                                                DialogButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  color: Colors.black,
                                                  child: const Text(
                                                    "CLOSE",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15),
                                                  ),
                                                ),
                                              ]).show();
                                        } else {
                                          if (kDebugMode) {
                                            print('NEXT PAGE');
                                          }
                                          var arrActualListSent = [];
                                          for (var i = 0;
                                              i < arrayList.length;
                                              i++) {
                                            var arrlist =
                                                arrayList[i]['inner_wo_data'];
                                            for (var j = 0;
                                                j < arrlist.length;
                                                j++) {
                                              var percentage = arrlist[j]
                                                      ['wo_percentage']
                                                  .toString();
                                              if (percentage != '') {
                                                arrActualListSent
                                                    .add(arrayList[i]);
                                                break;
                                              }
                                            }
                                          }
                                          if (kDebugMode) {
                                            print('----arrActualListSent-----');
                                            print('arrActualListSent');
                                          }

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) {
                                                return WorkOrderPercentagePreview(
                                                    projectId:
                                                        widget.projectId!,
                                                    towarId: widget.towarId!,
                                                    projectName:
                                                        widget.projectName!,
                                                    selectedConsultantType: widget
                                                        .selectedConsultantType,
                                                    selectedConsultantCompany:
                                                        widget
                                                            .selectedConsultantCompany,
                                                    selectedRequirementDate: widget
                                                        .selectedRequirementDate,
                                                    selectedGST:
                                                        widget.selectedGST,
                                                    inputBu: widget.inputBu,
                                                    inputNote: widget.inputNote,
                                                    inputRate: widget.inputRate,
                                                    inputRequirementFor: widget
                                                        .inputRequirementFor,
                                                    arrayFiles:
                                                        widget.arrayFiles,
                                                    totalPercentage:
                                                        totalPercentage!,
                                                    totalAmount: totalAmount!,
                                                    arrayList:
                                                        arrActualListSent);
                                              },
                                            ),
                                          ).then((value) => {
                                                checkNavigation(),
                                              });
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          border: Border(
                                              left: BorderSide(
                                                  color: Colors.white))),
                                      child: Text(
                                        "PREVIEW WORK ORDER",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                //    SimpleButton(
                                //     lblText: 'NEXT',
                                //     color: kcPrimaryColor,
                                //     onTap: () {
                                //       print(
                                //           '${totalPercentage}====== ${totalAmount} =====${TotalAmountActual}');
                                //       if (totalPercentage!.isBetween(99.98, 101)) {
                                //         if (totalAmount != TotalAmountActual) {
                                //           var diff =
                                //               TotalAmountActual - totalAmount!;
                                //           print(
                                //               '${diff}******${(diff / 100).toStringAsFixed(2)}');
                                //           print(
                                //               '------------------------------------');

                                //           //   Alert(
                                //           //       closeIcon: const SizedBox(),
                                //           //       padding: const EdgeInsets.symmetric(
                                //           //           horizontal: 20.0, vertical: 10.0),
                                //           //       image: Image.asset(
                                //           //           'images/Icon-512.png',
                                //           //           height: 80,
                                //           //           fit: BoxFit.fitWidth),
                                //           //       style: const AlertStyle(
                                //           //           titleTextAlign: TextAlign.center,
                                //           //           descTextAlign: TextAlign.center,
                                //           //           descStyle: TextStyle(
                                //           //               fontWeight: FontWeight.normal,
                                //           //               fontSize: 16),
                                //           //           isCloseButton: true),
                                //           //       context: context,
                                //           //       desc:
                                //           //           'The difference amount of \u{20B9} ${diff.toStringAsFixed(2)} will be \nadjusted in your final payment template',
                                //           //       alertAnimation: fadeAlertAnimation,
                                //           //       buttons: [
                                //           //         DialogButton(
                                //           //           onPressed: () {
                                //           //             var arrlist = arrayList[
                                //           //                     arrayList.length - 1]
                                //           //                 ['inner_wo_data'];
                                //           //             arrayList[arrayList.length - 1][
                                //           //                             'inner_wo_data']
                                //           //                         [arrlist.length - 1]
                                //           //                     ["wo_amount"] =
                                //           //                 '${(double.parse(arrayList[arrayList.length - 1]['inner_wo_data'][arrlist.length - 1]["wo_amount"]) + diff).toStringAsFixed(2)}';

                                //           //             //if (flagSelectedTab == 'Custom') {
                                //           //             //arrayList[arrayList.length - 1]
                                //           //             //  .payment_amount =
                                //           //             //'${double.parse(arrayList[arrayList.length - 1].payment_amount!) + diff}';
                                //           //             // }
                                //           //             double totPercentage1 = 0.00;
                                //           //             double totAmount = 0.00;

                                //           //             for (var i = 0;
                                //           //                 i < arrayList.length;
                                //           //                 i++) {
                                //           //               var arrlist = arrayList[i]
                                //           //                   ['inner_wo_data'];
                                //           //               for (var j = 0;
                                //           //                   j < arrlist.length;
                                //           //                   j++) {
                                //           //                 var totPer = arrlist[j]
                                //           //                         ['wo_percentage']
                                //           //                     .toString();
                                //           //                 String totAmt =
                                //           //                     double.parse(arrlist[j]
                                //           //                             ['wo_amount'])
                                //           //                         .toStringAsFixed(2);
                                //           //                 if (totPer != '') {
                                //           //                   totPercentage1 =
                                //           //                       totPercentage1 +
                                //           //                           double.parse(num
                                //           //                                   .parse(
                                //           //                                       totPer)
                                //           //                               .toStringAsFixed(
                                //           //                                   2));
                                //           //                 }
                                //           //                 // print(
                                //           //                 //     '${totPercentage1}-----------------------');
                                //           //                 if (totAmt != '') {
                                //           //                   totAmount = totAmount +
                                //           //                       double.parse(num
                                //           //                               .parse(totAmt)
                                //           //                           .toStringAsFixed(
                                //           //                               2));
                                //           //                 }
                                //           //               }
                                //           //             }
                                //           //             // setState(() {
                                //           //             //   totalPercentage = double
                                //           //             //       .parse(totPercentage1
                                //           //             //           .toStringAsFixed(2));
                                //           //             //   totalAmount = totAmount;
                                //           //             // });

                                //           //             updateContent();
                                //           //             Navigator.pop(context);
                                //           //           },
                                //           //           color: Colors.black,
                                //           //           child: const Text(
                                //           //             "CLOSE",
                                //           //             style: TextStyle(
                                //           //                 color: Colors.white,
                                //           //                 fontSize: 15),
                                //           //           ),
                                //           //         ),
                                //           //       ]).show();

                                //           Alert(
                                //               closeIcon: const SizedBox(),
                                //               padding:
                                //                   const EdgeInsets.only(top: 0.0),
                                //               image: Image.asset(
                                //                   'images/Icon-512.png',
                                //                   height: 80,
                                //                   fit: BoxFit.fitWidth),
                                //               style: const AlertStyle(
                                //                   titleTextAlign: TextAlign.center,
                                //                   descTextAlign: TextAlign.center,
                                //                   descStyle: TextStyle(
                                //                       fontWeight: FontWeight.normal,
                                //                       fontSize: 16),
                                //                   isCloseButton: true),
                                //               context: context,
                                //               desc:
                                //                   'Please match total percentage to 100.',
                                //               alertAnimation: fadeAlertAnimation,
                                //               buttons: [
                                //                 DialogButton(
                                //                   onPressed: () {
                                //                     Navigator.pop(context);
                                //                   },
                                //                   color: Colors.black,
                                //                   child: const Text(
                                //                     "CLOSE",
                                //                     style: TextStyle(
                                //                         color: Colors.white,
                                //                         fontSize: 15),
                                //                   ),
                                //                 ),
                                //               ]).show();
                                //         } else {
                                //           var arrActualListSent = [];
                                //           for (var i = 0;
                                //               i < arrayList.length;
                                //               i++) {
                                //             var arrlist =
                                //                 arrayList[i]['inner_wo_data'];
                                //             for (var j = 0;
                                //                 j < arrlist.length;
                                //                 j++) {
                                //               var percentage = arrlist[j]
                                //                       ['wo_percentage']
                                //                   .toString();
                                //               if (percentage != '') {
                                //                 arrActualListSent.add(arrayList[i]);
                                //                 break;
                                //               }
                                //             }
                                //           }

                                //           Navigator.push(
                                //             context,
                                //             MaterialPageRoute(
                                //               builder: (_) {
                                //                 return WorkOrderPercentagePreview(
                                //                     projectId: widget.projectId!,
                                //                     towarId: widget.towarId!,
                                //                     projectName:
                                //                         widget.projectName!,
                                //                     selectedConsultantType: widget
                                //                         .selectedConsultantType,
                                //                     selectedConsultantCompany: widget
                                //                         .selectedConsultantCompany,
                                //                     selectedRequirementDate: widget
                                //                         .selectedRequirementDate,
                                //                     selectedGST: widget.selectedGST,
                                //                     inputBu: widget.inputBu,
                                //                     inputNote: widget.inputNote,
                                //                     inputRate: widget.inputRate,
                                //                     inputRequirementFor:
                                //                         widget.inputRequirementFor,
                                //                     arrayFiles: widget.arrayFiles,
                                //                     totalPercentage:
                                //                         totalPercentage!,
                                //                     totalAmount: totalAmount!,
                                //                     arrayList: arrActualListSent);
                                //               },
                                //             ),
                                //           ).then((value) => {
                                //                 checkNavigation(),
                                //               });
                                //         }
                                //       } else if (totalPercentage != 100) {
                                //         Alert(
                                //             closeIcon: const SizedBox(),
                                //             padding:
                                //                 const EdgeInsets.only(top: 0.0),
                                //             image: Image.asset(
                                //                 'images/Icon-512.png',
                                //                 height: 80,
                                //                 fit: BoxFit.fitWidth),
                                //             style: const AlertStyle(
                                //                 titleTextAlign: TextAlign.center,
                                //                 descTextAlign: TextAlign.center,
                                //                 descStyle: TextStyle(
                                //                     fontWeight: FontWeight.normal,
                                //                     fontSize: 16),
                                //                 isCloseButton: true),
                                //             context: context,
                                //             desc:
                                //                 'Please match total percentage to 100.',
                                //             alertAnimation: fadeAlertAnimation,
                                //             buttons: [
                                //               DialogButton(
                                //                 onPressed: () {
                                //                   Navigator.pop(context);
                                //                 },
                                //                 color: Colors.black,
                                //                 child: const Text(
                                //                   "CLOSE",
                                //                   style: TextStyle(
                                //                       color: Colors.white,
                                //                       fontSize: 15),
                                //                 ),
                                //               ),
                                //             ]).show();
                                //       } else {
                                //         bool errorflag = false;
                                //         var errorMessage = '';
                                //         if (txtLinkSlabMasonry.text.isNotEmpty) {
                                //           for (var i = 0;
                                //               i < arrayList.length;
                                //               i++) {
                                //             var arrlist =
                                //                 arrayList[i]['inner_wo_data'];
                                //             for (var j = 0;
                                //                 j < arrlist.length;
                                //                 j++) {
                                //               var title =
                                //                   arrlist[j]['wo_name'].toString();
                                //               var percentage = arrlist[j]
                                //                       ['wo_percentage']
                                //                   .toString();
                                //               if (percentage != '') {
                                //                 if (title == '') {
                                //                   errorflag = true;
                                //                   errorMessage =
                                //                       'Please enter subtitle.';
                                //                 }
                                //               }
                                //             }
                                //           }
                                //         } else {
                                //           for (var i = 0;
                                //               i < arrayList.length;
                                //               i++) {
                                //             var arrlist =
                                //                 arrayList[i]['inner_wo_data'];
                                //             for (var j = 0;
                                //                 j < arrlist.length;
                                //                 j++) {
                                //               var title =
                                //                   arrlist[j]['wo_name'].toString();
                                //               var percentage = arrlist[j]
                                //                       ['wo_percentage']
                                //                   .toString();
                                //               if (title != '' || percentage != '') {
                                //                 if (title == '') {
                                //                   errorflag = true;
                                //                   errorMessage =
                                //                       'Please enter subtitle.';
                                //                 } else if (percentage == '') {
                                //                   errorflag = true;
                                //                   errorMessage =
                                //                       'Please enter percentage.';
                                //                 }
                                //               }
                                //             }
                                //           }
                                //         }
                                //         if (errorflag == true) {
                                //           Alert(
                                //               closeIcon: const SizedBox(),
                                //               padding:
                                //                   const EdgeInsets.only(top: 0.0),
                                //               image: Image.asset(
                                //                   'images/Icon-512.png',
                                //                   height: 80,
                                //                   fit: BoxFit.fitWidth),
                                //               style: const AlertStyle(
                                //                   titleTextAlign: TextAlign.center,
                                //                   descTextAlign: TextAlign.center,
                                //                   descStyle: TextStyle(
                                //                       fontWeight: FontWeight.normal,
                                //                       fontSize: 16),
                                //                   isCloseButton: true),
                                //               context: context,
                                //               desc: errorMessage,
                                //               alertAnimation: fadeAlertAnimation,
                                //               buttons: [
                                //                 DialogButton(
                                //                   onPressed: () =>
                                //                       Navigator.pop(context),
                                //                   color: Colors.black,
                                //                   child: const Text(
                                //                     "CLOSE",
                                //                     style: TextStyle(
                                //                         color: Colors.white,
                                //                         fontSize: 15),
                                //                   ),
                                //                 ),
                                //               ]).show();
                                //         } else {
                                //           if (kDebugMode) {
                                //             print('NEXT PAGE');
                                //           }
                                //           var arrActualListSent = [];
                                //           for (var i = 0;
                                //               i < arrayList.length;
                                //               i++) {
                                //             var arrlist =
                                //                 arrayList[i]['inner_wo_data'];
                                //             for (var j = 0;
                                //                 j < arrlist.length;
                                //                 j++) {
                                //               var percentage = arrlist[j]
                                //                       ['wo_percentage']
                                //                   .toString();
                                //               if (percentage != '') {
                                //                 arrActualListSent.add(arrayList[i]);
                                //                 break;
                                //               }
                                //             }
                                //           }
                                //           if (kDebugMode) {
                                //             print('----arrActualListSent-----');
                                //             print('arrActualListSent');
                                //           }

                                //           Navigator.push(
                                //             context,
                                //             MaterialPageRoute(
                                //               builder: (_) {
                                //                 return WorkOrderPercentagePreview(
                                //                     projectId: widget.projectId!,
                                //                     towarId: widget.towarId!,
                                //                     projectName:
                                //                         widget.projectName!,
                                //                     selectedConsultantType: widget
                                //                         .selectedConsultantType,
                                //                     selectedConsultantCompany: widget
                                //                         .selectedConsultantCompany,
                                //                     selectedRequirementDate: widget
                                //                         .selectedRequirementDate,
                                //                     selectedGST: widget.selectedGST,
                                //                     inputBu: widget.inputBu,
                                //                     inputNote: widget.inputNote,
                                //                     inputRate: widget.inputRate,
                                //                     inputRequirementFor:
                                //                         widget.inputRequirementFor,
                                //                     arrayFiles: widget.arrayFiles,
                                //                     totalPercentage:
                                //                         totalPercentage!,
                                //                     totalAmount: totalAmount!,
                                //                     arrayList: arrActualListSent);
                                //               },
                                //             ),
                                //           ).then((value) => {
                                //                 checkNavigation(),
                                //               });
                                //         }
                                //       }
                                //     },
                                //                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
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
                      // CircularProgressIndicator()
                    )),
        ));
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      var movedItem = _contents[oldListIndex].children.removeAt(oldItemIndex);
      _contents[newListIndex].children.insert(newItemIndex, movedItem);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = _contents.removeAt(oldListIndex);
      _contents.insert(newListIndex, movedList);
    });
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

  Future<void> _onRefresh() {
    Completer<void> completer = Completer<void>();
    return completer.future;
  }

  Widget _linkSlabMasonryType(List<ListElement>? slabList) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /*Padding(
            padding: const EdgeInsets.only(left: 250.0, right: 250.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SearchChoices.multiple(
                style: normalText,
                doneButton: 'Done',
                items: slabMasonryItems,
                selectedItems: selectedItemsMultiDialog,
                hint: const Text(
                  'Link to Slab and Masonry',
                  style: TextStyle(
                      fontFamily: 'HelveticaNeue',
                      fontSize: 17,
                      color: Colors.black),
                ),
                searchHint: "Select Link to Slab and Masonry",
                onChanged: (value) {
                  if (kDebugMode) {
                    print('value');
                    print(value);
                    selectedItemsMultiDialog = value;
                    if (kDebugMode) {
                      print('selectedItemsMultiDialog');
                      print(selectedItemsMultiDialog);
                    }

                    if (selectedItemsMultiDialog.isNotEmpty) {
                      if (selectedItemsMultiDialog.length == 1) {
                        for (var i = 0;
                            i < selectedItemsMultiDialog.length;
                            i++) {
                          if (kDebugMode) {
                            print(selectedItemsMultiDialog[i]);
                          }
                          if (selectedItemsMultiDialog[i] == 0) {
                            //Slab
                            arrayList = [];

                            List<Slablist>? arraySublist =
                                slabMasonryList![0].slablist;
                            if (arraySublist!.isNotEmpty) {
                              for (var j = 0; j < arraySublist.length; j++) {
                                if (kDebugMode) {
                                  print(arraySublist[j].slabName!);
                                }
                                Map<String, dynamic> dictslabList = {
                                  "inner_wo_data": [
                                    {
                                      "wo_name": arraySublist[j].slabName!,
                                      "wo_percentage": "",
                                      "wo_amount": "",
                                      "slab_id": arraySublist[j].slabId!,
                                      "block_id": "0"
                                    }
                                  ],
                                  "title": "",
                                };

                                setState(() {
                                  arrayList.add(dictslabList);
                                  totalPercentage = 0.0;
                                  totalAmount = 0.0;
                                  updateContent();
                                });
                              }
                            }
                          } else {
                            //Masonry
                            arrayList = [];
                            List<Masonrylist>? arraySublist =
                                slabMasonryList![1].masonrylist;

                            if (arraySublist!.isNotEmpty) {
                              for (var j = 0; j < arraySublist.length; j++) {
                                if (kDebugMode) {
                                  print(arraySublist[j].masonryName!);
                                }
                                String headerTitle = arraySublist[j].masonryName!;

                                Map<String, dynamic> dictslabList = {
                                  "inner_wo_data": List<Map<String, dynamic>>,
                                  "title": headerTitle,
                                };
                                List<Map<String, dynamic>> innerdata = [];
                                List<Block>? arrayblocklist =
                                    arraySublist[j].block;
                                if (kDebugMode) {
                                  print(arrayblocklist);
                                }
                                for (var k = 0; k < arrayblocklist!.length; k++) {
                                  if (kDebugMode) {
                                    print(arrayblocklist[k].blockName!);
                                  }

                                  innerdata.add({
                                    "wo_name": arrayblocklist[k].blockName!,
                                    "wo_percentage": "",
                                    "wo_amount": "",
                                    "slab_id": "0",
                                    "block_id": arrayblocklist[k].blockId!
                                  });
                                }
                                dictslabList["inner_wo_data"] = innerdata;

                                if (kDebugMode) {
                                  print(arrayList);
                                }
                                setState(() {
                                  arrayList.add(dictslabList);
                                  totalPercentage = 0.0;
                                  totalAmount = 0.0;
                                  updateContent();
                                });
                              }
                            }
                          }
                        }
                      } else if (selectedItemsMultiDialog.length == 2) {
                        // BOTH
                        for (var i = 0;
                            i < selectedItemsMultiDialog.length;
                            i++) {
                          if (i == 0) {
                            // for both slab
                            arrayList = [];
                            List<Slablist>? arraySublist =
                                slabMasonryList![0].slablist;
                            if (arraySublist!.isNotEmpty) {
                              for (var j = 0; j < arraySublist.length; j++) {
                                if (kDebugMode) {
                                  print(arraySublist[j].slabName!);
                                }
                                Map<String, dynamic> dictslabList = {
                                  "inner_wo_data": [
                                    {
                                      "wo_name": arraySublist[j].slabName!,
                                      "wo_percentage": "",
                                      "wo_amount": "",
                                      "slab_id": arraySublist[j].slabId!,
                                      "block_id": "0"
                                    }
                                  ],
                                  "title": "",
                                };

                                setState(() {
                                  arrayList.add(dictslabList);
                                  totalPercentage = 0.0;
                                  totalAmount = 0.0;
                                  updateContent();
                                });
                              }
                            }
                          } else {
                            // for both Masonry
                            if (arrayList.isNotEmpty) {
                              for (var m = 0; m < arrayList.length; m++) {
                                List<Masonrylist>? arraySublist =
                                    slabMasonryList![1].masonrylist;

                                if (arraySublist!.isNotEmpty) {
                                  for (var j = 0; j < arraySublist.length; j++) {
                                    List<Block>? arrayblocklist =
                                        arraySublist[j].block;
                                    for (var k = 0;
                                        k < arrayblocklist!.length;
                                        k++) {
                                      Map<String, String> dataSublist = {
                                        "wo_name": arrayblocklist[k].blockName!,
                                        "wo_percentage": "",
                                        "wo_amount": "",
                                        "slab_id": "0",
                                        "block_id": arrayblocklist[k].blockId!
                                      };
                                      setState(() {
                                        arrayList[m]["inner_wo_data"]
                                            .insert(k + 1, dataSublist);
                                        updateContent();
                                      });
                                    }
                                    break;
                                  }
                                }
                              }
                            }
                            setState(() {
                              totalPercentage = 0.0;
                              totalAmount = 0.0;
                            });
                          }
                        }
                      }
                    } else {
                      Map<String, dynamic> dataSlabList = {
                        "inner_wo_data": [
                          {
                            "wo_name": "",
                            "wo_percentage": "",
                            "wo_amount": "",
                            "slab_id": "0",
                            "block_id": "0"
                          }
                        ],
                        "title": "",
                      };

                      setState(() {
                        arrayList = [];
                        arrayList.add(dataSlabList);
                        totalPercentage = 0.0;
                        totalAmount = 0.0;
                        updateContent();
                      });
                    }
                  }
                },
                padding: selectedItemsMultiDialog.isEmpty ? 10.0 : 0.0,
                dialogBox: false,
                isExpanded: true,
                menuConstraints:
                    BoxConstraints.tight(const Size.fromHeight(230.0)),
                onClear: () {
                  setState(() {
                    selectedItemsMultiDialog = [];
                  });
                },
                underline: Container(
                  height: 1.0,
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.white, width: 0.0))),
                ),
              ),
            ),
          ),*/
          const SizedBox(
            width: 230.0,
            height: 40.0,
            child: Padding(
              padding: EdgeInsets.only(top: 15.0),
              child: Text('Link to Slab and Masonry',
                  style: TextStyle(fontSize: 15, color: Colors.black)),
            ),
          ),
          horizontalSpaceSmall,
          Expanded(
            child: InkWell(
              onTap: () {
                slabList!.isNotEmpty
                    ? showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            contentPadding: const EdgeInsets.all(0.0),
                            content: StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height /
                                        1.5,
                                    width:
                                        MediaQuery.of(context).size.width / 1.5,
                                    color: Colors.white,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Text(
                                              "Select Slab/Masonry or Both",
                                              style: boldText,
                                            ),
                                          ),
                                        ),
                                        verticalSpaceTiny,
                                        Expanded(
                                          child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              itemCount: slabList.length,
                                              itemBuilder:
                                                  (context, int index) {
                                                return InkWell(
                                                  onTap: () {
                                                    String name = '';
                                                    setState(() {
                                                      if (slabList[index]
                                                                  .selected ==
                                                              '' ||
                                                          slabList[index]
                                                                  .selected ==
                                                              '0') {
                                                        slabList[index]
                                                            .selected = '1';
                                                      } else {
                                                        slabList[index]
                                                            .selected = '0';
                                                      }
                                                      for (int i = 0;
                                                          i < slabList.length;
                                                          i++) {
                                                        if (slabList[i]
                                                                .selected ==
                                                            '1') {
                                                          if (i == 0) {
                                                            name = slabList[i]
                                                                .name!;
                                                          } else {
                                                            if (name == '') {
                                                              name = slabList[i]
                                                                  .name!;
                                                            } else {
                                                              name =
                                                                  '$name, ${slabList[i].name!}';
                                                            }
                                                          }
                                                        }
                                                      }
                                                      txtLinkSlabMasonry.text =
                                                          name;
                                                    });

                                                    if (name == 'Slab') {
                                                      //Slab
                                                      arrayList = [];

                                                      List<Slablist>?
                                                          arraySublist =
                                                          slabMasonryList![0]
                                                              .slablist;
                                                      if (arraySublist!
                                                          .isNotEmpty) {
                                                        for (var j = 0;
                                                            j <
                                                                arraySublist
                                                                    .length;
                                                            j++) {
                                                          if (kDebugMode) {
                                                            print(
                                                                arraySublist[j]
                                                                    .slabName!);
                                                          }
                                                          Map<String, dynamic>
                                                              dictslabList = {
                                                            "inner_wo_data": [
                                                              {
                                                                "wo_name":
                                                                    arraySublist[
                                                                            j]
                                                                        .slabName!,
                                                                "wo_percentage":
                                                                    "",
                                                                "wo_amount": "",
                                                                "slab_id":
                                                                    arraySublist[
                                                                            j]
                                                                        .slabId!,
                                                                "block_id": "0"
                                                              }
                                                            ],
                                                            "title": "",
                                                          };

                                                          setState(() {
                                                            arrayList.add(
                                                                dictslabList);
                                                            totalPercentage =
                                                                0.0;
                                                            totalAmount = 0.0;
                                                            updateContent();
                                                          });
                                                        }
                                                      }
                                                    } else if (name ==
                                                        'Masonry') {
                                                      //Masonry
                                                      arrayList = [];
                                                      List<Masonrylist>?
                                                          arraySublist =
                                                          slabMasonryList![1]
                                                              .masonrylist;

                                                      if (arraySublist!
                                                          .isNotEmpty) {
                                                        for (var j = 0;
                                                            j <
                                                                arraySublist
                                                                    .length;
                                                            j++) {
                                                          if (kDebugMode) {
                                                            print(arraySublist[
                                                                    j]
                                                                .masonryName!);
                                                          }
                                                          String headerTitle =
                                                              arraySublist[j]
                                                                  .masonryName!;

                                                          Map<String, dynamic>
                                                              dictslabList = {
                                                            "inner_wo_data": List<
                                                                Map<String,
                                                                    dynamic>>,
                                                            "title":
                                                                headerTitle,
                                                          };
                                                          List<
                                                                  Map<String,
                                                                      dynamic>>
                                                              innerdata = [];
                                                          List<Block>?
                                                              arrayblocklist =
                                                              arraySublist[j]
                                                                  .block;
                                                          if (kDebugMode) {
                                                            print(
                                                                arrayblocklist);
                                                          }
                                                          for (var k = 0;
                                                              k <
                                                                  arrayblocklist!
                                                                      .length;
                                                              k++) {
                                                            if (kDebugMode) {
                                                              print(arrayblocklist[
                                                                      k]
                                                                  .blockName!);
                                                            }

                                                            innerdata.add({
                                                              "wo_name":
                                                                  arrayblocklist[
                                                                          k]
                                                                      .blockName!,
                                                              "wo_percentage":
                                                                  "",
                                                              "wo_amount": "",
                                                              "slab_id": "0",
                                                              "block_id":
                                                                  arrayblocklist[
                                                                          k]
                                                                      .blockId!
                                                            });
                                                          }
                                                          dictslabList[
                                                                  "inner_wo_data"] =
                                                              innerdata;

                                                          if (kDebugMode) {
                                                            print(arrayList);
                                                          }
                                                          setState(() {
                                                            arrayList.add(
                                                                dictslabList);
                                                            totalPercentage =
                                                                0.0;
                                                            totalAmount = 0.0;
                                                            updateContent();
                                                          });
                                                        }
                                                      }
                                                    } else if (name ==
                                                        'Slab, Masonry') {
                                                      //Both
                                                      // BOTH

                                                      // for both slab
                                                      arrayList = [];
                                                      List<Slablist>?
                                                          arraySublist =
                                                          slabMasonryList![0]
                                                              .slablist;
                                                      if (arraySublist!
                                                          .isNotEmpty) {
                                                        for (var j = 0;
                                                            j <
                                                                arraySublist
                                                                    .length;
                                                            j++) {
                                                          if (kDebugMode) {
                                                            print(
                                                                arraySublist[j]
                                                                    .slabName!);
                                                          }
                                                          Map<String, dynamic>
                                                              dictslabList = {
                                                            "inner_wo_data": [
                                                              {
                                                                "wo_name":
                                                                    arraySublist[
                                                                            j]
                                                                        .slabName!,
                                                                "wo_percentage":
                                                                    "",
                                                                "wo_amount": "",
                                                                "slab_id":
                                                                    arraySublist[
                                                                            j]
                                                                        .slabId!,
                                                                "block_id": "0"
                                                              }
                                                            ],
                                                            "title": "",
                                                          };

                                                          setState(() {
                                                            arrayList.add(
                                                                dictslabList);
                                                            totalPercentage =
                                                                0.0;
                                                            totalAmount = 0.0;
                                                            updateContent();
                                                          });
                                                        }
                                                      }

                                                      if (arrayList
                                                          .isNotEmpty) {
                                                        for (var m = 0;
                                                            m <
                                                                arrayList
                                                                    .length;
                                                            m++) {
                                                          List<Masonrylist>?
                                                              arraySublist =
                                                              slabMasonryList![
                                                                      1]
                                                                  .masonrylist;

                                                          if (arraySublist!
                                                              .isNotEmpty) {
                                                            for (var j = 0;
                                                                j <
                                                                    arraySublist
                                                                        .length;
                                                                j++) {
                                                              List<Block>?
                                                                  arrayblocklist =
                                                                  arraySublist[
                                                                          j]
                                                                      .block;
                                                              for (var k = 0;
                                                                  k <
                                                                      arrayblocklist!
                                                                          .length;
                                                                  k++) {
                                                                Map<String,
                                                                        String>
                                                                    dataSublist =
                                                                    {
                                                                  "wo_name":
                                                                      arrayblocklist[
                                                                              k]
                                                                          .blockName!,
                                                                  "wo_percentage":
                                                                      "",
                                                                  "wo_amount":
                                                                      "",
                                                                  "slab_id":
                                                                      "0",
                                                                  "block_id":
                                                                      arrayblocklist[
                                                                              k]
                                                                          .blockId!
                                                                };
                                                                setState(() {
                                                                  arrayList[m][
                                                                          "inner_wo_data"]
                                                                      .insert(
                                                                          k + 1,
                                                                          dataSublist);
                                                                  updateContent();
                                                                });
                                                              }
                                                              break;
                                                            }
                                                          }
                                                        }
                                                      }
                                                      setState(() {
                                                        totalPercentage = 0.0;
                                                        totalAmount = 0.0;
                                                      });
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5.0,
                                                        vertical: 7.0),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  slabList[
                                                                          index]
                                                                      .name!,
                                                                  style:
                                                                      normalText,
                                                                ),
                                                              ],
                                                            ),
                                                            slabList[index]
                                                                        .selected ==
                                                                    '1'
                                                                ? const Icon(
                                                                    Icons
                                                                        .circle_rounded,
                                                                    size: 25,
                                                                    color: Colors
                                                                        .green,
                                                                  )
                                                                : const Icon(
                                                                    Icons
                                                                        .circle_outlined,
                                                                    size: 25,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                          ],
                                                        ),
                                                        verticalSpaceSmall,
                                                        const Divider(
                                                            height: 1.0,
                                                            color:
                                                                Colors.black),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                        verticalSpaceTiny,
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: SimpleButton(
                                            lblText: 'OK',
                                            color: kcPrimaryColor,
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      )
                    : null;
              },
              child: Stack(alignment: Alignment.center, children: [
                Container(
                  height: 45.0,
                  decoration: BoxDecoration(
                      color: kcTextFieldColor,
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: TextField(
                      controller: txtLinkSlabMasonry,
                      autofocus: false,
                      enabled: false,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 15.0),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Select Slab/Masonry or Both',
                      ),
                    ),
                  ),
                ),
                const Positioned(
                    right: 10,
                    child: Center(
                        child: Icon(Icons.arrow_drop_down_circle_outlined))),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
