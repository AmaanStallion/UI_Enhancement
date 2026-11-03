import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/budget_statutory_details.dart';
import 'package:stallion/models/project_budget_response.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';

class LegalStatutoryScreen extends StatefulWidget {
  const LegalStatutoryScreen(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      required this.budgetId,
      required this.budgetTitle,
      required this.gradeId,
      required this.totalEstmateCost,
      required this.totalProcuiteCost,
      required this.totalCost,
      required this.overBudgetAmount,
      required this.screenTittle,
      this.towarName})
      : super(key: key);
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? budgetId;
  final String? budgetTitle;
  final String? gradeId;
  final String? totalEstmateCost;
  final String? totalProcuiteCost;
  final String? totalCost;
  final String? overBudgetAmount;
  final String? screenTittle;

  @override
  State<LegalStatutoryScreen> createState() => _LegalStatutoryScreenState();
}

class _LegalStatutoryScreenState extends State<LegalStatutoryScreen> {
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

  List<StatutoryDetailsList>? budgetVenderList = [];
  ResponseBudgetStatutoryDetailsResponse? responseData;
  Future<List<FinalBudgetResult>?> fetchProjectBudgeVendertList() async {
    try {
      CustomLoading.progressDialog(isLoading: true, context: context);

      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "project_id": widget.projectId ?? '',
        "towar_id": widget.towarId ?? '',
        "trans_statutory_id": widget.gradeId ?? '',
      };

      if (kDebugMode) {
        print(data);
      }

      var response =
          await apiNetworkHandler.post(AppUrl.getProjectBudgetLegalList, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = budgetStatutoryDetailsResponseFromJson(response.body);

        if (kDebugMode) {
          print(dataModel.response?.errorCode);
        }

        if (dataModel.response?.errorCode == "0") {
          setState(() {
            budgetVenderList = dataModel.response?.statutoryDetailsList;
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
                          double.parse(responseData?.totalStatutory ?? '0')),
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
                      'Total Paid',
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
                          double.parse(responseData?.totalAmountIncur ?? '0')),
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
            child: Text(widget.screenTittle ?? '',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, height: 0),
                textAlign: TextAlign.center),
          ),
          const Divider(
            color: Colors.black,
          ),
          const SizedBox(height: 10),
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

  Widget budgetCardVendor({required StatutoryDetailsList data}) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox(width: 150),
            Container(
              decoration: const BoxDecoration(),
              width: MediaQuery.of(context).size.width * 0.25,
              child: const Text(
                "Payment On",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(),
              width: MediaQuery.of(context).size.width * 0.45,
              child: Text(
                DateFormat('dd MMM yyyy')
                    .format(data.transStatutoryDate ?? DateTime.now()),
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
                "Amount Paid",
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
                    double.parse(data.transStatutoryAmount ?? '')),
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
                "Remarks",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(),
              width: MediaQuery.of(context).size.width * 0.45,
              child: Text(
                data.transStatutoryNote ?? '',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
