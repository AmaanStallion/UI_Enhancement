import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stallion/models/get_all_sales_lead.dart';
import 'package:stallion/models/get_broker_list.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/salesmanagement/brokerManagement/brokerMettingDetail/brokerMettingDetail.dart';
import 'package:stallion/ui/views/salesmanagement/brokerManagement/individualBroketList.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/salesLeadDetailPage.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:url_launcher/url_launcher.dart';

class BrokerManagementList extends StatefulWidget {
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? flagRedirect;
  final String? towarName;

  const BrokerManagementList(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.flagRedirect,
      this.towarName});

  @override
  State<BrokerManagementList> createState() => _BrokerManagementListState();
}

class _BrokerManagementListState extends State<BrokerManagementList> {
  TextEditingController searchController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? offset = '0';
  String? brokerLink = '';

  GetBrokerListResponse? getAllBrokerListResponse;
  TotalBar? totalBar;

  List<BrokerList>? brokerList;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  // get all broker list
  Future<GetBrokerListResponse?> getAllBrokerList() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId!,
      "offset": offset ?? '',
      "limit": "20",
      "broker_search":
          searchController.text.length > 2 ? searchController.text : "",
    };
    var response =
        await apiNetworkHandler.post(AppUrl.webGetAllBrokerList, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getBrokerListFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          brokerLink = dataModel.response?.brokerLink;
          offset = dataModel.response?.offset;
          brokerList = dataModel.response?.brokerList;
          getAllBrokerListResponse = dataModel.response;
          totalBar = dataModel.response?.totalBar;
        });
      }
    }
    return null;
  }

  Future<GetBrokerListResponse?> getAllBrokerListPagination() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId!,
      "offset": offset ?? '',
      "limit": "20",
      "broker_search":
          searchController.text.length > 2 ? searchController.text : "",
    };
    var response =
        await apiNetworkHandler.post(AppUrl.webGetAllBrokerList, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getBrokerListFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          offset = dataModel.response?.offset;
          brokerList = [...?brokerList, ...?dataModel.response!.brokerList];
        });
      }
    }
    return null;
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));

    offset = '0';

    getAllBrokerListPagination();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));

    getAllBrokerListPagination();
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    getAllBrokerList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            border: Border(
                top: BorderSide(
          color: Colors.black,
        ))),
        height: 50,
        child: getAllBrokerListResponse != null
            ? Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    decoration: const BoxDecoration(
                        border: Border(
                            right: BorderSide(
                      color: Colors.black,
                    ))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppText(
                          title: "Total Amount",
                          fontSize: 14,
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          title:
                              getAllBrokerListResponse?.totalBar!.totalAmount !=
                                      ''
                                  ? currencyFormat.format(double.parse(
                                      getAllBrokerListResponse
                                              ?.totalBar?.totalAmount ??
                                          ''))
                                  : "",
                          fontSize: 14,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    decoration: const BoxDecoration(
                        border: Border(
                            right: BorderSide(
                      color: Colors.black,
                    ))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppText(
                          title: "Total Paid",
                          fontSize: 14,
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          title: currencyFormat.format(double.parse(
                              getAllBrokerListResponse?.totalBar?.totalPaid ??
                                  '')),
                          fontSize: 14,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    decoration: const BoxDecoration(
                        border: Border(
                            right: BorderSide(
                      color: Colors.black,
                    ))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppText(
                          title: "Total Balance",
                          fontSize: 14,
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          title: currencyFormat.format(double.parse(
                              getAllBrokerListResponse
                                      ?.totalBar?.totalBalance ??
                                  '')),
                          fontSize: 14,
                          titleColor: Colors.red,
                        ),
                      ],
                    ),
                  )
                ],
              )
            : const SizedBox.shrink(),
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            '${widget.projectName!.toUpperCase()} ${widget.towarName!.isNotEmpty ? "-" : ""} ${widget.towarName!.toUpperCase()}',
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: Row(
              children: [
                SizedBox(width: 143),
                Spacer(),
                AppText(
                  title: "CHANNEL PARTNER'S",
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
                Spacer(),
                InkWell(
                  onTap: () async {
                    if (brokerLink! != "") {
                      print(brokerLink!);
                      final uri = Uri.parse(brokerLink!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        throw 'Could not launch';
                      }
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 9),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppText(
                      title: "Invite CP",
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 60.0, right: 60),
            child: SizedBox(
              height: 40,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    offset = '0';
                  });
                  getAllBrokerList();
                },
                style: const TextStyle(fontSize: 13),
                controller: searchController,
                decoration: InputDecoration(
                    suffixIcon: searchController.text.length > 0
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                offset = '0';
                              });
                              searchController.clear();
                              getAllBrokerList();
                            },
                            child: Container(
                              padding: const EdgeInsets.only(right: 12),
                              child: const Icon(Icons.close_rounded),
                            ),
                          )
                        : const SizedBox.shrink(),
                    contentPadding: const EdgeInsets.all(12.0),
                    labelText: "Search by CP Name",
                    hintText: "Search by CP Name",
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          Expanded(
            child: getAllBrokerListResponse == null
                ? Center(
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
                  )
                // const Center(child: CircularProgressIndicator())
                : brokerList?.length != 0
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
                          itemBuilder: (context1, index) =>
                              _brokercard(brokerData: brokerList![index]),
                          itemCount: brokerList!.length,
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
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _rowTwoText({
    required BuildContext context,
    required String title,
    required String titleValue,
    String? subTitle = '',
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 22),
      width: MediaQuery.of(context).size.width - 120,
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: subTitle!.isEmpty
                ? Text(
                    title,
                    style: const TextStyle(fontSize: 16),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 16),
                      ),
                      AppText(
                        title: subTitle,
                        fontSize: 14,
                        titleColor: Colors.grey,
                      ),
                    ],
                  ),
          ),
          horizontalSpaceMedium,
          const Center(child: Icon(Icons.remove, color: Colors.black54)),
          horizontalSpaceLarge,
          Text(
            titleValue,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _brokercard({required BrokerList brokerData}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return IndividualBrokerList(
                brokerName: brokerData.companyName,
                brokerId: brokerData.brokerId,
                projectId: widget.projectId,
                towarId: widget.towarId,
                projectName: widget.projectName,
                towarName: widget.towarName,
                totalBar: totalBar,
                flagFrom: "BROKERMANAGEMENT",
                cashflowgst: false,
              );
            },
          ),
        ).then((value) => {});
      },
      child: Container(
          padding: const EdgeInsets.only(left: 50),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _rowTwoText(
                  //   context: context,
                  //   title: 'Channel Partner Name',
                  //   titleValue: brokerData.companyName ?? '',
                  // ),
                  Container(
                    padding: const EdgeInsets.only(top: 10, left: 22),
                    width: MediaQuery.of(context).size.width - 120,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 200,
                          child: Text(
                            'Channel Partner Name',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        horizontalSpaceMedium,
                        const Center(
                            child: Icon(Icons.remove, color: Colors.black54)),
                        horizontalSpaceLarge,
                        Text(
                          brokerData.companyName ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return BrokerMettingDetail(
                                    // brokerName: brokerData.companyName,
                                    brokerId: brokerData.brokerId,
                                    projectId: widget.projectId,
                                    towarId: widget.towarId,
                                    projectName: widget.projectName,
                                    towarName: widget.towarName,

                                    // totalBar: totalBar,
                                    // flagFrom: "BROKERMANAGEMENT",
                                    // cashflowgst: false,
                                  );
                                },
                              ),
                            );
                          },
                          child: Image.asset(
                            'images/projectmanagement/StallionMeeting_V1.png',
                            width: 32,
                            height: 32,
                          ),
                        ),
                        SizedBox(
                          width: 30,
                        )
                      ],
                    ),
                  ),
                  _rowTwoText(
                    context: context,
                    title: 'No. of Flats',
                    titleValue: brokerData.totalFlat ?? '',
                  ),
                  _rowTwoText(
                    context: context,
                    title: 'Total Flat Value',
                    subTitle: "(Inc. G.S.T)",
                    titleValue: currencyFormat
                        .format(double.parse(brokerData.totalFlatValue ?? '')),
                  ),
                  _rowTwoText(
                    context: context,
                    title: 'Total Brokerage',
                    subTitle: "(Inc. G.S.T)",
                    titleValue: currencyFormat
                        .format(double.parse(brokerData.brokerTotal!)),
                  ),
                  // _rowTwoText(
                  //   context: context,
                  //   title: 'Brokerage Paid',
                  //   subTitle: "(Inc. G.S.T)",
                  // titleValue: currencyFormat
                  //     .format(double.parse(brokerData.totalPaid ?? '')),
                  // ),
                  Container(
                    padding: const EdgeInsets.only(top: 10, left: 22),
                    width: MediaQuery.of(context).size.width - 120,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Brokerage Paid',
                                style: TextStyle(fontSize: 16),
                              ),
                              AppText(
                                title: '(Inc. G.S.T)',
                                fontSize: 14,
                                titleColor: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        horizontalSpaceMedium,
                        const Center(
                            child: Icon(Icons.remove, color: Colors.black54)),
                        horizontalSpaceLarge,
                        Text(
                          currencyFormat
                              .format(double.parse(brokerData.totalPaid ?? '')),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        if (double.parse(brokerData.totalPaid ?? '') > 0)
                          Text(
                            '(Bal. : ${currencyFormat.format(double.parse(brokerData.totalBalance ?? '0'))})',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        const Spacer(),
                      ],
                    ),
                  )
                ],
              ),
              const Icon(Icons.keyboard_arrow_right)
            ],
          )),
    );
  }
}
