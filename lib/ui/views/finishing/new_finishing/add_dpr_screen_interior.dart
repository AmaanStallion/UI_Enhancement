import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stallion/models/dprPreviewHtml.dart';
import 'package:stallion/models/get_edit_dpr.dart';
import 'package:stallion/models/get_project_dpr_contractor.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/finishing/new_finishing/preview_dpr_interior.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/views/rccstructure/dpr/preview_dpr.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AddDprScreenInterior extends StatefulWidget {
  AddDprScreenInterior({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    this.title,
    this.slabId,
    this.slabNumber,
    this.project_dpr_id = '',
  });
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? title;
  String? slabId;
  final String? slabNumber;
  String? project_dpr_id = '';

  @override
  State<AddDprScreenInterior> createState() => _AddDprScreenState();
}

class _AddDprScreenState extends State<AddDprScreenInterior> {
  Future<void> _selectInTime(BuildContext context, int controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        dprStaffList?[controller].inTime =
            pickedTime.format(context); // Formatting time
      });
    }
  }

  Future<void> _selectOutTime(BuildContext context, int controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        dprStaffList?[controller].outTime =
            pickedTime.format(context); // Formatting time
      });
    }
  }

  String formatDate(DateTime dateTime) {
    // Format the DateTime as "yyyy-MM-dd" (e.g., "2023-09-01")
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  }

  final TextEditingController _slabNumberController = TextEditingController();
  final TextEditingController _dificultiesNrequirementsController =
      TextEditingController();
  final TextEditingController _visitorsController = TextEditingController();
  final TextEditingController _workTypeController = TextEditingController();
  final TextEditingController _contractorController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _workProgressAddController =
      TextEditingController();
  final TextEditingController _customCategoryController =
      TextEditingController();
  final GlobalKey<FormState> _formKeyCustomCategory = GlobalKey<FormState>();
  // List<WorkProgress>? workProgress = [];
  TextEditingController editingController = TextEditingController();
  TextEditingController activityModalController = TextEditingController();

  String selectedSortBy = "";
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<PlatformFile> arrayFiles = [];
  List<Uint8List?> arrayFilesBytes = [];
  List<ContrctorList>? contrctorList = [];
  MasnoryList contrctorListSelected = MasnoryList(id: '', name: '');
  List<ContrctorList> searchcontrctorList(
      List<ContrctorList> objects, String query) {
    query = query
        .toLowerCase(); // Convert the query to lowercase for case-insensitive search
    return objects
        .where((obj) =>
            obj.companyName!.toLowerCase().contains(query) ||
            obj.companyName.toString().contains(query))
        .toList();
  }

  List<MasnoryList> searchSlabList(
      // List<MasnoryList>? masnoryList = [];

      List<MasnoryList> objects,
      String query) {
    query = query
        .toLowerCase(); // Convert the query to lowercase for case-insensitive search
    return objects
        .where((obj) =>
            obj.name!.toLowerCase().contains(query) ||
            obj.name.toString().contains(query))
        .toList();
  }

  List<Skill> searchActivitiesList(List<Skill> objects, String query) {
    query = query
        .toLowerCase(); // Convert the query to lowercase for case-insensitive search
    return objects
        .where((obj) =>
            obj.mstWorkName!.toLowerCase().contains(query) ||
            obj.mstWorkName.toString().contains(query))
        .toList();
  }

  List<Skill>? skillResponse;
  List<CustomType>? customType = [];
  List<DprStockList>? dprStockList = [];

  List<WorkProgress>? workProgressList = [];
  ResponseGetProjectDprContractor? responseGetProjectDprContractor;
  List<MasnoryList>? masnoryList = [];
  List<DprYesterdayActivity>? dprFinishingYesterdayActivity = [];

  bool isLoad = false;
  DateTime? _selectedFormDate;
  TextEditingController fromDateControler = TextEditingController();
  List<OrderDeliveredList>? orderDeliveredListResponse = [];
  // List<DprYesterdayActivity>? dprYesterdayActivity = [];
  List<DprStaffList>? dprStaffList = [];
  List<DprYesterdayActivity>? todaysPlanActivitySelected = [];
  List<String>? uploadImage = [];
  List<ContractProgress>? contractProgress = [];
  List<OrderDeliveredList>? orderDeliveredList = [];

  Future<ResponseDprPreviewHtml?> wsSetdprpreview() async {
    List<DprStaffList>? dprStaffListTemp = [];

    for (int i = 0; i < dprStaffList!.length; i++) {
      if (dprStaffList![i].staffName != '') {
        dprStaffListTemp.add(dprStaffList![i]);
      }
    }
    List<ContrctorList>? filteredContractorList =
        contrctorList?.where((element) => element.isSelected == true).toList();

    List<Skill>? filteredskillResponseList =
        skillResponse?.where((element) => element.isSelected == true).toList();

    int total = 0;

    for (CustomType item in customType!) {
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

    request.fields['user_id'] = userId ?? '';
    request.fields['project_id'] = widget.projectId!;
    request.fields['towar_id'] = towerId;
    request.fields['project_dpr_id'] = widget.project_dpr_id ?? '';
    request.fields['remark'] = '';
    request.fields['dpr_status'] = '0';
    request.fields['consultant_json'] = jsonEncode(filteredContractorList);
    request.fields['total_man_power'] = total.toString();
    request.fields['drp_work_json'] = jsonEncode(workProgressList);
    request.fields['drp_labour_json'] = json.encode(customType);
    request.fields['slab_id'] = widget.slabId ?? '';
    request.fields['slab_no'] = widget.slabNumber ?? '';
    request.fields['dpr_date'] =
        formatDate(_selectedFormDate ?? DateTime.now());
    request.fields['drp_activity_json'] = jsonEncode(filteredskillResponseList);
    request.fields['work_type'] = _workTypeController.text;
    request.fields['drp_order_delivered_json'] =
        jsonEncode(orderDeliveredListResponse);
    request.fields['dpr_difficulti_requirement'] =
        _dificultiesNrequirementsController.text;
    request.fields['visitors'] = _visitorsController.text;
    request.fields['dpr_today_activity'] =
        jsonEncode(todaysPlanActivitySelected);
    request.fields['dpr_yesterday_activity'] =
        jsonEncode(dprFinishingYesterdayActivity);
    // request.fields['dpr_staff'] = jsonEncode(dprStaffListTemp);

    for (int i = 0; i < arrayFiles.length; i++) {
      if (arrayFiles[i] != null && arrayFiles[i].extension == "mp4") {
        PlatformFile file = arrayFiles[i];
        request.files.add(await http.MultipartFile.fromPath(
          "drpuploadvedio[]",
          file.path.toString(),
          contentType: MediaType('application/pdf', file.extension ?? ""),
        ));
      } else {
        PlatformFile file = arrayFiles[i];
        request.files.add(await http.MultipartFile.fromPath(
          "drpuploadimg[]",
          file.path.toString(),
          contentType: MediaType('application/pdf', file.extension ?? ""),
        ));
      }
    }

    print("Request Fields: ${request.fields}");

    var response = await request.send();
    var responsed = await http.Response.fromStream(response);
    final responseData = json.decode(responsed.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      showDialog<void>(
          barrierDismissible: false,
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
                "Saved Successfully.",
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

      return null;
    } else {
      return null;
    }
  }

  Future<ResponseGetProjectDprContractor?> fetchGetAllDprlist() async {
    CustomLoading.progressDialog(isLoading: true, context: context);
    // String formatDate(DateTime dateTime) {
    //   // String formattedDate =
    //   //     DateFormat('yyyy-MM-dd HH:mm:ss').format(originalDate);
    //   // return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    //   return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    // }

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "towar_id": widget.towarId ?? '',
      "project_id": widget.projectId ?? '',
      "user_id": userId ?? '',
      'slab_id': widget.slabId ?? '',
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.getProjectDprContractor, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getProjectDprContractorFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        CustomLoading.progressDialog(isLoading: false, context: context);
        setState(() {
          masnoryList = dataModel.response?.masnoryList;
          dprStockList = dataModel.response?.dprStockList;

          responseGetProjectDprContractor = dataModel.response;
          contrctorList = dataModel.response?.contrctorList;
          customType = dataModel.response?.customType;
          orderDeliveredListResponse = dataModel.response?.orderDeliveredList;
          dprFinishingYesterdayActivity =
              dataModel.response?.dprFinishingYesterdayActivity;
          contractProgress = dataModel.response?.contractProgress;
          orderDeliveredList = dataModel.response?.orderDeliveredList;
          workProgressList = dataModel.response?.workProgress;
          //   projctDprListResponse = dataModel.response?.projctDprList;
          //   offset = dataModel.response?.offset ?? '';
          //   responseWebService = dataModel.response;
        });
        if (widget.project_dpr_id != '') {
          getProjectSaveDpr();
        }
      } else {
        CustomLoading.progressDialog(isLoading: false, context: context);
      }
    } else {
      CustomLoading.progressDialog(isLoading: false, context: context);
    }
    return null;
  }

  Future<ResponseGetProjectDprContractor?> deleteDocUploaded({
    required String document_name,
    required String project_dpr_id,
  }) async {
    Map<String, String> data = {
      "project_dpr_id": project_dpr_id,
      "document_name": document_name,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.wsDprDocumentRemove, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        uploadImage?.remove(document_name);
      });
      //   final dataModel = getProjectDprContractorFromJson(response.body);

      //   if (dataModel.response?.errorCode == "0") {
      //     setState(() {});
      //   } else {}
    }
    return null;
    // return null;
  }

  Future<ResponseGetProjectDprContractor?> getProjectSaveDpr() async {
    // String formatDate(DateTime dateTime) {
    //   // String formattedDate =
    //   //     DateFormat('yyyy-MM-dd HH:mm:ss').format(originalDate);
    //   // return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    //   return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    // }

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "towar_id": widget.towarId ?? '',
      "project_id": widget.projectId ?? '',
      "user_id": userId ?? '',
      'slab_id': widget.slabId ?? '',
      'project_dpr_id': widget.project_dpr_id ?? '',
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(AppUrl.getProjectSaveDpr, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getEditDprResponseFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          // if (dataModel.response?.projectDprDetails?.dprStaffJson!.length ==
          //     0) {
          //   dprStaffList = [
          //     DprStaffList(
          //       id: "1",
          //       staffName: '',
          //       inTime: '',
          //       outTime: '',
          //     )
          //   ];
          // } else {
          //   dprStaffList = dataModel.response?.projectDprDetails?.dprStaffJson;
          // }
          _visitorsController.text =
              dataModel.response?.projectDprDetails?.dprVisitors ?? '';
          uploadImage = dataModel.response?.projectDprDetails?.uploadImage;
          workProgressList = dataModel.response?.projectDprDetails?.drpWorkJson;
          todaysPlanActivitySelected =
              dataModel.response?.projectDprDetails?.dprTodayPlanActivity;
          _workTypeController.text =
              dataModel.response?.projectDprDetails?.drpWorkType ?? '';
          _dificultiesNrequirementsController.text =
              dataModel.response?.projectDprDetails?.dprDifficultiRequirement ??
                  '';
          // skillResponse = dataModel.response?.projectDprDetails?.s
          List<ContrctorList>? temp =
              dataModel.response?.projectDprDetails?.consultantJson;
          customType = dataModel.response?.projectDprDetails?.drpLabourJson;
          //     //   projctDprListResponse = dataModel.response?.projctDprList;
          //     //   offset = dataModel.response?.offset ?? '';
          //     //   responseWebService = dataModel.response;
          String tempStr = '';
          List<Skill>? skillTemp = [];
          List<Skill>? uniqueData = [];
          skillResponse = [];
          for (ContrctorList bElement in temp!) {
            var bId = bElement.companyId;
            var aElement = contrctorList?.firstWhere(
              (element) => element.companyId == bId,
            );
            if (aElement != null) {
              aElement.count = bElement.count;
              aElement.isSelected = true;
              skillTemp = [...?skillTemp, ...?aElement.skill];
              if (tempStr != "") {
                if (aElement.count == null) {
                  tempStr = "$tempStr,${aElement.companyName}";
                } else {
                  tempStr =
                      "$tempStr,${aElement.companyName} (${aElement.count})";
                }
              } else {
                if (aElement.count != null) {
                  tempStr = '${aElement.companyName} (${aElement.count})';
                } else {
                  tempStr = '${aElement.companyName}';
                }
              }
            }
          }
          for (var item in skillTemp!) {
            bool isDuplicate = false;
            for (var uniqueItem in uniqueData) {
              if (item.mstWorkName == uniqueItem.mstWorkName) {
                isDuplicate = true;
                break;
              }
            }
            if (!isDuplicate) {
              uniqueData.add(item);
            }
          }
          skillResponse = uniqueData;
          _contractorController.text = tempStr;

          List<Skill>? tempppp = dataModel
              .response?.projectDprDetails?.dprActivityJson; // skillResponse
          String tempStrSkill = '';
          for (Skill bSkills in tempppp!) {
            var bIds = bSkills.mstWorkName;
            // var aElements = skillResponse?.firstWhere(
            //   (element) => element.mstWorkName == bIds,
            // );
            Skill? aElements;
            if (skillResponse != null && skillResponse!.isNotEmpty) {
              aElements = skillResponse?.firstWhere(
                (element) => element.mstWorkName == bIds,
                orElse: () => Skill(), // Provide a default value here.
              );
              // Use aElements...
            }
            if (aElements != null) {
              aElements.isSelected = true;
              if (tempStrSkill != "") {
                tempStrSkill = "$tempStrSkill,${aElements.mstWorkName}";
              } else {
                tempStrSkill = aElements.mstWorkName ?? '';
              }
            }
          }
          // List<Skill>? tempppp =
          //     dataModel.response?.projectDprDetails?.dprActivityJson;
          // String tempStrSkill = '';

          // if (tempppp != null && skillResponse != null) {
          //   for (Skill bSkills in tempppp) {
          //     var bIds = bSkills.mstWorkName;

          //     Skill? aElements = skillResponse!.firstWhere(
          //       (element) => element.mstWorkName == bIds,
          //       orElse: () =>
          //           Skill(), // Default instance, but this may not be ideal
          //     );

          //     if (aElements.mstWorkName != null) {
          //       // Ensure it's a valid skill
          //       aElements.isSelected = true;

          //       if (tempStrSkill.isNotEmpty) {
          //         tempStrSkill += ",${aElements.mstWorkName}";
          //       } else {
          //         tempStrSkill = aElements.mstWorkName!;
          //       }
          //     }

          //     print(jsonEncode(aElements));
          //   }

          //   //  for (int p = 0; p < skillResponse!.length; p++) {
          //   //   print(skillResponse![p].mstWorkName);
          //   //   print('------------------------');
          //   //   print(bIds);
          //   //   if (skillResponse![p].mstWorkName == bIds) {
          //   //     print(bIds);
          //   //     skillResponse![p].isSelected = true;
          //   //     if (tempStrSkill != "") {
          //   //       tempStrSkill =
          //   //           "$tempStrSkill,${skillResponse![p].mstWorkName}";
          //   //     } else {
          //   //       tempStrSkill = skillResponse![p].mstWorkName ?? '';
          //   //     }
          //   //   }
          //   // }
          // }

          // print(tempStrSkill);
          _activityController.text = tempStrSkill;
        });
      } else {}
    }
    return null;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchGetAllDprlist();
    });

    setState(() {
      // dprStaffList?.add(DprStaffList(
      //   id: "1",
      //   staffName: '',
      //   inTime: '',
      //   outTime: '',
      // ));
      _slabNumberController.text =
          //  widget.towarName?.length != 0
          // ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
          // :
          widget.title ?? '';

      _selectedFormDate = DateTime.now();
      fromDateControler.text =
          DateFormat('dd MMMM yyyy', 'en_US').format(_selectedFormDate!);

      todaysPlanActivitySelected?.add(DprYesterdayActivity(
          dprFlag: '1',
          dprActivityDateController: TextEditingController(),
          isSelected: false,
          id: "1",
          targetdate: "",
          description: "",
          descriptionVal: '',
          dprActivityController: TextEditingController()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Row(
        children: [
          InkWell(
            onTap: () {
              wsSetdprpreview();
            },
            child: Container(
              height: 40,
              width: MediaQuery.of(context).size.width / 2,
              color: Colors.black,
              child: const Center(
                child: Text(
                  "SAVE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              print(jsonEncode(dprFinishingYesterdayActivity));
              // if (workProgressList?.length != 0) {
              inspect(todaysPlanActivitySelected);
              if ((todaysPlanActivitySelected?[0].descriptionVal != "" ||
                      todaysPlanActivitySelected?[0].targetdate != '') &&
                  _workTypeController.text != "" &&
                  _contractorController.text != '' &&
                  _activityController.text != '') {
                String formatDate(DateTime dateTime) {
                  // Format the DateTime as "yyyy-MM-dd" (e.g., "2023-09-01")
                  return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
                }

                for (int i = 0; i < todaysPlanActivitySelected!.length; i++) {
                  setState(() {
                    todaysPlanActivitySelected?[i].id = (i + 1).toString();
                  });
                }
                List<DprStaffList>? dprStaffListTemp = [];

                for (int i = 0; i < dprStaffList!.length; i++) {
                  if (dprStaffList![i].staffName != '') {
                    dprStaffListTemp.add(dprStaffList![i]);
                  }
                }

                print(jsonEncode(dprFinishingYesterdayActivity));
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return PreviewDPRScreenInterior(
                        dprStockList: dprStockList,
                        // dprStaffList: dprStaffListTemp,
                        visitors: _visitorsController.text,
                        project_dpr_id: widget.project_dpr_id,
                        dpr_difficulti_requirement:
                            _dificultiesNrequirementsController.text,
                        arrayFilesBytes: arrayFilesBytes,
                        arrayFiles: arrayFiles,
                        projectId: widget.projectId!,
                        projectName: widget.projectName!,
                        towarName: widget.towarName!,
                        towarId: widget.towarId,
                        contrctorList: contrctorList,
                        customType: customType,
                        workProgressList: workProgressList,
                        slabId: widget.slabId,
                        slabNo: widget.slabNumber,
                        dprDate:
                            formatDate(_selectedFormDate ?? DateTime.now()),
                        skillResponse: skillResponse,
                        workType: _workTypeController.text,
                        orderDeliveredList: orderDeliveredListResponse,
                        dprYesterdayActivity: dprFinishingYesterdayActivity,
                        todaysPlanActivitySelected: todaysPlanActivitySelected,
                        dificultiesNrequirements:
                            _dificultiesNrequirementsController.text,
                        contractProgress: contractProgress,
                      );
                    },
                  ),
                ).then((value) => {});
              }
              // }
              else {
                if (_workTypeController.text == "") {
                  commonAleertModal(textTitle: "Please enter Work Type.");
                } else if (_contractorController.text == '') {
                  commonAleertModal(textTitle: "Please Select Contractor.");
                } else if (_activityController.text == '') {
                  commonAleertModal(textTitle: "Please Select Activity.");
                } else {
                  commonAleertModal(
                      textTitle: "Please enter Today's Plan Activity.");
                }
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              height: 40,
              decoration: const BoxDecoration(
                  color: Colors.black,
                  border: Border(left: BorderSide(color: Colors.white70))),
              child: const Center(
                child: Text(
                  "PREVIEW D.P.R",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
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
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: AppText(
                  // title: '${widget.title} - D.P.R',
                  title: 'D.P.R',

                  fontSize: 18,
                  titleColor: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Divider(),
              slabNo(),
              const SizedBox(height: 10),
              selectDate(),
              const SizedBox(height: 10),
              workType(),
              const SizedBox(height: 10),
              contractor(),
              const SizedBox(height: 10),
              activity(),
              const SizedBox(height: 10),
              dificultiesNrequirements(),
              const SizedBox(height: 10),
              visitorss(),
              const SizedBox(height: 10),
              // if (customType?.length != 0)
              for (var i = 0; i < customType!.length; i++)
                dynamicCustomType(
                  data: customType![i],
                  indexx: i,
                  title: customType?[i].name ?? '',
                  hintText: 'Enter ${customType?[i].name}',
                  textEditingController: customType?[i].editingTextController ??
                      TextEditingController(),
                  titleVal: customType?[i].value ?? '',
                ),
              addCustomCategory(),
              const SizedBox(height: 10),
              const Divider(),
              // const SizedBox(height: 10),
              // addStaff(),
              // const SizedBox(height: 10),
              // addStaffBtn(),
              // const Divider(),
              const SizedBox(height: 10),

              if (dprFinishingYesterdayActivity!.length != 0)
                yesterdayWorkDone(),
              if (dprFinishingYesterdayActivity!.length != 0)
                const SizedBox(height: 10),
              if (dprFinishingYesterdayActivity!.length != 0) addToTodaysPlan(),
              if (dprFinishingYesterdayActivity!.length != 0)
                const SizedBox(height: 10),
              if (dprFinishingYesterdayActivity!.length != 0) const Divider(),
              if (dprFinishingYesterdayActivity!.length != 0)
                const SizedBox(height: 10),
              todaysPlanActivity(),
              const SizedBox(height: 10),
              addPlannedActivity(),
              const SizedBox(height: 10),
              if (dprStockList!.isNotEmpty) rawMaterialDelivered(),

              // const Divider(),
              const SizedBox(height: 10),

              // if (orderDeliveredListResponse!.isNotEmpty) const Divider(),
              // if (orderDeliveredListResponse!.isNotEmpty)
              if (orderDeliveredList!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.black45))),
                  width: double.maxFinite,
                  child: const Text("Order Delivered at Site",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              if (orderDeliveredList!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.only(bottom: 10, top: 10),
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.black45),
                          top: BorderSide(color: Colors.black45))),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: const Text("Grade Type",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.black45),
                            right: BorderSide(color: Colors.black45),
                          ),
                        ),
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: const Text("Del. QTY",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: const Text("Cons./Issued",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              for (int t = 0; t < orderDeliveredList!.length; t++)
                Container(
                  padding: const EdgeInsets.only(bottom: 10, top: 10),
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.black45),
                          top: BorderSide(color: Colors.black45))),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Text(orderDeliveredList?[t].name ?? '',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.black45),
                            right: BorderSide(color: Colors.black45),
                          ),
                        ),
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: Text(
                            '${orderDeliveredList?[t].totalQuantity} ${orderDeliveredList?[t].unit}', //     '${orderDeliveredList?[t].consumeQuantity} ${orderDeliveredList?[t].unit}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: Text(
                            '${orderDeliveredList?[t].consumeQuantity} ${orderDeliveredList?[t].unit}',
                            //'${orderDeliveredList?[t].totalQuantity} ${orderDeliveredList?[t].unit}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              // if (orderDeliveredListResponse!.isNotEmpty)
              //   const SizedBox(height: 6),
              // for (int i = 0; i < orderDeliveredListResponse!.length; i++)
              //   Container(
              //     padding: const EdgeInsets.only(bottom: 6),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text("${i + 1}. ${orderDeliveredListResponse?[i].name}",
              //             style: const TextStyle(fontSize: 14)),
              //         Text(
              //             "${orderDeliveredListResponse?[i].totalQuantity} ${orderDeliveredListResponse?[i].unit}",
              //             style: const TextStyle(fontSize: 14)),
              //       ],
              //     ),
              //   ),
              // if (orderDeliveredListResponse!.isNotEmpty) const Divider(),
              if (orderDeliveredList!.isNotEmpty) const SizedBox(height: 30),
              if (contractProgress!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.black45))),
                  width: double.maxFinite,
                  child: const Text("Contract Progress",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),

              if (contractProgress!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.only(bottom: 10, top: 10),
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.black45),
                          top: BorderSide(color: Colors.black45))),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: const Text("Company",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.black45),
                            right: BorderSide(color: Colors.black45),
                          ),
                        ),
                        width: MediaQuery.of(context).size.width * 0.14,
                        child: const Text("Skills",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.black45),
                          ),
                        ),
                        width: MediaQuery.of(context).size.width * 0.14,
                        child: const Text("Cert. %",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.14,
                        child: const Text("Total. %",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),

              for (int u = 0; u < contractProgress!.length; u++)
                Container(
                  padding: const EdgeInsets.only(bottom: 10, top: 10),
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.black45),
                          top: BorderSide(color: Colors.black45))),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Text(contractProgress?[u].mstCompanyName ?? '',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.black45),
                            right: BorderSide(color: Colors.black45),
                          ),
                        ),
                        width: MediaQuery.of(context).size.width * 0.14,
                        child: Text(contractProgress?[u].skillName ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.black45),
                          ),
                        ),
                        width: MediaQuery.of(context).size.width * 0.14,
                        child: Text(contractProgress?[u].quantification ?? '',
                            // '${contractProgress?[u].quantification} / ${contractProgress?[u].totalPercentage}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.14,
                        child: Text(
                            '${contractProgress?[u].woTotalQuantification} / ${contractProgress?[u].woTotalPercentage}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 6),

              const Text("Work Progress & Accomplishment's",
                  style: TextStyle(fontSize: 14)),
              const SizedBox(height: 5),
              for (int d = 0; d < workProgressList!.length; d++)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Text(
                        '${d + 1}. ${workProgressList?[d].title}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          setState(() {
                            workProgressList?.remove(workProgressList?[d]);
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(
                            Icons.close,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              workProgressAdd(),
              const SizedBox(height: 10),
              const Text("Upload", style: TextStyle(fontSize: 14)), //

              Row(
                children: [
                  InkWell(
                    onTap: () async {
                      // if (arrayFiles.length != 4) {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: [
                          'jpg',
                          'jpeg',
                          'png',
                          "mp4",
                          "pdf",
                        ],
                      );
                      if (result != null) {
                        PlatformFile file = result.files.first;
                        Uint8List? fileBytes = result.files.first.bytes;
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
                        if (arrayFiles[j].extension == 'jpg' ||
                            arrayFiles[j].extension == 'jpeg' ||
                            arrayFiles[j].extension == 'png')
                          Container(
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
                          ),
                        if (arrayFiles[j].extension == 'mp4')
                          Container(
                            padding: const EdgeInsets.only(right: 10),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(
                                  Icons.video_camera_back,
                                  size: 80,
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
                        if (arrayFiles[j].extension == 'pdf')
                          Container(
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

                  // for(int g = 0; g<uploadImage!.length; g++)
                  for (int i = 0; i < uploadImage!.length; i++)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        InkWell(
                          onTap: () async {
                            // if (uploadImage![i].contains('.pdf')) {
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (_) {
                            //         return PdfViewer(
                            //           fileName:
                            //               '${AppUrl.dprUploadImg}${uploadImage![i].toString()}',
                            //           fileUrl:
                            //               '${AppUrl.dprUploadImg}${uploadImage![i].toString()}',
                            //         );
                            //       },
                            //     ),
                            //   );
                            // } else if (uploadImage![i].contains('.mp4')) {
                            //   final uri = Uri.parse(
                            //       '${AppUrl.dprUploadImg}${uploadImage![i].toString()}');
                            //   if (await canLaunchUrl(uri)) {
                            //     await launchUrl(uri);
                            //   } else {
                            //     throw 'Could not launch';
                            //   }
                            // } else {
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (_) {
                            //         return ImagePreviewViewer(
                            //           fileName: uploadImage![i].toString(),
                            //           fileUrl:
                            //               '${AppUrl.dprUploadImg}${uploadImage![i].toString()}',
                            //         );
                            //       },
                            //     ),
                            //   );
                            // }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              // border: Border.all(
                              //   color: Colors.grey,
                              // ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            width: 140,
                            child: Column(
                              children: [
                                uploadImage![i].contains('.pdf')
                                    ? Image.asset(
                                        'images/projectmanagement/pdf.png',
                                        width: 100,
                                        height: 100,
                                      )
                                    : uploadImage![i].contains('.mp4')
                                        ? const Icon(
                                            Icons.video_camera_back,
                                            size: 80,
                                          )
                                        : Image.network(
                                            '${AppUrl.dprUploadImg}${uploadImage![i].toString()}',
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.fill,
                                          ),
                                AppText(
                                  title: uploadImage![i],
                                  fontSize: 14,
                                )
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: InkWell(
                            onTap: () {
                              // setState(() {
                              deleteDocUploaded(
                                  document_name: uploadImage?[i] ?? '',
                                  project_dpr_id: widget.project_dpr_id ?? '');
                              // arrayFilesBytes.remove(arrayFilesBytes[j]);
                              // });
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget slabNo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Slab No.',
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
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: InkWell(
                onTap: () {
                  selectSlabNumberModal();
                },
                child: TextFormField(
                  enabled: false,
                  controller: _slabNumberController,
                  style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(top: 0.0),
                      border: InputBorder.none,
                      hintText: 'Select Slab number',
                      hintStyle: TextStyle(color: Colors.black45)),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget selectDate() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Select Date',
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
              _selectFromDate(context);
            },
            child: TextFormField(
              // validator: (value) {
              //   if (value!.isEmpty) {
              //     return "(From Date Cannot be Ready)";
              //   }
              // },
              enabled: false,
              readOnly: true,
              controller: fromDateControler,
              style: const TextStyle(color: Colors.black, fontSize: 13.0),
              decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                    color: Colors.grey,
                  )),
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                    color: Colors.red,
                  )),
                  contentPadding: EdgeInsets.all(12.0),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  hintText: 'Select Date',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 116, 116, 116),
                    fontSize: 13.0,
                    fontWeight: FontWeight.w200,
                    fontFamily: 'HelveticaNeue',
                  ),
                  suffixIcon: Icon(
                    Icons.calendar_month_outlined,
                  )),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedFormDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedFormDate) {
      setState(() {
        _selectedFormDate = picked;
        fromDateControler.text =
            DateFormat('dd MMMM yyyy', 'en_US').format(_selectedFormDate!);
      });
    }
  }

  Widget workType() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Work Type *',
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
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: TextFormField(
                controller: _workTypeController,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(top: 0.0),
                  border: InputBorder.none,
                  hintText: 'Enter Work Type',
                  hintStyle: TextStyle(
                      color: Colors.black45, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget contractor() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Contractor *',
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
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: InkWell(
                onTap: () {
                  editingController.clear();
                  selectContractorModal();
                },
                child: TextFormField(
                  enabled: false,
                  controller: _contractorController,
                  style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(top: 0.0),
                    border: InputBorder.none,
                    hintText: 'Select Contractor',
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  selectSlabNumberModal() {
    return showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 10),
              actionsPadding: const EdgeInsets.only(bottom: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: const Text(
                'SELECT SLAB NUMBER',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              actions: [
                InkWell(
                  onTap: () {
                    // print('Selected');
                    // var castingFor = "";
                    // // List<Skill>? skillTemp;
                    // for (int i = 0; i < contrctorList!.length; i++) {
                    //   if (contrctorList![i].isSelected == true) {
                    //     // skillTemp = [
                    //     //   ...?skillTemp,
                    //     //   ...?contrctorList?[indexFor].skill
                    //     // ];
                    //     if (castingFor.isEmpty) {
                    //       if (contrctorList![i].count != null &&
                    //           contrctorList![i].count?.trim() != "" &&
                    //           contrctorList![i].count?.length != 0) {
                    //         castingFor =
                    //             '${contrctorList![i].companyName} (${contrctorList![i].count?.length})';
                    //       } else {
                    //         castingFor = '${contrctorList![i].companyName}';
                    //       }
                    //     } else {
                    //       if (contrctorList?[i].count != null &&
                    //           contrctorList![i].count?.trim() != "" &&
                    //           contrctorList![i].count?.length != 0) {
                    //         castingFor =
                    //             "$castingFor, ${contrctorList?[i].companyName} (${contrctorList?[i].count})";
                    //       } else {
                    //         castingFor =
                    //             "$castingFor, ${contrctorList?[i].companyName}";
                    //       }
                    //     }
                    //   }
                    // }
                    // _contractorController.text = castingFor;
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
                    // print('Selected');
                    // var castingFor = "";
                    // // List<Skill>? skillTemp;
                    // for (int i = 0; i < contrctorList!.length; i++) {
                    //   if (contrctorList![i].isSelected == true) {
                    //     // skillTemp = [
                    //     //   ...?skillTemp,
                    //     //   ...?contrctorList?[indexFor].skill
                    //     // ];
                    //     if (castingFor.isEmpty) {
                    //       if (contrctorList![i].count != null &&
                    //           contrctorList![i].count?.trim() != "" &&
                    //           contrctorList![i].count?.length != 0) {
                    //         castingFor =
                    //             '${contrctorList![i].companyName} (${contrctorList![i].count})';
                    //       } else {
                    //         castingFor = '${contrctorList![i].companyName}';
                    //       }
                    //     } else {
                    //       if (contrctorList?[i].count != null &&
                    //           contrctorList![i].count?.trim() != "" &&
                    //           contrctorList![i].count?.length != 0) {
                    //         castingFor =
                    //             "$castingFor, ${contrctorList?[i].companyName} (${contrctorList?[i].count})";
                    //       } else {
                    //         castingFor =
                    //             "$castingFor, ${contrctorList?[i].companyName}";
                    //       }
                    //     }
                    //   }
                    // }
                    // _contractorController.text = castingFor;
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
                      SizedBox(
                        height: 40,
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              isLoad = false;
                            });
                            // getAllSalesLead();
                          },
                          style: const TextStyle(fontSize: 13),
                          controller: editingController,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(12.0),
                              labelText: "Search by Name",
                              hintText: "Search by Name",
                              prefixIcon: Icon(Icons.search),
                              // suffixIcon: editingController.text.length > 0
                              //     ? InkWell(
                              //         onTap: () {
                              //           // setState(() {
                              //           //   offset = '0';
                              //           // });
                              //           setState(() {
                              //             isLoad = false;
                              //           });
                              //           editingController.clear();
                              //           // getAllSalesLead();
                              //         },
                              //         child: Container(
                              //           padding:
                              //               const EdgeInsets.only(right: 12),
                              //           child: const Icon(Icons.close_rounded),
                              //         ),
                              //       )
                              //     : const SizedBox.shrink(),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)))),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 340,
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: searchSlabList(
                                    masnoryList!, editingController.text)
                                .length, // contrctorList?.length,

                            itemBuilder: (context, int indexFor) {
                              MasnoryList contrctorListTemp = searchSlabList(
                                  masnoryList!,
                                  editingController.text)[indexFor];

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    contrctorListSelected = contrctorListTemp;
                                    _slabNumberController.text =
                                        contrctorListTemp.name ?? '';

                                    widget.slabId = contrctorListTemp
                                        .id; // if (contrctorListTemp.isSelected == true) {
                                    //   contrctorListTemp.isSelected = false;
                                    // } else {
                                    //   contrctorListTemp.isSelected = true;
                                    // }
                                  });
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
                                            contrctorListTemp.name ?? '',
                                            // 'slabDetails![indexFor].slabName!',
                                            style: normalText,
                                          ),
                                          // slabDetails![indexFor].selected == '1'
                                          // true
                                          // contrctorListTemp.isSelected == true
                                          contrctorListSelected.id ==
                                                  contrctorListTemp.id
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
          return StatefulBuilder(builder: (context, setState) {
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
                    print('Selected');
                    var castingFor = "";
                    // List<Skill>? skillTemp;
                    for (int i = 0; i < contrctorList!.length; i++) {
                      if (contrctorList![i].isSelected == true) {
                        // skillTemp = [
                        //   ...?skillTemp,
                        //   ...?contrctorList?[indexFor].skill
                        // ];
                        if (castingFor.isEmpty) {
                          if (contrctorList![i].count != null &&
                              contrctorList![i].count?.trim() != "" &&
                              contrctorList![i].count?.length != 0) {
                            castingFor =
                                '${contrctorList![i].companyName} (${contrctorList![i].count?.length})';
                          } else {
                            castingFor = '${contrctorList![i].companyName}';
                          }
                        } else {
                          if (contrctorList?[i].count != null &&
                              contrctorList![i].count?.trim() != "" &&
                              contrctorList![i].count?.length != 0) {
                            castingFor =
                                "$castingFor, ${contrctorList?[i].companyName} (${contrctorList?[i].count})";
                          } else {
                            castingFor =
                                "$castingFor, ${contrctorList?[i].companyName}";
                          }
                        }
                      }
                    }
                    _contractorController.text = castingFor;
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
                    print('Selected');
                    var castingFor = "";
                    // List<Skill>? skillTemp;
                    for (int i = 0; i < contrctorList!.length; i++) {
                      if (contrctorList![i].isSelected == true) {
                        // skillTemp = [
                        //   ...?skillTemp,
                        //   ...?contrctorList?[indexFor].skill
                        // ];
                        if (castingFor.isEmpty) {
                          if (contrctorList![i].count != null &&
                              contrctorList![i].count?.trim() != "" &&
                              contrctorList![i].count?.length != 0) {
                            castingFor =
                                '${contrctorList![i].companyName} (${contrctorList![i].count})';
                          } else {
                            castingFor = '${contrctorList![i].companyName}';
                          }
                        } else {
                          if (contrctorList?[i].count != null &&
                              contrctorList![i].count?.trim() != "" &&
                              contrctorList![i].count?.length != 0) {
                            castingFor =
                                "$castingFor, ${contrctorList?[i].companyName} (${contrctorList?[i].count})";
                          } else {
                            castingFor =
                                "$castingFor, ${contrctorList?[i].companyName}";
                          }
                        }
                      }
                    }
                    _contractorController.text = castingFor;
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
                      SizedBox(
                        height: 40,
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              isLoad = false;
                            });
                            // getAllSalesLead();
                          },
                          style: const TextStyle(fontSize: 13),
                          controller: editingController,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(12.0),
                              labelText: "Search by Name",
                              hintText: "Search by Name",
                              prefixIcon: Icon(Icons.search),
                              // suffixIcon: editingController.text.length > 0
                              //     ? InkWell(
                              //         onTap: () {
                              //           // setState(() {
                              //           //   offset = '0';
                              //           // });
                              //           setState(() {
                              //             isLoad = false;
                              //           });
                              //           editingController.clear();
                              //           // getAllSalesLead();
                              //         },
                              //         child: Container(
                              //           padding:
                              //               const EdgeInsets.only(right: 12),
                              //           child: const Icon(Icons.close_rounded),
                              //         ),
                              //       )
                              //     : const SizedBox.shrink(),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)))),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 340,
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: searchcontrctorList(
                                    contrctorList!, editingController.text)
                                .length, // contrctorList?.length,

                            itemBuilder: (context, int indexFor) {
                              ContrctorList contrctorListTemp =
                                  searchcontrctorList(contrctorList!,
                                      editingController.text)[indexFor];
                              TextEditingController _noOfLabourController =
                                  TextEditingController();
                              _noOfLabourController.text =
                                  contrctorListTemp.count ?? '';
                              return InkWell(
                                onTap: () {
                                  var castingFor = "";
                                  List<Skill>? skillTemp = [];
                                  List<Skill>? uniqueData = [];

                                  setState(() {
                                    if (contrctorListTemp.isSelected == true) {
                                      contrctorListTemp.isSelected = false;
                                      contrctorListTemp.count = "";
                                    } else {
                                      contrctorListTemp.isSelected = true;
                                    }
                                  });
                                  // _noOfLabourController.text =
                                  //     contrctorList?[indexFor].count ?? '';

                                  // setState(() {
                                  //   skillTemp?.clear();
                                  // });
                                  for (int i = 0;
                                      i < contrctorList!.length;
                                      i++) {
                                    if (contrctorList?[i].isSelected == true) {
                                      skillTemp = [
                                        ...?skillTemp,
                                        ...?contrctorList?[i].skill
                                      ];
                                      if (castingFor.isEmpty) {
                                        castingFor =
                                            '${contrctorList?[i].companyName} (${contrctorList?[i].count})';
                                      } else {
                                        castingFor =
                                            "$castingFor, ${contrctorList?[i].companyName!} (${contrctorList![i].count})";
                                      }
                                    }
                                  }
                                  // _contractorController.text = castingFor;
                                  if (skillTemp?.length != 0) {
                                    for (var item in skillTemp!) {
                                      bool isDuplicate = false;
                                      for (var uniqueItem in uniqueData) {
                                        if (item.mstWorkName ==
                                            uniqueItem.mstWorkName) {
                                          isDuplicate = true;
                                          break;
                                        }
                                      }
                                      if (!isDuplicate) {
                                        uniqueData.add(item);
                                      }
                                    }
                                    setState(() {
                                      skillResponse = uniqueData;
                                    });
                                  } else {
                                    setState(() {
                                      skillResponse?.clear();
                                    });
                                  }

                                  // updateRequirementFor(castingFor, index);
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
                                            contrctorListTemp.companyName ?? '',
                                            // 'slabDetails![indexFor].slabName!',
                                            style: normalText,
                                          ),
                                          // slabDetails![indexFor].selected == '1'
                                          // true
                                          contrctorListTemp.isSelected == true
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
                                      Row(
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment.start,
                                        // crossAxisAlignment:
                                        //     CrossAxisAlignment.start,
                                        children: [
                                          const Text("No of Labour :"),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Container(
                                            height: 45.0,
                                            width: 100,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey,
                                                ),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(5.0))),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0,
                                                  right: 10.0,
                                                  top: 0),
                                              child: TextFormField(
                                                enabled: contrctorListTemp
                                                    .isSelected,
                                                // contrctorListTemp.isSelected
                                                controller:
                                                    _noOfLabourController,
                                                onChanged: (value) {
                                                  contrctorListTemp.count =
                                                      value;
                                                },
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12.0,
                                                    height: 1),
                                                decoration:
                                                    const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  border: InputBorder.none,
                                                  hintText:
                                                      'Enter No of Labour',
                                                ),
                                              ),
                                            ),
                                          ),
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

  selectActivityModal({required BuildContext contextModal}) {
    return showDialog<void>(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 10),
              actionsPadding: const EdgeInsets.only(bottom: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: const Text(
                'SELECT ACTIVITIES',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.of(contextModal).pop();
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
                  onTap: () {
                    Navigator.of(contextModal).pop();
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
                      SizedBox(
                        height: 40,
                        child: TextField(
                          onChanged: (value) {
                            // setState(() {
                            //   offset = '0';
                            // });
                            // getAllSalesLead();
                            setState(() {
                              isLoad = false;
                            });
                          },
                          style: const TextStyle(fontSize: 13),
                          controller: activityModalController,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(12.0),
                              labelText: "Search by Name",
                              hintText: "Search by Name",
                              prefixIcon: Icon(Icons.search),
                              // suffixIcon: activityModalController.text.length >
                              //         0
                              //     ? InkWell(
                              //         onTap: () {
                              //           // setState(() {
                              //           //   offset = '0';
                              //           // });
                              //           activityModalController.clear();
                              //           // getAllSalesLead();
                              //         },
                              //         child: Container(
                              //           padding:
                              //               const EdgeInsets.only(right: 12),
                              //           child: const Icon(Icons.close_rounded),
                              //         ),
                              //       )
                              //     : const SizedBox.shrink(),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)))),
                        ),
                      ),
                      const SizedBox(height: 10),
                      searchActivitiesList(skillResponse!,
                                      activityModalController.text)
                                  .length !=
                              0
                          ? SizedBox(
                              height: 340,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: searchActivitiesList(
                                          skillResponse!,
                                          activityModalController.text)
                                      .length,
                                  // skillResponse?.length,
                                  itemBuilder: (contextModal, int indexFor) {
                                    //inspect(skillResponse);
                                    Skill tempSkills = searchActivitiesList(
                                        skillResponse!,
                                        activityModalController.text)[indexFor];
                                    return InkWell(
                                      onTap: () {
                                        var castingFor = "";
                                        setState(() {
                                          if (tempSkills.isSelected == true) {
                                            tempSkills.isSelected = false;
                                          } else {
                                            tempSkills.isSelected = true;
                                          }
                                        });
                                        // setState(() {
                                        //   if (slabDetails![indexFor].selected ==
                                        //       "1") {
                                        //     slabDetails![indexFor].selected = '0';
                                        //   } else {
                                        //     slabDetails![indexFor].selected = '1';
                                        //   }
                                        // });
                                        for (int i = 0;
                                            i < skillResponse!.length;
                                            i++) {
                                          if (skillResponse![i].isSelected ==
                                              true) {
                                            if (castingFor.isEmpty) {
                                              castingFor = skillResponse![i]
                                                  .mstWorkName!;
                                            } else {
                                              castingFor =
                                                  "$castingFor, ${skillResponse![i].mstWorkName!}";
                                            }
                                          }
                                        }
                                        // updateRequirementFor(castingFor, index);
                                        _activityController.text = castingFor;
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 13.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  tempSkills.mstWorkName ?? '',
                                                  // 'slabDetails![indexFor].slabName!',
                                                  style: normalText,
                                                ),
                                                // slabDetails![indexFor].selected == '1'
                                                // true
                                                tempSkills.isSelected == true
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
                                                height: 1.0,
                                                color: Colors.black),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            )
                          // if (searchActivitiesList(
                          //             skillResponse!, activityModalController.text)
                          //         .length ==
                          //     0)
                          : Center(
                              child: InkWell(
                                onTap: () {
                                  // print('Selected');
                                  // var castingFor = "";
                                  // setState(() {
                                  //   skillResponse?.add(Skill(
                                  //       mstWorkName:
                                  //           activityModalController.text,
                                  //       mstWorkId: "",
                                  //       isSelected: true));
                                  //   activityModalController.clear();
                                  // });

                                  // for (int i = 0;
                                  //     i < skillResponse!.length;
                                  //     i++) {
                                  //   if (skillResponse![i].isSelected == true) {
                                  //     if (castingFor.isEmpty) {
                                  //       castingFor =
                                  //           skillResponse![i].mstWorkName!;
                                  //     } else {
                                  //       castingFor =
                                  //           "$castingFor, ${skillResponse![i].mstWorkName!}";
                                  //     }
                                  //   }
                                  // }
                                  // // updateRequirementFor(castingFor, index);
                                  // _activityController.text = castingFor;
                                  // Navigator.of(contextModal).pop();
//                                   Future.delayed(Duration(seconds: 2), () {
// // code to be executed after 2 seconds
//                                     addCustomActivityModal();
//                                   });
                                  Navigator.of(context).pop();
                                  addCustomActivityModal();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(6)),
                                  margin: const EdgeInsets.only(top: 150),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 16),
                                  child: const Text(
                                    "ADD CUSTOM ACTIVITY",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
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

  addCustomActivityModal() {
    return showDialog<void>(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 10),
              actionsPadding:
                  const EdgeInsets.only(bottom: 10, left: 16, right: 16),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: const Text(
                'ENTER ACTIVITIES',
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
                  onTap: () {
                    Navigator.of(context).pop();
                    var castingFor = "";
                    setState(() {
                      skillResponse?.add(Skill(
                          mstWorkName: activityModalController.text,
                          mstWorkId: "",
                          isSelected: true));
                      activityModalController.clear();
                    });

                    for (int i = 0; i < skillResponse!.length; i++) {
                      if (skillResponse![i].isSelected == true) {
                        if (castingFor.isEmpty) {
                          castingFor = skillResponse![i].mstWorkName!;
                        } else {
                          castingFor =
                              "$castingFor, ${skillResponse![i].mstWorkName!}";
                        }
                      }
                    }
                    // updateRequirementFor(castingFor, index);
                    _activityController.text = castingFor;
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
                width: 300,
                // height: 104,
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    onChanged: (value) {
                      // setState(() {
                      //   offset = '0';
                      // });
                      // getAllSalesLead();
                      setState(() {
                        isLoad = false;
                      });
                    },
                    style: const TextStyle(fontSize: 13),
                    controller: activityModalController,
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(12.0),
                        // labelText: "Search by Name",
                        hintText: "Search by Name",
                        prefixIcon: Icon(Icons.search),
                        // suffixIcon: activityModalController.text.length >
                        //         0
                        //     ? InkWell(
                        //         onTap: () {
                        //           // setState(() {
                        //           //   offset = '0';
                        //           // });
                        //           activityModalController.clear();
                        //           // getAllSalesLead();
                        //         },
                        //         child: Container(
                        //           padding:
                        //               const EdgeInsets.only(right: 12),
                        //           child: const Icon(Icons.close_rounded),
                        //         ),
                        //       )
                        //     : const SizedBox.shrink(),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)))),
                  ),
                ),
              ),
            );
          });
        });
  }

  enterCustomCategoryModal() {
    return showDialog<void>(
        barrierDismissible: true,
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
            title: const Text(
              'ENTER CUSTOM CATEGORY',
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
                  if (_formKeyCustomCategory.currentState!.validate()) {
                    setState(() {
                      customType?.add(
                        CustomType(
                          editingTextController: TextEditingController(),
                          name: _customCategoryController.text,
                        ),
                      );
                    });

                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(7)),
                  child: const Center(
                    child: Text(
                      "SUBMIT",
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
              height: 140,
              child: Form(
                key: _formKeyCustomCategory,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "(Custom Category Cannot Be Empty)";
                        }
                        return null;
                      },
                      style: const TextStyle(fontSize: 13),
                      controller: _customCategoryController,
                      decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Colors.grey,
                          )),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Colors.red,
                          )),
                          contentPadding: EdgeInsets.all(15.0),
                          hintText: 'Enter Custom Category',
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7.0)))),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget activity() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Activity *',
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
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: InkWell(
                onTap: () {
                  if (skillResponse?.length != 0 && skillResponse != null) {
                    selectActivityModal(contextModal: context);
                  } else {
                    commonAleertModal(textTitle: "Please Select Contractor");
                  }
                },
                child: TextFormField(
                  enabled: false,
                  controller: _activityController,
                  style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(top: 0.0),
                    border: InputBorder.none,
                    hintText: 'Select Activity',
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget dificultiesNrequirements() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Difficulties & Requirements',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: 76.0,
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 10.0, right: 10.0),
              child: TextFormField(
                maxLines: 3,
                // enabled: false,
                controller: _dificultiesNrequirementsController,
                style: normalText,
                // style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(top: 0.0),
                  border: InputBorder.none,
                  hintText: 'Enter Difficulties & Requirements',
                  hintStyle: TextStyle(
                      color: Colors.black45, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget visitorss() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Visitors',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: 76.0,
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 10.0, right: 10.0),
              child: TextFormField(
                maxLines: 3,
                // enabled: false,
                controller: _visitorsController,
                style: normalText,
                // style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(top: 0.0),
                  border: InputBorder.none,
                  hintText: 'Enter Visitors',
                  hintStyle: TextStyle(
                      color: Colors.black45, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget yesterdayWorkDone() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Yesterday Work Done:',
                  style: TextStyle(
                      backgroundColor: Colors.white,
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w600)),
              for (int j = 0; j < dprFinishingYesterdayActivity!.length; j++)
                InkWell(
                  onTap: () {
                    if (dprFinishingYesterdayActivity?[j].dprFlag == '1') {
                      setState(() {
                        dprFinishingYesterdayActivity?[j].dprFlag = '0';
                      });
                    } else {
                      setState(() {
                        dprFinishingYesterdayActivity?[j].dprFlag = '1';
                      });
                    }
                  },
                  child: Text(
                      '${j + 1}. ${dprFinishingYesterdayActivity?[j].description}',
                      style: const TextStyle(
                          backgroundColor: Colors.white,
                          fontSize: 15,
                          color: Colors.black)),
                ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Target Achieved On',
                  // textAlign: TextAlign.end,
                  style: TextStyle(
                      backgroundColor: Colors.white,
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w600)),
              for (int j = 0; j < dprFinishingYesterdayActivity!.length; j++)
                InkWell(
                  onTap: () {
                    if (dprFinishingYesterdayActivity?[j].dprFlag == '1') {
                      setState(() {
                        dprFinishingYesterdayActivity?[j].dprFlag = '0';
                      });
                    } else {
                      setState(() {
                        dprFinishingYesterdayActivity?[j].dprFlag = '1';
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Text('${dprFinishingYesterdayActivity?[j].targetdate}',
                          style: const TextStyle(
                              backgroundColor: Colors.white,
                              fontSize: 15,
                              color: Colors.black)),
                      const SizedBox(
                        width: 6,
                      ),
                      Icon(
                        dprFinishingYesterdayActivity?[j].dprFlag == '1'
                            ? Icons.check_circle_outline_sharp
                            : Icons.circle_outlined,
                        color: dprFinishingYesterdayActivity?[j].dprFlag == '1'
                            ? Colors.green
                            : Colors.grey,
                        size: 18,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget addStaff() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 40,
              child: const Text("",
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w600)),
            ),
            const Expanded(
                child: Text("Team Members",
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w600))),
            Container(
              margin: const EdgeInsets.only(left: 10),
              width: 160,
              child: const Text("In Time",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w600)),
            ),
            Container(
              margin: const EdgeInsets.only(left: 10),
              width: 160,
              child: const Text("Out Time",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w600)),
            ),
            const Icon(
              Icons.cancel_outlined,
              color: Colors.transparent,
            )
          ],
        ),
        for (int t = 0; t < dprStaffList!.length; t++)
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 40,
                  child: Text('${t + 1}.'),
                ),
                Expanded(
                  child: TextFormField(
                    onChanged: (value) {
                      dprStaffList?[t].staffName = value;
                    },
                    controller:
                        TextEditingController(text: dprStaffList?[t].staffName),
                    style: const TextStyle(color: Colors.black, fontSize: 13.0),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(12.0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      hintText: 'Enter  Name',
                      // hintStyle: TextStyle(
                      //   color: Color.fromARGB(255, 116, 116, 116),
                      //   fontSize: 13.0,
                      //   fontWeight: FontWeight.w200,
                      //   fontFamily: 'HelveticaNeue',
                      // ),
                      hintStyle: TextStyle(
                          color: Colors.black45, fontWeight: FontWeight.w400),
                      // suffixIcon: Icon(
                      //   Icons.calendar_month_outlined,
                      // ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  width: 160,
                  child: TextFormField(
                    controller:
                        TextEditingController(text: dprStaffList?[t].inTime),
                    style: const TextStyle(color: Colors.black, fontSize: 13.0),
                    readOnly: true,
                    onTap: () => _selectInTime(context, t),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(12.0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      hintText: 'In Time',
                      // hintStyle: TextStyle(
                      //   color: Color.fromARGB(255, 116, 116, 116),
                      //   fontSize: 13.0,
                      //   fontWeight: FontWeight.w200,
                      //   fontFamily: 'HelveticaNeue',
                      // ),
                      hintStyle: TextStyle(
                          color: Colors.black45, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  width: 160,
                  child: TextFormField(
                    style: const TextStyle(color: Colors.black, fontSize: 13.0),
                    controller:
                        TextEditingController(text: dprStaffList?[t].outTime),
                    readOnly: true,
                    onTap: () => _selectOutTime(context, t),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(12.0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      hintText: 'Out Time',
                      // hintStyle: TextStyle(
                      //   color: Color.fromARGB(255, 116, 116, 116),
                      //   fontSize: 13.0,
                      //   fontWeight: FontWeight.w200,
                      //   fontFamily: 'HelveticaNeue',
                      // ),
                      hintStyle: TextStyle(
                          color: Colors.black45, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                t != 0
                    ? InkWell(
                        onTap: () {
                          setState(() {
                            dprStaffList?.remove(dprStaffList?[t]);
                          });
                        },
                        child: const Icon(
                          Icons.cancel_outlined,
                          size: 20,
                        ))
                    : const Icon(
                        Icons.circle,
                        color: Colors.transparent,
                        size: 20,
                      )
              ],
            ),
          )
      ],
    );
  }

  Widget todaysPlanActivity() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Today's Planned Activity:",
                  style: TextStyle(
                      backgroundColor: Colors.white,
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              // for (int j = 0; j < todaysPlanActivitySelected!.length; j++)
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: todaysPlanActivitySelected!.length,
                  itemBuilder: (context, index) {
                    todaysPlanActivitySelected?[index]
                            .dprActivityDateController
                            .text =
                        todaysPlanActivitySelected?[index].targetdate ?? '';

                    todaysPlanActivitySelected?[index]
                            .dprActivityController
                            .text =
                        todaysPlanActivitySelected?[index].description ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14, right: 40),
                      child: Row(
                        children: [
                          const SizedBox(width: 4),
                          Text(
                            '${index + 1} .',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              // readOnly: true,
                              enabled:
                                  todaysPlanActivitySelected?[index].dprFlag ==
                                          "1"
                                      ? true
                                      : false,
                              controller: todaysPlanActivitySelected?[index]
                                  .dprActivityController,
                              onChanged: (value) {
                                todaysPlanActivitySelected?[index]
                                    .descriptionVal = value;
                                todaysPlanActivitySelected?[index].description =
                                    value;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "(Title Cannot Be Empty)";
                                }
                                return null;
                              },
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 13.0),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(12.0),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black)),
                                hintText: 'Please Enter Planned Activity',
                                hintStyle: TextStyle(
                                  color: Color.fromARGB(255, 116, 116, 116),
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w200,
                                  fontFamily: 'HelveticaNeue',
                                ),
                                // suffixIcon: Icon(
                                //   Icons.calendar_month_outlined,
                                // ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              // Text('$j. ${dprYesterdayActivity?[j].description}',
              //     style: const TextStyle(
              //         backgroundColor: Colors.white,
              //         fontSize: 15,
              //         color: Colors.black)),
            ],
          ),
        ),
        // SizedBox(width: 50),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Target Completion On',
                  // textAlign: TextAlign.end,
                  style: TextStyle(
                      backgroundColor: Colors.white,
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              for (int j = 0; j < todaysPlanActivitySelected!.length; j++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null) {
                              // setState(() {
                              // _selectedToDate = picked;
                              todaysPlanActivitySelected?[j].targetdate =
                                  DateFormat('yyyy-MM-dd').format(picked);
                              todaysPlanActivitySelected?[j]
                                      .dprActivityDateController
                                      .text =
                                  DateFormat('yyyy-MM-dd').format(picked);
                              // });
                            }
                          },
                          child: TextFormField(
                            enabled: false,
                            controller: todaysPlanActivitySelected?[j]
                                .dprActivityDateController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "(Target Completion Date Cannot Be Empty)";
                              }
                              return null;
                            },
                            style: const TextStyle(
                                color: Colors.black, fontSize: 13.0),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(12.0),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              hintText: 'Please Select Target Completion Date',
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 116, 116, 116),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'HelveticaNeue',
                              ),
                              // suffixIcon: Icon(
                              //   Icons.calendar_month_outlined,
                              // ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      if (j != 0)
                        InkWell(
                          onTap: () {
                            setState(() {
                              todaysPlanActivitySelected
                                  ?.remove(todaysPlanActivitySelected?[j]);
                            });
                          },
                          child: const Icon(
                            Icons.cancel_outlined,
                            size: 18,
                          ),
                        ),
                      const SizedBox(
                        width: 30,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget addCustomCategory() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            // child: Text('Activity',
            //     style: TextStyle(
            //         backgroundColor: Colors.white,
            //         fontSize: 15,
            //         color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: 45.0,
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: InkWell(
                onTap: () {
                  enterCustomCategoryModal();
                },
                child: const Center(
                    child: Text(
                  "ADD CUSTOM CATEGORY",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ))),
          ),
        )
      ],
    );
  }

  Widget addToTodaysPlan() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            // child: Text('Activity',
            //     style: TextStyle(
            //         backgroundColor: Colors.white,
            //         fontSize: 15,
            //         color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: 45.0,
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: InkWell(
                onTap: () {
                  for (int j = 0;
                      j < dprFinishingYesterdayActivity!.length;
                      j++) {
                    if (dprFinishingYesterdayActivity?[j].dprFlag == '1') {
                      setState(() {
                        if (todaysPlanActivitySelected?.length == 1 &&
                            todaysPlanActivitySelected?[0].description == '' &&
                            todaysPlanActivitySelected?[0].targetdate == '' &&
                            todaysPlanActivitySelected?[0]
                                    .dprActivityController
                                    .text ==
                                '' &&
                            todaysPlanActivitySelected?[0]
                                    .dprActivityDateController
                                    .text ==
                                '') {
                          print('--------------------------------------');
                          todaysPlanActivitySelected = [
                            DprYesterdayActivity(
                                dprFlag:
                                    "0", //dprYesterdayActivity![j].dprFlag,
                                isSelected: false,
                                descriptionVal: '',
                                dprActivityController: TextEditingController(
                                    text: dprFinishingYesterdayActivity![j]
                                        .description),
                                id: '1',
                                targetdate: dprFinishingYesterdayActivity![j]
                                    .targetdate,
                                description: dprFinishingYesterdayActivity![j]
                                    .description,
                                dprActivityDateController:
                                    TextEditingController(
                                        text: dprFinishingYesterdayActivity?[j]
                                            .targetdate))
                          ];
                        } else {
                          print('else----------------------------------------');
                          todaysPlanActivitySelected?.add(DprYesterdayActivity(
                              dprFlag: "0", //dprYesterdayActivity![j].dprFlag,
                              isSelected: false,
                              descriptionVal: '',
                              dprActivityController: TextEditingController(
                                  text: dprFinishingYesterdayActivity![j]
                                      .description),
                              id: (j + 1).toString(),
                              targetdate:
                                  dprFinishingYesterdayActivity![j].targetdate,
                              description:
                                  dprFinishingYesterdayActivity![j].description,
                              dprActivityDateController: TextEditingController(
                                  text: dprFinishingYesterdayActivity?[j]
                                      .targetdate)

                              // dprYesterdayActivity![j]
                              ));
                        }
                      });
                    }
                  }
                },
                child: const Center(
                    child: Text(
                  "ADD TO TODAY'S PLAN",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ))),
          ),
        )
      ],
    );
  }

  Widget addStaffBtn() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            // child: Text('Activity',
            //     style: TextStyle(
            //         backgroundColor: Colors.white,
            //         fontSize: 15,
            //         color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: 45.0,
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: InkWell(
                onTap: () {
                  setState(() {
                    dprStaffList?.add(DprStaffList(
                        staffName: '',
                        inTime: '',
                        outTime: '',
                        id: (dprStaffList!.length + 1).toString()));
                  });
                },
                child: const Center(
                    child: Text(
                  "ADD MEMBERS",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ))),
          ),
        )
      ],
    );
  }

  Widget rawMaterialDelivered() {
    return Column(
      children: [
        if (dprStockList!.isNotEmpty) const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black45))),
          width: double.maxFinite,
          child: const Text("Raw Material Inventory",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 10, top: 10),
          decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.black45),
                  top: BorderSide(color: Colors.black45))),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: const Text("Description",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.black45),
                    right: BorderSide(color: Colors.black45),
                  ),
                ),
                width: MediaQuery.of(context).size.width * 0.14,
                child: const Text("Stock In",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    // left: BorderSide(color: Colors.black45),
                    right: BorderSide(color: Colors.black45),
                  ),
                ),
                width: MediaQuery.of(context).size.width * 0.14,
                child: const Text("Stock Out",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.14,
                child: const Text("Consume",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        for (int s = 0; s < dprStockList!.length; s++)
          Container(
            padding: const EdgeInsets.only(bottom: 10, top: 10),
            decoration: const BoxDecoration(
                border: Border(
              bottom: BorderSide(color: Colors.black45),
              // top: BorderSide(color: Colors.black45)
            )),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Text(dprStockList![s].name ?? '',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.black45),
                      right: BorderSide(color: Colors.black45),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width * 0.14,
                  child: Text(dprStockList![s].stockIn ?? '',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      // left: BorderSide(color: Colors.black45),
                      right: BorderSide(color: Colors.black45),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width * 0.14,
                  child: Text(dprStockList![s].stockRemain ?? '',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.14,
                  child: Text(dprStockList![s].stockConsume ?? '',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        if (dprStockList!.isNotEmpty) const SizedBox(height: 30),
      ],
    );
  }

  Widget addPlannedActivity() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            // child: Text('Activity',
            //     style: TextStyle(
            //         backgroundColor: Colors.white,
            //         fontSize: 15,
            //         color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: 45.0,
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: InkWell(
                onTap: () {
                  setState(() {
                    todaysPlanActivitySelected?.add(DprYesterdayActivity(
                        dprFlag: '1',
                        dprActivityDateController: TextEditingController(),
                        isSelected: false,
                        id: (todaysPlanActivitySelected!.length + 1).toString(),
                        targetdate: "",
                        description: "",
                        descriptionVal: '',
                        dprActivityController: TextEditingController()));
                  });
                },
                child: const Center(
                    child: Text(
                  "ADD PLANNED ACTIVITY",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ))),
          ),
        )
      ],
    );
  }

  Widget dynamicCustomType({
    required CustomType data,
    required int indexx,
    required String title,
    required String titleVal,
    required String hintText,
    required TextEditingController textEditingController,
  }) {
    textEditingController.text = titleVal;
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 230.0,
                height: 40.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(title,
                      style: const TextStyle(
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
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: TextFormField(
                      onChanged: (value) {
                        // setState(() {
                        // data.editingTextController?.text = value;
                        data.value = value;
                        // });
                      },
                      controller: textEditingController,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 15.0),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(top: 0.0),
                        border: InputBorder.none,
                        hintText: hintText,
                        hintStyle: const TextStyle(
                            color: Colors.black45, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
              ),
              horizontalSpaceSmall,
              InkWell(
                onTap: () {
                  setState(() {
                    customType?[indexx].flag = "true";
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.only(top: 15.0),
                  child: Text('Work Report',
                      style: TextStyle(fontSize: 14, color: Colors.blue)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (customType?[indexx].flag == "true")
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 230.0,
                  height: 40.0,
                  child: Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: Text('',
                        style: TextStyle(
                            backgroundColor: Colors.white,
                            fontSize: 15,
                            color: Colors.black)),
                  ),
                ),
                horizontalSpaceSmall,
                Expanded(
                  child: Container(
                    height: 76.0,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5.0))),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 8, left: 10.0, right: 10.0),
                      child: TextFormField(
                        maxLines: 3,
                        // enabled: false,
                        controller: TextEditingController(
                            text: customType?[indexx].description),
                        onChanged: (value) {
                          customType?[indexx].description = value;
                        },
                        style: normalText,
                        // style: const TextStyle(color: Colors.black, fontSize: 15.0),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(top: 0.0),
                          border: InputBorder.none,
                          hintText: 'Enter Work Report',
                          hintStyle: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ),
                ),
                horizontalSpaceSmall,
                InkWell(
                  onTap: () {
                    setState(() {
                      // customType?.remove(data);
                      customType?[indexx].flag = "";
                      customType?[indexx].description = "";
                    });
                  },
                  child: Container(
                    height: 70.0,
                    child: const Icon(
                      Icons.cancel_outlined,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 26,
                ),
                horizontalSpaceSmall,
                horizontalSpaceSmall,
              ],
            )
        ],
      ),
    );
  }

  Widget workProgressAdd() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              height: 45.0,
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(5.0))),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: TextFormField(
                  controller: _workProgressAddController,
                  style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(top: 0.0),
                    border: InputBorder.none,
                    hintText: 'Enter Work Progress',
                    hintStyle: TextStyle(
                        color: Colors.black45, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 30),
          InkWell(
            onTap: () {
              setState(() {
                if (_workProgressAddController.text.trim().isNotEmpty) {
                  workProgressList?.add(WorkProgress(
                    title: _workProgressAddController.text,
                    id: '${workProgressList!.length + 1}',
                  ));
                  _workProgressAddController.clear();
                }
              });
            },
            child: Container(
              height: 45.0,
              width: 100,
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(5.0))),
              child: const Center(child: Text("ADD")),
            ),
          ),
        ],
      ),
    );
  }

  commonAleertModal({required String textTitle}) {
    return showDialog<void>(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 10),
              actionsPadding: const EdgeInsets.only(bottom: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: Text(
                textTitle,
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
                    width: 400,
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
              ],
              content: const SizedBox(
                width: 400,
                height: 0,
              ),
            );
          });
        });
  }
}
