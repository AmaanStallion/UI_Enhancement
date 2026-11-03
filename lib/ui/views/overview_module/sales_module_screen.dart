import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';
import 'package:stallion/models/get_overview.dart';
import 'package:stallion/ui/views/salesmanagement/salesmainview.dart';

class SalesModuleScreen extends StatefulWidget {
  const SalesModuleScreen(
      {super.key,
      required this.paymentStatusReceive,
      required this.paymentStatusOver,
      required this.availableValue,
      required this.successLead,
      required this.pendingRequest,
      required this.nextTargetPrice,
      required this.projectId,
      required this.towarName,
      required this.towarId,
      required this.brokerDetail,
      required this.projectName,
      required this.totalSoldAvg,
      required this.totalSoldSqft,
      required this.totalUnsoldAvg,
      required this.paymentCollectable,
      required this.flatReserved,
      required this.flatReservedPencentage,
      required this.unsoldInventry});
  final String? paymentStatusReceive;
  final String? paymentStatusOver;
  final List<AvailableValue>? availableValue;
  final List<AvailableValue>? successLead;
  final String? pendingRequest;
  final String? nextTargetPrice;
  final String? unsoldInventry;
  final String projectId;
  final String towarName;
  final String projectName;
  final String towarId;
  final List<BrokerDetail>? brokerDetail;
  final String? totalSoldSqft;
  final String? totalSoldAvg;
  final String? totalUnsoldAvg;
  final String? paymentCollectable;
  final String? flatReserved;
  final String? flatReservedPencentage;

  @override
  State<SalesModuleScreen> createState() => _SalesModuleScreenState();
}

class _SalesModuleScreenState extends State<SalesModuleScreen> {
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
          SizedBox(
            height: 820,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "SALES",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
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
                          const SizedBox(width: 10),
                          const Text(
                            "Payment Status",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Column(
                            children: [
                              const Text(
                                "Collectable",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                widget.paymentCollectable ?? '',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                          const Spacer(),
                          Container(
                            height: 44,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)),
                          ),
                          const Spacer(),
                          // const Spacer(),
                          Column(
                            children: [
                              const Text(
                                "Received",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                widget.paymentStatusReceive ?? '',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                          const Spacer(),
                          Container(
                            height: 44,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)),
                          ),
                          const Spacer(),
                          Column(
                            children: [
                              const Text(
                                "Overdue",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                widget.paymentStatusOver ?? '',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
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
                      const SizedBox(width: 10),
                      Text(
                        "Total Sold",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width > 1184
                              ? 16
                              : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(width: 50),
                    AnimatedProgressBar(
                      height: 10,
                      width: MediaQuery.of(context).size.width / 3 - 218,
                      value: double.parse(
                              widget.availableValue?[0].percentage ?? '0') /
                          100,
                      duration: const Duration(seconds: 2),
                      color: Colors.green,
                      backgroundColor: Colors.grey,
                    ),
                    const SizedBox(width: 20),
                    Text(
                      widget.availableValue?[0].value ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            MediaQuery.of(context).size.width > 1184 ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
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
                      const SizedBox(width: 10),
                      Text(
                        "Total Reserved",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width > 1184
                              ? 16
                              : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ),
                // const SizedBox(height: 14),

                Row(
                  children: [
                    const SizedBox(width: 50),
                    AnimatedProgressBar(
                      height: 10,
                      width: MediaQuery.of(context).size.width / 3 - 218,
                      value:
                          double.parse(widget.flatReservedPencentage ?? '0') /
                              100,
                      duration: const Duration(seconds: 2),
                      color: Colors.orange,
                      backgroundColor: Colors.grey,
                    ),
                    const SizedBox(width: 20),
                    Text(
                      '${widget.flatReserved}',
                      // widget.successLead?[0].value ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            MediaQuery.of(context).size.width > 1184 ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
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
                      const SizedBox(width: 10),
                      Text(
                        "Successful Leads",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width > 1184
                              ? 16
                              : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ),

                // const SizedBox(height: 14),
                Row(
                  children: [
                    const SizedBox(width: 50),
                    AnimatedProgressBar(
                      height: 10,
                      width: MediaQuery.of(context).size.width / 3 - 218,
                      value: double.parse(
                              widget.successLead?[0].percentage ?? '0') /
                          100,
                      duration: const Duration(seconds: 2),
                      color: Colors.orange,
                      backgroundColor: Colors.grey,
                    ),
                    const SizedBox(width: 20),
                    Text(
                      widget.successLead?[0].value ?? '',
                      // textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            MediaQuery.of(context).size.width > 1184 ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 26),
                  child: Row(
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
                      const SizedBox(width: 10),
                      Text(
                        "Pending Approval",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width > 1184
                              ? 16
                              : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.only(right: 24),
                        child: Text(
                          widget.pendingRequest ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width > 1184
                                ? 18
                                : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 26),
                  child: Row(
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
                      const SizedBox(width: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3 - 236,
                        child: Text(
                          "Avg. Price to Achieve",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width > 1184
                                ? 16
                                : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.nextTargetPrice ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width > 1184
                              ? 18
                              : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ),
                // const SizedBox(height: 14),
                // const SizedBox(height: 10),
                // Container(
                //   padding: const EdgeInsets.only(left: 20, right: 26),
                //   child: Row(
                //     children: [
                //       Container(
                //         height: 20,
                //         width: 20,
                //         // color: Colors.amber,
                //         decoration: const BoxDecoration(
                //           gradient: LinearGradient(
                //             // Where the linear gradient begins and ends
                //             begin: Alignment.topCenter,
                //             end: Alignment.bottomCenter,
                //             // Add one stop for each color. Stops should increase from 0 to 1
                //             stops: [0.2, 0.9],
                //             colors: [
                //               Color.fromARGB(255, 32, 147, 241),
                //               Colors.red,
                //             ],
                //           ),
                //         ),
                //       ),
                //       const SizedBox(width: 10),
                //       Text(
                //         "Unsold Inventory",
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontSize: MediaQuery.of(context).size.width > 1184
                //               ? 16
                //               : 14,
                //           fontWeight: FontWeight.w600,
                //         ),
                //       ),
                //       const Spacer(),
                //       Text(
                //         widget.unsoldInventry ?? '',
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontSize: MediaQuery.of(context).size.width > 1184
                //               ? 18
                //               : 16,
                //           fontWeight: FontWeight.w600,
                //         ),
                //       )
                //     ],
                //   ),
                // ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                        children: [
                          const Spacer(),
                          Column(
                            children: [
                              Text(
                                "Total Sold (Sq.Ft)",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize:
                                      MediaQuery.of(context).size.width > 1184
                                          ? 16
                                          : 14,
                                ),
                              ),
                              Text(
                                widget.totalSoldSqft ?? '',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width > 1184
                                            ? 18
                                            : 16,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '(Avg. ${formatToIndianStandard(double.parse(widget.totalSoldAvg ?? ''))})',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width > 1184
                                            ? 14
                                            : 12,
                                    fontWeight: FontWeight.w400),
                              )
                            ],
                          ),
                          const Spacer(),
                          Container(
                            height: 44,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)),
                          ),
                          const Spacer(),
                          Column(
                            children: [
                              Text(
                                "Total Unsold (Sq.Ft)",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize:
                                      MediaQuery.of(context).size.width > 1184
                                          ? 16
                                          : 14,
                                ),
                              ),
                              Text(
                                widget.unsoldInventry ?? '',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width > 1184
                                            ? 18
                                            : 16,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '(Avg. ${formatToIndianStandard(double.parse(widget.totalUnsoldAvg ?? ''))})',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width > 1184
                                            ? 14
                                            : 12,
                                    fontWeight: FontWeight.w400),
                              )
                            ],
                          ),
                          const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  child: brokerDetails(
                      brokerDetail: widget.brokerDetail,
                      widthCont: (MediaQuery.of(context).size.width / 3) - 78),
                ),
                // const SizedBox(height: 104),
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
                      var projectId = widget.projectId;
                      var projectName = widget.projectName;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return SalesManagementView(
                                projectId: projectId,
                                towarId: widget.towarId,
                                projectName: projectName,
                                towarName: widget.towarName,
                                navigationFlag: 'Project');
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

  Widget brokerDetails(
      {required double widthCont, required List<BrokerDetail>? brokerDetail}) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 5),
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
                Text(
                  "Broker Details",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize:
                        MediaQuery.of(context).size.width > 1184 ? 16 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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
                        width: (0.31 * widthCont) - 40,
                        //     MediaQuery.of(context).size.width > 1184 ? 110 : 70,
                        child: Text(
                          "Company",
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
                    "Total Sold",
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
                        "Total Brokerage",
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
                        "Total Paid",
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
            for (int p = 0;
                p < (brokerDetail!.length >= 2 ? 2 : brokerDetail.length);
                p++)
              Container(
                padding: EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 0.31 * widthCont,
                      // height: 50,
                      // color: Colors.amber,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Container(
                          //   height: 20,
                          //   width: 20,
                          //   // color: Colors.amber,
                          //   decoration: const BoxDecoration(
                          //     gradient: LinearGradient(
                          //       // Where the linear gradient begins and ends
                          //       begin: Alignment.topCenter,
                          //       end: Alignment.bottomCenter,
                          //       // Add one stop for each color. Stops should increase from 0 to 1
                          //       stops: [0.2, 0.9],
                          //       colors: [
                          //         Color.fromARGB(255, 32, 147, 241),
                          //         Colors.red,
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          Container(
                            // color: Colors.cyan,
                            padding: const EdgeInsets.only(left: 10),
                            width: (0.31 * widthCont) - 40,
                            //     MediaQuery.of(context).size.width > 1184 ? 110 : 70,
                            child: Text(
                              brokerDetail[p].companyName ?? '',
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
                    ),
                    SizedBox(
                      width: 0.34 * widthCont,
                      // height: 50,
                      // color: Colors.red,
                      child: Text(
                        brokerDetail[p].totalSold ?? '',
                        textAlign: TextAlign.center,
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
                      // color: Colors.cyan,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            formatToIndianStandard(double.parse(
                                brokerDetail[p].brokerTotal ?? '')),
                            // brokerDetail[p].brokerTotal ?? '',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width > 1184
                                        ? 16
                                        : 14,
                                height: 0),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: MediaQuery.of(context).size.width > 1184
                                ? 76
                                : 60,
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey))),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatToIndianStandard(
                                double.parse(brokerDetail[p].totPaid ?? '')),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width > 1184
                                        ? 16
                                        : 14,
                                height: 0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            // const SizedBox(height: 8),
            // for (int i = 0; i < widget.woBudgetList!.length; i++)
            //   Padding(
            //     padding: const EdgeInsets.only(bottom: 6),
            //     child: Row(
            //       children: [
            //         Container(
            //           padding: const EdgeInsets.only(left: 18),
            //           width: 0.31 * widthCont,
            //           // height: 50,
            //           // color: Colors.amber,
            //           child: Text(
            //             widget.woBudgetList?[i].budgetWoName ?? '',
            //             // textAlign: TextAlign.center,
            //             style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: MediaQuery.of(context).size.width > 1184
            //                     ? 16
            //                     : 14,
            //                 height: 0),
            //           ),
            //         ),
            //         SizedBox(
            //           width: 0.34 * widthCont,
            //           // height: 50,
            //           // color: Colors.red,
            //           child: Text(
            //             formatToIndianStandard(double.parse(widget
            //                     .woBudgetList?[i].budgetWoEstContractValue ??
            //                 '0')), //'₹ ${widget.woBudgetList?[i].budgetWoEstContractRate}'

            //             textAlign: TextAlign.center,
            //             style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: MediaQuery.of(context).size.width > 1184
            //                     ? 15
            //                     : 13,
            //                 height: 0),
            //           ),
            //         ),
            //         SizedBox(
            //           width: 0.34 * widthCont,
            //           // height: 50,
            //           // color: Colors.cyan,
            //           child: Column(
            //             children: [
            //               Text(
            //                 formatToIndianStandard(double.parse(widget
            //                         .woBudgetList?[i].budgetWoContractAvoided ??
            //                     '0')),
            //                 style: TextStyle(
            //                     color: Colors.white,
            //                     fontSize:
            //                         MediaQuery.of(context).size.width > 1184
            //                             ? 15
            //                             : 13,
            //                     height: 0),
            //               ),
            //               const SizedBox(height: 4),
            //               Container(
            //                 width: MediaQuery.of(context).size.width > 1184
            //                     ? 86
            //                     : 80,
            //                 decoration: const BoxDecoration(
            //                     border: Border(
            //                         bottom: BorderSide(color: Colors.grey))),
            //               ),
            //               const SizedBox(height: 4),
            //               Text(
            //                 formatToIndianStandard(double.parse(widget
            //                         .woBudgetList?[i].budgetWoContractPaid ??
            //                     '0')), //'₹ ${widget.poBudgetList?[i].purchaseAmount}',
            //                 style: TextStyle(
            //                     color: double.parse(widget.woBudgetList?[i]
            //                                     .budgetWoEstContractRate ??
            //                                 '0') <
            //                             double.parse(widget.woBudgetList?[i]
            //                                     .budgetWoContractPaid ??
            //                                 '0')
            //                         //  widget.woBudgetList?[i].overBudgetFlag ==
            //                         //         '1'
            //                         ? Colors.red
            //                         : Colors.white,
            //                     fontSize:
            //                         MediaQuery.of(context).size.width > 1184
            //                             ? 15
            //                             : 13,
            //                     height: 0),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // const SizedBox(height: 6),
          ],
        ));
  }
}
