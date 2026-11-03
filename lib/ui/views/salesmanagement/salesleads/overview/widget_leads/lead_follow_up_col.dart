import 'package:flutter/material.dart';
import 'package:stallion/models/resSalesLeadDashbord.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadFollowUpCol extends StatefulWidget {
  const LeadFollowUpCol(
      {super.key, this.followUp, this.leadModule, required this.dataa});
  final LeadModule? leadModule;
  final FollowUp? followUp;
  final List<ChartData> dataa;

  @override
  State<LeadFollowUpCol> createState() => _LeadFollowUpColState();
}

class _LeadFollowUpColState extends State<LeadFollowUpCol> {
  // List<ChartData> data = [];
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double widthParent = MediaQuery.of(context).size.width * 0.3;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          width: widthParent,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white60),
            borderRadius: BorderRadius.circular(12),
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // Shadow color
                spreadRadius: 0, // Spread radius
                blurRadius: 4, // Blur radius
                offset: const Offset(4, 4), // Changes position of shadow
              ),
            ],
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
                  const SizedBox(width: 10),
                  const Text(
                    "Leads",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    // decoration: BoxDecoration(color: Colors.amber),
                    height: 160,
                    width: 160,
                    child: SfCircularChart(
                        tooltipBehavior: _tooltip,
                        series: <CircularSeries<ChartData, String>>[
                          DoughnutSeries<ChartData, String>(
                            dataSource: widget.dataa,
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y,
                            name: '',
                            pointColorMapper: (ChartData data, _) =>
                                data.color, // Assign colors
                          )
                        ]),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      // InkWell(
                      //   onTap: () async {
                      //     final uri = Uri.parse(
                      //         'https://stallion.build/stallion-new/alpha/backend/sales-lead-dashboard-excell/NTQ=/NTY=?lead=Leads&eadDt=Total&dleadStatus=0');
                      //     if (await canLaunchUrl(uri)) {
                      //       await launchUrl(uri);
                      //     } else {
                      //       throw 'Could not launch';
                      //     }
                      //   },
                      //   child:
                      Row(
                        children: [
                          const SizedBox(
                            width: 100,
                            child: Text(
                              "Total:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            widget.leadModule?.totalLead ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.yellow,
                            ),
                          ),
                        ],
                      ),
                      // ),
                      // InkWell(
                      //   onTap: () async {
                      //     final uri = Uri.parse(
                      //         'https://stallion.build/stallion-new/alpha/backend/sales-lead-dashboard-excell/NTQ=/NTY=?lead=Leads&eadDt=Total&dleadStatus=1');
                      //     if (await canLaunchUrl(uri)) {
                      //       await launchUrl(uri);
                      //     } else {
                      //       throw 'Could not launch';
                      //     }
                      //   },
                      //   child:
                      Row(
                        children: [
                          const SizedBox(
                            width: 100,
                            child: Text(
                              "Successfull:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            widget.leadModule?.successLead ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      // ),
                      // InkWell(
                      //   onTap: () async {
                      //     final uri = Uri.parse(
                      //         'https://stallion.build/stallion-new/alpha/backend/sales-lead-dashboard-excell/NTQ=/NTY=?lead=Leads&eadDt=Total&dleadStatus=2');
                      //     if (await canLaunchUrl(uri)) {
                      //       await launchUrl(uri);
                      //     } else {
                      //       throw 'Could not launch';
                      //     }
                      //   },
                      //   child:
                      Row(
                        children: [
                          const SizedBox(
                            width: 100,
                            child: Text(
                              "Canclelled:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            widget.leadModule?.failLead ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      // ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                width: 190,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Conversion Rate:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${widget.leadModule?.conversionRate}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10)
            ],
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          width: widthParent,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white60),
            borderRadius: BorderRadius.circular(12),
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // Shadow color
                spreadRadius: 0, // Spread radius
                blurRadius: 4, // Blur radius
                offset: const Offset(4, 4), // Changes position of shadow
              ),
            ],
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
                  const SizedBox(width: 10),
                  const Text(
                    "Follow-Up / Interest",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.only(top: 14, bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: (widthParent / 3) - 14,
                      decoration: const BoxDecoration(
                        border: Border(
                            // left: BorderSide(color: Colors.white60),
                            // right: BorderSide(color: Colors.white60),
                            ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Lucurative",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            widget.followUp?.luractive ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: (widthParent / 3) - 14,
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.white60),
                          right: BorderSide(color: Colors.white60),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Enquiry",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            widget.followUp?.enquiry ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: (widthParent / 3) - 14,
                      decoration: const BoxDecoration(
                        border: Border(),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Potential",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            widget.followUp?.potential ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    width: (widthParent / 3) - 18,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(8),
                      // border: Border(
                      // left: BorderSide(color: Colors.white60),
                      // right: BorderSide(color: Colors.white60),
                      // ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Total Follow-Ups",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          widget.followUp?.totalFollow ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    width: (widthParent / 3) - 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(8),

                      // border: Border(
                      //   left: BorderSide(color: Colors.white60),
                      //   right: BorderSide(color: Colors.white60),
                      // ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Missed Follow-Ups",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          widget.followUp?.totalMisslead ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    width: (widthParent / 3) - 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(8),

                      // border: Border(
                      //   left: BorderSide(color: Colors.white60),
                      //   right: BorderSide(color: Colors.white60),
                      // ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Walk-in",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          widget.followUp?.walkIn ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        )
      ],
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);

  final String x;
  final double y;
  final Color color;
}
