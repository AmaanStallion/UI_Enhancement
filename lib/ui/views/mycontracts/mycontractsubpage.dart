import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/ui/views/mycontracts/woinvoicelist.dart';
import 'package:stallion/utils/remove_temp_file.dart';

import '../../../models/get_project_my_contracts_sublist.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import '../accountmanagement/wopreviewhtml.dart';
import '../rccstructure/pdfviewer.dart';
import 'imagepreviewview.dart';
import 'mycontractdetailview.dart';

class MyContractsSubView extends StatefulWidget {
  MyContractsSubView({
    Key? key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.companyId,
    this.gradeId,
    this.companyType,
    this.contractorName,
    required this.categoryId,
    required this.developerId,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? companyId;
  final String? gradeId;
  final String? companyType;
  final String? contractorName;
  final String? categoryId;
  final String? developerId;

  @override
  State<MyContractsSubView> createState() => _MyContractsSubViewState();
}

class _MyContractsSubViewState extends State<MyContractsSubView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  bool flagcalled = false;

  List<ContractList>? contractLists = [];
  TotalBar? totalBar;
  List<OrderList>? orderList = [];

  double? costToComplete = 0.0;

  String? offset = '0';
  String searchTermValue = '';
  TextEditingController editingController = TextEditingController();

  Future<ResponseGetProjectMyContractsSubListing?>
      fetchProjectMyContracts() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    String? loginType = prefs.getString('loginType');

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": widget.projectId ?? '',
      "towar_id": towerId,
      "grade_id": widget.gradeId ?? '',
      "company_id": widget.companyId ?? '',
      "limit": "20",
      "offset": offset ?? '',
      "search_data": searchTermValue,
      "login_type": loginType ?? '',
      "category_id": widget.categoryId ?? '',
      "developer_id": widget.developerId ?? '',
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(
        AppUrl.getprojectmycontractscompanylist, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getProjectMyContractsSubListingFromJson(response.body);
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

        List<ContractList>? actualList = [];
        actualList = dataModel.response?.contractLists!;

        if (contractLists!.isEmpty) {
          contractLists = actualList;
        } else {
          for (int i = 0; i < actualList!.length; i++) {
            contractLists?.add(actualList![i]);
          }
        }

        if (orderList!.isEmpty) {
          orderList = dataModel.response?.orderList!;
        }
        totalBar = dataModel.response?.totalBar!;

        setState(() {
          double? discountAmt = 0.0;
          if (totalBar!.discountAmount!.isNotEmpty) {
            discountAmt = double.parse(totalBar!.discountAmount!);
          }
          if (totalBar!.totalAmount!.isNotEmpty) {
            costToComplete = double.parse(totalBar!.totalAmount!);
          }

          // if (totalBar!.totalPaid!.isNotEmpty) {
          //   costToComplete = costToComplete! -
          //       (double.parse(totalBar!.totalPaid!) + discountAmt);
          // }
          flagcalled = true;
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 500));

    offset = '0';
    searchTermValue = '';
    contractLists = [];

    fetchProjectMyContracts();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 500));
    fetchProjectMyContracts();
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    fetchProjectMyContracts();
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
              '${widget.projectName!.toUpperCase()} - ${widget.contractorName!}',
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
          height: double.infinity,
          color: Colors.white,
          child: SafeArea(
            child: flagcalled == true
                ? Column(
                    children: [
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
                      Expanded(
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
                            itemCount: contractLists!.length,
                            itemBuilder: (context, index) {
                              var arrUploadImg =
                                  contractLists![index].uploadNoteImage!;
                              var totPer = 0.0;
                              if (contractLists![index].totalPercentage! !=
                                  '') {
                                totPer = double.parse(double.parse(
                                        contractLists![index].totalPercentage!)
                                    .toStringAsFixed(0));
                              }

                              return Column(
                                children: [
                                  ListTile(
                                    onTap: () {
                                      var projectId = widget.projectId!;
                                      var projectName = widget.projectName!;
                                      if (projectId.isEmpty) {
                                        projectId =
                                            contractLists![index].projectId!;
                                        projectName =
                                            contractLists![index].projectName!;
                                      }
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (_) {
                                      //       return MyContractsDetailView(
                                      //           projectId: projectId,
                                      //           towarId: widget.towarId!,
                                      //           projectName: projectName,
                                      //           gradeId: contractLists![index]
                                      //               .gradeId!,
                                      //           companyId: contractLists![index]
                                      //                   .companyIdFk ??
                                      //               ' ',
                                      //           workorderId:
                                      // contractLists![index]
                                      //     .woOrderId!,
                                      //           workId: contractLists![index]
                                      //               .woOrderNo!,
                                      //           contractorName:
                                      //               contractLists![index]
                                      //                   .mstCompanyName!
                                      //                   .toUpperCase());
                                      //     },
                                      //   ),
                                      // );
                                      Navigator.of(context).pushNamed(
                                        '/myContractsDetailViewScreen',
                                        arguments: NotificationArgs(
                                          projectId: projectId,
                                          projectName: projectName,
                                          towarName: widget.towarId,
                                          response: NotificationResponseData(
                                            towarId: widget.towarId,
                                            woOrderId:
                                                contractLists![index].woOrderId,
                                            woOrderNo:
                                                contractLists![index].woOrderNo,
                                            // assignToId: assignToId ?? '',
                                          ),
                                        ),
                                      );
                                    },
                                    trailing:
                                        const Icon(Icons.keyboard_arrow_right),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 50, right: 10, top: 10),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 200,
                                                child: Text(
                                                    widget.companyType! ==
                                                            'consultant'
                                                        ? 'Consultant Name'
                                                        : 'Contractor Name',
                                                    style: const TextStyle(
                                                        backgroundColor:
                                                            Colors.white,
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                              ),
                                              horizontalSpaceMedium,
                                              const Center(
                                                  child: Icon(Icons.remove,
                                                      color: Colors.black54)),
                                              horizontalSpaceLarge,
                                              Text(
                                                  contractLists![index]
                                                      .mstCompanyName!,
                                                  style: const TextStyle(
                                                      backgroundColor:
                                                          Colors.white,
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                              const Expanded(
                                                  child: horizontalSpaceLarge),
                                              contractLists![index]
                                                          .woOrderNo! ==
                                                      '--'
                                                  ? const SizedBox()
                                                  : Stack(children: [
                                                      // SizedBox(
                                                      //   height: 64,
                                                      //   child: OverflowBox(
                                                      //     minHeight: 100,
                                                      //     maxHeight: 100,
                                                      //     child: Lottie.asset(
                                                      //       'assets/animation/running2.json',
                                                      //       // 'assets/animation/chatbotfinallotiie.json',
                                                      //       repeat: true,
                                                      //     ),
                                                      //   ),
                                                      // ),
                                                      SizedBox(
                                                          width: 35,
                                                          height: 35,
                                                          child:
                                                              CircularProgressIndicator(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .grey,
                                                                  color: Colors
                                                                      .green,
                                                                  strokeWidth:
                                                                      4,
                                                                  value:
                                                                      totPer)),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 6,
                                                                top: 11),
                                                        child: Text('$totPer%',
                                                            style:
                                                                const TextStyle(
                                                                    fontSize: 9,
                                                                    color: Colors
                                                                        .black)),
                                                      ),
                                                    ]),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 50, right: 10, top: 10),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 200,
                                                child: Text('Work Order Number',
                                                    style: TextStyle(
                                                        backgroundColor:
                                                            Colors.white,
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                              ),
                                              horizontalSpaceMedium,
                                              const Center(
                                                  child: Icon(Icons.remove,
                                                      color: Colors.black54)),
                                              horizontalSpaceLarge,
                                              Text(
                                                  contractLists![index]
                                                      .woOrderNo!,
                                                  style: const TextStyle(
                                                      backgroundColor:
                                                          Colors.white,
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                              const Expanded(
                                                  child: horizontalSpaceLarge),
                                              contractLists![index]
                                                          .woOrderNo! !=
                                                      '--'
                                                  ? SizedBox(
                                                      width: 110,
                                                      height: 33,
                                                      child: Container(
                                                        width: double.infinity,
                                                        height: 33,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(17),
                                                          border: Border.all(
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        child: InkWell(
                                                          onTap: () {
                                                            var projectId =
                                                                widget
                                                                    .projectId!;
                                                            var projectName =
                                                                widget
                                                                    .projectName!;
                                                            if (projectId
                                                                .isEmpty) {
                                                              projectId =
                                                                  contractLists![
                                                                          index]
                                                                      .projectId!;
                                                              projectName =
                                                                  contractLists![
                                                                          index]
                                                                      .projectName!;
                                                            }
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (_) {
                                                                  return WoPreviewHtml(
                                                                      projectId:
                                                                          projectId,
                                                                      projectName:
                                                                          projectName,
                                                                      workOrderId:
                                                                          contractLists![index]
                                                                              .woOrderId!,
                                                                      workOrderNo: contractLists![
                                                                              index]
                                                                          .woOrderNo!
                                                                          .toUpperCase(),
                                                                      flagRedirect:
                                                                          'project');
                                                                },
                                                              ),
                                                            ).then(
                                                                (value) => {});
                                                          },
                                                          child: const Text(
                                                            'VIEW WO',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .normal,
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
                                          padding: const EdgeInsets.only(
                                              left: 50, right: 10, top: 10),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 200,
                                                child: Text('Project Name',
                                                    style: TextStyle(
                                                        backgroundColor:
                                                            Colors.white,
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                              ),
                                              horizontalSpaceMedium,
                                              const Center(
                                                  child: Icon(Icons.remove,
                                                      color: Colors.black54)),
                                              horizontalSpaceLarge,
                                              Text(
                                                  contractLists![index]
                                                      .projectName!,
                                                  style: const TextStyle(
                                                      backgroundColor:
                                                          Colors.white,
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                              const Expanded(
                                                  child: horizontalSpaceLarge),
                                              contractLists![index]
                                                      .uploadNoteImage!
                                                      .isNotEmpty
                                                  ? SizedBox(
                                                      width: 110,
                                                      height: 33,
                                                      child: Container(
                                                        width: double.infinity,
                                                        height: 33,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(17),
                                                          border: Border.all(
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        child: InkWell(
                                                          onTap: () {
                                                            showDialog(
                                                                barrierDismissible:
                                                                    false,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                            context) =>
                                                                        Dialog(
                                                                          elevation:
                                                                              0,
                                                                          child:
                                                                              Container(
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
                                                                                                            return PdfViewer(
                                                                                                              fileName: arrUploadImg[index]["image_name"].toString(),
                                                                                                              fileUrl: '${AppUrl.globalUploadWoBoqURLMain}${arrUploadImg[index]["image_name"].toString()}',
                                                                                                            );
                                                                                                          },
                                                                                                        ),
                                                                                                      )
                                                                                                    : Navigator.push(
                                                                                                        context,
                                                                                                        MaterialPageRoute(
                                                                                                          builder: (_) {
                                                                                                            return ImagePreviewViewer(
                                                                                                              fileName: arrUploadImg[index]["image_name"].toString(),
                                                                                                              fileUrl: '${AppUrl.globalUploadWoBoqURLMain}${arrUploadImg[index]["image_name"].toString()}',
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
                                                                                                    arrUploadImg[index]["image_name"].toString().split(".").last == 'pdf'
                                                                                                        ? Image.asset(
                                                                                                            'images/projectmanagement/pdf.png',
                                                                                                            width: 100.0,
                                                                                                            height: 100.0,
                                                                                                            fit: BoxFit.cover,
                                                                                                          )
                                                                                                        : Image.network(
                                                                                                            '${AppUrl.globalUploadWoBoqURLMain}${arrUploadImg[index]["image_name"].toString()}',
                                                                                                            width: 100,
                                                                                                            height: 100,
                                                                                                          ),
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
                                                          child: const Text(
                                                            'VIEW BOQ',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .normal,
                                                              fontSize: 13.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ))
                                                  : const SizedBox()
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 50, right: 10, top: 10),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 200,
                                                child: Text(
                                                    widget.companyType! ==
                                                            'consultant'
                                                        ? 'Consultant Type'
                                                        : 'Contractor Type',
                                                    style: const TextStyle(
                                                        backgroundColor:
                                                            Colors.white,
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                              ),
                                              horizontalSpaceMedium,
                                              const Center(
                                                  child: Icon(Icons.remove,
                                                      color: Colors.black54)),
                                              horizontalSpaceLarge,
                                              Text(
                                                  contractLists![index]
                                                      .contractType!,
                                                  style: const TextStyle(
                                                      backgroundColor:
                                                          Colors.white,
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 50, right: 10, top: 10),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 200,
                                                child: Text('Amount Due',
                                                    style: TextStyle(
                                                        backgroundColor:
                                                            Colors.white,
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                              ),
                                              horizontalSpaceMedium,
                                              const Center(
                                                  child: Icon(Icons.remove,
                                                      color: Colors.black54)),
                                              horizontalSpaceLarge,
                                              Text(
                                                  currencyFormat.format(
                                                      double.parse(
                                                          contractLists![index]
                                                              .dueamount!)),
                                                  style: const TextStyle(
                                                      backgroundColor:
                                                          Colors.white,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.red)),
                                              const Expanded(
                                                  child: horizontalSpaceLarge),
                                              SizedBox(
                                                  width: 110,
                                                  height: 33,
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 33,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              17),
                                                      border: Border.all(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    child: InkWell(
                                                      onTap: () {
                                                        var projectId =
                                                            widget.projectId!;
                                                        var projectName =
                                                            widget.projectName!;
                                                        if (projectId.isEmpty) {
                                                          projectId =
                                                              contractLists![
                                                                      index]
                                                                  .projectId!;
                                                          projectName =
                                                              contractLists![
                                                                      index]
                                                                  .projectName!;
                                                        }
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (_) {
                                                              return WoInvoiceList(
                                                                projectId:
                                                                    projectId,
                                                                projectName:
                                                                    projectName,
                                                                orderId: contractLists![
                                                                        index]
                                                                    .woOrderId!,
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      },
                                                      child: const Text(
                                                        'VIEW INVOICE',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 13.0,
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 50, right: 10, top: 10),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 200,
                                                child: Text('Status',
                                                    style: TextStyle(
                                                        backgroundColor:
                                                            Colors.white,
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                              ),
                                              horizontalSpaceMedium,
                                              const Center(
                                                  child: Icon(Icons.remove,
                                                      color: Colors.black54)),
                                              horizontalSpaceLarge,
                                              Text(
                                                  contractLists?[index]
                                                              .woRuningStatus !=
                                                          null
                                                      ? contractLists![
                                                                      index]
                                                                  .woRuningStatus! ==
                                                              '0'
                                                          ? 'Open'
                                                          : 'Closed'
                                                      : 'Open',
                                                  style: TextStyle(
                                                      backgroundColor:
                                                          Colors.white,
                                                      fontSize: 15,
                                                      color: contractLists?[
                                                                      index]
                                                                  .woRuningStatus !=
                                                              null
                                                          ? contractLists![
                                                                          index]
                                                                      .woRuningStatus! ==
                                                                  '0'
                                                              ? const Color
                                                                  .fromRGBO(0,
                                                                  128, 43, 1.0)
                                                              : Colors.red
                                                          : const Color
                                                              .fromRGBO(0, 128,
                                                              43, 1.0))),
                                              const Spacer(),
                                              Text(
                                                "Pending Invoices ${contractLists![index].pendingInvoice}/${contractLists![index].totalInvoice}",
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                ),
                                                textAlign: TextAlign.end,
                                              ),
                                            ],
                                          ),
                                        ),
                                        verticalSpaceSmall15,
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
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 1,
                        endIndent: 1,
                        color: Colors.black,
                      ),
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
                                      Text(currencyFormat.format(double.parse(
                                          totalBar!.totalAmount!))),
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
                                          double.parse(totalBar!.workDone!)))
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
                                      Text(currencyFormat.format(double.parse(
                                          totalBar!.totalPaid ?? '0'))),
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
                                          currencyFormat.format(double.parse(
                                              totalBar!.payables!)),
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 1,
                        endIndent: 1,
                        color: Colors.black,
                      ),
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
                : SizedBox(
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
            // const Center(child: CircularProgressIndicator())
          ),
        ));
  }
}
