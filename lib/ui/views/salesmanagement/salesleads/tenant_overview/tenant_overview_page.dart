import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/models/res_tenant_dashboard.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/overview/widget_leads/lead_follow_up_col.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/tenant_overview/additional_area_col.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/tenant_overview/tenant_rent_col.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/tenant_overview/total_tenants_col1.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/tenant_overview/total_tenants_col2.dart';
import 'package:stallion/ui/views/tenantManagement/tenantManagementList.dart';
import 'package:stallion/utils/app_url.dart';

class TenantOverViewPage extends StatefulWidget {
  const TenantOverViewPage(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.towarName});
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;

  @override
  State<TenantOverViewPage> createState() => _TenantOverViewPageState();
}

class _TenantOverViewPageState extends State<TenantOverViewPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TenantTab? tenantTab;
  TenantPie? tenantPie;
  List<TenantRent>? tenantRent = [];
  List<TenantAddintionaArea>? tenantAddintionaArea = [];
  List<ChartData> dataa = [];
  String? tenantModule = '';

  Future<dynamic?> getAllLeadOverview() async {
    CustomLoading.progressDialog(isLoading: true, context: context);

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId!,
    };
    var response = await apiNetworkHandler.post(AppUrl.webTenantDashbord, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = resTenantDashbordFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        CustomLoading.progressDialog(isLoading: false, context: context);
        setState(() {
          tenantModule = dataModel.response?.tenantModule;
          tenantTab = dataModel.response?.tenantTab;
          tenantPie = dataModel.response?.tenantPie;
          tenantRent = dataModel.response?.tenantRent;
          tenantAddintionaArea = dataModel.response?.tenantAddintionaArea;

          double paaaPercentage = (double.parse(tenantPie?.paaa ?? '0') /
                  double.parse(tenantPie?.tototal ?? '0')) *
              100;
          double consentsPercentage =
              (double.parse(tenantPie?.consents ?? '0') /
                      double.parse(tenantPie?.tototal ?? '0')) *
                  100;
          double tototalPercentage =
              100 - (paaaPercentage + consentsPercentage);
          // double remainingPercentage =
          //     100 - (paaaPercentage + consentsPercentage);

          dataa = [
            // ChartData('Successful', successfulPercentage),
            // ChartData('Canceled', canceledPercentage),
            // ChartData('Remaining', remainingPercentage),
            ChartData(
                'PAAA', paaaPercentage, Colors.yellow), // Total (Always 100%)
            ChartData(
                'Consents', consentsPercentage, Colors.green), // Successful
            ChartData('Total', 100, Colors.orange), // Canceled
          ];
        });
      } else {
        CustomLoading.progressDialog(isLoading: false, context: context);
      }
    } else {
      CustomLoading.progressDialog(isLoading: false, context: context);
    }
    return null;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getAllLeadOverview();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return tenantModule == "1"
        ? Container(
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
            child: Column(
              children: [
                // Center(
                //   child: const Text(
                //     "TENANT DASHBOARD",
                //     textAlign: TextAlign.center,
                //     style: TextStyle(
                //       fontSize: 30,
                //       fontWeight: FontWeight.w600,
                //       color: Colors.white,
                //     ),
                //   ),
                // ),
                const SizedBox(height: 20),
                TotalTenantCol1(
                  totalTenant: tenantTab?.totalTenant,
                  recidential: tenantTab?.recidential,
                  nonRecidential: tenantTab?.nonRecidential,
                ),
                const SizedBox(width: 20),
                TotalTenantCol2(
                  dataa: dataa,
                  tenantPie: tenantPie,
                  //  [
                  //   ChartData('PAAA', 100, Colors.orange),
                  //   ChartData('Total', 10, Colors.pink),
                  //   ChartData('Total', 40, Colors.blue),
                  // ],
                ),
                const SizedBox(height: 20),
                TenanatRentCol(
                  tenantRent: tenantRent,
                ),
                const SizedBox(width: 20),
                AdditionalAreaCol(
                  tenantAddintionaArea: tenantAddintionaArea,
                ),

                InkWell(
                  onTap: () {
                    var projectId = widget.projectId!;
                    var projectName = widget.projectName!;
                    // var projectId = widget.projectId!;
                    // var projectName = widget.projectName!;
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) {
                    //       return TenantManagementList(
                    //         projectId: projectId,
                    //         towarId: widget.towarId!,
                    //         projectName: projectName,
                    //         towarName: widget.towarName!,
                    //       );
                    //     },
                    //   ),
                    // );
                    Navigator.of(context).pushNamed(
                      '/tenantManagementScreen',
                      arguments: NotificationArgs(
                        projectId: projectId,
                        projectName: widget.projectName,
                        towarName: widget.towarName,
                        response: NotificationResponseData(
                          towarId: widget.towarId,
                          // assignToId: assignToId ?? '',
                        ),
                      ),
                    );
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

                SizedBox(
                  height: 16,
                )
              ],
            ),
          )
        : SizedBox();
  }
}
