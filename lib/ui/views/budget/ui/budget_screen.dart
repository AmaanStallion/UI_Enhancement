import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/models/project_budget_response.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/budget/ui/auto_recon.dart';
import 'package:stallion/ui/views/budget/ui/po_raw_material/budget_categories.dart';
import 'package:stallion/ui/views/budget/ui/wo_contracts/budget_wo_categories.dart';
import 'package:stallion/ui/views/budget/ui/wo_contracts/contract_overbudget.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'po_raw_material/raw_material_overbudget.dart';
import 'statutory_cost_screen/statutory_cost_screen.dart';

// class BudgetScreen extends ConsumerStatefulWidget {
//   BudgetScreen(
//       {Key? key,
//       this.projectId,
//       this.towarId,
//       this.projectName,
//       this.towarName})
//       : super(key: key);
//   final String? projectId;
//   String? towarId;
//   final String? projectName;
//   final String? towarName;
//   @override
//   ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
// }

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late NotificationArgs args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context)!.settings.arguments as NotificationArgs;
  }

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
  bool isBottomViewMore = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? _selectedToDate;
  DateTime? _selectedFormDate;
  int _isDropDown = -1;
  TextEditingController fromDateControler = TextEditingController();
  TextEditingController toDateControler = TextEditingController();
  ProjectBudgetResponse? projectBudgetResponsee = null;
  List<FinalBudgetResult>? finalBudgetResultResponse = [];
  List<TowarList>? towarListResponse = [];
  String? strTowarName = "All Tower";
  String? budgetStatus = '';
  String? contractStatus = '';
  String? statutoryStatus = '';

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedFormDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedFormDate) {
      setState(() {
        _selectedFormDate = picked;
        // ref.read(budgetApiProvider).setSelectedFormDate(data: picked);
        fromDateControler.text =
            DateFormat('yyyy/M/d').format(_selectedFormDate!);
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedToDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedToDate) {
      setState(() {
        _selectedToDate = picked;
        toDateControler.text = DateFormat('yyyy/M/d').format(_selectedToDate!);
      });
    }
  }

  Future<List<FinalBudgetResult>?> fetchProjectBudget() async {
    String formatDate(DateTime dateTime) {
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    }

    try {
      CustomLoading.progressDialog(isLoading: true, context: context);

      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "project_id": args.projectId ?? '',
        "start_date":
            _selectedFormDate == null ? '' : formatDate(_selectedFormDate!),
        "end_date": _selectedToDate == null ? '' : formatDate(_selectedToDate!),
        "towar_id": args.response?.towarId ?? '',
      };

      if (kDebugMode) {
        print(data);
      }

      var response =
          await apiNetworkHandler.post(AppUrl.getProjectBudget, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = projectBudgetFromJson(response.body);

        if (kDebugMode) {
          print(dataModel.response?.errorCode);
        }

        if (dataModel.response?.errorCode == "0") {
          setState(() {
            projectBudgetResponsee = dataModel.response;
            finalBudgetResultResponse = dataModel.response?.finalBudgetResult;
            towarListResponse = dataModel.response?.towarList;
            budgetStatus = dataModel.response?.budgetStatus;
            contractStatus = dataModel.response?.contractStatus;
            statutoryStatus = dataModel.response?.statutoryStatus;
          });
          if (dataModel.response!.towarList!.isNotEmpty) {
            towarListResponse?.insert(
                0, TowarList(towarId: "", towarName: "All Tower"));
          }
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
      fetchProjectBudget();
      setState(() {
        strTowarName = 'args.towarName';
      });
    });
    super.initState();
  }

  selectTowarModal() {
    return showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              elevation: 0,
              titlePadding: EdgeInsets.zero,
              actionsPadding:
                  const EdgeInsets.only(bottom: 10, left: 10, right: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    )),
                child: const Text(
                  "SELECT TOWER",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 180,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Text(
                      "NO",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 180,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Text(
                      "YES",
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
              content: SizedBox(
                height: 320,
                width: 360.0,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 310,
                        width: 360,
                        child: ListView.builder(
                            itemCount: towarListResponse?.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      // args.towarId =
                                      //     towarListResponse![index].towarId!;
                                      setState(() {
                                        strTowarName = towarListResponse![index]
                                            .towarName!;
                                      });

                                      Navigator.of(context).pop();
                                      fetchProjectBudget();
                                    },
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0,
                                                bottom: 20.0,
                                                top: 15.0),
                                            child: Text(
                                                towarListResponse?[index]
                                                        .towarName ??
                                                    ''),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10.0),
                                            child: Icon(
                                              args.response?.towarId ==
                                                      towarListResponse?[index]
                                                          .towarId
                                                  ? Icons
                                                      .check_circle_outline_sharp
                                                  : Icons.circle_outlined,
                                              color: args.response?.towarId ==
                                                      towarListResponse?[index]
                                                          .towarId
                                                  ? Colors.green
                                                  : Colors.grey,
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
                    ],
                  ),
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            args.towarName != null && args.towarName!.isNotEmpty
                ? '${args.projectName!.toUpperCase()} - ${args.towarName!.toUpperCase()}'
                : args.projectName!.toUpperCase(),
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
      ),
      bottomNavigationBar: SizedBox(
        height: isBottomViewMore ? 204 : 124,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Divider(color: Colors.black),
            isBottomViewMore
                ? InkWell(
                    onTap: () {
                      setState(() {
                        isBottomViewMore = false;
                      });
                    },
                    child: const Icon(
                      Icons.arrow_drop_down_sharp,
                      size: 34,
                    ),
                  )
                : InkWell(
                    onTap: () {
                      setState(() {
                        isBottomViewMore = true;
                      });
                    },
                    child: const Icon(
                      Icons.arrow_drop_up,
                      size: 34,
                    ),
                  ),
            Text(
              isBottomViewMore ? "View Less" : "View More",
              style: const TextStyle(fontSize: 10),
            ),
            if (isBottomViewMore)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Paid",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    Text(
                      formatToIndianStandard(double.parse(
                          projectBudgetResponsee?.totalPaid ?? '0')),
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                    )
                  ],
                ),
              ),
            if (isBottomViewMore) const SizedBox(height: 2),
            if (isBottomViewMore)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Cost to incur",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    Text(
                      formatToIndianStandard(double.parse(
                          projectBudgetResponsee?.totalCostToIncur ?? '0')),
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                    )
                  ],
                ),
              ),
            if (isBottomViewMore) const SizedBox(height: 2),
            if (isBottomViewMore)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total OverBudget Cost",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    Text(
                      formatToIndianStandard(double.parse(
                          projectBudgetResponsee?.totalOverBudgetCost ?? '0')),
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    )
                  ],
                ),
              ),
            if (isBottomViewMore)
              const Divider(
                color: Colors.black,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Estimated Cost",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                  Text(
                    formatToIndianStandard(
                        double.parse(projectBudgetResponsee?.totalCost ?? '0')),
                    style: const TextStyle(
                        color: Colors.black,
                        // fontWeight: FontWeight.w600,
                        fontSize: 14),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.black,
              width: double.maxFinite,
              child: Text(
                "Live Cost Per Sqr.Ft : ${formatToIndianStandard(double.parse(projectBudgetResponsee?.costPerSqft ?? '0'))}",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text('BUDGET',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
          if (projectBudgetResponsee?.towarList?.length != 0)
            const SizedBox(
              height: 1,
              child: Divider(
                color: Colors.black,
              ),
            ),
          if (projectBudgetResponsee?.towarList?.length != 0)
            InkWell(
              onTap: () {
                selectTowarModal();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(strTowarName?.toUpperCase() ?? '',
                      style: const TextStyle(
                          fontStyle: FontStyle.normal, fontSize: 16.0)),
                  horizontalSpaceSmall,
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.black),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          const Divider(color: Colors.grey),
          const SizedBox(height: 8),
          StartEndDateSelection(),
          const Divider(),
          // if (finalBudgetResultResponse?.length != 0)
          budgetStatus == '2' || contractStatus == '2' || statutoryStatus == '2'
              ? Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // for (int i = 0; i < finalBudgetResultResponse!.length; i++)
                        //   if ((finalBudgetResultResponse?[i].title ==
                        //               'Raw Materials' &&
                        //           projectBudgetResponsee?.budgetStatus == "2") ||
                        //       (finalBudgetResultResponse?[i].title == 'Contracts' &&
                        //           projectBudgetResponsee?.contractStatus == "2") ||
                        //       (finalBudgetResultResponse?[i].title ==
                        //               'Statutory Cost' &&
                        //           projectBudgetResponsee?.statutoryStatus == "2") ||
                        //       (finalBudgetResultResponse?[i].title ==
                        //               'Raw Materials Over Budget' &&
                        //           projectBudgetResponsee?.budgetStatus == "2") ||
                        //       finalBudgetResultResponse?[i].arrBudgetCost?.length ==
                        //           0)
                        if (finalBudgetResultResponse?[0].title ==
                                'Raw Materials' &&
                            projectBudgetResponsee?.budgetStatus == "2")
                          budgetCard(
                            currInt: 0,
                            data: finalBudgetResultResponse![0],
                            onDropDown: () {
                              if (_isDropDown == 0) {
                                setState(() {
                                  _isDropDown = -1;
                                });
                              } else {
                                setState(() {
                                  _isDropDown = 0;
                                });
                              }
                            },
                            isDropDownActive: finalBudgetResultResponse![0]
                                    .arrBudgetCost!
                                    .isEmpty
                                ? false
                                : true,
                          ),
                        if (finalBudgetResultResponse?[1].title ==
                                'Contracts' &&
                            projectBudgetResponsee?.contractStatus == "2")
                          budgetCard(
                            currInt: 1,
                            data: finalBudgetResultResponse![1],
                            onDropDown: () {
                              if (_isDropDown == 1) {
                                setState(() {
                                  _isDropDown = -1;
                                });
                              } else {
                                setState(() {
                                  _isDropDown = 1;
                                });
                              }
                            },
                            isDropDownActive: finalBudgetResultResponse![1]
                                    .arrBudgetCost!
                                    .isEmpty
                                ? false
                                : true,
                          ),
                        if (finalBudgetResultResponse?[2].title ==
                                'Statutory Cost' &&
                            projectBudgetResponsee?.statutoryStatus == "2")
                          budgetCard(
                            currInt: 2,
                            data: finalBudgetResultResponse![2],
                            onDropDown: () {
                              if (_isDropDown == 2) {
                                setState(() {
                                  _isDropDown = -1;
                                });
                              } else {
                                setState(() {
                                  _isDropDown = 2;
                                });
                              }
                            },
                            isDropDownActive: finalBudgetResultResponse![2]
                                    .arrBudgetCost!
                                    .isEmpty
                                ? false
                                : true,
                          ),
                        if (finalBudgetResultResponse?[3].title ==
                                'Raw Materials Over Budget' &&
                            projectBudgetResponsee?.budgetStatus == "2")
                          budgetCard(
                            currInt: 3,
                            data: finalBudgetResultResponse![3],
                            onDropDown: () {
                              if (_isDropDown == 3) {
                                setState(() {
                                  _isDropDown = -1;
                                });
                              } else {
                                setState(() {
                                  _isDropDown = 3;
                                });
                              }
                            },
                            isDropDownActive: finalBudgetResultResponse![3]
                                    .arrBudgetCost!
                                    .isEmpty
                                ? false
                                : true,
                          ),
                        if (finalBudgetResultResponse?[4].title ==
                                'Contracts Over Budget' &&
                            projectBudgetResponsee?.contractStatus == "2")
                          budgetCard(
                            currInt: 4,
                            data: finalBudgetResultResponse![4],
                            onDropDown: () {
                              if (_isDropDown == 4) {
                                setState(() {
                                  _isDropDown = -1;
                                });
                              } else {
                                setState(() {
                                  _isDropDown = 4;
                                });
                              }
                            },
                            isDropDownActive: finalBudgetResultResponse![4]
                                    .arrBudgetCost!
                                    .isEmpty
                                ? false
                                : true,
                          ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return AutoRecon(
                                    projectId: args.projectId,
                                    projectName: args.projectName,
                                    towarId: args.response?.towarId,
                                    // towarName: args.towarName!,
                                  );
                                },
                              ),
                            );
                          },
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 6),
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(6)),
                              child: Text("Auto Reco")),
                        )
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: Center(
                    child: Text(
                      budgetStatus == '' ||
                              contractStatus == '' ||
                              statutoryStatus == ''
                          ? ""
                          : "Budget is under review and yet to be approved.",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget budgetCard(
      {bool isDropDownActive = true,
      required VoidCallback onDropDown,
      required FinalBudgetResult data,
      required int currInt}) {
    return InkWell(
      onTap: () {
        if (data.title == 'Raw Materials') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return BudgetCategories(
                  projectId: args.projectId,
                  projectName: args.projectName,
                  towarId: args.response?.towarId,
                  // towarName: args.towarName!,
                  arrBudgetCost: data.arrBudgetCost,
                );
              },
            ),
          ).then((value) {
            fetchProjectBudget();
            setState(() {
              // strTowarName = args.towarName;
            });
          });
        } else if (data.title == 'Contracts') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return BudgetWoCategories(
                  projectId: args.projectId,
                  projectName: args.projectName,
                  towarId: args.response?.towarId,
                  // towarName: args.towarName!,
                  arrBudgetCost: data.arrBudgetCost,
                );
              },
            ),
          ).then((value) {
            fetchProjectBudget();
            setState(() {
              // strTowarName = args.towarName;
            });
          });
        } else if (data.title == 'Contracts Over Budget' &&
            projectBudgetResponsee?.contractStatus == "2") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return ContractOverBudgetScreen(
                  projectId: args.projectId,
                  projectName: args.projectName,
                  towarId: args.response?.towarId,
                  // towarName: args.towarName!,
                  arrBudgetCost: data.arrBudgetCost,
                  budgetId: '',
                  budgetTitle: 'CONTRACTS',
                );
              },
            ),
          ).then((value) {
            fetchProjectBudget();
            setState(() {
              // strTowarName = args.towarName;
            });
          });
        } else if (data.title == 'Statutory Cost') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return StatutoryCostScreen(
                  over_budget_flag: '0',
                  projectId: args.projectId,
                  projectName: args.projectName,
                  towarId: args.response?.towarId,
                  // towarName: args.towarName!,
                  arrBudgetCost: data.arrBudgetCost,
                  budgetId: '',
                  budgetTitle: 'CONTRACTS',
                );
              },
            ),
          ).then((value) {
            fetchProjectBudget();
            setState(() {
              // strTowarName = args.towarName;
            });
          });
        } else if (data.title == 'Raw Materials Over Budget' &&
            projectBudgetResponsee?.budgetStatus == "2") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return RawMaterialOverBudget(
                  projectId: args.projectId,
                  projectName: args.projectName,
                  towarId: args.response?.towarId,
                  // towarName: args.towarName!,
                  arrBudgetCost: data.arrBudgetCost,
                  budgetId: '',
                  budgetTitle: 'Over Budget',
                );
              },
            ),
          ).then((value) {
            fetchProjectBudget();
            setState(() {
              // strTowarName = args.towarName;
            });
          });
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.subtitle ?? '',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        formatToIndianStandard(
                            double.parse(data.totalcost ?? '0')),
                        style: TextStyle(
                          color: data.arrBudgetCost!.isEmpty
                              ? Colors.red
                              : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.keyboard_arrow_right_sharp,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isDropDownActive)
            Column(
              children: [
                InkWell(
                  onTap: onDropDown,
                  child: _isDropDown == currInt
                      ? const Icon(
                          Icons.arrow_drop_up,
                          size: 34,
                        )
                      : const Icon(
                          Icons.arrow_drop_down_sharp,
                          size: 34,
                        ),
                ),
                if (_isDropDown == currInt)
                  ListView.separated(
                    shrinkWrap: true,
                    itemCount: data.arrBudgetCost?.length ?? 0,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 54, vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                data.arrBudgetCost?[index].title ?? '',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                formatToIndianStandard(double.parse(
                                    data.arrBudgetCost?[index].amount ?? '0')),
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: data.arrBudgetCost?[index].title ==
                                          "Total Over Budget Cost"
                                      ? Colors.red
                                      : Colors.black,
                                  fontSize: 16,
                                  fontWeight:
                                      data.arrBudgetCost?[index].title ==
                                              'Total Cost to Incur'
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          const Divider(
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget StartEndDateSelection() {
    return Form(
      key: _formKey,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 40),
          Container(
            padding: const EdgeInsets.only(right: 12),
            child: const AppText(
              title: "Filter",
              fontSize: 16,
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                _selectFromDate(context);
              },
              child: TextFormField(
                // validator: (value) {
                //   if (value!.isEmpty) {
                //     return "(From Date Cannot be Ready)";
                //   }
                // },
                enabled: false,
                readOnly: true,
                controller: fromDateControler,
                style: const TextStyle(color: Colors.black, fontSize: 13.0),
                decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.grey,
                    )),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.red,
                    )),
                    contentPadding: EdgeInsets.all(12.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    hintText: 'Select From Date',
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 116, 116, 116),
                      fontSize: 13.0,
                      fontWeight: FontWeight.w200,
                      fontFamily: 'HelveticaNeue',
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_month_outlined,
                    )),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: InkWell(
              onTap: () {
                _selectToDate(context);
              },
              child: TextFormField(
                enabled: false,
                readOnly: true,
                controller: toDateControler,
                style: const TextStyle(color: Colors.black, fontSize: 13.0),
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    hintText: 'Select To Date',
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 116, 116, 116),
                      fontSize: 13.0,
                      fontWeight: FontWeight.w200,
                      fontFamily: 'HelveticaNeue',
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_month_outlined,
                    )),
              ),
            ),
          ),
          const SizedBox(width: 20),
          OutlinedButton(
            onPressed: () {
              if (_selectedFormDate != null && _selectedToDate != null) {
                fetchProjectBudget();
              }
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.black,
              side: const BorderSide(width: 1.0, color: Colors.black45),
            ),
            child: const Text('Submit',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 16.0,
                  color: Colors.white,
                )),
          ),
          const SizedBox(width: 20),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedToDate = null;
                _selectedFormDate = null;
                fromDateControler.clear();
                toDateControler.clear();
                // offset = '0';
              });
              fetchProjectBudget();
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(width: 1.0, color: Colors.black45),
            ),
            child: const Text('Reset',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 16.0,
                )),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
