import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/models/rcc_dpr_api_models.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/dpr/add_dpr_screen.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/views/rccstructure/rcc_skeleton_loader.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:url_launcher/url_launcher.dart';

class DailyProgressReport extends StatefulWidget {
  const DailyProgressReport({super.key});

  @override
  State<DailyProgressReport> createState() => _DailyProgressReportState();
}

class _DailyProgressReportState extends State<DailyProgressReport> {
  late NotificationArgs args;
  final NetworkHandler apiNetworkHandler = NetworkHandler();
  bool _isInit = true;
  bool isLoading = true;

  DateTime? _selectedFromDate;
  final TextEditingController fromDateControler = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? _selectedToDate;
  final TextEditingController toDateControler = TextEditingController();
  DateTime? _appliedFromDate;
  DateTime? _appliedToDate;

  int _currentPage = 1;
  bool _hasNextPage = false;
  List<DprItem> _dprList = [];

  // Computed Metrics
  int _activeContractorsCount = 0;
  int _avgSkilledCount = 0;
  int _avgUnskilledCount = 0;

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      args = ModalRoute.of(context)!.settings.arguments as NotificationArgs;
      fetchGetAllDPRlist(isInitial: true);
      _isInit = false;
    }
  }

  String _formatDateForApi(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  }

  DateTime? _parseDprDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;
    final str = dateStr.trim();
    final iso = DateTime.tryParse(str);
    if (iso != null) {
      return DateTime(iso.year, iso.month, iso.day);
    }
    try {
      if (str.contains('/')) {
        final parts = str.split('/');
        if (parts.length == 3) {
          final d = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          final y = int.tryParse(parts[2]);
          if (d != null && m != null && y != null) {
            return DateTime(y, m, d);
          }
        }
      } else if (str.contains('-')) {
        final parts = str.split('-');
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            final y = int.tryParse(parts[0]);
            final m = int.tryParse(parts[1]);
            final d = int.tryParse(parts[2]);
            if (d != null && m != null && y != null) {
              return DateTime(y, m, d);
            }
          } else {
            final d = int.tryParse(parts[0]);
            final m = int.tryParse(parts[1]);
            final y = int.tryParse(parts[2]);
            if (d != null && m != null && y != null) {
              return DateTime(y, m, d);
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  bool _isItemInDateRange(DprItem item) {
    if (_appliedFromDate == null && _appliedToDate == null) {
      return true;
    }
    final itemDate = _parseDprDate(item.dprDate);
    if (itemDate == null) {
      return false;
    }
    final normItem = DateTime(itemDate.year, itemDate.month, itemDate.day);
    if (_appliedFromDate != null) {
      final from = DateTime(_appliedFromDate!.year, _appliedFromDate!.month, _appliedFromDate!.day);
      if (normItem.isBefore(from)) return false;
    }
    if (_appliedToDate != null) {
      final to = DateTime(_appliedToDate!.year, _appliedToDate!.month, _appliedToDate!.day);
      if (normItem.isAfter(to)) return false;
    }
    return true;
  }

  List<DprItem> get _filteredDprList {
    if (_appliedFromDate == null && _appliedToDate == null) {
      return _dprList;
    }
    return _dprList.where(_isItemInDateRange).toList();
  }

  void _calculateMetrics(List<DprItem> dprs) {
    if (dprs.isEmpty) {
      _activeContractorsCount = 0;
      _avgSkilledCount = 0;
      _avgUnskilledCount = 0;
      return;
    }

    final Set<String> uniqueContractorIds = {};
    int totalSkilled = 0;
    int totalUnskilled = 0;

    for (var dpr in dprs) {
      for (var c in dpr.contractors) {
        if (c.contractorId.isNotEmpty) {
          uniqueContractorIds.add(c.contractorId);
        }
      }

      for (var emp in dpr.employeeDetails) {
        final typeName = emp.dprType?.name.toLowerCase() ?? '';
        if (typeName.contains('skill') && !typeName.contains('unskill')) {
          totalSkilled += emp.employeeCount;
        } else if (typeName.contains('unskill')) {
          totalUnskilled += emp.employeeCount;
        }
      }
    }

    _activeContractorsCount = uniqueContractorIds.isNotEmpty
        ? uniqueContractorIds.length
        : dprs.fold<int>(0, (sum, item) => sum + item.contractors.length);

    _avgSkilledCount = (totalSkilled / dprs.length).round();
    _avgUnskilledCount = (totalUnskilled / dprs.length).round();
  }

  Future<void> fetchGetAllDPRlist({bool isInitial = false}) async {
    if (isInitial) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final String slabId = args.response?.slabId ?? '';
      final String? fromDate = _appliedFromDate != null ? _formatDateForApi(_appliedFromDate!) : null;
      final String? toDate = _appliedToDate != null ? _formatDateForApi(_appliedToDate!) : null;

      final url = AppUrl.getDprsForSlab(
        slabId,
        page: _currentPage,
        limit: 20,
        fromDate: fromDate,
        toDate: toDate,
      );

      final response = await apiNetworkHandler.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        final dprResponse = DprListResponse.fromJson(decoded);

        if (dprResponse.success && dprResponse.data != null) {
          setState(() {
            if (_currentPage == 1) {
              _dprList = dprResponse.data!.dprs;
            } else {
              _dprList.addAll(dprResponse.data!.dprs);
            }

            _hasNextPage = dprResponse.data!.pagination?.hasNextPage ?? false;
            _calculateMetrics(_dprList);
          });
        }
      }
    } catch (e) {
      if (kDebugMode) print("Fetch DPR List Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _onRefresh() async {
    _currentPage = 1;
    await fetchGetAllDPRlist();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    if (_hasNextPage) {
      _currentPage++;
      await fetchGetAllDPRlist();
      _refreshController.loadComplete();
    } else {
      _refreshController.loadNoData();
    }
  }

  String getAppBarTitle() {
    final String pName = args.projectName?.toUpperCase() ?? '';
    final String tName = args.towarName?.toUpperCase() ?? '';
    if (tName.isNotEmpty) {
      return '$pName - $tName';
    }
    return pName;
  }

  String getSubHeaderTitle() {
    final String slabNo = args.response?.slabNo?.toUpperCase() ?? 'SLAB';
    return '$slabNo - D.P.R';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final double btnHeaderWidth = isMobile ? 110.0 : 140.0;

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          getAppBarTitle(),
          style: TextStyle(
            fontSize: isMobile ? 15.0 : 17.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xfff8f9fa),
            border: Border(
              top: BorderSide(color: Color(0xffe2e8f0)),
            ),
          ),
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 8.0 : 12.0,
            horizontal: isMobile ? 10.0 : 16.0,
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: "Active Contractors",
                  value: '0',
                  isMobile: isMobile,
                ),
              ),
              SizedBox(width: isMobile ? 8.0 : 12.0),
              Expanded(
                child: _buildMetricCard(
                  title: "Avg. Skilled",
                  value: '0',
                  isMobile: isMobile,
                ),
              ),
              SizedBox(width: isMobile ? 8.0 : 12.0),
              Expanded(
                child: _buildMetricCard(
                  title: "Avg. Unskilled",
                  value: '0',
                  isMobile: isMobile,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // SubHeader Section with Centered Slab Title and Add DPR CTA Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 8 : 10,
              ),
              color: Colors.white,
              child: Row(
                children: [
                  SizedBox(width: btnHeaderWidth),
                  Expanded(
                    child: Text(
                      getSubHeaderTitle(),
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return AddDprScreen(
                              projectId: args.projectId,
                              towarId: args.response?.towarId ?? '',
                              projectName: args.projectName,
                              towarName: args.towarName ?? '',
                              title: args.response?.slabNo,
                              slabId: args.response?.slabId,
                              slabNumber: args.response?.slabNo,
                            );
                          },
                        ),
                      ).then((value) {
                        _currentPage = 1;
                        fetchGetAllDPRlist();
                      });
                    },
                    child: Container(
                      width: btnHeaderWidth,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 6 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "ADD DPR",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 12 : 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1.0, color: Colors.black12),

            // Date Filter Section with Submit & Reset Buttons
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 8 : 10,
              ),
              child: Form(
                key: _formKey,
                child: Row(
                  children: [
                    // From Date Field
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectFromDate(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 6 : 10,
                            vertical: isMobile ? 7 : 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xffcbd5e1)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: isMobile ? 15 : 17,
                                color: const Color(0xff64748b),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  fromDateControler.text.isNotEmpty
                                      ? fromDateControler.text
                                      : "From Date",
                                  style: TextStyle(
                                    fontSize: isMobile ? 11 : 12.5,
                                    color: fromDateControler.text.isNotEmpty
                                        ? const Color(0xff1a202c)
                                        : const Color(0xff94a3b8),
                                    fontWeight: fromDateControler.text.isNotEmpty
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 6 : 8),

                    // To Date Field
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectToDate(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 6 : 10,
                            vertical: isMobile ? 7 : 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xffcbd5e1)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: isMobile ? 15 : 17,
                                color: const Color(0xff64748b),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  toDateControler.text.isNotEmpty
                                      ? toDateControler.text
                                      : "To Date",
                                  style: TextStyle(
                                    fontSize: isMobile ? 11 : 12.5,
                                    color: toDateControler.text.isNotEmpty
                                        ? const Color(0xff1a202c)
                                        : const Color(0xff94a3b8),
                                    fontWeight: toDateControler.text.isNotEmpty
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 6 : 8),

                    // Submit Button
                    InkWell(
                      onTap: _submitFilter,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 10 : 14,
                          vertical: isMobile ? 7 : 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 10.5 : 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 4 : 6),

                    // Reset Button
                    InkWell(
                      onTap: _resetFilter,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 10 : 14,
                          vertical: isMobile ? 7 : 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xffcbd5e1)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Reset",
                          style: TextStyle(
                            color: const Color(0xff475569),
                            fontSize: isMobile ? 10.5 : 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1.0, color: Colors.black12),

            // Content Area / Skeleton Loader
            Expanded(
              child: isLoading
                  ? DprSkeletonScreen(isMobile: isMobile)
                  : (_filteredDprList.isNotEmpty)
                      ? SmartRefresher(
                          controller: _refreshController,
                          enablePullDown: true,
                          enablePullUp: _hasNextPage,
                          onRefresh: _onRefresh,
                          onLoading: _onLoading,
                          child: ListView.builder(
                            padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                            itemCount: _filteredDprList.length,
                            itemBuilder: (context, index) {
                              return _buildDprCard(
                                data: _filteredDprList[index],
                                isMobile: isMobile,
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_outlined,
                                  size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text(
                                "No Daily Progress Reports found.",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: isMobile ? 14 : 15,
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 8.0 : 10.0,
        horizontal: isMobile ? 6.0 : 10.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffe2e8f0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 10.5 : 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xff1a202c),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDprCard({
    required DprItem data,
    required bool isMobile,
  }) {
    String dprDateStr = "";
    if (data.dprDate != null && data.dprDate!.trim().isNotEmpty) {
      final rawDate = data.dprDate!.trim();
      final parsed = DateTime.tryParse(rawDate);
      if (parsed != null) {
        dprDateStr = DateFormat('dd/MM/yyyy').format(parsed);
      } else {
        dprDateStr = rawDate;
      }
    }

    final String submitterName = data.createdByUser?.name ?? data.createdBy ?? "-";
    final String workType = data.workDescription ?? "-";
    final double actionBtnWidth = isMobile ? 85.0 : 95.0;

    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: isMobile ? 10.0 : 14.0),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xffe9ecef)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (data.fileUrl != null && data.fileUrl!.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PdfViewer(
                  fileName: data.fileName ?? "DPR #${data.id}.pdf",
                  fileUrl: data.fileUrl!,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("PDF report is not generated yet for this draft."),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      label: "DPR No",
                      value: data.id.isNotEmpty ? data.id : "-",
                      isMobile: isMobile,
                    ),
                    const SizedBox(height: 5),
                    _buildDetailRow(
                      label: "Submitted By",
                      value: submitterName,
                      isMobile: isMobile,
                    ),
                    const SizedBox(height: 5),
                    _buildDetailRow(
                      label: "Work Type",
                      value: workType,
                      isMobile: isMobile,
                    ),
                    const SizedBox(height: 5),
                    _buildDetailRow(
                      label: "Date on",
                      value: dprDateStr,
                      isMobile: isMobile,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Right Side Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Edit Button (Only visible if is_submitted is false)
                  if (!data.isSubmitted)
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddDprScreen(
                              projectId: args.projectId,
                              towarId: args.response?.towarId ?? '',
                              projectName: args.projectName,
                              towarName: args.towarName ?? '',
                              title: args.response?.slabNo,
                              slabId: args.response?.slabId,
                              slabNumber: args.response?.slabNo,
                              project_dpr_id: data.id,
                              dprItem: data,
                            ),
                          ),
                        ).then((value) {
                          _currentPage = 1;
                          fetchGetAllDPRlist();
                        });
                      },
                      child: Container(
                        width: actionBtnWidth,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 5 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          "Edit",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // View Doc Button (Dynamic)
                  if (data.documents.isNotEmpty) ...[
                    if (!data.isSubmitted) const SizedBox(height: 8),
                    InkWell(
                      onTap: () => viewDocumentsModal(documents: data.documents),
                      child: Container(
                        width: actionBtnWidth,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 5 : 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black87),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          "View Doc",
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required bool isMobile,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isMobile ? 95 : 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 11.5 : 12.5,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          ": ",
          style: TextStyle(
            fontSize: isMobile ? 11.5 : 12.5,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 12 : 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedFromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedFromDate = picked;
        fromDateControler.text = DateFormat('dd/MM/yyyy').format(picked);
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
    if (picked != null) {
      setState(() {
        _selectedToDate = picked;
        toDateControler.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _submitFilter() {
    setState(() {
      _appliedFromDate = _selectedFromDate;
      _appliedToDate = _selectedToDate;
      _currentPage = 1;
      _dprList.clear();
    });
    fetchGetAllDPRlist(isInitial: true);
  }

  void _resetFilter() {
    setState(() {
      _selectedFromDate = null;
      _selectedToDate = null;
      _appliedFromDate = null;
      _appliedToDate = null;
      fromDateControler.clear();
      toDateControler.clear();
      _currentPage = 1;
      _dprList.clear();
    });
    fetchGetAllDPRlist(isInitial: true);
  }

  void viewDocumentsModal({required List<DprDocument> documents}) {
    final isMobile = context.isMobile;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          title: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Text(
              "ATTACHED DOCUMENTS",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: SizedBox(
            width: isMobile ? 320 : 480,
            height: isMobile ? 280 : 340,
            child: documents.isEmpty
                ? const Center(
                    child: Text(
                      "No documents attached",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  )
                : SingleChildScrollView(
                    child: Center(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final doc in documents)
                            InkWell(
                              onTap: () async {
                                final fileUrl = doc.fileUrl;
                                final fileName = doc.fileName;
                                final mime = doc.mimeType?.toLowerCase() ?? '';
                                final ext = doc.extension?.toLowerCase() ?? '';

                                if (mime.contains('pdf') || ext == 'pdf' || fileName.toLowerCase().endsWith('.pdf')) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PdfViewer(
                                        fileName: fileName,
                                        fileUrl: fileUrl,
                                      ),
                                    ),
                                  );
                                } else if (mime.contains('video') || ext == 'mp4' || fileName.toLowerCase().endsWith('.mp4')) {
                                  final uri = Uri.parse(fileUrl);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  }
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ImagePreviewViewer(
                                        fileName: fileName,
                                        fileUrl: fileUrl,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                width: isMobile ? 110 : 120,
                                height: isMobile ? 120 : 130,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: (doc.mimeType?.contains('pdf') == true ||
                                                doc.extension == 'pdf' ||
                                                doc.fileName.toLowerCase().endsWith('.pdf'))
                                            ? Image.asset(
                                                'images/projectmanagement/pdf.png',
                                                width: isMobile ? 55 : 65,
                                                height: isMobile ? 55 : 65,
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, __, ___) => const Icon(
                                                  Icons.picture_as_pdf,
                                                  size: 50,
                                                  color: Colors.red,
                                                ),
                                              )
                                            : (doc.mimeType?.contains('video') == true ||
                                                    doc.extension == 'mp4' ||
                                                    doc.fileName.toLowerCase().endsWith('.mp4'))
                                                ? Icon(
                                                    Icons.video_camera_back,
                                                    size: isMobile ? 55 : 65,
                                                    color: Colors.black87,
                                                  )
                                                : ClipRRect(
                                                    borderRadius: BorderRadius.circular(6),
                                                    child: Image.network(
                                                      doc.fileUrl,
                                                      width: isMobile ? 70 : 80,
                                                      height: isMobile ? 70 : 80,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) => const Icon(
                                                        Icons.broken_image,
                                                        size: 45,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      doc.fileName,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 16, top: 4, left: 16, right: 16),
          actions: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: isMobile ? 120 : 140,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    "CLOSE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
