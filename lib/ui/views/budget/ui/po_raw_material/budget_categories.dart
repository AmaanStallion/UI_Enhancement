import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/budget_categories_response.dart';
import 'package:stallion/models/project_budget_response.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/budget/ui/po_raw_material/budget_list_screen.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';

class BudgetCategories extends StatefulWidget {
  const BudgetCategories(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      required this.arrBudgetCost,
      this.towarName})
      : super(key: key);
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final List<ArrBudgetCost>? arrBudgetCost;
  @override
  State<BudgetCategories> createState() => _BudgetCategoriesState();
}

class _BudgetCategoriesState extends State<BudgetCategories> {
  String formatToIndianStandard(double numberString) {
    final indianRupeesFormat = NumberFormat.currency(
      name: "INR",
      locale: 'en_IN',
      decimalDigits: 2, // change it to get decimal places
      symbol: 'Rs ',
    );

    return indianRupeesFormat.format(numberString);
  }

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  List<BudgetGroupDatum>? budgetGroupDataResponse = [];
  Future<List<FinalBudgetResult>?> fetchProjectBudgetCategories() async {
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
      };

      if (kDebugMode) {
        print(data);
      }

      var response =
          await apiNetworkHandler.post(AppUrl.getProjectBudgetCategory, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = projectBudgetCategoriesFromJson(response.body);

        if (kDebugMode) {
          print(dataModel.response?.errorCode);
        }

        if (dataModel.response?.errorCode == "0") {
          setState(() {
            budgetGroupDataResponse = dataModel.response?.budgetGroupData;
          });
        } else {
          // Handle error when errorCode is not "0"
        }
      } else {
        // Handle error for non-200/201 status codes
      }
    } catch (e) {
      print('Exception occurred: $e');
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
      fetchProjectBudgetCategories();
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
            for (int i = 0; i < widget.arrBudgetCost!.length; i++)
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
                      Text(
                        widget.arrBudgetCost?[i].title ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.arrBudgetCost?[i].title ==
                                  "Total Over Budget Cost"
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                      Text(
                        formatToIndianStandard(double.parse(
                            widget.arrBudgetCost?[i].amount ?? '0')),
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.arrBudgetCost?[i].title ==
                                  "Total Over Budget Cost"
                              ? Colors.red
                              : Colors.black,
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
          SizedBox(
            height: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 100),
                const Spacer(),
                const Text('RAW MATERIALS (PURCHASE ORDER)',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500, height: 0),
                    textAlign: TextAlign.center),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          return BudgetListScreen(
                            projectId: widget.projectId,
                            projectName: widget.projectName,
                            towarId: widget.towarId,
                            towarName: widget.towarName!,
                            arrBudgetCost: widget.arrBudgetCost,
                            budgetId: '',
                            budgetTitle: 'RAW MATERIALS',
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "ALL",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 50),
              ],
            ),
          ),
          const Divider(color: Colors.black),
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
                  "MATERIAL CATEGORIES",
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
                  "Estimated Cost",
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
                  "Purchased Cost",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.end,
                ),
              )
            ],
          ),
          const Divider(color: Colors.black),
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
                        return BudgetListScreen(
                          projectId: widget.projectId,
                          projectName: widget.projectName,
                          towarId: widget.towarId,
                          towarName: widget.towarName!,
                          arrBudgetCost: widget.arrBudgetCost,
                          budgetId:
                              budgetGroupDataResponse?[index].budgetTypeId,
                          budgetTitle:
                              budgetGroupDataResponse?[index].budgetTypeName,
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
                        child: Text(
                          budgetGroupDataResponse?[index].budgetTypeName ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
                              budgetGroupDataResponse![index]
                                  .estTotal
                                  .toString())),
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
                              budgetGroupDataResponse![index]
                                  .purchaseAmount
                                  .toString())),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.end,
                        ),
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
