import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';
import 'package:stallion/models/BudgetVenderList.dart';
import 'package:stallion/models/project_budget_list.dart';
import 'package:stallion/models/project_budget_response.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/accountmanagement/paymentdue/paymentcompanylist.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';

class BudgetVenderList extends StatefulWidget {
  const BudgetVenderList(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      required this.budgetId,
      required this.budgetTitle,
      required this.gradeId,
      required this.budgetListdata,
      required this.totalEstmateCost,
      required this.totalProcuiteCost,
      required this.totalCost,
      required this.overBudgetAmount,
      this.towarName})
      : super(key: key);
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? budgetId;
  final String? budgetTitle;
  final String? gradeId;
  final BudgetList budgetListdata;
  final String? totalEstmateCost;
  final String? totalProcuiteCost;
  final String? totalCost;
  final String? overBudgetAmount;

  @override
  State<BudgetVenderList> createState() => _BudgetVenderListState();
}

class _BudgetVenderListState extends State<BudgetVenderList> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  String formatToIndianStandard(double numberString) {
    final indianRupeesFormat = NumberFormat.currency(
      name: "INR",
      locale: 'en_IN',
      decimalDigits: 2, // change it to get decimal places
      symbol: 'Rs ',
    );

    return indianRupeesFormat.format(numberString);
  }

  List<BudgetVenderListElement>? budgetVenderList = [];

  Future<List<FinalBudgetResult>?> fetchProjectBudgeVendertList() async {
    try {
      CustomLoading.progressDialog(isLoading: true, context: context);

      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "project_id": widget.projectId ?? '',
        "towar_id": widget.towarId ?? '',
        "start_date": "",
        "end_date": "",
        // "budget_type_id": widget.budgetId ?? '',
        // "over_budget_flag": "0",
        "grade_id": widget.gradeId ?? '',
      };

      if (kDebugMode) {
        print(data);
      }

      var response =
          await apiNetworkHandler.post(AppUrl.getProjectBudgetVenderList, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = budgetVenderListFromJson(response.body);

        if (kDebugMode) {
          print(dataModel.response?.errorCode);
        }

        if (dataModel.response?.errorCode == "0") {
          setState(() {
            budgetVenderList = dataModel.response?.budgetVenderList;
          });
        } else {
          // Handle error when errorCode is not "0"
        }
      } else {
        // Handle error for non-200/201 status codes
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
      // Handle exceptions here if needed
      // throw SomeCustomException('Exception occurred: $e');
    } finally {
      // ignore: use_build_context_synchronously
      CustomLoading.progressDialog(isLoading: false, context: context);
    }
    return null;
  }

  double calValue({required BudgetList data}) {
    if (double.parse(data.purchaseAmount ?? '0') >
        double.parse(data.estTotal ?? '0')) {
      double temp = double.parse(data.estTotal ?? '0') /
          double.parse(data.purchaseAmount ?? '0');
      return 100 - ((1 - temp) * 100);
      // return temp;
    } else {
      double temp = double.parse(data.purchaseAmount ?? '0') /
          double.parse(data.estTotal ?? '0');
      return temp * 100;
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchProjectBudgeVendertList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black),
          ),
        ),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.black),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Total Estimated Cost',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      formatToIndianStandard(
                          double.parse(widget.totalEstmateCost ?? '0')),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.black),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Total Purchased Cost',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      formatToIndianStandard(
                          double.parse(widget.totalProcuiteCost ?? '0')),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.black),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Total Cost To Incur',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      formatToIndianStandard(
                          double.parse(widget.totalCost ?? '0')),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.black),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Total Over Budget Cost',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      formatToIndianStandard(
                          double.parse(widget.overBudgetAmount ?? '0')),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            widget.towarName!.isNotEmpty
                ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                : widget.projectName!.toUpperCase(),
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            width: double.maxFinite,
            child: const Text('VENDORS LIST',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, height: 0),
                textAlign: TextAlign.center),
          ),
          const Divider(
            color: Colors.black,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: const Text(
                  "MATERIAL TYPES",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.black),
                    right: BorderSide(color: Colors.black),
                  ),
                ),
                width: MediaQuery.of(context).size.width * 0.23,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey),
                        ),
                      ),
                      child: const Text(
                        "Estimated Qty",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Text(
                      "Estimated Value",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.23,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey),
                        ),
                      ),
                      child: const Text(
                        "Purchased Qty",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Text(
                      "Purchased Value",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(color: Colors.grey),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey),
                  ),
                ),
                width: MediaQuery.of(context).size.width * 0.3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.budgetListdata.gradeName ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          ((double.parse(widget.budgetListdata.purchaseAmount ??
                                          '0') >
                                      double.parse(
                                          widget.budgetListdata.estTotal ??
                                              '0')) &&
                                  double.parse(widget.budgetListdata.estTotal ??
                                          '0') !=
                                      0)
                              ? "100%"
                              : '${calValue(data: widget.budgetListdata).toStringAsFixed(2)}%',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        AnimatedProgressBar(
                            height: 18,
                            value: calValue(data: widget.budgetListdata) / 100,
                            duration: const Duration(seconds: 2),
                            color: Colors.black,
                            backgroundColor: ((double.parse(widget
                                                .budgetListdata
                                                .purchaseAmount ??
                                            '0') >
                                        double.parse(
                                            widget.budgetListdata.estTotal ??
                                                '0')) &&
                                    double.parse(
                                            widget.budgetListdata.estTotal ??
                                                '0') !=
                                        0)
                                ? Colors.red
                                : Colors.black26),
                        const SizedBox(width: 10),
                        Text(
                          ((double.parse(widget.budgetListdata.purchaseAmount ??
                                          '0') >
                                      double.parse(
                                          widget.budgetListdata.estTotal ??
                                              '0')) &&
                                  double.parse(widget.budgetListdata.estTotal ??
                                          '0') !=
                                      0)
                              ? '${(100 - calValue(data: widget.budgetListdata)).toStringAsFixed(2)}%'
                              : "",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey),
                  ),
                ),
                width: MediaQuery.of(context).size.width * 0.23,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey),
                        ),
                      ),
                      child: Text(
                        widget.budgetListdata.budgetEstQuantity ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      formatToIndianStandard(
                          double.parse(widget.budgetListdata.estTotal ?? '')),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.23,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey),
                        ),
                      ),
                      child: Text(
                        widget.budgetListdata.purchaseTotalQuantity ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      formatToIndianStandard(double.parse(
                          widget.budgetListdata.purchaseAmount ?? '')),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ((double.parse(
                                        widget.budgetListdata.purchaseAmount ??
                                            '0') >
                                    double.parse(
                                        widget.budgetListdata.estTotal ??
                                            '0')) &&
                                double.parse(widget.budgetListdata.estTotal ??
                                        '0') !=
                                    0)
                            ? Colors.black
                            : widget.budgetListdata.overBudgetFlag == "1"
                                ? Colors.red
                                : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if ((double.parse(
                                widget.budgetListdata.purchaseAmount ?? '0') >
                            double.parse(
                                widget.budgetListdata.estTotal ?? '0')) &&
                        double.parse(widget.budgetListdata.estTotal ?? '0') !=
                            0)
                      Text(
                        "(${formatToIndianStandard(double.parse(widget.budgetListdata.purchaseAmount ?? '') - double.parse(widget.budgetListdata.estTotal ?? '0'))})",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: widget.budgetListdata.overBudgetFlag == "1"
                              ? Colors.red
                              : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.black),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: budgetVenderList!.length,
              itemBuilder: (context, index) {
                return budgetCardVendor(data: budgetVenderList![index]);
              },
              separatorBuilder: (context, index) => const Divider(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget budgetCardVendor({required BudgetVenderListElement data}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return PaymentCompanyList(
                projectId: widget.projectId,
                towarId: widget.towarId!,
                projectName: widget.projectName,
                vendorId: data.venderId ?? '',
                vendorName: data.venderName ?? '',
                gradeId: data.gradeId,
                gradeName: 'data.gra',
                isFromBudget: true,
              );
            },
          ),
        );
      },
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 150),
              Container(
                decoration: const BoxDecoration(),
                width: MediaQuery.of(context).size.width * 0.25,
                child: const Text(
                  "Vendor Name",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(),
                width: MediaQuery.of(context).size.width * 0.45,
                child: Text(
                  data.venderName ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 150),
              Container(
                decoration: const BoxDecoration(),
                width: MediaQuery.of(context).size.width * 0.25,
                child: const Text(
                  "Total Purchased Qty",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(),
                width: MediaQuery.of(context).size.width * 0.45,
                child: Text(
                  data.procuredQuantity ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_right_sharp),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 150),
              Container(
                decoration: const BoxDecoration(),
                width: MediaQuery.of(context).size.width * 0.25,
                child: const Text(
                  "Total Purchased Cost",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(),
                width: MediaQuery.of(context).size.width * 0.45,
                child: Text(
                  formatToIndianStandard(
                      double.parse(data.procuredValue ?? '0')),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
