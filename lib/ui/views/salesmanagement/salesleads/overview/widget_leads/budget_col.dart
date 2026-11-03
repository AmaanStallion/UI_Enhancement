import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stallion/models/resSalesLeadDashbord.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BudgetCol extends StatefulWidget {
  const BudgetCol({super.key, this.budget});
  final List<Budget>? budget;

  @override
  State<BudgetCol> createState() => _BudgetColState();
}

class _BudgetColState extends State<BudgetCol> {
  // late List<_ChartData> data;
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    // data = [
    //   _ChartData('CHN', 12),
    //   _ChartData('GER', 15),
    //   _ChartData('RUS', 30),
    //   _ChartData('BRZ', 6.4),
    //   _ChartData('IND', 14)
    // ];
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double widthParent = MediaQuery.of(context).size.width * 0.3;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      // margin: EdgeInsets.only(left: 20),
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      width: widthParent,
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow color
            spreadRadius: 0, // Spread radius
            blurRadius: 4, // Blur radius
            offset: Offset(4, 4), // Changes position of shadow
          ),
        ],
        border: Border.all(color: Colors.white60),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 20,
                width: 20,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.2, 0.9],
                    colors: [
                      Color.fromARGB(255, 32, 147, 241),
                      Colors.red,
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text(
                "Budget",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              )
            ],
          ),
          Container(
            height: 166,
            child: SfCartesianChart(
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  maximum: 40,
                  interval: 10,
                  majorGridLines:
                      MajorGridLines(width: 0), // Hides grid lines for Y-axis
                ),
                primaryXAxis: CategoryAxis(
                  majorGridLines:
                      MajorGridLines(width: 0), // Hides grid lines for X-axis
                ),
                plotAreaBorderWidth: 0,
                plotAreaBorderColor: Colors.transparent,
                // primaryXAxis: CategoryAxis(),
                // primaryYAxis:
                //     NumericAxis(minimum: 0, maximum: 40, interval: 10),
                tooltipBehavior: _tooltip,
                series: <CartesianSeries<Budget, String>>[
                  ColumnSeries<Budget, String>(
                      dataSource: widget.budget!,
                      xValueMapper: (Budget data, _) => data.name,
                      yValueMapper: (Budget data, _) =>
                          double.parse(data.percentage ?? '0'),
                      name: '',
                      color: Color.fromRGBO(8, 142, 255, 1))
                ]),
          )
        ],
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
