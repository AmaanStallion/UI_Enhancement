import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/getPmsWorkList.dart';
import 'package:stallion/ui/views/accountmanagement/wopreviewhtml.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/src/tree_indentation.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/models/get_pms_project.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:url_launcher/url_launcher.dart';
import '../provider/home_provider/fetch_api_provider.dart';
import '../provider/provider_registration.dart';
import 'drag_and_drop.dart';

class Node {
  Node({
    required this.id,
    Iterable<Node>? children,
  }) : _children = <Node>[] {
    if (children == null) return;

    for (final Node child in children) {
      child._parent = this;
      _children.add(child);
    }
  }

  final int id;
  final List<Node> _children;

  Iterable<Node> get children => _children;
  bool get isLeaf => _children.isEmpty;

  Node? get parent => _parent;
  Node? _parent;

  int get index => _parent?._children.indexOf(this) ?? -1;

  void insertChild(int index, Node node) {
    // Adjust the index if necessary when dropping a node at the same parent
    if (node._parent == this && node.index < index) {
      index--;
    }

    // Ensure the node is removed from its previous parent and update it
    node
      .._parent?._children.remove(node)
      .._parent = this;

    _children.insert(index, node);
  }
}

class SelectedExampleNotifier extends ValueNotifier<Example> {
  SelectedExampleNotifier() : super(Example.dragAndDrop);

  void select(Example? example) {
    if (example == null) return;
    value = example;
  }
}

enum Example {
  dragAndDrop('Drag and Drop', Icon(Icons.move_down_rounded));

  const Example(this.title, this.icon);

  final String title;
  final Widget icon;

  Widget get tree {
    return const DragAndDropTreeView();
  }
}

class ScheduleView extends ConsumerStatefulWidget {
  ScheduleView(
      {super.key,
      required this.projectId,
      required this.towarId,
      required this.projectName,
      required this.isSetupDone,
      this.towarName});
  final String projectId;
  final String towarId;
  final String projectName;
  final String? towarName;
  bool isSetupDone;

  @override
  ConsumerState<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends ConsumerState<ScheduleView> {
  List<Map<String, dynamic>> updatedPmsListTemp = [];
  bool isValidateForDates = false;
  String isValidateForDatesString = "";

  bool isValidateStartEndLoop = false;
  TextEditingController remarkControler = TextEditingController();
  TextEditingController notifyStartDateControler = TextEditingController();
  TextEditingController notifyEndDateControler = TextEditingController();

  TextEditingController projectNameControler = TextEditingController();
  TextEditingController templateNameControler = TextEditingController();
  DateTime? selectedEndDatePopup;
  TextEditingController endDateControlerPopup = TextEditingController();

  DateTime? selectedStartDatePopup;
  TextEditingController startDateControlerPopup = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final GlobalKey<FormState> _keyFormPOPup = GlobalKey<FormState>();

  TextEditingController workOrderControler = TextEditingController();
  int? offsetRes;
  List<WorkOrderList>? workOrderListRes;
  final GlobalKey<FormState> _formKeySelectWorkOrder = GlobalKey<FormState>();
  ScrollController modalScrollController = ScrollController();
  List<ProjectDefaultLsit>? projectPmsDetailsResponse;
  List<ProjectDefaultLsit>? projectDefaultLsitResponse;
  ProjectDefaultLsit? selectedTemplate;
  bool isValidateingTemplatye = false;
  bool isLoad = true;
  bool isCancle = false;
  bool isSetFor = false;

  @override
  void initState() {
    // ref.read(homeProvider).setDrawerTitle("PMS-----------");
    setState(() {
      offsetRes = 0;
    });
    ref.read(fetchApiProvider).fetchRecords(
          projectId: widget.projectId,
          towarId: widget.towarId,
        );
    getProjectPms(projectId: widget.projectId, towarId: widget.towarId);

    fetchWorkOrders(projectId: widget.projectId, towarId: widget.towarId);
    // if (widget.isSetupDone) {
    // } else {

    // .then((value) => {
    //       setState(() {
    //         isSetFor = true;
    //       })
    //     });
    // }

    super.initState();
  }

  Future<List<WorkOrderList>?> fetchWorkOrders({
    required String projectId,
    required String towarId,
    bool isFromPagination = false,
  }) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": projectId,
      "towar_id": towarId,
      "search_data":
          workOrderControler.text.length > 2 ? workOrderControler.text : "",
      "limit": '50',
      "offset": '0',
      // workOrderControler.text.isNotEmpty ? "0" : offsetRes.toString(),
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(AppUrl.wsgetpmsWorkList, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getPmsWorkListFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          if (isFromPagination) {
          } else {
            workOrderListRes = dataModel.response?.workOrderList;
            // if (ref.read(homeProvider).workOrderListSelected != null &&
            //     dataModel.response?.workOrderList?.length != 0) {
            // if (ref
            //             .read(homeProvider)
            //             .dictDrawerData!
            //             .workOrderDetails
            //             ?.length !=
            //         0 &&
            //     workOrderListRes?[0] !=
            //         ref
            //             .read(homeProvider)
            //             .dictDrawerData!
            //             .workOrderDetails![0]) {
            //   workOrderListRes?.insert(
            //       0,
            //       ref
            //           .read(homeProvider)
            //           .dictDrawerData!
            //           .workOrderDetails![0]);
            // }
            // }
          }

          offsetRes = dataModel.response?.offset;
        });

        return dataModel.response?.workOrderList;
      } else {
        if (kDebugMode) {
          print(response.body);
        }
        return null;
      }
    }
  }

  Future<ResponseGetyPmsProjectResponse?> getProjectPms({
    required String projectId,
    required String towarId,
  }) async {
    // print("------------------------------------");
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": projectId,
      "towar_id": towarId,
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(AppUrl.wsgetpROJECTpMS, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getyPmsProjectResponseFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          projectPmsDetailsResponse = dataModel.response?.projectPmsDetails;
          projectDefaultLsitResponse = dataModel.response?.projectDefaultLsit;
        });
      } else {
        if (kDebugMode) {
          print(response.body);
        }
        return null;
      }
      return null;
    }
  }

  Future<ResponseGetyPmsProjectResponse?> deleteProjectPms({
    required String projectPmsId,
  }) async {
    // print("------------------------------------");
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_pms_id": projectPmsId,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.wsdeletepROJECTpMS, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      getProjectPms(projectId: widget.projectId, towarId: widget.towarId);

      return null;
    }
  }

  Future<ResponseGetyPmsProjectResponse?> setProjectPms({
    required String projectId,
    required String towarId,
    required String default_flag,
  }) async {
    // print('----------------------------------------------------');
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    String formatDate(DateTime dateTime) {
      // Format the DateTime as "yyyy-MM-dd" (e.g., "2023-09-01")
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    }

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": projectId,
      "towar_id": towarId,
      "project_pms_id": selectedTemplate?.mstProjectPmsId ?? '',
      "project_pms_name": templateNameControler.text,
      "project_pms_start_date": formatDate(selectedStartDatePopup!),
      "project_pms_end_date": formatDate(selectedEndDatePopup!),
      "default_flag": default_flag,
      "pms_reminder_start_date": notifyStartDateControler.text,
      "pms_reminder_end_date": notifyEndDateControler.text,
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(AppUrl.wsSetProjectPms, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        widget.isSetupDone = false;
      });
      ref.read(fetchApiProvider).fetchRecords(
            projectId: widget.projectId,
            towarId: widget.towarId,
          );
      getProjectPms(projectId: widget.projectId, towarId: widget.towarId);
      //   final dataModel = getyPmsProjectResponseFromJson(response.body);
      //   if (dataModel.response?.errorCode == "0") {
      //     setState(() {
      //       projectPmsDetailsResponse = dataModel.response?.projectPmsDetails;
      //       projectDefaultLsitResponse = dataModel.response?.projectDefaultLsit;
      //     });
      //   } else {
      //     if (kDebugMode) {
      //       print(response.body);
      //     }
      //     return null;
      //   }
      //   return null;
    }
  }

  Future<ResponseGetyPmsProjectResponse?> downloadPms({
    // required String projectId,
    // required String towarId,
    required String projectPmsId,
  }) async {
    // print('----------------------------------------------------');
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId ?? '',
      // "project_id": projectId,
      // "towar_id": towarId,
      "project_pms_id": projectPmsId,
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(AppUrl.wsProjectCmsExcel, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {}
  }

  @override
  void dispose() {
    // print("----------inside dispose---------------");
    // ref.read(fetchApiProvider).treeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    projectNameControler.text = widget.towarName!.isNotEmpty
        ? '${widget.projectName.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
        : widget.projectName.toUpperCase();

    Future<void> selectEndDatePopUp({
      required BuildContext context,
      required DateTime startDateRes,
      required DateTime endDateRes,
    }) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().isAfter(selectedStartDatePopup!)
            ? DateTime.now()
            : selectedStartDatePopup!,
        firstDate: selectedStartDatePopup == DateTime(2000) ||
                selectedStartDatePopup == null
            ? DateTime(2000)
            : selectedStartDatePopup!, //  startDateRes, //DateTime(2000),
        lastDate: endDateRes, //DateTime(2101),
      );
      if (picked != null && picked != selectedEndDatePopup) {
        selectedEndDatePopup = picked;
        endDateControlerPopup.text = DateFormat('dd/MM/yyyy').format(picked);
      }
    }

    Future<void> selectStartDatePopUp({
      required BuildContext context,
      required DateTime startDateRes,
      required DateTime endDateRes,
    }) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: startDateRes, //DateTime(2000),
        lastDate: selectedEndDatePopup == DateTime(2101) ||
                selectedEndDatePopup == null
            ? DateTime(2101)
            : selectedEndDatePopup!, //DateTime(2101),
      );
      if (picked != null && picked != selectedStartDatePopup) {
        selectedStartDatePopup = picked;
        startDateControlerPopup.text = DateFormat('dd/MM/yyyy').format(picked);
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            ref.read(fetchApiProvider).treeController.collapseAll();
            ref.read(fetchApiProvider).arrWidget.clear();
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          InkWell(
            // onTap: () {
            //   // Implement download functionality here
            //   downloadPms(
            //       projectPmsId: ref
            //               .read(fetchApiProvider)
            //               .projectPmsInfoResponse?[0]
            //               .mstProjectPmsId ??
            //           '');
            // },

            onTap: () async {
              //shareFile(widget.fileName);
              //Save single pdf file
              // _launchURL();
              final uri = Uri.parse(
                  '${AppUrl.baseURL}/ws-project-cms-excel-download?id=${ref.read(fetchApiProvider).projectPmsInfoResponse?[0].mstProjectPmsId ?? ''}');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                throw 'Could not launch';
              }
            },
            child: Icon(Icons.download, color: Colors.white),
            //  Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(10),
            //     border: Border.all(color: Colors.white),
            //   ),
            //   child: const Text(
            //     "Download",
            //     style: TextStyle(
            //       color: Colors.white,
            //       fontSize: 16,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
          ),
          SizedBox(width: 20),
          if (!widget.isSetupDone)
            InkWell(
              onTap: () {
                getProjectPms(
                    projectId: widget.projectId, towarId: widget.towarId);
                setState(() {
                  selectedTemplate = ProjectDefaultLsit(
                      selectedFlag: "1",
                      projectPmsName: ref
                          .read(fetchApiProvider)
                          .projectPmsInfoResponse?[0]
                          .projectPmsName,
                      mstProjectPmsId: ref
                          .read(fetchApiProvider)
                          .projectPmsInfoResponse?[0]
                          .mstProjectPmsId);
                  widget.isSetupDone = true;
                  isCancle = true;
                  if (ref.read(fetchApiProvider).pmsStartDateFromResponse !=
                      null) {
                    selectedStartDatePopup =
                        ref.read(fetchApiProvider).pmsStartDateFromResponse;
                    startDateControlerPopup.text = DateFormat('dd/MM/yyyy')
                        .format(ref
                            .read(fetchApiProvider)
                            .pmsStartDateFromResponse!);
                  }

                  if (ref.read(fetchApiProvider).pmsEndDateFromResponse !=
                      null) {
                    selectedEndDatePopup =
                        ref.read(fetchApiProvider).pmsEndDateFromResponse;
                    endDateControlerPopup.text = DateFormat('dd/MM/yyyy')
                        .format(
                            ref.read(fetchApiProvider).pmsEndDateFromResponse!);
                  }
                  templateNameControler.text = ref
                          .read(fetchApiProvider)
                          .projectPmsInfoResponse?[0]
                          .projectPmsName ??
                      '';
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white),
                ),
                child: const Text(
                  "Change Template",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    ref.read(fetchApiProvider).arrWidget.clear();
                    ref.read(homeProvider).setIsSelectedFilterView('DAYS');
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      color:
                          ref.watch(homeProvider).isSelectedFilterView == "DAYS"
                              ? Colors.white
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: ref.watch(homeProvider).isSelectedFilterView ==
                                  "DAYS"
                              ? Colors.white
                              : Colors.transparent),
                    ),
                    child: Text(
                      "Days",
                      style: TextStyle(
                        fontSize: 15,
                        color: ref.watch(homeProvider).isSelectedFilterView ==
                                "DAYS"
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    ref.read(fetchApiProvider).arrWidget.clear();
                    ref.read(homeProvider).setIsSelectedFilterView('WEEK');
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      color:
                          ref.watch(homeProvider).isSelectedFilterView == "WEEK"
                              ? Colors.white
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: ref.watch(homeProvider).isSelectedFilterView ==
                                  "WEEK"
                              ? Colors.white
                              : Colors.transparent),
                    ),
                    child: Text(
                      "Week",
                      style: TextStyle(
                        fontSize: 15,
                        color: ref.watch(homeProvider).isSelectedFilterView ==
                                "WEEK"
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    ref.read(fetchApiProvider).arrWidget.clear();
                    ref.read(homeProvider).setIsSelectedFilterView('MONTH');
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      color: ref.watch(homeProvider).isSelectedFilterView ==
                              "MONTH"
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      // border: Border.all(color: Colors.black),
                      border: Border.all(
                          color: ref.watch(homeProvider).isSelectedFilterView ==
                                  "MONTH"
                              ? Colors.white
                              : Colors.transparent),
                    ),
                    child: Text(
                      "Month",
                      style: TextStyle(
                        fontSize: 15,
                        color: ref.watch(homeProvider).isSelectedFilterView ==
                                "MONTH"
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    ref.read(fetchApiProvider).arrWidget.clear();
                    ref.read(homeProvider).setIsSelectedFilterView('YEAR');
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      color:
                          ref.watch(homeProvider).isSelectedFilterView == "YEAR"
                              ? Colors.white
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      // border: Border.all(color: Colors.black),
                      border: Border.all(
                          color: ref.watch(homeProvider).isSelectedFilterView ==
                                  "YEAR"
                              ? Colors.white
                              : Colors.transparent),
                    ),
                    child: Text(
                      "Year",
                      style: TextStyle(
                        fontSize: 15,
                        color: ref.watch(homeProvider).isSelectedFilterView ==
                                "YEAR"
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
        title: Text(
          'SCHEDULE MANAGEMENT (${widget.towarName!.isNotEmpty ? '${widget.projectName.toUpperCase()} - ${widget.towarName!.toUpperCase()}' : widget.projectName.toUpperCase()})',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        notificationPredicate: (_) => false,
        titleSpacing: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: widget.isSetupDone
          ? Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 130),
                width: 800,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _keyFormPOPup,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        Text(
                          isCancle ? "Change Template" : "Create New Template",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // SizedBox(width: 50),
                            const SizedBox(
                              width: 200,
                              child: Text(
                                'Project Name :',
                                textAlign: TextAlign.end,
                              ),
                            ),
                            const SizedBox(width: 50),
                            SizedBox(
                              width: 500,
                              child: TextFormField(
                                enabled: false,
                                readOnly: true,
                                controller: projectNameControler,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 13.0),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(12.0),
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  hintText: 'Enter Project Name',
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 116, 116, 116),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'HelveticaNeue',
                                  ),
                                  // suffixIcon: Icon(
                                  //   Icons.keyboard_arrow_down_outlined,
                                  // ),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 14),

                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: 200,
                              child: Text(
                                'Project Start Date :',
                                textAlign: TextAlign.end,
                              ),
                            ),
                            const SizedBox(width: 50),
                            GestureDetector(
                              onTap: () {
                                selectStartDatePopUp(
                                  context: context,
                                  startDateRes: DateTime(2000),
                                  endDateRes: DateTime(2101),
                                );
                              },
                              child: SizedBox(
                                width: 180,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "(Start Date Cannot Be Empty)";
                                    }
                                  },
                                  enabled: false,
                                  readOnly: true,
                                  controller: startDateControlerPopup,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 13.0),
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.all(12.0),
                                      border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black)),
                                      hintText: 'Select Project Start Date',
                                      hintStyle: TextStyle(
                                        color:
                                            Color.fromARGB(255, 116, 116, 116),
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
                            const SizedBox(width: 36),
                            const SizedBox(
                              width: 100,
                              child: Text(
                                'Project End Date :',
                                textAlign: TextAlign.end,
                              ),
                            ),
                            // SizedBox(width: 50),
                            GestureDetector(
                              onTap: () {
                                selectEndDatePopUp(
                                  context: context,
                                  startDateRes: DateTime(2000),
                                  endDateRes: DateTime(2101),
                                );
                              },
                              child: SizedBox(
                                width: 180,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "(End Date Cannot Be Empty)";
                                    }
                                  },
                                  enabled: false,
                                  readOnly: true,
                                  controller: endDateControlerPopup,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 13.0),
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.all(12.0),
                                      border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black)),
                                      hintText: 'Select Project End Date',
                                      hintStyle: TextStyle(
                                        color:
                                            Color.fromARGB(255, 116, 116, 116),
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w200,
                                        fontFamily: 'HelveticaNeue',
                                      ),
                                      suffixIcon: Icon(
                                        Icons.calendar_month_outlined,
                                      )),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: 200,
                              child: Text(
                                'Reminder (Start Date) :',
                                textAlign: TextAlign.end,
                              ),
                            ),
                            const SizedBox(width: 50),
                            SizedBox(
                              width: 146,
                              child: TextFormField(
                                // validator: (value) {
                                //   if (value!.isEmpty) {
                                //     return "(Start Date Cannot Be Empty)";
                                //   }
                                // },

                                controller: notifyStartDateControler,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 13.0),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(12.0),
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  hintText: 'Enter Start Date',
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 116, 116, 116),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'HelveticaNeue',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Days',
                              textAlign: TextAlign.end,
                            ),
                            const SizedBox(width: 10),
                            const SizedBox(
                              width: 130,
                              child: Text(
                                'Reminder (End Date) :',
                                textAlign: TextAlign.end,
                              ),
                            ),
                            // const SizedBox(width: 50),
                            SizedBox(
                              width: 146,
                              child: TextFormField(
                                // validator: (value) {
                                //   if (value!.isEmpty) {
                                //     return "(Start Date Cannot Be Empty)";
                                //   }
                                // },

                                controller: notifyEndDateControler,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 13.0),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(12.0),
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  hintText: 'Enter End Date',
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 116, 116, 116),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'HelveticaNeue',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Days',
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Row(
                        //   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Container(
                        //       width: 200,
                        //       child: Text(
                        //         'Project End Date :',
                        //         textAlign: TextAlign.end,
                        //       ),
                        //     ),
                        //     SizedBox(width: 50),
                        //     GestureDetector(
                        //       onTap: () {
                        //         selectEndDatePopUp(
                        //           context: context,
                        //           startDateRes: DateTime(2000),
                        //           endDateRes: DateTime(2101),
                        //         );
                        //       },
                        //       child: Container(
                        //         width: 500,
                        //         child: TextFormField(
                        //           enabled: false,
                        //           readOnly: true,
                        //           controller: endDateControlerPopup,
                        //           style: const TextStyle(
                        //               color: Colors.black, fontSize: 13.0),
                        //           decoration: const InputDecoration(
                        //               contentPadding: EdgeInsets.all(12.0),
                        //               border: OutlineInputBorder(
                        //                   borderSide:
                        //                       BorderSide(color: Colors.black)),
                        //               hintText: 'Select Project End Date',
                        //               hintStyle: TextStyle(
                        //                 color: Color.fromARGB(255, 116, 116, 116),
                        //                 fontSize: 13.0,
                        //                 fontWeight: FontWeight.w200,
                        //                 fontFamily: 'HelveticaNeue',
                        //               ),
                        //               suffixIcon: Icon(
                        //                 Icons.calendar_month_outlined,
                        //               )),
                        //         ),
                        //       ),
                        //     )
                        //   ],
                        // ),
                        // SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 200,
                              child: Text(
                                'Select Template :',
                                textAlign: TextAlign.end,
                              ),
                            ),
                            const SizedBox(width: 50),
                            SizedBox(
                                width: 500,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (projectDefaultLsitResponse != null &&
                                        projectDefaultLsitResponse!.length != 0)
                                      Container(
                                        // padding: EdgeInsets.only(top: 6),
                                        // width: double.maxFinite,
                                        // decoration: BoxDecoration(
                                        //     border: Border(
                                        //         top: BorderSide(
                                        //             color: Colors.grey))),
                                        margin:
                                            const EdgeInsets.only(right: 30),
                                        padding: const EdgeInsets.only(left: 8),
                                        width: double.maxFinite,
                                        decoration: const BoxDecoration(
                                          color: Colors.black12,
                                        ),
                                        child: const Text("Stallion Template",
                                            style: TextStyle(
                                              color: Colors.black,
                                            )),
                                      ),
                                    if (projectDefaultLsitResponse != null)
                                      for (int h = 0;
                                          h <
                                              projectDefaultLsitResponse!
                                                  .length;
                                          h++)
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedTemplate =
                                                  projectDefaultLsitResponse?[
                                                      h];
                                              templateNameControler.text = "";
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                                right: 30),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: (projectDefaultLsitResponse?[
                                                                      h]
                                                                  .selectedFlag ==
                                                              '1')
                                                          ? Colors.black12
                                                          : Colors.transparent),
                                                  child: SizedBox(
                                                    width: 440,
                                                    // child: Text(
                                                    //     style: const TextStyle(
                                                    //         overflow: TextOverflow
                                                    //             .ellipsis),
                                                    //     '${h + 1}. ${projectDefaultLsitResponse?[h].projectPmsName} ${projectDefaultLsitResponse?[h].projectPmsDecs}'),

                                                    child: RichText(
                                                      text: TextSpan(
                                                        text: '${h + 1}. ',
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                        // style:
                                                        //     DefaultTextStyle.of(
                                                        //             context)
                                                        //         .style,
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                              text: projectDefaultLsitResponse?[
                                                                      h]
                                                                  .projectPmsName,
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                              )),
                                                          TextSpan(
                                                              text:
                                                                  ' ${projectDefaultLsitResponse?[h].projectPmsDecs}',
                                                              style:
                                                                  const TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Spacer(),
                                                ((selectedTemplate?.mstProjectPmsId ==
                                                                null &&
                                                            projectDefaultLsitResponse?[
                                                                        h]
                                                                    .selectedFlag ==
                                                                '1') ||
                                                        selectedTemplate
                                                                ?.mstProjectPmsId ==
                                                            projectDefaultLsitResponse?[
                                                                    h]
                                                                .mstProjectPmsId)
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
                                          ),
                                        ),
                                    if (projectDefaultLsitResponse != null &&
                                        projectDefaultLsitResponse!.length != 0)
                                      const SizedBox(
                                        height: 8,
                                      ),
                                    if (projectPmsDetailsResponse != null &&
                                        projectPmsDetailsResponse!.length != 0)
                                      Container(
                                        margin:
                                            const EdgeInsets.only(right: 30),
                                        padding: const EdgeInsets.only(left: 8),
                                        width: double.maxFinite,
                                        decoration: const BoxDecoration(
                                          color: Colors.black12,
                                        ),
                                        child: const Text(
                                          "Your's Saved Template",
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    if (projectPmsDetailsResponse != null)
                                      for (int k = 0;
                                          k < projectPmsDetailsResponse!.length;
                                          k++)
                                        GestureDetector(
                                          onTap: () {
                                            if (projectPmsDetailsResponse?[k]
                                                    .selectedFlag !=
                                                '1') {
                                              setState(() {
                                                selectedTemplate =
                                                    projectPmsDetailsResponse?[
                                                        k];
                                                // templateNameControler.clear();
                                                templateNameControler.text =
                                                    projectPmsDetailsResponse?[
                                                                k]
                                                            .projectPmsName ??
                                                        '';
                                              });
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              Text(
                                                '${k + 1}. ${projectPmsDetailsResponse?[k].projectPmsName}',
                                                style: TextStyle(
                                                    color: projectPmsDetailsResponse?[
                                                                    k]
                                                                .selectedFlag !=
                                                            '1'
                                                        ? Colors.black
                                                        : Colors.black45),
                                              ),
                                              const Spacer(),
                                              ((selectedTemplate?.mstProjectPmsId ==
                                                              null &&
                                                          projectPmsDetailsResponse?[
                                                                      k]
                                                                  .selectedFlag ==
                                                              '1') ||
                                                      selectedTemplate
                                                              ?.mstProjectPmsId ==
                                                          projectPmsDetailsResponse?[
                                                                  k]
                                                              .mstProjectPmsId)
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
                                                    ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              projectPmsDetailsResponse?[k]
                                                          .deleteFlag ==
                                                      "1"
                                                  ? InkWell(
                                                      onTap: () {
                                                        showDialog<void>(
                                                            barrierDismissible:
                                                                true,
                                                            context: context,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8), // Set radius to zero
                                                                ),
                                                                titlePadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            20),
                                                                actionsPadding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10,
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10),
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            16),
                                                                actionsAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                title:
                                                                    const Text(
                                                                  "You are about to Delete the Template.\nThis change will impact on your scheduling for the current project if you have made any.\nDo you still want to proceed and Delete the Template?",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                                actions: [
                                                                  InkWell(
                                                                    onTap: () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          250,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              4),
                                                                      decoration: BoxDecoration(
                                                                          color: Colors
                                                                              .black,
                                                                          borderRadius:
                                                                              BorderRadius.circular(7)),
                                                                      child:
                                                                          const Text(
                                                                        "No",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      deleteProjectPms(
                                                                          projectPmsId:
                                                                              projectPmsDetailsResponse?[k].mstProjectPmsId ?? '');
                                                                      // getProjectPms(
                                                                      //     projectId:
                                                                      //         widget.projectId,
                                                                      //     towarId: widget.towarId);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          250,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              4),
                                                                      decoration: BoxDecoration(
                                                                          color: Colors
                                                                              .black,
                                                                          borderRadius:
                                                                              BorderRadius.circular(7)),
                                                                      child:
                                                                          const Text(
                                                                        'Yes',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            });
                                                      },
                                                      child: const Icon(
                                                        Icons.delete_outline,
                                                        color: Colors.red,
                                                      ),
                                                    )
                                                  : const SizedBox(
                                                      width: 24,
                                                    ),
                                            ],
                                          ),
                                        ),
                                  ],
                                ))
                          ],
                        ),
                        if (isValidateingTemplatye && selectedTemplate == null)
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 200,
                                ),
                                const SizedBox(width: 50),
                                const SizedBox(
                                  width: 500,
                                  child: Text(
                                    "(Please Select Template)",
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 12),
                                  ),
                                )
                              ]),

                        const SizedBox(height: 14),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // SizedBox(width: 50),
                            const SizedBox(
                              width: 200,
                              child: Text(
                                'Template Name :',
                                textAlign: TextAlign.end,
                              ),
                            ),
                            const SizedBox(width: 50),
                            SizedBox(
                              width: 500,
                              child: TextFormField(
                                validator: (value) {
                                  if (selectedTemplate?.selectedFlag != '1') {
                                    if (value!.isEmpty) {
                                      return "(Template Name Cannot Be Empty)";
                                    } else {
                                      for (int h = 0;
                                          h <
                                              projectDefaultLsitResponse!
                                                  .length;
                                          h++) {
                                        if (value.trim().toLowerCase() ==
                                            projectDefaultLsitResponse?[h]
                                                .projectPmsName
                                                ?.trim()
                                                .toLowerCase()) {
                                          return "Please write unique name";
                                        }
                                      }

                                      // if (projectPmsDetailsResponse != null)
                                      //   for (int k = 0;
                                      //       k <
                                      //           projectPmsDetailsResponse!
                                      //               .length;
                                      //       k++) {
                                      //     if (projectPmsDetailsResponse?[k]
                                      //             .projectPmsName ==
                                      //         value) {
                                      //       return "Please write unique name";
                                      //     }
                                      //   }
                                    }
                                  }
                                },
                                // enabled: false,
                                // readOnly: true,
                                controller: templateNameControler,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 13.0),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(12.0),
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  hintText: 'Enter Template Name',
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 116, 116, 116),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'HelveticaNeue',
                                  ),
                                  // suffixIcon: Icon(
                                  //   Icons.keyboard_arrow_down_outlined,
                                  // ),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 250,
                            ),
                            if (isCancle)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    widget.isSetupDone = false;
                                  });
                                  // if (_keyFormPOPup.currentState!.validate() &&
                                  //     selectedTemplate != null) {
                                  //   print(endDateControlerPopup.text);
                                  //   setProjectPms(
                                  //       projectId: widget.projectId,
                                  //       towarId: widget.towarId);
                                  // } else {
                                  //   setState(() {
                                  //     isValidateingTemplatye = true;
                                  //   });
                                  // }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            if (selectedTemplate?.deleteFlag != null)
                              GestureDetector(
                                onTap: () {
                                  // setState(() {
                                  //   widget.isSetupDone = false;
                                  // });
                                  // if (_keyFormPOPup.currentState!.validate() &&
                                  //     selectedTemplate != null) {
                                  //   print(endDateControlerPopup.text);
                                  //   setProjectPms(
                                  //       projectId: widget.projectId,
                                  //       towarId: widget.towarId);
                                  // } else {
                                  //   setState(() {
                                  //     isValidateingTemplatye = true;
                                  //   });
                                  // }
                                  if (_keyFormPOPup.currentState!.validate() &&
                                      selectedTemplate != null) {
                                    showDialog<void>(
                                        barrierDismissible: true,
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      8), // Set radius to zero
                                            ),
                                            titlePadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 20),
                                            actionsPadding:
                                                const EdgeInsets.only(
                                                    bottom: 10,
                                                    left: 10,
                                                    right: 10),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16),
                                            actionsAlignment:
                                                MainAxisAlignment.center,
                                            title: const Text(
                                              "Are you sure, you want to shift to another saved Template?",
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
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 4),
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7)),
                                                  child: const Text(
                                                    "No",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  setProjectPms(
                                                      default_flag: "1",
                                                      projectId:
                                                          widget.projectId,
                                                      towarId: widget.towarId);
                                                  // setState(() {
                                                  //   widget.isSetupDone = false;
                                                  // });
                                                  Navigator.of(context).pop();
                                                  // getProjectPms(
                                                  //     projectId:
                                                  //         widget.projectId,
                                                  //     towarId: widget.towarId);
                                                },
                                                child: Container(
                                                  width: 250,
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 4),
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7)),
                                                  child: const Text(
                                                    'Yes',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        });
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    "Switch Template",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            InkWell(
                              onTap: () {
                                if (_keyFormPOPup.currentState!.validate() &&
                                    selectedTemplate != null) {
                                  // print(
                                  //     '${endDateControlerPopup.text} ---- ${selectedTemplate?.selectedFlag} ==== ${selectedTemplate?.projectPmsName}');
                                  if (selectedTemplate?.selectedFlag == "1") {
                                    // Navigator.of(context).pop();
                                    setProjectPms(
                                        default_flag:
                                            selectedTemplate?.selectedFlag ??
                                                "0",
                                        projectId: widget.projectId,
                                        towarId: widget.towarId);
                                    setState(() {
                                      widget.isSetupDone = false;
                                    });
                                  } else {
                                    // setProjectPms(
                                    //     projectId: widget.projectId,
                                    //     towarId: widget.towarId);
                                    if (isCancle) {
                                      showDialog<void>(
                                          barrierDismissible: true,
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8), // Set radius to zero
                                              ),
                                              titlePadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 20),
                                              actionsPadding:
                                                  const EdgeInsets.only(
                                                      bottom: 10),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              actionsAlignment:
                                                  MainAxisAlignment.center,
                                              title: const Text(
                                                "You are shifting to a New Template. \nOnce confirmed, you can't go back to your Old Template with necessary changes.\nAre you Sure?",
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
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 4),
                                                    decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(7)),
                                                    child: const Text(
                                                      "No",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    setProjectPms(
                                                        default_flag:
                                                            selectedTemplate
                                                                    ?.selectedFlag ??
                                                                "0",
                                                        projectId:
                                                            widget.projectId,
                                                        towarId:
                                                            widget.towarId);
                                                    Navigator.of(context).pop();
                                                    // getProjectPms(
                                                    //     projectId:
                                                    //         widget.projectId,
                                                    //     towarId: widget.towarId);
                                                  },
                                                  child: Container(
                                                    width: 250,
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 4),
                                                    decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(7)),
                                                    child: const Text(
                                                      'Yes',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          });
                                    } else {
                                      setProjectPms(
                                          projectId: widget.projectId,
                                          towarId: widget.towarId,
                                          default_flag:
                                              selectedTemplate?.selectedFlag ??
                                                  "0");
                                    }
                                  }
                                } else {
                                  setState(() {
                                    isValidateingTemplatye = true;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isCancle
                                      ? "Create New Schedule"
                                      : "Create Schedule Management",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : ExamplesView(
              projectId: widget.projectId,
              towarId: widget.towarId,
              projectName: widget.projectName,
              towarName: widget.towarName ?? '',
            ),
      onEndDrawerChanged: (isOpened) {
        setState(() {
          isValidateForDates = false;
          isValidateForDatesString = '';
        });
      },
      endDrawerEnableOpenDragGesture:
          false, // Disable swipe gesture to open the drawer
      endDrawer: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Drawer(
              // This is the right drawer
              width: 524,
              child: SingleChildScrollView(
                child: Form(
                  key: _key,
                  // padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    children: <Widget>[
                      Container(
                        padding:
                            const EdgeInsets.fromLTRB(10.0, 16.0, 16.0, 8.0),
                        color: Colors.black,
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              ref.watch(homeProvider).drawerTitle ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      /*if (ref.watch(homeProvider).dictDrawerData?.parent_start_date !=
                          null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
                          child: Text(
                            '*Date cannot exceed more than ${DateFormat('dd/MM/yyyy').format(ref.watch(homeProvider).dictDrawerData?.parent_end_date ?? DateTime.now())} for ${ref.watch(homeProvider).drawerTitle}*',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),*/

                      Container(
                        height: 300,
                        margin: const EdgeInsetsDirectional.symmetric(
                            horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color.fromARGB(255, 175, 175, 175)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // SizedBox(
                            //   height: 10,
                            // ),
                            Container(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 6),
                              decoration: const BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 150,
                                    padding: const EdgeInsets.fromLTRB(
                                        16.0, 0.0, 16.0, 0.0),
                                    child: const Text(
                                      'Title',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 65,
                                    padding: const EdgeInsets.fromLTRB(
                                        10.0, 0.0, 10.0, 0.0),
                                    child: const Text(
                                      'Days',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 130,
                                    padding: const EdgeInsets.fromLTRB(
                                        10.0, 0.0, 10.0, 0.0),
                                    child: const Text(
                                      'Start Date',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 130,
                                    padding: const EdgeInsets.fromLTRB(
                                        10.0, 0.0, 10.0, 0.0),
                                    child: const Text(
                                      'End Date',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: ref
                                      .watch(fetchApiProvider)
                                      .pmsStructureForDuplicating
                                      ?.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    // setState(() {
                                    isValidateStartEndLoop = false;
                                    // });
                                    // DupliacateDataPms dictPms = ref.watch(fetchApiProvider).pmsStructureForDuplicating![index];
                                    TextEditingController controllerTitle =
                                        TextEditingController();
                                    TextEditingController controller =
                                        TextEditingController();
                                    TextEditingController controllerEnd =
                                        TextEditingController();
                                    TextEditingController controllerStart =
                                        TextEditingController();
                                    controllerTitle.text = ref
                                            .read(fetchApiProvider)
                                            .pmsStructureForDuplicating![index]
                                            .pmsCategoryName ??
                                        '';
                                    if (ref
                                                .read(fetchApiProvider)
                                                .pmsStructureForDuplicating![
                                                    index]
                                                .pmsEndDate !=
                                            DateTime(2101) &&
                                        ref
                                                .read(fetchApiProvider)
                                                .pmsStructureForDuplicating![
                                                    index]
                                                .pmsEndDate !=
                                            null) {
                                      controllerEnd.text =
                                          DateFormat('dd/MM/yyyy').format(ref
                                              .read(fetchApiProvider)
                                              .pmsStructureForDuplicating![
                                                  index]
                                              .pmsEndDate!);
                                    }

                                    if (ref
                                                .read(fetchApiProvider)
                                                .pmsStructureForDuplicating![
                                                    index]
                                                .pmsStartDate !=
                                            DateTime(2000) &&
                                        ref
                                                .read(fetchApiProvider)
                                                .pmsStructureForDuplicating![
                                                    index]
                                                .pmsStartDate !=
                                            null) {
                                      controllerStart.text =
                                          DateFormat('dd/MM/yyyy').format(ref
                                                  .read(fetchApiProvider)
                                                  .pmsStructureForDuplicating![
                                                      index]
                                                  .pmsStartDate ??
                                              DateTime.now());
                                    }
                                    if (ref
                                                .read(fetchApiProvider)
                                                .pmsStructureForDuplicating![
                                                    index]
                                                .pmsStartDate !=
                                            null &&
                                        ref
                                                .read(fetchApiProvider)
                                                .pmsStructureForDuplicating![
                                                    index]
                                                .pmsEndDate !=
                                            null &&
                                        ref
                                                .read(fetchApiProvider)
                                                .pmsStructureForDuplicating![
                                                    index]
                                                .pmsEndDate !=
                                            DateTime(2101) &&
                                        ref
                                                .read(fetchApiProvider)
                                                .pmsStructureForDuplicating![
                                                    index]
                                                .pmsStartDate !=
                                            DateTime(2000)) {
                                      // print(
                                      //     '${ref.read(fetchApiProvider).pmsStructureForDuplicating![index].pmsEndDate} ${ref.read(fetchApiProvider).pmsStructureForDuplicating![index].pmsStartDate} ===+++++++++');
                                      controller.text = ref
                                          .read(fetchApiProvider)
                                          .pmsStructureForDuplicating![index]
                                          .pmsEndDate!
                                          .difference(ref
                                              .read(fetchApiProvider)
                                              .pmsStructureForDuplicating![
                                                  index]
                                              .pmsStartDate!)
                                          .inDays
                                          .toString();
                                    } else {
                                      controller.text = ref
                                          .read(fetchApiProvider)
                                          .pmsStructureForDuplicating![index]
                                          .totalDays!;
                                    }
                                    //  ref
                                    //     .read(fetchApiProvider)
                                    //     .pmsStructureForDuplicating![index]
                                    //     .totalDays!;

                                    Color validateStartdate(
                                        DupliacateDataPms data) {
                                      // print(
                                      //     '${data.pmsEndDate}  ${data.pmsStartDate} ${data.pmsCategoryName}------------ new');
                                      if (data.pmsStartDate == null &&
                                          data.pmsEndDate != null &&
                                          data.pmsEndDate != DateTime(2101)) {
                                        // print(
                                        //     '${data.pmsEndDate}  ${data.pmsStartDate} ${data.pmsCategoryName}------------');
                                        return Colors.red;
                                      }
                                      // else if (data.pmsStartDate != null &&
                                      //     data.pmsEndDate == DateTime(2101)) {
                                      //   return Colors.red;
                                      // }
                                      else {
                                        return Colors.black45;
                                      }
                                    }

                                    Color validateEnddate(
                                        DupliacateDataPms data) {
                                      // print(
                                      //     '${data.pmsEndDate}  ${data.pmsStartDate} ${data.pmsCategoryName}------------[-0-]');
                                      // if (data.pmsEndDate == null &&
                                      //     data.pmsStartDate != null &&
                                      //     data.pmsEndDate != DateTime(2101) &&
                                      //     data.pmsStartDate != DateTime(2000)) {
                                      //   return Colors.red;
                                      // } else {
                                      //   return Colors.black45;
                                      // }

                                      if (data.pmsEndDate == null &&
                                          data.pmsStartDate != null) {
                                        return Colors.red;
                                      } else if (data.pmsStartDate != null &&
                                          data.pmsStartDate != DateTime(2000) &&
                                          data.pmsEndDate == DateTime(2101)) {
                                        return Colors.red;
                                      } else {
                                        return Colors.black45;
                                      }
                                    }

                                    // if ((ref
                                    //                 .read(fetchApiProvider)
                                    //                 .pmsStructureForDuplicating![
                                    //                     index]
                                    //                 .pmsEndDate ==
                                    //             null &&
                                    //         ref
                                    //                 .read(fetchApiProvider)
                                    //                 .pmsStructureForDuplicating![
                                    //                     index]
                                    //                 .pmsStartDate !=
                                    //             null &&
                                    //         ref
                                    //                 .read(fetchApiProvider)
                                    //                 .pmsStructureForDuplicating![
                                    //                     index]
                                    //                 .pmsEndDate !=
                                    //             DateTime(2101) &&
                                    //         ref
                                    //                 .read(fetchApiProvider)
                                    //                 .pmsStructureForDuplicating![
                                    //                     index]
                                    //                 .pmsStartDate !=
                                    //             DateTime(2000)) ||
                                    //     (ref
                                    //                 .read(fetchApiProvider)
                                    //                 .pmsStructureForDuplicating![
                                    //                     index]
                                    //                 .pmsStartDate ==
                                    //             null &&
                                    //         ref
                                    //                 .read(fetchApiProvider)
                                    //                 .pmsStructureForDuplicating![
                                    //                     index]
                                    //                 .pmsEndDate !=
                                    //             null &&
                                    //         ref
                                    //                 .read(fetchApiProvider)
                                    //                 .pmsStructureForDuplicating![
                                    //                     index]
                                    //                 .pmsEndDate !=
                                    //             DateTime(2101))) {
                                    //   // setState(() {
                                    //   isValidateStartEndLoop = true;
                                    //   // });
                                    // }
                                    return SizedBox(
                                      // height: 50,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 14,
                                              width: 14,
                                              decoration: BoxDecoration(
                                                  color: Color(int.parse(
                                                          '0xFF${(ref.read(fetchApiProvider).pmsStructureForDuplicating![index].pms_color_code)?.replaceAll(RegExp('[^A-Za-z0-9]'), '')}'))
                                                      .withOpacity(0.8),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  border: Border.all(
                                                      color: Colors.black45)),
                                            ),
                                            const SizedBox(
                                              width: 6,
                                            ),
                                            SizedBox(
                                              width: 140,
                                              // child: Text(ref
                                              //     .watch(fetchApiProvider)
                                              //     .pmsStructureForDuplicating![index]
                                              //     .pmsCategoryName!),
                                              child: TextFormField(
                                                minLines: 1,
                                                maxLines:
                                                    4, // grows until 4 lines, then scrolls

                                                // minLines: 1, // starts at 1 line
                                                // maxLines:
                                                //     null, // <-- unlimited lines (wraps & grows)
                                                textAlign: TextAlign
                                                    .start, // or keep center if you prefer
                                                keyboardType:
                                                    TextInputType.multiline,
                                                textInputAction:
                                                    TextInputAction.newline,

                                                // readOnly: true,
                                                // enabled: true,
                                                // inputFormatters: [
                                                //   FilteringTextInputFormatter
                                                //       .digitsOnly,
                                                // ],
                                                onChanged: (value) {
                                                  ref
                                                      .read(fetchApiProvider)
                                                      .pmsStructureForDuplicating![
                                                          index]
                                                      .pmsCategoryName = value;
                                                  // controllerEnd.text = DateFormat(
                                                  //         'dd/MM/yyyy')
                                                  //     .format(ref
                                                  //         .watch(fetchApiProvider)
                                                  //         .pmsStructureForDuplicating![
                                                  //             index]
                                                  //         .pmsStartDate!
                                                  //         .add(Duration(
                                                  //             days:
                                                  //                 (int.parse(value)))));
                                                },
                                                controller: controllerTitle,
                                                textAlignVertical:
                                                    TextAlignVertical.center,
                                                // textAlign: TextAlign.center,
                                                // maxLines: 1,
                                                style: const TextStyle(
                                                    fontSize: 13),
                                                decoration: const InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10.0,
                                                            vertical: 0),
                                                    hintText: "Title",
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    7.0)))),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            SizedBox(
                                              // height: 40,
                                              width: 60,
                                              child: TextFormField(
                                                // readOnly: ref
                                                //             .read(fetchApiProvider)
                                                //             .pmsStructureForDuplicating![
                                                //                 index]
                                                //             .totalDays ==
                                                //         "0"
                                                //     ? true
                                                //     : false,
                                                // enabled: true,

                                                // readOnly: true,
                                                // enabled: true,

                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],

                                                onChanged: (value) {
                                                  /// pranav testing starts here
                                                  ///
                                                  if (value != "" &&
                                                      index - 1 >= 0 &&
                                                      ref
                                                              .watch(
                                                                  fetchApiProvider)
                                                              .pmsStructureForDuplicating?[
                                                                  index - 1]
                                                              .pmsEndDate !=
                                                          null &&
                                                      ref
                                                              .watch(
                                                                  fetchApiProvider)
                                                              .pmsStructureForDuplicating?[
                                                                  index - 1]
                                                              .parentIdFk ==
                                                          ref
                                                              .watch(
                                                                  fetchApiProvider)
                                                              .pmsStructureForDuplicating?[
                                                                  index]
                                                              .parentIdFk &&
                                                      ref
                                                              .watch(
                                                                  fetchApiProvider)
                                                              .pmsStructureForDuplicating?[
                                                                  index]
                                                              .pmsStartDate ==
                                                          null) {
                                                    print("inside");
                                                    DateTime? prevEndDate = ref
                                                        .watch(fetchApiProvider)
                                                        .pmsStructureForDuplicating?[
                                                            index - 1]
                                                        .pmsEndDate!;
                                                    DateTime newStartDate =
                                                        prevEndDate!.add(
                                                            Duration(days: 1));
                                                    ref
                                                        .read(fetchApiProvider)
                                                        .pmsStructureForDuplicating![
                                                            index]
                                                        .pmsStartDate = newStartDate;
                                                    controllerStart.text =
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(
                                                                newStartDate);
                                                  }
                                                  // print(
                                                  //     'pranav testing starts here -- ${ref.watch(fetchApiProvider).pmsStructureForDuplicating?[index - 1].pmsCategoryName} index - 1=${ref.watch(fetchApiProvider).pmsStructureForDuplicating?[index - 1].parentIdFk} index=${ref.watch(fetchApiProvider).pmsStructureForDuplicating?[index].parentIdFk}');

                                                  ///
                                                  /// pranav ends here testing
                                                  if (int.parse(value) > 0) {
                                                    DateTime temp = ref
                                                        .watch(fetchApiProvider)
                                                        .pmsStructureForDuplicating![
                                                            index]
                                                        .pmsStartDate!
                                                        .add(Duration(
                                                            days: (int.parse(
                                                                    value) -
                                                                1)));
                                                    controllerEnd.text =
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(temp);
                                                    String previousDays = ref
                                                            .read(
                                                                fetchApiProvider)
                                                            .pmsStructureForDuplicating![
                                                                index]
                                                            .totalDaysTemp ??
                                                        '0';
                                                    String differenceDays = (int
                                                                .parse(value) -
                                                            int.parse(
                                                                previousDays))
                                                        .toString();

                                                    ref
                                                        .read(fetchApiProvider)
                                                        .pmsStructureForDuplicating![
                                                            index]
                                                        .totalDays = value;
                                                    ref
                                                        .read(fetchApiProvider)
                                                        .pmsStructureForDuplicating![
                                                            index]
                                                        .pmsEndDate = temp;

                                                    String parentIdd = ref
                                                            .read(
                                                                fetchApiProvider)
                                                            .pmsStructureForDuplicating![
                                                                index]
                                                            .parentIdFk ??
                                                        '';

                                                    updatedPmsListTemp = [];
                                                    String _formatDate(
                                                        DateTime date) {
                                                      return DateFormat(
                                                              'dd-MM-yyyy')
                                                          .format(date);
                                                    }

                                                    for (int y = 0;
                                                        y <
                                                            ref
                                                                .read(
                                                                    fetchApiProvider)
                                                                .pmsStructureForUpdateExistingDrawer!
                                                                .length;
                                                        y++) {
                                                      final item = ref
                                                          .read(
                                                              fetchApiProvider)
                                                          .pmsStructureForUpdateExistingDrawer![y];

                                                      // print(ref
                                                      //     .read(fetchApiProvider)
                                                      //     .pmsStructureForUpdateExistingDrawer![
                                                      //         y]
                                                      //     .pmsCategoryName);
                                                      if (differenceDays
                                                          .startsWith('-')) {
                                                        //decrease
                                                        break;
                                                      } else {
                                                        if (item.pmsStartDate !=
                                                                null &&
                                                            item.pmsStartDate!
                                                                    .year !=
                                                                2000) {
                                                          if (item.pmsEndDate !=
                                                                  null &&
                                                              item.pmsEndDate!
                                                                      .year !=
                                                                  2101) {
                                                            print(
                                                                '${DateTime(2101)} -- ${item.pmsEndDate}');
                                                            print(
                                                                'pmsStartDate${item.pmsStartDate} --- pmsEndDate ${item.pmsEndDate}');
                                                            //skip
                                                            final newEndDate = item
                                                                .pmsEndDate!
                                                                .add(Duration(
                                                                    days: int.parse(
                                                                        differenceDays)));

                                                            updatedPmsListTemp
                                                                .add({
                                                              "pmsId": item
                                                                  .mstPmsId
                                                                  .toString(),
                                                              "pmsCategoryName": item
                                                                  .pmsCategoryName
                                                                  .toString(),
                                                              "start_date":
                                                                  _formatDate(item
                                                                      .pmsStartDate!),
                                                              "end_date":
                                                                  _formatDate(
                                                                      newEndDate),
                                                            });
                                                          }
                                                        }
                                                      }
                                                    }

                                                    print(
                                                        'Updated PMS List: $updatedPmsListTemp');

                                                    for (int u = index;
                                                        u <
                                                            ref
                                                                .read(
                                                                    fetchApiProvider)
                                                                .pmsStructureForDuplicating!
                                                                .length;
                                                        u++) {
                                                      final item = ref
                                                          .read(
                                                              fetchApiProvider)
                                                          .pmsStructureForDuplicating?[u];

                                                      if (item?.parentIdFk ==
                                                          parentIdd) {
                                                        // print(
                                                        //     '''name == ${ref.read(fetchApiProvider).pmsStructureForDuplicating?[u].pmsCategoryName} differenceDays: $differenceDays}
                                                        //       pmsEndDatePrev: ${ref.read(fetchApiProvider).pmsStructureForDuplicating?[u].pmsEndDate} | pmsEndDateAfter ${ref.read(fetchApiProvider).pmsStructureForDuplicating?[u].pmsEndDate!.add(Duration(days: int.parse(differenceDays)))}
                                                        //       ''');
                                                        if (differenceDays
                                                            .startsWith('-')) {
                                                          //decrease
                                                          break;
                                                        } else {
                                                          //increase
                                                          if (ref
                                                                  .read(
                                                                      fetchApiProvider)
                                                                  .pmsStructureForDuplicating?[
                                                                      u]
                                                                  .mstPmsId !=
                                                              ref
                                                                  .read(
                                                                      fetchApiProvider)
                                                                  .pmsStructureForDuplicating?[
                                                                      index]
                                                                  .mstPmsId) {
                                                            print(
                                                                'name - ${item?.pmsCategoryName} parentIdd-${item?.parentIdFk} parentIdd-$parentIdd');

                                                            //skip self

                                                            // if (parentIdd ==
                                                            //     ref
                                                            //         .read(
                                                            //             fetchApiProvider)
                                                            //         .pmsStructureForDuplicating?[
                                                            //             u]
                                                            //         .parentIdFk) {
                                                            // ref
                                                            //         .read(
                                                            //             fetchApiProvider)
                                                            //         .pmsStructureForDuplicating?[
                                                            //             u]
                                                            //         .pmsStartDate =
                                                            //     ref
                                                            //         .read(
                                                            //             fetchApiProvider)
                                                            //         .pmsStructureForDuplicating?[
                                                            //             u]
                                                            //         .pmsStartDate!
                                                            //         .add(Duration(
                                                            //             days: int.parse(
                                                            //                 differenceDays)));
                                                            ref
                                                                    .read(
                                                                        fetchApiProvider)
                                                                    .pmsStructureForDuplicating?[
                                                                        u]
                                                                    .pmsEndDate =
                                                                ref
                                                                    .read(
                                                                        fetchApiProvider)
                                                                    .pmsStructureForDuplicating?[
                                                                        u]
                                                                    .pmsEndDate!
                                                                    .add(Duration(
                                                                        days: int.parse(
                                                                            differenceDays)));

                                                            ref.read(fetchApiProvider).pmsStructureForDuplicating?[u].totalDays = ref
                                                                .read(
                                                                    fetchApiProvider)
                                                                .pmsStructureForDuplicating![
                                                                    u]
                                                                .pmsEndDate!
                                                                .difference(ref
                                                                        .read(
                                                                            fetchApiProvider)
                                                                        .pmsStructureForDuplicating?[
                                                                            u]
                                                                        .pmsStartDate ??
                                                                    DateTime
                                                                        .now())
                                                                .inDays
                                                                .toString();
                                                            setState(() {
                                                              print('-');
                                                            });
                                                          }
                                                        }
                                                      }
                                                      //     else {
                                                      //       break;
                                                      // }
                                                    }
                                                    // for (int u = index;
                                                    //     u >= 0;
                                                    //     u--) {
                                                    //   print(
                                                    //       'name == ${ref.read(fetchApiProvider).pmsStructureForDuplicating?[u].pmsCategoryName}');
                                                    // }

                                                    // for (int k = index;
                                                    //     k >= 0;
                                                    //     k--) {
                                                    //   for (int l = k;
                                                    //       l >= 0;
                                                    //       l--) {
                                                    //     if (parentIdd ==
                                                    //         ref
                                                    //             .read(
                                                    //                 fetchApiProvider)
                                                    //             .pmsStructureForDuplicating?[
                                                    //                 l]
                                                    //             .mstPmsId) {
                                                    //       if (ref
                                                    //                   .read(
                                                    //                       fetchApiProvider)
                                                    //                   .pmsStructureForDuplicating?[
                                                    //                       l]
                                                    //                   .pmsEndDate ==
                                                    //               DateTime(
                                                    //                   2101) ||
                                                    //           ref
                                                    //                   .read(
                                                    //                       fetchApiProvider)
                                                    //                   .pmsStructureForDuplicating?[
                                                    //                       l]
                                                    //                   .pmsEndDate ==
                                                    //               null) {
                                                    //         // print(
                                                    //         //     '---Now ----${ref.read(fetchApiProvider).pmsStructureForDuplicating?[l].pmsCategoryName}');
                                                    //       } else {}
                                                    //       parentIdd = ref
                                                    //               .read(
                                                    //                   fetchApiProvider)
                                                    //               .pmsStructureForDuplicating?[
                                                    //                   l]
                                                    //               .parentIdFk ??
                                                    //           "";
                                                    //       Duration difference =
                                                    //           temp.difference(ref
                                                    //                   .read(
                                                    //                       fetchApiProvider)
                                                    //                   .pmsStructureForDuplicating?[
                                                    //                       l]
                                                    //                   .pmsEndDate ??
                                                    //               DateTime.now());

                                                    //       if (difference.inDays >
                                                    //           0) {
                                                    //         ref
                                                    //                 .read(
                                                    //                     fetchApiProvider)
                                                    //                 .pmsStructureForDuplicating?[
                                                    //                     l]
                                                    //                 .maxDate =
                                                    //             ref
                                                    //                 .read(
                                                    //                     fetchApiProvider)
                                                    //                 .pmsStructureForDuplicating?[
                                                    //                     l]
                                                    //                 .pmsEndDate!
                                                    //                 .add(Duration(
                                                    //                     days: difference
                                                    //                         .inDays));
                                                    //         ref
                                                    //                 .read(
                                                    //                     fetchApiProvider)
                                                    //                 .pmsStructureForDuplicating?[
                                                    //                     l]
                                                    //                 .pmsEndDate =
                                                    //             ref
                                                    //                 .read(
                                                    //                     fetchApiProvider)
                                                    //                 .pmsStructureForDuplicating?[
                                                    //                     l]
                                                    //                 .pmsEndDate!
                                                    //                 .add(Duration(
                                                    //                     days: difference
                                                    //                         .inDays));

                                                    //         ref
                                                    //                 .read(
                                                    //                     fetchApiProvider)
                                                    //                 .pmsStructureForDuplicating?[
                                                    //                     l]
                                                    //                 .totalDays =
                                                    //             ref
                                                    //                 .read(
                                                    //                     fetchApiProvider)
                                                    //                 .pmsStructureForDuplicating![
                                                    //                     l]
                                                    //                 .pmsEndDate!
                                                    //                 .difference(ref
                                                    //                         .read(
                                                    //                             fetchApiProvider)
                                                    //                         .pmsStructureForDuplicating?[
                                                    //                             l]
                                                    //                         .pmsStartDate ??
                                                    //                     DateTime
                                                    //                         .now())
                                                    //                 .inDays
                                                    //                 .toString();
                                                    //         setState(() {
                                                    //           isLoad = true;
                                                    //         });
                                                    //       }
                                                    //     }
                                                    //   }
                                                    // }
                                                  }
                                                },
                                                controller: controller,
                                                textAlignVertical:
                                                    TextAlignVertical.center,
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                    fontSize: 13),
                                                decoration: const InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    hintText: "Days",
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    7.0)))),
                                              ),
                                            ),
                                            SizedBox(
                                              // height: 40,
                                              width: 125,
                                              child: InkWell(
                                                onTap: () {
                                                  inspect(ref
                                                          .watch(fetchApiProvider)
                                                          .pmsStructureForDuplicating![
                                                      index]);

                                                  print(ref
                                                      .watch(fetchApiProvider)
                                                      .pmsStructureForDuplicating![
                                                          index]
                                                      .parentStartDate);
                                                  print(
                                                      'pmsCategoryName - ${ref.read(fetchApiProvider).pmsStructureForDuplicating![index].pmsCategoryName} parentStartDate-${ref.read(fetchApiProvider).pmsStructureForDuplicating![index].parentStartDate}');
                                                  ref
                                                      .read(homeProvider)
                                                      .selectStartDateDrawer(
                                                        context: context,
                                                        // startDateRes:
                                                        //     DateTime(2000),
                                                        startDateRes: ref
                                                                .read(
                                                                    fetchApiProvider)
                                                                .pmsStructureForDuplicating![
                                                                    index]
                                                                .parentStartDate ??
                                                            DateTime(
                                                                2000), // Use parent start date as minimum

                                                        endDateRes:
                                                            DateTime(2101),
                                                        control:
                                                            controllerStart,
                                                        controlday: controller,
                                                        endDateResponse: ref
                                                                .watch(
                                                                    fetchApiProvider)
                                                                .pmsStructureForDuplicating![
                                                                    index]
                                                                .pmsEndDate ??
                                                            DateTime.now(),
                                                        currData: ref
                                                            .watch(
                                                                fetchApiProvider)
                                                            .pmsStructureForDuplicating![index],
                                                        inndex: index,
                                                      );
                                                  setState(() {
                                                    isLoad = false;
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    border: Border.all(
                                                        color: validateStartdate(ref
                                                                .read(
                                                                    fetchApiProvider)
                                                                .pmsStructureForDuplicating![
                                                            index])),
                                                  ),
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          5.0, 0.0, 5.0, 0.0),
                                                  child: TextFormField(
                                                    // validator: (value) {
                                                    //   if (value!.isEmpty) {
                                                    //     return "(Start Date Cannot Be Empty)";
                                                    //   }
                                                    // },
                                                    enabled: false,
                                                    readOnly: true,
                                                    controller: controllerStart,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 13.0),
                                                    textAlignVertical:
                                                        TextAlignVertical
                                                            .center,

                                                    decoration:
                                                        const InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        10.0),
                                                            border: InputBorder
                                                                .none,
                                                            //  OutlineInputBorder(
                                                            //     borderSide: BorderSide(
                                                            //         color: Colors
                                                            //             .black)),
                                                            hintText:
                                                                'Start Date',
                                                            hintStyle:
                                                                TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      116,
                                                                      116,
                                                                      116),
                                                              fontSize: 13.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w200,
                                                              fontFamily:
                                                                  'HelveticaNeue',
                                                            ),
                                                            suffixIcon: Icon(
                                                              Icons
                                                                  .calendar_month_outlined,
                                                              size: 20,
                                                            )),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              // height: 40,
                                              width: 125,
                                              child: InkWell(
                                                onTap: () {
                                                  ref
                                                      .read(homeProvider)
                                                      .selectEndDateDrawer(
                                                        context: context,
                                                        startDateRes:
                                                            DateTime(2000),
                                                        endDateRes:
                                                            DateTime(2101),
                                                        control: controllerEnd,
                                                        controlday: controller,
                                                        startDateResponse: ref
                                                                .read(
                                                                    fetchApiProvider)
                                                                .pmsStructureForDuplicating![
                                                                    index]
                                                                .pmsStartDate ??
                                                            DateTime.now(),
                                                        currData: ref
                                                            .read(
                                                                fetchApiProvider)
                                                            .pmsStructureForDuplicating![index],
                                                        inndex: index,
                                                        // ref
                                                        //     .watch(homeProvider)
                                                        //     .dictDrawerData!
                                                        // .parent_start_date!,
                                                      );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    border: Border.all(
                                                        color: validateEnddate(ref
                                                                .read(
                                                                    fetchApiProvider)
                                                                .pmsStructureForDuplicating![
                                                            index])),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          5.0, 0.0, 5.0, 0.0),
                                                  child: TextFormField(
                                                    // validator: (value) {
                                                    //   if (value!.isEmpty) {
                                                    //     return "(End Date Cannot Be Empty)";
                                                    //   }
                                                    // },

                                                    enabled: false,
                                                    readOnly: true,
                                                    controller: controllerEnd,
                                                    textAlign: TextAlign.center,
                                                    textAlignVertical:
                                                        TextAlignVertical
                                                            .center,

                                                    // controller: ref
                                                    //     .watch(homeProvider)
                                                    //     .endDateControlerDrawer,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 13.0),
                                                    decoration:
                                                        const InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        12.0),
                                                            border: InputBorder
                                                                .none,
                                                            // OutlineInputBorder(
                                                            //     borderSide: BorderSide(
                                                            //         color: Colors
                                                            //             .black)),
                                                            hintText:
                                                                'End Date',
                                                            hintStyle:
                                                                TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      116,
                                                                      116,
                                                                      116),
                                                              fontSize: 13.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w200,
                                                              fontFamily:
                                                                  'HelveticaNeue',
                                                            ),
                                                            suffixIcon: Icon(
                                                              Icons
                                                                  .calendar_month_outlined,
                                                              size: 20,
                                                            )),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // if (ref.watch(homeProvider).workOrderListSelected == null)
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                        child: Row(
                          children: [
                            Text(
                              'Work Order Percentage: ',
                              style: TextStyle(
                                color: ref
                                            .read(homeProvider)
                                            .workOrderListSelected !=
                                        null
                                    ? Colors.black54
                                    : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              height: 30,
                              child: TextFormField(
                                readOnly:
                                    ref.read(homeProvider).checkboxValue == 0
                                        ? true
                                        : false,
                                // enabled: true,
                                // inputFormatters: [
                                //   FilteringTextInputFormatter.digitsOnly,
                                // ],
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}')),
                                  Max100InputFormatter(),
                                ],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                onChanged: (value) {
                                  ref
                                      .read(homeProvider)
                                      .setWorkCompletePercentageValue(
                                          double.parse(value) / 100);
                                },
                                controller: ref
                                    .watch(homeProvider)
                                    .controllerWorkOrderPercentageDrawer,
                                textAlignVertical: TextAlignVertical.center,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: const TextStyle(fontSize: 13),
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    hintText: "Work Order Percentage",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(7.0)))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (ref.read(homeProvider).checkboxValue == 0
                          // ref.watch(homeProvider).workOrderListSelected != null
                          )
                        AbsorbPointer(
                          child: Slider(
                            activeColor: Colors.black26,
                            inactiveColor: Colors.black12,
                            thumbColor: Colors.black45,
                            value: ref
                                .read(homeProvider)
                                .workCompletePercentageValue,
                            label: ref
                                .watch(homeProvider)
                                .workCompletePercentageValue
                                .round()
                                .toString(),
                            onChanged: (double value) {
                              // setState(() {
                              // ref
                              //     .read(homeProvider)
                              //     .setWorkCompletePercentageValue(value);
                              // _currentSliderSecondaryValue = value;
                              // });
                            },
                          ),
                        ),
                      if (ref.read(homeProvider).checkboxValue == 1
                          // ref.watch(homeProvider).workOrderListSelected == null
                          )
                        Slider(
                          activeColor: Colors.black,
                          inactiveColor: Colors.black12,
                          thumbColor: Colors.black,
                          value: ref
                              .read(homeProvider)
                              .workCompletePercentageValue,
                          label: ref
                              .watch(homeProvider)
                              .workCompletePercentageValue
                              .round()
                              .toString(),
                          onChanged: (double value) {
                            // setState(() {
                            ref
                                .read(homeProvider)
                                .setWorkCompletePercentageValue(value);
                            ref
                                .watch(homeProvider)
                                .controllerWorkOrderPercentageDrawer
                                .text = (value * 100).toStringAsFixed(2);
                            // _currentSliderSecondaryValue = value;
                            // });
                          },
                        ),

                      CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                            'Would you like to extend the percentage'),
                        value: ref.read(homeProvider).checkboxValue == 1,
                        onChanged: (bool? newValue) {
                          ref
                              .read(homeProvider)
                              .updateCheckboxValue(newValue == true ? 1 : 0);
                        },
                      ),
                      Container(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                        child: const Text(
                          'Remark',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                        child: TextFormField(
                          validator: (value) {
                            if (ref.read(homeProvider).workOrderListSelected !=
                                    null &&
                                ref
                                        .watch(homeProvider)
                                        .dictDrawerData!
                                        .workOrderDetails
                                        ?.length !=
                                    0) {
                              // print(ref
                              //         .watch(homeProvider)
                              //         .dictDrawerData!
                              //         .workOrderDetails![0]
                              //         .workOrderNumber !=
                              //     ref
                              //         .watch(homeProvider)
                              //         .workOrderListSelected
                              //         ?.workOrderNumber);
                              if (ref
                                          .watch(homeProvider)
                                          .dictDrawerData!
                                          .workOrderDetails![0]
                                          .workOrderNumber !=
                                      ref
                                          .watch(homeProvider)
                                          .workOrderListSelected
                                          ?.workOrderNumber &&
                                  value!.isEmpty) {
                                return "(Remark Cannot Be Empty)";
                              }
                            }
                            // if (value!.isEmpty) {
                            //   return "(Remark Cannot Be Empty)";
                            // }
                          },
                          controller: remarkControler,
                          maxLines: 5,
                          minLines: 3,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 13.0),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(12.0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            hintText: 'Please Enter Remark',
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
                      const SizedBox(height: 16),
                      // const Divider(
                      //   color: Colors.black,
                      // ),
                      Container(
                        margin: const EdgeInsetsDirectional.symmetric(
                            horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color.fromARGB(255, 175, 175, 175)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 14),

                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  10.0, 0.0, 10.0, 0.0),
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Assign Work Order',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (ref
                                          .watch(homeProvider)
                                          .workOrderListSelected !=
                                      null)
                                    InkWell(
                                      onTap: () {
                                        ref
                                            .watch(homeProvider)
                                            .workOrderControlerDrawer
                                            .text = "";
                                        ref
                                            .read(homeProvider)
                                            .setWorkOrderListSelected(null);
                                        ref
                                            .read(homeProvider)
                                            .setWorkCompletePercentageValue(
                                                0.0);
                                        ref
                                            .watch(homeProvider)
                                            .controllerWorkOrderPercentageDrawer
                                            .text = "0";
                                        ref
                                            .read(homeProvider)
                                            .updateCheckboxValue(1);
                                      },
                                      child: Container(
                                        // padding: EdgeInsets.only(left: 10),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 2),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          "Clear",
                                          // style: TextStyle(
                                          //   color: Colors.red,
                                          // ),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  if (ref
                                          .watch(homeProvider)
                                          .workOrderListSelected !=
                                      null)
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) {
                                              return WoPreviewHtml(
                                                projectId: widget.projectId,
                                                projectName: widget.projectName,
                                                workOrderId: ref
                                                    .watch(homeProvider)
                                                    .workOrderListSelected
                                                    ?.workOrderId,
                                                workOrderNo: ref
                                                    .watch(homeProvider)
                                                    .workOrderListSelected
                                                    ?.workOrderNumber,
                                                flagRedirect:
                                                    'Issued', //'Issued', //Assigned
                                              );
                                            },
                                          ),
                                        ).then((value) => {});
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 2),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'View WO',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () {
                                workOrderControler.clear();
                                fetchWorkOrders(
                                    projectId: widget.projectId,
                                    towarId: widget.towarId);

                                // if (ref
                                //             .watch(homeProvider)
                                //             .dictDrawerData!
                                //             .workOrderDetails
                                //             ?.length !=
                                //         0 &&
                                //     workOrderListRes?[0] !=
                                //         ref
                                //             .watch(homeProvider)
                                //             .dictDrawerData!
                                //             .workOrderDetails![0]) {
                                //   workOrderListRes?.insert(
                                //       0,
                                //       ref
                                //           .watch(homeProvider)
                                //           .dictDrawerData!
                                //           .workOrderDetails![0]
                                //       // workOrderListSelected!
                                //       );
                                // }
                                selectWorkOrderModal(
                                  projectId: widget.projectId,
                                  towarId: widget.towarId,
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(
                                    10.0, 0.0, 10.0, 0.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                  ),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: TextFormField(
                                  // validator: (value) {
                                  //   if (value!.isEmpty) {
                                  //     return "(Start Date Cannot Be Empty)";
                                  //   }
                                  // },
                                  enabled: false,
                                  readOnly: true,
                                  controller: ref
                                      .watch(homeProvider)
                                      .workOrderControlerDrawer,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 13.0),
                                  maxLines: 1,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(12.0),
                                    border: InputBorder.none,
                                    // OutlineInputBorder(
                                    //     borderSide: BorderSide(color: Colors.black)),
                                    hintText: 'Select Work Order',
                                    hintStyle: TextStyle(
                                      color: Color.fromARGB(255, 116, 116, 116),
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w200,
                                      fontFamily: 'HelveticaNeue',
                                    ),
                                    suffixIcon: Icon(
                                        Icons.arrow_drop_down_circle_outlined),
                                  ),
                                ),
                              ),
                            ),
                            // const SizedBox(height: 14),
                            if (ref
                                    .read(homeProvider)
                                    .workOrderListSelected
                                    ?.mstCompanyName !=
                                null)
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                    10.0, 0.0, 10.0, 0.0),
                                // child: Text(
                                //     'Company Name - ${ref.watch(homeProvider).dictDrawerData?.workOrderDetails?[0].mstCompanyName}'),

                                child: Text(
                                    'Company Name - ${ref.read(homeProvider).workOrderListSelected?.mstCompanyName}'),
                              ),
                            if (ref
                                    .read(homeProvider)
                                    .workOrderListSelected
                                    ?.companyType !=
                                null)
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                    10.0, 0.0, 10.0, 0.0),
                                child: Text(
                                    'WO Type - ${ref.read(homeProvider).workOrderListSelected?.skillType}'),
                              ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                          child: const Text("Remarks :")),
                      const Divider(
                        color: Colors.black,
                      ),
                      const SizedBox(height: 8),
                      if (ref
                              .watch(homeProvider)
                              .dictDrawerData
                              ?.remarkList
                              ?.length !=
                          0)
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: ref
                                        .watch(homeProvider)
                                        .dictDrawerData
                                        ?.remarkList
                                        ?.length !=
                                    0
                                ? ref
                                        .watch(homeProvider)
                                        .dictDrawerData
                                        ?.remarkList
                                        ?.length ??
                                    0
                                : 0,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: const EdgeInsets.fromLTRB(
                                    16.0, 0.0, 16.0, 0.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ref
                                              .watch(homeProvider)
                                              .dictDrawerData
                                              ?.remarkList?[index]
                                              .transPmsRemark ??
                                          '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      // crossAxisAlignment: cros,
                                      children: [
                                        Text(
                                          DateFormat('dd/MM/yyyy HH:mm:ss')
                                              .format(ref
                                                      .watch(homeProvider)
                                                      .dictDrawerData
                                                      ?.remarkList?[index]
                                                      .createdAt ??
                                                  DateTime.now()),
                                          style: const TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          '-by ${ref.watch(homeProvider).dictDrawerData?.remarkList?[index].userName}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (context, index) => const Divider(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      if (ref
                              .watch(homeProvider)
                              .dictDrawerData
                              ?.remarkList
                              ?.length ==
                          0)
                        Container(
                            // color: Colors.amber,
                            height: 120,
                            padding:
                                const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                            child:
                                const Center(child: Text("No Remark Found"))),
                      if (isValidateForDatesString != "" &&
                          isValidateForDates == true)
                        Container(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                          child: Text(
                            isValidateForDatesString,
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      Container(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: 240,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.black)),
                                child: const Text(
                                  'Close',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // if (!isValidateStartEndLoop)
                            InkWell(
                              onTap: () async {
                                if (_key.currentState!.validate()) {
                                  // inspect(ref
                                  //     .watch(homeProvider)
                                  //     .dictDrawerData!
                                  //     .workOrderDetails![0]);
                                  // inspect(
                                  //     ref.watch(homeProvider).workOrderListSelected);
                                  if (ref
                                              .watch(homeProvider)
                                              .workOrderListSelected !=
                                          null &&
                                      ref
                                              .watch(homeProvider)
                                              .dictDrawerData!
                                              .workOrderDetails
                                              ?.length !=
                                          0) {
                                    // print(ref
                                    //         .watch(homeProvider)
                                    //         .dictDrawerData!
                                    //         .workOrderDetails![0]
                                    //         .workOrderNumber !=
                                    //     ref
                                    //         .watch(homeProvider)
                                    //         .workOrderListSelected
                                    //         ?.workOrderNumber);
                                  }
                                  setState(() {
                                    isValidateForDates = false;
                                    isValidateForDatesString = '';
                                  });
                                  for (int l = 0;
                                      l <
                                          ref
                                              .read(fetchApiProvider)
                                              .pmsStructureForDuplicating!
                                              .length;
                                      l++) {
                                    // print(
                                    //     '${ref.read(fetchApiProvider).pmsStructureForDuplicating?[l].pmsStartDate} +++++++++++ ${ref.read(fetchApiProvider).pmsStructureForDuplicating?[l].pmsEndDate}');

                                    if ((ref
                                                .read(fetchApiProvider)
                                                .pmsStructureForDuplicating?[l]
                                                .pmsStartDate ==
                                            null &&
                                        ref
                                                .read(fetchApiProvider)
                                                .pmsStructureForDuplicating?[l]
                                                .pmsEndDate ==
                                            null)) {
                                      setState(() {
                                        isValidateForDates = false;
                                        isValidateForDatesString = '';
                                      });
                                    } else if ((ref
                                                .read(fetchApiProvider)
                                                .pmsStructureForDuplicating?[l]
                                                .pmsStartDate !=
                                            null &&
                                        ref
                                                .read(fetchApiProvider)
                                                .pmsStructureForDuplicating?[l]
                                                .pmsEndDate ==
                                            null)) {
                                      setState(() {
                                        isValidateForDates = true;
                                        isValidateForDatesString =
                                            '(Please Enter Necessary Details)';
                                      });
                                      break;
                                    } else if (ref
                                                .read(fetchApiProvider)
                                                .pmsStructureForDuplicating?[l]
                                                .pmsStartDate ==
                                            null &&
                                        ref
                                                .read(fetchApiProvider)
                                                .pmsStructureForDuplicating?[l]
                                                .pmsEndDate !=
                                            null) {
                                      setState(() {
                                        isValidateForDates = true;
                                        isValidateForDatesString =
                                            '(Please Enter Necessary Details)';
                                      });
                                      break;
                                    }
                                    // else if (ref
                                    //             .read(fetchApiProvider)
                                    //             .pmsStructureForDuplicating?[l]
                                    //             .pmsStartDate ==
                                    //         DateTime(2000) &&
                                    //     ref
                                    //             .read(fetchApiProvider)
                                    //             .pmsStructureForDuplicating?[l]
                                    //             .pmsEndDate !=
                                    //         null) {
                                    //   // print('-----------inside-----------');
                                    //   setState(() {
                                    //     isValidateForDates = true;
                                    //     isValidateForDatesString =
                                    //         '(Please Enter Necessary Details)';
                                    //     // '${ref.read(fetchApiProvider).pmsStructureForDuplicating?[l].pmsCategoryName}';
                                    //   });
                                    // }
                                    else if (ref
                                                .read(fetchApiProvider)
                                                .pmsStructureForDuplicating?[l]
                                                .pmsStartDate !=
                                            null &&
                                        ref
                                                .read(fetchApiProvider)
                                                .pmsStructureForDuplicating?[l]
                                                .pmsStartDate !=
                                            DateTime(2000) &&
                                        ref
                                                .read(fetchApiProvider)
                                                .pmsStructureForDuplicating?[l]
                                                .pmsEndDate ==
                                            DateTime(2101)) {
                                      // print('-----------inside-----------');
                                      setState(() {
                                        isValidateForDates = true;
                                        isValidateForDatesString =
                                            '(Please Enter Necessary Details)';
                                        // '${ref.read(fetchApiProvider).pmsStructureForDuplicating?[l].pmsCategoryName}';
                                      });
                                      break;
                                    }
                                  }
                                  if (isValidateForDates == false) {
                                    ref
                                        .read(fetchApiProvider)
                                        .updateExistingPmsApi(
                                            // parentId: widget.entry.node.dict?.mstPmsId ?? '',
                                            mstpmsid: ref
                                                    .watch(homeProvider)
                                                    .dictDrawerData
                                                    ?.mstPmsId ??
                                                '',
                                            parentId: ref
                                                    .watch(homeProvider)
                                                    .dictDrawerData
                                                    ?.parentIdFk ??
                                                '',
                                            title: ref
                                                    .watch(homeProvider)
                                                    .dictDrawerData
                                                    ?.pmsCategoryName ??
                                                '',
                                            startDate: ref
                                                .watch(homeProvider)
                                                .selectedStartDateDrawer!,
                                            endtDate: ref
                                                .watch(homeProvider)
                                                .selectedEndDateDrawer!,
                                            projectId: widget.projectId,
                                            towarId: widget.towarId,
                                            remark: remarkControler.text,
                                            updatedPmsListTemp:
                                                jsonEncode(updatedPmsListTemp));
                                    ;
                                    setState(() {
                                      isLoad = true;
                                    });
                                    Navigator.of(context).pop();
                                    remarkControler.clear();
                                  }

                                  // Future.delayed(const Duration(seconds: 10), () {
                                  // print(
                                  //     'One second has passed.'); // Prints after 1 second.
                                  // inspect(ref.read(fetchApiProvider).treeController);
                                  // for (int k = 0;
                                  //     k <
                                  //         ref
                                  //             .read(fetchApiProvider)
                                  //             .openDropDown
                                  //             .length;
                                  //     k++) {
                                  //   print(ref
                                  //       .read(fetchApiProvider)
                                  //       .openDropDown[k]
                                  //       .dict
                                  //       ?.pmsCategoryName);
                                  //   ref.read(fetchApiProvider).treeController.expand(
                                  //       ref.read(fetchApiProvider).openDropDown[k]);
                                  // }
                                  // });
                                  // DateTime? selectedStartDateDrawer;
                                  // DateTime? selectedEndDateDrawer;
                                }
                              },
                              child: Container(
                                width: 240,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.black,
                                ),
                                child: const Text(
                                  'Submit',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  selectWorkOrderModal({
    required String projectId,
    required String towarId,
  }) {
    // titleControler.clear();
    // startDateControler.clear();
    // endDateControler.clear();
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
                "Select Work Order",
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
                    workOrderControler.clear();
                    fetchWorkOrders(
                        projectId: widget.projectId, towarId: widget.towarId);
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Text(
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
                InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                    workOrderControler.clear();
                    fetchWorkOrders(
                        projectId: widget.projectId, towarId: widget.towarId);
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Text(
                      'ADD',
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
              content: SizedBox(
                width: 500,
                height: 444,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKeySelectWorkOrder,
                    child: Column(
                      children: [
                        TextFormField(
                          // validator: (value) {
                          //   if (value!.isEmpty) {
                          //     return "(Remark Cannot Be Empty)";
                          //   }
                          // },
                          onChanged: (value) {
                            setState(() {
                              offsetRes = 0;
                            });
                            // if (value.length >= 2) {
                            // print(value);
                            // Future<List<WorkOrderList>?> daaaa =
                            fetchWorkOrders(
                              projectId: projectId,
                              towarId: towarId,
                            ).then((value) {
                              setState(() {
                                workOrderListRes = value;
                              });
                            });

                            // print(daaaa.then((value) => null));
                            // }
                          },
                          controller: workOrderControler,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 13.0),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(12.0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            hintText: 'Search By Work Order',
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 116, 116, 116),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'HelveticaNeue',
                            ),
                            // suffixIcon: workOrderControler.text.length != 0
                            //     ? Icon(
                            //         Icons.clear_rounded,
                            //       )
                            //     : SizedBox.shrink(),
                            prefixIcon: Icon(
                              Icons.search,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 380,
                          child: workOrderListRes?.length != 0
                              ? ListView.separated(
                                  controller: modalScrollController,
                                  shrinkWrap: true,
                                  itemCount: workOrderListRes?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        // setState(() {
                                        ref
                                            .read(homeProvider)
                                            .setWorkOrderListSelected(
                                                workOrderListRes![index]);
                                        ref
                                            .read(homeProvider)
                                            .updateCheckboxValue(0);
                                        // workOrderListSelected =
                                        //     workOrderListRes?[index];
                                        ref
                                                .watch(homeProvider)
                                                .workOrderControlerDrawer
                                                .text =
                                            '${workOrderListRes?[index].workOrderNumber} \n ${workOrderListRes?[index].mstCompanyName}  |  ${workOrderListRes?[index].skillType}';
                                        // });

                                        Navigator.of(context).pop();
                                        workOrderControler.clear();
                                        fetchWorkOrders(
                                            projectId: widget.projectId,
                                            towarId: widget.towarId);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                          color: Colors.grey,
                                        ))),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  workOrderListRes?[index]
                                                          .workOrderNumber ??
                                                      '',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  '${workOrderListRes?[index].mstCompanyName}  |  ${workOrderListRes?[index].skillType}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              height: 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                              ),
                                              child: ref
                                                          .watch(homeProvider)
                                                          .workOrderListSelected
                                                          ?.workOrderNumber ==
                                                      workOrderListRes?[index]
                                                          .workOrderNumber
                                                  ? SvgPicture.asset(
                                                      'images/projectmanagement/check_icon.svg',
                                                      height: 20,
                                                      width: 20,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Container(
                                                      height: 24,
                                                      width: 24,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: Colors.grey,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100)),
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const Divider(
                                      height: 1,
                                      thickness: 0.5,
                                      indent: 1,
                                      endIndent: 1,
                                      color: Colors.black,
                                    );
                                  },
                                )
                              : const Center(child: Text("No Record Found")),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }
}

class Max100InputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final double? parsedValue = double.tryParse(newValue.text);
    if (parsedValue != null && parsedValue > 100) {
      return const TextEditingValue(
        text: '100',
        selection: TextSelection.collapsed(offset: 3),
      );
    }
    return newValue;
  }
}

class ExamplesView extends StatefulWidget {
  const ExamplesView({
    super.key,
    required this.projectId,
    required this.towarId,
    required this.projectName,
    required this.towarName,
  });
  final String projectId;
  final String towarId;
  final String projectName;
  final String towarName;

  @override
  State<ExamplesView> createState() => _ExamplesViewState();
}

class _ExamplesViewState extends State<ExamplesView> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: kThemeAnimationDuration,
      child: TreeIndentGuideScope(
        key: const Key('Drag and Drop'),
        child: DragAndDropTreeView(
          projectId: widget.projectId,
          towarId: widget.towarId,
          projectName: widget.projectName,
          towarName: widget.towarName,
        ),
      ),
    );
  }
}

class TreeIndentGuideScope extends StatelessWidget {
  const TreeIndentGuideScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final IndentGuide guide;
    const indent = 40.0;
    const lineOrigin = 0.5;
    const lineThickness = 2.0;

    guide = IndentGuide.connectingLines(
      indent: indent,
      color: Theme.of(context).colorScheme.outline,
      thickness: lineThickness,
      origin: lineOrigin,
      roundCorners: false,
    );
    return DefaultIndentGuide(
      guide: guide,
      child: child,
    );
  }
}
