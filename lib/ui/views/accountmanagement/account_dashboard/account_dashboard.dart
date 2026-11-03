import 'package:stallion/ui/views/accountmanagement/account_management_preview.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_network.dart';
import 'dart:math' as Math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/getDeveloperRawMaterialDashboard.dart';
import 'package:stallion/models/get_developer_po_dashboard.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:stallion/models/get_project_account_management.dart';
import 'package:stallion/models/get_po_new.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';

class AccountDashboard extends StatefulWidget {
  const AccountDashboard({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    this.navigationFlag,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? navigationFlag;

  @override
  State<AccountDashboard> createState() => _AccountDashboardState();
}

class _AccountDashboardState extends State<AccountDashboard> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = AccountManagementPreviewNetwork();
  bool isLoading = true;

  //new data
  List<Approval>? approvals = [];
  List<Approval>? invoices = [];
  List<Approval>? delivery = [];
  List<Approval>? vendor = [];
  List<Approval>? dueover = [];
  List<Approval>? payments = [];

  List<Approval>? approvalsWo = [];
  List<Approval>? invoicesWo = [];
  List<Approval>? deliveryWo = [];
  List<Approval>? vendorWo = [];
  List<Approval>? dueoverWo = [];
  List<Approval>? paymentsWo = [];
  List<DatumDeveloperRawMaterialDashboard>? datumDeveloperRawMaterialDashboard =
      [];

  Future<void> getDeveloperPoDashboard() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
    };

    var response =
        await apiNetworkHandler.post(AppUrl.getDeveloperPoDashboard, data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getDeveloperPoDashboardFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          approvals = dataModel.response?.data?.approvals ?? [];
          invoices = dataModel.response?.data?.invoices ?? [];
          delivery = dataModel.response?.data?.delivery ?? [];
          vendor = dataModel.response?.data?.vendor ?? [];
          dueover = dataModel.response?.data?.dueover ?? [];
          payments = dataModel.response?.data?.payments ?? [];
        });
      }
    }
  }

  Future<void> getDeveloperWoDashboard() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
    };

    var response =
        await apiNetworkHandler.post(AppUrl.getDeveloperWoDashboard, data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getDeveloperPoDashboardFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          approvalsWo = dataModel.response?.data?.approvals ?? [];
          invoicesWo = dataModel.response?.data?.invoices ?? [];
          deliveryWo = dataModel.response?.data?.delivery ?? [];
          vendorWo = dataModel.response?.data?.vendor ?? [];
          dueoverWo = dataModel.response?.data?.dueover ?? [];
          paymentsWo = dataModel.response?.data?.payments ?? [];
        });
      }
    }
  }

  Future<void> getDeveloperRawMaterialDashboard() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
    };

    var response = await apiNetworkHandler.post(
        AppUrl.getDeveloperRawMaterialDashboard, data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getDeveloperRawMaterialDashboardFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          datumDeveloperRawMaterialDashboard = dataModel.response?.data ?? [];
        });
      }
    }
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      // fetchAccountData(),
      // fetchDueOverdueData(),
      getDeveloperPoDashboard(),
      getDeveloperWoDashboard(),
      getDeveloperRawMaterialDashboard(),
    ]);
    if (mounted) setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // ─── Color Palette ────────────────────────────────────────────────────
  static const Color _cardBg = Color(0xFF1E1E1E);
  static const Color _surfaceDark = Color(0xFF2A2A2A);
  static const Color _green = Color(0xFF4CAF50);
  static const Color _blue = Color(0xFF42A5F5);
  static const Color _orange = Color(0xFFFF9800);
  static const Color _red = Color(0xFFEF5350);
  static const Color _yellow = Color(0xFFFFEB3B);
  static const Color _purple = Color(0xFF9C27B0);
  static const Color _teal = Color(0xFF26A69A);
  static const Color _pink = Color(0xFFEC407A);
  static const Color _lime = Color(0xFFCDDC39);

  String isTabSelected = 'PO';

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
          'ACCOUNT DASHBOARD${widget.projectName != null ? ' - ${widget.projectName!.toUpperCase()}' : ''}',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: isLoading
          ? Center(
              child: SizedBox(
                height: 64,
                child: OverflowBox(
                  minHeight: 100,
                  maxHeight: 100,
                  child: Lottie.asset(
                    'assets/animation/running2.json',
                    repeat: true,
                  ),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        decoration: BoxDecoration(
                          color: _surfaceDark,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isTabSelected = 'PO';
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isTabSelected == 'PO'
                                      ? _purple
                                      : _surfaceDark,
                                  borderRadius: BorderRadius.circular(100),
                                  // border: Border.all(color: Colors.white12),
                                ),
                                child: Text(
                                  'Purchase Order',
                                  style: TextStyle(
                                      color: Colors.white,
                                      letterSpacing: 1,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isTabSelected = 'Work Order';
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isTabSelected == 'Work Order'
                                      ? _purple
                                      : _surfaceDark,
                                  borderRadius: BorderRadius.circular(100),
                                  // border: Border.all(color: Colors.white12),
                                ),
                                child: Text(
                                  'Work Order',
                                  style: TextStyle(
                                      color: Colors.white,
                                      letterSpacing: 1,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isTabSelected = 'Raw Material';
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isTabSelected == 'Raw Material'
                                      ? _purple
                                      : _surfaceDark,
                                  borderRadius: BorderRadius.circular(100),
                                  // border: Border.all(color: Colors.white12),
                                ),
                                child: Text(
                                  'Raw Material',
                                  style: TextStyle(
                                      color: Colors.white,
                                      letterSpacing: 1,
                                      fontSize: 15),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // ─── Row 1: PO Status | Supply/WO Status | Payment Due ─────────

                  Expanded(
                    child: SingleChildScrollView(
                        child: Column(children: [
                      if (isTabSelected == 'PO') ...[
                        _buildResponsiveRow([
                          _buildPoStatusCard(),
                          _buildWoStatusCard(),
                          _buildPaymentDueCard(),
                        ]),
                        const SizedBox(height: 20),
                        // ─── Row 2: Invoice Summary | Vendor Orders | Payment Status ───
                        _buildResponsiveRow([
                          _buildInvoiceSummaryCard(),
                          _buildVendorOrdersCard(),
                          _buildPaymentStatusCard(),
                        ]),
                      ],
                      if (isTabSelected == 'Work Order') ...[
                        _buildResponsiveRow([
                          _buildwoStatusCard(),
                          _buildWoCertificateCard(),
                          _buildPaymentDueWoCard(),
                        ]),
                        const SizedBox(height: 20),
                        // ─── Row 2: Invoice Summary | Vendor Orders | Payment Status ───
                        _buildResponsiveRow([
                          _buildInvoiceSummaryWoCard(),
                          _buildVendorOrdersWoCard(),
                          _buildPaymentStatusWoCard(),
                        ]),
                      ],
                      // if (isTabSelected == 'Raw Material') ...[
                      //   ...datumDeveloperRawMaterialDashboard!
                      //       .map((e) => _buildRawMaterialCard(e))
                      //       .toList(),
                      // ]
                      // if (isTabSelected == 'Raw Material') ...[
                      //   ...chunkList(datumDeveloperRawMaterialDashboard ?? [], 3)
                      //       .map((chunk) => Padding(
                      //             padding: const EdgeInsets.only(bottom: 20),
                      //             child: _buildResponsiveRow(
                      //               chunk
                      //                   .map((e) => _buildRawMaterialCard(e))
                      //                   .toList(),
                      //             ),
                      //           ))
                      //       .toList(),
                      // ]
                      if (isTabSelected == 'Raw Material') ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Wrap(
                            spacing: 40,
                            runSpacing: 20,
                            children: datumDeveloperRawMaterialDashboard!
                                .map((e) => SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                              3 -
                                          100,
                                      child: _buildRawMaterialCard(e),
                                    ))
                                .toList(),
                          ),
                        ),
                      ]
                    ])),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRawMaterialCard(DatumDeveloperRawMaterialDashboard item) {
    final List<RawMaterialChartData> chartData = (item.details ?? []).map((e) {
      return RawMaterialChartData(
        e.monthName ?? '',
        double.tryParse(e.stockIn ?? '0') ?? 0,
        double.tryParse(e.stockOut ?? '0') ?? 0,
      );
    }).toList();

    return Container(
      // width: MediaQuery.of(context).size.width / 3 - 40,
      // 520,
      height: 402,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
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
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Container(
              width: double.infinity,
              child: Text(
                item.gradeName?.toUpperCase() ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            /// Chart
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                backgroundColor: Colors.transparent,
                legend: Legend(
                  isVisible: true,
                  textStyle: const TextStyle(color: Colors.white),
                ),
                primaryXAxis: const CategoryAxis(
                  labelStyle: TextStyle(color: Colors.white70),
                  axisLine: AxisLine(color: Colors.white24),
                  majorGridLines: MajorGridLines(width: 0),
                ),
                primaryYAxis: const NumericAxis(
                  labelStyle: TextStyle(color: Colors.white70),
                  axisLine: AxisLine(color: Colors.white24),
                  majorGridLines: MajorGridLines(width: 0),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  /// IN (Green)
                  ColumnSeries<RawMaterialChartData, String>(
                    name: 'In',
                    dataSource: chartData,
                    xValueMapper: (data, _) => data.month,
                    yValueMapper: (data, _) => data.inQty,
                    color: Colors.green,
                    width: 0.35,
                    spacing: 0.2,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(color: Colors.white),
                    ),
                  ),

                  /// OUT (Red)
                  ColumnSeries<RawMaterialChartData, String>(
                    name: 'Out',
                    dataSource: chartData,
                    xValueMapper: (data, _) => data.month,
                    yValueMapper: (data, _) => data.outQty,
                    color: Colors.red,
                    width: 0.35,
                    spacing: 0.2,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveRow(List<Widget> cards) {
    // if (constraints.maxWidth > 1100) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cards
          .map((card) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: card,
                ),
              ))
          .toList(),
    );
    // } else if (constraints.maxWidth > 700) {
    //   return Column(
    //     children: [
    //       Row(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Expanded(
    //               child: Padding(
    //                   padding: const EdgeInsets.symmetric(horizontal: 8),
    //                   child: cards[0])),
    //           Expanded(
    //               child: Padding(
    //                   padding: const EdgeInsets.symmetric(horizontal: 8),
    //                   child: cards[1])),
    //         ],
    //       ),
    //       const SizedBox(height: 20),
    //       Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 8),
    //         child: cards[2],
    //       ),
    //     ],
    //   );
    // } else {
    //   return Column(
    //     children: cards
    //         .map((card) => Padding(
    //               padding: const EdgeInsets.only(bottom: 16),
    //               child: card,
    //             ))
    //         .toList(),
    //   );
    // }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // CARD 1 — PO Status (Pie Chart)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildPoStatusCard() {
    final double pending = double.tryParse(approvals?[0].count ?? '0') ?? 0;
    final double verified = double.tryParse(approvals?[1].count ?? '0') ?? 0;
    final double assigned = double.tryParse(approvals?[2].count ?? '0') ?? 0;
    final double issued = double.tryParse(approvals?[3].count ?? '0') ?? 0;

    final data = <_ChartItem>[
      _ChartItem('Pending', pending, _orange),
      _ChartItem('Verified', verified, _blue),
      _ChartItem('Assigned', assigned, _yellow),
      _ChartItem('Issued', issued, _green),
    ];

    return _DashboardCard(
      title: 'Approvals',
      chart: SizedBox(
        height: 220,
        child: SfCircularChart(
          margin: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CircularSeries>[
            PieSeries<_ChartItem, String>(
              strokeWidth: 0.5,
              strokeColor: Colors.black,
              dataSource: data,
              xValueMapper: (item, _) => item.label,
              yValueMapper: (item, _) => item.value,
              pointColorMapper: (item, _) => item.color,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside,
                textStyle: TextStyle(color: Colors.white, fontSize: 11),
                connectorLineSettings:
                    ConnectorLineSettings(type: ConnectorType.curve),
              ),
              dataLabelMapper: (item, _) =>
                  '${item.value.toStringAsFixed(1)}\n${item.label}',
              explode: false,
              radius: '85%',
            )
          ],
        ),
      ),
      legendItems: data,
      countLabel: 'Count',
    );
  }

  Widget _buildwoStatusCard() {
    final double pending = double.tryParse(approvalsWo?[0].count ?? '0') ?? 0;
    final double verified = double.tryParse(approvalsWo?[1].count ?? '0') ?? 0;
    final double assigned = double.tryParse(approvalsWo?[2].count ?? '0') ?? 0;
    // final double issued = double.tryParse(approvalsWo?[3].count ?? '0') ?? 0;

    final data = <_ChartItem>[
      _ChartItem('Pending', pending, _orange),
      _ChartItem('Verified', verified, _blue),
      _ChartItem('Assigned', assigned, _yellow),
      // _ChartItem('Issued', issued, _green),
    ];

    return _DashboardCard(
      title: 'Approvals',
      chart: SizedBox(
        height: 220,
        child: SfCircularChart(
          margin: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CircularSeries>[
            PieSeries<_ChartItem, String>(
              strokeWidth: 0.5,
              strokeColor: Colors.black,
              dataSource: data,
              xValueMapper: (item, _) => item.label,
              yValueMapper: (item, _) => item.value,
              pointColorMapper: (item, _) => item.color,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside,
                textStyle: TextStyle(color: Colors.white, fontSize: 11),
                connectorLineSettings:
                    ConnectorLineSettings(type: ConnectorType.curve),
              ),
              dataLabelMapper: (item, _) =>
                  '${item.value.toStringAsFixed(1)}\n${item.label}',
              explode: false,
              radius: '85%',
            )
          ],
        ),
      ),
      legendItems: data,
      countLabel: 'Count',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // CARD 2 — WO / Supply Status (Bar Chart)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildWoStatusCard() {
    final double quoteReceived =
        double.tryParse(delivery?[0].count ?? '0') ?? 0;
    final double pendingDelivery =
        double.tryParse(delivery?[1].count ?? '0') ?? 0;
    final double partiallyDelivered =
        double.tryParse(delivery?[2].count ?? '0') ?? 0;
    final double fullyDelivered =
        double.tryParse(delivery?[3].count ?? '0') ?? 0;

    final data = <_ChartItem>[
      _ChartItem('Quote Received', quoteReceived, _blue),
      _ChartItem('Pending Delivery', pendingDelivery, _orange),
      _ChartItem('Partially Delivered', partiallyDelivered, _green),
      _ChartItem('Delivered', fullyDelivered, _purple),
    ];

    return _DashboardCard(
      title: 'Delivery',
      chart: SizedBox(
        height: 220,
        child: SfCartesianChart(
          backgroundColor: Colors.transparent,
          plotAreaBorderWidth: 0,
          primaryXAxis: const CategoryAxis(
            labelStyle: TextStyle(color: Colors.white70, fontSize: 11),
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(color: Colors.white24),
          ),
          primaryYAxis: const NumericAxis(
            labelStyle: TextStyle(color: Colors.white70, fontSize: 11),
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(color: Colors.white24),
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CartesianSeries>[
            ColumnSeries<_ChartItem, String>(
              dataSource: data,
              xValueMapper: (item, _) => item.label,
              yValueMapper: (item, _) => item.value,
              pointColorMapper: (item, _) => item.color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(color: Colors.white, fontSize: 11),
              ),
              width: 0.5,
            )
          ],
        ),
      ),
      legendItems: data,
      countLabel: 'Count',
    );
  }

  Widget _buildWoCertificateCard() {
    final double quoteReceived =
        double.tryParse(deliveryWo?[0].count ?? '0') ?? 0;
    final double pendingDelivery =
        double.tryParse(deliveryWo?[1].count ?? '0') ?? 0;
    final double certified = double.tryParse(deliveryWo?[2].count ?? '0') ?? 0;
    // final double fullyDelivered =
    //     double.tryParse(deliveryWo?[3].count ?? '0') ?? 0;

    final data = <_ChartItem>[
      _ChartItem("Tendor Received", quoteReceived, _blue),
      _ChartItem("Pending Certification", pendingDelivery, _orange),
      _ChartItem("Certified", certified, _green),
      // _ChartItem('Delivered', fullyDelivered, _purple),
    ];

    return _DashboardCard(
      title: 'Certification',
      chart: SizedBox(
        height: 220,
        child: SfCartesianChart(
          backgroundColor: Colors.transparent,
          plotAreaBorderWidth: 0,
          primaryXAxis: const CategoryAxis(
            labelStyle: TextStyle(color: Colors.white70, fontSize: 11),
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(color: Colors.white24),
          ),
          primaryYAxis: const NumericAxis(
            labelStyle: TextStyle(color: Colors.white70, fontSize: 11),
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(color: Colors.white24),
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CartesianSeries>[
            ColumnSeries<_ChartItem, String>(
              dataSource: data,
              xValueMapper: (item, _) => item.label,
              yValueMapper: (item, _) => item.value,
              pointColorMapper: (item, _) => item.color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(color: Colors.white, fontSize: 11),
              ),
              width: 0.5,
            )
          ],
        ),
      ),
      legendItems: data,
      countLabel: 'Count',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // CARD 3 — Payment Due Overview (Doughnut)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildPaymentDueCard() {
    final double totalDue = double.tryParse(dueover?[0].count ?? '0') ?? 0;
    final double overdue = double.tryParse(dueover?[1].count ?? '0') ?? 0;
    final double balance = double.tryParse(dueover?[2].count ?? '0') ?? 0;
    // final double balance = (total - overdue).clamp(0, double.infinity);

    final data = <_ChartItem>[
      _ChartItem('Total Due', totalDue, _blue),
      _ChartItem('Overdue', overdue, _red),
      _ChartItem('Balance', balance, _orange),
    ];

    return _DashboardCard(
      title: 'Due And Overdue',
      chart: SizedBox(
        height: 220,
        child: SfCircularChart(
          margin: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CircularSeries>[
            DoughnutSeries<_ChartItem, String>(
              dataSource: data,
              xValueMapper: (item, _) => item.label,
              yValueMapper: (item, _) => item.value,
              pointColorMapper: (item, _) => item.color,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside,
                textStyle: TextStyle(color: Colors.white, fontSize: 10),
                connectorLineSettings:
                    ConnectorLineSettings(type: ConnectorType.curve),
              ),
              dataLabelMapper: (item, _) =>
                  '${_formatAmount(item.value)}\n${item.label}',
              innerRadius: '55%',
              radius: '85%',
              strokeColor: _cardBg,
              strokeWidth: 3,
            )
          ],
        ),
      ),
      legendItems: data,
      countLabel: 'Amount (₹)',
      isAmountFormat: true,
    );
  }

  Widget _buildPaymentDueWoCard() {
    final double totalDue = double.tryParse(dueoverWo?[0].count ?? '0') ?? 0;
    final double overdue = double.tryParse(dueoverWo?[1].count ?? '0') ?? 0;
    final double balance = double.tryParse(dueoverWo?[2].count ?? '0') ?? 0;
    // final double balance = (total - overdue).clamp(0, double.infinity);

    final data = <_ChartItem>[
      _ChartItem('Total Due', totalDue, _blue),
      _ChartItem('Overdue', overdue, _red),
      _ChartItem('Balance', balance, _orange),
    ];

    return _DashboardCard(
      title: 'Due And Overdue',
      chart: SizedBox(
        height: 220,
        child: SfCircularChart(
          margin: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CircularSeries>[
            DoughnutSeries<_ChartItem, String>(
              dataSource: data,
              xValueMapper: (item, _) => item.label,
              yValueMapper: (item, _) => item.value,
              pointColorMapper: (item, _) => item.color,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside,
                textStyle: TextStyle(color: Colors.white, fontSize: 10),
                connectorLineSettings:
                    ConnectorLineSettings(type: ConnectorType.curve),
              ),
              dataLabelMapper: (item, _) =>
                  '${_formatAmount(item.value)}\n${item.label}',
              innerRadius: '55%',
              radius: '85%',
              strokeColor: _cardBg,
              strokeWidth: 3,
            )
          ],
        ),
      ),
      legendItems: data,
      countLabel: 'Amount (₹)',
      isAmountFormat: true,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // CARD 4 — Invoice Summary (Horizontal Bar)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildInvoiceSummaryCard() {
    // Aggregate invoice data from vendor lists
    int totalPaid = double.parse(invoices?[0].count ?? '0').toInt();
    int totalPending = double.parse(invoices?[1].count ?? '0').toInt();
    int totalInv = double.parse(invoices?[2].count ?? '0').toInt();

    final data = <_ChartItem>[
      _ChartItem('Paid Invoices', totalPaid.toDouble(), _lime),
      _ChartItem('Pending Invoices', totalPending.toDouble(), _orange),
      _ChartItem('Total Invoices', totalInv.toDouble(), _blue),
    ];

    return _DashboardCard(
      title: 'Invoices',
      chart: SizedBox(
        height: 220,
        child: SfCartesianChart(
          backgroundColor: Colors.transparent,
          plotAreaBorderWidth: 0,
          primaryXAxis: const CategoryAxis(
            labelStyle: TextStyle(color: Colors.white70, fontSize: 10),
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(color: Colors.white24),
          ),
          primaryYAxis: const NumericAxis(
            labelStyle: TextStyle(color: Colors.white70, fontSize: 10),
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(color: Colors.white24),
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CartesianSeries>[
            BarSeries<_ChartItem, String>(
              dataSource: data,
              xValueMapper: (item, _) => item.label,
              yValueMapper: (item, _) => item.value,
              pointColorMapper: (item, _) => item.color,
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(4)),
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(color: Colors.white, fontSize: 11),
              ),
              width: 0.5,
              spacing: 0.2,
            )
          ],
        ),
      ),
      legendItems: data,
      countLabel: 'Count',
    );
  }

  Widget _buildInvoiceSummaryWoCard() {
    // Aggregate invoice data from vendor lists
    int totalPaid = double.parse(invoicesWo?[0].count ?? '0').toInt();
    int totalPending = double.parse(invoicesWo?[1].count ?? '0').toInt();
    int totalInv = double.parse(invoicesWo?[2].count ?? '0').toInt();

    final data = <_ChartItem>[
      _ChartItem('Paid Invoices', totalPaid.toDouble(), _lime),
      _ChartItem('Pending Invoices', totalPending.toDouble(), _orange),
      _ChartItem('Total Invoices', totalInv.toDouble(), _blue),
    ];

    return _DashboardCard(
      title: 'Invoices',
      chart: SizedBox(
        height: 220,
        child: SfCartesianChart(
          backgroundColor: Colors.transparent,
          plotAreaBorderWidth: 0,
          primaryXAxis: const CategoryAxis(
            labelStyle: TextStyle(color: Colors.white70, fontSize: 10),
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(color: Colors.white24),
          ),
          primaryYAxis: const NumericAxis(
            labelStyle: TextStyle(color: Colors.white70, fontSize: 10),
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(color: Colors.white24),
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CartesianSeries>[
            BarSeries<_ChartItem, String>(
              dataSource: data,
              xValueMapper: (item, _) => item.label,
              yValueMapper: (item, _) => item.value,
              pointColorMapper: (item, _) => item.color,
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(4)),
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(color: Colors.white, fontSize: 11),
              ),
              width: 0.5,
              spacing: 0.2,
            )
          ],
        ),
      ),
      legendItems: data,
      countLabel: 'Count',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // CARD 5 — Vendor Orders (Horizontal Bar)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildVendorOrdersCard() {
    final colors = [_blue, _teal, _green, _pink, _orange, _purple, _yellow];

    final data = <_ChartItem>[
      // for (var v = 0; v < (vendor?.length ?? 0); v++)
      for (var v = 0; v < Math.min(vendor?.length ?? 0, 5); v++)
        _ChartItem(vendor?[v].status ?? '',
            double.parse(vendor?[v].count ?? '0'), colors[v]),
    ];
    final dataMap = <_ChartItem>[
      // for (var v = 0; v < (vendor?.length ?? 0); v++)
      for (var v = 0; v < Math.min(vendor?.length ?? 0, 5); v++)
        _ChartItem(vendor?[v].status ?? '',
            double.parse(vendor?[v].count ?? '0'), colors[v]),
    ].reversed.toList();

    return _DashboardCard(
      title: 'Active Vendors',
      chart: SizedBox(
        height: 220,
        child: SfCartesianChart(
          backgroundColor: Colors.transparent,
          plotAreaBorderWidth: 0,
          primaryXAxis: const CategoryAxis(
            labelStyle: TextStyle(color: Colors.white70, fontSize: 9),
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(color: Colors.white24),
            maximumLabelWidth: 80,
          ),
          primaryYAxis: const NumericAxis(
            labelStyle: TextStyle(color: Colors.white70, fontSize: 10),
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(color: Colors.white24),
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CartesianSeries>[
            BarSeries<_ChartItem, String>(
              dataSource: dataMap,
              xValueMapper: (item, _) => item.label,
              yValueMapper: (item, _) => item.value,
              pointColorMapper: (item, _) => item.color,
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(4)),
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(color: Colors.white, fontSize: 11),
              ),
              width: 0.5,
              spacing: 0.2,
            )
          ],
        ),
      ),
      legendItems: data,
      countLabel: 'Orders',
    );
  }

  Widget _buildVendorOrdersWoCard() {
    final colors = [_blue, _teal, _green, _pink, _orange, _purple, _yellow];

    final data = <_ChartItem>[
      for (var v = 0; v < (vendorWo?.length ?? 0); v++)
        _ChartItem(vendorWo?[v].status ?? '',
            double.parse(vendorWo?[v].count ?? '0'), colors[v]),
    ];

    return _DashboardCard(
      title: 'Active Vendors',
      chart: SizedBox(
        height: 220,
        child: SfCartesianChart(
          backgroundColor: Colors.transparent,
          plotAreaBorderWidth: 0,
          primaryXAxis: const CategoryAxis(
            labelStyle: TextStyle(color: Colors.white70, fontSize: 9),
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(color: Colors.white24),
            maximumLabelWidth: 80,
          ),
          primaryYAxis: const NumericAxis(
            labelStyle: TextStyle(color: Colors.white70, fontSize: 10),
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(color: Colors.white24),
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CartesianSeries>[
            BarSeries<_ChartItem, String>(
              dataSource: data,
              xValueMapper: (item, _) => item.label,
              yValueMapper: (item, _) => item.value,
              pointColorMapper: (item, _) => item.color,
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(4)),
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(color: Colors.white, fontSize: 11),
              ),
              width: 0.5,
              spacing: 0.2,
            )
          ],
        ),
      ),
      legendItems: data,
      countLabel: 'Orders',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // CARD 6 — Payment Status (Vertical Bar)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildPaymentStatusCard() {
    final double requested = double.tryParse(payments?[0].count ?? '0') ?? 0;
    final double approved = double.tryParse(payments?[1].count ?? '0') ?? 0;
    // Hold and Rejected derived if possible
    final double hold = double.tryParse(payments?[2].count ?? '0') ?? 0;
    final double rejected = double.tryParse(payments?[3].count ?? '0') ?? 0;

    final data = <_ChartItem>[
      _ChartItem('Requested', requested, _blue),
      _ChartItem('Approved', approved, _green),
      _ChartItem('Hold', hold, _yellow),
      _ChartItem('Rejected', rejected, _red),
    ];

    return _DashboardCard(
      title: 'Payments',
      chart: SizedBox(
        height: 220,
        child: SfCartesianChart(
          backgroundColor: Colors.transparent,
          plotAreaBorderWidth: 0,
          primaryXAxis: const CategoryAxis(
            labelStyle: TextStyle(color: Colors.white70, fontSize: 11),
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(color: Colors.white24),
          ),
          primaryYAxis: const NumericAxis(
            labelStyle: TextStyle(color: Colors.white70, fontSize: 11),
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(color: Colors.white24),
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CartesianSeries>[
            ColumnSeries<_ChartItem, String>(
              dataSource: data,
              xValueMapper: (item, _) => item.label,
              yValueMapper: (item, _) => item.value,
              pointColorMapper: (item, _) => item.color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(color: Colors.white, fontSize: 11),
              ),
              width: 0.5,
            )
          ],
        ),
      ),
      legendItems: data,
      countLabel: 'Count',
    );
  }

  Widget _buildPaymentStatusWoCard() {
    final double requested = double.tryParse(paymentsWo?[0].count ?? '0') ?? 0;
    final double approved = double.tryParse(paymentsWo?[1].count ?? '0') ?? 0;
    // Hold and Rejected derived if possible
    final double hold = double.tryParse(paymentsWo?[2].count ?? '0') ?? 0;
    final double rejected = double.tryParse(paymentsWo?[3].count ?? '0') ?? 0;

    final data = <_ChartItem>[
      _ChartItem('Requested', requested, _blue),
      _ChartItem('Approved', approved, _green),
      _ChartItem('Hold', hold, _yellow),
      _ChartItem('Rejected', rejected, _red),
    ];

    return _DashboardCard(
      title: 'Payments',
      chart: SizedBox(
        height: 220,
        child: SfCartesianChart(
          backgroundColor: Colors.transparent,
          plotAreaBorderWidth: 0,
          primaryXAxis: const CategoryAxis(
            labelStyle: TextStyle(color: Colors.white70, fontSize: 11),
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(color: Colors.white24),
          ),
          primaryYAxis: const NumericAxis(
            labelStyle: TextStyle(color: Colors.white70, fontSize: 11),
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(color: Colors.white24),
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CartesianSeries>[
            ColumnSeries<_ChartItem, String>(
              dataSource: data,
              xValueMapper: (item, _) => item.label,
              yValueMapper: (item, _) => item.value,
              pointColorMapper: (item, _) => item.color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(color: Colors.white, fontSize: 11),
              ),
              width: 0.5,
            )
          ],
        ),
      ),
      legendItems: data,
      countLabel: 'Count',
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────
  static String _formatAmount(double val) {
    if (val >= 100000) {
      return '${(val / 100000).toStringAsFixed(0)}L';
    } else if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(0)}K';
    }
    return val.toStringAsFixed(0);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Reusable Dashboard Card Widget
// ═══════════════════════════════════════════════════════════════════════════
class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.chart,
    required this.legendItems,
    required this.countLabel,
    this.isAmountFormat = false,
  });

  final String title;
  final Widget chart;
  final List<_ChartItem> legendItems;
  final String countLabel;
  final bool isAmountFormat;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 468,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),

        color: Colors.black,
        // borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: Colors.white12),
        // boxShadow: const [
        //   BoxShadow(
        //     color: Color(0x44000000),
        //     offset: Offset(4, 4),
        //     blurRadius: 10,
        //     spreadRadius: 2,
        //   ),
        // ],
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
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 14),
          Text(title.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          // ─── Chart Area ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
            child: chart,
          ),
          const SizedBox(height: 8),
          // ─── Legend Table ────────────────────────────────────────
          Container(
            height: 212,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          title.contains('Vendor') ? 'Vendor' : _headerLabel,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          countLabel,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Colors.white12),
                // Rows
                ...legendItems.map(
                  (item) => Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            isAmountFormat
                                ? _formatCurrency(item.value)
                                : item.value.toStringAsFixed(0),
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _headerLabel {
    if (title.contains('Invoice')) return 'Invoice Type';
    if (title.contains('Payment Status')) return 'Payment Status';
    if (title.contains('Payment Due')) return 'Category';
    return 'Status';
  }

  static String _formatCurrency(double val) {
    return currencyFormatWothoutSymbol.format(val);
    // if (val >= 10000000) {
    //   return '${(val / 10000000).toStringAsFixed(1)} Cr';
    // } else if (val >= 100000) {
    //   return '${(val / 100000).toStringAsFixed(1)} L';
    // } else if (val >= 1000) {
    //   return '${(val / 1000).toStringAsFixed(1)} K';
    // }
    // return val.toStringAsFixed(0);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Data model for chart items
// ═══════════════════════════════════════════════════════════════════════════
class _ChartItem {
  _ChartItem(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

class RawMaterialChartData {
  final String month;
  final double inQty;
  final double outQty;

  RawMaterialChartData(this.month, this.inQty, this.outQty);
}
