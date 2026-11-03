import 'package:flutter/material.dart';
import 'package:stallion/models/res_tenant_dashboard.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/overview/widget_leads/lead_follow_up_col.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TotalTenantCol2 extends StatefulWidget {
  const TotalTenantCol2({super.key, required this.dataa, this.tenantPie});
  final List<ChartData> dataa;
  final TenantPie? tenantPie;

  @override
  State<TotalTenantCol2> createState() => _TotalTenantCol2State();
}

class _TotalTenantCol2State extends State<TotalTenantCol2> {
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    _tooltip = TooltipBehavior(enable: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double widthParent = (MediaQuery.of(context).size.width / 3) - 50;

    return SizedBox(
      width: widthParent,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
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
                        pointColorMapper: (ChartData data, _) => data.color,
                      )
                    ]),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        "• ",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 100,
                        child: Text(
                          "PAAA:",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        widget.tenantPie?.paaa ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.yellow,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        "• ",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 100,
                        child: Text(
                          "Consents:",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        widget.tenantPie?.consents ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        "• ",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 100,
                        child: Text(
                          "T.O.T:",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        widget.tenantPie?.tototal ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
