import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_project_my_contracts.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/mycontracts/woinvoicelist.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/utils/remove_temp_file.dart';

import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import '../accountmanagement/wopreviewhtml.dart';
import 'mycontractdetailview.dart';
import 'mycontractsubpage.dart';

class MyContractsView extends StatefulWidget {
  MyContractsView({
    Key? key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    this.navigationFlag,
    required this.categoryId,
    required this.developerId,
  });

  String? projectId;
  String? towarId;
  String? projectName;
  String? navigationFlag;
  String? towarName;
  String? categoryId;
  final String? developerId;

  @override
  State<MyContractsView> createState() => _MyContractsViewState();
}

class _MyContractsViewState extends State<MyContractsView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  bool flagcalled = false;
  bool norecord = false;

  String gradeStatus = 'Both';
  List<String> arrStatus = ["Both", "Consultant", "Contractor"];

  List<ContractList>? contractLists = [];
  List<ContractList>? actualcontractLists = [];
  TotalBar? totalBar = TotalBar();
  List<OrderList>? orderList = [];
  List<TowarList>? towarLists = [];
  String? strTowarName = "All Tower";
  String? accountFlag = '0';

  double? costToComplete = 0.0;
  String? offset = '0';
  String searchTermValue = '';
  TextEditingController editingController = TextEditingController();

  Future<ResponseGetProjectMyContracts?> fetchProjectMyContracts() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    String? loginType = prefs.getString('loginType');

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "limit": "20",
      "offset": offset!,
      "search_data": searchTermValue,
      "login_type": loginType!,
      "category_id": widget.categoryId ?? "",
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.getprojectmycontracts, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      //context.loaderOverlay.hide();
      final dataModel = getProjectMyContractsFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        if (searchTermValue.isEmpty) {
          offset = dataModel.response?.offset;
        } else {
          offset = '0';
          contractLists = [];
        }
        setState(() {
          accountFlag = dataModel.response?.accountFlag ?? '0';
          actualcontractLists = dataModel.response?.contractLists!;

          if (contractLists!.isEmpty) {
            contractLists = actualcontractLists;
          } else {
            for (int i = 0; i < actualcontractLists!.length; i++) {
              contractLists?.add(actualcontractLists![i]);
            }
          }

          if (orderList!.isEmpty) {
            orderList = dataModel.response?.orderList!;
          }
          totalBar = dataModel.response?.totalBar!;

          if (widget.navigationFlag! == 'Project') {
            towarLists = [];
            var arrTowar = dataModel.response?.towarList;
            if (arrTowar!.isNotEmpty) {
              towarLists?.add(TowarList(towarId: "", towarName: "All Tower"));
              if (towarLists!.isNotEmpty) {
                for (int i = 0; i < arrTowar.length; i++) {
                  if (arrTowar[i].towarId! == widget.towarId!) {
                    strTowarName = arrTowar[i].towarName!;
                  }
                  towarLists?.add(arrTowar[i]);
                }
              }
            }
          }

          double? discountAmt = 0.0;
          if (totalBar!.discountAmount!.isNotEmpty) {
            discountAmt = double.parse(totalBar!.discountAmount ?? '0');
          }
          costToComplete = double.parse(totalBar!.totalAmount ?? '0') -
              (double.parse(totalBar!.totalPaid ?? '0') + discountAmt);
          flagcalled = true;

          if (contractLists!.isEmpty) {
            norecord = true;
          } else {
            norecord = false;
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

  @override
  void initState() {
    super.initState();
    offset = '0';
    searchTermValue = '';
    contractLists = [];
    gradeStatus = 'Both';
    if (kDebugMode) {
      print('CALLED');
    }
    if (widget.navigationFlag == "SideMenu") {
      widget.projectName = "ALL PROJECTS";
      widget.projectId = "";
      widget.towarId = "";
    }
    fetchProjectMyContracts();
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));

    offset = '0';
    searchTermValue = '';
    setState(() {
      flagcalled = false;
      contractLists = [];
    });
    fetchProjectMyContracts();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));
    fetchProjectMyContracts();
    _refreshController.loadComplete();
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
              widget.navigationFlag! == 'SideMenu'
                  ? 'MY CONTRACTS'
                  : widget.towarName != ''
                      ? '${widget.projectName?.toUpperCase()} - ${widget.towarName?.toUpperCase()}'
                      : widget.projectName?.toUpperCase() ?? '',
              style:
                  const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
          leading: widget.navigationFlag! == 'SideMenu'
              ? const SizedBox()
              : IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                ),
          actions: [
            InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Set radius to zero
                          ),
                          actionsPadding: EdgeInsets.zero,
                          titlePadding: EdgeInsets.zero,
                          title: Container(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'INFO',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
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
                                width: 600,
                                padding: EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'CLOSE',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          ],
                          content: StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState) {
                            return SizedBox(
                              height: 140,
                              width: 400,
                              child: Center(
                                child: Text(
                                  "The pending invoice count is shown as per Total Pending invoices to Pay against Total Uploaded Invoices",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }));
                    });
              },
              child: Container(
                padding: const EdgeInsets.only(right: 24),
                child: const Icon(
                  Icons.info_rounded,
                  size: 30,
                ),
              ),
            )
          ],
        ),
        body: Container(
          height: double.infinity,
          color: Colors.white,
          child: SafeArea(
              child: flagcalled == true
                  ? Column(
                      children: [
                        widget.navigationFlag! == 'SideMenu'
                            ? SizedBox(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder:
                                                (BuildContext context) =>
                                                    Dialog(
                                                      elevation: 0,
                                                      child: SizedBox(
                                                        height: 400,
                                                        width: 360.0,
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 5.0,
                                                                      bottom:
                                                                          5),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: const [
                                                                  Text(
                                                                    'SELECT PROJECT',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Divider(
                                                              color: Colors.grey
                                                                  .shade500,
                                                              thickness: 1.5,
                                                            ),
                                                            SizedBox(
                                                              height: 310,
                                                              width: 360,
                                                              child: ListView
                                                                  .builder(
                                                                      itemCount:
                                                                          orderList
                                                                              ?.length,
                                                                      itemBuilder:
                                                                          (context,
                                                                              index) {
                                                                        return Column(
                                                                          children: [
                                                                            InkWell(
                                                                              onTap: () {
                                                                                setState(() {
                                                                                  widget.projectId = orderList![index].id!;
                                                                                  widget.projectName = orderList![index].name!;
                                                                                  widget.towarId = '';
                                                                                  strTowarName = "ALL TOWER";
                                                                                  var arrTowar = orderList![index].towarList!;
                                                                                  towarLists = [];
                                                                                  if (arrTowar.isNotEmpty) {
                                                                                    towarLists?.add(TowarList(towarId: '', towarName: 'All Tower'));
                                                                                    widget.towarId = '';
                                                                                    for (int i = 0; i < arrTowar.length; i++) {
                                                                                      towarLists?.add(arrTowar[i]);
                                                                                    }
                                                                                  }
                                                                                  offset = '0';
                                                                                  contractLists = [];
                                                                                  searchTermValue = '';
                                                                                });
                                                                                //context.loaderOverlay.show();
                                                                                fetchProjectMyContracts();
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 10.0, bottom: 20.0, top: 15.0),
                                                                                  child: Text(orderList![index].name!),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(right: 10.0),
                                                                                  child: Icon(
                                                                                    widget.projectId == orderList![index].id! ? Icons.check_circle_outline_sharp : Icons.circle_outlined,
                                                                                    color: widget.projectId == orderList![index].id! ? Colors.green : Colors.grey,
                                                                                    size: 26,
                                                                                  ),
                                                                                ),
                                                                              ]),
                                                                            ),
                                                                            const Divider(
                                                                              height: 1,
                                                                              thickness: 0.5,
                                                                              color: Colors.black,
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
                                                                child:
                                                                    Container(
                                                                  width: double
                                                                      .infinity,
                                                                  color: Colors
                                                                      .black,
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
                                                                          fontWeight: FontWeight
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
                                            Text(
                                                widget.projectName!
                                                    .toUpperCase(),
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
                                    ),
                                    const Divider(
                                      height: 0.5,
                                      thickness: 0.5,
                                      indent: 1,
                                      endIndent: 1,
                                      color: Colors.black,
                                    ),
                                    towarLists!.isNotEmpty
                                        ? InkWell(
                                            onTap: () {
                                              towarLists!.isNotEmpty
                                                  ? showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder:
                                                          (BuildContext
                                                                  context) =>
                                                              Dialog(
                                                                elevation: 0,
                                                                child: SizedBox(
                                                                  height: 400,
                                                                  width: 360.0,
                                                                  child: Column(
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                5.0,
                                                                            bottom:
                                                                                5),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: const [
                                                                            Text(
                                                                              'SELECT TOWER',
                                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Divider(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade500,
                                                                        thickness:
                                                                            1.5,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            310,
                                                                        width:
                                                                            360,
                                                                        child: ListView.builder(
                                                                            itemCount: towarLists?.length,
                                                                            itemBuilder: (context, index) {
                                                                              return Column(
                                                                                children: [
                                                                                  InkWell(
                                                                                    onTap: () {
                                                                                      setState(() {
                                                                                        widget.towarId = towarLists![index].towarId!;
                                                                                        strTowarName = towarLists![index].towarName!;
                                                                                        offset = '0';
                                                                                        contractLists = [];
                                                                                        searchTermValue = '';
                                                                                      });
                                                                                      //context.loaderOverlay.show();
                                                                                      fetchProjectMyContracts();
                                                                                      Navigator.of(context).pop();
                                                                                    },
                                                                                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(left: 10.0, bottom: 20.0, top: 15.0),
                                                                                        child: Text(towarLists![index].towarName!),
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(right: 10.0),
                                                                                        child: Icon(
                                                                                          widget.towarId == towarLists![index].towarId! ? Icons.check_circle_outline_sharp : Icons.circle_outlined,
                                                                                          color: widget.towarId == towarLists![index].towarId! ? Colors.green : Colors.grey,
                                                                                          size: 26,
                                                                                        ),
                                                                                      ),
                                                                                    ]),
                                                                                  ),
                                                                                  const Divider(
                                                                                    height: 1,
                                                                                    thickness: 0.5,
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                ],
                                                                              );
                                                                            }),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                double.infinity,
                                                                            color:
                                                                                Colors.black,
                                                                            child:
                                                                                const Padding(
                                                                              padding: EdgeInsets.only(top: 13.0),
                                                                              child: Text(
                                                                                'OK',
                                                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ))
                                                  : Alert(
                                                      closeIcon:
                                                          const SizedBox(),
                                                      padding:
                                                          const EdgeInsets
                                                              .only(top: 0.0),
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
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 16),
                                                          isCloseButton: true),
                                                      context: context,
                                                      desc:
                                                          'Please select project.',
                                                      alertAnimation:
                                                          fadeAlertAnimation,
                                                      buttons: [
                                                          DialogButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            color: Colors.black,
                                                            child: const Text(
                                                              "CLOSE",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 15),
                                                            ),
                                                          ),
                                                        ]).show();
                                            },
                                            child: SizedBox(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                      strTowarName!
                                                          .toUpperCase(),
                                                      style: const TextStyle(
                                                          fontStyle:
                                                              FontStyle.normal,
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
                                        : const SizedBox(),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        widget.navigationFlag! == 'Project'
                            ? SizedBox(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    towarLists!.isNotEmpty
                                        ? InkWell(
                                            onTap: () {
                                              towarLists!.isNotEmpty
                                                  ? showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder:
                                                          (BuildContext
                                                                  context) =>
                                                              Dialog(
                                                                elevation: 0,
                                                                child: SizedBox(
                                                                  height: 400,
                                                                  width: 360.0,
                                                                  child: Column(
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                5.0,
                                                                            bottom:
                                                                                5),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: const [
                                                                            Text(
                                                                              'SELECT TOWER',
                                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Divider(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade500,
                                                                        thickness:
                                                                            1.5,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            310,
                                                                        width:
                                                                            360,
                                                                        child: ListView.builder(
                                                                            itemCount: towarLists?.length,
                                                                            itemBuilder: (context, index) {
                                                                              return Column(
                                                                                children: [
                                                                                  InkWell(
                                                                                    onTap: () {
                                                                                      setState(() {
                                                                                        widget.towarId = towarLists![index].towarId!;
                                                                                        strTowarName = towarLists![index].towarName!;
                                                                                        offset = '0';
                                                                                        contractLists = [];
                                                                                        searchTermValue = '';
                                                                                      });
                                                                                      //context.loaderOverlay.show();
                                                                                      fetchProjectMyContracts();
                                                                                      Navigator.of(context).pop();
                                                                                    },
                                                                                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(left: 10.0, bottom: 20.0, top: 15.0),
                                                                                        child: Text(towarLists![index].towarName!),
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(right: 10.0),
                                                                                        child: Icon(
                                                                                          widget.towarId == towarLists![index].towarId! ? Icons.check_circle_outline_sharp : Icons.circle_outlined,
                                                                                          color: widget.towarId == towarLists![index].towarId! ? Colors.green : Colors.grey,
                                                                                          size: 26,
                                                                                        ),
                                                                                      ),
                                                                                    ]),
                                                                                  ),
                                                                                  const Divider(
                                                                                    height: 1,
                                                                                    thickness: 0.5,
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                ],
                                                                              );
                                                                            }),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                double.infinity,
                                                                            color:
                                                                                Colors.black,
                                                                            child:
                                                                                const Padding(
                                                                              padding: EdgeInsets.only(top: 13.0),
                                                                              child: Text(
                                                                                'OK',
                                                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ))
                                                  : Alert(
                                                      closeIcon:
                                                          const SizedBox(),
                                                      padding:
                                                          const EdgeInsets
                                                              .only(top: 0.0),
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
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 16),
                                                          isCloseButton: true),
                                                      context: context,
                                                      desc:
                                                          'Please select project.',
                                                      alertAnimation:
                                                          fadeAlertAnimation,
                                                      buttons: [
                                                          DialogButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            color: Colors.black,
                                                            child: const Text(
                                                              "CLOSE",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 15),
                                                            ),
                                                          ),
                                                        ]).show();
                                            },
                                            child: SizedBox(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                      strTowarName!
                                                          .toUpperCase(),
                                                      style: const TextStyle(
                                                          fontStyle:
                                                              FontStyle.normal,
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
                                        : const SizedBox(),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        const Divider(
                          height: 0.5,
                          thickness: 0.5,
                          indent: 1,
                          endIndent: 1,
                          color: Colors.black,
                        ),
                        verticalSpaceSmall,
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0, right: 30),
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              onChanged: (value) {
                                Future.delayed(const Duration(seconds: 1), () {
                                  if (value.isNotEmpty) {
                                    if (value.length > 2) {
                                      contractLists = [];
                                      offset = '0';
                                      searchTermValue = value;
                                      searchTermValue =
                                          searchTermValue.replaceAll("  ", " ");
                                      searchTermValue = searchTermValue.trim();
                                      fetchProjectMyContracts();
                                    }
                                  } else {
                                    offset = '0';
                                    searchTermValue = '';
                                    contractLists = [];
                                    editingController.clear();
                                    fetchProjectMyContracts();
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                  }
                                });
                              },
                              style: const TextStyle(fontSize: 13),
                              controller: editingController,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(12.0),
                                  labelText:
                                      "Search by consultant or contractor name",
                                  hintText:
                                      "Search by consultant or contractor name",
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
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20.0),
                                  child: SmartRefresher(
                                    enablePullDown:
                                        searchTermValue.isEmpty ? true : false,
                                    enablePullUp:
                                        searchTermValue.isEmpty ? true : false,
                                    controller: _refreshController,
                                    onRefresh: searchTermValue.isEmpty
                                        ? _onRefresh
                                        : null,
                                    onLoading: searchTermValue.isEmpty
                                        ? _onLoading
                                        : null,
                                    footer: const ClassicFooter(
                                        loadStyle: LoadStyle.ShowWhenLoading),
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: contractLists!.length,
                                      itemBuilder: (context, index) {
                                        return ListItem(
                                            categoryId: widget.categoryId,
                                            developerId: widget.developerId,
                                            contractLists:
                                                contractLists![index],
                                            projectId: widget.projectId!,
                                            towarId: widget.towarId!,
                                            projectName: widget.projectName!);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                        if (accountFlag == '1')
                          const Divider(
                            height: 1,
                            thickness: 0.5,
                            indent: 1,
                            endIndent: 1,
                            color: Colors.black,
                          ),
                        if (accountFlag == '1') verticalSpaceSmall,
                        if (accountFlag == '1')
                          SizedBox(
                            height: 75,
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  horizontalSpaceSmall,
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const Text('Total',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black)),
                                          verticalSpaceSmall,
                                          Text(currencyFormat.format(
                                              double.parse(
                                                  totalBar!.totalAmount ??
                                                      '0')))
                                        ],
                                      ),
                                    ),
                                  ),
                                  const VerticalDivider(
                                    width: 1,
                                    thickness: 1,
                                    indent: 10,
                                    endIndent: 0,
                                    color: Colors.black54,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const Text('Work Done',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black)),
                                          verticalSpaceSmall,
                                          Text(currencyFormat.format(
                                              double.parse(
                                                  totalBar!.workDone ?? '0')))
                                        ],
                                      ),
                                    ),
                                  ),
                                  const VerticalDivider(
                                    width: 1,
                                    thickness: 1,
                                    indent: 10,
                                    endIndent: 0,
                                    color: Colors.black54,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const Text('Total Paid',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black)),
                                          verticalSpaceSmall,
                                          Text(currencyFormat.format(
                                              double.parse(
                                                  totalBar!.totalPaid ?? "0"))),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const VerticalDivider(
                                    width: 1,
                                    thickness: 1,
                                    indent: 10,
                                    endIndent: 0,
                                    color: Colors.black54,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const Text('Amount Due',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black)),
                                          verticalSpaceSmall,
                                          Text(
                                              currencyFormat.format(
                                                  double.parse(
                                                      totalBar!.payables ??
                                                          "0")),
                                              style: double.parse(
                                                          totalBar!.payables ??
                                                              '0') ==
                                                      0.00
                                                  ? const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.black)
                                                  : const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (accountFlag == '1')
                          const Divider(
                            height: 1,
                            thickness: 0.5,
                            indent: 1,
                            endIndent: 1,
                            color: Colors.black,
                          ),
                        if (accountFlag == '1')
                          SizedBox(
                              height: 50,
                              child: Center(
                                child: Text(
                                    'Cost to Complete: ${currencyFormat.format(costToComplete!)}',
                                    style: const TextStyle(
                                        backgroundColor: Colors.white,
                                        fontSize: 15,
                                        color: Colors.black)),
                              )),
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
                    )),
          // const Center(child: CircularProgressIndicator())),
        ));
  }
}

class ListItem extends StatelessWidget {
  ListItem(
      {Key? key,
      required this.contractLists,
      required this.categoryId,
      required this.developerId,
      this.projectId,
      this.towarId,
      this.projectName})
      : super(key: key);

  ContractList contractLists;
  String? projectId;
  String? towarId;
  String? projectName;
  final String? categoryId;
  final String? developerId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            print(projectId);
            print(towarId);
            print(projectName);
            if (contractLists.woOrderNo! == '--') {
              print('IN');
              var projectIdd = projectId;
              var towarIdd = towarId!;
              var projectNamee = projectName!;
              if (projectId!.isEmpty) {
                projectIdd = contractLists.projectId!;
                towarIdd = contractLists.towarId!;
                projectNamee = contractLists.projectName!;
              }
              print(projectIdd);
              print(towarIdd);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return MyContractsSubView(
                        categoryId: categoryId,
                        developerId: developerId,
                        projectId: projectIdd,
                        towarId: towarIdd,
                        projectName: projectNamee,
                        gradeId: contractLists.gradeId!,
                        companyId: contractLists.companyIdFk,
                        companyType: contractLists.companyType,
                        contractorName:
                            contractLists.mstCompanyName!.toUpperCase());
                  },
                ),
              );
            } else {
              print('ELSE');
              print(projectId!);
              print(towarId!);
              var projectIdd = projectId!;
              var towarIdd = towarId!;
              var projectNamee = this.projectName!;
              if (projectId!.isEmpty) {
                projectId = contractLists.projectId!;
                towarId = contractLists.towarId!;
                projectName = contractLists.projectName!;
              }
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) {
              //       return MyContractsDetailView(
              //           projectId: projectIdd,
              //           towarId: towarIdd,
              //           projectName: projectNamee,
              //           gradeId: contractLists.gradeId!,
              //           companyId: contractLists.companyIdFk,
              //           workorderId: contractLists.woOrderId!,
              //           workId: contractLists.woOrderNo!,
              //           contractorName:
              //               contractLists.mstCompanyName!.toUpperCase());
              //     },
              //   ),
              // );
              Navigator.of(context).pushNamed(
                '/myContractsDetailViewScreen',
                arguments: NotificationArgs(
                  projectId: projectIdd,
                  projectName: projectNamee,
                  // towarName: widget.towarName,
                  response: NotificationResponseData(
                    towarId: towarIdd,
                    woOrderId: contractLists.woOrderId,
                    woOrderNo: contractLists.woOrderNo,
                    // assignToId: assignToId ?? '',
                  ),
                ),
              );
            }
          },
          child: ListTile(
            trailing: Icon(Icons.keyboard_arrow_right),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                verticalSpaceSmall,
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: Text(
                                contractLists.companyType! == 'consultant'
                                    ? 'Consultant Name'
                                    : 'Contractor Name',
                                style: const TextStyle(
                                    backgroundColor: Colors.white,
                                    fontSize: 15,
                                    color: Colors.black)),
                          ),
                          horizontalSpaceMedium,
                          const Center(
                              child: Icon(Icons.remove, color: Colors.black54)),
                          horizontalSpaceLarge,
                          Text(contractLists.mstCompanyName!,
                              style: const TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                          const Expanded(child: horizontalSpaceLarge),
                          contractLists.woOrderNo! == '--'
                              ? const SizedBox()
                              : Stack(children: [
                                  SizedBox(
                                    width: 35,
                                    height: 35,
                                    child: CircularProgressIndicator(
                                        backgroundColor: Colors.grey,
                                        color: Colors.green,
                                        strokeWidth: 4,
                                        value: contractLists.totalPercentage! !=
                                                '--'
                                            ? double.parse(
                                                contractLists.totalPercentage ??
                                                    '0')
                                            : 0.0),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 11, left: 7),
                                    child: Text(
                                        contractLists.totalPercentage! != '--'
                                            ? '${double.parse(contractLists.totalPercentage ?? '0').toStringAsFixed(0)}%'
                                            : '0%',
                                        style: const TextStyle(
                                            fontSize: 9, color: Colors.black)),
                                  ),
                                ]), //
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: Text(
                                contractLists.woOrderNo! == '--'
                                    ? 'No. of Work Order'
                                    : 'Work Order Number',
                                style: const TextStyle(
                                    backgroundColor: Colors.white,
                                    fontSize: 15,
                                    color: Colors.black)),
                          ),
                          horizontalSpaceMedium,
                          const Center(
                              child: Icon(Icons.remove, color: Colors.black54)),
                          horizontalSpaceLarge,
                          Text(
                              contractLists.woOrderNo! == '--'
                                  ? contractLists.woOrderCount!
                                  : contractLists.woOrderNo!,
                              style: const TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                          const Expanded(child: horizontalSpaceLarge),
                          contractLists.woOrderNo! != '--'
                              ? SizedBox(
                                  width: 110,
                                  height: 33,
                                  child: Container(
                                    width: double.infinity,
                                    height: 33,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(17),
                                      border: Border.all(
                                        color: Colors.black,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        var projectId = this.projectId!;
                                        var projectName = this.projectName!;
                                        if (projectId.isEmpty) {
                                          projectId = contractLists.projectId!;
                                          projectName =
                                              contractLists.projectName!;
                                        }
                                        print(projectId);
                                        print(projectName);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) {
                                              return WoPreviewHtml(
                                                  projectId: projectId,
                                                  towarId: towarId!,
                                                  projectName: projectName,
                                                  workOrderId:
                                                      contractLists.woOrderId!,
                                                  workOrderNo: contractLists
                                                      .woOrderNo!
                                                      .toUpperCase(),
                                                  flagRedirect: 'project');
                                            },
                                          ),
                                        ).then((value) => {});
                                      },
                                      child: const Text(
                                        'VIEW WO',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 13.0,
                                        ),
                                      ),
                                    ),
                                  ))
                              : const SizedBox(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 200,
                            child: Text('Project Name',
                                style: TextStyle(
                                    backgroundColor: Colors.white,
                                    fontSize: 15,
                                    color: Colors.black)),
                          ),
                          horizontalSpaceMedium,
                          const Center(
                              child: Icon(Icons.remove, color: Colors.black54)),
                          horizontalSpaceLarge,
                          Text(contractLists.projectName!,
                              style: const TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                          Spacer(),
                          if (contractLists.woOrderNo! != '--')
                            InkWell(
                              onTap: () {
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                8), // Set radius to zero
                                          ),
                                          titlePadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 0),
                                          actionsPadding: EdgeInsets.zero,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 10),
                                          actionsAlignment:
                                              MainAxisAlignment.center,
                                          title: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            decoration: const BoxDecoration(
                                                color: Colors.black,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(7),
                                                  topRight: Radius.circular(7),
                                                )),
                                            child: const Text(
                                              "VIEW BOQ",
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                decoration: const BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(7),
                                                      bottomRight:
                                                          Radius.circular(7),
                                                    )),
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
                                          ],
                                          content: Container(
                                            height: 320,
                                            width: 400,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                contractLists.uploadNoteImage!
                                                            .length !=
                                                        0
                                                    ? Expanded(
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Wrap(
                                                            children: List.generate(
                                                                growable: true,
                                                                contractLists
                                                                    .uploadNoteImage!
                                                                    .length,
                                                                (index) {
                                                              return Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              10,
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              10),
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      // contractLists
                                                                      //             .uploadNoteImage?[
                                                                      //                 index]
                                                                      //             .toString()
                                                                      //             .split(
                                                                      //                 ".")
                                                                      //             .contains('.pdf')
                                                                      //             ==
                                                                      //         'pdf'
                                                                      // ?
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder:
                                                                              (_) {
                                                                            return PdfViewer(
                                                                              fileName: contractLists.uploadNoteImage?[index]["image_name"].toString(),
                                                                              fileUrl: '${AppUrl.globalUploadWoBoqURL}${contractLists.uploadNoteImage?[index]["image_name"].toString()}',
                                                                            );
                                                                          },
                                                                        ),
                                                                      );
                                                                      // : Navigator
                                                                      //     .push(
                                                                      //     context,
                                                                      //     MaterialPageRoute(
                                                                      //       builder:
                                                                      //           (_) {
                                                                      //         return ImagePreviewViewer(
                                                                      //           fileName: contractLists.uploadNoteImage?[index]["image_name"].toString(),
                                                                      //           fileUrl: '${AppUrl.globalUploadWoBoqURL}${contractLists.uploadNoteImage?[index]["image_name"].toString()}',
                                                                      //         );
                                                                      //       },
                                                                      //     ),
                                                                      //   );
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          129,
                                                                      height:
                                                                          140,
                                                                      decoration: BoxDecoration(
                                                                          border:
                                                                              Border.all(color: Colors.grey),
                                                                          borderRadius: BorderRadius.circular(5)),
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          const SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          contractLists.uploadNoteImage?[index]["image_name"].toString().split(".").last == 'pdf'
                                                                              ? Image.asset(
                                                                                  'images/projectmanagement/pdf.png',
                                                                                  width: 100.0,
                                                                                  height: 100.0,
                                                                                  fit: BoxFit.cover,
                                                                                )
                                                                              : Image.network(
                                                                                  '${AppUrl.globalUploadWoBoqURL}${contractLists.uploadNoteImage?[index].toString()}',
                                                                                  width: 100,
                                                                                  height: 100,
                                                                                ),
                                                                          const SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Text(contractLists.uploadNoteImage?[index]["image_name"].toString().capitalize() ??
                                                                              ''),
                                                                          const SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ));
                                                            }),
                                                          ),
                                                        ),
                                                      )
                                                    : Expanded(
                                                        child: Center(
                                                          child: Text(
                                                            "No Result Found",
                                                            style: TextStyle(
                                                                fontSize: 16),
                                                          ),
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ));
                              },
                              child: Container(
                                width: 110,
                                height: 33,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(17),
                                  border: Border.all(
                                    color: Colors.black,
                                  ),
                                ),
                                child: const Text(
                                  'VIEW BOQ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 13.0,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: Text(
                                contractLists.companyType! == 'consultant'
                                    ? 'Consultant Type'
                                    : 'Contractor Type',
                                style: const TextStyle(
                                    backgroundColor: Colors.white,
                                    fontSize: 15,
                                    color: Colors.black)),
                          ),
                          horizontalSpaceMedium,
                          const Center(
                              child: Icon(Icons.remove, color: Colors.black54)),
                          horizontalSpaceLarge,
                          Text(contractLists.contractType!,
                              style: const TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 200,
                            child: Text('Amount Due',
                                style: TextStyle(
                                    backgroundColor: Colors.white,
                                    fontSize: 15,
                                    color: Colors.black)),
                          ),
                          horizontalSpaceMedium,
                          const Center(
                              child: Icon(Icons.remove, color: Colors.black54)),
                          horizontalSpaceLarge,
                          Text(
                              currencyFormat.format(
                                  double.parse(contractLists.dueamount ?? '0')),
                              style: double.parse(
                                          contractLists.dueamount ?? '0') ==
                                      0.00
                                  ? const TextStyle(
                                      backgroundColor: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)
                                  : const TextStyle(
                                      backgroundColor: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red)),
                          const Expanded(child: horizontalSpaceLarge),
                          SizedBox(
                            width: 110,
                            height: 33,
                            child: Container(
                              width: double.infinity,
                              height: 33,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(17),
                                border: Border.all(
                                  color: Colors.black,
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  var projectId = this.projectId!;
                                  var projectName = this.projectName!;
                                  if (projectId.isEmpty) {
                                    projectId = contractLists.projectId!;
                                    projectName = contractLists.projectName!;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return WoInvoiceList(
                                          projectId: projectId,
                                          towarId: towarId!,
                                          projectName: projectName,
                                          orderId: contractLists.woOrderId!,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: const Text(
                                  'VIEW INVOICE',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 13.0,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // contractLists.woOrderNo! != '--'
                    // ?
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 200,
                            child: Text(
                              'Status',
                              style: TextStyle(
                                backgroundColor: Colors.white,
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          horizontalSpaceMedium,
                          const Center(
                              child: Icon(Icons.remove, color: Colors.black54)),
                          horizontalSpaceLarge,
                          Text(
                              contractLists.woRuningStatus != null
                                  ? contractLists.woRuningStatus! == '0'
                                      ? 'Open'
                                      : 'Closed'
                                  : 'Open',
                              style: TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 15,
                                  color: contractLists.woRuningStatus != null
                                      ? contractLists.woRuningStatus! == '0'
                                          ? Colors.green
                                          : Colors.red
                                      : Colors.green)),
                          Spacer(),
                          Text(
                            "Pending Invoices ${contractLists.pendingInvoice}/${contractLists.totalInvoice}",
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    )
                    // : const SizedBox(),
                  ],
                ),
                verticalSpaceSmall,
                const Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 1,
                  endIndent: 1,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.error,
          color: Colors.grey,
        ),
        Text('No Record Found'),
      ],
    );
  }
}
