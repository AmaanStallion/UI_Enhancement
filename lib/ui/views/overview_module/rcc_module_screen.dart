import 'package:flutter/material.dart';
import 'package:stallion/models/get_overview.dart';
import 'package:stallion/models/projectRccmodel.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:stallion/ui/views/rccstructure/rccstructurescreen.dart';

class RccModuleScreen extends StatefulWidget {
  const RccModuleScreen({
    super.key,
    required this.lineChartData,
    required this.averageSlabSpeed,
    required this.slabConsumptionData,
    required this.lastUpdateRccResponse,
    required this.projectId,
    required this.towarName,
    required this.towarId,
    required this.projectName,
  });
  final List<LineChart>? lineChartData;
  final String averageSlabSpeed;
  final List<SlabConsumption>? slabConsumptionData;
  final List<String>? lastUpdateRccResponse;
  final String projectId;
  final String towarName;
  final String projectName;
  final String towarId;

  @override
  State<RccModuleScreen> createState() => _RccModuleScreenState();
}

class _RccModuleScreenState extends State<RccModuleScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 820,
      width: (MediaQuery.of(context).size.width / 3) - 50,
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
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  "RCC PROGRESS",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    title: AxisTitle(
                        text: "(Slab)",
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        )),
                    labelStyle: const TextStyle(
                      color: Colors.white, // Change label color here
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                    labelAlignment: LabelAlignment.start,
                  ),
                  primaryYAxis: NumericAxis(
                    title: AxisTitle(
                        text: "(Days)",
                        textStyle:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                    majorGridLines: const MajorGridLines(width: 0),
                    labelStyle: const TextStyle(
                      color: Colors.white, // Change label color here
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                    labelAlignment: LabelAlignment.start,
                  ),

                  series: <CartesianSeries<LineChart, String>>[
                    SplineSeries<LineChart, String>(
                      dataSource: widget.lineChartData!,
                      xValueMapper: (LineChart data, _) => data.name,
                      yValueMapper: (LineChart data, _) =>
                          int.tryParse(data.percentage ?? '0') ?? 0,
                      color: Colors.yellow,
                      markerSettings: const MarkerSettings(
                        isVisible: true,
                        width: 8, // Adjust the size of the circular marker
                      ),
                      dataLabelSettings: const DataLabelSettings(
                        textStyle: TextStyle(
                            fontFamily: 'Roboto',
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.normal,
                            color: Colors.amber,
                            fontSize: 12),
                        isVisible: true,
                      ),
                    )
                  ],

                  // tooltipBehavior: TooltipBehavior(
                  //   enable: true,
                  // ),
                ),
                // Text(
                //   "(Slab)",
                //   style: TextStyle(
                //       color: Colors.white, fontSize: 12, height: -0.4),
                // ),
                const SizedBox(height: 10),
                Container(
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.white))),
                  child: Text(
                    "Average Slab Speed: ${widget.averageSlabSpeed} days",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            "Raw Material Consumption",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      const SizedBox(height: 10),
                      if (widget.slabConsumptionData != null)
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  const Text(
                                    "",
                                    style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: 16,
                                        height: -1),
                                  ),
                                  const SizedBox(height: 8),
                                  for (int i = 0;
                                      i < widget.slabConsumptionData!.length;
                                      i++)
                                    Row(
                                      children: [
                                        Text(
                                          widget.slabConsumptionData?[i].name ??
                                              '',
                                          style: const TextStyle(
                                            color: Colors.blueAccent,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          ' (${widget.slabConsumptionData?[i].unit})',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            if (widget.slabConsumptionData != null)
                              Expanded(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      right: BorderSide(color: Colors.grey),
                                      // left: BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 18),
                                      const Text(
                                        " Consumption \n Last Slab",
                                        style: TextStyle(
                                          color: Colors.blueAccent,
                                          height: -1,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      for (int i = 0;
                                          i <
                                              widget
                                                  .slabConsumptionData!.length;
                                          i++)
                                        Text(
                                          widget.slabConsumptionData?[i]
                                                  .quantity ??
                                              '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            if (widget.slabConsumptionData != null)
                              Expanded(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 18),
                                    const Text(
                                      " Consumption \n Total",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 16,
                                          height: -1),
                                    ),
                                    const SizedBox(height: 8),
                                    for (int i = 0;
                                        i < widget.slabConsumptionData!.length;
                                        i++)
                                      Text(
                                        widget.slabConsumptionData?[i]
                                                .totalQuantity ??
                                            '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      "Latest Updates",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // lastUpdateRccResponse
                widget.lastUpdateRccResponse!.length > 0
                    ? Column(
                        children: [
                          for (int i = 0;
                              i <
                                  (widget.lastUpdateRccResponse!.length > 3
                                      ? 3
                                      : widget.lastUpdateRccResponse!.length);
                              // widget.lastUpdateRccResponse!.length;
                              i++)
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, bottom: 6),
                              child: Text(
                                "•  ${widget.lastUpdateRccResponse?[i] ?? ''}",
                                style: const TextStyle(
                                  // fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      )
                    : const SizedBox(
                        height: 60,
                        child: Center(
                          child: Text(
                            "No Record Found",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                // InkWell(
                // onTap: () {
                //   var projectId = widget.projectId!;
                //                         var projectName = widget.projectName!;
                //                         Navigator.push(
                //                           context,
                //                           MaterialPageRoute(
                //                             builder: (_) {
                //                               return RccStructure(
                //                                 projectId: projectId,
                //                                 towarId: widget.towarId!,
                //                                 projectName: projectName,
                //                                 towarName: widget.towarName!,
                //                               );
                //                             },
                //                           ),
                //                         )
                // },
                //   child: Container(
                //     decoration: BoxDecoration(
                //         border: Border(bottom: BorderSide(color: Colors.grey))),
                //     child: Text(
                //       "View More",
                //       style: TextStyle(
                //         fontSize: 16,
                //         color: Colors.grey,
                //       ),
                //     ),
                //   ),
                // )
                // const SizedBox(height: 30),
              ],
            ),
          ),
          Positioned(
            top: 784,
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
                      var projectId = widget.projectId!;
                      var projectName = widget.projectName!;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return RccStructure(
                              projectId: projectId,
                              towarId: widget.towarId!,
                              projectName: projectName,
                              towarName: widget.towarName!,
                            );
                          },
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
    );
  }
}
