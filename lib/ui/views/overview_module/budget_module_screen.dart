import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stallion/models/get_budget_overview.dart';
import 'package:stallion/models/get_overview.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/ui/views/budget/ui/budget_screen.dart';
import 'package:stallion/ui/views/overview_module/overview.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BudgetModuleScreen extends StatefulWidget {
  const BudgetModuleScreen(
      {super.key,
      required this.halfPie,
      required this.halfPieValue,
      required this.totalBudget,
      required this.totalSpend,
      required this.rawMaterialOverBudget,
      required this.contractOverBudget,
      required this.poBudgetList,
      required this.projectId,
      required this.towarName,
      required this.towarId,
      required this.projectName,
      required this.woBudgetList});
  final String? halfPie;
  final String? halfPieValue;
  final String? totalBudget;
  final String? totalSpend;
  final List<ContractOverBudget>? rawMaterialOverBudget;
  final List<ContractOverBudget>? contractOverBudget;
  final List<PoBudgetList>? poBudgetList;
  final List<WoBudgetList>? woBudgetList;
  final String projectId;
  final String towarName;
  final String projectName;
  final String towarId;

  @override
  State<BudgetModuleScreen> createState() => _BudgetModuleScreenState();
}

class _BudgetModuleScreenState extends State<BudgetModuleScreen> {
  String formatToIndianStandard(double numberString) {
    final indianRupeesFormat = NumberFormat.currency(
      name: "INR",
      locale: 'en_IN',
      decimalDigits: 2, // change it to get decimal places
      symbol: 'Rs ',
    );

    return indianRupeesFormat.format(numberString);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width / 3) - 50,
      height: 820,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(166, 77, 77, 77),
            offset: Offset(
              5.0,
              5.0,
            ),
            blurRadius: 10.0,
            spreadRadius: 2.0,
          ), //BoxShadow
          BoxShadow(
            color: Color.fromARGB(255, 61, 61, 61),
            offset: Offset(0.0, 0.0),
            blurRadius: 0.0,
            spreadRadius: 0.0,
          ), //BoxShadow
        ],
        color: Colors.black, // Color(0xFF383838), //Color(0xFF2C2F33)
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "BUDGET",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 820,
                ),
                Align(
                  alignment:
                      //  MediaQuery.of(context).size.width > 1184
                      //     ?
                      Alignment.topLeft,
                  // : Alignment.center,
                  child: Container(
                    width: MediaQuery.of(context).size.width > 1184 ? 300 : 200,
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.zero,
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
                    child: SfCircularChart(
                      palette: const <Color>[
                        Colors.green,
                        Colors.yellow,
                      ],
                      margin: EdgeInsets
                          .zero, // Setting margin to zero removes padding around the chart
                      backgroundColor: Colors.black,
                      series: <CircularSeries>[
                        DoughnutSeries<ChartData, String>(
                          dataSource: [
                            ChartData(
                                '2nd', double.parse(widget.halfPieValue ?? '0')
                                // Colors.amber,
                                ),
                            ChartData('3rd',
                                double.parse(widget.halfPieValue ?? '0') - 100
                                // Colors.green,
                                ),
                          ],
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          // pointColorMapper: (ChartData data, _) => data.colr,
                          // dataLabelSettings:
                          //     const DataLabelSettings(isVisible: true),
                          strokeColor: Colors.black,
                          strokeWidth: 6,
                          // Starting angle of doughnut
                          startAngle: 270,
                          // Ending angle of doughnut
                          endAngle: 90,
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 120,
                  left:
                      // MediaQuery.of(context).size.width > 1184
                      //     ?
                      MediaQuery.of(context).size.width > 1184 ? 120 : 76,
                  // : 140,
                  child: Text(
                    '${widget.halfPieValue} %',
                    style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width > 1184 ? 22 : 18,
                        height:
                            MediaQuery.of(context).size.width > 1184 ? 1 : 2,
                        fontWeight: FontWeight.w900,
                        color: Colors.white),
                  ),
                ),
                // MediaQuery.of(context).size.width > 1184
                //     ?
                Positioned(
                  top: 26,
                  // left: 0,
                  right: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            height: 20,
                            width: 20,
                            // color: Colors.amber,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                // Where the linear gradient begins and ends
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                // Add one stop for each color. Stops should increase from 0 to 1
                                stops: [0.2, 0.9],
                                colors: [
                                  Color.fromARGB(255, 32, 147, 241),
                                  Colors.red,
                                ],
                              ),
                              // color: Colors.yellow,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Budget",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                widget.totalBudget ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      //
                      // const Spacer(),
                      // Divider(
                      //   thickness: 2,
                      //   color: Colors.white,
                      // ),
                      // Container(
                      //   width: 120,
                      //   height: 0.5,
                      //   decoration: BoxDecoration(
                      //       border: Border.all(color: Colors.grey)),
                      // ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            height: 20,
                            width: 20,
                            // color: Colors.amber,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                // Where the linear gradient begins and ends
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                // Add one stop for each color. Stops should increase from 0 to 1
                                stops: [0.2, 0.9],
                                colors: [
                                  Color.fromARGB(255, 32, 147, 241),
                                  Colors.red,
                                ],
                              ),
                              // color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Spent",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                widget.totalSpend ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: 170,
                  right: 0,
                  left: 0,
                  child: Column(
                    children: [
                      if (widget.poBudgetList != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 0),
                          child: RawmaterialCont(
                              widthCont:
                                  (MediaQuery.of(context).size.width / 3) - 78),
                        ),
                      const SizedBox(height: 16),
                      if (widget.woBudgetList != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 0),
                          child: ContractsCont(
                              widthCont:
                                  (MediaQuery.of(context).size.width / 3) - 78),
                        ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 20,
                            width: 20,
                            // color: Colors.amber,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                // Where the linear gradient begins and ends
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                // Add one stop for each color. Stops should increase from 0 to 1
                                stops: [0.2, 0.9],
                                colors: [
                                  Color.fromARGB(255, 32, 147, 241),
                                  Colors.red,
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            // width: MediaQuery.of(context).size.width >
                            //         1184
                            //     ? 110
                            //     : 70,
                            child: Text(
                              "Over Budget",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width > 1184
                                          ? 16
                                          : 14,
                                  height: 0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (widget.rawMaterialOverBudget != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceAround,
                            // mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Raw Material",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.blue),
                                  ),
                                  const SizedBox(height: 6),
                                  for (int i = 0;
                                      i < widget.rawMaterialOverBudget!.length;
                                      i++)
                                    Container(
                                      width: MediaQuery.of(context).size.width >
                                              1185
                                          ? MediaQuery.of(context).size.width /
                                                  3 -
                                              420
                                          : 150,
                                      padding:
                                          const EdgeInsets.only(bottom: 4.0),
                                      child: RichText(
                                        text: TextSpan(
                                          text:
                                              '•  ${widget.rawMaterialOverBudget?[i].name} ',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontFamily: 'HelveticaNeue'),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text:
                                                    '${widget.rawMaterialOverBudget?[i].amount}', // '(28th Feb 2023)',
                                                style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              // Container(
                              //   width: 2,
                              //   // height: 62,
                              //   margin: const EdgeInsets.only(top: 10),
                              //   decoration: BoxDecoration(
                              //       border: Border.all(color: Colors.yellow)),
                              // ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Contract",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.blue),
                                  ),
                                  const SizedBox(height: 6),
                                  for (int i = 0;
                                      i < widget.contractOverBudget!.length;
                                      i++)
                                    Container(
                                      padding: const EdgeInsets.only(
                                          left: 4, bottom: 4),
                                      // color: Colors.red,
                                      width: MediaQuery.of(context).size.width >
                                              1185
                                          ? MediaQuery.of(context).size.width /
                                                  3 -
                                              420
                                          : 150,
                                      // padding: const EdgeInsets.only(bottom: 4),
                                      child: RichText(
                                        text: TextSpan(
                                          text:
                                              '•  ${widget.contractOverBudget?[i].name} ',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontFamily: 'HelveticaNeue'),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text:
                                                    "${widget.contractOverBudget?[i].amount}", // '(28th Feb 2023)',
                                                style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            ],
                          ),
                        )
                    ],
                  ),
                ),

                Positioned(
                  top: 735,
                  right: 0,
                  left: 0,
                  child: Container(
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.black,
                      // border: Border(
                      //   bottom: BorderSide(color: Colors.grey),
                      // ),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (_) {
                            //       return BudgetScreen(
                            //         projectId: widget.projectId,
                            //         projectName: widget.projectName,
                            //         towarId: widget.towarId,
                            //         towarName: widget.towarName,
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
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              // color: Colors.black,
                              border: Border(
                                bottom: BorderSide(color: Colors.grey),
                              ),
                            ),
                            child: const Text(
                              "View More",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey, height: 0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            // Container(color: Colors.cyan, height: 1076),
          ],
        ),
      ),
    );
  }

  Widget RawmaterialCont({required double widthCont}) {
    return Container(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(104, 0, 0, 0),
              offset: Offset(
                5.0,
                5.0,
              ),
              blurRadius: 10.0,
              spreadRadius: 2.0,
            ), //BoxShadow
            BoxShadow(
              color: Colors.black,
              offset: Offset(0.0, 0.0),
              blurRadius: 0.0,
              spreadRadius: 0.0,
            ), //BoxShadow
          ],
          // border: Border.all(
          //     color: const Color.fromARGB(255, 177, 177, 177)),
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 32, 32, 32),
        ),
        child: Column(
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                SizedBox(
                  width: 0.31 * widthCont,
                  // height: 50,
                  // color: Colors.amber,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        // color: Colors.amber,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            // Where the linear gradient begins and ends
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            // Add one stop for each color. Stops should increase from 0 to 1
                            stops: [0.2, 0.9],
                            colors: [
                              Color.fromARGB(255, 32, 147, 241),
                              Colors.red,
                            ],
                          ),
                        ),
                      ),
                      Container(
                        // color: Colors.cyan,
                        padding: const EdgeInsets.only(left: 10),
                        width: (0.31 * widthCont) - 50,
                        //     MediaQuery.of(context).size.width > 1184 ? 110 : 70,
                        child: Text(
                          "Raw Material",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width > 1184
                                  ? 16
                                  : 14,
                              height: 0),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 0.34 * widthCont,
                  // height: 50,
                  // color: Colors.red,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Est. Qty",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: MediaQuery.of(context).size.width > 1184
                                ? 16
                                : 14,
                            height: 0),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width:
                            MediaQuery.of(context).size.width > 1184 ? 60 : 50,
                        decoration: const BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey))),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Est. Cost",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: MediaQuery.of(context).size.width > 1184
                                ? 16
                                : 14,
                            height: 0),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 0.34 * widthCont,
                  // height: 50,
                  // color: Colors.cyan,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Purch. Qty",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: MediaQuery.of(context).size.width > 1184
                                ? 16
                                : 14,
                            height: 0),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width:
                            MediaQuery.of(context).size.width > 1184 ? 76 : 60,
                        decoration: const BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey))),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Purch. Cost",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: MediaQuery.of(context).size.width > 1184
                                ? 16
                                : 14,
                            height: 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            for (int i = 0; i < widget.poBudgetList!.length; i++)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 18),
                    width: 0.31 * widthCont,
                    // height: 50,
                    // color: Colors.amber,
                    child: Text(
                      widget.poBudgetList?[i].gradeName ?? '',
                      // textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width > 1184
                              ? 16
                              : 14,
                          height: 0),
                    ),
                  ),
                  SizedBox(
                    width: 0.34 * widthCont,
                    // height: 50,
                    // color: Colors.red,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.poBudgetList?[i].budgetEstQuantity ?? '',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width > 1184
                                  ? 15
                                  : 13,
                              height: 0),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: MediaQuery.of(context).size.width > 1184
                              ? 90
                              : 76,
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey))),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatToIndianStandard(double.parse(widget
                                  .poBudgetList?[i].estTotal ??
                              '0')), // '₹ ${widget.poBudgetList?[i].estTotal}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width > 1184
                                  ? 15
                                  : 13,
                              height: 0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 0.34 * widthCont,
                    // height: 50,
                    // color: Colors.cyan,
                    child: Column(
                      children: [
                        Text(
                          widget.poBudgetList?[i].purchaseTotalQuantity ?? '',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width > 1184
                                  ? 15
                                  : 13,
                              height: 0),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: MediaQuery.of(context).size.width > 1184
                              ? 86
                              : 80,
                          // MediaQuery.of(context)
                          //             .size
                          //             .width >
                          //         1184
                          //     ? 60
                          //     : 50,
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey))),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatToIndianStandard(double.parse(widget
                                  .poBudgetList?[i].purchaseAmount ??
                              '0')), //'₹ ${widget.poBudgetList?[i].purchaseAmount}',
                          style: TextStyle(
                              color:
                                  // widget.poBudgetList?[i].overBudgetFlag == '1'
                                  double.parse(widget
                                                  .poBudgetList?[i].estTotal ??
                                              '0') <
                                          double.parse(widget.poBudgetList?[i]
                                                  .purchaseAmount ??
                                              '0')
                                      ? Colors.red
                                      : Colors.white,
                              fontSize: MediaQuery.of(context).size.width > 1184
                                  ? 15
                                  : 13,
                              height: 0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 6),
          ],
        ));
  }

  Widget ContractsCont({required double widthCont}) {
    return Container(
        decoration: BoxDecoration(
          // border: Border.all(
          //     color: const Color.fromARGB(255, 177, 177, 177)),
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 32, 32, 32),
        ),
        child: Column(
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                SizedBox(
                  width: 0.31 * widthCont,
                  // height: 50,
                  // color: Colors.amber,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        // color: Colors.amber,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            // Where the linear gradient begins and ends
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            // Add one stop for each color. Stops should increase from 0 to 1
                            stops: [0.2, 0.9],
                            colors: [
                              Color.fromARGB(255, 32, 147, 241),
                              Colors.red,
                            ],
                          ),
                        ),
                      ),
                      Container(
                        // color: Colors.cyan,
                        padding: const EdgeInsets.only(left: 10),
                        width: (0.31 * widthCont) - 50,
                        //     MediaQuery.of(context).size.width > 1184 ? 110 : 70,
                        child: Text(
                          "Contracts",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width > 1184
                                  ? 16
                                  : 14,
                              height: 0),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 0.34 * widthCont,
                  // height: 50,
                  // color: Colors.red,
                  child: Text(
                    "Est. Cost",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize:
                            MediaQuery.of(context).size.width > 1184 ? 16 : 14,
                        height: 0),
                  ),
                ),
                SizedBox(
                  width: 0.34 * widthCont,
                  // height: 50,
                  // color: Colors.cyan,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Cont. Awarded",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: MediaQuery.of(context).size.width > 1184
                                ? 16
                                : 14,
                            height: 0),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width:
                            MediaQuery.of(context).size.width > 1184 ? 76 : 60,
                        decoration: const BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey))),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Cont. Paid",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: MediaQuery.of(context).size.width > 1184
                                ? 16
                                : 14,
                            height: 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < widget.woBudgetList!.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 18),
                      width: 0.31 * widthCont,
                      // height: 50,
                      // color: Colors.amber,
                      child: Text(
                        widget.woBudgetList?[i].budgetWoName ?? '',
                        // textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width > 1184
                                ? 16
                                : 14,
                            height: 0),
                      ),
                    ),
                    SizedBox(
                      width: 0.34 * widthCont,
                      // height: 50,
                      // color: Colors.red,
                      child: Text(
                        formatToIndianStandard(double.parse(widget
                                .woBudgetList?[i].budgetWoEstContractValue ??
                            '0')), //'₹ ${widget.woBudgetList?[i].budgetWoEstContractRate}'

                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width > 1184
                                ? 15
                                : 13,
                            height: 0),
                      ),
                    ),
                    SizedBox(
                      width: 0.34 * widthCont,
                      // height: 50,
                      // color: Colors.cyan,
                      child: Column(
                        children: [
                          Text(
                            formatToIndianStandard(double.parse(widget
                                    .woBudgetList?[i].budgetWoContractAvoided ??
                                '0')),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width > 1184
                                        ? 15
                                        : 13,
                                height: 0),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: MediaQuery.of(context).size.width > 1184
                                ? 86
                                : 80,
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey))),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatToIndianStandard(double.parse(widget
                                    .woBudgetList?[i].budgetWoContractPaid ??
                                '0')), //'₹ ${widget.poBudgetList?[i].purchaseAmount}',
                            style: TextStyle(
                                color: double.parse(widget.woBudgetList?[i]
                                                .budgetWoEstContractRate ??
                                            '0') <
                                        double.parse(widget.woBudgetList?[i]
                                                .budgetWoContractPaid ??
                                            '0')
                                    //  widget.woBudgetList?[i].overBudgetFlag ==
                                    //         '1'
                                    ? Colors.red
                                    : Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width > 1184
                                        ? 15
                                        : 13,
                                height: 0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
          ],
        ));
  }
}
