import 'package:stallion/ui/views/accountmanagement/account_management_preview.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/views/accountmanagement/paymentdue/poinvoicetotalpaidList.dart';
import 'package:stallion/ui/views/accountmanagement/paymentdue/popreviewhtmldetails.dart';
import 'package:stallion/ui/views/accountmanagement/paymentdue/viewchallan.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import '../../../../models/get_payment_details_by_vendor.dart';
import '../../../../utils/api_network_call.dart';
import '../../../../utils/app_url.dart';
import '../../../shared/ui_helpers.dart';
import 'invoicelist.dart';

class PaymentCompanyList extends StatefulWidget {
  const PaymentCompanyList(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.vendorId,
      this.gradeId,
      this.gradeName,
      this.isFromBudget = false,
      this.vendorName});
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? vendorId;
  final String? vendorName;
  final String? gradeName;
  final String? gradeId;
  final bool? isFromBudget;

  @override
  State<PaymentCompanyList> createState() => _PaymentCompanyListState();
}

class _PaymentCompanyListState extends State<PaymentCompanyList> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = AccountManagementPreviewNetwork();

  String gradeId = '0';
  String gradeName = 'All Grades';

  String gradeStatus = 'All';
  List<String> arrStatus = [
    'All',
    'Open',
    'Closed',
    'Due',
    'Overdue',
    'Paid',
    'Unpaid'
  ];

  bool flagcalled = false;
  List<PaymentHistory>? paymentHistory = [];
  List<PaymentHistory>? actualpaymentHistory;
  List<VenderGrade>? venderGrade;
  List<SearchDatum>? searchData;
  double totalDue = 0.0;
  DateTime selectedDate = DateTime.now();
  String? totalInvoice = '0';
  String? totalPayment = '0';
  String? totalBalance = '0';
  String? totalOverdue = '0';
  TextEditingController searchController = TextEditingController();
  List<PaymentHistory>? filteredPaymentHistory = [];
  Future<ResponseGetPaymentDetailsByVendor?> wsPaymentHistoryDuelist() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));
    String? userType = (prefs.getString('userType') ??
        (useAccountManagementTestData ? '1' : null));

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    if (kDebugMode) {
      print(formattedDate);
    }

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "vender_id": widget.vendorId!,
      "till_date": formattedDate,
      "user_type": userType!,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.wsvenderpaymenthistory, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getPaymentDetailsByVendorFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          flagcalled = true;
          actualpaymentHistory = dataModel.response?.paymentHistory!;
          paymentHistory = actualpaymentHistory;
          filteredPaymentHistory = dataModel.response?.paymentHistory;
          venderGrade = dataModel.response?.venderGrade!;
          List<SearchDatum>? data = dataModel.response?.searchData!;
          searchData = [];
          searchData?.add(SearchDatum(gradeName: "All Grades", gradeId: "0"));
          for (int i = 0; i < data!.length; i++) {
            searchData?.add(data[i]);
          }

          totalInvoice = dataModel.response?.totalInvoice!;
          totalPayment = dataModel.response?.totalPayment!;
          totalOverdue = dataModel.response?.totalOverdue!;
          totalBalance = dataModel.response?.totalBalance!;
          if (widget.isFromBudget == true) {
            gradeId = widget.gradeId ?? '';
            // gradeName = widget.gradeName ?? '';
            paymentHistory = [];
            for (int i = 0; i < actualpaymentHistory!.length; i++) {
              if (actualpaymentHistory![i].creditType == "0" ||
                  actualpaymentHistory![i].creditType == "2") {
                var arrGrade = actualpaymentHistory![i].orderType!;
                for (int j = 0; j < arrGrade.length; j++) {
                  if (arrGrade[j].gradeId == gradeId) {
                    gradeName = arrGrade[j].gradeName ?? '';
                    paymentHistory!.add(actualpaymentHistory![i]);
                    break;
                  }
                }
              }
            }
          }
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

  void filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredPaymentHistory = paymentHistory;
      });
    } else {
      setState(() {
        filteredPaymentHistory = paymentHistory?.where((payment) {
          // return payment.poNo!.toLowerCase().contains(query.toLowerCase());
          return (payment.poNo != null &&
                  payment.poNo!.toLowerCase().contains(query.toLowerCase())) ||
              (payment.orderTypeComma != null &&
                  payment.orderTypeComma!
                      .toLowerCase()
                      .contains(query.toLowerCase()));
        }).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    wsPaymentHistoryDuelist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.projectName!.toUpperCase(),
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
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
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: const BoxDecoration(
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
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: const BoxDecoration(
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
                          return const SizedBox(
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
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 30, right: 30, top: 10, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                              onTap: () {
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) => Dialog(
                                          elevation: 0,
                                          child: SizedBox(
                                            height: 400,
                                            width: 360.0,
                                            child: Column(
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10.0, bottom: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'SORT BY STATUS',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Divider(
                                                  color: Colors.grey.shade500,
                                                  thickness: 1.5,
                                                ),
                                                SizedBox(
                                                  height: 300,
                                                  width: 360,
                                                  child: ListView.builder(
                                                      itemCount:
                                                          arrStatus.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Column(
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  gradeStatus =
                                                                      arrStatus[
                                                                          index];
                                                                  if (gradeStatus ==
                                                                      'All') {
                                                                    paymentHistory =
                                                                        actualpaymentHistory;
                                                                  } else if (gradeStatus ==
                                                                      'Open') {
                                                                    paymentHistory =
                                                                        [];
                                                                    for (int i =
                                                                            0;
                                                                        i < actualpaymentHistory!.length;
                                                                        i++) {
                                                                      if (actualpaymentHistory![i]
                                                                              .creditType !=
                                                                          '1') {
                                                                        if (actualpaymentHistory![i].status ==
                                                                            '0') {
                                                                          paymentHistory
                                                                              ?.add(actualpaymentHistory![i]);
                                                                        }
                                                                      }
                                                                    }
                                                                  } else if (gradeStatus ==
                                                                      'Closed') {
                                                                    paymentHistory =
                                                                        [];
                                                                    for (int i =
                                                                            0;
                                                                        i < actualpaymentHistory!.length;
                                                                        i++) {
                                                                      if (actualpaymentHistory![i]
                                                                              .creditType !=
                                                                          '1') {
                                                                        if (actualpaymentHistory![i].status ==
                                                                            '1') {
                                                                          paymentHistory
                                                                              ?.add(actualpaymentHistory![i]);
                                                                        }
                                                                      }
                                                                    }
                                                                  } else if (gradeStatus ==
                                                                      'Due') {
                                                                    paymentHistory =
                                                                        [];
                                                                    for (int i =
                                                                            0;
                                                                        i < actualpaymentHistory!.length;
                                                                        i++) {
                                                                      if (actualpaymentHistory![i]
                                                                              .creditType !=
                                                                          '1') {
                                                                        if (actualpaymentHistory![i].dueType ==
                                                                                '0' &&
                                                                            actualpaymentHistory![i].isPaid ==
                                                                                '0') {
                                                                          paymentHistory
                                                                              ?.add(actualpaymentHistory![i]);
                                                                        }
                                                                      }
                                                                    }
                                                                  } else if (gradeStatus ==
                                                                      'Overdue') {
                                                                    paymentHistory =
                                                                        [];
                                                                    for (int i =
                                                                            0;
                                                                        i < actualpaymentHistory!.length;
                                                                        i++) {
                                                                      if (actualpaymentHistory![i]
                                                                              .creditType !=
                                                                          '1') {
                                                                        if (actualpaymentHistory![i].dueType ==
                                                                            '1') {
                                                                          paymentHistory
                                                                              ?.add(actualpaymentHistory![i]);
                                                                        }
                                                                      }
                                                                    }
                                                                  } else if (gradeStatus ==
                                                                      'Paid') {
                                                                    paymentHistory =
                                                                        [];
                                                                    for (int i =
                                                                            0;
                                                                        i < actualpaymentHistory!.length;
                                                                        i++) {
                                                                      if (actualpaymentHistory![i]
                                                                              .creditType !=
                                                                          '1') {
                                                                        if (actualpaymentHistory![i].isPaid ==
                                                                            '1') {
                                                                          paymentHistory
                                                                              ?.add(actualpaymentHistory![i]);
                                                                        }
                                                                      }
                                                                    }
                                                                  } else if (gradeStatus ==
                                                                      'Unpaid') {
                                                                    paymentHistory =
                                                                        [];
                                                                    for (int i =
                                                                            0;
                                                                        i < actualpaymentHistory!.length;
                                                                        i++) {
                                                                      if (actualpaymentHistory![i]
                                                                              .creditType !=
                                                                          '1') {
                                                                        if (actualpaymentHistory![i].isPaid ==
                                                                            '0') {
                                                                          paymentHistory
                                                                              ?.add(actualpaymentHistory![i]);
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                });

                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              10.0,
                                                                          bottom:
                                                                              20.0,
                                                                          top:
                                                                              15.0),
                                                                      child: Text(
                                                                          arrStatus[index]
                                                                              .capitalize()),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              10.0),
                                                                      child:
                                                                          Icon(
                                                                        gradeStatus ==
                                                                                arrStatus[index]
                                                                            ? Icons.check_circle_outline_sharp
                                                                            : Icons.circle_outlined,
                                                                        color: gradeStatus ==
                                                                                arrStatus[index]
                                                                            ? Colors.green
                                                                            : Colors.grey,
                                                                        size:
                                                                            26,
                                                                      ),
                                                                    ),
                                                                  ]),
                                                            ),
                                                            const Divider(
                                                              height: 1,
                                                              thickness: 0.5,
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
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Container(
                                                      width: double.infinity,
                                                      color: Colors.black,
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 13.0),
                                                        child: Text(
                                                          'OK',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15),
                                                          textAlign:
                                                              TextAlign.center,
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
                              child:
                                  const Icon(Icons.sort, color: Colors.black)),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.vendorName ?? '',
                                style: boldText,
                              ),
                              verticalSpaceTiny,
                              Text(
                                  'as on ${DateFormat('dd MMM yyyy').format(selectedDate)}',
                                  style: normalText12),
                            ],
                          ),
                          InkWell(
                              onTap: () async {
                                DateTime? newDateTime = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(DateTime.now().year - 20),
                                  lastDate: DateTime(DateTime.now().year + 20),
                                );
                                if (newDateTime != null) {
                                  selectedDate = newDateTime;
                                  wsPaymentHistoryDuelist();
                                }
                              },
                              child: const Icon(Icons.calendar_today,
                                  color: Colors.black)),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Colors.black,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) => Dialog(
                                    elevation: 0,
                                    child: SizedBox(
                                      height: 400,
                                      width: 360.0,
                                      child: Column(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(
                                                top: 10.0, bottom: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'SORT BY GRADE TYPE',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Divider(
                                            color: Colors.grey.shade500,
                                            thickness: 1.5,
                                          ),
                                          SizedBox(
                                            height: 300,
                                            width: 360,
                                            child: ListView.builder(
                                                itemCount: searchData!.length,
                                                itemBuilder: (context, index) {
                                                  return Column(
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            gradeId =
                                                                searchData![
                                                                        index]
                                                                    .gradeId!;
                                                            gradeName =
                                                                searchData![
                                                                        index]
                                                                    .gradeName!;
                                                            if (gradeId ==
                                                                '0') {
                                                              paymentHistory =
                                                                  actualpaymentHistory;
                                                            } else {
                                                              paymentHistory =
                                                                  [];
                                                              for (int i = 0;
                                                                  i <
                                                                      actualpaymentHistory!
                                                                          .length;
                                                                  i++) {
                                                                if (actualpaymentHistory![i]
                                                                            .creditType ==
                                                                        "0" ||
                                                                    actualpaymentHistory![i]
                                                                            .creditType ==
                                                                        "2") {
                                                                  var arrGrade =
                                                                      actualpaymentHistory![
                                                                              i]
                                                                          .orderType!;
                                                                  for (int j =
                                                                          0;
                                                                      j <
                                                                          arrGrade
                                                                              .length;
                                                                      j++) {
                                                                    if (arrGrade[j]
                                                                            .gradeId ==
                                                                        gradeId) {
                                                                      paymentHistory!.add(
                                                                          actualpaymentHistory![
                                                                              i]);
                                                                      break;
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          });

                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10.0,
                                                                        bottom:
                                                                            20.0,
                                                                        top:
                                                                            15.0),
                                                                child: Text(searchData![
                                                                        index]
                                                                    .gradeName!
                                                                    .capitalize()),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            10.0),
                                                                child: Icon(
                                                                  gradeId ==
                                                                          searchData![index]
                                                                              .gradeId!
                                                                      ? Icons
                                                                          .check_circle_outline_sharp
                                                                      : Icons
                                                                          .circle_outlined,
                                                                  color: gradeId ==
                                                                          searchData![index]
                                                                              .gradeId!
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .grey,
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
                                                Navigator.of(context).pop();
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                color: Colors.black,
                                                child: const Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 13.0),
                                                  child: Text(
                                                    'OK',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15),
                                                    textAlign: TextAlign.center,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(gradeName.capitalize(), style: boldText),
                            horizontalSpaceSmall,
                            const Icon(Icons.arrow_drop_down_sharp,
                                color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Colors.black,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60.0, vertical: 10),
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          onChanged: (value) => filterSearchResults(value),
                          style: const TextStyle(fontSize: 13),
                          controller: searchController,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(12.0),
                              labelText: "Search by Vendor Name",
                              hintText: "Search by Vendor Name",
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)))),
                        ),
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Colors.black,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 65, right: 65, top: 10, bottom: 10),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Last Price Per'),
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 130,
                                height: 30,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: venderGrade!.length,
                                    itemBuilder: (context, index) {
                                      return Row(
                                        children: [
                                          Text(
                                              '${venderGrade![index].gradeTypeName!} - ',
                                              style: boldText),
                                          Text(
                                            currencyFormat.format(double.parse(
                                                venderGrade![index]
                                                    .gradePrice!)),
                                            style: normalText,
                                          ),
                                          horizontalSpaceSmall
                                        ],
                                      );
                                    }),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Colors.black,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredPaymentHistory!.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              var projectId = widget.projectId!;
                              var projectName = widget.projectName!;
                              filteredPaymentHistory![index].creditType == '0'
                                  ? Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return PoPreviewHtml(
                                            projectId: projectId,
                                            towarId: widget.towarId!,
                                            projectName: projectName,
                                            orderId:
                                                filteredPaymentHistory![index]
                                                    .orderId!,
                                            poNo: filteredPaymentHistory![index]
                                                .poNo!,
                                          );
                                        },
                                      ),
                                    ).then((_) => {})
                                  : null;
                            },
                            child: filteredPaymentHistory![index].creditType ==
                                    '0'
                                ? ListTile(
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
                                                      child: Text('P.O. No.',
                                                          style: normalText),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        filteredPaymentHistory![
                                                                index]
                                                            .poNo!,
                                                        style: boldText),
                                                    horizontalSpaceSmall,
                                                    filteredPaymentHistory![
                                                                    index]
                                                                .isStarMarked! ==
                                                            '1'
                                                        ? const Icon(Icons.star,
                                                            size: 15,
                                                            color: Colors.red)
                                                        : const SizedBox(),
                                                    const SizedBox(width: 20),
                                                    Text(
                                                      '(${filteredPaymentHistory![index].poSignDate})',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 16.0,
                                                        color: Colors.black45,
                                                      ),
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
                                                      child: Text('Order Type',
                                                          style: normalText),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Flexible(
                                                      child: Text(
                                                          filteredPaymentHistory![
                                                                  index]
                                                              .orderTypeComma!,
                                                          style: normalText),
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
                                                          'Project Name',
                                                          style: normalText),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        filteredPaymentHistory![
                                                                index]
                                                            .projectName!
                                                            .capitalize(),
                                                        style: normalText),
                                                    const Expanded(
                                                        child:
                                                            horizontalSpaceSmall),
                                                    filteredPaymentHistory![index]
                                                                .dueType! ==
                                                            '0'
                                                        ? Text(currencyFormat.format(double.parse(filteredPaymentHistory![index].amount!)),
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16.0,
                                                                color: Colors
                                                                    .black))
                                                        : Text(
                                                            currencyFormat.format(
                                                                double.parse(
                                                                    filteredPaymentHistory![index]
                                                                        .amount!)),
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16.0,
                                                                color: Colors.red)),
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
                                                          'Requested by',
                                                          style: normalText),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        filteredPaymentHistory![
                                                                index]
                                                            .raisedBy!,
                                                        style: normalText),
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
                                                          'Delivery Date',
                                                          style: normalText),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        filteredPaymentHistory![
                                                                index]
                                                            .deliveryDate!,
                                                        style: normalText),
                                                    const Expanded(
                                                        child:
                                                            horizontalSpaceSmall),
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (_) {
                                                              return InvoiceList(
                                                                projectId: widget
                                                                    .projectId!,
                                                                projectName: widget
                                                                    .projectName!,
                                                                orderId:
                                                                    filteredPaymentHistory![
                                                                            index]
                                                                        .orderId!,
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        width: 120,
                                                        height: 35,
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
                                                        child: const Text(
                                                          'VIEW INVOICE',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            fontSize: 13.0,
                                                          ),
                                                        ),
                                                      ),
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
                                                          'Over Due Date',
                                                          style: normalText),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        filteredPaymentHistory![
                                                                index]
                                                            .dueDate!,
                                                        style: normalText),
                                                    const Spacer(),
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (_) {
                                                              return ViewChallanList(
                                                                projectId: widget
                                                                    .projectId!,
                                                                projectName: widget
                                                                    .projectName!,
                                                                orderId:
                                                                    filteredPaymentHistory![
                                                                            index]
                                                                        .orderId!,
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        width: 120,
                                                        height: 35,
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
                                                        child: const Text(
                                                          'VIEW CHALLAN',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            fontSize: 13.0,
                                                          ),
                                                        ),
                                                      ),
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
                                                      child: Text('Status',
                                                          style: normalText),
                                                    ),
                                                    horizontalSpaceMedium,
                                                    const Center(
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black54)),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                      filteredPaymentHistory![
                                                                      index]
                                                                  .status! ==
                                                              '0'
                                                          ? 'Open'
                                                          : 'Closed',
                                                      style:
                                                          filteredPaymentHistory![
                                                                          index]
                                                                      .status! ==
                                                                  '0'
                                                              ? const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      14.0,
                                                                  color: Colors
                                                                      .green)
                                                              : const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      14.0,
                                                                  color: Colors
                                                                      .red),
                                                    ),
                                                    if (filteredPaymentHistory![
                                                                index]
                                                            .isPaid ==
                                                        '1')
                                                      const Spacer(),
                                                    if (filteredPaymentHistory![
                                                                index]
                                                            .isPaid ==
                                                        '1')
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 30),
                                                        width: 50,
                                                        height: 30,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          border: Border.all(
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          'PAID',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              // fontStyle:
                                                              //     FontStyle
                                                              //         .normal,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                                    // const Expanded(
                                                    //     child:
                                                    //         horizontalSpaceSmall),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: double.maxFinite,
                                                child: Text(
                                                  "Pending Invoice : ${filteredPaymentHistory![index].pendingInvoice} / ${filteredPaymentHistory![index].totalInv}",
                                                  textAlign: TextAlign.end,
                                                  style: const TextStyle(
                                                      color: Colors.blue),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        verticalSpaceSmall15,
                                        const Divider(
                                          height: 1,
                                          thickness: 0.5,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  )
                                : filteredPaymentHistory![index].creditType ==
                                        '1'
                                    ? ListTile(
                                        trailing: const Padding(
                                          padding: EdgeInsets.only(top: 70.0),
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
                                                                'Transaction No.',
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
                                                          Expanded(
                                                            child: Text(
                                                                filteredPaymentHistory![
                                                                        index]
                                                                    .poNo!,
                                                                style:
                                                                    boldText),
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
                                                          Flexible(
                                                            child: Text(
                                                                filteredPaymentHistory![
                                                                        index]
                                                                    .purchaseOrderNumber!,
                                                                style:
                                                                    boldText),
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
                                                              filteredPaymentHistory![
                                                                      index]
                                                                  .projectName!
                                                                  .capitalize(),
                                                              style: boldText),
                                                          const Expanded(
                                                              child:
                                                                  horizontalSpaceSmall),
                                                          Text(
                                                              '- ${currencyFormat.format(double.parse(filteredPaymentHistory![index].amount!))}',
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      16.0,
                                                                  color: Colors
                                                                      .green))
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
                                                                'Invoice No.',
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
                                                          Expanded(
                                                            child: Text(
                                                                filteredPaymentHistory![
                                                                        index]
                                                                    .invoiceNumber!,
                                                                style:
                                                                    boldText),
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
                                                            child: Text('Date',
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
                                                              filteredPaymentHistory![
                                                                      index]
                                                                  .deliveryDate!,
                                                              style: boldText),
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
                                                                'Payment Type',
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
                                                              filteredPaymentHistory![
                                                                      index]
                                                                  .paymentType!,
                                                              style: boldText),
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
                                      )
                                    : ListTile(
                                        trailing: const Padding(
                                          padding: EdgeInsets.only(top: 70.0),
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
                                                              filteredPaymentHistory![
                                                                      index]
                                                                  .poNo!,
                                                              style: boldText),
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
                                                                'Order Type',
                                                                style:
                                                                    normalText),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                            child: Icon(
                                                              Icons.remove,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                          ),
                                                          horizontalSpaceLarge,
                                                          Flexible(
                                                            child: Text(
                                                                filteredPaymentHistory![
                                                                        index]
                                                                    .orderTypeComma!,
                                                                style:
                                                                    boldText),
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
                                                              filteredPaymentHistory![
                                                                      index]
                                                                  .projectName!
                                                                  .capitalize(),
                                                              style: boldText),
                                                          const Expanded(
                                                              child:
                                                                  horizontalSpaceSmall),
                                                          Text(
                                                              '- ${currencyFormat.format(double.parse(filteredPaymentHistory![index].amount!))}',
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      16.0,
                                                                  color: Colors
                                                                      .red))
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
                                                                'Requested by',
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
                                                              filteredPaymentHistory![
                                                                      index]
                                                                  .raisedBy!,
                                                              style: boldText),
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
                                                                'Delivery Date',
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
                                                              filteredPaymentHistory![
                                                                      index]
                                                                  .deliveryDate!,
                                                              style: boldText),
                                                          const Expanded(
                                                              child:
                                                                  horizontalSpaceSmall),
                                                          InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (_) {
                                                                    return InvoiceList(
                                                                      projectId:
                                                                          widget
                                                                              .projectId!,
                                                                      projectName:
                                                                          widget
                                                                              .projectName!,
                                                                      orderId: filteredPaymentHistory![
                                                                              index]
                                                                          .orderId!,
                                                                    );
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                            child: Container(
                                                              width: 120,
                                                              height: 35,
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
                                                                            17),
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              child: const Text(
                                                                'VIEW INVOICE',
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
                                                                'Over Due Date',
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
                                                              filteredPaymentHistory![
                                                                      index]
                                                                  .dueDate!,
                                                              style: boldText),
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
                                                                'Status',
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
                                                              filteredPaymentHistory![
                                                                              index]
                                                                          .status! ==
                                                                      '0'
                                                                  ? 'Open'
                                                                  : 'Closed',
                                                              style: filteredPaymentHistory![
                                                                              index]
                                                                          .status! ==
                                                                      '0'
                                                                  ? const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          14.0,
                                                                      color: Colors
                                                                          .green)
                                                                  : const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          14.0,
                                                                      color: Colors
                                                                          .red)),
                                                          const Expanded(
                                                              child:
                                                                  horizontalSpaceSmall),
                                                          InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (_) {
                                                                    return ViewChallanList(
                                                                      projectId:
                                                                          widget
                                                                              .projectId!,
                                                                      projectName:
                                                                          widget
                                                                              .projectName!,
                                                                      orderId: filteredPaymentHistory![
                                                                              index]
                                                                          .orderId!,
                                                                    );
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                            child: Container(
                                                              width: 120,
                                                              height: 35,
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
                                                                            17),
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              child: const Text(
                                                                'VIEW CHALLAN',
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
                  ],
                )
              : SizedBox(
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
      ),
      bottomNavigationBar: SizedBox(
        height: 75,
        child: IntrinsicHeight(
          child: Column(
            children: [
              const Divider(
                height: 1,
                thickness: 0.5,
                color: Colors.black,
              ),
              IntrinsicHeight(
                child: Row(
                  children: [
                    horizontalSpaceSmall,
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const Text('Total Invoice',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black)),
                            verticalSpaceSmall,
                            Text(
                                currencyFormat
                                    .format(double.parse(totalInvoice!)),
                                style: boldText)
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
                      child: InkWell(
                        onTap: () {
                          List<PaymentHistory>? arrPayments = [];
                          for (int i = 0;
                              i < filteredPaymentHistory!.length;
                              i++) {
                            if (filteredPaymentHistory![i].creditType == '1') {
                              arrPayments.add(filteredPaymentHistory![i]);
                            }
                          }
                          var projectId = widget.projectId!;
                          var projectName = widget.projectName!;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) {
                                return PoInvoiceTotalPaidList(
                                    projectId: projectId,
                                    towarId: widget.towarId!,
                                    projectName: projectName,
                                    paymentHistory: arrPayments,
                                    vendorName: widget.vendorName,
                                    totalpaidamt: totalPayment);
                              },
                            ),
                          );
                        },
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
                              Text(
                                  currencyFormat
                                      .format(double.parse(totalPayment!)),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green))
                            ],
                          ),
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
                            const Text('Balance',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black)),
                            verticalSpaceSmall,
                            Text(
                                currencyFormat
                                    .format(double.parse(totalBalance!)),
                                style: boldText),
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
                            const Text('Overdue',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black)),
                            verticalSpaceSmall,
                            Text(
                                currencyFormat
                                    .format(double.parse(totalOverdue!)),
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)),
                          ],
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
    );
  }
}
