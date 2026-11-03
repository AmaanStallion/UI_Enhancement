import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/models/profit_loss_response.dart';
import 'package:stallion/models/project_budget_response.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/budget/ui/budget_screen.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/salesmanagement/salesmainview.dart';
import 'package:stallion/ui/widgets/row_three_text.dart';
import 'package:stallion/utils/app_url.dart';

class ProfitAndLoss extends StatefulWidget {
  const ProfitAndLoss({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;

  @override
  State<ProfitAndLoss> createState() => _ProfitAndLossState();
}

class _ProfitAndLossState extends State<ProfitAndLoss> {
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
  List<InventryCostly>? projectCostly = [];
  List<InventryCostly>? inventryCostly = [];
  List<InventryCostly>? resultCostly = [];
  BudgetDetails? responseData;
  Future<List<FinalBudgetResult>?> fetchProfitLoss() async {
    try {
      CustomLoading.progressDialog(isLoading: true, context: context);

      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "project_id": widget.projectId ?? '',
        "towar_id": widget.towarId ?? '',
      };

      if (kDebugMode) {
        print(data);
      }

      var response = await apiNetworkHandler.post(AppUrl.getProfitLoss, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = profitLossResponseFromJson(response.body);

        if (kDebugMode) {
          print(dataModel.response?.errorCode);
        }

        if (dataModel.response?.errorCode == "0") {
          setState(() {
            responseData = dataModel.response?.budgetDetails;
            projectCostly = dataModel.response?.projectCostly;
            inventryCostly = dataModel.response?.inventryCostly;
            resultCostly = dataModel.response?.resultCostly;
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
      fetchProfitLoss();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: resultCostly!.isNotEmpty
          ? Container(
              height: 62,
              color: Colors.black,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    "GROSS PROFIT / LOSS : ${formatToIndianStandard(double.parse(resultCostly?[0].totalcost ?? '0'))}",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Per Sq ft : ${formatToIndianStandard(double.parse(resultCostly?[1].totalcost ?? '0'))}",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            widget.towarName!.isNotEmpty
                ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                : widget.projectName!.toUpperCase(),
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
        padding: const EdgeInsets.symmetric(horizontal: 80),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "PROFIT & LOSS",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Divider(),
              const SizedBox(height: 10),
              if (projectCostly!.isNotEmpty)
                const Text('PROJECT COSTING',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              if (projectCostly!.isNotEmpty)
                InkWell(
                  onTap: () {
                    if (responseData?.budgetStatus == '2') {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) {
                      //       return BudgetScreen(
                      //         projectId: widget.projectId,
                      //         projectName: widget.projectName,
                      //         towarId: widget.towarId,
                      //         towarName: widget.towarName!,
                      //       );
                      //     },
                      //   ),
                      // );
                      Navigator.of(context).pushNamed(
                        '/budgetScreen',
                        arguments: NotificationArgs(
                          projectId: widget.projectId,
                          // towarId: widget.towarId,
                          projectName: widget.projectName,
                          // towarName: widget.towarName,
                          towarName: widget.towarName,

                          response: NotificationResponseData(
                            towarId: widget.towarId,
                          ),
                        ),
                      );
                    } else {
                      showDialog<void>(
                          barrierDismissible: true,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), // Set radius to zero
                              ),
                              titlePadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              actionsPadding: const EdgeInsets.only(
                                  bottom: 10, left: 10, right: 10),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              actionsAlignment: MainAxisAlignment.center,
                              title: const Text(
                                "You don't have an access to this module",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              actions: [
                                InkWell(
                                  onTap: () {
                                    // Navigator.of(context).pop();

                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    width: 250,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(7)),
                                    child: const Text(
                                      "Okay",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          });
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        for (int i = 0; i < projectCostly!.length; i++)
                          Column(
                            children: [
                              rowThreeText(
                                context: context,
                                title: projectCostly?[i].title ?? '',
                                titleValue: formatToIndianStandard(double.parse(
                                    projectCostly?[i].totalcost ?? '0')),
                              ),
                              if (projectCostly!.length - 1 != i)
                                const Divider(),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 40),
              if (inventryCostly!.isNotEmpty)
                const Text(
                  'INVENTORY SALES COSTING',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
              const SizedBox(height: 10),
              if (inventryCostly!.isNotEmpty)
                InkWell(
                  onTap: () {
                    // if (true) {
                    var projectId = widget.projectId!;
                    var projectName = widget.projectName!;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          return SalesManagementView(
                              projectId: projectId,
                              towarId: widget.towarId!,
                              projectName: projectName,
                              towarName: widget.towarName!,
                              navigationFlag: 'Project');
                        },
                      ),
                    );
                    // } else {
                    //   showDialog<void>(
                    //       barrierDismissible: true,
                    //       context: context,
                    //       builder: (context) {
                    //         return AlertDialog(
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(
                    //                 8), // Set radius to zero
                    //           ),
                    //           titlePadding: const EdgeInsets.symmetric(
                    //               vertical: 10, horizontal: 20),
                    //           actionsPadding: const EdgeInsets.only(
                    //               bottom: 10, left: 10, right: 10),
                    //           contentPadding:
                    //               const EdgeInsets.symmetric(horizontal: 16),
                    //           actionsAlignment: MainAxisAlignment.center,
                    //           title: const Text(
                    //             "You don't have an access to this module",
                    //             style: TextStyle(
                    //               fontSize: 16,
                    //               fontWeight: FontWeight.w600,
                    //             ),
                    //             textAlign: TextAlign.center,
                    //           ),
                    //           actions: [
                    //             InkWell(
                    //               onTap: () {
                    //                 // Navigator.of(context).pop();

                    //                 Navigator.of(context).pop();
                    //               },
                    //               child: Container(
                    //                 width: 250,
                    //                 padding:
                    //                     const EdgeInsets.symmetric(vertical: 4),
                    //                 decoration: BoxDecoration(
                    //                     color: Colors.black,
                    //                     borderRadius: BorderRadius.circular(7)),
                    //                 child: const Text(
                    //                   "Okay",
                    //                   style: TextStyle(
                    //                     fontSize: 16,
                    //                     fontWeight: FontWeight.w600,
                    //                     color: Colors.white,
                    //                   ),
                    //                   textAlign: TextAlign.center,
                    //                 ),
                    //               ),
                    //             ),
                    //           ],
                    //         );
                    //       });
                    // }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        for (int j = 0; j < inventryCostly!.length; j++)
                          Column(
                            children: [
                              rowThreeText(
                                context: context,
                                title: inventryCostly?[j].title ?? '',
                                titleValue: formatToIndianStandard(double.parse(
                                    inventryCostly?[j].totalcost ?? '0')),
                              ),
                              if (inventryCostly!.length - 1 != j)
                                const Divider(),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
