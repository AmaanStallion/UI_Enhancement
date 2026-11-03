import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/views/workorder/quantity/quantitywoitemsview.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/get_default_workorder_create.dart';
import '../../../../utils/app_url.dart';
import '../../../shared/ui_helpers.dart';
import '../../../widgets/simple_button.dart';

class QuantityWoConsultantView extends StatefulWidget {
  QuantityWoConsultantView({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.navigationFlag,
    this.consultantMagicLink,
    this.contractorMagicLink,
    this.vendMagicLink,
    this.towarName,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? navigationFlag;
  final String? towarName;

  final String? contractorMagicLink;
  final String? vendMagicLink;
  final String? consultantMagicLink;

  @override
  State<QuantityWoConsultantView> createState() =>
      _QuantityWoConsultantViewState();
}

class _QuantityWoConsultantViewState extends State<QuantityWoConsultantView> {
  bool flagcalled = false;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  bool isChecked = false;

  List<GradeList>? gradeList = [];
  List<GradeList>? gradeListOriginal = [];

  List<CompanyList>? companyListOriginal = [];
  List<CompanyList>? companyList = [];

  List<DropdownMenuItem> gradeItems = [];
  List<DropdownMenuItem> companyItems = [];
  TextEditingController txtConsultantType = TextEditingController();

  TextEditingController txtRequirementFor = TextEditingController();
  TextEditingController txtInputNote = TextEditingController();
  TextEditingController txtConsultantCompany = TextEditingController();

  String? selectedConsultantType;
  String? selectedConsultantId;
  String? selectedConsultantCompany;
  String? selectedConsultantCompanyId;
  String? selectedRequirementDate;
  String? selectedGST;

  var arrayFiles = [];
  var arrayFilesBytes = [];

  @override
  void initState() {
    super.initState();
    flagcalled = false;
    selectedConsultantType = '';
    selectedConsultantCompany = '';
    selectedRequirementDate =
        DateFormat('dd MMM yyyy').format(DateTime.now()).toString();
    selectedGST = '0';
    fetchDefaultWorkOrderCreate();
  }

  Future<ResponseWorkorderCreate?> fetchDefaultWorkOrderCreate() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    var type = '0';
    if (widget.navigationFlag! == "Consultant") {
      type = '1';
    }

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "type": type,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.getGetDefaultWoCreate, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getDefaultWorkorderCreateFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        //return dataModel.response;
        gradeListOriginal = dataModel.response?.gradeList;
        gradeList = dataModel.response?.gradeList;
        companyList = dataModel.response?.companyList;
        if (gradeList!.isNotEmpty) {
          gradeItems = [];
          for (var i = 0; i < gradeList!.length; i++) {
            gradeItems.add(DropdownMenuItem(
              value: gradeList![i].graderName!,
              onTap: () {
                setState(() {
                  companyItems = [];
                  selectedConsultantType = gradeList![i].graderName!;
                  selectedConsultantId = gradeList![i].gradeId!;
                  if (kDebugMode) {
                    print('selectedConsultantType');
                    print(selectedConsultantType);
                    print(selectedConsultantId);
                  }

                  List<CompanyList>? companyList = gradeList![i].companyList!;
                  if (companyList.isNotEmpty) {
                    for (var i = 0; i < companyList.length; i++) {
                      companyItems.add(DropdownMenuItem(
                        value: companyList[i].companyName!,
                        onTap: () {
                          setState(() {
                            selectedConsultantCompany =
                                companyList[i].companyName!;
                            selectedConsultantCompanyId =
                                companyList[i].companyId!;

                            if (kDebugMode) {
                              print('selectedConsultantCompany');
                              print(selectedConsultantCompany);
                              print(selectedConsultantCompanyId);
                            }
                          });
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: Text(companyList[i].companyName ?? ''),
                        ),
                      ));
                    }
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text(gradeList![i].graderName!),
              ),
            ));
          }
        }

        setState(() {
          flagcalled = true;
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

        // Text(
        //     '${widget.projectName!.toUpperCase()} -- WORK ORDER QUANTITY',
        //     style:
        //         const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
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
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 80),
                          child: Row(
                            children: [
                              SizedBox(width: 140),
                              Spacer(),
                              Text(
                                'WORK ORDER QUANTITY',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Spacer(),
                              InkWell(
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
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10.0, left: 100.0, right: 100.0),
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
                                          border:
                                              Border.all(color: Colors.black),
                                          color: Colors.black,
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
                                          border:
                                              Border.all(color: Colors.black),
                                          color: Colors.white,
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
                                      height: 1.0,
                                      thickness: 0.5,
                                      indent: 1.0,
                                      endIndent: 1.0,
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
                                          border:
                                              Border.all(color: Colors.black),
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
                            height: 1.0,
                            thickness: 0.5,
                            indent: 1.0,
                            endIndent: 1.0,
                            color: Colors.black,
                          ),
                        ),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              return ListView.builder(
                                  itemCount: 1,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, left: 70.0, right: 70.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _consultantType(),
                                          verticalSpaceSmall15,
                                          _consultantCompany(),
                                          verticalSpaceSmall15,
                                          _requirementFor(),
                                          verticalSpaceSmall15,
                                          _selectedReqDate(),
                                          verticalSpaceMedium,
                                          _addGst(),
                                          verticalSpaceSmall15,
                                          _notetextfield(),
                                          verticalSpaceSmall15,
                                          _uploadFile(),
                                          verticalSpaceSmall15,
                                        ],
                                      ),
                                    );
                                  });
                            },
                          ),
                        ),
                        verticalSpaceSmall,
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 70.0, right: 70.0),
                          child: SimpleButton(
                            lblText: 'NEXT',
                            color: kcPrimaryColor,
                            onTap: () {
                              if (selectedConsultantType == '') {
                                showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          title: const Text(''),
                                          content: const Text(
                                              'Please select consultant type.',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.normal,
                                                  fontSize: 17.0)),
                                          actions: <Widget>[
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.black,
                                                  fixedSize:
                                                      const Size.fromWidth(100),
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  textStyle: const TextStyle(
                                                      color: Colors.white)),
                                              child: const Text('CLOSE',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
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
                              } else if (selectedConsultantCompany == '') {
                                showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          title: const Text(''),
                                          content: const Text(
                                              'Please select consultant company.',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.normal,
                                                  fontSize: 17.0)),
                                          actions: <Widget>[
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.black,
                                                  fixedSize:
                                                      const Size.fromWidth(100),
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  textStyle: const TextStyle(
                                                      color: Colors.white)),
                                              child: const Text('CLOSE',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
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
                              } else if (txtRequirementFor.text == '') {
                                showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          title: const Text(''),
                                          content: const Text(
                                              'Please enter requirement for.',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.normal,
                                                  fontSize: 17.0)),
                                          actions: <Widget>[
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.black,
                                                  fixedSize:
                                                      const Size.fromWidth(100),
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  textStyle: const TextStyle(
                                                      color: Colors.white)),
                                              child: const Text('CLOSE',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
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
                              } else if (selectedRequirementDate == '') {
                                showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          title: const Text(''),
                                          content: const Text(
                                              'Please select estimated completion date.',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.normal,
                                                  fontSize: 17.0)),
                                          actions: <Widget>[
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.black,
                                                  fixedSize:
                                                      const Size.fromWidth(100),
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  textStyle: const TextStyle(
                                                      color: Colors.white)),
                                              child: const Text('CLOSE',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
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
                                var projectId = widget.projectId!;
                                var projectName = widget.projectName!;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return QuantityWoItemsView(
                                          consultantMagicLink:
                                              widget.consultantMagicLink,
                                          contractorMagicLink:
                                              widget.contractorMagicLink,
                                          vendMagicLink: widget.vendMagicLink,
                                          towarName: widget.towarName,
                                          projectId: projectId,
                                          towarId: widget.towarId!,
                                          projectName: projectName,
                                          selectedConsultantType:
                                              selectedConsultantId,
                                          selectedConsultantCompany:
                                              selectedConsultantCompanyId,
                                          selectedRequirementDate:
                                              selectedRequirementDate,
                                          selectedGST: selectedGST,
                                          inputNote: txtInputNote.text,
                                          inputRequirementFor:
                                              txtRequirementFor.text,
                                          arrayFiles: arrayFiles,
                                          strGradeId: selectedConsultantId,
                                          gradeUnit: [],
                                          navigationFlag:
                                              widget.navigationFlag!);
                                    },
                                  ),
                                ).then((value) => {checkNavigation()});
                              }
                            },
                          ),
                        ),
                        verticalSpaceSmall,
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
                      //  CircularProgressIndicator()
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

  Widget _consultantType() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Consultant Type',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: InkWell(
            onTap: () {
              gradeList!.isNotEmpty
                  ? showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          surfaceTintColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Set radius to zero
                          ),
                          titlePadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          actionsPadding: const EdgeInsets.only(bottom: 10),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          actionsAlignment: MainAxisAlignment.center,
                          title: Text(
                            // widget.navigationFlag == "Consultant"
                            //     ? "SELECT CONSULTANT TYPE"
                            //     : "SELECT REQUIRED SKILL",
                            'Select Consultant Type',
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
                              },
                              child: Container(
                                width: 500,
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
                          ],
                          content: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
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
                                          if (value.isNotEmpty) {
                                            if (value.length > 2) {
                                              var filteredList = gradeListOriginal
                                                  ?.where((element) => element
                                                      .graderName!
                                                      .toLowerCase()
                                                      .contains(
                                                          value.toLowerCase()))
                                                  .toList();
                                              setState(() {
                                                gradeList = filteredList;
                                              });
                                            }
                                          } else {
                                            setState(() {
                                              gradeList = gradeListOriginal;
                                            });
                                          }
                                        },
                                        style: const TextStyle(fontSize: 13),
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.all(12.0),
                                          labelText: widget.navigationFlag ==
                                                  "Consultant"
                                              ? "Search Consultant Type"
                                              : 'Search Required Skill',
                                          hintText: widget.navigationFlag ==
                                                  "Consultant"
                                              ? "Search Consultant Type"
                                              : 'Search Required Skill',
                                          prefixIcon: const Icon(Icons.search),
                                          border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(7.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    verticalSpaceTiny,
                                    Expanded(
                                      child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: gradeList!.length,
                                          itemBuilder: (context, int index) {
                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  selectedConsultantType =
                                                      gradeList![index].gradeId;
                                                  txtConsultantType.text =
                                                      gradeList![index]
                                                          .graderName!;
                                                  selectedConsultantId =
                                                      gradeList![index]
                                                          .gradeId!;
                                                  companyList =
                                                      gradeList![index]
                                                          .companyList;
                                                  companyListOriginal =
                                                      gradeList![index]
                                                          .companyList;
                                                });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                              gradeList![index]
                                                                  .graderName!,
                                                              style: normalText,
                                                            ),
                                                          ],
                                                        ),
                                                        selectedConsultantId ==
                                                                null
                                                            ? const Icon(
                                                                Icons
                                                                    .circle_outlined,
                                                                size: 25,
                                                                color:
                                                                    Colors.grey,
                                                              )
                                                            : selectedConsultantId ==
                                                                    gradeList![
                                                                            index]
                                                                        .gradeId
                                                                ? const Icon(
                                                                    Icons
                                                                        .circle,
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
                    borderRadius: const BorderRadius.all(Radius.circular(5.0))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: TextField(
                    controller: txtConsultantType,
                    autofocus: false,
                    enabled: false,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: widget.navigationFlag == "Consultant"
                          ? 'Select Consultant Type'
                          : 'Select Required Skill',
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
        // Expanded(
        //   child: Container(
        //     decoration: BoxDecoration(
        //         color: kcTextFieldColor,
        //         border: Border.all(
        //           color: Colors.grey,
        //         ),
        //         borderRadius: const BorderRadius.all(Radius.circular(5.0))),
        //     child: Padding(
        //       padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        //       child: SearchChoices.single(
        //         style: const TextStyle(fontSize: 15.0, color: Colors.black),
        //         items: gradeItems,
        //         value: selectedConsultantType,
        //         hint: "Select Consultant Type",
        //         searchHint: "Select Consultant Type",
        //         onChanged: (value) {},
        //         padding: selectedConsultantType == '' ||
        //                 selectedConsultantType == null
        //             ? 0.0
        //             : 0.0,
        //         dialogBox: false,
        //         isExpanded: true,
        //         menuConstraints:
        //             BoxConstraints.tight(const Size.fromHeight(350.0)),
        //         onClear: () {
        //           setState(() {
        //             selectedConsultantType = '';
        //             selectedConsultantId = '';
        //           });
        //         },
        //         underline: const SizedBox(height: 0.0),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _consultantCompany() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Consultant Company',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: InkWell(
            onTap: () {
              companyList!.isNotEmpty
                  ? showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          surfaceTintColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Set radius to zero
                          ),
                          titlePadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          actionsPadding: const EdgeInsets.only(bottom: 10),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          actionsAlignment: MainAxisAlignment.center,
                          title: Text(
                            widget.navigationFlag! == "Consultant"
                                ? "SELECT CONSULTANT COMPANY"
                                : "SELECT CONTRACTOR COMPANY",
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
                              },
                              child: Container(
                                width: 500,
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
                          ],
                          content: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
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
                                          if (value.isNotEmpty) {
                                            if (value.length > 2) {
                                              var filteredList =
                                                  companyListOriginal
                                                      ?.where((element) => element
                                                          .companyName!
                                                          .toLowerCase()
                                                          .contains(value
                                                              .toLowerCase()))
                                                      .toList();
                                              setState(() {
                                                companyList = filteredList;
                                              });
                                            }
                                          } else {
                                            setState(() {
                                              companyList = companyListOriginal;
                                            });
                                          }
                                        },
                                        style: const TextStyle(fontSize: 13),
                                        decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.all(12.0),
                                            labelText: widget.navigationFlag! ==
                                                    "Consultant"
                                                ? "Search Consultant Company"
                                                : 'Search Contractor Company',
                                            hintText:
                                                "Search Consultant Company",
                                            prefixIcon:
                                                const Icon(Icons.search),
                                            border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(7.0)))),
                                      ),
                                    ),
                                    verticalSpaceTiny,
                                    Expanded(
                                      child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: companyList!.length,
                                          itemBuilder: (context, int index) {
                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  selectedConsultantCompany =
                                                      companyList![index]
                                                          .companyName;
                                                  txtConsultantCompany.text =
                                                      companyList![index]
                                                          .companyName!;
                                                  selectedConsultantCompanyId =
                                                      companyList![index]
                                                          .companyId!;
                                                });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                              companyList![
                                                                      index]
                                                                  .companyName!,
                                                              style: normalText,
                                                            ),
                                                          ],
                                                        ),
                                                        selectedConsultantCompanyId ==
                                                                null
                                                            ? const Icon(
                                                                Icons
                                                                    .circle_outlined,
                                                                size: 25,
                                                                color:
                                                                    Colors.grey,
                                                              )
                                                            : selectedConsultantCompanyId ==
                                                                    companyList![
                                                                            index]
                                                                        .companyId
                                                                ? const Icon(
                                                                    Icons
                                                                        .circle,
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
                    borderRadius: const BorderRadius.all(Radius.circular(5.0))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: TextField(
                    controller: txtConsultantCompany,
                    autofocus: false,
                    enabled: false,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: widget.navigationFlag! == "Consultant"
                          ? 'Select Consultant Company'
                          : 'Select Contractor Company',
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

        // Expanded(
        //   child: Container(
        //     decoration: BoxDecoration(
        //         color: kcTextFieldColor,
        //         border: Border.all(
        //           color: Colors.grey,
        //         ),
        //         borderRadius: const BorderRadius.all(Radius.circular(5.0))),
        //     child: Padding(
        //       padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        //       child: SearchChoices.single(
        //         style: const TextStyle(fontSize: 15.0, color: Colors.black),
        //         items: companyItems,
        //         value: selectedConsultantCompany,
        //         hint: "Select Consultant Company",
        //         searchHint: "Select Consultant Company",
        //         onChanged: (value) {},
        //         padding: selectedConsultantCompany == '' ||
        //                 selectedConsultantCompany == null
        //             ? (selectedConsultantType == '' ? 0.0 : 0.0)
        //             : 0.0,
        //         dialogBox: false,
        //         isExpanded: true,
        //         menuConstraints:
        //             BoxConstraints.tight(const Size.fromHeight(350.0)),
        //         onClear: () {
        //           setState(() {
        //             selectedConsultantCompany = '';
        //             selectedConsultantCompanyId = '';
        //           });
        //         },
        //         underline: const SizedBox(height: 0.0),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _requirementFor() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Requirement For',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: 45.0,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: TextField(
                controller: txtRequirementFor,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter Requirement For',
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _selectedReqDate() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Select Completion Date --',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: 45.0,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: InkWell(
                onTap: () async {
                  DateTime? newDateTime = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(DateTime.now().year + 20),
                  );
                  if (newDateTime != null) {
                    setState(() {
                      selectedRequirementDate = DateFormat('dd MMM yyyy')
                          .format(newDateTime)
                          .toString();
                    });
                  }
                },
                child: TextField(
                  enabled: false,
                  style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  decoration: InputDecoration(
                      labelText: selectedRequirementDate,
                      labelStyle:
                          const TextStyle(color: Colors.black, fontSize: 15.0),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 18.0),
                      border: InputBorder.none,
                      hintText: 'Select Completion Date'),
                  onChanged: (text) {
                    setState(() {
                      //fullName = text;
                      //you can access nameController in its scope to get
                      // the value of text entered as shown below
                      //fullName = nameController.text;
                    });
                  },
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _addGst() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          width: 230,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Add GST',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Transform.scale(
          scale: 2.0,
          child: Checkbox(
            checkColor: Colors.white,
            // fillColor: MaterialStateProperty.resolveWith(getColor),
            value: isChecked,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.0),
            ),
            side: MaterialStateBorderSide.resolveWith(
              (states) => const BorderSide(width: 0.7, color: Colors.black54),
            ),
            onChanged: (bool? value) {
              setState(() {
                isChecked = value!;
                if (value! == true) {
                  selectedGST = '1';
                } else {
                  selectedGST = '0';
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _notetextfield() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Add Note',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: TextField(
                controller: txtInputNote,
                maxLines: 4,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                    border: InputBorder.none, hintText: 'Add Note'),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _uploadFile() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230,
          height: 80.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Upload file \n(Attach Detailed Quotes)',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: SizedBox(
              height: 100,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: arrayFiles.length + 1,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Container(
                        height: 80,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black54, // red as border color
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
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: [
                                      'pdf',
                                      'jpg',
                                      'jpeg',
                                      'png'
                                    ],
                                  );
                                  if (result != null) {
                                    PlatformFile file = result.files.first;
                                    print("FILE SELECTED");
                                    print(file.name);
                                    print(file.bytes);
                                    print(file.size);
                                    print(file.extension);
                                    print(file.path);
                                    Uint8List? fileBytes =
                                        result.files.first.bytes;
                                    setState(() {
                                      arrayFilesBytes.add(fileBytes);
                                      arrayFiles.add(file);
                                    });
                                  } else {
                                    // User canceled the picker
                                  }
                                },
                              )
                            : _imagePdf(arrayFiles[index - 1], index - 1),
                      ),
                    );
                  })),
        ),
      ],
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
