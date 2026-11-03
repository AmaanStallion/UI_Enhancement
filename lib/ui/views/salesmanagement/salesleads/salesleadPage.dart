import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stallion/models/get_all_sales_lead.dart';
import 'package:stallion/models/get_broker_details.dart';
import 'package:stallion/models/sales_lead_default_filter.dart';
import 'package:stallion/models/sales_lead_filter.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/salesmanagement/bookingdetailsview.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/addSalesLeadPage.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/overview/overviewPageSales.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/salesLeadDetailPage.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:url_launcher/url_launcher.dart';

class SalesLeadPage extends StatefulWidget {
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? navigationFlag;
  final String? towarName;
  String? assignToId = '';

  SalesLeadPage(
      {super.key,
      required this.projectId,
      required this.towarId,
      required this.projectName,
      required this.navigationFlag,
      required this.towarName,
      this.assignToId});

  @override
  State<SalesLeadPage> createState() => _SalesLeadPageState();
}

TextEditingController editingController = TextEditingController();
final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
NetworkHandler apiNetworkHandler = NetworkHandler();
List<SalesLead> salesLeadList = [];
List<AreaRangeList>? intrestFilters = [];
List<AreaRangeList>? location = [];
List<AreaRangeList>? leadStage = [];

List<AreaRangeList>? rangeList = [];
List<AreaRangeList>? currentOwner = [];

List<AreaRangeList>? sourceList = [];
List<AreaRangeList>? subSources = [];
List<AreaRangeList>? ethnicity = [];

List<String>? requirementFilter = [];
List<BrokerList>? brokerFilters = [];
List<FlatDetail>? flatDetails = [];
List<AreaRangeList>? areaRangeList = [];
List<FilterList>? filterListData = [];
List<AssingUserList>? assingUserList = [];
List<AreaRangeList>? lostReason = [];
List<AreaRangeList>? invensterFilter = [
  AreaRangeList(id: "7", name: "Last 7 Days"),
  AreaRangeList(id: "30", name: "Last 30 Days"),
  AreaRangeList(id: "60", name: "Last 60 Days"),
];
String? clientAccess = '';
String selectedSortBy = "";
int selectedBottomFilter = 0;
ResponseGetAllSalesLead? responseGetAllSalesLead;
String? offset = '0';

bool isLoading = false;

final RefreshController _refreshController =
    RefreshController(initialRefresh: false);

DateTime? _selectedToDate;
DateTime? _selectedFormDate;
TextEditingController fromDateControler = TextEditingController();
TextEditingController toDateControler = TextEditingController();

List bottomFilterList = [
  "Total Leads",
  "Successfull Leads",
  "Cancelled Leads",
];

class _SalesLeadPageState extends State<SalesLeadPage> {
  String searchText = '';
  int filterListSelected = 0;
  List<FilterList>? filteredList = [];
  TextEditingController searchController = TextEditingController();

  List<Detail>? filteredProjects() {
    if (searchText.isEmpty) {
      return filterListData![filterListSelected].details;
    }
    return filterListData![filterListSelected].details!.where((project) {
      return project.name!.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
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
        // ref.read(budgetApiProvider).setSelectedFormDate(data: picked);
        fromDateControler.text =
            DateFormat('dd-MM-yyyy').format(_selectedFormDate!);
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
        toDateControler.text =
            DateFormat('dd-MM-yyyy').format(_selectedToDate!);
      });
    }
  }

  // get all sales lead filter
  Future<ResponseGetAllSalesLead?> getAllSalesLeadFilter() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId!,
    };
    var response =
        await apiNetworkHandler.post(AppUrl.webGetAllSalesLeadFilter, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = salesLeadDefaultFilterFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          currentOwner = dataModel.response?.currentOwner;
          currentConfiguration = dataModel.response?.currentConfiguration;
          nationality = dataModel.response?.nationality;
          campaign = dataModel.response?.campaign;
          flatDetails = dataModel.response?.flatDetails;
          rangeList = dataModel.response?.rangeList;
          subSources = dataModel.response?.subSources;
          ethnicity = dataModel.response?.ethnicity;
          lostReason = dataModel.response?.lostReason;
          sourceList = dataModel.response?.sourceList;
          areaRangeList = dataModel.response?.areaRangeList;
          inspect(sourceList);
          intrestFilters = dataModel.response?.invenster;
          location = dataModel.response?.location;
          brokerFilters = dataModel.response?.brokerList;
          leadStage = dataModel.response?.leadStage;
          requirementFilter = dataModel.response?.requirement;
          assingUserList = dataModel.response?.assingUserList;
          invensterFilter = [
            ...?invensterFilter,
            ...?dataModel.response?.invenster
          ];
        });
        //inspect(invensterFilter);
      }
    }
    return null;
  }

  Future<ResponseGetAllSalesLead?> getLeadFilter() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId!,
    };
    var response = await apiNetworkHandler.post(AppUrl.wsLeadFilter, data);

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

  // get all sales lead
  Future<ResponseGetAllSalesLead?> getAllSalesLead() async {
    setState(() {
      isLoading = true;
    });
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId!,
      "offset": offset ?? '',
      "lead_status": selectedBottomFilter.toString(),
      "limit": "20",
      "search_data":
          editingController.text.length > 2 ? editingController.text : "",
      "filter_invester": selectedSortBy == '0' ||
              selectedSortBy == "1" ||
              selectedSortBy == '2'
          ? selectedSortBy
          : '',
      "filter_date": selectedSortBy == '0' ||
              selectedSortBy == "1" ||
              selectedSortBy == '2'
          ? ''
          : selectedSortBy,
      "fliterlist": jsonEncode(filteredList),
      "start_date": fromDateControler.text,
      "end_date": toDateControler.text,
      "assign_to_id": widget.assignToId ?? '',
    };
    var response =
        await apiNetworkHandler.post(AppUrl.webGetAllSalesLead, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getAllSalesLeadFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          clientAccess = dataModel.response?.clientAccess;
          offset = dataModel.response?.offset;
          salesLeadList = dataModel.response!.salesLead!;
          responseGetAllSalesLead = dataModel.response;
          isLoading = false;
        });
      }
    }
    return null;
  }

  // get all sales lead for pagination
  Future<ResponseGetAllSalesLead?> getAllSalesLeadRefresh() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId!,
      "offset": offset ?? '',
      "lead_status": selectedBottomFilter.toString(),
      "limit": "20",
      "search_data":
          editingController.text.length > 2 ? editingController.text : "",
      "filter_invester": selectedSortBy == '0' ||
              selectedSortBy == "1" ||
              selectedSortBy == '2'
          ? selectedSortBy
          : '',
      "filter_date": selectedSortBy == '0' ||
              selectedSortBy == "1" ||
              selectedSortBy == '2'
          ? ''
          : selectedSortBy,
      "fliterlist": jsonEncode(filteredList),
      "assign_to_id": widget.assignToId ?? '',
    };
    var response =
        await apiNetworkHandler.post(AppUrl.webGetAllSalesLead, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getAllSalesLeadFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          clientAccess = dataModel.response?.clientAccess;
          if (dataModel.response!.salesLead!.isNotEmpty) {
            if (offset == '0') {
              salesLeadList = dataModel.response!.salesLead!;
            } else {
              salesLeadList = [
                ...salesLeadList,
                ...dataModel.response!.salesLead!
              ];
            }
            offset = dataModel.response?.offset;
          }
          responseGetAllSalesLead = dataModel.response;
        });
      }
    }
    return null;
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));

    offset = '0';

    getAllSalesLeadRefresh();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));

    getAllSalesLeadRefresh();
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    fromDateControler.clear();
    toDateControler.clear();
    setState(() {
      offset = '0';
      invensterFilter = [
        AreaRangeList(id: "7", name: "Last 7 Days"),
        AreaRangeList(id: "30", name: "Last 30 Days"),
        AreaRangeList(id: "60", name: "Last 60 Days"),
      ];
    });
    getAllSalesLead();
    getAllSalesLeadFilter();
    getLeadFilter();
    super.initState();
  }

  @override
  void dispose() {
    setState(() {
      offset = '0';
    });
    editingController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context1) {
    //inspect(responseGetAllSalesLead);
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            border: Border(
                top: BorderSide(
          color: Colors.black,
        ))),
        height: 70,
        child: Row(
          children: [
            for (int i = 0; i < bottomFilterList.length; i++)
              InkWell(
                onTap: () {
                  setState(() {
                    selectedBottomFilter = i;
                    offset = "0";
                    selectedSortBy = '';
                  });
                  getAllSalesLead();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  width: MediaQuery.of(context).size.width /
                      bottomFilterList.length,
                  decoration: BoxDecoration(
                    border: const Border(
                        left: BorderSide(
                      color: Colors.black,
                    )),
                    color:
                        selectedBottomFilter == i ? Colors.black : Colors.white,
                  ),
                  child: Column(
                    children: [
                      Text(
                        bottomFilterList[i],
                        style: TextStyle(
                          color: selectedBottomFilter == i
                              ? Colors.white
                              : Colors.black,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        bottomFilterList[i] == "Total Leads"
                            ? responseGetAllSalesLead?.generatedLead ?? ''
                            : bottomFilterList[i] == "Successfull Leads"
                                ? responseGetAllSalesLead?.convertedLead ?? ''
                                : bottomFilterList[i] == "Cancelled Leads"
                                    ? responseGetAllSalesLead?.cancelLead ?? ''
                                    : "",
                        style: TextStyle(
                          color: selectedBottomFilter == i
                              ? Colors.white
                              : Colors.black,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
            editingController.clear();
            //Navigator.of(context).pushReplacementNamed('/dashboard');
          },
        ),
        centerTitle: true,
        title: Text(
          '${widget.projectName!.toUpperCase()} ${widget.towarName!.isNotEmpty ? "-" : ""} ${widget.towarName!.toUpperCase()}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          // if (responseData?.projectOverView == '1')
          InkWell(
            onTap: () {
              var projectId = widget.projectId!;
              var projectName = widget.projectName!;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return OverviewPageSales(
                      projectId: projectId,
                      projectName: projectName,
                      towarId: widget.towarId,
                      towarName: widget.towarName!,
                    );
                  },
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text(
                  "Overview",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(
              color: Color.fromARGB(255, 80, 80, 80),
            ))),
            padding: const EdgeInsets.symmetric(horizontal: 70),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
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
                                            });

                                            filteredList = [];
                                            getAllSalesLead();
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

                                            print(jsonEncode(filteredList));
                                            setState1(() {
                                              offset = '0';
                                            });
                                            getAllSalesLead();
                                            Navigator.of(context).pop();
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
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.6,
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
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
                                                        CrossAxisAlignment
                                                            .start,
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
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .transparent
                                                                // border: Border.all(
                                                                //     color:
                                                                //         Colors.black),
                                                                ),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        14,
                                                                    horizontal:
                                                                        40),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  '${filterListData?[i].name}',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
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
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            7.0),
                                                                    child:
                                                                        Container(
                                                                      height: 5,
                                                                      width: 5,
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              100),
                                                                          color:
                                                                              Colors.black),
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
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8.0)),
                                                          ),
                                                          hintText: 'Search',
                                                          hintStyle: TextStyle(
                                                            color:
                                                                Color.fromARGB(
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
                                                        color: Colors
                                                            .grey.shade300),
                                                    //      height: 300,
                                                    // width: 282,
                                                    // color: Colors.cyan,
                                                    SizedBox(
                                                      // height: 240,
                                                      height: (MediaQuery.of(
                                                                      context1)
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
                                                                    if (filterListSelected ==
                                                                        0) {
                                                                      bool? temp = filterListData![
                                                                              filterListSelected]
                                                                          .details![
                                                                              k]
                                                                          .isSelected;
                                                                      filterListData?[
                                                                              filterListSelected]
                                                                          .ct = temp ==
                                                                              true
                                                                          ? 0
                                                                          : 1;
                                                                      for (int p =
                                                                              0;
                                                                          p < filteredProjects()!.length;
                                                                          p++) {
                                                                        filterListData![filterListSelected]
                                                                            .details?[p]
                                                                            .isSelected = false;
                                                                      }

                                                                      filterListData![filterListSelected]
                                                                          .details?[
                                                                              k]
                                                                          .isSelected = temp ==
                                                                              true
                                                                          ? false
                                                                          : true;
                                                                      // filterListData![filterListSelected]
                                                                      //     .details?[
                                                                      //         k]
                                                                      //     .isSelected = filterListData![filterListSelected].details?[k].isSelected ==
                                                                      //         false
                                                                      //     ? true
                                                                      //     : false;
                                                                    } else {
                                                                      if (filteredProjects()?[k]
                                                                              .isSelected ==
                                                                          false) {
                                                                        filterListData?[filterListSelected]
                                                                            .ct = filterListData![filterListSelected]
                                                                                .ct +
                                                                            1;
                                                                      } else {
                                                                        filterListData?[filterListSelected]
                                                                            .ct = filterListData![filterListSelected]
                                                                                .ct -
                                                                            1;
                                                                      }
                                                                      filterListData![filterListSelected]
                                                                          .details?[
                                                                              k]
                                                                          .isSelected = filteredProjects()?[k].isSelected ==
                                                                              false
                                                                          ? true
                                                                          : false;
                                                                    }
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
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
                                                                              .check_box_outlined
                                                                          : Icons
                                                                              .check_box_outline_blank_outlined),
                                                                      const SizedBox(
                                                                          width:
                                                                              10),
                                                                      Text(
                                                                        filteredProjects()?[k].name ??
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
                            color: Colors.black,
                            padding: const EdgeInsets.all(4),
                            child: Image.asset(
                              'images/projectmanagement/filter_black.png',
                              height: 20,
                            ),
                          )
                        : Image.asset(
                            'images/projectmanagement/filter-sort-icon.png',
                            height: 20,
                          ),
                  ),
                ),
                const Spacer(),
                const Text(
                  "SALES LEAD",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    if (
                        // brokerFilters!.isNotEmpty &&
                        requirementFilter?.length != 0 &&
                            intrestFilters?.length != 0) {
                      print("---------{}");
                      inspect(currentConfiguration);
                      Navigator.push(
                        context1,
                        MaterialPageRoute(
                          builder: (_) {
                            return AddSalesLeadPage(
                              nationality: nationality,
                              campaign: campaign,
                              currentOwner: currentOwner,
                              currentConfiguration: currentConfiguration,
                              clientAccess: clientAccess ?? '',
                              ethnicity: ethnicity,
                              flatDetails: flatDetails,
                              brokerList: brokerFilters,
                              requirementList: requirementFilter,
                              intrestFilters: intrestFilters,
                              projectId: widget.projectId,
                              towarId: widget.towarId,
                              projectName: widget.projectName,
                              navigationFlag: widget.navigationFlag,
                              towarName: widget.towarName,
                              rangeList: rangeList,
                              sourceList: sourceList,
                              areaRangeList: areaRangeList,
                              subSources: subSources,
                              location: location,
                              leadStage: leadStage,
                              assingUserList: assingUserList,
                              lostReason: lostReason,
                            );
                          },
                        ),
                      ).then((value) => {
                            setState(() {
                              offset = '0';
                              selectedSortBy = "";
                              editingController.text = '';
                              selectedSortBy = '';
                              selectedBottomFilter = 0;
                              invensterFilter = [
                                AreaRangeList(id: "7", name: "Last 7 Days"),
                                AreaRangeList(id: "30", name: "Last 30 Days"),
                                AreaRangeList(id: "60", name: "Last 60 Days"),
                              ];
                            }),
                            getAllSalesLead(),
                            getAllSalesLeadFilter(),
                          });
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        "ADD LEADS",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Row(
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
              // const Spacer(),
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
                  offset = '0';
                  getAllSalesLead();
                  // if (_selectedFormDate != null && _selectedToDate != null) {
                  //   // if (_formKey.currentState!.validate()) {
                  //   setState(() {
                  //     offset = "0";
                  //     projctDprListResponse?.clear();
                  //   });
                  //   CustomLoading.progressDialog(
                  //       isLoading: true, context: context);
                  //   fetchGetAllDPRlist().then((value) {
                  //     CustomLoading.progressDialog(
                  //         isLoading: false, context: context);
                  //   });
                  // }
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
                  offset = '0';
                  fromDateControler.clear();
                  toDateControler.clear();
                  getAllSalesLead();
                  // setState(() {
                  //   _selectedFormDate = null;
                  //   fromDateControler.clear();
                  //   _selectedToDate = null;
                  //   toDateControler.clear();
                  //   offset = '0';
                  // });
                  // fetchGetAllDPRlist();
                },
                style: OutlinedButton.styleFrom(
                  // backgroundColor: Colors.black,
                  side: const BorderSide(width: 1.0, color: Colors.black45),
                ),
                child: const Text('Reset',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16.0,
                      color: Colors.black,
                    )),
              ),
              const SizedBox(width: 40),
            ],
          ),
          Container(
            padding:
                const EdgeInsets.only(left: 66, right: 66, bottom: 10, top: 12),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  offset = '0';
                });
                getAllSalesLead();
              },
              style: const TextStyle(fontSize: 13),
              controller: editingController,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(12.0),
                  labelText: "Search by Name",
                  hintText: "Search by Name",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: editingController.text.length > 0
                      ? InkWell(
                          onTap: () {
                            setState(() {
                              offset = '0';
                            });
                            editingController.clear();
                            getAllSalesLead();
                          },
                          child: Container(
                            padding: const EdgeInsets.only(right: 12),
                            child: const Icon(Icons.close_rounded),
                          ),
                        )
                      : const SizedBox.shrink(),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            ),
          ),
          const Divider(),
          Expanded(
            child: isLoading && responseGetAllSalesLead == null
                ? const Center(child: CircularProgressIndicator())
                : salesLeadList.length != 0
                    ? SmartRefresher(
                        enablePullDown: true,
                        enablePullUp: true,
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        onLoading: _onLoading,
                        footer: const ClassicFooter(
                            loadStyle: LoadStyle.ShowWhenLoading),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context1, index) {
                            return _salesLeadCard(
                              context: context,
                              salesLeadData: salesLeadList[index],
                            );
                          },
                          itemCount: salesLeadList.length,
                          separatorBuilder: (context1, index) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 66,
                            ),
                            child: const Divider(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )
                    : const Center(
                        child: Text(
                          "No Record Found",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _statusCapsule({
    required BuildContext context,
    required String title,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: backgroundColor,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _salesLeadCard({
    required BuildContext context,
    required SalesLead salesLeadData,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return SalesLeadDeatilsPage(
                intrestFilters: intrestFilters,
                responseGetAllSalesLead: responseGetAllSalesLead,
                salesLeadData: salesLeadData,
                projectId: widget.projectId,
                towarId: widget.towarId,
                projectName: widget.projectName,
                navigationFlag: widget.navigationFlag,
                towarName: widget.towarName,
                clientAccess: clientAccess,
              );
            },
          ),
        ).then((value) => {
              setState(() {
                offset = '0';
              }),
              getAllSalesLead(),
            });
      },
      child: Container(
          padding: const EdgeInsets.only(left: 50),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 22, top: 10),
                    width: MediaQuery.of(context).size.width - 120,
                    child: Row(
                      children: [
                        Text(
                          salesLeadData.leadBuyerName ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        if (salesLeadData.leadIntrested != null)
                          _statusCapsule(
                            context: context,
                            title: salesLeadData.leadIntrested ?? '',
                            backgroundColor:
                                const Color.fromARGB(255, 118, 233, 122),
                          )
                      ],
                    ),
                  ),
                  _rowTwoText(
                    context: context,
                    title: 'Last Followed',
                    titleValue: salesLeadData.leadBuyerUpdatedAt ?? '',
                    isStatus: salesLeadData.leadSource!.isNotEmpty,
                    leadSourceSttus: salesLeadData.leadSource,
                    isTimerIcon: true,
                  ),
                  _rowEmailContact(
                    icon: 'images/projectmanagement/whatsappIcon.svg',
                    context: context,
                    title: "Contact No",
                    titleValue: responseGetAllSalesLead?.maskContact == '2'
                        ? salesLeadData.leadBuyerPhone!.length > 3
                            ? "*" * (salesLeadData.leadBuyerPhone!.length - 4) +
                                salesLeadData.leadBuyerPhone!.substring(
                                    salesLeadData.leadBuyerPhone!.length - 4)
                            : salesLeadData.leadBuyerPhone!.length <= 3
                                ? salesLeadData.leadBuyerPhone ?? ''
                                : "--"
                        : salesLeadData.leadBuyerPhone ?? '',
                    isVerified: salesLeadData.smsVerify ?? '0',
                  ),
                  _rowEmailContact(
                    icon: 'images/projectmanagement/emailIcon.svg',
                    context: context,
                    title: "Email",
                    titleValue: responseGetAllSalesLead?.maskContact == '2'
                        ? salesLeadData.leadBuyerEmail!.length > 3
                            ? "*" * (salesLeadData.leadBuyerEmail!.length - 4) +
                                salesLeadData.leadBuyerEmail!.substring(
                                    salesLeadData.leadBuyerEmail!.length - 4)
                            : salesLeadData.leadBuyerEmail!.length <= 3
                                ? salesLeadData.leadBuyerEmail ?? ''
                                : "--"
                        : salesLeadData.leadBuyerEmail ?? '',
                    onTap: responseGetAllSalesLead?.maskContact != '2'
                        ? () async {
                            final Uri emailUrl = Uri(
                              scheme: 'mailto',
                              path: salesLeadData.leadBuyerEmail,
                            );

                            if (await canLaunchUrl(emailUrl)) {
                              launchUrl(emailUrl);
                            } else {
                              throw Exception("couldnot launch url");
                            }
                          }
                        : () {},
                    isVerified: salesLeadData.emailVerify ?? '0',
                  ),
                  _rowTwoText(
                    context: context,
                    title: 'Requirement',
                    titleValue: salesLeadData.leadRequirement ?? '',
                  ),
                  _rowTwoText(
                    context: context,
                    title: 'Location',
                    titleValue: salesLeadData.leadLocation ?? '',
                  ),
                  _rowTwoText(
                    context: context,
                    title: 'Budget',
                    titleValue: salesLeadData.leadBudgetValue ?? '',
                  ),
                  _rowTwoText(
                    context: context,
                    title: 'Follow Up',
                    titleValue: '${salesLeadData.totalLead} times',
                  ),
                  _rowTwoText(
                    context: context,
                    title: 'Lead Owner',
                    titleValue: salesLeadData.leadOwner ?? '',
                  ),
                  _rowTwoText(
                    context: context,
                    title: 'Assign To',
                    titleValue:
                        '${salesLeadData.details?[salesLeadData.details!.length - 1]['assignto_name']}',
                  ),
                  _rowTwoText(
                    context: context,
                    title: 'Broker',
                    titleValue: salesLeadData.brokerName ?? '--',
                  ),
                  if (salesLeadData.flatName != '')
                    Container(
                      padding: const EdgeInsets.only(top: 10, left: 22),
                      width: MediaQuery.of(context).size.width - 120,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: Text(
                              'Flat Allocated',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          horizontalSpaceMedium,
                          const Center(
                              child: Icon(Icons.remove, color: Colors.black54)),
                          horizontalSpaceLarge,
                          Text(
                            salesLeadData.flatName ?? '',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          // if (isStatus)
                          salesLeadData.flatBuyerIdFk != ''
                              ? InkWell(
                                  onTap: () {
                                    var projectId = widget.projectId!;
                                    var projectName = widget.projectName!;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return BookingDetailsView(
                                            flat_buyer_id: salesLeadData
                                                .flatBuyerIdFk, // flatParking![i].buyerTenantId,
                                            // memberShipForm: widget.member_ship_form,
                                            projectId: widget.projectId,
                                            projectName: widget.projectName,
                                            towarId: widget.towarId,
                                            towarName: widget.towarName!,
                                            flatBuyerRequest:
                                                FlatBuyerRequest(),
                                            // flatAvailableListData
                                            //     .floorDetails!
                                            //     .flatDetails?[i]
                                            //     .flatBuyerDetails?[0],
                                            navigationFlag: 'SoldInventory',
                                            title: '',
                                            // inventryFlatName: flatAvailableListData
                                            //     .floorDetails!
                                            //     .flatDetails?[i]
                                            //     .inventryFlatName,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 28),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: Colors.black,
                                    ),
                                    child: Text(
                                      'View Details',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    ),
                                  ),
                                )
                              : const SizedBox()
                        ],
                      ),
                    ),
                ],
              ),
              const Icon(Icons.keyboard_arrow_right)
            ],
          )),
    );
  }

  Widget _rowTwoText({
    required BuildContext context,
    required String title,
    required String titleValue,
    bool isStatus = false,
    bool isTimerIcon = false,
    String? leadSourceSttus,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 22),
      width: MediaQuery.of(context).size.width - 120,
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          horizontalSpaceMedium,
          const Center(child: Icon(Icons.remove, color: Colors.black54)),
          horizontalSpaceLarge,
          if (isTimerIcon)
            Container(
                padding: const EdgeInsets.only(right: 10),
                child: const Icon(Icons.timer_outlined)),
          Text(
            titleValue,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          if (isStatus)
            _statusCapsule(
              context: context,
              title: leadSourceSttus ?? '',
              backgroundColor: const Color.fromARGB(255, 223, 205, 49),
            ),
        ],
      ),
    );
  }

  Widget _rowEmailContact({
    required BuildContext context,
    required String title,
    required String titleValue,
    required String icon,
    required String isVerified,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 22),
      width: MediaQuery.of(context).size.width - 120,
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          horizontalSpaceMedium,
          const Center(child: Icon(Icons.remove, color: Colors.black54)),
          horizontalSpaceLarge,
          InkWell(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.grey,
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    icon,
                    height: 20,
                    fit: BoxFit.fitWidth,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    titleValue,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10),
          if (isVerified == "1")
            Icon(
              Icons.check_circle_outline,
              color: Colors.blue,
            ),
        ],
      ),
    );
  }
}
