import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/resSalesLeadDashbord.dart';
import 'package:stallion/ui/custom_loading/custom_loading_dark.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/overview/widget_leads/active_sales_executive.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/overview/widget_leads/budget_col.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/overview/widget_leads/lead_follow_up_col.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/overview/widget_leads/lost_reason_lead.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/overview/widget_leads/potential_client.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/overview/widget_leads/source_col.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/app_url.dart';

class OverviewPageSales extends StatefulWidget {
  const OverviewPageSales(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.towarName})
      : super(key: key);

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;

  @override
  State<OverviewPageSales> createState() => _OverviewPageSalesState();
}

class _OverviewPageSalesState extends State<OverviewPageSales> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  LeadModule? leadModule;
  FollowUp? followUp;
  List<Potential>? potential = [];
  List<Active>? activeSalesExe = [];
  List<Active>? activeChennelPart = [];
  List<GetLeadSource>? getLeadSource = [];
  List<Budget>? budget = [];
  List<ChartData> dataa = [];
  List<Reason>? reason = [];
  DateTime? _selectedToDate;
  DateTime? _selectedFormDate;
  TextEditingController fromDateControler = TextEditingController();
  TextEditingController toDateControler = TextEditingController();

  Future<dynamic?> getAllLeadOverview() async {
    CustomLoadingDark.progressDialog(isLoading: true, context: context);

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "tower_id": widget.towarId!,
      "start_date": fromDateControler.text,
      "end_date": toDateControler.text,
    };
    var response =
        await apiNetworkHandler.post(AppUrl.websalesLeadDashbord, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = resSalesLeadDashbordFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        CustomLoadingDark.progressDialog(isLoading: false, context: context);
        setState(() {
          leadModule = dataModel.response?.leadModule;
          followUp = dataModel.response?.followUp;
          potential = dataModel.response?.potentialClient?.potential;
          activeSalesExe = dataModel.response?.activeSalesExe;
          activeChennelPart = dataModel.response?.activeChennelPart;
          getLeadSource = dataModel.response?.leadSource?.getLeadSource;
          reason = dataModel.response?.reason;
          budget = dataModel.response?.budget;

          double successfulPercentage =
              (double.parse(leadModule?.successLead ?? '0') /
                      double.parse(leadModule?.totalLead ?? '0')) *
                  100;
          double canceledPercentage =
              (double.parse(leadModule?.failLead ?? '0') /
                      double.parse(leadModule?.totalLead ?? '0')) *
                  100;
          // double remainingPercentage =
          //     100 - (successfulPercentage + canceledPercentage);
          double remainingPercentage =
              100 - (successfulPercentage + canceledPercentage);

          dataa = [
            // ChartData('Successful', successfulPercentage),
            // ChartData('Canceled', canceledPercentage),
            // ChartData('Remaining', remainingPercentage),
            ChartData('Total', 100, Colors.yellow), // Total (Always 100%)
            ChartData(
                'Successful', successfulPercentage, Colors.green), // Successful
            ChartData('Canceled', canceledPercentage, Colors.red), // Canceled
          ];
        });
      } else {
        CustomLoadingDark.progressDialog(isLoading: false, context: context);
      }
    } else {
      CustomLoadingDark.progressDialog(isLoading: false, context: context);
    }
    return null;
  }

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
            DateFormat('dd-MM-yyyy').format(_selectedFormDate!);
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
        toDateControler.text =
            DateFormat('dd-MM-yyyy').format(_selectedToDate!);
      });
    }
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            widget.towarName!.isNotEmpty
                ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                : widget.projectName!.toUpperCase(),
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "Lead Overview",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 1000,
              padding: const EdgeInsets.symmetric(horizontal: 80),
              // color: Colors.white,
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // const SizedBox(width: 40),
                  Container(
                    padding: const EdgeInsets.only(right: 12),
                    child: const AppText(
                      title: "Filter",
                      fontSize: 16,
                      titleColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _selectFromDate(context);
                      },
                      child: Container(
                        height: 32,
                        child: TextFormField(
                          // validator: (value) {
                          //   if (value!.isEmpty) {
                          //     return "(From Date Cannot be Ready)";
                          //   }
                          // },
                          enabled: false,
                          readOnly: true,
                          controller: fromDateControler,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13.0),
                          decoration: const InputDecoration(
                              filled: true,
                              // fillColor: Colors.white,

                              disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: Colors.grey,
                              )),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: Colors.red,
                              )),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 0),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              hintText: 'Select From Date',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.0,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'HelveticaNeue',
                              ),
                              suffixIcon: Icon(
                                Icons.calendar_month_outlined,
                                color: Color.fromARGB(255, 116, 116, 116),
                              )),
                        ),
                      ),
                    ),
                  ),
                  // const Spacer(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _selectToDate(context);
                      },
                      child: Container(
                        height: 32,
                        child: TextFormField(
                          enabled: false,
                          readOnly: true,
                          controller: toDateControler,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13.0),
                          decoration: const InputDecoration(
                              filled: true,
                              // fillColor: Colors.white,
                              disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: Colors.grey,
                              )),
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
                                color: Color.fromARGB(255, 116, 116, 116),
                              )),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  OutlinedButton(
                    onPressed: () {
                      getAllLeadOverview();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.green,
                      side: const BorderSide(
                          width: 1.0, color: Colors.transparent),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Border radius 4
                      ),
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
                      // offset = '0';
                      fromDateControler.clear();
                      toDateControler.clear();
                      getAllLeadOverview();

                      // getAllSalesLead();
                      // setState(() {
                      //   _selectedFormDate = null;
                      //   fromDateControler.clear();
                      //   _selectedToDate = null;
                      //   toDateControler.clear();
                      //   offset = '0';
                      // });
                      // fetchGetAllDPRlist();
                    },
                    style: OutlinedButton.styleFrom(
                      // backgroundColor: Colors.white,
                      side: const BorderSide(width: 1.0, color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Border radius 4
                      ),
                    ),
                    child: const Text('Reset',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16.0,
                          color: Colors.white,
                        )),
                  ),
                  // const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LeadFollowUpCol(
                  dataa: dataa,
                  leadModule: leadModule,
                  followUp: followUp,
                ),
                PotentialCleint(
                  potential: potential,
                ),
                ActiveSalesExecutive(
                  activeChennelPart: activeChennelPart,
                  activeSalesExe: activeSalesExe,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SourceCol(getLeadSource: getLeadSource),
                BudgetCol(budget: budget),
                LostReasonLead(reason: reason)
              ],
            ),
            const SizedBox(height: 40)
          ],
        ),
      ),
    );
  }
}
