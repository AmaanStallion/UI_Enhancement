import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/PurchaseOrder/purchase_order_form.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import '../../../models/get_completed_percentage_list.dart';
import '../../../models/get_work_order_details.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import '../rccstructure/pdfviewer.dart';

class WorkOrderQuantification extends StatefulWidget {
  WorkOrderQuantification(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.workId,
      this.tranWorkId,
      this.details,
      this.woTypeOrder});

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? workId;
  String? tranWorkId;
  String? woTypeOrder;
  ContractorDetail? details;

  @override
  State<WorkOrderQuantification> createState() =>
      _WorkOrderQuantificationState();
}

class _WorkOrderQuantificationState extends State<WorkOrderQuantification> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  late BuildContext dialogContext;

  bool flagcalled = false;
  List<QuatificationList>? quatificationList;
  double countActPercentage = 0.0;
  var arrayFiles = [];
  var arrayFilesBytes = [];

  TextEditingController txtCertifyWork = TextEditingController();
  TextEditingController txtRemark = TextEditingController();

  Future<ResponseGetCompletedPercentageList?>
      wsGetCompletedPercentageList() async {
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
      "trans_work_id": widget.tranWorkId!,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.getcompletedpercentagelist, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getCompletedPercentageListFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          flagcalled = true;
          quatificationList = dataModel.response?.quatificationList!;

          for (int i = 0; i < quatificationList!.length; i++) {
            countActPercentage = countActPercentage +
                double.parse(quatificationList![i].woQuatificationValue!);
          }
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
  }

  wsworkorderpercentagecompletedsubmit() async {
    //for multipartrequest
    // context.loaderOverlay.show();
    CustomLoading.progressDialog(isLoading: true, context: context);
    var request = http.MultipartRequest(
        'POST', Uri.parse(AppUrl.wssetworkordercompletedpercentage));

    //for token
    request.headers.addAll({"Authorization": "Bearer token"});

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    //for image and videos and files
    request.fields['user_id'] = userId!;
    request.fields['trans_work_id'] = widget.tranWorkId!;
    request.fields['certify_work'] = txtCertifyWork.text;
    request.fields['remark'] = txtRemark.text;

    for (int i = 0; i < arrayFiles.length; i++) {
      PlatformFile file = arrayFiles[i];
      print("FILE UPLOAD");
      print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.extension);
      print(file.path);
      request.files.add(await http.MultipartFile.fromPath(
          "upload_lab_image[]", file.path.toString()));
    }
    //for completeing the request
    var response = await request.send();

    //for getting and decoding the response into json format
    var responsed = await http.Response.fromStream(response);
    final responseData = json.decode(responsed.body);
    print("RESPONSE IMAGE");
    print(response);
    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("SUCCESS");
      }
      if (kDebugMode) {
        print(responseData);
      }
      // context.loaderOverlay.hide();
      CustomLoading.progressDialog(isLoading: false, context: context);

      // ignore: use_build_context_synchronously
      showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text(''),
                content: const Text('Certify work submitted successfully.',
                    style:
                        TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
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
    } else {
      print("ERROR");
    }
  }

  @override
  void initState() {
    super.initState();
    wsGetCompletedPercentageList();
  }

  @override
  Widget build(BuildContext context) {
    double percentage_completed =
        double.parse(widget.details!.percentageCompleted!);
    double percentage = double.parse(widget.details!.percentage!);
    double actualPer = (percentage_completed / percentage);

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
            ? Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 5),
                      child: Center(child: Text(widget.workId!)),
                    ),
                    const Divider(),
                    Container(
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              width: 400,
                              height: 100,
                              child: SingleChildScrollView(
                                child: Text(
                                    '${widget.details!.name?.capitalize()}'),
                              )),
                          const VerticalDivider(),
                          Container(
                            width: 100,
                            child: Column(
                              children: [
                                Text(widget.woTypeOrder! == '0'
                                    ? '${double.parse(widget.details!.percentage!).toStringAsFixed(2)}%'
                                    : '${double.parse(widget.details!.percentage!).toStringAsFixed(2)} ${widget.details?.woUnitName}'),
                                const Flexible(child: Divider()),
                                Text(currencyFormat.format(
                                    double.parse(widget.details!.amount!)))
                              ],
                            ),
                          ),
                          const VerticalDivider(),
                          Container(
                            width: 100,
                            child: Column(
                              children: [
                                Text(widget.woTypeOrder! == '0'
                                    ? '${double.parse(widget.details!.percentageCompleted!).toStringAsFixed(2)}%'
                                    : '${double.parse(widget.details!.percentageCompleted!).toStringAsFixed(2)} ${widget.details?.woUnitName}'),
                                const Flexible(child: Divider()),
                                Text(currencyFormat.format(double.parse(
                                    widget.details!.amountCompleted!)))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 32,
                      width: 400,
                      child: RoundedProgressBar(
                          style: RoundedProgressBarStyle(
                              widthShadow: 0,
                              colorBorder: Colors.white,
                              backgroundProgress: Colors.grey,
                              colorProgress: Colors.black,
                              colorProgressDark: Colors.black),
                          height: 20,
                          percent: actualPer * 100),
                    ),
                    const Divider(),
                    Container(
                      height: MediaQuery.of(context).size.height - 270,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text('Certify Work'),
                                const SizedBox(width: 35),
                                Container(
                                  height: 45,
                                  width: 180,
                                  decoration: BoxDecoration(
                                      color: kcTextFieldColor,
                                      border: Border.all(
                                        color: Colors.grey,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: TextFormField(
                                      controller: txtCertifyWork,
                                      // keyboardType: TextInputType.number,
                                      // inputFormatters: <TextInputFormatter>[
                                      //   FilteringTextInputFormatter.allow(
                                      //       RegExp(r'^\d+\.?\d{0,2}')),
                                      // ],
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      inputFormatters: [
                                        DecimalTextInputFormatter(
                                            decimalPlaces: 3)
                                      ],

                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 15.0),
                                      decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 18.0),
                                          border: InputBorder.none,
                                          hintText: 'Enter Certify Work'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 35),
                                Text(widget.woTypeOrder! == '0'
                                    ? '( ${countActPercentage.toStringAsFixed(3)} / ${double.parse(widget.details!.percentage!).toStringAsFixed(3)}% Completed )'
                                    : '( ${countActPercentage.toStringAsFixed(3)} / ${double.parse(widget.details!.percentage!).toStringAsFixed(3)} ${widget.details?.woUnitName} Completed )'),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('Upload Fact Sheet'),
                                SizedBox(
                                  width: 80,
                                ),
                                SizedBox(width: 50),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                                height: 100,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: arrayFiles.length + 1,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: Container(
                                          height: 80,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Colors
                                                  .black54, // red as border color
                                            ),
                                          ),
                                          child: index == 0
                                              ? IconButton(
                                                  iconSize: 50,
                                                  icon: const Icon(
                                                    Icons.add_circle_outlined,
                                                  ),
                                                  color: Colors.black,
                                                  onPressed: () async {
                                                    FilePickerResult? result =
                                                        await FilePicker
                                                            .platform
                                                            .pickFiles(
                                                      type: FileType.custom,
                                                      allowedExtensions: [
                                                        'pdf',
                                                        'jpg',
                                                        'jpeg',
                                                        'png'
                                                      ],
                                                    );
                                                    if (result != null) {
                                                      PlatformFile file =
                                                          result.files.first;
                                                      print("FILE SELECTED");
                                                      print(file.name);
                                                      print(file.bytes);
                                                      print(file.size);
                                                      print(file.extension);
                                                      print(file.path);
                                                      Uint8List? fileBytes =
                                                          result.files.first
                                                              .bytes;
                                                      String fileName = result
                                                          .files.first.name;
                                                      setState(() {
                                                        arrayFilesBytes
                                                            .add(fileBytes);
                                                        arrayFiles.add(file);
                                                      });
                                                    } else {
                                                      // User canceled the picker
                                                    }
                                                  },
                                                )
                                              : _imagePdf(arrayFiles[index - 1],
                                                  index - 1),
                                        ),
                                      );
                                    })),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Remark'),
                                const SizedBox(width: 30),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30, right: 30),
                                    child: Container(
                                      height: 45,
                                      width: 180,
                                      decoration: BoxDecoration(
                                          color: kcTextFieldColor,
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5.0))),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 10.0),
                                        child: TextFormField(
                                          controller: txtRemark,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 15.0),
                                          decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 18.0),
                                              border: InputBorder.none,
                                              hintText: 'Enter Remark'),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      if (txtCertifyWork.text == '') {
                                        Alert(
                                            closeIcon: const SizedBox(),
                                            padding: const EdgeInsets.only(
                                                top: 0.0, left: 18, right: 18),
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
                                                'Please enter certify work field.',
                                            alertAnimation: fadeAlertAnimation,
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
                                      } else if (widget.woTypeOrder! == '0') {
                                        //percentage
                                        double percentage = double.parse(
                                            widget.details!.percentage!);
                                        double actPer =
                                            percentage - countActPercentage;
                                        // if (double.parse(txtCertifyWork.text) >
                                        //     actPer) {
                                        // const double tolerance =
                                        //     1e-9; // Define a small tolerance for floating-point comparisons
                                        // 15% tolerance based on actPer
                                        double tolerance = 0.15 * actPer;
                                        print(
                                            '${percentage}-------${countActPercentage} ---------- ${actPer}---pr');
                                        if (double.parse(txtCertifyWork.text) >
                                            actPer + tolerance) {
                                          print(
                                              '${percentage}-------${countActPercentage} ---------- ${actPer}');
                                          Alert(
                                              closeIcon: const SizedBox(),
                                              padding: const EdgeInsets.only(
                                                  top: 0.0,
                                                  left: 18,
                                                  right: 18),
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
                                                  'Certify work field should not be greater than ${actPer.toStringAsFixed(3)} percentage.',
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
                                        } else if (double.parse(
                                                txtCertifyWork.text) <=
                                            0) {
                                          Alert(
                                              closeIcon: const SizedBox(),
                                              padding: const EdgeInsets.only(
                                                  top: 0.0,
                                                  left: 18,
                                                  right: 18),
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
                                                  'Certify work field should be greater than 0 quantity.',
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
                                          wsworkorderpercentagecompletedsubmit();
                                        }
                                      } else if (widget.woTypeOrder! == '1') {
                                        //quantity
                                        double percentage = double.parse(
                                            widget.details!.percentage!);
                                        double actPer =
                                            percentage - countActPercentage;
                                        double tolerance = (((percentage * 15) /
                                                100) +
                                            percentage); //.toStringAsFixed(1);
                                        print(
                                            'txtCertifyWork.text${txtCertifyWork.text}--actPer ${actPer} -----countActPercentage${tolerance - countActPercentage}');
                                        if (double.parse(txtCertifyWork.text) >
                                            (tolerance - countActPercentage)) {
                                          print(
                                              'percentage${percentage}--tolerance ${tolerance} -----countActPercentage${tolerance - countActPercentage}');
                                          Alert(
                                              closeIcon: const SizedBox(),
                                              padding: const EdgeInsets.only(
                                                  top: 0.0,
                                                  left: 18,
                                                  right: 18),
                                    
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
                                                  'Certify work field should not be greater than ${(tolerance - countActPercentage).toStringAsFixed(2)} quantity.',
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
                                        } else if (double.parse(
                                                txtCertifyWork.text) <=
                                            0) {
                                          Alert(
                                              closeIcon: const SizedBox(),
                                              padding: const EdgeInsets.only(
                                                  top: 0.0,
                                                  left: 18,
                                                  right: 18),
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
                                                  'Certify work field should be greater than 0 quantity.',
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
                                          wsworkorderpercentagecompletedsubmit();
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        // primary: Colors.black,
                                        fixedSize: const Size(200, 35),
                                        elevation: 0),
                                    child: const Text(
                                      'SUBMIT',
                                      style: TextStyle(color: Colors.white),
                                    ))
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(thickness: 1, color: Colors.grey),
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: quatificationList?.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    decoration: const BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30.0, right: 30.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          verticalSpaceSmall,
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                  width: 250,
                                                  child:
                                                      Text('Certified Work')),
                                              horizontalSpaceSmall,
                                              Text(
                                                  '-    ${quatificationList?[index].woQuatificationValue}'),
                                              horizontalSpaceSmall,
                                            ],
                                          ),
                                          verticalSpaceSmall,
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                  width: 250,
                                                  child:
                                                      Text('Certified Date')),
                                              horizontalSpaceSmall,
                                              Expanded(
                                                child: Text(
                                                    '-    ${DateFormat('dd MMM yyyy').format(DateFormat("yyyy-MM-dd HH:mm:ss").parse('${quatificationList?[index].woQuatificationCreatedAt}')).toString()}'),
                                              ),
                                              horizontalSpaceLarge,
                                              horizontalSpaceLarge,
                                              quatificationList![index]
                                                      .labReport!
                                                      .isNotEmpty
                                                  ? OutlinedButton(
                                                      onPressed: () {
                                                        var arrRecords =
                                                            quatificationList![
                                                                    index]
                                                                .labReport!;
                                                        showDialog(
                                                            barrierDismissible:
                                                                false,
                                                            context: context,
                                                            builder: (BuildContext
                                                                    context) =>
                                                                Dialog(
                                                                  elevation: 0,
                                                                  child:
                                                                      SizedBox(
                                                                    height: 600,
                                                                    width:
                                                                        460.0,
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        const Padding(
                                                                          padding: EdgeInsets.only(
                                                                              top: 10.0,
                                                                              bottom: 5),
                                                                          child:
                                                                              Text(
                                                                            'Fact Sheet',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ),
                                                                        const Divider(
                                                                          color:
                                                                              Colors.grey,
                                                                          thickness:
                                                                              1,
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              490,
                                                                          child:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Wrap(
                                                                              children: List.generate(growable: true, arrRecords.length, (index) {
                                                                                return Padding(
                                                                                    padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                                                                                    child: InkWell(
                                                                                      onTap: () {
                                                                                        arrRecords[index].toString().split(".").last == 'pdf'
                                                                                            ? Navigator.push(
                                                                                                context,
                                                                                                MaterialPageRoute(
                                                                                                  builder: (_) {
                                                                                                    return PdfViewer(
                                                                                                      fileName: arrRecords[index].toString(),
                                                                                                      fileUrl: '${AppUrl.globalWoFactSheetPath}${arrRecords[index].toString()}',
                                                                                                    );
                                                                                                  },
                                                                                                ),
                                                                                              )
                                                                                            : Navigator.push(
                                                                                                context,
                                                                                                MaterialPageRoute(
                                                                                                  builder: (_) {
                                                                                                    return ImagePreviewViewer(
                                                                                                      fileName: arrRecords[index].toString(),
                                                                                                      fileUrl: '${AppUrl.globalWoFactSheetPath}${arrRecords[index].toString()}',
                                                                                                    );
                                                                                                  },
                                                                                                ),
                                                                                              );
                                                                                      },
                                                                                      child: Container(
                                                                                        width: 129,
                                                                                        height: 140,
                                                                                        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
                                                                                        child: Column(
                                                                                          children: [
                                                                                            const SizedBox(
                                                                                              height: 5,
                                                                                            ),
                                                                                            arrRecords[index].toString().split(".").last == 'pdf'
                                                                                                ? Image.asset(
                                                                                                    'images/projectmanagement/pdf.png',
                                                                                                    width: 100.0,
                                                                                                    height: 100.0,
                                                                                                    fit: BoxFit.cover,
                                                                                                  )
                                                                                                : Image.network(
                                                                                                    '${AppUrl.globalWoFactSheetPath}${arrRecords[index].toString()}',
                                                                                                    width: 100,
                                                                                                    height: 100,
                                                                                                  ),
                                                                                            const SizedBox(
                                                                                              height: 5,
                                                                                            ),
                                                                                            Text(arrRecords[index].toString().capitalize()),
                                                                                            const SizedBox(height: 5),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ));
                                                                              }),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            decoration: BoxDecoration(
                                                                                border: Border.all(),
                                                                                borderRadius: BorderRadius.circular(5),
                                                                                color: Colors.black),
                                                                            width:
                                                                                240,
                                                                            height:
                                                                                40,
                                                                            child:
                                                                                const Padding(
                                                                              padding: EdgeInsets.only(top: 10.0),
                                                                              child: Text(
                                                                                'Close',
                                                                                style: TextStyle(color: Colors.white, fontSize: 16),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ));
                                                      },
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                              side: const BorderSide(
                                                                  color: Colors
                                                                      .black)),
                                                      child: const Text(
                                                          'View Docs',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black)))
                                                  : const SizedBox(),
                                            ],
                                          ),
                                          verticalSpaceSmall,
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                  width: 250,
                                                  child: Text('Remark')),
                                              horizontalSpaceSmall,
                                              Flexible(
                                                child: Text(
                                                    '-    ${quatificationList?[index].woQuatificationRemark}'),
                                              ),
                                              horizontalSpaceSmall,
                                            ],
                                          ),
                                          verticalSpaceSmall,
                                        ],
                                      ),
                                    ),
                                  );
                                })
                          ],
                        ),
                      ),
                    )
                  ],
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
        //  const Center(child: CircularProgressIndicator())
      ),
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
}
