import 'package:stallion/ui/views/accountmanagement/account_management_preview.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_document.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_network.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_all_sales_lead.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/models/sales_lead_filter.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/accountmanagement/signature_wo_dialog.dart';
import 'package:stallion/ui/views/accountmanagement/wopreviewhtml.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import '../../../models/get_project_wo_request.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import '../mycontracts/imagepreviewview.dart';
import '../rccstructure/pdfviewer.dart';

// class WoRequestedView extends StatefulWidget {
//   const WoRequestedView(
//       {super.key,
//       this.projectId,
//       this.towarId,
//       this.projectName,
//       required this.assignToId,
//       this.flagRedirect});

//   final String? projectId;
//   final String? towarId;
//   final String? projectName;
//   final String? flagRedirect;
//   final String assignToId;

//   @override
//   State<WoRequestedView> createState() => _WoRequestedViewState();
// }

class WoRequestedView extends StatefulWidget {
  const WoRequestedView({super.key});

  @override
  State<WoRequestedView> createState() => _WoRequestedViewState();
}

class _WoRequestedViewState extends State<WoRequestedView> {
  late NotificationArgs args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context)!.settings.arguments as NotificationArgs;
  }

  String? handSignUrl = '';

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = AccountManagementPreviewNetwork();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? woMaskFlagRes = "1";
  String isSelectedVenderList = '';
  bool flagcalled = false;
  bool norecord = false;
  List<FilterList>? filterListData = [];

  List<FilterList>? filteredList = [];
  int filterListSelected = 0;
  String searchText = '';
  TextEditingController searchController = TextEditingController();

  List<WoOrderList>? woOrderList = [];

  String? offset = '0';
  String searchTermValue = '';
  TextEditingController editingController = TextEditingController();
  DateTime? _selectedToDate;
  DateTime? _selectedFormDate;
  TextEditingController fromDateControler = TextEditingController();
  TextEditingController toDateControler = TextEditingController();
  // String? authorizeFlag = '';

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
        // ref.read(budgetApiProvider).setSelectedFormDate(data: picked);
        fromDateControler.text =
            DateFormat('yyyy/M/d').format(_selectedFormDate!);
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedToDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedToDate) {
      setState(() {
        _selectedToDate = picked;
        toDateControler.text = DateFormat('yyyy/M/d').format(_selectedToDate!);
      });
    }
  }

  List<InvoiceFilterList>? invoiceFilterList = [];

  Future<ResponseGetProjectWoRequest?> fetchProjectWoRequested() async {
    String formatDate(DateTime dateTime) {
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    }

    CustomLoading.progressDialog(isLoading: true, context: context);

    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));
    String? loginType = (prefs.getString('loginType') ??
        (useAccountManagementTestData ? '1' : null));
    var status = '';
    if (args.response?.flagRedirect == "Requested") {
      status = '3';
    } else if (args.response?.flagRedirect == "Assigned") {
      status = '0';
    } else if (args.response?.flagRedirect == "Issued") {
      status = '1';
    }

    // String towerId = "";
    // if (args.response?.towarId != null) {
    //   towerId = args.response!.towarId!;
    // }

    Map<String, String> data = {
      "user_type": (prefs.getString('userType') ??
              (useAccountManagementTestData ? '1' : null)) ??
          '',
      "user_id": userId!,
      "project_id": args.projectId!,
      "towar_id": args.response?.towarId ?? "",
      "wo_status": status,
      "limit": "20",
      "offset": offset!,
      "search_data": searchTermValue,
      "login_type": loginType!,
      "start_date":
          _selectedFormDate == null ? '' : formatDate(_selectedFormDate!),
      "end_date": _selectedToDate == null ? '' : formatDate(_selectedToDate!),
      'invoice_status':
          isSelectedVenderList == "" ? "" : isSelectedVenderList.toString(),
      "fliterlist": jsonEncode(filteredList),
      "assign_to_id": args.response?.assignToId ?? "",
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.getprojectworequested, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getProjectWoRequestFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          handSignUrl = dataModel.response?.handSignUrl;

          // authorizeFlag = dataModel.response?.authorizeFlag;
          invoiceFilterList = dataModel.response?.invoiceFilterList;
          woMaskFlagRes = dataModel.response?.woMaskFlag;
          if (searchTermValue.isEmpty) {
            offset = dataModel.response?.offset;
          } else {
            offset = '0';
            woOrderList = [];
          }
          List<WoOrderList>? rccBooking = [];
          rccBooking = dataModel.response?.woOrderList!;

          if (woOrderList!.isEmpty) {
            woOrderList = rccBooking;
          } else {
            for (int i = 0; i < rccBooking!.length; i++) {
              woOrderList?.add(rccBooking[i]);
            }
          }

          if (woOrderList!.isEmpty) {
            norecord = true;
          } else {
            norecord = false;
          }

          setState(() {
            flagcalled = true;
            woOrderList!.length;
          });
        });
      }
      CustomLoading.progressDialog(isLoading: false, context: context);
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      CustomLoading.progressDialog(isLoading: false, context: context);

      return null;
    }
    return null;
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));

    offset = '0';
    searchTermValue = '';
    woOrderList = [];

    fetchProjectWoRequested();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));
    fetchProjectWoRequested();
    _refreshController.loadComplete();
  }

  List<Detail>? filteredProjects() {
    if (searchText.isEmpty) {
      return filterListData![filterListSelected].details;
    }
    return filterListData![filterListSelected].details!.where((project) {
      return project.name!.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
  }

  Future<ResponseGetAllSalesLead?> getLeadFilter() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": args.projectId!,
      "towar_id": args.response?.towarId ?? "",
      // "status_supply": flagSortBy == true ? "1" : "0",
      "wo_status": args.response?.flagRedirect! == 'Assigned' ? "0" : "1",
    };
    var response = await apiNetworkHandler.post(AppUrl.wsWoFilter, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = salesLeadFilterFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        //inspect(invensterFilter);
        setState(() {
          filterListData = dataModel.response?.filterList;
        });
      }
    }
    return null;
  }

  String checkStatus(
      {required String woIsIssued, required String reApprovedReson}) {
    if (woIsIssued == "0") {
      if (reApprovedReson != "") {
        return "Re-Assigned";
      }
      return "Assigned ";
    } else if (woIsIssued == "1") {
      if (reApprovedReson != "") {
        return "Re-Issued";
      }
      return "Issued ";
    } else if (woIsIssued == "3") {
      return "Requested";
    } else {
      return '';
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchProjectWoRequested();
      getLeadFilter();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
              args.response?.flagRedirect == 'Requested'
                  ? '${args.projectName!.toUpperCase()} - WORK ORDER REQUESTED'
                  : args.response?.flagRedirect == 'Assigned'
                      ? '${args.projectName!.toUpperCase()} - WORK ORDER ASSIGNED'
                      : '${args.projectName!.toUpperCase()} - WORK ORDER ISSUED',
              style:
                  const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.maybePop(context);
            },
          ),
          actions: [
            // if (widget.flagRedirect! != 'Requested' &&
            //     widget.flagRedirect! != 'Assigned')
            //   InkWell(
            //       onTap: () {
            //         selectFilterModal();
            //         // selectFilterVenderModal();
            //       },
            //       child: Image.asset(
            //         // 'images/projectmanagement/filter-sort-icon-white.png',
            //         'images/projectmanagement/filter-sort-icon-white.png',
            //         height: 20,
            //       )),
            if (args.response?.flagRedirect != 'Requested' &&
                args.response?.assignToId == '')
              InkWell(
                onTap: () {
                  searchController.clear();
                  setState(() {
                    searchText = "";
                  });
                  showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setState1) {
                            return AlertDialog(
                                elevation: 0,
                                shadowColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // Set radius to zero
                                ),
                                titlePadding:
                                    const EdgeInsets.symmetric(vertical: 0),
                                actionsPadding:
                                    const EdgeInsets.only(bottom: 0),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 0),
                                actionsAlignment: MainAxisAlignment.center,
                                title: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  decoration: const BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8))),
                                  child: const Text(
                                    "FILTER",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                actions: <Widget>[
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          searchController.clear();
                                          setState(() {
                                            searchText = "";
                                          });
                                          for (FilterList filter
                                              in filterListData!) {
                                            filter.ct = 0;
                                            for (Detail detail
                                                in filter.details!) {
                                              setState1(() {
                                                detail.isSelected = false;
                                              });
                                            }
                                          }
                                          setState1(() {
                                            offset = '0';

                                            filteredList = [];
                                            searchTermValue = '';
                                            // rccBookingHistory = [];
                                          });

                                          filteredList = [];
                                          woOrderList = [];

                                          fetchProjectWoRequested();
                                          // Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          decoration: const BoxDecoration(
                                              color: Colors.black,
                                              border: Border(
                                                  right: BorderSide(
                                                      color: Colors.white)),
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(8))),
                                          child: const Text(
                                            "RESET",
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
                                        onTap: () {
                                          // Navigator.of(context).pop();

                                          filteredList = [];

                                          // Filter the data
                                          for (FilterList filter
                                              in filterListData!) {
                                            List<Detail>? details = [];
                                            for (Detail detail
                                                in filter.details!) {
                                              if (detail.isSelected == true) {
                                                details.add(detail);
                                              }
                                            }
                                            // Add filtered details to the filteredList
                                            filteredList?.add(FilterList(
                                              name: filter.name,
                                              id: filter.id,
                                              details: details,
                                            ));
                                          }

                                          setState1(() {
                                            offset = '0';
                                            searchTermValue = '';
                                            woOrderList = [];
                                          });
                                          fetchProjectWoRequested()
                                              .then((value) => {
                                                    Navigator.of(context).pop(),
                                                  });
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          decoration: const BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(8))),
                                          child: const Text(
                                            "APPLY FILTER",
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
                                  )
                                ],
                                content: StatefulBuilder(builder:
                                    (BuildContext context1,
                                        StateSetter setState) {
                                  return SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.6,
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: MediaQuery.of(context1)
                                                      .size
                                                      .height *
                                                  0.6,
                                              width: MediaQuery.of(context1)
                                                      .size
                                                      .width *
                                                  0.2,
                                              color: Colors.grey.shade300,
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    for (int i = 0;
                                                        i <
                                                            filterListData!
                                                                .length;
                                                        i++)
                                                      InkWell(
                                                        onTap: () {
                                                          setState1(() {
                                                            filterListSelected =
                                                                i;
                                                            searchText = '';
                                                            searchController
                                                                .clear();
                                                          });
                                                        },
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                      context1)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                          // color: Colors.white,
                                                          decoration: BoxDecoration(
                                                              color: i ==
                                                                      filterListSelected
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .transparent
                                                              // border: Border.all(
                                                              //     color:
                                                              //         Colors.black),
                                                              ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 14,
                                                                  horizontal:
                                                                      40),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                '${filterListData?[i].name}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              if (filterListData![
                                                                          i]
                                                                      .ct >
                                                                  0)
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              7.0),
                                                                  child:
                                                                      Container(
                                                                    height: 5,
                                                                    width: 5,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                100),
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                )
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              // height: 300,
                                              // width: 455,
                                              height: MediaQuery.of(context1)
                                                      .size
                                                      .height *
                                                  0.6,
                                              width: MediaQuery.of(context1)
                                                      .size
                                                      .width *
                                                  0.4,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    height: 36,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 40),
                                                    child: TextFormField(
                                                      controller:
                                                          searchController,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          // filteredProjects();
                                                          searchText = value;
                                                        });
                                                      },
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 13.0),
                                                      decoration:
                                                          const InputDecoration(
                                                        prefixIcon: Icon(
                                                          Icons.search,
                                                          size: 22,
                                                        ),

                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                bottom: 0,
                                                                left: 12),
                                                        // border: OutlineInputBorder(
                                                        //   borderSide: BorderSide(color: Colors.transparent),
                                                        // ),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          8.0)),
                                                        ),
                                                        hintText: 'Search',
                                                        hintStyle: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              116,
                                                              116,
                                                              116),
                                                          fontSize: 13.0,
                                                          fontWeight:
                                                              FontWeight.w200,
                                                          fontFamily:
                                                              'HelveticaNeue',
                                                        ),
                                                        // suffixIcon: Icon(
                                                        //   Icons.calendar_month_outlined,
                                                        // ),
                                                      ),
                                                    ),
                                                  ),
                                                  // const SizedBox(
                                                  //   height: 10,
                                                  // ),
                                                  Divider(
                                                      color:
                                                          Colors.grey.shade300),
                                                  //      height: 300,
                                                  // width: 282,
                                                  // color: Colors.cyan,
                                                  SizedBox(
                                                    // height: 240,
                                                    height:
                                                        (MediaQuery.of(context1)
                                                                    .size
                                                                    .height *
                                                                0.6) -
                                                            62,
                                                    // width: 482,
                                                    // color: Colors.cyan,
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          for (int k = 0;
                                                              k <
                                                                  filteredProjects()!
                                                                      .length;
                                                              k++)
                                                            InkWell(
                                                              onTap: () {
                                                                setState1(() {
                                                                  // if (filterListSelected == 0) {
                                                                  //   bool? temp = filterListData![filterListSelected].details![k].isSelected;
                                                                  //   filterListData?[filterListSelected].ct = temp == true ? 0 : 1;
                                                                  //   for (int p = 0; p < filteredProjects()!.length; p++) {
                                                                  //     filterListData![filterListSelected].details?[p].isSelected = false;
                                                                  //   }

                                                                  //   filterListData![filterListSelected].details?[k].isSelected = temp == true ? false : true;
                                                                  //   // filterListData![filterListSelected]
                                                                  //   //     .details?[
                                                                  //   //         k]
                                                                  //   //     .isSelected = filterListData![filterListSelected].details?[k].isSelected ==
                                                                  //   //         false
                                                                  //   //     ? true
                                                                  //   //     : false;
                                                                  // } else {
                                                                  if (filteredProjects()?[
                                                                              k]
                                                                          .isSelected ==
                                                                      false) {
                                                                    filterListData?[
                                                                            filterListSelected]
                                                                        .ct = filterListData![filterListSelected]
                                                                            .ct +
                                                                        1;
                                                                  } else {
                                                                    filterListData?[
                                                                            filterListSelected]
                                                                        .ct = filterListData![filterListSelected]
                                                                            .ct -
                                                                        1;
                                                                  }
                                                                  filteredProjects()?[
                                                                              k]
                                                                          .isSelected =
                                                                      filteredProjects()?[k].isSelected ==
                                                                              false
                                                                          ? true
                                                                          : false;
                                                                  // }
                                                                });
                                                              },
                                                              child: Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        40,
                                                                    vertical:
                                                                        5),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(filteredProjects()?[k].isSelected ==
                                                                            true
                                                                        ? Icons
                                                                            .check_box_rounded
                                                                        : Icons
                                                                            .check_box_outline_blank_outlined),
                                                                    const SizedBox(
                                                                        width:
                                                                            10),
                                                                    Text(
                                                                      filteredProjects()?[k]
                                                                              .name ??
                                                                          '',
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                }));
                          },
                        );
                      });
                },
                child: Container(
                  child: filteredList?.length != 0
                      ? Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(4),
                          child: Image.asset(
                            'images/projectmanagement/filter-sort-icon.png',
                            height: 20,
                          ),
                        )
                      : Image.asset(
                          'images/projectmanagement/filter_black.png',
                          height: 20,
                        ),
                ),
              ),
            const SizedBox(width: 80)
          ],
        ),
        body: Container(
            height: double.infinity,
            color: Colors.white,
            child: SafeArea(
                child:
                    //  flagcalled == true
                    //     ?
                    Column(
              children: [
                verticalSpaceSmall,
                StartEndDateSelection(),
                verticalSpaceSmall,
                verticalSpaceSmall,
                Padding(
                  padding: const EdgeInsets.only(left: 60.0, right: 60),
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      onChanged: (value) {
                        Future.delayed(const Duration(seconds: 1), () {
                          if (value.isNotEmpty) {
                            if (value.length > 2) {
                              woOrderList = [];
                              offset = '0';
                              searchTermValue = value;
                              searchTermValue =
                                  searchTermValue.replaceAll("  ", " ");
                              searchTermValue = searchTermValue.trim();
                              fetchProjectWoRequested();
                            }
                          } else {
                            offset = '0';
                            searchTermValue = '';
                            woOrderList = [];
                            editingController.clear();
                            fetchProjectWoRequested();
                            FocusScope.of(context).requestFocus(FocusNode());
                          }
                        });
                      },
                      style: const TextStyle(fontSize: 13),
                      controller: editingController,
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                          // labelText: "Search by WO.No, Skills or Company Name",
                          hintText: "Search by WO.No, Skills or Company Name",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0)))),
                    ),
                  ),
                ),
                verticalSpaceSmall,
                const Divider(
                    height: 0.5,
                    thickness: 0.5,
                    indent: 1,
                    endIndent: 1,
                    color: Colors.black),
                verticalSpaceSmall,
                norecord == true
                    ? const Expanded(
                        child: Center(
                            child: Text('No Record Found', style: normalText)))
                    : Expanded(
                        child: SmartRefresher(
                          enablePullDown:
                              searchTermValue.isEmpty ? true : false,
                          enablePullUp: searchTermValue.isEmpty ? true : false,
                          controller: _refreshController,
                          onRefresh:
                              searchTermValue.isEmpty ? _onRefresh : null,
                          onLoading:
                              searchTermValue.isEmpty ? _onLoading : null,
                          footer: const ClassicFooter(
                              loadStyle: LoadStyle.ShowWhenLoading),
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ListView.builder(
                            itemCount: woOrderList!.length,
                            itemBuilder: (context, index) {
                              var arrUploadImg =
                                  woOrderList![index].uploadNoteImage!;
                              return InkWell(
                                // onTap: () {
                                //   Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (_) {
                                //         return WoPreviewHtml(
                                //             poAssingTo:
                                //                 woOrderList![index].woAssingTo,
                                //             projectId:
                                //                 woOrderList![index].projectId!,
                                //             projectName: woOrderList![index]
                                //                 .projectName!,
                                //             workOrderId:
                                //                 woOrderList![index].woOrderId!,
                                //             workOrderNo: woOrderList![index]
                                //                 .woOrderNo!
                                //                 .toUpperCase(),
                                //             flagRedirect: widget.flagRedirect!);
                                //       },
                                //     ),
                                //   ).then((_) {
                                //     // This block runs when you have returned back to the 1st Page from 2nd.
                                //     setState(() {
                                //       // Call setState to refresh the page.
                                //       flagcalled = false;
                                //       offset = '0';
                                //       searchTermValue = '';
                                //       woOrderList = [];
                                //       fetchProjectWoRequested();
                                //     });
                                //   });
                                // },
                                onTap: () {
                                  if (woOrderList![index].arrWoDoc!.length ==
                                      1) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return WoPreviewHtml(
                                              arrPoDoc: woOrderList![index]
                                                  .arrWoDoc?[0],
                                              towarId:
                                                  args.response?.towarId ?? '',
                                              poAssingTo: woOrderList![index]
                                                  .woAssingTo,
                                              projectId: woOrderList![index]
                                                      .projectIdFk ??
                                                  '',
                                              projectName: woOrderList![index]
                                                  .projectName!,
                                              workOrderId: woOrderList![index]
                                                  .woOrderId!,
                                              workOrderNo: woOrderList![index]
                                                  .woOrderNo!
                                                  .toUpperCase(),
                                              flagRedirect:
                                                  args.response?.flagRedirect ??
                                                      '');
                                        },
                                      ),
                                    ).then((_) {
                                      // This block runs when you have returned back to the 1st Page from 2nd.
                                      setState(() {
                                        // Call setState to refresh the page.
                                        flagcalled = false;
                                        offset = '0';
                                        searchTermValue = '';
                                        woOrderList = [];
                                        fetchProjectWoRequested();
                                      });
                                    });
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(
                                            builder: (context, setState1) {
                                              return AlertDialog(
                                                  elevation: 0,
                                                  shadowColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  titlePadding: const EdgeInsets
                                                      .symmetric(vertical: 0),
                                                  actionsPadding:
                                                      const EdgeInsets.only(
                                                          bottom: 0),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 0),
                                                  actionsAlignment:
                                                      MainAxisAlignment.center,
                                                  title: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 5),
                                                    decoration: const BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        8),
                                                                topRight: Radius
                                                                    .circular(
                                                                        8))),
                                                    child: const Text(
                                                      "WORK ORDER'S",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    Row(
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Container(
                                                            width: 500,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        4),
                                                            decoration: const BoxDecoration(
                                                                color: Colors
                                                                    .black,
                                                                borderRadius: BorderRadius.only(
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            8),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            8))),
                                                            child: const Text(
                                                              "OK",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                  content: StatefulBuilder(
                                                      builder: (BuildContext
                                                              context1,
                                                          StateSetter
                                                              setState) {
                                                    return SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.4,
                                                      child: Column(children: [
                                                        for (int i = 0;
                                                            i <
                                                                woOrderList![
                                                                        index]
                                                                    .arrWoDoc!
                                                                    .length;
                                                            i++)
                                                          InkWell(
                                                            onTap: () {
                                                              if (i == 0) {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (_) {
                                                                      return WoPreviewHtml(
                                                                        arrPoDoc:
                                                                            woOrderList![index].arrWoDoc?[i],
                                                                        poAssingTo:
                                                                            woOrderList![index].woAssingTo,
                                                                        projectId:
                                                                            woOrderList![index].projectIdFk!,
                                                                        projectName:
                                                                            woOrderList![index].projectName!,
                                                                        workOrderId:
                                                                            woOrderList![index].woOrderId!,
                                                                        workOrderNo: woOrderList![index]
                                                                            .woOrderNo!
                                                                            .toUpperCase(),
                                                                        flagRedirect:
                                                                            args.response?.flagRedirect ??
                                                                                '',
                                                                      );
                                                                    },
                                                                  ),
                                                                ).then((_) {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  Future.delayed(
                                                                      const Duration(
                                                                          seconds:
                                                                              1),
                                                                      () {
                                                                    // This block runs when you have returned back to the 1st Page from 2nd.
                                                                    // setState(
                                                                    // () {
                                                                    // Call setState to refresh the page.
                                                                    flagcalled =
                                                                        false;
                                                                    offset =
                                                                        '0';
                                                                    searchTermValue =
                                                                        '';
                                                                    woOrderList =
                                                                        [];
                                                                    fetchProjectWoRequested();
                                                                    // });
                                                                  });
                                                                });
                                                              } else {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (_) {
                                                                      return (useAccountManagementTestData
                                                                          ? const AccountManagementPreviewDocumentScreen()
                                                                          : PdfViewer(
                                                                              fileName: woOrderList![index].arrWoDoc?[i].fileName!,
                                                                              fileUrl: woOrderList![index].arrWoDoc?[i].filePath,
                                                                              // AppUrl.globalPoinvoicePath +
                                                                              //     invoiceData![index].invoiceImage!,
                                                                            ));
                                                                    },
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                            child: Container(
                                                              decoration: const BoxDecoration(
                                                                  border: Border(
                                                                      bottom: BorderSide(
                                                                          color:
                                                                              Colors.black))),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          24,
                                                                      vertical:
                                                                          9),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  // Column(
                                                                  //   crossAxisAlignment:
                                                                  //       CrossAxisAlignment
                                                                  //           .start,
                                                                  //   children: [
                                                                  //     Text(
                                                                  //       woOrderList![index].arrWoDoc?[i].fileName ??
                                                                  //           '',
                                                                  //       style:
                                                                  //           const TextStyle(
                                                                  //         fontSize:
                                                                  //             16,
                                                                  //         fontWeight:
                                                                  //             FontWeight.w400,
                                                                  //       ),
                                                                  //     ),
                                                                  // Text(
                                                                  //   '(${woOrderList![index].arrWoDoc?[i].createdAt})',
                                                                  //   style: const TextStyle(
                                                                  //       fontSize:
                                                                  //           14,
                                                                  //       fontWeight:
                                                                  //           FontWeight.w400,
                                                                  //       color: Colors.black54),
                                                                  // )
                                                                  //   ],
                                                                  // ),
                                                                  Container(
                                                                    decoration: const BoxDecoration(
                                                                        border: Border(
                                                                            bottom: BorderSide(
                                                                      color: Colors
                                                                          .blue,
                                                                    ))),
                                                                    child: Text(
                                                                      woOrderList![index]
                                                                              .arrWoDoc?[i]
                                                                              .fileName ??
                                                                          '',
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        color: Colors
                                                                            .blue,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '(${woOrderList![index].arrWoDoc?[i].createdAt})',
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: Colors
                                                                            .black54),
                                                                  )
                                                                  // Container(
                                                                  //   padding: const EdgeInsets
                                                                  //       .symmetric(
                                                                  //       horizontal:
                                                                  //           20),
                                                                  //   decoration:
                                                                  //       BoxDecoration(
                                                                  //     borderRadius:
                                                                  //         BorderRadius.circular(
                                                                  //             8),
                                                                  //     border: Border.all(
                                                                  //         color:
                                                                  //             Colors.black),
                                                                  //   ),
                                                                  //   child:
                                                                  //       const Text(
                                                                  //     "View WO",
                                                                  //     style:
                                                                  //         TextStyle(
                                                                  //       fontSize:
                                                                  //           16,
                                                                  //       fontWeight:
                                                                  //           FontWeight.w400,
                                                                  //     ),
                                                                  //   ),
                                                                  // )
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                      ]),
                                                    );
                                                  }));
                                            },
                                          );
                                        });
                                  }
                                },
                                child: ListTile(
                                  trailing: const Padding(
                                    padding: EdgeInsets.only(top: 70.0),
                                    child: Icon(Icons.keyboard_arrow_right),
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              left: 50, top: 10),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 200,
                                                      child: Text(
                                                          'Project Name',
                                                          style: TextStyle(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        woOrderList![index]
                                                            .projectName!,
                                                        style: const TextStyle(
                                                            backgroundColor:
                                                                Colors.white,
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black)),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 200,
                                                      child: Text('W.O. Status',
                                                          style: normalText),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: args.response
                                                                    ?.flagRedirect ==
                                                                "Requested"
                                                            ? Colors.yellow
                                                            : args.response
                                                                        ?.flagRedirect ==
                                                                    "Assigned"
                                                                ? Colors.yellow
                                                                : args.response
                                                                            ?.flagRedirect ==
                                                                        "Issued"
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .yellow,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 15.0,
                                                                right: 15.0,
                                                                top: 5.0,
                                                                bottom: 5.0),
                                                        child: Text(
                                                            // widget.flagRedirect! ==
                                                            //             "Requested" ||
                                                            //         widget.flagRedirect! ==
                                                            //             "RequestedNew"
                                                            //     ? 'Requested'
                                                            //     : widget.flagRedirect! ==
                                                            //             "Assigned"
                                                            //         ? woOrderList![index].reApprovedReson! !=
                                                            //                 ""
                                                            //             ? 'Re-Assigned'
                                                            //             : 'Assigned'
                                                            //         //  'Assigned'
                                                            //         : widget.flagRedirect! ==
                                                            //                 "Issued"
                                                            //             ? woOrderList![index].reApprovedReson! !=
                                                            //                     ""
                                                            //                 ? 'Re-Issued'
                                                            //                 : 'Issued'
                                                            //             : '--',

                                                            checkStatus(
                                                                woIsIssued:
                                                                    woOrderList![index]
                                                                            .woIsIssued ??
                                                                        '',
                                                                reApprovedReson:
                                                                    woOrderList![index]
                                                                            .reApprovedReson ??
                                                                        ''),
                                                            style: args.response
                                                                            ?.flagRedirect ==
                                                                        "Requested" ||
                                                                    args.response
                                                                            ?.flagRedirect ==
                                                                        "RequestedNew"
                                                                ? normalText
                                                                : args.response
                                                                            ?.flagRedirect ==
                                                                        "Assigned"
                                                                    ? normalText
                                                                    : const TextStyle(
                                                                        fontWeight: FontWeight
                                                                            .bold,
                                                                        fontSize:
                                                                            14.0,
                                                                        color:
                                                                            Colors.white)),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 15.0,
                                                              right: 15.0,
                                                              top: 5.0,
                                                              bottom: 5.0),
                                                      child: Text(
                                                          woOrderList![index]
                                                                      .reApprovedReson! !=
                                                                  ""
                                                              ? '( ${DateFormat('dd MMM yyyy').format(DateFormat('dd-MM-yyyy').parse(woOrderList![index].reApprovedDate!.toString()))} )'
                                                              : '',
                                                          style: boldText),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 200,
                                                      child: Text(
                                                          'Work Order Number',
                                                          style: TextStyle(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        woOrderList![index]
                                                            .woOrderNo!,
                                                        style: const TextStyle(
                                                            backgroundColor:
                                                                Colors.white,
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black)),
                                                    horizontalSpaceSmall,
                                                    woOrderList![index]
                                                                .is_star_marked! ==
                                                            '1'
                                                        ? const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    bottom:
                                                                        8.0),
                                                            child: Icon(
                                                              Icons.star,
                                                              color: Colors.red,
                                                              size: 14,
                                                            ),
                                                          )
                                                        : const SizedBox(),
                                                    if (woOrderList![index]
                                                                .draftFlag ==
                                                            "1" &&
                                                        args.response
                                                                ?.flagRedirect ==
                                                            "Requested")
                                                      const Text("(Draft)",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.grey)),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 200,
                                                      child: Text('Assigned To',
                                                          style: TextStyle(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        woOrderList![index]
                                                            .woAssingToName!,
                                                        style: const TextStyle(
                                                            backgroundColor:
                                                                Colors.white,
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black)),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 200,
                                                      child: Text(
                                                          'Company Name',
                                                          style: TextStyle(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        woOrderList![index]
                                                            .companyName!,
                                                        style: const TextStyle(
                                                            backgroundColor:
                                                                Colors.white,
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black)),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 200,
                                                      child: Text('Grade Type',
                                                          style: TextStyle(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        woOrderList![index]
                                                                .contractType ??
                                                            '',
                                                        style: const TextStyle(
                                                            backgroundColor:
                                                                Colors.white,
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black)),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 200,
                                                      child: Wrap(
                                                        crossAxisAlignment:
                                                            WrapCrossAlignment
                                                                .end,
                                                        children: [
                                                          Text('Amount',
                                                              style: TextStyle(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black)),
                                                          Text(' (Excl. GST)',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .grey)),
                                                        ],
                                                      ),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        currencyFormat.format(double
                                                            .parse(woOrderList![
                                                                        index]
                                                                    .valueTotalWithOutGst ??
                                                                '0')),
                                                        style:
                                                            const TextStyle(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black)),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 200,
                                                      child: Wrap(
                                                        crossAxisAlignment:
                                                            WrapCrossAlignment
                                                                .end,
                                                        children: [
                                                          Text('Total Amount',
                                                              style: TextStyle(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black)),
                                                          Text(' (Incl. GST)',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .grey)),
                                                        ],
                                                      ),
                                                      // child: Text(
                                                      //     'Total Amount',
                                                      //     style: TextStyle(
                                                      //         backgroundColor:
                                                      //             Colors.white,
                                                      //         fontSize: 15,
                                                      //         color: Colors
                                                      //             .black)),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    woMaskFlagRes != "1"
                                                        ? Text(
                                                            woOrderList![index]
                                                                        .valueTotal! !=
                                                                    ""
                                                                ? currencyFormat.format(double.parse(
                                                                    woOrderList![index]
                                                                        .valueTotal!))
                                                                : '\u{20B9} 0',
                                                            style: const TextStyle(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black))
                                                        : const Text(
                                                            '\u{20B9}**',
                                                            style: TextStyle(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black)),
                                                    const Spacer(),
                                                    if (
                                                        // ((woOrderList![index]
                                                        //               .woHandSignImg)
                                                        //           ?.trim() !=
                                                        //       "") &&
                                                        woOrderList![index]
                                                                    .authorizeFlag ==
                                                                '1' &&
                                                            woOrderList![index]
                                                                    .woHandSignImg
                                                                    ?.trim() !=
                                                                "")
                                                      const Icon(
                                                        Icons
                                                            .check_circle_outline,
                                                        color: Colors.green,
                                                      ),
                                                    const SizedBox(width: 10),
                                                    // if ((widget.flagRedirect! ==
                                                    //             "Assigned" ||
                                                    //         widget.flagRedirect! ==
                                                    //             "Issued") &&
                                                    //     authorizeFlag ==
                                                    //         '1            ')
                                                    if (
                                                        // ((woOrderList![index]
                                                        //               .woHandSignImg)
                                                        //           ?.trim() !=
                                                        //       "") &&
                                                        woOrderList![index]
                                                                    .authorizeFlag ==
                                                                '1' &&
                                                            args.response
                                                                    ?.flagRedirect !=
                                                                "Requested")
                                                      InkWell(
                                                        onTap: () async {
                                                          // if ((woOrderList![
                                                          //                 index]
                                                          //             .woHandSignImg)
                                                          //         ?.trim() ==
                                                          //     "") {
                                                          final result =
                                                              await showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (context) =>
                                                                      SignatureWoDialog(
                                                                        projectId:
                                                                            // widget.projectId ??
                                                                            //     '',
                                                                            (args.projectId?.trim() == '' || args.projectId == null)
                                                                                ? woOrderList![index].projectIdFk
                                                                                : args.projectId,
                                                                        towarId: (args.response?.towarId?.trim() == '' ||
                                                                                args.response?.towarId == null)
                                                                            ? woOrderList![index].towarIdFk
                                                                            : args.response?.towarId,
                                                                        // widget.towarId ??
                                                                        //     '',
                                                                        // towarName:
                                                                        //     widget.towarName ?? '',
                                                                        projectName:
                                                                            args.projectName ??
                                                                                '',
                                                                        orderId:
                                                                            woOrderList![index].woOrderId,
                                                                        handSignUrl: woOrderList![index].woHandSignImg?.trim() !=
                                                                                ''
                                                                            ? '${AppUrl.baseURL}media/backend/wo-hand-sign/${woOrderList![index].woHandSignImg}'
                                                                            // 'https://stallions.in/stallion-new/media/backend/wo-hand-sign/${woOrderList![index].woHandSignImg}'
                                                                            // https://skrite.com/stallion-build-test/media/backend/wo-hand-sign/${woOrderList![index].woHandSignImg}'
                                                                            : '',
                                                                        flagRedirect: args
                                                                            .response
                                                                            ?.flagRedirect,
                                                                      )).then(
                                                                  (value) {
                                                            // Navigator.of(
                                                            //         context)
                                                            //     .pop();
                                                            setState(() {
                                                              offset = '0';
                                                              searchTermValue =
                                                                  '';
                                                              woOrderList = [];
                                                              searchTermValue =
                                                                  '';
                                                              woOrderList = [];
                                                            });

                                                            fetchProjectWoRequested();
                                                          });
                                                          // }
                                                        },
                                                        child: Container(
                                                          width: 108,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 0,
                                                                  vertical: 4),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                          ),
                                                          child: const Text(
                                                            // (woOrderList![index]
                                                            //                 .woHandSignImg)
                                                            //             ?.trim() !=
                                                            //         ""
                                                            //     ? "Signed"
                                                            //     :
                                                            "E-Sign",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  // (woOrderList![index]
                                                                  //                 .woHandSignImg)
                                                                  //             ?.trim() !=
                                                                  //         ""
                                                                  //     ? Colors.grey
                                                                  //     :
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              if (woOrderList![index]
                                                      .woCheckedBy !=
                                                  "")
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 10.0),
                                                  child: Row(
                                                    children: [
                                                      const SizedBox(
                                                          width: 200,
                                                          child: Text(
                                                              'Checked By',
                                                              style: TextStyle(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black))),
                                                      horizontalSpaceMedium,
                                                      const Center(
                                                          child: Icon(
                                                              Icons.remove,
                                                              color: Colors
                                                                  .black54)),
                                                      horizontalSpaceLarge,
                                                      Text(
                                                          '${woOrderList![index].woCheckedBy} (${woOrderList![index].woCheckedByDate})',
                                                          style: const TextStyle(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.black))
                                                    ],
                                                  ),
                                                ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(
                                                      width: 200,
                                                      child: Text(
                                                          'Est. Completion Date',
                                                          style: TextStyle(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        woOrderList![index]
                                                            .estDate!,
                                                        style:
                                                            const TextStyle(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black)),
                                                    const Expanded(
                                                        child:
                                                            horizontalSpaceLarge),
                                                    arrUploadImg.isNotEmpty
                                                        ? SizedBox(
                                                            width: 110,
                                                            height: 33,
                                                            child: InkWell(
                                                              onTap: () {
                                                                showDialog(
                                                                    barrierDismissible:
                                                                        false,
                                                                    context:
                                                                        context,
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        Dialog(
                                                                          elevation:
                                                                              0,
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                600,
                                                                            width:
                                                                                460.0,
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                const Padding(
                                                                                  padding: EdgeInsets.only(top: 10.0, bottom: 5),
                                                                                  child: Text(
                                                                                    'VIEW BOQ',
                                                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                ),
                                                                                const Divider(
                                                                                  color: Colors.grey,
                                                                                  thickness: 1,
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 490,
                                                                                  child: SingleChildScrollView(
                                                                                    child: Wrap(
                                                                                      children: List.generate(growable: true, arrUploadImg.length, (index) {
                                                                                        return Padding(
                                                                                            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                                                                                            child: InkWell(
                                                                                              onTap: () {
                                                                                                arrUploadImg[index]["image_name"].toString().split(".").last == 'pdf'
                                                                                                    ? Navigator.push(
                                                                                                        context,
                                                                                                        MaterialPageRoute(
                                                                                                          builder: (_) {
                                                                                                            return (useAccountManagementTestData
                                                                                                                ? const AccountManagementPreviewDocumentScreen()
                                                                                                                : PdfViewer(
                                                                                                                    fileName: arrUploadImg[index]["image_name"].toString(),
                                                                                                                    fileUrl: '${AppUrl.globalUploadWoBoqURLMain}${arrUploadImg[index]["image_name"].toString()}',
                                                                                                                  ));
                                                                                                          },
                                                                                                        ),
                                                                                                      )
                                                                                                    : Navigator.push(
                                                                                                        context,
                                                                                                        MaterialPageRoute(
                                                                                                          builder: (_) {
                                                                                                            return (useAccountManagementTestData
                                                                                                                ? const AccountManagementPreviewDocumentScreen()
                                                                                                                : ImagePreviewViewer(
                                                                                                                    fileName: arrUploadImg[index]["image_name"].toString(),
                                                                                                                    fileUrl: '${AppUrl.globalUploadWoBoqURLMain}${arrUploadImg[index]["image_name"].toString()}',
                                                                                                                  ));
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
                                                                                                    arrUploadImg[index]["image_name"].toString().split(".").last == 'pdf'
                                                                                                        ? Image.asset(
                                                                                                            'images/projectmanagement/pdf.png',
                                                                                                            width: 100.0,
                                                                                                            height: 100.0,
                                                                                                            fit: BoxFit.cover,
                                                                                                          )
                                                                                                        : (useAccountManagementTestData
                                                                                                            ? const Icon(Icons.description_outlined, size: 48, color: Colors.black54)
                                                                                                            : Image.network(
                                                                                                                '${AppUrl.globalUploadWoBoqURLMain}${arrUploadImg[index]["image_name"].toString()}',
                                                                                                                width: 100,
                                                                                                                height: 100,
                                                                                                              )),
                                                                                                    const SizedBox(
                                                                                                      height: 5,
                                                                                                    ),
                                                                                                    Text(arrUploadImg[index]["image_name"].toString().capitalize()),
                                                                                                    const SizedBox(
                                                                                                      height: 5,
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ));
                                                                                      }),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                GestureDetector(
                                                                                  onTap: () {
                                                                                    Navigator.of(context).pop();
                                                                                  },
                                                                                  child: Container(
                                                                                    decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(5), color: Colors.black),
                                                                                    width: 240,
                                                                                    height: 40,
                                                                                    child: const Padding(
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
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                height: 33,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .black54,
                                                                  ),
                                                                ),
                                                                child:
                                                                    const Text(
                                                                  'VIEW BOQ',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .normal,
                                                                    fontSize:
                                                                        13.0,
                                                                  ),
                                                                ),
                                                              ),
                                                            ))
                                                        : const SizedBox()
                                                  ],
                                                ),
                                              ),
                                              args.response?.flagRedirect ==
                                                      "Requested"
                                                  ? woOrderList![index]
                                                              .reApprovedReson! !=
                                                          ""
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 10.0),
                                                          child: Row(
                                                            children: [
                                                              const SizedBox(
                                                                width: 200,
                                                                child: Text(
                                                                    'Re-Approval Reason',
                                                                    style:
                                                                        normalText),
                                                              ),
                                                              horizontalSpaceMedium,
                                                              const Center(
                                                                  child: Icon(
                                                                      Icons
                                                                          .remove,
                                                                      color: Colors
                                                                          .black54)),
                                                              horizontalSpaceLarge,
                                                              Flexible(
                                                                child: Text(
                                                                    woOrderList![
                                                                            index]
                                                                        .reApprovedReson!,
                                                                    style:
                                                                        normalText),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : const SizedBox()
                                                  : args.response
                                                              ?.flagRedirect ==
                                                          "Assigned"
                                                      ? woOrderList![index]
                                                                  .reApprovedReson! !=
                                                              ""
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          10.0),
                                                              child: Row(
                                                                children: [
                                                                  const SizedBox(
                                                                    width: 200,
                                                                    child: Text(
                                                                        'Re-Approval Reason',
                                                                        style:
                                                                            normalText),
                                                                  ),
                                                                  horizontalSpaceMedium,
                                                                  const Center(
                                                                      child: Icon(
                                                                          Icons
                                                                              .remove,
                                                                          color:
                                                                              Colors.black54)),
                                                                  horizontalSpaceLarge,
                                                                  Flexible(
                                                                    child: Text(
                                                                        woOrderList![index]
                                                                            .reApprovedReson!,
                                                                        style:
                                                                            normalText),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          : const SizedBox()
                                                      : args.response
                                                                  ?.flagRedirect ==
                                                              "Issued"
                                                          ? woOrderList![index]
                                                                      .reApprovedReson! !=
                                                                  ""
                                                              ? Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          10.0),
                                                                  child: Row(
                                                                    children: [
                                                                      const SizedBox(
                                                                        width:
                                                                            200,
                                                                        child: Text(
                                                                            'Re-Issued For',
                                                                            style:
                                                                                normalText),
                                                                      ),
                                                                      horizontalSpaceMedium,
                                                                      const Center(
                                                                          child: Icon(
                                                                              Icons.remove,
                                                                              color: Colors.black54)),
                                                                      horizontalSpaceLarge,
                                                                      Flexible(
                                                                        child: Text(
                                                                            woOrderList![index]
                                                                                .reApprovedReson!,
                                                                            style:
                                                                                normalText),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              : const SizedBox()
                                                          : const SizedBox(),
                                            ],
                                          )),
                                      verticalSpaceSmall15,
                                      const Divider(
                                        height: 1,
                                        thickness: 0.5,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ],
            ))
            // : const Center(child: CircularProgressIndicator())),
            ));
  }

  selectFilterModal() {
    return showDialog<void>(
        // barrierDismissible: false,
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
                'FILTER',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
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
              content: SizedBox(
                width: 200,
                height: 144,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (int i = 0; i < invoiceFilterList!.length; i++)
                        InkWell(
                          onTap: () {
                            setState1(() {
                              isSelectedVenderList =
                                  invoiceFilterList?[i].id ?? '';
                              offset = '0';
                              searchTermValue = '';
                              woOrderList = [];
                              // rccBookingHistory = [];
                            });
                            Navigator.of(context).pop();
                            fetchProjectWoRequested();
                          },
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 10, top: 8),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.black))),
                            child: Row(
                              children: [
                                Text(
                                  '${invoiceFilterList?[i].name} (${invoiceFilterList?[i].invoiceCount})',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const Spacer(),
                                Icon(
                                  isSelectedVenderList ==
                                          invoiceFilterList?[i].id
                                      ? Icons.check_circle_outline_sharp
                                      : Icons.circle_outlined,
                                  color: isSelectedVenderList ==
                                          invoiceFilterList?[i].id
                                      ? Colors.green
                                      : Colors.grey,
                                )
                              ],
                            ),
                          ),
                        ),
                      // Divider(color: Colors.grey),
                      // InkWell(
                      //   onTap: () {
                      //     setState1(() {
                      //       isSelectedVenderList = 0;
                      //       offset = '0';
                      //       searchTermValue = '';
                      //       woOrderList = [];
                      //       // rccBookingHistory = [];
                      //     });
                      //     Navigator.of(context).pop();
                      //     fetchProjectWoRequested();
                      //   },
                      //   child: Row(
                      //     children: [
                      //       Text(
                      //         'Pending Invoices',
                      //         style: TextStyle(fontSize: 16),
                      //       ),
                      //       Spacer(),
                      //       Icon(
                      //         isSelectedVenderList == 0
                      //             ? Icons.check_circle_outline_sharp
                      //             : Icons.circle_outlined,
                      //         color: isSelectedVenderList == 0
                      //             ? Colors.green
                      //             : Colors.grey,
                      //       )
                      //     ],
                      //   ),
                      // ),
                      // Divider(color: Colors.grey),
                      // InkWell(
                      //   onTap: () {
                      //     setState1(() {
                      //       isSelectedVenderList = 1;
                      //       offset = '0';
                      //       searchTermValue = '';
                      //       woOrderList = [];
                      //       // rccBookingHistory = [];
                      //     });
                      //     Navigator.of(context).pop();
                      //     fetchProjectWoRequested();
                      //   },
                      //   child: Row(
                      //     children: [
                      //       Text(
                      //         'Uploaded Invoices',
                      //         style: TextStyle(fontSize: 16),
                      //       ),
                      //       Spacer(),
                      //       Icon(
                      //         isSelectedVenderList == 1
                      //             ? Icons.check_circle_outline_sharp
                      //             : Icons.circle_outlined,
                      //         color: isSelectedVenderList == 1
                      //             ? Colors.green
                      //             : Colors.grey,
                      //       )
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  Widget StartEndDateSelection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 40),
            Container(
              padding: const EdgeInsets.only(right: 12),
              child: const AppText(
                title: "Filter",
                fontSize: 16,
              ),
            ),
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
                      hintText: 'Select From Date',
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
            const SizedBox(width: 14),
            Expanded(
              child: InkWell(
                onTap: () {
                  _selectToDate(context);
                },
                child: TextFormField(
                  enabled: false,
                  readOnly: true,
                  controller: toDateControler,
                  style: const TextStyle(color: Colors.black, fontSize: 13.0),
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(12.0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      hintText: 'Select To Date',
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
            const SizedBox(width: 20),
            OutlinedButton(
              onPressed: () {
                if (_selectedFormDate != null && _selectedToDate != null) {
                  setState(() {
                    offset = '0';
                  });
                  fetchProjectWoRequested();
                }
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.black,
                side: const BorderSide(width: 1.0, color: Colors.black45),
              ),
              child: const Text('Submit',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16.0,
                    color: Colors.white,
                  )),
            ),
            const SizedBox(width: 20),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedToDate = null;
                  _selectedFormDate = null;
                  fromDateControler.clear();
                  toDateControler.clear();
                  offset = '0';
                });
                fetchProjectWoRequested();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(width: 1.0, color: Colors.black45),
              ),
              child: const Text('Reset',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16.0,
                  )),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}
