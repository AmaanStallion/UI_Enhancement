import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';
import 'package:stallion/models/project_budget_list.dart';
import 'package:stallion/models/project_budget_response.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/budget/ui/po_raw_material/budget_vender_list.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';

class RawMaterialOverBudget extends StatefulWidget {
  const RawMaterialOverBudget(
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
  State<RawMaterialOverBudget> createState() => _RawMaterialOverBudgetState();
}

class _RawMaterialOverBudgetState extends State<RawMaterialOverBudget> {
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

  List<BudgetList>? budgetListResponse = [];
  ProjectBudgetListResponse? responseData;

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
        // "budget_type_id": widget.budgetId ?? '',
        "over_budget_flag": "1"
      };

      if (kDebugMode) {
        print(data);
      }

      var response =
          await apiNetworkHandler.post(AppUrl.getProjectBudgetList, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = projectBudgetListFromJson(response.body);

        if (kDebugMode) {
          print(dataModel.response?.errorCode);
        }

        if (dataModel.response?.errorCode == "0") {
          setState(() {
            responseData = dataModel.response;
            budgetListResponse = dataModel.response?.budgetList;
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
    } else {
      double temp = double.parse(data.purchaseAmount ?? '0') /
          double.parse(data.estTotal ?? '0');
      return temp * 100;
    }
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
    return Scaffold(
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 6),
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(color: Colors.black),
          ),
        ),
        height: 40,
        child: Text(
          'Total Over Budget Cost ${formatToIndianStandard(double.parse(responseData?.overBudgetAmount ?? '0'))}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
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
            child: Text('RAW MATERIALS ${widget.budgetTitle?.toUpperCase()}',
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
    required BudgetList data,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return BudgetVenderList(
                budgetListdata: data,
                projectId: widget.projectId,
                projectName: widget.projectName,
                towarId: widget.towarId,
                towarName: widget.towarName!,
                budgetId: widget.budgetId,
                budgetTitle: widget.budgetTitle,
                gradeId: data.gradeId,
                totalEstmateCost: data.estTotal,
                totalProcuiteCost: data.purchaseAmount,
                totalCost: (double.parse(data.estTotal ?? '0') -
                        double.parse(data.purchaseAmount ?? '0'))
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
                  data.gradeName ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      ((double.parse(data.purchaseAmount ?? '0') >
                                  double.parse(data.estTotal ?? '0')) &&
                              double.parse(data.estTotal ?? '0') != 0)
                          ? "100%"
                          : '${calValue(data: data).toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    AnimatedProgressBar(
                        height: 18,
                        value: calValue(data: data) / 100,
                        duration: const Duration(seconds: 2),
                        color: Colors.black,
                        backgroundColor:
                            ((double.parse(data.purchaseAmount ?? '0') >
                                        double.parse(data.estTotal ?? '0')) &&
                                    double.parse(data.estTotal ?? '0') != 0)
                                ? Colors.red
                                : Colors.black26 // const Color(0xFFF0F0F0),

                        ),
                    const SizedBox(width: 10),
                    Text(
                      ((double.parse(data.purchaseAmount ?? '0') >
                                  double.parse(data.estTotal ?? '0')) &&
                              double.parse(data.estTotal ?? '0') != 0)
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
                    data.budgetEstQuantity ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  formatToIndianStandard(double.parse(data.estTotal ?? '')),
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
                    data.purchaseTotalQuantity ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  formatToIndianStandard(
                      double.parse(data.purchaseAmount ?? '')),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ((double.parse(data.purchaseAmount ?? '0') >
                                double.parse(data.estTotal ?? '0')) &&
                            double.parse(data.estTotal ?? '0') != 0)
                        ? Colors.black
                        : data.overBudgetFlag == "1"
                            ? Colors.red
                            : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                if ((double.parse(data.purchaseAmount ?? '0') >
                        double.parse(data.estTotal ?? '0')) &&
                    double.parse(data.estTotal ?? '0') != 0)
                  Text(
                    "(${formatToIndianStandard(double.parse(data.purchaseAmount ?? '') - double.parse(data.estTotal ?? '0'))})",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: data.overBudgetFlag == "1"
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
    );
  }
}
