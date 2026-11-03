import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_all_sales_lead.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/models/sales_lead_filter.dart';
import 'package:stallion/ui/views/statusofsupply/inventory_management.dart';
import 'package:stallion/ui/views/statusofsupply/suppliesdetails.dart';
import '../../../models/get_status_of_supply_list.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import '../accountmanagement/grnlistingview.dart';

// class StatusOfSupplyView extends StatefulWidget {
//   StatusOfSupplyView(
//       {super.key,
//       this.projectId,
//       this.towarId,
//       this.projectName,
//       this.towarName,
//       this.navigationFlag});

//   final String? projectId;
//   String? towarId;
//   final String? projectName;
//   final String? navigationFlag;
//   final String? towarName;

//   @override
//   State<StatusOfSupplyView> createState() => _StatusOfSupplyViewState();
// }
class StatusOfSupplyView extends StatefulWidget {
  const StatusOfSupplyView({super.key});

  @override
  State<StatusOfSupplyView> createState() => _StatusOfSupplyViewState();
}

class _StatusOfSupplyViewState extends State<StatusOfSupplyView> {
  late NotificationArgs args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is NotificationArgs) {
      args = routeArgs;
    } else {
      args = NotificationArgs(
        projectId: '',
        projectName: 'ALL PROJECT',
        towarName: '',
        response: NotificationResponseData(
          projectId: '',
          towarId: '',
          navigationFlag: 'SideMenu',
        ),
      );
    }
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  List<FilterList>? filterListData = [];
  List<FilterList>? filteredList = [];
  int filterListSelected = 0;
  String searchText = '';
  TextEditingController searchController = TextEditingController();
  String? poRawMaterialFlag = '0';

  bool flagcalled = false;
  bool norecord = false;
  bool flagSortBy = true;
  List<RccBookingHistory>? rccBookingHistory = [];
  String? offset = '0';
  String searchTermValue = '';

  TextEditingController editingController = TextEditingController();
  String? strTowarName = "All Tower";
  List<TowarList>? towarLists = [];
  List<Detail>? filteredProjects() {
    if (searchText.isEmpty) {
      return filterListData![filterListSelected].details;
    }
    return filterListData![filterListSelected].details!.where((project) {
      return project.name!.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
  }

  Future<ResponseGetPoStatusOfSupply?> fetchPoStatusOfSupply() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    String? loginType = prefs.getString('loginType');

    String towerId = "";
    if (args.response?.towarId != null) {
      towerId = args.response!.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": args.projectId!,
      "towar_id": towerId,
      "limit": "20",
      "offset": offset!,
      "search_data": searchTermValue,
      "login_type": loginType!,
      "fliterlist": jsonEncode(filteredList),
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.webSupplierBookingHistory, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getPoStatusOfSupplyFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        poRawMaterialFlag = dataModel.response?.poRawMaterialFlag;

        if (searchTermValue.isEmpty) {
          offset = dataModel.response?.offset;
        } else {
          offset = '0';
          rccBookingHistory = [];
        }

        List<RccBookingHistory>? rccBooking = [];
        rccBooking = dataModel.response?.rccBookingHistory!;
        if (rccBookingHistory!.isEmpty) {
          rccBookingHistory = rccBooking;
        } else {
          for (int i = 0; i < rccBooking!.length; i++) {
            rccBookingHistory?.add(rccBooking[i]);
          }
        }

        if (rccBookingHistory!.isEmpty) {
          norecord = true;
        } else {
          norecord = false;
        }

        setState(() {
          if (args.response?.navigationFlag! == 'Project') {
            towarLists = [];
            var arrTowar = dataModel.response?.towarList;
            if (arrTowar!.isNotEmpty) {
              towarLists?.add(TowarList(towarId: "", towarName: "All Tower"));
              if (towarLists!.isNotEmpty) {
                for (int i = 0; i < arrTowar.length; i++) {
                  if (arrTowar[i].towarId! == args.response?.towarId!) {
                    strTowarName = arrTowar[i].towarName!;
                  }
                  towarLists?.add(arrTowar[i]);
                }
              }
            }
          }
          flagcalled = true;
          rccBookingHistory!.length;
        });
      }

      if (flagSortBy == false) {
        rccBookingHistory?.sort((a, b) {
          var adate = a.poNo!; //before -> var adate = a.expiry;
          var bdate = b.poNo!; //var bdate = b.expiry;
          return adate.compareTo(bdate);
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

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 500));

    offset = '0';
    searchTermValue = '';
    rccBookingHistory = [];
    fetchPoStatusOfSupply();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 500));
    fetchPoStatusOfSupply();
    _refreshController.loadComplete();
  }

  Future<ResponseGetAllSalesLead?> getLeadFilter() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": args.projectId!,
      "towar_id": args.response?.towarId ?? '',
      "status_supply": flagSortBy == true ? "1" : "0",
      "po_status": "2",
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

  @override
  void initState() {
    super.initState();
    fetchPoStatusOfSupply();
    getLeadFilter();
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
              args.towarName == ""
                  ? '${args.projectName!.toUpperCase()} - ${args.towarName!.toUpperCase()}'
                  : args.projectName!.toUpperCase(),
              style:
                  const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
          leading: args.response?.navigationFlag == 'SideMenu'
              ? const SizedBox()
              : IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                ),
          actions: [
            const SizedBox(width: 80),
            if (poRawMaterialFlag == '1')
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return InventoryManagement(
                          projectId: args.projectId,
                          towarId: args.response?.towarId ?? '',
                          projectName: args.projectName,
                          towarName: args.towarName,
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Text(
                      "Inventory",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            // InkWell(
            // onTap: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (_) {
            //         return InventoryManagement(
            //           projectId: widget.projectId,
            //           towarId: widget.towarId!,
            //           projectName: widget.projectName,
            //           towarName: widget.towarName,
            //         );
            //       },
            //     ),
            //   );
            // },
            //   child: Image.asset(
            //     'images/projectmanagement/inventory-management.png',
            //     height: 40,
            //   ),
            // ),
            const SizedBox(width: 14),
          ],
        ),
        body: Container(
          height: double.infinity,
          color: Colors.white,
          child: SafeArea(
            child: flagcalled == true
                ? Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        height: 40,
                        child: Row(
                          children: [
                            const Spacer(),
                            const Text('STATUS OF SUPPLY',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center),
                            const Spacer(),
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
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8), // Set radius to zero
                                              ),
                                              titlePadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 0),
                                              actionsPadding:
                                                  const EdgeInsets.only(
                                                      bottom: 0),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 0),
                                              actionsAlignment:
                                                  MainAxisAlignment.center,
                                              title: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                decoration: const BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft: Radius
                                                                .circular(8),
                                                            topRight:
                                                                Radius.circular(
                                                                    8))),
                                                child: const Text(
                                                  "FILTER",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              actions: <Widget>[
                                                Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        searchController
                                                            .clear();
                                                        setState(() {
                                                          searchText = "";
                                                          flagcalled = false;
                                                        });
                                                        for (FilterList filter
                                                            in filterListData!) {
                                                          filter.ct = 0;
                                                          for (Detail detail
                                                              in filter
                                                                  .details!) {
                                                            setState1(() {
                                                              detail.isSelected =
                                                                  false;
                                                            });
                                                          }
                                                        }
                                                        setState1(() {
                                                          offset = '0';

                                                          filteredList = [];
                                                          searchTermValue = '';
                                                          rccBookingHistory =
                                                              [];
                                                        });

                                                        filteredList = [];
                                                        fetchPoStatusOfSupply();
                                                        // Navigator.of(context).pop();
                                                      },
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4),
                                                        decoration: const BoxDecoration(
                                                            color: Colors.black,
                                                            border: Border(
                                                                right: BorderSide(
                                                                    color: Colors
                                                                        .white)),
                                                            borderRadius:
                                                                BorderRadius.only(
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            8))),
                                                        child: const Text(
                                                          "RESET",
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
                                                      onTap: () {
                                                        filteredList = [];
                                                        setState(() {
                                                          flagcalled = false;
                                                        });
                                                        // Filter the data
                                                        for (FilterList filter
                                                            in filterListData!) {
                                                          List<Detail>?
                                                              details = [];
                                                          for (Detail detail
                                                              in filter
                                                                  .details!) {
                                                            if (detail
                                                                    .isSelected ==
                                                                true) {
                                                              details
                                                                  .add(detail);
                                                            }
                                                          }
                                                          // Add filtered details to the filteredList
                                                          filteredList
                                                              ?.add(FilterList(
                                                            name: filter.name,
                                                            id: filter.id,
                                                            details: details,
                                                          ));
                                                        }
                                                        setState1(() {
                                                          offset = '0';
                                                          searchTermValue = '';
                                                          rccBookingHistory =
                                                              [];
                                                        });
                                                        fetchPoStatusOfSupply();
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4),
                                                        decoration: const BoxDecoration(
                                                            color: Colors.black,
                                                            borderRadius:
                                                                BorderRadius.only(
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            8))),
                                                        child: const Text(
                                                          "APPLY FILTER",
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
                                                )
                                              ],
                                              content: StatefulBuilder(builder:
                                                  (BuildContext context1,
                                                      StateSetter setState) {
                                                return SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.6,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.6,
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            height: MediaQuery.of(
                                                                        context1)
                                                                    .size
                                                                    .height *
                                                                0.6,
                                                            width: MediaQuery.of(
                                                                        context1)
                                                                    .size
                                                                    .width *
                                                                0.2,
                                                            color: Colors
                                                                .grey.shade300,
                                                            child:
                                                                SingleChildScrollView(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          filterListData!
                                                                              .length;
                                                                      i++)
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        setState1(
                                                                            () {
                                                                          filterListSelected =
                                                                              i;
                                                                          searchText =
                                                                              '';
                                                                          searchController
                                                                              .clear();
                                                                        });
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width: MediaQuery.of(context1).size.width *
                                                                            0.2,
                                                                        // color: Colors.white,
                                                                        decoration: BoxDecoration(
                                                                            color: i == filterListSelected
                                                                                ? Colors.white
                                                                                : Colors.transparent
                                                                            // border: Border.all(
                                                                            //     color:
                                                                            //         Colors.black),
                                                                            ),
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                14,
                                                                            horizontal:
                                                                                40),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Text(
                                                                              '${filterListData?[i].name}',
                                                                              style: const TextStyle(
                                                                                fontSize: 16,
                                                                                fontWeight: FontWeight.w600,
                                                                              ),
                                                                            ),
                                                                            if (filterListData![i].ct >
                                                                                0)
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 7.0),
                                                                                child: Container(
                                                                                  height: 5,
                                                                                  width: 5,
                                                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.black),
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
                                                            height: MediaQuery.of(
                                                                        context1)
                                                                    .size
                                                                    .height *
                                                                0.6,
                                                            width: MediaQuery.of(
                                                                        context1)
                                                                    .size
                                                                    .width *
                                                                0.4,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const SizedBox(
                                                                    height: 8),
                                                                Container(
                                                                  height: 36,
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          40),
                                                                  child:
                                                                      TextFormField(
                                                                    controller:
                                                                        searchController,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        // filteredProjects();
                                                                        searchText =
                                                                            value;
                                                                      });
                                                                    },
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            13.0),
                                                                    decoration:
                                                                        const InputDecoration(
                                                                      prefixIcon:
                                                                          Icon(
                                                                        Icons
                                                                            .search,
                                                                        size:
                                                                            22,
                                                                      ),

                                                                      contentPadding: EdgeInsets.only(
                                                                          bottom:
                                                                              0,
                                                                          left:
                                                                              12),
                                                                      // border: OutlineInputBorder(
                                                                      //   borderSide: BorderSide(color: Colors.transparent),
                                                                      // ),
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(8.0)),
                                                                      ),
                                                                      hintText:
                                                                          'Search',
                                                                      hintStyle:
                                                                          TextStyle(
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            116,
                                                                            116,
                                                                            116),
                                                                        fontSize:
                                                                            13.0,
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
                                                                        .grey
                                                                        .shade300),
                                                                //      height: 300,
                                                                // width: 282,
                                                                // color: Colors.cyan,
                                                                SizedBox(
                                                                  // height: 240,
                                                                  height: (MediaQuery.of(context1)
                                                                              .size
                                                                              .height *
                                                                          0.6) -
                                                                      62,
                                                                  // width: 482,
                                                                  // color: Colors.cyan,
                                                                  child:
                                                                      SingleChildScrollView(
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        for (int k =
                                                                                0;
                                                                            k < filteredProjects()!.length;
                                                                            k++)
                                                                          InkWell(
                                                                            onTap:
                                                                                () {
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
                                                                                if (filteredProjects()?[k].isSelected == false) {
                                                                                  filterListData?[filterListSelected].ct = filterListData![filterListSelected].ct + 1;
                                                                                } else {
                                                                                  filterListData?[filterListSelected].ct = filterListData![filterListSelected].ct - 1;
                                                                                }
                                                                                filteredProjects()?[k].isSelected = filteredProjects()?[k].isSelected == false ? true : false;
                                                                                // }
                                                                              });
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                                                                              child: Row(
                                                                                children: [
                                                                                  Icon(filteredProjects()?[k].isSelected == true ? Icons.check_box_rounded : Icons.check_box_outline_blank_outlined),
                                                                                  const SizedBox(width: 10),
                                                                                  Text(
                                                                                    filteredProjects()?[k].name ?? '',
                                                                                    style: const TextStyle(
                                                                                      fontSize: 16,
                                                                                      fontWeight: FontWeight.w400,
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
                                        color: Colors.grey,
                                        padding: const EdgeInsets.all(4),
                                        child: Image.asset(
                                          'images/projectmanagement/filter-sort-icon.png',
                                          height: 20,
                                        ),
                                      )
                                    : Image.asset(
                                        color: Colors.black,
                                        'images/projectmanagement/filter_black.png',
                                        height: 20,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 1.0,
                        color: Colors.black,
                      ),
                      args.response?.navigationFlag != 'SideMenu'
                          ? towarLists!.isNotEmpty
                              ? InkWell(
                                  onTap: () {
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder:
                                            (BuildContext context) => Dialog(
                                                  elevation: 0,
                                                  child: SizedBox(
                                                    height: 400,
                                                    width: 360.0,
                                                    child: Column(
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 5.0,
                                                                  bottom: 5),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                'SELECT TOWER',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Divider(
                                                          color: Colors
                                                              .grey.shade500,
                                                          thickness: 1.5,
                                                        ),
                                                        SizedBox(
                                                          height: 310,
                                                          width: 360,
                                                          child:
                                                              ListView.builder(
                                                                  itemCount:
                                                                      towarLists
                                                                          ?.length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return Column(
                                                                      children: [
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            offset =
                                                                                '0';
                                                                            searchTermValue =
                                                                                '';
                                                                            rccBookingHistory =
                                                                                [];
                                                                            editingController.clear();
                                                                            args.response?.towarId =
                                                                                towarLists![index].towarId!;
                                                                            towarLists![index].towarId!;
                                                                            setState(() {
                                                                              strTowarName = towarLists![index].towarName!;
                                                                            });
                                                                            fetchPoStatusOfSupply();
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 10.0, bottom: 20.0, top: 15.0),
                                                                                  child: Text(towarLists![index].towarName!),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(right: 10.0),
                                                                                  child: Icon(
                                                                                    args.response?.towarId == towarLists![index].towarId! ? Icons.check_circle_outline_sharp : Icons.circle_outlined,
                                                                                    color: args.response?.towarId == towarLists![index].towarId! ? Colors.green : Colors.grey,
                                                                                    size: 26,
                                                                                  ),
                                                                                ),
                                                                              ]),
                                                                        ),
                                                                        const Divider(
                                                                          height:
                                                                              1,
                                                                          thickness:
                                                                              0.5,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ],
                                                                    );
                                                                  }),
                                                        ),
                                                        Expanded(
                                                          child: InkWell(
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              color:
                                                                  Colors.black,
                                                              child:
                                                                  const Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            13.0),
                                                                child: Text(
                                                                  'OK',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          15),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ));
                                  },
                                  child: SizedBox(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(strTowarName!.toUpperCase(),
                                            style: const TextStyle(
                                                fontStyle: FontStyle.normal,
                                                fontSize: 17.0)),
                                        horizontalSpaceSmall,
                                        IconButton(
                                          icon: const Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.black),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox()
                          : const SizedBox(),
                      const Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 1,
                        endIndent: 1,
                        color: Colors.black,
                      ),
                      const Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Colors.white,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (flagSortBy == false) {
                                      flagSortBy = true;
                                      DateFormat format =
                                          DateFormat("dd-MM-yyyy");
                                      rccBookingHistory?.sort((a, b) {
                                        var adate = format.parse(a
                                            .castingDate!); //before -> var adate = a.expiry;
                                        var bdate = format.parse(b
                                            .castingDate!); //var bdate = b.expiry;
                                        return bdate.compareTo(adate);
                                      });
                                    }
                                  });
                                },
                                child: Container(
                                    padding: const EdgeInsets.only(top: 13),
                                    height: 40,
                                    color: flagSortBy == true
                                        ? Colors.black
                                        : Colors.white,
                                    child: Text(
                                      'Sort By Recent',
                                      style: flagSortBy == true
                                          ? const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold)
                                          : const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ))),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (flagSortBy == true) {
                                    flagSortBy = false;
                                    getLeadFilter();
                                    rccBookingHistory?.sort((a, b) {
                                      var adate = a
                                          .poNo!; //before -> var adate = a.expiry;
                                      var bdate =
                                          b.poNo!; //var bdate = b.expiry;
                                      return adate.compareTo(bdate);
                                    });
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.only(top: 13),
                                height: 40,
                                color: flagSortBy == false
                                    ? Colors.black
                                    : Colors.white,
                                child: Text(
                                  'Sort By P.O. No.',
                                  style: flagSortBy == false
                                      ? const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)
                                      : const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Colors.black,
                      ),
                      verticalSpaceSmall,
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 60.0, right: 60, top: 5.0),
                        child: SizedBox(
                          height: 40,
                          child: TextField(
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
                                    fetchPoStatusOfSupply();
                                  }
                                } else {
                                  offset = '0';
                                  searchTermValue = '';
                                  rccBookingHistory = [];
                                  editingController.clear();
                                  fetchPoStatusOfSupply();
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                }
                              });
                            },
                            style: const TextStyle(fontSize: 13),
                            controller: editingController,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(12.0),
                                labelText: "Search by PO.No or Vendor Name",
                                hintText: "Search by PO.No or Vendor Name",
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(25.0)))),
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
                      norecord == true
                          ? const Expanded(
                              child: Center(
                                  child: Text('No Record Found',
                                      style: normalText)),
                            )
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
                                    // List<OrderDetail>? orderDetails =
                                    //     rccBookingHistory?[index].orderDetails;
                                    if (index >=
                                        (rccBookingHistory?.length ?? 0)) {
                                      return const SizedBox();
                                    }

                                    List<OrderDetail>? orderDetails =
                                        rccBookingHistory?[index].orderDetails;
                                    if (orderDetails == null ||
                                        orderDetails.isEmpty) {
                                      return const SizedBox();
                                    }

                                    double actualQty = 0.0;
                                    double deliveredQty = 0.0;
                                    String units = "";
                                    String deliver = "";
                                    String grades = "";
                                    for (int i = 0;
                                        i < orderDetails!.length;
                                        i++) {
                                      actualQty = double.parse(
                                          orderDetails[i].orderQuantity!);
                                      deliveredQty = double.parse(
                                          orderDetails[i].deliveryQuantity!);
                                      if (i == 0) {
                                        units =
                                            '${actualQty.toStringAsFixed(3)} ${orderDetails[i].castingUnitName!}';
                                        deliver =
                                            '${deliveredQty.toStringAsFixed(3)} ${orderDetails[i].castingUnitName!}';
                                        grades = orderDetails[i].gradeTypeName!;
                                      } else {
                                        units =
                                            '$units, ${actualQty.toStringAsFixed(3)} ${orderDetails[i].castingUnitName!}';
                                        deliver =
                                            '$deliver, ${deliveredQty.toStringAsFixed(3)} ${orderDetails[i].castingUnitName!}';
                                        grades =
                                            '$grades, ${orderDetails[i].gradeTypeName!}';
                                      }
                                    }
                                    return InkWell(
                                      onTap: () {
                                        var projectId = args.projectId!;
                                        var projectName = args.projectName!;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) {
                                              return SuppliesPoDetails(
                                                  projectId: projectId,
                                                  towarId:
                                                      args.response?.towarId ??
                                                          '',
                                                  projectName: projectName,
                                                  orderDetails:
                                                      rccBookingHistory![
                                                          index]);
                                            },
                                          ),
                                        ).then((_) {
                                          // This block runs when you have returned back to the 1st Page from 2nd.
                                          setState(() {
                                            // Call setState to refresh the page.
                                            flagcalled = false;
                                            offset = '0';
                                            searchTermValue = '';
                                            rccBookingHistory = [];
                                            editingController.clear();
                                            fetchPoStatusOfSupply();
                                          });
                                        });
                                      },
                                      child: ListTile(
                                        trailing: const Padding(
                                          padding: EdgeInsets.only(top: 200.0),
                                          child:
                                              Icon(Icons.keyboard_arrow_right),
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
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'P.O. No.',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .poNo!,
                                                              style: boldText),
                                                          if (rccBookingHistory![
                                                                      index]
                                                                  .isStarMarked ==
                                                              '1')
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 8),
                                                              child: const Icon(
                                                                Icons
                                                                    .star_rounded,
                                                                color:
                                                                    Colors.red,
                                                                size: 14,
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
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'P.O. Created Date',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .poCreatedAt!,
                                                              style:
                                                                  normalText),
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
                                                              const SizedBox(
                                                                width: 200,
                                                                child: Text(
                                                                    'P.O. Status',
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
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: rccBookingHistory![index]
                                                                              .poStatus! ==
                                                                          '0'
                                                                      ? const Color
                                                                          .fromRGBO(
                                                                          255,
                                                                          214,
                                                                          51,
                                                                          1.0)
                                                                      : rccBookingHistory![index].poStatus! ==
                                                                              '1'
                                                                          ? const Color
                                                                              .fromRGBO(
                                                                              255,
                                                                              214,
                                                                              51,
                                                                              1.0)
                                                                          : rccBookingHistory![index].poStatus! == '2'
                                                                              ? const Color.fromRGBO(0, 128, 43, 1.0) //green
                                                                              : const Color.fromRGBO(255, 214, 51, 1.0), // yellow
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5.0),
                                                                ),
                                                                child: Padding(
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
                                                                      rccBookingHistory![index].poStatus! ==
                                                                              '0'
                                                                          ? 'Pending'
                                                                          : rccBookingHistory![index].poStatus! == '1'
                                                                              ? 'Assigned'
                                                                              : rccBookingHistory![index].poStatus! == '2'
                                                                                  ? 'Issued'
                                                                                  : rccBookingHistory![index].poStatus! == '3'
                                                                                      ? 'Dispute'
                                                                                      : '---',
                                                                      style: rccBookingHistory![index].poStatus! == '0'
                                                                          ? boldText
                                                                          : rccBookingHistory![index].poStatus! == '1'
                                                                              ? boldText
                                                                              : const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.white)),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
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
                                                                              towarId: args.response?.towarId ?? '',
                                                                              projectName: projectName,
                                                                              orderId: rccBookingHistory![index].orderId!);
                                                                        },
                                                                      ),
                                                                    );
                                                                  },
                                                                  child: Container(
                                                                      height: 35,
                                                                      width: 100,
                                                                      decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.grey),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        color: Colors
                                                                            .white,
                                                                        shape: BoxShape
                                                                            .rectangle,
                                                                      ),
                                                                      child: const Center(
                                                                        child:
                                                                            Text(
                                                                          'VIEW GRN',
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w400),
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
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
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Booking Type',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .gradeName!,
                                                              style:
                                                                  normalText),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Status Delivery',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
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
                                                                      1.0) // yellow

                                                                  : rccBookingHistory![index].orderStatus! ==
                                                                              '1' ||
                                                                          rccBookingHistory![index].orderStatus! ==
                                                                              '4'
                                                                      ? const Color.fromRGBO(
                                                                          255,
                                                                          214,
                                                                          51,
                                                                          1.0) //yellow
                                                                      : rccBookingHistory![index].orderStatus! ==
                                                                              '2'
                                                                          ? const Color.fromRGBO(
                                                                              0,
                                                                              128,
                                                                              43,
                                                                              1.0) //green
                                                                          : const Color.fromRGBO(
                                                                              255,
                                                                              51,
                                                                              0,
                                                                              1.0), //yellow
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
                                                                      ? boldText
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
                                                                  ? '( ${rccBookingHistory![index].orderDeliverDate!} )'
                                                                  : '',
                                                              style:
                                                                  normalText),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Vendor Name',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .venderName!,
                                                              style: boldText),
                                                          const SizedBox(
                                                              width: 18),
                                                          InkWell(
                                                            onTap: () {
                                                              showDialog<void>(
                                                                  barrierDismissible:
                                                                      true,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return AlertDialog(
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8), // Set radius to zero
                                                                      ),
                                                                      titlePadding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              10,
                                                                          horizontal:
                                                                              20),
                                                                      actionsPadding: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              10,
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              10),
                                                                      contentPadding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              16),
                                                                      actionsAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      title:
                                                                          Text(
                                                                        rccBookingHistory![index].venderName ??
                                                                            '',
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                      content: SizedBox(
                                                                          height: 200,
                                                                          child: SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                for (int i = 0; i < rccBookingHistory![index].venderPhone!.length; i++)
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(
                                                                                        rccBookingHistory![index].venderPhone?[i].venderName ?? '',
                                                                                        style: const TextStyle(fontSize: 16),
                                                                                      ),
                                                                                      Text(
                                                                                        rccBookingHistory![index].venderPhone?[i].venderPhoneNumber ?? '',
                                                                                        style: const TextStyle(fontSize: 16),
                                                                                      ),
                                                                                      const Divider(),
                                                                                    ],
                                                                                  )
                                                                              ],
                                                                            ),
                                                                          )),
                                                                      actions: [
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            // Navigator.of(context).pop();
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                250,
                                                                            padding:
                                                                                const EdgeInsets.symmetric(vertical: 4),
                                                                            decoration:
                                                                                BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(7)),
                                                                            child:
                                                                                const Text(
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
                                                                    );
                                                                  });
                                                            },
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(3),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .black54),
                                                              ),
                                                              child: const Icon(
                                                                Icons
                                                                    .local_phone_outlined,
                                                              ),
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
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Project Name',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .projectName!,
                                                              style:
                                                                  normalText),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Slab No',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .slabName!,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style:
                                                                  normalText),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Requirement Date',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(
                                                              DateFormat('dd MMM yyyy').format(DateFormat(
                                                                      'dd-MM-yyyy')
                                                                  .parse(rccBookingHistory![
                                                                          index]
                                                                      .castingDate!
                                                                      .toString())),
                                                              style:
                                                                  normalText),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Requested By',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .raisedBy!,
                                                              style:
                                                                  normalText),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Verified By',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
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
                                                                      1.0) //blue
                                                                  : rccBookingHistory![index]
                                                                              .poApproveBy! !=
                                                                          '---'
                                                                      ? const Color
                                                                          .fromRGBO(
                                                                          0,
                                                                          122,
                                                                          204,
                                                                          1.0) //blue
                                                                      : null,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
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
                                                                  style: rccBookingHistory![index]
                                                                              .poApproveBy! !=
                                                                          ''
                                                                      ? const TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              14.0,
                                                                          color: Colors
                                                                              .white)
                                                                      : rccBookingHistory![index].poApproveBy! !=
                                                                              '---'
                                                                          ? const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 14.0,
                                                                              color: Colors.white)
                                                                          : normalText),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (rccBookingHistory![
                                                                index]
                                                            .poCheckedBy !=
                                                        "")
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 10.0),
                                                        child: Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                  'Checked By',
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
                                                            Text(
                                                                rccBookingHistory![
                                                                            index]
                                                                        .poCheckedBy ??
                                                                    '',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize:
                                                                      16.0,
                                                                  color: Colors
                                                                      .black,
                                                                )),
                                                            if (rccBookingHistory![
                                                                        index]
                                                                    .poCheckedByDate !=
                                                                '')
                                                              Text(
                                                                '  (${rccBookingHistory![index].poCheckedByDate})',
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            16),
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
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Received By',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .checkedBy!,
                                                              style:
                                                                  normalText),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'PO Quantity',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Flexible(
                                                            child: Text(units,
                                                                style:
                                                                    normalText),
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
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Delivered Quantity',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Flexible(
                                                            child: Text(deliver,
                                                                style:
                                                                    normalText),
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
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                                'Grades',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54)),
                                                          horizontalSpaceLarge,
                                                          Flexible(
                                                            child: Text(grades,
                                                                style:
                                                                    normalText),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
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
                  )
                : Center(
                    child: SizedBox(
                      height: 64,
                      child: OverflowBox(
                        minHeight: 100,
                        maxHeight: 100,
                        child: Lottie.asset(
                          'assets/animation/running2.json',
                          repeat: true,
                        ),
                      ),
                    ),
                  ),
            // const Center(child: CircularProgressIndicator())
          ),
        ));
  }
}
