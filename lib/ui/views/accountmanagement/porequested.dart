import 'package:stallion/ui/views/accountmanagement/account_management_preview.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_document.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_network.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_project_wo_request.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/models/po_delivery_details.dart' as poDeliveryDetailss;
import 'package:stallion/models/sales_lead_filter.dart' as sales_lead_filter;
import 'package:stallion/models/sales_lead_filter.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/accountmanagement/chalan_Screen.dart';
import 'package:stallion/ui/views/accountmanagement/poassignedpreviewhtml.dart';
import 'package:stallion/ui/views/accountmanagement/podetails.dart';
import 'package:stallion/ui/views/accountmanagement/quote_pdf.dart';
import 'package:stallion/ui/views/accountmanagement/signature_dialog.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/get_po_details_by_status.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../../utils/responsive.dart';
import '../../shared/ui_helpers.dart';
import 'grnlistingview.dart';

// class PoRequestedView extends StatefulWidget {
//   const PoRequestedView(
//       {super.key,
//       this.projectId,
//       this.towarId,
//       this.projectName,
//       required this.assignToId,
//       this.towarName,
//       this.flagRedirect});

//   final String? projectId;
//   final String? towarId;
//   final String? projectName;
//   final String? flagRedirect;
//   final String assignToId;
//   final String? towarName;

//   @override
//   State<PoRequestedView> createState() => _PoRequestedViewState();
// }
class PoRequestedView extends StatefulWidget {
  const PoRequestedView({super.key});

  @override
  State<PoRequestedView> createState() => _PoRequestedViewState();
}

class _PoRequestedViewState extends State<PoRequestedView> {
  late NotificationArgs args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context)!.settings.arguments as NotificationArgs;
  }

  List<sales_lead_filter.FilterList>? filteredList = [];
  int filterListSelected = 0;
  String searchText = '';
  List<poDeliveryDetailss.OrderDetail>? orderDetails = [];
  String? deliveryQuantity = '';
  String? orderQuantity = '';

  TextEditingController searchController = TextEditingController();
  List<WoOrderList>? woOrderList = [];
  List<sales_lead_filter.FilterList>? filterListData = [];

  List<sales_lead_filter.Detail>? filteredProjects() {
    if (searchText.isEmpty) {
      return filterListData![filterListSelected].details;
    }
    return filterListData![filterListSelected].details!.where((project) {
      return project.name!.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
  }

  Future<FilterList?> getLeadFilter() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": args.projectId!,
      "towar_id": args.response?.towarId ?? '',
      "status_supply": "0",
      "po_status": args.response?.flagRedirect == 'Assigned' ? "0" : "2",
    };
    var response = await apiNetworkHandler.post(AppUrl.wsPoFilter, data);

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

  Future<List<poDeliveryDetailss.OrderDetail>?> getOrderDetails(
      {required String orderId}) async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));
    Map<String, String> data = {
      "user_id": userId!,
      "order_id": orderId,
    };
    var response =
        await apiNetworkHandler.post(AppUrl.wsPoDeliveryDetails, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel =
          poDeliveryDetailss.poDeliveryDetailsFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          orderDetails = dataModel.response?.orderDetails;
          deliveryQuantity = dataModel.response?.deliveryQuantity;
          orderQuantity = dataModel.response?.orderQuantity;
          // filterListData = dataModel.response?.filterList;
        });
      }
    }
    return orderDetails;
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = AccountManagementPreviewNetwork();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<String> venderSelectListFilter = [
    "All PO",
    "Pending Invoices",
    "Uploaded Invoices"
  ];

  int isSelectedVenderList = 0;
  bool flagcalled = false;
  bool norecord = false;
  DateTime? _selectedToDate;
  DateTime? _selectedFormDate;
  TextEditingController fromDateControler = TextEditingController();
  TextEditingController toDateControler = TextEditingController();

  List<RccBookingHistory>? rccBookingHistory = [];
  List<VenderListPO>? venderListRes = [];
  VenderListPO? selecetdVenderListPO;
  String? offset = '0';
  String searchTermValue = '';
  TextEditingController editingController = TextEditingController();
  TextEditingController editingVendorNameController = TextEditingController();
  String? handSignUrl = '';

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

  Future<ResponseGetPoDetailsByStatus?> fetchProjectPoRequested() async {
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
    if (args.response?.flagRedirect == "Verified") {
      status = '0';
    } else if (args.response?.flagRedirect == "Assigned") {
      status = '1';
    } else if (args.response?.flagRedirect == "Issued") {
      status = '2';
    }

    // String towerId = "";
    // if (widget.towarId != null) {
    //   towerId = widget.towarId!;
    // }

    Map<String, String> data = {
      "user_type": (prefs.getString('userType') ??
              (useAccountManagementTestData ? '1' : null)) ??
          '',
      "user_id": userId!,
      "project_id": args.projectId!,
      "towar_id": args.response?.towarId ?? '',
      "po_status": status,
      "limit": "20",
      "offset": offset!,
      "search_data": searchTermValue,
      "login_type": loginType!,
      "start_date":
          _selectedFormDate == null ? '' : formatDate(_selectedFormDate!),
      "end_date": _selectedToDate == null ? '' : formatDate(_selectedToDate!),
      "vender_id": selecetdVenderListPO?.venderId ?? '',
      "invoice_status": isSelectedVenderList == 1
          ? "0"
          : isSelectedVenderList == 2
              ? "1"
              : "",
      "fliterlist": jsonEncode(filteredList),
      "assign_to_id": args.response?.assignToId ?? '',
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.wspodetailsbystatus, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getPoDetailsByStatusFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          // authorizeFlag = dataModel.response?.authorizeFlag;
          handSignUrl = dataModel.response?.handSignUrl;

          offset = dataModel.response?.offset;
          venderListRes = dataModel.response?.venderList;
          if (rccBookingHistory?.length == 0) {
            rccBookingHistory = dataModel.response?.rccBookingHistory;
          } else {
            rccBookingHistory = [
              ...?rccBookingHistory,
              ...?dataModel.response!.rccBookingHistory
            ];
          }
          // if (searchTermValue.isEmpty) {
          //   offset = dataModel.response?.offset;
          // } else {
          //   offset = '0';
          //   rccBookingHistory = [];
          // }
          // setState(() {
          // List<RccBookingHistory>? rccBooking = [];
          // rccBooking = dataModel.response?.rccBookingHistory!;
          // });
          // if (dataModel.response?.rccBookingHistory!.length != 0 ||
          //     dataModel.response?.offset == "0") {
          //   // setState(() {
          //   rccBookingHistory = dataModel.response?.rccBookingHistory;
          //   // });
          // } else {
          //   for (int i = 0; i < rccBooking!.length; i++) {
          //     // setState(() {
          //     rccBookingHistory?.add(dataModel.response!.rccBookingHistory![i]);
          //     // });
          //   }
          // }
          // });

          if (rccBookingHistory!.isEmpty) {
            norecord = true;
          } else {
            norecord = false;
          }

          // setState(() {
          flagcalled = true;
          // rccBookingHistory!.length;
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
    rccBookingHistory = [];

    fetchProjectPoRequested();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));
    fetchProjectPoRequested();
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchProjectPoRequested();
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
        backgroundColor: const Color(0xfff8f9fa),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
              args.response?.flagRedirect == 'Verified'
                  ? '${args.projectName!.toUpperCase()} - PO REQUESTS'
                  : args.response?.flagRedirect == 'Assigned'
                      ? '${args.projectName!.toUpperCase()} - PO ASSIGNED'
                      : '${args.projectName!.toUpperCase()} - PO ISSUED',
              style: TextStyle(
                  fontSize: context.isMobile ? 14 : 17,
                  fontWeight: FontWeight.w600)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.maybePop(context);
            },
          ),
          actions: [
            // if (widget.flagRedirect! != 'Verified' &&
            //     widget.flagRedirect! != 'Assigned')
            if (args.response?.flagRedirect != 'Verified' &&
                args.response?.assignToId == '')
              InkWell(
                onTap: () {
                  searchController.clear();
                  setState(() {
                    searchText = '';
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
                                  borderRadius: BorderRadius.circular(16),
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

                                          for (sales_lead_filter
                                              .FilterList filter
                                              in filterListData!) {
                                            filter.ct = 0;
                                            for (sales_lead_filter.Detail detail
                                                in filter.details!) {
                                              setState1(() {
                                                detail.isSelected = false;
                                              });
                                            }
                                          }
                                          setState1(() {
                                            offset = '0';
                                            offset = '0';
                                            searchTermValue = '';
                                            rccBookingHistory = [];
                                            filteredList = [];
                                            searchTermValue = '';
                                            searchText = '';
                                            // rccBookingHistory = [];
                                          });

                                          filteredList = [];
                                          woOrderList = [];

                                          fetchProjectPoRequested();
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
                                          for (sales_lead_filter
                                              .FilterList filter
                                              in filterListData!) {
                                            List<sales_lead_filter.Detail>?
                                                details = [];
                                            for (sales_lead_filter.Detail detail
                                                in filter.details!) {
                                              if (detail.isSelected == true) {
                                                details.add(detail);
                                              }
                                            }
                                            // Add filtered details to the filteredList
                                            filteredList?.add(
                                                sales_lead_filter.FilterList(
                                              name: filter.name,
                                              id: filter.id,
                                              details: details,
                                            ));
                                          }
                                          setState1(() {
                                            offset = '0';
                                            searchTermValue = '';
                                            woOrderList = [];
                                            offset = '0';
                                            searchTermValue = '';
                                            rccBookingHistory = [];
                                          });
                                          fetchProjectPoRequested()
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
                                                                  // filterListData![
                                                                  //         filterListSelected]
                                                                  //     .details?[
                                                                  //         k]
                                                                  //     .isSelected = filteredProjects()?[k]
                                                                  //             .isSelected ==
                                                                  //         false
                                                                  //     ? true
                                                                  //     : false;

                                                                  filteredProjects()?[
                                                                              k]
                                                                          .isSelected =
                                                                      filteredProjects()?[k].isSelected ==
                                                                              true
                                                                          ? false
                                                                          : true;
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

            SizedBox(width: context.isMobile ? 12 : 24)
          ],
        ),
        body: Container(
            height: double.infinity,
            color: const Color(0xfff8f9fa),
            child: SafeArea(
              child:
                  // flagcalled == true
                  //     ?
                  Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  verticalSpaceSmall,
                  StartEndDateSelection(),
                  verticalSpaceSmall,
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: context.isMobile ? 12 : 40),
                    child: SizedBox(
                      height: 40,
                      child: TextFormField(
                        onChanged: (value) {
                          Future.delayed(const Duration(seconds: 1), () {
                            if (value.isNotEmpty) {
                              if (value.length > 2) {
                                rccBookingHistory = [];
                                offset = '0';
                                searchTermValue = value;
                                searchTermValue =
                                    searchTermValue.replaceAll("  ", " ");
                                searchTermValue = searchTermValue.trim();
                                fetchProjectPoRequested();
                              }
                            } else {
                              offset = '0';
                              searchTermValue = '';
                              rccBookingHistory = [];
                              editingController.clear();
                              editingVendorNameController.clear();
                              fetchProjectPoRequested();
                              FocusScope.of(context).requestFocus(FocusNode());
                            }
                          });
                        },
                        style: const TextStyle(fontSize: 13),
                        controller: editingController,
                        decoration: _poInputDecoration(
                            'Search by PO.No, Booking type or Vendor Name',
                            Icons.search_rounded,
                            trailing: false),
                      ),
                    ),
                  ),
                  if (args.response?.flagRedirect != 'Verified' &&
                      venderListRes?.length != 0)
                    const SizedBox(height: 20),
                  if (args.response?.flagRedirect != 'Verified' &&
                      venderListRes?.length != 0)
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: context.isMobile ? 12 : 40),
                      child: InkWell(
                        onTap: () {
                          selectFilterVenderModal();
                        },
                        child: SizedBox(
                          height: 40,
                          child: TextFormField(
                            style: const TextStyle(
                                color: Colors.black, fontSize: 13.0),
                            enabled: false,
                            readOnly: true,
                            controller: editingVendorNameController,
                            decoration: _poInputDecoration(
                                'Filter by Vendor Company Name',
                                Icons.keyboard_arrow_down_rounded,
                                trailing: true),
                          ),
                        ),
                      ),
                    ),
                  verticalSpaceSmall,
                  const Divider(
                    height: 0.5,
                    thickness: 0.5,
                    indent: 1,
                    endIndent: 1,
                    color: Colors.black,
                  ),
                  verticalSpaceSmall,
                  norecord == true
                      ? const Expanded(
                          child: Center(
                              child:
                                  Text('No Record Found', style: normalText)))
                      : Expanded(
                          child: SmartRefresher(
                            enablePullDown:
                                searchTermValue.isEmpty ? true : false,
                            enablePullUp:
                                searchTermValue.isEmpty ? true : false,
                            controller: _refreshController,
                            onRefresh:
                                searchTermValue.isEmpty ? _onRefresh : null,
                            onLoading:
                                searchTermValue.isEmpty ? _onLoading : null,
                            footer: const ClassicFooter(
                                loadStyle: LoadStyle.ShowWhenLoading),
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ListView.builder(
                              itemCount: rccBookingHistory?.length,
                              itemBuilder: (context, index) {
                                //var arrUploadImg = rccBookingHistory![index].uploadNoteImage!;
                                List<OrderDetail>? orderDetails =
                                    rccBookingHistory![index].orderDetails!;
                                double actualQty = 0.0;
                                double deliveredQty = 0.0;
                                String units = "";
                                String deliver = "";
                                String grades = "";
                                for (int i = 0; i < orderDetails.length; i++) {
                                  actualQty = double.parse(
                                      orderDetails[i].orderQuantity ?? '0');
                                  // deliveredQty = double.parse(
                                  //     orderDetails[i].deliveryQuantity ?? '0');
                                  inspect(orderDetails[i]);
                                  print(
                                      '${orderDetails[i].deliveryQuantity}----------------');
                                  if (i == 0) {
                                    units =
                                        '${actualQty.toStringAsFixed(2)} ${orderDetails[i].castingUnitName!}';
                                    deliver =
                                        '${deliveredQty.toStringAsFixed(2)} ${orderDetails[i].castingUnitName!}';
                                    grades = orderDetails[i].gradeTypeName!;
                                  } else {
                                    units =
                                        '$units, ${actualQty.toStringAsFixed(2)} ${orderDetails[i].castingUnitName!}';
                                    deliver =
                                        '$deliver, ${deliveredQty.toStringAsFixed(2)} ${orderDetails[i].castingUnitName!}';
                                    grades =
                                        '$grades, ${orderDetails[i].gradeTypeName!}';
                                  }
                                }
                                return InkWell(
                                  // onTap: () {
                                  //   var projectId =
                                  //       rccBookingHistory![index].projectIdFk!;
                                  //   var projectName =
                                  //       rccBookingHistory![index].projectName!;
                                  //   Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //       builder: (_) {
                                  //         return widget.flagRedirect! ==
                                  //                 'Verified'
                                  //             ? PoDetails(
                                  //                 projectId: projectId,
                                  //                 towarId:
                                  //                     rccBookingHistory![index]
                                  //                         .towar_id_fk!,
                                  //                 projectName: projectName,
                                  //                 poId: widget.flagRedirect!,
                                  //                 orderDetails:
                                  //                     rccBookingHistory![index])
                                  //             : widget.flagRedirect! ==
                                  //                     'Assigned'
                                  //                 ? PoAssignedPreviewHtml(
                                  //                     projectId: projectId,
                                  //                     projectName: projectName,
                                  //                     towarId:
                                  //                         rccBookingHistory![
                                  //                                 index]
                                  //                             .towar_id_fk!,
                                  //                     flagRedirect:
                                  //                         widget.flagRedirect!,
                                  //                     poOrderId:
                                  //                         rccBookingHistory![
                                  //                                 index]
                                  //                             .orderId!,
                                  //                     poOrderNo:
                                  //                         rccBookingHistory![
                                  //                                 index]
                                  //                             .poNo!,
                                  //                   )
                                  //                 : PoAssignedPreviewHtml(
                                  //                     projectId: projectId,
                                  //                     projectName: projectName,
                                  //                     towarId:
                                  //                         rccBookingHistory![
                                  //                                 index]
                                  //                             .towar_id_fk!,
                                  //                     flagRedirect:
                                  //                         widget.flagRedirect!,
                                  //                     poOrderId:
                                  //                         rccBookingHistory![
                                  //                                 index]
                                  //                             .orderId!,
                                  //                     poOrderNo:
                                  //                         rccBookingHistory![
                                  //                                 index]
                                  //                             .poNo!,
                                  //                   );
                                  //       },
                                  //     ),
                                  //   ).then((_) {
                                  //     setState(() {
                                  //       //   // Call setState to refresh the page.
                                  //       //   flagcalled = false;
                                  //       offset = '0';
                                  //       searchTermValue = '';
                                  //       woOrderList = [];
                                  //       searchTermValue = '';
                                  //       rccBookingHistory = [];
                                  //       //   searchTermValue = '';
                                  //       //   rccBookingHistory = [];
                                  //       //   fetchProjectPoRequested();
                                  //     });
                                  //     fetchProjectPoRequested();
                                  //     // This block runs when you have returned back to the 1st Page from 2nd.
                                  //   });
                                  // },

                                  onTap: () {
                                    if (rccBookingHistory![index]
                                            .arrPoDoc!
                                            .length ==
                                        1) {
                                      var projectId = rccBookingHistory![index]
                                          .projectIdFk!;
                                      var projectName =
                                          rccBookingHistory![index]
                                              .projectName!;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) {
                                            return args.response
                                                        ?.flagRedirect ==
                                                    'Verified'
                                                ? PoDetails(
                                                    projectId: projectId,
                                                    towarId: rccBookingHistory![
                                                            index]
                                                        .towar_id_fk!,
                                                    projectName: projectName,
                                                    poId: args.response
                                                        ?.flagRedirect!,
                                                    orderDetails:
                                                        rccBookingHistory![
                                                            index])
                                                : args.response?.flagRedirect ==
                                                        'Assigned'
                                                    ? PoAssignedPreviewHtml(
                                                        projectId: projectId,
                                                        projectName:
                                                            projectName,
                                                        towarId:
                                                            rccBookingHistory![
                                                                    index]
                                                                .towar_id_fk!,
                                                        flagRedirect: args
                                                            .response
                                                            ?.flagRedirect!,
                                                        poOrderId:
                                                            rccBookingHistory![
                                                                    index]
                                                                .orderId!,
                                                        poOrderNo:
                                                            rccBookingHistory![
                                                                    index]
                                                                .poNo!,
                                                        arrPoDoc:
                                                            rccBookingHistory![
                                                                    index]
                                                                .arrPoDoc?[0],
                                                      )
                                                    : PoAssignedPreviewHtml(
                                                        projectId: projectId,
                                                        projectName:
                                                            projectName,
                                                        towarId:
                                                            rccBookingHistory![
                                                                    index]
                                                                .towar_id_fk!,
                                                        flagRedirect: args
                                                                        .response
                                                                        ?.flagRedirect ==
                                                                    null ||
                                                                args.response
                                                                        ?.flagRedirect ==
                                                                    ''
                                                            ? ''
                                                            : args.response
                                                                    ?.flagRedirect ??
                                                                '',
                                                        poOrderId:
                                                            rccBookingHistory![
                                                                    index]
                                                                .orderId!,
                                                        poOrderNo:
                                                            rccBookingHistory![
                                                                    index]
                                                                .poNo!,
                                                        arrPoDoc:
                                                            rccBookingHistory![
                                                                    index]
                                                                .arrPoDoc?[0],
                                                      );
                                          },
                                        ),
                                      ).then((_) {
                                        setState(() {
                                          //   // Call setState to refresh the page.
                                          //   flagcalled = false;
                                          offset = '0';
                                          searchTermValue = '';
                                          woOrderList = [];
                                          searchTermValue = '';
                                          rccBookingHistory = [];
                                          //   searchTermValue = '';
                                          //   rccBookingHistory = [];
                                          //   fetchProjectPoRequested();
                                        });
                                        fetchProjectPoRequested();
                                        // This block runs when you have returned back to the 1st Page from 2nd.
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
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    titlePadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 0),
                                                    actionsPadding:
                                                        const EdgeInsets.only(
                                                            bottom: 0),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 0),
                                                    actionsAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    title: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 5),
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
                                                        "PURCHASE ORDER'S",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
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
                                                                style:
                                                                    TextStyle(
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
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.4,
                                                        child: Column(
                                                            children: [
                                                              for (int i = 0;
                                                                  i <
                                                                      rccBookingHistory![
                                                                              index]
                                                                          .arrPoDoc!
                                                                          .length;
                                                                  i++)
                                                                InkWell(
                                                                  onTap: () {
                                                                    if (i ==
                                                                        0) {
                                                                      var projectId =
                                                                          rccBookingHistory![index]
                                                                              .projectIdFk!;
                                                                      var projectName =
                                                                          rccBookingHistory![index]
                                                                              .projectName!;
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder:
                                                                              (_) {
                                                                            return args.response?.flagRedirect == 'Verified'
                                                                                ? PoDetails(projectId: projectId, towarId: rccBookingHistory![index].towar_id_fk!, projectName: projectName, poId: args.response?.flagRedirect!, orderDetails: rccBookingHistory![index])
                                                                                : args.response?.flagRedirect == 'Assigned'
                                                                                    ? PoAssignedPreviewHtml(projectId: projectId, projectName: projectName, towarId: rccBookingHistory![index].towar_id_fk!, flagRedirect: args.response?.flagRedirect!, poOrderId: rccBookingHistory![index].orderId!, poOrderNo: rccBookingHistory![index].poNo!, arrPoDoc: rccBookingHistory![index].arrPoDoc?[i])
                                                                                    : PoAssignedPreviewHtml(
                                                                                        projectId: projectId,
                                                                                        projectName: projectName,
                                                                                        towarId: rccBookingHistory![index].towar_id_fk!,
                                                                                        flagRedirect: args.response?.flagRedirect!,
                                                                                        poOrderId: rccBookingHistory![index].orderId!,
                                                                                        poOrderNo: rccBookingHistory![index].poNo!,
                                                                                        arrPoDoc: rccBookingHistory![index].arrPoDoc?[i],
                                                                                      );
                                                                          },
                                                                        ),
                                                                      ).then(
                                                                          (_) {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        Future.delayed(
                                                                            const Duration(seconds: 1),
                                                                            () {
                                                                          // setState(
                                                                          //     () {
                                                                          //   // Call setState to refresh the page.
                                                                          //   flagcalled = false;
                                                                          offset =
                                                                              '0';
                                                                          searchTermValue =
                                                                              '';
                                                                          woOrderList =
                                                                              [];
                                                                          searchTermValue =
                                                                              '';
                                                                          rccBookingHistory =
                                                                              [];
                                                                          //   searchTermValue = '';
                                                                          //   rccBookingHistory = [];
                                                                          //   fetchProjectPoRequested();
                                                                          // });
                                                                          fetchProjectPoRequested();
                                                                          // This block runs when you have returned back to the 1st Page from 2nd.
                                                                        });
                                                                      });
                                                                    } else {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder:
                                                                              (_) {
                                                                            return (useAccountManagementTestData
                                                                                ? const AccountManagementPreviewDocumentScreen()
                                                                                : PdfViewer(
                                                                                    fileName: rccBookingHistory![index].arrPoDoc?[i].fileName!,
                                                                                    fileUrl: rccBookingHistory![index].arrPoDoc?[i].filePath,
                                                                                    // AppUrl.globalPoinvoicePath +
                                                                                    //     invoiceData![index].invoiceImage!,
                                                                                  ));
                                                                          },
                                                                        ),
                                                                      );
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                            border:
                                                                                Border(bottom: BorderSide(color: Colors.black))),
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            24,
                                                                        vertical:
                                                                            8),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Container(
                                                                              decoration: const BoxDecoration(
                                                                                  border: Border(
                                                                                      bottom: BorderSide(
                                                                                color: Colors.blue,
                                                                              ))),
                                                                              child: Text(
                                                                                rccBookingHistory![index].arrPoDoc?[i].fileName ?? '',
                                                                                style: const TextStyle(
                                                                                  fontSize: 16,
                                                                                  fontWeight: FontWeight.w400,
                                                                                  color: Colors.blue,
                                                                                  // decoration: TextDecoration.underline,
                                                                                  // decorationColor: Colors.blue,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            // Text(
                                                                            //   '(${rccBookingHistory![index].arrPoDoc?[i].createdAt})',
                                                                            //   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black54),
                                                                            // )
                                                                          ],
                                                                        ),
                                                                        // Container(
                                                                        //   padding: const EdgeInsets
                                                                        //       .symmetric(
                                                                        //       horizontal: 20),
                                                                        //   decoration:
                                                                        //       BoxDecoration(
                                                                        //     borderRadius:
                                                                        //         BorderRadius.circular(8),
                                                                        //     border:
                                                                        //         Border.all(color: Colors.black),
                                                                        //   ),
                                                                        //   child:
                                                                        //       const Text(
                                                                        //     "View PO",
                                                                        //     style:
                                                                        //         TextStyle(
                                                                        //       fontSize: 16,
                                                                        //       fontWeight: FontWeight.w400,
                                                                        //     ),
                                                                        //   ),
                                                                        // )
                                                                        Text(
                                                                          '(${rccBookingHistory![index].arrPoDoc?[i].createdAt})',
                                                                          style: const TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: Colors.black54),
                                                                        )
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
                                  child: Container(
                                      margin: EdgeInsets.fromLTRB(
                                          context.isMobile ? 12 : 40,
                                          6,
                                          context.isMobile ? 12 : 40,
                                          10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                            color: const Color(0xffe9ecef)),
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Color(0x08000000),
                                              blurRadius: 8,
                                              offset: Offset(0, 2))
                                        ],
                                      ),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal:
                                                context.isMobile ? 12 : 20,
                                            vertical: 12),
                                        trailing: const Icon(
                                            Icons.chevron_right_rounded,
                                            color: Colors.black54),
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    left: context.isMobile
                                                        ? 0
                                                        : 12,
                                                    top: 8),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                context.isMobile
                                                                    ? 100
                                                                    : 180,
                                                            child: Text(
                                                                'P.O. No.',
                                                                style:
                                                                    _poBodyStyle),
                                                          ),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 6
                                                                  : 16),
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 8
                                                                  : 24),
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .poNo!,
                                                              style:
                                                                  _poStrongStyle),
                                                          horizontalSpaceSmall,
                                                          rccBookingHistory![
                                                                          index]
                                                                      .is_star_marked! ==
                                                                  '1'
                                                              ? const Icon(
                                                                  Icons.star,
                                                                  size: 15,
                                                                  color: Colors
                                                                      .red)
                                                              : const SizedBox(),
                                                          const Spacer(),
                                                          if (args.response
                                                                  ?.flagRedirect ==
                                                              'Issued')
                                                            InkWell(
                                                              onTap: () {
                                                                getOrderDetails(
                                                                        orderId:
                                                                            rccBookingHistory![index].orderId ??
                                                                                '')
                                                                    .then(
                                                                  (value) =>
                                                                      viewDelQty(),
                                                                );
                                                              },
                                                              child: Container(
                                                                width: 108,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            4),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .black),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child:
                                                                    const Text(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  "Del. Qty.",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                context.isMobile
                                                                    ? 100
                                                                    : 180,
                                                            child: Text(
                                                                'P.O. Created Date',
                                                                style:
                                                                    _poBodyStyle),
                                                          ),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 6
                                                                  : 16),
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 8
                                                                  : 24),
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .poCreatedAt!,
                                                              style:
                                                                  _poBodyStyle),
                                                          const Spacer(),
                                                          rccBookingHistory![
                                                                          index]
                                                                      .grn_active ==
                                                                  '1'
                                                              ? InkWell(
                                                                  onTap: () {
                                                                    var projectId =
                                                                        args.projectId!;
                                                                    var projectName =
                                                                        args.projectName!;
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (_) {
                                                                          return GrnListingView(
                                                                              projectId: projectId,
                                                                              towarId: args.response?.towarId,
                                                                              projectName: projectName,
                                                                              orderId: rccBookingHistory![index].orderId!);
                                                                        },
                                                                      ),
                                                                    );
                                                                  },
                                                                  child: Container(
                                                                      width: 108,
                                                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                                                      decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.black),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                      ),
                                                                      child: const Text(
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        'View GRN',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w400),
                                                                      )),
                                                                )
                                                              : const SizedBox(),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        // mainAxisAlignment:
                                                        //     MainAxisAlignment
                                                        //         .spaceBetween,
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                context.isMobile
                                                                    ? 100
                                                                    : 180,
                                                            child: Text(
                                                                'Requirement Date',
                                                                style:
                                                                    _poBodyStyle),
                                                          ),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 6
                                                                  : 16),
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 8
                                                                  : 24),
                                                          Text(
                                                              DateFormat('dd MMM yyyy').format(DateFormat(
                                                                      'dd-MM-yyyy')
                                                                  .parse(rccBookingHistory![
                                                                          index]
                                                                      .castingDate!
                                                                      .toString())),
                                                              style:
                                                                  _poBodyStyle),
                                                          const Spacer(),
                                                          if (args.response
                                                                  ?.flagRedirect ==
                                                              'Issued')
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (_) {
                                                                      return ChalanScreen(
                                                                        orderId:
                                                                            rccBookingHistory![index].orderId,
                                                                        projectId:
                                                                            args.projectId,
                                                                        towarId: args
                                                                            .response
                                                                            ?.towarId,
                                                                        projectName:
                                                                            args.projectName,
                                                                        towarName:
                                                                            args.towarName,
                                                                      );
                                                                    },
                                                                  ),
                                                                );
                                                              },
                                                              child: Container(
                                                                  width: 108,
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          4),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .black),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  child:
                                                                      const Text(
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    'View Challan',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  )),
                                                            ),
                                                        ],
                                                      ),
                                                    ),

                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                width: context
                                                                        .isMobile
                                                                    ? 100
                                                                    : 180,
                                                                child: Text(
                                                                    'P.O. Status',
                                                                    style:
                                                                        _poBodyStyle),
                                                              ),
                                                              SizedBox(
                                                                  width: context
                                                                          .isMobile
                                                                      ? 6
                                                                      : 16),
                                                              const Center(
                                                                  child: Icon(
                                                                      Icons
                                                                          .remove,
                                                                      color: Colors
                                                                          .black54)),
                                                              SizedBox(
                                                                  width: context
                                                                          .isMobile
                                                                      ? 8
                                                                      : 24),
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: rccBookingHistory![index].poStatus! ==
                                                                              '0'
                                                                          ? const Color
                                                                              .fromRGBO(
                                                                              255,
                                                                              214,
                                                                              51,
                                                                              1.0)
                                                                          : rccBookingHistory![index].poStatus! == '1'
                                                                              ? const Color.fromRGBO(255, 214, 51, 1.0)
                                                                              : rccBookingHistory![index].poStatus! == '2'
                                                                                  ? const Color.fromRGBO(0, 128, 43, 1.0) //green
                                                                                  : const Color.fromRGBO(255, 214, 51, 1.0), //yellow
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets.only(
                                                                          left:
                                                                              15.0,
                                                                          right:
                                                                              15.0,
                                                                          top:
                                                                              5.0,
                                                                          bottom:
                                                                              5.0),
                                                                      child: Text(
                                                                          rccBookingHistory![index].poStatus! == '0'
                                                                              ? 'Pending'
                                                                              : rccBookingHistory![index].poStatus! == '1'
                                                                                  ? rccBookingHistory![index].reApprovedReson! != ""
                                                                                      ? 'Re-Assigned'
                                                                                      : 'Assigned'
                                                                                  : rccBookingHistory![index].poStatus! == '2'
                                                                                      ? rccBookingHistory![index].reApprovedReson! != ""
                                                                                          ? 'Re-Issued'
                                                                                          : 'Issued'
                                                                                      : rccBookingHistory![index].poStatus! == '3'
                                                                                          ? 'Dispute'
                                                                                          : '---',
                                                                          style: rccBookingHistory![index].poStatus! == '0'
                                                                              ? _poBodyStyle
                                                                              : rccBookingHistory![index].poStatus! == '1'
                                                                                  ? _poBodyStyle
                                                                                  : const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.white)),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  width: context
                                                                          .isMobile
                                                                      ? 6
                                                                      : 16),
                                                              // rccBookingHistory![index].poStatus! == '2'
                                                              //                         ? rccBookingHistory![index].reApprovedReson! != ""
                                                              //                             ? 'Re-Issued'
                                                              //                             : 'Issued'
                                                              // rccBookingHistory![
                                                              //                 index]
                                                              //             .reApprovedReson! !=
                                                              //         ""
                                                              //     ?
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    left: 15.0,
                                                                    right: 15.0,
                                                                    top: 5.0,
                                                                    bottom:
                                                                        5.0),
                                                                child: Text(
                                                                  // rccBookingHistory![index]
                                                                  //             .poStatus! ==
                                                                  //         '0'
                                                                  //     ? ''
                                                                  //     : rccBookingHistory![index].poStatus! ==
                                                                  //             '1'
                                                                  //         ? rccBookingHistory![index].reApprovedReson! !=
                                                                  //                 ""
                                                                  //             ? '( ${DateFormat('dd MMM yyyy').format(DateFormat('dd-MM-yyyy').parse(rccBookingHistory![index].reApprovedDate!.toString()))} )'
                                                                  //             : '(${rccBookingHistory![index].poSignDate})'
                                                                  //         : rccBookingHistory![index].poStatus! ==
                                                                  //                 '2'
                                                                  //             ? rccBookingHistory![index].reApprovedReson! != ""
                                                                  //                 ? ''
                                                                  //                 : ''
                                                                  //             : rccBookingHistory![index].poStatus! == '3'
                                                                  //                 ? ''
                                                                  //                 : '',
                                                                  rccBookingHistory![index]
                                                                              .poStatus! ==
                                                                          '0'
                                                                      ? ''
                                                                      : rccBookingHistory![index].poStatus! ==
                                                                              '1'
                                                                          ? rccBookingHistory![index].reApprovedReson! != ""
                                                                              ? '(${rccBookingHistory![index].reApprovedDate})'
                                                                              : '(${rccBookingHistory![index].poAssingDate})'
                                                                          : rccBookingHistory![index].poStatus! == '2'
                                                                              ? rccBookingHistory![index].reApprovedReson! != ""
                                                                                  ? '(${rccBookingHistory![index].poSignDate})'
                                                                                  : ''
                                                                              : rccBookingHistory![index].poStatus! == '3'
                                                                                  ? ''
                                                                                  : '',
                                                                  // '( ${DateFormat('dd MMM yyyy').format(DateFormat('dd-MM-yyyy').parse(rccBookingHistory![index].reApprovedDate!.toString()))} )',
                                                                ),
                                                              ),
                                                              // :
                                                              // Text(
                                                              //     '  (${rccBookingHistory![index].poSignDate})',
                                                              //     style:
                                                              //         _poStrongStyle),
                                                              const SizedBox(),
                                                              rccBookingHistory![
                                                                              index]
                                                                          .poStatus! ==
                                                                      '0'
                                                                  ? rccBookingHistory![index]
                                                                              .poRequsition! ==
                                                                          '1'
                                                                      ? const Padding(
                                                                          padding: EdgeInsets.only(
                                                                              left: 15.0,
                                                                              right: 15.0,
                                                                              top: 5.0,
                                                                              bottom: 5.0),
                                                                          child: Text(
                                                                              '(Waiting For Quote)',
                                                                              style: _poStrongStyle),
                                                                        )
                                                                      : const SizedBox()
                                                                  : const SizedBox(),
                                                              if (rccBookingHistory![
                                                                              index]
                                                                          .poRequsition ==
                                                                      '2'
                                                                  //      &&
                                                                  // widget.flagRedirect ==
                                                                  //     'Verified'
                                                                  )
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(builder:
                                                                            (_) {
                                                                      return QuotePdf(
                                                                        projectId: args
                                                                            .response
                                                                            ?.projectId,
                                                                        towarId: args
                                                                            .response
                                                                            ?.towarId,
                                                                        projectName:
                                                                            args.projectName,
                                                                        towarName:
                                                                            args.towarName,
                                                                        orderId:
                                                                            rccBookingHistory![index].orderId,
                                                                      );
                                                                    }));
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                            border:
                                                                                Border(bottom: BorderSide(color: Colors.blue))),
                                                                    child:
                                                                        const Text(
                                                                      '(Quote Received)',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight: FontWeight
                                                                              .w600,
                                                                          color: Colors
                                                                              .blue,
                                                                          height:
                                                                              1.5 // decoration:
                                                                          //     TextDecoration
                                                                          //         .underline,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                          if (rccBookingHistory![
                                                                      index]
                                                                  .poDocument
                                                                  ?.length !=
                                                              0)
                                                            InkWell(
                                                              onTap: () {
                                                                viewDocs(
                                                                    poDocument:
                                                                        rccBookingHistory![index]
                                                                            .poDocument);
                                                              },
                                                              child: Container(
                                                                width: 108,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            4),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .black),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child:
                                                                    const Text(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  "View Doc.",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),

                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                context.isMobile
                                                                    ? 100
                                                                    : 180,
                                                            child: Text(
                                                                'Requested By',
                                                                style:
                                                                    _poBodyStyle),
                                                          ),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 6
                                                                  : 16),
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 8
                                                                  : 24),
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .raisedBy!,
                                                              style:
                                                                  _poBodyStyle),
                                                          const Spacer(),
                                                          // if (((rccBookingHistory![
                                                          //                     index]
                                                          //                 .poHandSignImg)
                                                          //             ?.trim() !=
                                                          //         "") &&
                                                          //     rccBookingHistory![
                                                          //                 index]
                                                          //             .authorizeFlag ==
                                                          //         '1')
                                                          if ((args.response
                                                                          ?.flagRedirect ==
                                                                      "Assigned" ||
                                                                  args.response
                                                                          ?.flagRedirect ==
                                                                      "Issued") &&
                                                              rccBookingHistory![
                                                                          index]
                                                                      .authorizeFlag ==
                                                                  '1' &&
                                                              rccBookingHistory![
                                                                          index]
                                                                      .poHandSignImg
                                                                      ?.trim() !=
                                                                  "")
                                                            const Icon(
                                                              Icons
                                                                  .check_circle_outline,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          const SizedBox(
                                                              width: 10),
                                                          if ((args.response
                                                                          ?.flagRedirect ==
                                                                      "Assigned" ||
                                                                  args.response
                                                                          ?.flagRedirect ==
                                                                      "Issued") &&
                                                              rccBookingHistory![
                                                                          index]
                                                                      .authorizeFlag ==
                                                                  '1')
                                                            InkWell(
                                                              onTap: () async {
                                                                // if ((rccBookingHistory![
                                                                //                 index]
                                                                //             .poHandSignImg)
                                                                //         ?.trim() ==
                                                                //     "") {
                                                                final result =
                                                                    await showDialog(
                                                                        context:
                                                                            context,
                                                                        builder: (context) =>
                                                                            SignatureDialog(
                                                                              // onTap:
                                                                              //     () {
                                                                              //   fetchProjectPoRequested();
                                                                              // },
                                                                              flagRedirect: args.response?.flagRedirect,
                                                                              projectId: (args.response?.projectId?.trim() == '' || args.response?.projectId == null) ? rccBookingHistory![index].projectIdFk : args.response?.projectId,
                                                                              towarId: (args.response?.towarId?.trim() == '' || args.response?.towarId == null) ? rccBookingHistory![index].towarIdFk : args.response?.towarId,
                                                                              towarName: args.towarName ?? '',
                                                                              projectName: args.projectName ?? '',
                                                                              orderId: rccBookingHistory![index].orderId,
                                                                              handSignUrl: rccBookingHistory![index].poHandSignImg?.trim() != '' ? '$handSignUrl/${rccBookingHistory![index].poHandSignImg}' : '',
                                                                            )).then(
                                                                        (value) {
                                                                  // Navigator.of(
                                                                  //         context)
                                                                  //     .pop();
                                                                  setState(() {
                                                                    //   // Call setState to refresh the page.
                                                                    //   flagcalled = false;
                                                                    offset =
                                                                        '0';
                                                                    searchTermValue =
                                                                        '';
                                                                    woOrderList =
                                                                        [];
                                                                    searchTermValue =
                                                                        '';
                                                                    rccBookingHistory =
                                                                        [];
                                                                    //   searchTermValue = '';
                                                                    //   rccBookingHistory = [];
                                                                    //   fetchProjectPoRequested();
                                                                  });
                                                                  fetchProjectPoRequested();
                                                                });

                                                                // if (result != null &&
                                                                //     result
                                                                //         is Uint8List) {
                                                                //   // Handle the returned image bytes
                                                                //   print(
                                                                //       "Signature received!");
                                                                // }
                                                                // }
                                                              },
                                                              child: Container(
                                                                width: 106,
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        0,
                                                                    vertical:
                                                                        4),
                                                                decoration:
                                                                    BoxDecoration(
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
                                                                child: Text(
                                                                  // (rccBookingHistory![index]
                                                                  //                 .poHandSignImg)
                                                                  //             ?.trim() !=
                                                                  //         ""
                                                                  //     ? "Signed"
                                                                  //     :
                                                                  "E-Sign",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color:
                                                                        //  (rccBookingHistory![index].poHandSignImg)
                                                                        //             ?.trim() !=
                                                                        //         ""
                                                                        //     ? Colors
                                                                        //         .grey
                                                                        //     :
                                                                        Colors
                                                                            .black,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                context.isMobile
                                                                    ? 100
                                                                    : 180,
                                                            child: Text(
                                                                'Verified By',
                                                                style:
                                                                    _poBodyStyle),
                                                          ),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 6
                                                                  : 16),
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 8
                                                                  : 24),
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: rccBookingHistory![
                                                                              index]
                                                                          .poApproveBy! !=
                                                                      ''
                                                                  ? const Color
                                                                      .fromRGBO(
                                                                      0,
                                                                      122,
                                                                      204,
                                                                      1.0)
                                                                  : rccBookingHistory![index]
                                                                              .poApproveBy! !=
                                                                          '---'
                                                                      ? const Color
                                                                          .fromRGBO(
                                                                          0,
                                                                          122,
                                                                          204,
                                                                          1.0)
                                                                      : null,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          15.0,
                                                                      right:
                                                                          15.0,
                                                                      top: 5.0,
                                                                      bottom:
                                                                          5.0),
                                                                  child: Text(
                                                                      rccBookingHistory![
                                                                              index]
                                                                          .poApproveBy!,
                                                                      style: rccBookingHistory![index].poApproveBy! !=
                                                                              ''
                                                                          ? const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 14.0,
                                                                              color: Colors.white)
                                                                          : rccBookingHistory![index].poApproveBy! != '---'
                                                                              ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.white)
                                                                              : _poStrongStyle),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          if (rccBookingHistory![
                                                                          index]
                                                                      .poApproveBy !=
                                                                  '--' &&
                                                              rccBookingHistory![
                                                                          index]
                                                                      .poSignDate !=
                                                                  '30th Nov -0001')
                                                            Text(
                                                              '  (${rccBookingHistory![index].poVerifyDate})',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                              ),
                                                            )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                context.isMobile
                                                                    ? 100
                                                                    : 180,
                                                            child: Text(
                                                                'Assign To',
                                                                style:
                                                                    _poBodyStyle),
                                                          ),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 6
                                                                  : 16),
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 8
                                                                  : 24),
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .poAssingToName!,
                                                              style:
                                                                  _poBodyStyle),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                context.isMobile
                                                                    ? 100
                                                                    : 180,
                                                            child: Text(
                                                                'Requirement For',
                                                                style:
                                                                    _poBodyStyle),
                                                          ),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 6
                                                                  : 16),
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 8
                                                                  : 24),
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .slabName!,
                                                              style:
                                                                  _poBodyStyle),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                context.isMobile
                                                                    ? 100
                                                                    : 180,
                                                            child: Text(
                                                                'Booking Type',
                                                                style:
                                                                    _poBodyStyle),
                                                          ),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 6
                                                                  : 16),
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 8
                                                                  : 24),
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .gradeName!,
                                                              style:
                                                                  _poBodyStyle),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                context.isMobile
                                                                    ? 100
                                                                    : 180,
                                                            child: Text(
                                                                'Vendor Name',
                                                                style:
                                                                    _poBodyStyle),
                                                          ),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 6
                                                                  : 16),
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 8
                                                                  : 24),
                                                          Text(
                                                              rccBookingHistory![
                                                                              index]
                                                                          .venderName! !=
                                                                      ''
                                                                  ? rccBookingHistory![
                                                                          index]
                                                                      .venderName!
                                                                  : '--',
                                                              style:
                                                                  _poStrongStyle),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                context.isMobile
                                                                    ? 100
                                                                    : 180,
                                                            child: Text(
                                                                'Project Name',
                                                                style:
                                                                    _poBodyStyle),
                                                          ),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 6
                                                                  : 16),
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 8
                                                                  : 24),
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .projectName!,
                                                              style:
                                                                  _poBodyStyle),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                context.isMobile
                                                                    ? 100
                                                                    : 180,
                                                            child: Text(
                                                                'Delivery Status',
                                                                style:
                                                                    _poBodyStyle),
                                                          ),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 6
                                                                  : 16),
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 8
                                                                  : 24),
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: rccBookingHistory![index]
                                                                          .orderStatus! ==
                                                                      '0'
                                                                  ? const Color
                                                                      .fromRGBO(
                                                                      255,
                                                                      214,
                                                                      51,
                                                                      1.0)
                                                                  : rccBookingHistory![index].orderStatus! ==
                                                                              '1' ||
                                                                          rccBookingHistory![index]
                                                                                  .orderStatus! ==
                                                                              '4'
                                                                      ? const Color.fromRGBO(
                                                                          255,
                                                                          214,
                                                                          51,
                                                                          1.0)
                                                                      : rccBookingHistory![index].orderStatus! ==
                                                                              '2'
                                                                          ? const Color.fromRGBO(
                                                                              0,
                                                                              128,
                                                                              43,
                                                                              1.0)
                                                                          : Colors
                                                                              .transparent,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                  rccBookingHistory![index]
                                                                              .orderStatus! ==
                                                                          '0'
                                                                      ? 'Order Pending'
                                                                      : rccBookingHistory![index].orderStatus! ==
                                                                              '1'
                                                                          ? 'Order Processed'
                                                                          : rccBookingHistory![index].orderStatus! ==
                                                                                  '2'
                                                                              ? 'Order Delivered'
                                                                              : rccBookingHistory![index].orderStatus! ==
                                                                                      '4'
                                                                                  ? 'Partially Delivered'
                                                                                  : 'Order Cancelled',
                                                                  style: rccBookingHistory![index]
                                                                              .orderStatus! ==
                                                                          '0'
                                                                      ? _poStrongStyle
                                                                      : rccBookingHistory![index].orderStatus! == '1' ||
                                                                              rccBookingHistory![index].orderStatus! ==
                                                                                  '4'
                                                                          ? const TextStyle(
                                                                              fontWeight: FontWeight
                                                                                  .bold,
                                                                              fontSize:
                                                                                  14.0,
                                                                              color: Colors
                                                                                  .black)
                                                                          : const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 14.0,
                                                                              color: Colors.white)),
                                                            ),
                                                          ),
                                                          horizontalSpaceSmall,
                                                          Text(
                                                            rccBookingHistory![
                                                                            index]
                                                                        .orderStatus! ==
                                                                    '2'
                                                                ? '( ${rccBookingHistory![index].orderDeliverDate!.toString()} )'
                                                                : '',
                                                            style: _poBodyStyle,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (rccBookingHistory![
                                                                index]
                                                            .projectDelivered !=
                                                        '')
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 10.0),
                                                        child: Row(
                                                          children: [
                                                            SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 100
                                                                  : 180,
                                                              child: Text(
                                                                  'Delivered To',
                                                                  style:
                                                                      _poBodyStyle),
                                                            ),
                                                            SizedBox(
                                                                width: context
                                                                        .isMobile
                                                                    ? 6
                                                                    : 16),
                                                            const Center(
                                                                child: Icon(
                                                                    Icons
                                                                        .remove,
                                                                    color: Colors
                                                                        .black54)),
                                                            SizedBox(
                                                                width: context
                                                                        .isMobile
                                                                    ? 8
                                                                    : 24),
                                                            Text(
                                                                rccBookingHistory![
                                                                            index]
                                                                        .projectDelivered ??
                                                                    '',
                                                                style:
                                                                    _poBodyStyle),
                                                          ],
                                                        ),
                                                      ),

                                                    if (rccBookingHistory![
                                                                index]
                                                            .poCheckedBy !=
                                                        '')
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 10.0),
                                                        child: Row(
                                                          children: [
                                                            SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 100
                                                                  : 180,
                                                              child: Text(
                                                                  'Checked By',
                                                                  style:
                                                                      _poBodyStyle),
                                                            ),
                                                            SizedBox(
                                                                width: context
                                                                        .isMobile
                                                                    ? 6
                                                                    : 16),
                                                            const Center(
                                                                child: Icon(
                                                                    Icons
                                                                        .remove,
                                                                    color: Colors
                                                                        .black54)),
                                                            SizedBox(
                                                                width: context
                                                                        .isMobile
                                                                    ? 8
                                                                    : 24),
                                                            Text(
                                                                rccBookingHistory![
                                                                            index]
                                                                        .poCheckedBy ??
                                                                    '',
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16.0,
                                                                    color: Colors
                                                                        .black)),
                                                            if (rccBookingHistory![
                                                                        index]
                                                                    .poCheckedByDate !=
                                                                '')
                                                              Text(
                                                                '  (${rccBookingHistory![index].poCheckedByDate})',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                ),
                                                              )
                                                          ],
                                                        ),
                                                      ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                context.isMobile
                                                                    ? 100
                                                                    : 180,
                                                            child: Text(
                                                                'Received By',
                                                                style:
                                                                    _poBodyStyle),
                                                          ),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 6
                                                                  : 16),
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 8
                                                                  : 24),
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .checkedBy!,
                                                              style:
                                                                  _poBodyStyle),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                context.isMobile
                                                                    ? 100
                                                                    : 180,
                                                            child: Text(
                                                                'PO Quantity',
                                                                style:
                                                                    _poBodyStyle),
                                                          ),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 6
                                                                  : 16),
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 8
                                                                  : 24),
                                                          Expanded(
                                                            child: Text(units,
                                                                style:
                                                                    _poBodyStyle),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Padding(
                                                    //   padding:
                                                    //       const EdgeInsets.only(
                                                    //           bottom: 10.0),
                                                    //   child: Row(
                                                    //     children: [
                                                    //       const SizedBox(
                                                    //         width: 200,
                                                    //         child: Text(
                                                    //             'Delivered Quantity',
                                                    //             style: _poBodyStyle),
                                                    //       ),
                                                    //       SizedBox(width: context.isMobile ? 6 : 16),
                                                    //       const Center(
                                                    //           child: Icon(
                                                    //               Icons.remove,
                                                    //               color: Colors
                                                    //                   .black54)),
                                                    //       SizedBox(width: context.isMobile ? 8 : 24),
                                                    //       Text(deliver,
                                                    //           style: _poBodyStyle),
                                                    //     ],
                                                    //   ),
                                                    // ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                context.isMobile
                                                                    ? 100
                                                                    : 180,
                                                            child: Text(
                                                                'Grades',
                                                                style:
                                                                    _poBodyStyle),
                                                          ),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 6
                                                                  : 16),
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          SizedBox(
                                                              width: context
                                                                      .isMobile
                                                                  ? 8
                                                                  : 24),
                                                          Flexible(
                                                            child: Text(grades,
                                                                style:
                                                                    _poBodyStyle),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    rccBookingHistory![index]
                                                                .poStatus! ==
                                                            '1'
                                                        ? rccBookingHistory![
                                                                        index]
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
                                                                    SizedBox(
                                                                      width: context
                                                                              .isMobile
                                                                          ? 100
                                                                          : 180,
                                                                      child: Text(
                                                                          'Re-Approval Reason',
                                                                          style:
                                                                              _poBodyStyle),
                                                                    ),
                                                                    SizedBox(
                                                                        width: context.isMobile
                                                                            ? 6
                                                                            : 16),
                                                                    const Center(
                                                                        child: Icon(
                                                                            Icons
                                                                                .remove,
                                                                            color:
                                                                                Colors.black54)),
                                                                    SizedBox(
                                                                        width: context.isMobile
                                                                            ? 8
                                                                            : 24),
                                                                    Flexible(
                                                                      child: Text(
                                                                          rccBookingHistory![index]
                                                                              .reApprovedReson!,
                                                                          style:
                                                                              _poBodyStyle),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            : const SizedBox()
                                                        : rccBookingHistory![
                                                                        index]
                                                                    .poStatus! ==
                                                                '2'
                                                            ? rccBookingHistory![
                                                                            index]
                                                                        .reApprovedReson! !=
                                                                    ""
                                                                ? Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10.0),
                                                                    child: Row(
                                                                      children: [
                                                                        SizedBox(
                                                                          width: context.isMobile
                                                                              ? 100
                                                                              : 180,
                                                                          child: Text(
                                                                              'Re-Issued For',
                                                                              style: _poBodyStyle),
                                                                        ),
                                                                        SizedBox(
                                                                            width: context.isMobile
                                                                                ? 6
                                                                                : 16),
                                                                        const Center(
                                                                            child:
                                                                                Icon(Icons.remove, color: Colors.black54)),
                                                                        SizedBox(
                                                                            width: context.isMobile
                                                                                ? 8
                                                                                : 24),
                                                                        Flexible(
                                                                          child: Text(
                                                                              rccBookingHistory![index].reApprovedReson!,
                                                                              style: _poBodyStyle),
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
                                      )),
                                );
                              },
                            ),
                          ),
                        ),
                ],
              ),
            )
            // : const Center(child: CircularProgressIndicator())),
            ));
  }

  static const _poBodyStyle = TextStyle(
      fontFamily: 'HelveticaNeue', fontSize: 14, color: Colors.black87);
  static const _poStrongStyle = TextStyle(
      fontFamily: 'HelveticaNeue',
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: Colors.black);

  InputDecoration _poInputDecoration(String hint, IconData icon,
      {bool trailing = false}) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xffe0e0e0)),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
          fontFamily: 'HelveticaNeue', fontSize: 13, color: Colors.black54),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      prefixIcon: trailing ? null : Icon(icon, size: 20, color: Colors.black54),
      suffixIcon: trailing ? Icon(icon, size: 20, color: Colors.black54) : null,
      border: border,
      enabledBorder: border,
      disabledBorder: border,
      focusedBorder:
          border.copyWith(borderSide: const BorderSide(color: Colors.black)),
    );
  }

  Widget StartEndDateSelection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.isMobile ? 12 : 40),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
            width: (MediaQuery.of(context).size.width -
                    (context.isMobile ? 24 : 80))
                .clamp(680.0, double.infinity)
                .toDouble(),
            child: Form(
              key: _formKey,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 0),
                  // if (widget.flagRedirect! != 'Verified')
                  //   InkWell(
                  //     onTap: () {
                  //       searchController.clear();
                  //       setState(() {
                  //         searchText = '';
                  //       });
                  //       showDialog(
                  //           context: context,
                  //           builder: (context) {
                  //             return StatefulBuilder(
                  //               builder: (context, setState1) {
                  //                 return AlertDialog(
                  //                     elevation: 0,
                  //                     shadowColor: Colors.white,
                  //                     shape: RoundedRectangleBorder(
                  //                       borderRadius: BorderRadius.circular(
                  //                           8), // Set radius to zero
                  //                     ),
                  //                     titlePadding:
                  //                         const EdgeInsets.symmetric(vertical: 0),
                  //                     actionsPadding:
                  //                         const EdgeInsets.only(bottom: 0),
                  //                     contentPadding:
                  //                         const EdgeInsets.symmetric(horizontal: 0),
                  //                     actionsAlignment: MainAxisAlignment.center,
                  //                     title: Container(
                  //                       padding:
                  //                           const EdgeInsets.symmetric(vertical: 5),
                  //                       decoration: const BoxDecoration(
                  //                           color: Colors.black,
                  //                           borderRadius: BorderRadius.only(
                  //                               topLeft: Radius.circular(8),
                  //                               topRight: Radius.circular(8))),
                  //                       child: const Text(
                  //                         "FILTER",
                  //                         style: TextStyle(
                  //                             color: Colors.white,
                  //                             fontSize: 18,
                  //                             fontWeight: FontWeight.w600),
                  //                         textAlign: TextAlign.center,
                  //                       ),
                  //                     ),
                  //                     actions: <Widget>[
                  //                       Row(
                  //                         children: [
                  //                           InkWell(
                  //                             onTap: () {
                  //                               searchController.clear();

                  //                               for (sales_lead_filter
                  //                                   .FilterList filter
                  //                                   in filterListData!) {
                  //                                 filter.ct = 0;
                  //                                 for (sales_lead_filter.Detail detail
                  //                                     in filter.details!) {
                  //                                   setState1(() {
                  //                                     detail.isSelected = false;
                  //                                   });
                  //                                 }
                  //                               }
                  //                               setState1(() {
                  //                                 offset = '0';
                  //                                 offset = '0';
                  //                                 searchTermValue = '';
                  //                                 rccBookingHistory = [];
                  //                                 filteredList = [];
                  //                                 searchTermValue = '';
                  //                                 searchText = '';
                  //                                 // rccBookingHistory = [];
                  //                               });

                  //                               filteredList = [];
                  //                               woOrderList = [];

                  //                               fetchProjectPoRequested();
                  //                               // Navigator.of(context).pop();
                  //                             },
                  //                             child: Container(
                  //                               width: MediaQuery.of(context)
                  //                                       .size
                  //                                       .width *
                  //                                   0.3,
                  //                               padding: const EdgeInsets.symmetric(
                  //                                   vertical: 4),
                  //                               decoration: const BoxDecoration(
                  //                                   color: Colors.black,
                  //                                   border: Border(
                  //                                       right: BorderSide(
                  //                                           color: Colors.white)),
                  //                                   borderRadius: BorderRadius.only(
                  //                                       bottomLeft:
                  //                                           Radius.circular(8))),
                  //                               child: const Text(
                  //                                 "RESET",
                  //                                 style: TextStyle(
                  //                                   fontSize: 16,
                  //                                   fontWeight: FontWeight.w600,
                  //                                   color: Colors.white,
                  //                                 ),
                  //                                 textAlign: TextAlign.center,
                  //                               ),
                  //                             ),
                  //                           ),
                  //                           InkWell(
                  //                             onTap: () {
                  //                               // Navigator.of(context).pop();

                  //                               filteredList = [];

                  //                               // Filter the data
                  //                               for (sales_lead_filter
                  //                                   .FilterList filter
                  //                                   in filterListData!) {
                  //                                 List<sales_lead_filter.Detail>?
                  //                                     details = [];
                  //                                 for (sales_lead_filter.Detail detail
                  //                                     in filter.details!) {
                  //                                   if (detail.isSelected == true) {
                  //                                     details.add(detail);
                  //                                   }
                  //                                 }
                  //                                 // Add filtered details to the filteredList
                  //                                 filteredList?.add(
                  //                                     sales_lead_filter.FilterList(
                  //                                   name: filter.name,
                  //                                   id: filter.id,
                  //                                   details: details,
                  //                                 ));
                  //                               }

                  //                               print(jsonEncode(filteredList));
                  //                               setState1(() {
                  //                                 offset = '0';
                  //                                 searchTermValue = '';
                  //                                 woOrderList = [];
                  //                                 offset = '0';
                  //                                 searchTermValue = '';
                  //                                 rccBookingHistory = [];
                  //                                 // rccBookingHistory = [];
                  //                               });
                  //                               fetchProjectPoRequested();
                  //                               Navigator.of(context).pop();
                  //                             },
                  //                             child: Container(
                  //                               width: MediaQuery.of(context)
                  //                                       .size
                  //                                       .width *
                  //                                   0.3,
                  //                               padding: const EdgeInsets.symmetric(
                  //                                   vertical: 4),
                  //                               decoration: const BoxDecoration(
                  //                                   color: Colors.black,
                  //                                   borderRadius: BorderRadius.only(
                  //                                       bottomRight:
                  //                                           Radius.circular(8))),
                  //                               child: const Text(
                  //                                 "APPLY FILTER",
                  //                                 style: TextStyle(
                  //                                   fontSize: 16,
                  //                                   fontWeight: FontWeight.w600,
                  //                                   color: Colors.white,
                  //                                 ),
                  //                                 textAlign: TextAlign.center,
                  //                               ),
                  //                             ),
                  //                           ),
                  //                         ],
                  //                       )
                  //                     ],
                  //                     content: StatefulBuilder(builder:
                  //                         (BuildContext context1,
                  //                             StateSetter setState) {
                  //                       return SizedBox(
                  //                         height: MediaQuery.of(context).size.height *
                  //                             0.6,
                  //                         width:
                  //                             MediaQuery.of(context).size.width * 0.6,
                  //                         child: Column(
                  //                           children: [
                  //                             Row(
                  //                               crossAxisAlignment:
                  //                                   CrossAxisAlignment.start,
                  //                               children: [
                  //                                 Container(
                  //                                   height: MediaQuery.of(context1)
                  //                                           .size
                  //                                           .height *
                  //                                       0.6,
                  //                                   width: MediaQuery.of(context1)
                  //                                           .size
                  //                                           .width *
                  //                                       0.2,
                  //                                   color: Colors.grey.shade300,
                  //                                   child: SingleChildScrollView(
                  //                                     child: Column(
                  //                                       crossAxisAlignment:
                  //                                           CrossAxisAlignment.start,
                  //                                       children: [
                  //                                         for (int i = 0;
                  //                                             i <
                  //                                                 filterListData!
                  //                                                     .length;
                  //                                             i++)
                  //                                           InkWell(
                  //                                             onTap: () {
                  //                                               setState1(() {
                  //                                                 filterListSelected =
                  //                                                     i;
                  //                                                 searchText = '';
                  //                                                 searchController
                  //                                                     .clear();
                  //                                               });
                  //                                             },
                  //                                             child: Container(
                  //                                               width: MediaQuery.of(
                  //                                                           context1)
                  //                                                       .size
                  //                                                       .width *
                  //                                                   0.2,
                  //                                               // color: Colors.white,
                  //                                               decoration: BoxDecoration(
                  //                                                   color: i ==
                  //                                                           filterListSelected
                  //                                                       ? Colors.white
                  //                                                       : Colors
                  //                                                           .transparent
                  //                                                   // border: Border.all(
                  //                                                   //     color:
                  //                                                   //         Colors.black),
                  //                                                   ),
                  //                                               padding:
                  //                                                   const EdgeInsets
                  //                                                       .symmetric(
                  //                                                       vertical: 14,
                  //                                                       horizontal:
                  //                                                           40),
                  //                                               child: Row(
                  //                                                 children: [
                  //                                                   Text(
                  //                                                     '${filterListData?[i].name}',
                  //                                                     style:
                  //                                                         const TextStyle(
                  //                                                       fontSize: 16,
                  //                                                       fontWeight:
                  //                                                           FontWeight
                  //                                                               .w600,
                  //                                                     ),
                  //                                                   ),
                  //                                                   if (filterListData![
                  //                                                               i]
                  //                                                           .ct >
                  //                                                       0)
                  //                                                     Padding(
                  //                                                       padding:
                  //                                                           const EdgeInsets
                  //                                                               .only(
                  //                                                               left:
                  //                                                                   7.0),
                  //                                                       child:
                  //                                                           Container(
                  //                                                         height: 5,
                  //                                                         width: 5,
                  //                                                         decoration: BoxDecoration(
                  //                                                             borderRadius:
                  //                                                                 BorderRadius.circular(
                  //                                                                     100),
                  //                                                             color: Colors
                  //                                                                 .black),
                  //                                                       ),
                  //                                                     )
                  //                                                 ],
                  //                                               ),
                  //                                             ),
                  //                                           )
                  //                                       ],
                  //                                     ),
                  //                                   ),
                  //                                 ),
                  //                                 SizedBox(
                  //                                   // height: 300,
                  //                                   // width: 455,
                  //                                   height: MediaQuery.of(context1)
                  //                                           .size
                  //                                           .height *
                  //                                       0.6,
                  //                                   width: MediaQuery.of(context1)
                  //                                           .size
                  //                                           .width *
                  //                                       0.4,
                  //                                   child: Column(
                  //                                     mainAxisAlignment:
                  //                                         MainAxisAlignment.start,
                  //                                     children: [
                  //                                       const SizedBox(height: 8),
                  //                                       Container(
                  //                                         height: 36,
                  //                                         padding: const EdgeInsets
                  //                                             .symmetric(
                  //                                             horizontal: 40),
                  //                                         child: TextFormField(
                  //                                           controller:
                  //                                               searchController,
                  //                                           onChanged: (value) {
                  //                                             setState(() {
                  //                                               // filteredProjects();
                  //                                               searchText = value;
                  //                                             });
                  //                                           },
                  //                                           style: const TextStyle(
                  //                                               color: Colors.black,
                  //                                               fontSize: 13.0),
                  //                                           decoration:
                  //                                               const InputDecoration(
                  //                                             prefixIcon: Icon(
                  //                                               Icons.search,
                  //                                               size: 22,
                  //                                             ),

                  //                                             contentPadding:
                  //                                                 EdgeInsets.only(
                  //                                                     bottom: 0,
                  //                                                     left: 12),
                  //                                             // border: OutlineInputBorder(
                  //                                             //   borderSide: BorderSide(color: Colors.transparent),
                  //                                             // ),
                  //                                             border:
                  //                                                 OutlineInputBorder(
                  //                                               borderRadius:
                  //                                                   BorderRadius.all(
                  //                                                       Radius
                  //                                                           .circular(
                  //                                                               8.0)),
                  //                                             ),
                  //                                             hintText: 'Search',
                  //                                             hintStyle: TextStyle(
                  //                                               color: Color.fromARGB(
                  //                                                   255,
                  //                                                   116,
                  //                                                   116,
                  //                                                   116),
                  //                                               fontSize: 13.0,
                  //                                               fontWeight:
                  //                                                   FontWeight.w200,
                  //                                               fontFamily:
                  //                                                   'HelveticaNeue',
                  //                                             ),
                  //                                             // suffixIcon: Icon(
                  //                                             //   Icons.calendar_month_outlined,
                  //                                             // ),
                  //                                           ),
                  //                                         ),
                  //                                       ),
                  //                                       // const SizedBox(
                  //                                       //   height: 10,
                  //                                       // ),
                  //                                       Divider(
                  //                                           color:
                  //                                               Colors.grey.shade300),
                  //                                       //      height: 300,
                  //                                       // width: 282,
                  //                                       // color: Colors.cyan,
                  //                                       SizedBox(
                  //                                         // height: 240,
                  //                                         height:
                  //                                             (MediaQuery.of(context1)
                  //                                                         .size
                  //                                                         .height *
                  //                                                     0.6) -
                  //                                                 62,
                  //                                         // width: 482,
                  //                                         // color: Colors.cyan,
                  //                                         child:
                  //                                             SingleChildScrollView(
                  //                                           child: Column(
                  //                                             children: [
                  //                                               for (int k = 0;
                  //                                                   k <
                  //                                                       filteredProjects()!
                  //                                                           .length;
                  //                                                   k++)
                  //                                                 InkWell(
                  //                                                   onTap: () {
                  //                                                     setState1(() {
                  //                                                       // if (filterListSelected == 0) {
                  //                                                       //   bool? temp = filterListData![filterListSelected].details![k].isSelected;
                  //                                                       //   filterListData?[filterListSelected].ct = temp == true ? 0 : 1;
                  //                                                       //   for (int p = 0; p < filteredProjects()!.length; p++) {
                  //                                                       //     filterListData![filterListSelected].details?[p].isSelected = false;
                  //                                                       //   }

                  //                                                       //   filterListData![filterListSelected].details?[k].isSelected = temp == true ? false : true;
                  //                                                       //   // filterListData![filterListSelected]
                  //                                                       //   //     .details?[
                  //                                                       //   //         k]
                  //                                                       //   //     .isSelected = filterListData![filterListSelected].details?[k].isSelected ==
                  //                                                       //   //         false
                  //                                                       //   //     ? true
                  //                                                       //   //     : false;
                  //                                                       // } else {
                  //                                                       if (filteredProjects()?[
                  //                                                                   k]
                  //                                                               .isSelected ==
                  //                                                           false) {
                  //                                                         filterListData?[
                  //                                                                 filterListSelected]
                  //                                                             .ct = filterListData![filterListSelected]
                  //                                                                 .ct +
                  //                                                             1;
                  //                                                       } else {
                  //                                                         filterListData?[
                  //                                                                 filterListSelected]
                  //                                                             .ct = filterListData![filterListSelected]
                  //                                                                 .ct -
                  //                                                             1;
                  //                                                       }
                  //                                                       // filterListData![
                  //                                                       //         filterListSelected]
                  //                                                       //     .details?[
                  //                                                       //         k]
                  //                                                       //     .isSelected = filteredProjects()?[k]
                  //                                                       //             .isSelected ==
                  //                                                       //         false
                  //                                                       //     ? true
                  //                                                       //     : false;

                  //                                                       filteredProjects()?[
                  //                                                                   k]
                  //                                                               .isSelected =
                  //                                                           filteredProjects()?[k].isSelected ==
                  //                                                                   true
                  //                                                               ? false
                  //                                                               : true;
                  //                                                       // }
                  //                                                     });
                  //                                                   },
                  //                                                   child: Container(
                  //                                                     padding: const EdgeInsets
                  //                                                         .symmetric(
                  //                                                         horizontal:
                  //                                                             40,
                  //                                                         vertical:
                  //                                                             5),
                  //                                                     child: Row(
                  //                                                       children: [
                  //                                                         Icon(filteredProjects()?[k].isSelected ==
                  //                                                                 true
                  //                                                             ? Icons
                  //                                                                 .check_box_rounded
                  //                                                             : Icons
                  //                                                                 .check_box_outline_blank_outlined),
                  //                                                         const SizedBox(
                  //                                                             width:
                  //                                                                 10),
                  //                                                         Text(
                  //                                                           filteredProjects()?[k]
                  //                                                                   .name ??
                  //                                                               '',
                  //                                                           style:
                  //                                                               const TextStyle(
                  //                                                             fontSize:
                  //                                                                 16,
                  //                                                             fontWeight:
                  //                                                                 FontWeight.w400,
                  //                                                           ),
                  //                                                         ),
                  //                                                       ],
                  //                                                     ),
                  //                                                   ),
                  //                                                 )
                  //                                             ],
                  //                                           ),
                  //                                         ),
                  //                                       ),
                  //                                     ],
                  //                                   ),
                  //                                 )
                  //                               ],
                  //                             )
                  //                           ],
                  //                         ),
                  //                       );
                  //                     }));
                  //               },
                  //             );
                  //           });
                  //     },
                  //     child: Container(
                  //       child: filteredList?.length != 0
                  //           ? Container(
                  //               color: Colors.black,
                  //               padding: const EdgeInsets.all(4),
                  //               child: Image.asset(
                  //                 'images/projectmanagement/filter_black.png',
                  //                 height: 20,
                  //               ),
                  //             )
                  //           : Image.asset(
                  //               'images/projectmanagement/filter-sort-icon.png',
                  //               height: 20,
                  //             ),
                  //     ),
                  //   ),
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
                        style: const TextStyle(
                            color: Colors.black, fontSize: 13.0),
                        decoration: _poInputDecoration(
                            'Select From Date', Icons.calendar_month_outlined,
                            trailing: true),
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
                        style: const TextStyle(
                            color: Colors.black, fontSize: 13.0),
                        decoration: _poInputDecoration(
                            'Select To Date', Icons.calendar_month_outlined,
                            trailing: true),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  OutlinedButton(
                    onPressed: () {
                      if (_selectedFormDate != null &&
                          _selectedToDate != null) {
                        // setState(() {
                        //   rccBookingHistory = [];
                        //   offset = '0';
                        // });

                        setState(() {
                          //   // Call setState to refresh the page.
                          //   flagcalled = false;
                          offset = '0';
                          searchTermValue = '';
                          woOrderList = [];
                          searchTermValue = '';
                          rccBookingHistory = [];
                          //   searchTermValue = '';
                          //   rccBookingHistory = [];
                          //   fetchProjectPoRequested();
                        });

                        fetchProjectPoRequested();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size(88, 42),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(21)),
                      side: const BorderSide(width: 1.0, color: Colors.black45),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
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
                      fetchProjectPoRequested();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(88, 42),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(21)),
                      side: const BorderSide(width: 1.0, color: Colors.black45),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Reset',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16.0,
                        )),
                  ),
                  const SizedBox(width: 0),
                ],
              ),
            )),
      ),
    );
  }

  viewDocs({List<String>? poDocument}) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Set radius to zero
            ),
            titlePadding: const EdgeInsets.symmetric(vertical: 0),
            actionsPadding: EdgeInsets.zero,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            actionsAlignment: MainAxisAlignment.center,
            title: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(7),
                    topRight: Radius.circular(7),
                  )),
              child: const Text(
                "View Documents",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            actions: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 500,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(7),
                        bottomRight: Radius.circular(7),
                      )),
                  child: const Text(
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
            ],
            content: SizedBox(
              height: 320,
              width: 400,
              child: SingleChildScrollView(
                child: Wrap(
                  direction: Axis.horizontal, // default
                  alignment: WrapAlignment.start, // default
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    for (int i = 0; i < poDocument!.length; i++)
                      poDocument[i].split(".").last == 'pdf'
                          ? InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return (useAccountManagementTestData
                                          ? const AccountManagementPreviewDocumentScreen()
                                          : PdfViewer(
                                              // here
                                              fileName: poDocument[i],
                                              fileUrl:
                                                  '${AppUrl.poDocPath}${poDocument[i].toString()}',
                                            ));
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
                                width: 140,
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'images/projectmanagement/pdf.png',
                                      width: 100,
                                      height: 100,
                                    ),
                                    AppText(
                                      title: poDocument[i],
                                      fontSize: 14,
                                    )
                                  ],
                                ),
                              ),
                            )
                          : poDocument[i].split(".").last == 'xlsx'
                              ? InkWell(
                                  onTap: () async {
                                    if (useAccountManagementTestData) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const AccountManagementPreviewDocumentScreen()));
                                      return;
                                    }
                                    final uri = Uri.parse(
                                        '${AppUrl.poDocPath}${poDocument[i].toString()}');
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    } else {
                                      throw 'Could not launch';
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    width: 140,
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'images/projectmanagement/excel_icon.png',
                                          width: 100,
                                          height: 100,
                                        ),
                                        AppText(
                                          title: poDocument[i],
                                          fontSize: 14,
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return (useAccountManagementTestData
                                              ? const AccountManagementPreviewDocumentScreen()
                                              : ImagePreviewViewer(
                                                  // here
                                                  fileName: poDocument[i],
                                                  fileUrl:
                                                      '${AppUrl.poDocPath}${poDocument[i].toString()}',
                                                ));
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
                                    width: 140,
                                    child: Column(
                                      children: [
                                        (useAccountManagementTestData
                                            ? const Icon(
                                                Icons.description_outlined,
                                                size: 48,
                                                color: Colors.black54)
                                            : Image.network(
                                                '${AppUrl.poDocPath}${poDocument[i].toString()}',
                                                width: 100,
                                                height: 100,
                                              )),
                                        AppText(
                                          title: poDocument[i],
                                          fontSize: 14,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  viewDelQty() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 0),
              actionsPadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.zero,
              // const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              actionsAlignment: MainAxisAlignment.center,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7),
                    )),
                child: const Text(
                  "Order Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 500,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(7),
                          bottomRight: Radius.circular(7),
                        )),
                    child: const Text(
                      "Close",
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
                  height: 320,
                  width: 400,
                  child: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.black))),
                        child: const Row(
                          children: [
                            SizedBox(
                              width: 180,
                              child: Text(
                                "Grade",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              child: Text(
                                textAlign: TextAlign.center,
                                "PO Qty",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              child: Text(
                                "Deliver Qty",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 270,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              for (int i = 0; i < orderDetails!.length; i++)
                                Container(
                                  padding:
                                      const EdgeInsets.only(bottom: 6, top: 4),
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom:
                                              BorderSide(color: Colors.black))),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          orderDetails?[i].gradeName ?? '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 140,
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          '${orderDetails?[i].orderQuantity} ${orderDetails?[i].castingUnitName}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 140,
                                        child: Text(
                                          '${orderDetails?[i].deliveryQuantity} ${orderDetails?[i].castingUnitName}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
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
                      Container(
                        decoration: const BoxDecoration(
                            border:
                                Border(top: BorderSide(color: Colors.black))),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 180,
                              child: Text(
                                'Total',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              child: Text(
                                textAlign: TextAlign.center,
                                orderQuantity ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              child: Text(
                                deliveryQuantity ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            );
          });
        });
  }

  selectFilterModal() {
    return showDialog<void>(
        // barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState1) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // Set radius to zero
              ),
              titlePadding: EdgeInsets.zero,
              actionsPadding: const EdgeInsets.only(bottom: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: const Text('SELECT VENDOR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'HelveticaNeue',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              actions: [
                InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 240,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10)),
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
                      ListView.separated(
                        shrinkWrap: true,
                        itemCount: venderSelectListFilter.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                isSelectedVenderList = index;
                                offset = '0';
                                searchTermValue = '';
                                rccBookingHistory = [];
                                woOrderList = [];
                              });

                              Navigator.of(context).pop();
                              fetchProjectPoRequested();
                            },
                            child: Row(
                              children: [
                                Text(
                                  venderSelectListFilter[index],
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const Spacer(),
                                Icon(
                                  isSelectedVenderList == index
                                      ? Icons.check_circle_outline_sharp
                                      : Icons.circle_outlined,
                                  color: isSelectedVenderList == index
                                      ? Colors.green
                                      : Colors.grey,
                                )
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(
                          color: Colors.grey,
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

  selectFilterVenderModal() {
    return showDialog<void>(
        // barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState1) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // Set radius to zero
              ),
              titlePadding: EdgeInsets.zero,
              actionsPadding: const EdgeInsets.only(bottom: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: const Text('SELECT VENDOR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'HelveticaNeue',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              actions: [
                InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 360,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10)),
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
                height: 320,
                width: 360.0,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        itemCount: venderListRes?.length ?? 0,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState1(() {
                                selecetdVenderListPO = venderListRes?[index];
                                editingVendorNameController.text =
                                    venderListRes?[index].venderCompanyName ??
                                        '';
                                offset = '0';
                                searchTermValue = '';
                                rccBookingHistory = [];
                                woOrderList = [];
                              });
                              Navigator.of(context).pop();
                              fetchProjectPoRequested();
                            },
                            child: Row(
                              children: [
                                Text(
                                  venderListRes?[index].venderCompanyName ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const Spacer(),
                                Icon(
                                  venderListRes?[index].venderId ==
                                          selecetdVenderListPO?.venderId
                                      ? Icons.check_circle_outline_sharp
                                      : Icons.circle_outlined,
                                  color: venderListRes?[index].venderId ==
                                          selecetdVenderListPO?.venderId
                                      ? Colors.green
                                      : Colors.grey,
                                )
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(
                          color: Colors.grey,
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
}
