import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stallion/models/get_overview.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/ui/views/overview_module/overview.dart';
import 'package:stallion/ui/views/permission/permissions.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PermissionModuleScreen extends StatefulWidget {
  const PermissionModuleScreen(
      {super.key,
      required this.pieChart,
      required this.pieChartValue,
      required this.latestIssued,
      required this.totoalExpired,
      required this.projectId,
      required this.towarName,
      required this.towarId,
      required this.projectName,
      required this.totoalPending});
  final List<PieChart>? pieChart;
  final List<PieChart>? pieChartValue;
  final List<String>? latestIssued;
  final List<TotoalExpired>? totoalExpired;
  final List<String>? totoalPending;
  final String projectId;
  final String towarName;
  final String projectName;
  final String towarId;

  @override
  State<PermissionModuleScreen> createState() => _PermissionModuleScreenState();
}

class _PermissionModuleScreenState extends State<PermissionModuleScreen> {
  DateTime? parseCustomDate(String dateString) {
    // Define a map to convert month abbreviations to their respective numeric value
    final months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };

    // Split the string to extract day, month abbreviation, and year
    List<String> parts = dateString.split(' ');
    if (parts.length != 3) return null;

    String dayPart = parts[0]
        .replaceAll(RegExp(r'[^\d]'), ''); // Remove non-numeric characters
    int day = int.tryParse(dayPart) ?? 1;

    int month = months[parts[1]] ??
        1; // Get the numeric value of the month abbreviation
    int year = int.tryParse(parts[2]) ??
        DateTime.now().year; // Use current year if year is invalid
    return DateTime(year, month, day);
  }

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
                  "PERMISSIONS",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: (MediaQuery.of(context).size.width / 3) - 70,
                  // decoration: BoxDecoration(
                  //     border: Border.all(color: Colors.red)),
                  child: SfCircularChart(palette: const <Color>[
                    Color.fromRGBO(255, 235, 59, 1),
                    Colors.orange,
                    Colors.green,
                  ], series: <CircularSeries>[
                    DoughnutSeries<PieChart, String>(
                      dataSource: widget.pieChart,
                      xValueMapper: (PieChart data, _) => data.name,
                      yValueMapper: (PieChart data, _) =>
                          double.parse(data.percentage ?? '1'),
                      // Mode of grouping
                      // pointColorMapper: (PieChart data, _) => data.colr,
                      groupMode: CircularChartGroupMode.point,
                      // dataLabelSettings:
                      //     const DataLabelSettings(isVisible: true),
                      enableTooltip: true,
                      strokeColor: Colors.black,
                      strokeWidth: 6,
                      // groupTo: 2,
                    )
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (int i = 0; i < widget.pieChart!.length; i++)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              height: 20,
                              width: 20,
                              // color: Colors.amber,
                              decoration: BoxDecoration(
                                color: i == 0
                                    ? Colors.yellow
                                    : i == 1
                                        ? Colors.orange
                                        : i == 2
                                            ? Colors.green
                                            : Colors.amber,
                                //  Colors.amber,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.pieChart?[i].name ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  widget.pieChart?[i].value ?? '',
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
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // const SizedBox(height: 14),
                if (widget.latestIssued != null &&
                    widget.latestIssued?.length != 0)
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
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
                      child: Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.start,
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
                            width: 100,
                            child: const Text(
                              "Latest\nIssued",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16, height: 0),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (int i = 0;
                                  i <
                                      (widget.latestIssued!.length > 4
                                          ? 4
                                          : widget.latestIssued!.length);
                                  i++)
                                Container(
                                  width: MediaQuery.of(context).size.width / 3 -
                                      230,
                                  child: Row(
                                    children: [
                                      Text(
                                        "•  ",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    3 -
                                                250,
                                        child: Text(
                                          "${widget.latestIssued?[i]}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontFamily: 'HelveticaNeue'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          )
                        ],
                      )),
                const SizedBox(height: 16),
                if (widget.totoalExpired != null &&
                    widget.totoalExpired?.length != 0)
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
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
                      child: Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.start,
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
                            width: 100,
                            child: const Text(
                              "Permissions\nExpired",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16, height: 0),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (int i = 0;
                                      i < widget.totoalExpired!.length;
                                      i++)
                                    if (i == 1 || i == 2 || i == 3)
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    3 -
                                                230,
                                        child: Row(
                                          children: [
                                            Text(
                                              "•  ",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3 -
                                                  250,
                                              child: RichText(
                                                text: TextSpan(
                                                  text:
                                                      '${widget.totoalExpired?[i].name} ',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontFamily:
                                                          'HelveticaNeue'),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text: parseCustomDate(widget
                                                                        .totoalExpired![
                                                                            i]
                                                                        .date ??
                                                                    '')!
                                                                .isBefore(
                                                                    DateTime
                                                                        .now())
                                                            ? ' (${widget.totoalExpired?[i].date})'
                                                            : "", // '(28th Feb 2023)',
                                                        style: const TextStyle(
                                                          color: Colors.red,
                                                        )),
                                                  ],
                                                ),

                                                // Text(
                                                //   "•  ${widget.totoalExpired?[i].name}",
                                                //   style: const TextStyle(
                                                //       color: Colors.white, fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                ],
                              )
                            ],
                          )
                        ],
                      )),
                const SizedBox(height: 16),
                if (widget.totoalPending != null &&
                    widget.totoalPending?.length != 0)
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
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
                            width: 100,
                            child: const Text(
                              "Total\nPending",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16, height: 0),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (int i = 0;
                                      i < widget.totoalPending!.length;
                                      i++)
                                    if (i == 1 || i == 2 || i == 3 || i == 4)
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    3 -
                                                230,
                                        child: Text(
                                          "•  ${widget.totoalPending?[i]}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                      ),
                                ],
                              )
                            ],
                          )
                        ],
                      )),
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
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) {
                      //       return Permissions(
                      //         projectId: widget.projectId,
                      //         towarId: widget.towarId,
                      //         projectName: widget.projectName,
                      //         towarName: widget.towarName,
                      //       );
                      //     },
                      //   ),
                      // );
                      Navigator.of(context).pushNamed(
                        '/permissions',
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
    );
  }
}
