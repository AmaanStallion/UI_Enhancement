import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/models/tenantList.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/salesleadPage.dart';
import 'package:stallion/ui/views/salesmanagement/viewdocumentsview.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/ui/widgets/card_title_icon.dart';
import 'package:stallion/ui/widgets/row_three_text.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
// class TenantManagementList extends StatefulWidget {
//   String? projectId;
//   String? towarId;
//   String? projectName;
//   String? towarName;
//   TenantManagementList({
//     super.key,
//     this.towarId,
//     this.projectId,
//     this.projectName,
//     this.towarName,
//   });

//   @override
//   State<TenantManagementList> createState() => _TenantManagementListState();
// }
class TenantManagementList extends StatefulWidget {
  const TenantManagementList({super.key});

  @override
  State<TenantManagementList> createState() => _TenantManagementListState();
}

TextEditingController editingController = TextEditingController();
final RefreshController _refreshController =
    RefreshController(initialRefresh: false);

class _TenantManagementListState extends State<TenantManagementList> {
  late NotificationArgs args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context)!.settings.arguments as NotificationArgs;
  }

  Color getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  Color hexToColorSafe(String? hex) {
    try {
      if (hex == null || hex.isEmpty) return Colors.black;
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.black;
    }
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<FilterArr>? filterArr;
  ResponseTenantList? responseData;
  // bool isTransit = true;
  String typeTransit = '';
  String? transitCount = '0';
  String? rentalCount = '0';
  String selectedSortBy = "";
  String filterType = "";
  List<TenantListElement>? tenantList;
  String? tenantLink = '';

  Future<ResponseTenantList?> getAllTenants() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": args.projectId!,
      "towar_id": args.response?.towarId ?? '',
      "offset": offset ?? "0",
      "type": typeTransit, //isTransit ? "2" : "1",
      "limit": '20',
      'search_data':
          editingController.text.length > 2 ? editingController.text : "",
      'filter': selectedSortBy,
      "filter_type": filterType,
    };
    var response =
        await apiNetworkHandler.post(AppUrl.webGetProjectTenantList, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = tenantListFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          tenantLink = dataModel.response?.tenantLink;
          if (typeTransit == "") {
            transitCount = dataModel.response?.transitCount ?? '';
            rentalCount = dataModel.response?.rentalCount ?? '';
            typeTransit = dataModel.response?.type ?? '';
          }

          if (offset == "0") {
            tenantList = dataModel.response?.tenantList;
          } else {
            tenantList = [...?tenantList, ...?dataModel.response?.tenantList];
          }
          offset = dataModel.response?.offset;
          filterArr = dataModel.response?.filterArr;
          responseData = dataModel.response;
        });
      }
    }
    return null;
  }

  String? offset = '0';
  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));

    offset = '0';

    // getAllSalesLeadRefresh();
    getAllTenants();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));

    // getAllSalesLeadRefresh();
    getAllTenants();
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    getAllTenants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        color: Colors.black,
        height: 50,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(
                        right: BorderSide(
                  width: 1.5,
                  color: Colors.white,
                ))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppText(
                      title: "Total Tenants",
                      fontSize: 16,
                      titleColor: Colors.white,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    AppText(
                      title: responseData?.totalTenants ?? '',
                      fontSize: 16,
                      titleColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(
                        right: BorderSide(
                  width: 1.5,
                  color: Colors.white,
                ))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppText(
                      title: "Signed Consents",
                      fontSize: 16,
                      titleColor: Colors.white,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    AppText(
                      title: responseData?.registeredPaa ?? '',
                      fontSize: 16,
                      titleColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppText(
                    title: "Registered PAAA",
                    fontSize: 16,
                    titleColor: Colors.white,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  AppText(
                    title: responseData?.signedConsents ?? '',
                    fontSize: 16,
                    titleColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: () async {
              if (tenantLink != "") {
                final uri = Uri.parse(tenantLink ?? '');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  throw 'Could not launch';
                }
              }
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
                  "Tenant Form",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            args.towarName!.isNotEmpty
                ? '${args.projectName!.toUpperCase()} - ${args.towarName!.toUpperCase()}'
                : args.projectName!.toUpperCase(),
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            titlePadding: EdgeInsets.zero,
                            title: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                              ),
                              child: const Text(
                                "SORT BY",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(50),
                                    backgroundColor: Colors.black,
                                    fixedSize: const Size.fromWidth(100),
                                    padding: const EdgeInsets.all(10),
                                    textStyle:
                                        const TextStyle(color: Colors.white)),
                                child: const Text('OK',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14.0,
                                        color: Colors.white)),
                                onPressed: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                              ),
                            ],
                            content: StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              return SizedBox(
                                height: 300,
                                width: 400,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      for (int i = 0;
                                          i < filterArr!.length;
                                          i++)
                                        Container(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                            color: Colors.grey,
                                          ))),
                                          child: RadioListTile<String>(
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(
                                              filterArr?[i].title ?? '',
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            value: filterArr?[i].id ?? '',
                                            groupValue: selectedSortBy,
                                            onChanged: (value) {
                                              setState(() {
                                                offset = "0";
                                                selectedSortBy = value ?? '';
                                                filterType =
                                                    filterArr?[i].type ?? '';
                                                // intrestContoller.text =
                                                value ?? '';
                                              });
                                              // getAllSalesLead();
                                              getAllTenants();
                                              Navigator.pop(context);
                                            },
                                            controlAffinity:
                                                ListTileControlAffinity
                                                    .trailing,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }));
                      });
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 60),
                  child: Image.asset(
                    'images/projectmanagement/filter-sort-icon.png',
                    height: 20,
                  ),
                ),
              ),
              const Spacer(),
              const SizedBox(
                child: AppText(
                  title: "TENANT MANAGEMENT",
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  titleTextAlign: TextAlign.right,
                ),
              ),
              const Spacer(),
              Container(
                height: 20,
                padding: const EdgeInsets.only(left: 60),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 64),
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                if (transitCount != '0')
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          typeTransit = '2';
                          // isTransit = true;
                          selectedSortBy = '';
                          offset = "0";
                        });
                        getAllTenants();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                            color: typeTransit == '2'
                                ? Colors.black
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8)),
                        child: AppText(
                          title: "Transit",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          titleTextAlign: TextAlign.center,
                          titleColor:
                              typeTransit == '2' ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                if (rentalCount != '0')
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          typeTransit = '1';
                          // isTransit = false;
                          selectedSortBy = '';
                          offset = "0";
                        });
                        getAllTenants();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                            color: typeTransit == '1'
                                ? Colors.black
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8)),
                        child: AppText(
                          title: "Rental",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          titleTextAlign: TextAlign.center,
                          titleColor:
                              typeTransit == '1' ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 66,
              right: 66,
              bottom: 12,
              top: 12,
            ),
            child: SizedBox(
              height: 40,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    offset = "0";
                  });
                  getAllTenants();
                },
                style: const TextStyle(fontSize: 13),
                controller: editingController,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12.0),
                    labelText: "Search by Name",
                    hintText: "Search by Name",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: editingController.text.isNotEmpty
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                offset = "0";
                              });
                              editingController.clear();
                              getAllTenants();
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
          ),
          const Divider(),
          Expanded(
            child: responseData == null
                ? Center(
                    child:
                        // CircularProgressIndicator()

                        SizedBox(
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
                : tenantList?.length != 0
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
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 82, right: 60),
                                  child: cardTitleIcon(
                                    context: context,
                                    title: tenantList?[index].tenantName ?? '',
                                    listWidget: [
                                      const Spacer(),
                                      if (tenantList?[index].tenantFlagOpt ==
                                          "2")
                                        Image.asset(
                                          'images/projectmanagement/red_flagI_icon.png',
                                          height: 20,
                                          width: 20,
                                          fit: BoxFit.cover,
                                        ),
                                      const SizedBox(width: 10),
                                      InkWell(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  titlePadding: EdgeInsets.zero,
                                                  actionsPadding:
                                                      EdgeInsets.zero,
                                                  title: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8,
                                                        horizontal: 8),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.black,
                                                    ),
                                                    child: Text(
                                                      tenantList?[index]
                                                              .tenantName ??
                                                          '',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                          minimumSize: const Size
                                                              .fromHeight(50),
                                                          backgroundColor:
                                                              Colors.black,
                                                          fixedSize: const Size
                                                              .fromWidth(100),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          textStyle:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                      child: const Text('CLOSE',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 14.0,
                                                              color: Colors
                                                                  .white)),
                                                      onPressed: () {
                                                        setState(() {
                                                          Navigator.pop(
                                                              context);
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                  content: responseData
                                                              ?.tenantList
                                                              ?.isNotEmpty ==
                                                          true
                                                      ? Container(
                                                          child: Row(
                                                            children: [
                                                              const AppText(
                                                                title:
                                                                    'Mobile Number : ',
                                                                titleColor:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 16,
                                                              ),
                                                              AppText(
                                                                title: responseData
                                                                            ?.tenantList?[
                                                                                index]
                                                                            .mobile
                                                                            ?.length !=
                                                                        0
                                                                    ? responseData
                                                                            ?.tenantList![index]
                                                                            .mobile ??
                                                                        ''
                                                                    : "No Record Found",
                                                                titleColor:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 16,
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : const SizedBox(
                                                          child: AppText(
                                                            title:
                                                                "No Record Found",
                                                            titleColor:
                                                                Colors.black,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                );
                                              });
                                        },
                                        child: SvgPicture.asset(
                                          'images/projectmanagement/whatsappIcon.svg',
                                          height: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      InkWell(
                                        onTap: () async {
                                          final Uri emailUrl = Uri(
                                            scheme: 'mailto',
                                            path: tenantList?[index].email,
                                          );

                                          if (await canLaunchUrl(emailUrl)) {
                                            launchUrl(emailUrl);
                                          } else {
                                            throw Exception(
                                                "couldnot launch url");
                                          }
                                        },
                                        child: SvgPicture.asset(
                                          'images/projectmanagement/emailIcon.svg',
                                          height: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          color: tenantList?[index]
                                                      .userResidntName ==
                                                  "Resident"
                                              ? const Color(0xFF3678E9)
                                              : tenantList?[index]
                                                          .userResidntName ==
                                                      "Non-Resident"
                                                  ? const Color(0XFFD7AA42)
                                                  : hexToColorSafe(tenantList?[
                                                          index]
                                                      .labelColor), //getRandomColor()
                                          border: Border.all(
                                              color: tenantList?[index]
                                                          .labelColor ==
                                                      "#ffffff"
                                                  ? Colors.black
                                                  : Colors.transparent),
                                        ),
                                        child: AppText(
                                          title: tenantList?[index]
                                                  .userResidntName ??
                                              '',
                                          fontSize: 14,
                                          titleColor: tenantList?[index]
                                                      .userResidntName ==
                                                  "Resident"
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                tenantCard(tenantList: tenantList?[index]),
                              ],
                            );
                          },
                          itemCount: tenantList?.length ?? 0,
                          separatorBuilder: (context1, index) => Container(
                            padding: const EdgeInsets.only(left: 82, right: 60),
                            child: const Divider(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )
                    : const Center(
                        child: AppText(
                          title: "No Record Found",
                          fontSize: 16,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget tenantCard({required TenantListElement? tenantList}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 60),
          width: MediaQuery.of(context).size.width * 0.7,
          child: Column(
            children: [
              rowThreeText(
                  context: context,
                  title: "Demolition Date",
                  titleValue: '${tenantList?.demolitionDt}'),
              rowThreeText(
                  context: context,
                  title: "Existing Area",
                  titleValue: '${tenantList?.areaInSqft} Sq.Ft.'),
              rowThreeText(
                context: context,
                title: "Proposed Area",
                titleValue: '${tenantList?.proposedAreaInSqft} Sq.Ft.',
              ),
              rowThreeText(
                context: context,
                title: "Alloted Flat",
                titleValue: tenantList?.numberAllocated ?? '',
              ),
              rowThreeText(
                context: context,
                title: "Category",
                titleValue: tenantList?.categoryName ?? '0',
              ),
              rowThreeText(
                context: context,
                title: "Monthly Rent",
                titleValue: currencyFormat
                    .format(double.parse(tenantList?.monthRent ?? '0')),
              ),
              if (tenantList?.brokerage != '0')
                rowThreeText(
                  context: context,
                  title: "Brokerage",
                  titleValue: currencyFormat
                      .format(double.parse(tenantList?.brokerage ?? '0')),
                ),
              if (tenantList?.shiftingCharges != '0')
                rowThreeText(
                  context: context,
                  title: "Shifting Chrg.",
                  titleValue: currencyFormat
                      .format(double.parse(tenantList?.shiftingCharges ?? '0')),
                ),
              rowThreeText(
                context: context,
                title: "Corpus",
                titleValue: currencyFormat
                    .format(double.parse(tenantList?.corpusAmount ?? '0')),
                // currencyFormat
                //     .format(double.parse(tenantList?.shiftingCharges ?? '0')),
              ),
              for (int j = 0; j < tenantList!.details!.length; j++)
                rowThreeText(
                  context: context,
                  title: tenantList.details?[j]['year_name'],
                  titleSubValueColor: tenantList.details?[j]['paid'] == "1"
                      ? Colors.green
                      : Colors.black,
                  titleSubValue:
                      tenantList.details?[j]['paid'] == "1" ? " (Paid)" : "",
                  titleValue: currencyFormat.format(
                      double.parse(tenantList.details?[j]['amount_per_year'])),
                )
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.only(right: 60),
          width: MediaQuery.of(context).size.width * 0.3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              documentStatus(
                status: tenantList.docName1 == '1',
                title: "Consent",
              ),
              documentStatus(
                status: tenantList.docName2 == '1',
                title: "PAAA",
              ),
              documentStatus(
                status: tenantList.docName3 == '1',
                title: "Identity Proof",
              ),
              documentStatus(
                status: tenantList.docName4 == '1',
                title: "TOT",
              ),
              documentStatus(
                status: tenantList.docName5 == '1',
                title: "Receipt",
              ),
              InkWell(
                onTap: () {
                  var projectId = args.projectId!;
                  var projectName = args.projectName!;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return ViewDocumentsView(
                          projectId: projectId,
                          projectName: projectName,
                          towarName: args.towarName,
                          towarId: args.response?.towarId ?? '',
                          flatBuyerID: tenantList.tenantId,
                          flatFunding: "",
                          flagFrom: 'TENANAT',
                          titleName: tenantList.tenantName,
                          tenantList: tenantList.docName5 == '1',
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.grey,
                      )),
                  child: const AppText(
                    title: "View Docs",
                    fontSize: 16,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget documentStatus({
    required String title,
    required bool status,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AppText(
            title: title,
            fontSize: 14,
          ),
          const SizedBox(width: 8),
          Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
            ),
            child: status
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
                        borderRadius: BorderRadius.circular(100)),
                  ),
          ),
        ],
      ),
    );
  }
}
