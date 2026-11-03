// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';
import 'package:stallion/models/project_budget_response.dart';
import 'package:stallion/models/wo_budget_list.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/budget/ui/wo_contracts/budget_contract_list.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';

class BudgetWoListScreen extends StatefulWidget {
  const BudgetWoListScreen(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      required this.arrBudgetCost,
      required this.budgetId,
      required this.budgetTitle,
      required this.over_budget_flag,
      this.towarName})
      : super(key: key);
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? budgetId;
  final String? budgetTitle;
  final String? over_budget_flag;
  final List<ArrBudgetCost>? arrBudgetCost;

  @override
  State<BudgetWoListScreen> createState() => _BudgetListScreenState();
}

class _BudgetListScreenState extends State<BudgetWoListScreen> {
  String formatToIndianStandard(double numberString) {
    final indianRupeesFormat = NumberFormat.currency(
      name: "INR",
      locale: 'en_IN',
      decimalDigits: 2, // change it to get decimal places
      symbol: 'Rs ',
    );

    return indianRupeesFormat.format(numberString);
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  List<BudgetWoList>? budgetListResponse = [];
  WoBudgetListResponse? responseData;

  Future<List<FinalBudgetResult>?> fetchProjectBudgetList() async {
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
        "budget_type_id": widget.budgetId ?? '',
        "over_budget_flag": widget.over_budget_flag ?? '0',
      };

      if (kDebugMode) {
        print(data);
      }

      var response =
          await apiNetworkHandler.post(AppUrl.getProjectBudgetWoList, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = woBudgetListFromJson(response.body);

        if (kDebugMode) {
          print(dataModel.response?.errorCode);
        }

        if (dataModel.response?.errorCode == "0") {
          setState(() {
            responseData = dataModel.response;
            budgetListResponse = dataModel.response?.budgetWoList;
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
      CustomLoading.progressDialog(isLoading: false, context: context);
    }
    return null;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchProjectBudgetList();
    });
    super.initState();
  }

  double calValue({required BudgetWoList data}) {
    if (double.parse(data.budgetWoContractAvoided ?? '0') >
        double.parse(data.budgetWoEstContractValue ?? '0')) {
      double temp = double.parse(data.budgetWoEstContractValue ?? '0') /
          double.parse(data.budgetWoContractAvoided ?? '0');
      return 100 - ((1 - temp) * 100);
    } else {
      double temp = double.parse(data.budgetWoContractAvoided ?? '0') /
          double.parse(data.budgetWoEstContractValue ?? '0');
      return temp * 100;
    }
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
                          double.parse(responseData?.totalContractCost ?? '0')),
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
                          double.parse(responseData?.totalAmountPaid ?? '0')),
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
                          double.parse(responseData?.totalCost ?? '0')),
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
                          double.parse(responseData?.overBudgetAmount ?? '0')),
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
            child: Text(
                'CONTRACTS - ${widget.budgetTitle?.toUpperCase()} (WORK ORDER)',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, height: 0),
                textAlign: TextAlign.center),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.black),
                  ),
                ),
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
                    right: BorderSide(color: Colors.black),
                  ),
                ),
                width: MediaQuery.of(context).size.width * 0.23,
                child: Container(
                  decoration: const BoxDecoration(),
                  child: const Text(
                    "Estimated Contract",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
                        "Contract Awarded",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Text(
                      "Contract Paid",
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
          const Divider(),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: budgetListResponse?.length ?? 0,
              itemBuilder: (context, index) {
                return budgetCard(data: budgetListResponse![index]);
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

  Widget budgetCard({
    required BudgetWoList data,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return BudgetContractrList(
                budgetWoType: data.budgetWoType,
                budgetWoId: data.budgetWoId,
                budgetListdata: data,
                projectId: widget.projectId,
                projectName: widget.projectName,
                towarId: widget.towarId,
                towarName: widget.towarName!,
                budgetId: widget.budgetId,
                budgetTitle: widget.budgetTitle,
                gradeId: data.budgetTypeId,
                totalEstmateCost: data.budgetWoEstContractValue,
                totalProcuiteCost: data.budgetWoEstContractValue,
                totalCost: (double.parse(data.budgetWoEstContractValue ?? '0') -
                        double.parse(data.budgetWoEstContractValue ?? '0'))
                    .toString(), // responseData?.totalCost,
                overBudgetAmount: data.budgetOverBudgetAmount,
              );
            },
          ),
        );
      },
      child: Row(
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
                  data.budgetWoName ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      double.parse(data.budgetWoContractAvoided ?? '0') >
                              double.parse(data.budgetWoEstContractValue ?? '0')
                          ? "100%"
                          : '${calValue(data: data).toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    AnimatedProgressBar(
                        //
                        height: 18,
                        value: calValue(data: data) / 100,
                        duration: const Duration(seconds: 2),
                        color: Colors.black,
                        backgroundColor:
                            (double.parse(data.budgetWoContractAvoided ?? '0') >
                                    double.parse(
                                        data.budgetWoEstContractValue ?? '0'))
                                ? Colors.red
                                : Colors.black26 // const Color(0xFFF0F0F0),
                        ),
                    const SizedBox(width: 10),
                    Text(
                      double.parse(data.budgetWoContractAvoided ?? '0') >
                              double.parse(data.budgetWoEstContractValue ?? '0')
                          ? '${(100 - calValue(data: data)).toStringAsFixed(2)}%'
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
            child: Container(
              decoration: const BoxDecoration(),
              child: Text(
                formatToIndianStandard(
                    double.parse(data.budgetWoEstContractValue ?? '0')),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
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
                    formatToIndianStandard(
                        double.parse(data.budgetWoContractAvoided ?? '0')),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  formatToIndianStandard(
                      double.parse(data.budgetWoContractPaid ?? '0')),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (double.parse(data.budgetWoContractAvoided ?? '0') >
                    double.parse(data.budgetWoEstContractValue ?? '0'))
                  Text(
                    '(' +
                        formatToIndianStandard(double.parse(
                                    data.budgetWoContractAvoided ?? '0') -
                                double.parse(
                                    data.budgetWoEstContractValue ?? '0'))
                            .toString() +
                        ")",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
