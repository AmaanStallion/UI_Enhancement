import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stallion/models/get_overview.dart';
import 'package:stallion/models/projectPurchaseordermodel.dart';
import 'package:stallion/ui/views/accountmanagement/accountmanagement.dart';
import 'package:intl/intl.dart';

import '../PurchaseOrder/purchase_order_form.dart';

class POModuleScreen extends StatefulWidget {
  const POModuleScreen(
      {super.key,
      required this.totalOpenPoData,
      required this.totalIssuedPoData,
      required this.totalDueData,
      required this.totalPaidData,
      required this.projectId,
      required this.towarName,
      required this.towarId,
      required this.projectName,
      required this.lastUpdateData,
      required this.paymentDue,
      required this.totalPaidBalance,
      required this.totalPaidAmount});
  final String? totalOpenPoData;
  final String? totalIssuedPoData;
  final String? totalDueData;
  final String? totalPaidData;
  final List<LastUpdate>? lastUpdateData;
  final String projectId;
  final String towarName;
  final String projectName;
  final String towarId;

  final String? paymentDue;
  final String? totalPaidAmount;
  final String? totalPaidBalance;

  @override
  State<POModuleScreen> createState() => _POModuleScreenState();
}

class _POModuleScreenState extends State<POModuleScreen> {
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
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "PURCHASES",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 34),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
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
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        "Total Open PO",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.totalOpenPoData ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 20),
                    child: const Divider()),
                // SizedBox(height: 16),
                // const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
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
                      const SizedBox(width: 10),
                      const Text(
                        "Total Issued PO",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.totalIssuedPoData ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 20),
                    child: const Divider()),
                // const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
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
                      const SizedBox(width: 10),
                      const Text(
                        "Total Due",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatToIndianStandard(double.parse(widget.paymentDue ??
                            '')), // widget.paymentDue ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // SizedBox(height: 2),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 20),
                    child: const Divider()),
                // const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
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
                      const SizedBox(width: 10),
                      const Text(
                        "Total Paid",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatToIndianStandard(
                            double.parse(widget.totalPaidAmount ?? '')),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height: 2),

                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 20),
                    child: const Divider()),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
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
                      const SizedBox(width: 10),
                      const Text(
                        "Total Balance",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatToIndianStandard(
                            double.parse(widget.totalPaidBalance ?? '0')),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 20),
                    child: const Divider()),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 28),
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
                      "Latest Purchases",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 20),
                //   child: const Text(
                //     "•  Paddy alluminium. (type)\n•  Vaibhav Electronics.\n•  Shree Laxmi Lime Depot Ltd.\n•  Manish Steel Co.",
                //     style: TextStyle(
                //       // fontWeight: FontWeight.w600,
                //       fontSize: 14,
                //       color: Colors.white,
                //     ),
                //     textAlign: TextAlign.start,
                //   ),
                // ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: Column(
                    children: [
                      // if (widget.lastUpdateData != null)
                      widget.lastUpdateData != null &&
                              widget.lastUpdateData?.length != 0
                          ? Column(
                              children: [
                                for (int i = 0;
                                    i < widget.lastUpdateData!.length;
                                    i++)
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: RichText(
                                      text: TextSpan(
                                        text:
                                            "•    ${widget.lastUpdateData?[i].name}",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontFamily: 'HelveticaNeue'),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text:
                                                  " (${widget.lastUpdateData?[i].type})",
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : Container(
                              height: 200,
                              child: const Center(
                                child: Text(
                                  "No Record Found",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                // const SizedBox(height: 76),
                // InkWell(
                //   // onTap: () {
                //   //   var projectId = widget.projectId!;
                //   //                         var projectName = widget.projectName!;
                //   //                         Navigator.push(
                //   //                           context,
                //   //                           MaterialPageRoute(
                //   //                             builder: (_) {
                //   //                               return RccStructure(
                //   //                                 projectId: projectId,
                //   //                                 towarId: widget.towarId!,
                //   //                                 projectName: projectName,
                //   //                                 towarName: widget.towarName!,
                //   //                               );
                //   //                             },
                //   //                           ),
                //   //                         )
                //   // },
                //   child: Center(
                //     child: Container(
                //       decoration: BoxDecoration(
                //           border: Border(bottom: BorderSide(color: Colors.grey))),
                //       child: Text(
                //         "View More",
                //         style: TextStyle(
                //           fontSize: 16,
                //           color: Colors.grey,
                //         ),
                //       ),
                //     ),
                //   ),
                // )
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
                      // RequestPurchaseOrderNavigate();
                      var projectId = widget.projectId!;
                      var projectName = widget.projectName!;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return AccountManagementView(
                                projectId: projectId,
                                towarId: widget.towarId!,
                                projectName: projectName,
                                towarName: widget.towarName!,
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
}
