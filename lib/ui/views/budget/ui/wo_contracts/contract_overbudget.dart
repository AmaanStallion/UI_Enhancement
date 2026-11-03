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

class ContractOverBudgetScreen extends StatefulWidget {
  const ContractOverBudgetScreen(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      required this.arrBudgetCost,
      required this.budgetId,
      required this.budgetTitle,
      this.towarName})
      : super(key: key);
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? budgetId;
  final String? budgetTitle;
  final List<ArrBudgetCost>? arrBudgetCost;

  @override
  State<ContractOverBudgetScreen> createState() =>
      _ContractOverBudgetScreenState();
}

class _ContractOverBudgetScreenState extends State<ContractOverBudgetScreen> {
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

  List<BudgetWoList>? budgetGroupDataResponse = [];
  WoBudgetListResponse? responseData;
  Future<List<BudgetWoList>?> fetchProjectBudgetList() async {
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
        "over_budget_flag": "1"
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
            budgetGroupDataResponse = dataModel.response?.budgetWoList;
            responseData = dataModel.response;
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

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchProjectBudgetList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double calculatePercentage({required BudgetWoList data}) {
      if (double.parse(data.budgetWoEstContractValue ?? '0') > 0 &&
          (double.parse(data.budgetWoContractPaid ?? '0') >
              double.parse(data.budgetWoEstContractValue ?? '0'))) {
        double percent = 100 -
            ((double.parse(data.budgetWoEstContractValue ?? '0') /
                    double.parse(data.budgetWoContractPaid ?? '0')) *
                100);
        double percentCal = 1 - (percent / 100);
        return percentCal;
      } else {
        return 0.00;
      }
    }

    double calculatePercentageText({required BudgetWoList data}) {
      if (double.parse(data.budgetWoContractPaid ?? '0') >
          double.parse(data.budgetWoEstContractValue ?? '0')) {
        double percent = 100 -
            ((double.parse(data.budgetWoEstContractValue ?? '0') /
                    double.parse(data.budgetWoContractPaid ?? '0')) *
                100);
        double percentCal = 1 - (percent / 100);
        return percentCal;
      } else {
        return 0.00;
      }
    }

    return Scaffold(
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 6),
        height: 40,
        color: Colors.black,
        child: Text(
          "Total Over Budget Cost: ${formatToIndianStandard(double.parse(responseData?.overBudgetAmount ?? '0'))}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text('CONTRACTS OVER BUDGET',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w500, height: 0),
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
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
                  "CONTRACT TYPES",
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
                child: const Text(
                  "Estimated Contract",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black54),
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.23,
                    child: const Text(
                      "Contract Paid",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            ],
          ),
          const Divider(
            color: Colors.black,
          ),
          ListView.separated(
            shrinkWrap: true,
            itemCount: budgetGroupDataResponse?.length ?? 0,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return BudgetContractrList(
                          budgetWoType:
                              budgetGroupDataResponse?[index].budgetWoType,
                          budgetWoId:
                              budgetGroupDataResponse?[index].budgetWoId,
                          budgetListdata: budgetGroupDataResponse![index],
                          projectId: widget.projectId,
                          projectName: widget.projectName,
                          towarId: widget.towarId,
                          towarName: widget.towarName!,
                          budgetId: widget.budgetId,
                          budgetTitle: widget.budgetTitle,
                          gradeId: budgetGroupDataResponse?[index].budgetTypeId,
                          totalEstmateCost: budgetGroupDataResponse?[index]
                              .budgetWoEstContractValue,
                          totalProcuiteCost: budgetGroupDataResponse?[index]
                              .budgetWoEstContractValue,
                          totalCost: (double.parse(
                                      budgetGroupDataResponse?[index]
                                              .budgetWoEstContractValue ??
                                          '0') -
                                  double.parse(budgetGroupDataResponse?[index]
                                          .budgetWoEstContractValue ??
                                      '0'))
                              .toString(), // responseData?.totalCost,
                          overBudgetAmount: budgetGroupDataResponse?[index]
                              .budgetOverBudgetAmount,
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                              budgetGroupDataResponse?[index].budgetWoName ??
                                  '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                double.parse(budgetGroupDataResponse![index]
                                                    .budgetWoEstContractValue ??
                                                '0') >
                                            0 &&
                                        (double.parse(
                                                budgetGroupDataResponse![index]
                                                        .budgetWoContractPaid ??
                                                    '0') >
                                            double.parse(budgetGroupDataResponse![
                                                        index]
                                                    .budgetWoEstContractValue ??
                                                '0'))
                                    ? const Text(
                                        "100% ",
                                        style: TextStyle(color: Colors.black),
                                      )
                                    : const Text(
                                        "0% ",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                AnimatedProgressBar(
                                    height: 18,
                                    value: calculatePercentage(
                                        data: budgetGroupDataResponse![index]),
                                    duration: const Duration(seconds: 2),
                                    color: Colors.black,
                                    backgroundColor: double.parse(
                                                    budgetGroupDataResponse![index]
                                                            .budgetWoEstContractValue ??
                                                        '0') >
                                                0 &&
                                            (double.parse(budgetGroupDataResponse![
                                                            index]
                                                        .budgetWoContractPaid ??
                                                    '0') >
                                                double.parse(budgetGroupDataResponse![
                                                            index]
                                                        .budgetWoEstContractValue ??
                                                    '0'))
                                        ? Colors.red
                                        : Colors
                                            .black26 // const Color(0xFFF0F0F0),
                                    ),
                                if (double.parse(budgetGroupDataResponse?[index]
                                                .budgetWoEstContractValue ??
                                            '0') >
                                        0 &&
                                    (double.parse(
                                            budgetGroupDataResponse?[index]
                                                    .budgetWoContractPaid ??
                                                '0') >
                                        double.parse(
                                            budgetGroupDataResponse?[index]
                                                    .budgetWoEstContractValue ??
                                                '0')))
                                  Text(
                                    " ${(100 - (calculatePercentageText(data: budgetGroupDataResponse![index]) * 100)).toStringAsFixed(2)}%",
                                    style: const TextStyle(color: Colors.red),
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
                        child: Text(
                          formatToIndianStandard(double.parse(
                              budgetGroupDataResponse?[index]
                                      .budgetWoEstContractValue
                                      .toString() ??
                                  '0')),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black54),
                              ),
                            ),
                            child: Text(
                              formatToIndianStandard(double.parse(
                                  budgetGroupDataResponse?[index]
                                          .budgetWoContractAvoided
                                          .toString() ??
                                      '0')),
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.23,
                            child: Text(
                              formatToIndianStandard(double.parse(
                                  budgetGroupDataResponse?[index]
                                          .budgetWoContractPaid
                                          .toString() ??
                                      '0')),
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (double.parse(budgetGroupDataResponse?[index]
                                          .budgetWoEstContractValue ??
                                      '0') >
                                  0 &&
                              (double.parse(budgetGroupDataResponse?[index]
                                          .budgetWoContractPaid ??
                                      '0') >
                                  double.parse(budgetGroupDataResponse?[index]
                                          .budgetWoEstContractValue ??
                                      '0')))
                            Container(
                              decoration: const BoxDecoration(),
                              child: Text(
                                '(${formatToIndianStandard((double.parse(budgetGroupDataResponse?[index].budgetWoContractPaid ?? '0') - double.parse(budgetGroupDataResponse![index].budgetWoEstContractValue ?? '0')))})',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(
              color: Colors.grey,
            ),
          ),
          const Divider(
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
