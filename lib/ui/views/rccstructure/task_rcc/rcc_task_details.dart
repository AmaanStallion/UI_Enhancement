import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stallion/models/rcc_dpr_activity_model.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/views/rccstructure/task_rcc/rcc_complete_task.dart';
import 'package:stallion/ui/views/rccstructure/task_rcc/rcc_extend_deadline.dart';
import 'package:stallion/ui/views/rccstructure/task_rcc/rcc_task_remarks.dart';
import 'package:stallion/ui/widgets/row_three_text.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

class RccTaskDetails extends StatefulWidget {
  const RccTaskDetails({
    super.key,
    this.towarId,
    this.projectId,
    this.projectName,
    this.towarName,
    this.dprTaskId,
    this.activity,
  });
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? dprTaskId;
  final RccDprActivity? activity;

  @override
  State<RccTaskDetails> createState() => _RccTaskDetailsState();
}

class _RccTaskDetailsState extends State<RccTaskDetails> {
  RccDprActivity? _activity;
  bool isLoading = false;

  Future<void> fetchActivityDetails() async {
    final String towerId = widget.towarId ?? _activity?.towerId ?? '';
    if (towerId.isEmpty) return;

    setState(() => isLoading = true);
    try {
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        await apiNetworkHandler.ensureProjectContext(widget.projectId);
      }

      final url = AppUrl.getDprActivities(towerId);
      final response = await apiNetworkHandler.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          final dataModel = RccDprActivityResponse.fromJson(decoded);
          final targetId = widget.dprTaskId ?? _activity?.id;
          final updated = dataModel.data.firstWhere(
            (a) => a.id == targetId,
            orElse: () => _activity!,
          );
          setState(() {
            _activity = updated;
            isLoading = false;
          });
          return;
        }
      }
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _activity = widget.activity;
    if (_activity == null) {
      fetchActivityDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;
    final act = _activity;
    final isCompleted = act?.isCompleted ?? false;
    final isOverdue = act?.isOverdue ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.towarName != null && widget.towarName!.isNotEmpty
              ? '${widget.projectName?.toUpperCase() ?? ''} - ${widget.towarName?.toUpperCase() ?? ''}'
              : (widget.projectName?.toUpperCase() ?? "TASK DETAILS"),
          style: TextStyle(
            fontSize: isMobile ? 15.0 : 17.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: isLoading || act == null
          ? CustomLoading.buildRccTaskDetailsSkeletonInline(context)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fixed Subheader
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "TASK DETAILS",
                    style: TextStyle(
                      fontSize: isMobile ? 15 : 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),

                        // 1. Assignor & Deadline Top Card (Two Columns)
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 24, vertical: 6),
                          padding: EdgeInsets.symmetric(
                              vertical: isMobile ? 12 : 16,
                              horizontal: isMobile ? 12 : 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Assignor',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: isMobile ? 13 : 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    act.resolvedAssignor ?? '--',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: isMobile ? 15 : 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    act.createdAt != null
                                        ? DateFormat('dd-MM-yyyy')
                                            .format(act.createdAt!)
                                        : '',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: isMobile ? 12 : 14,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 50,
                                width: 1,
                                color: Colors.grey.shade300,
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Deadline',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: isMobile ? 13 : 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    act.targetCompletionDate != null
                                        ? DateFormat('dd-MM-yyyy')
                                            .format(act.targetCompletionDate!)
                                        : '--',
                                    style: TextStyle(
                                      color: isOverdue ? Colors.red : Colors.black,
                                      fontSize: isMobile ? 15 : 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // 2. Task Assigned Label
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 16.0 : 24.0),
                          child: Text(
                            'Task Assigned',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // 3. Task Name & Info Card
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 24, vertical: 4),
                          padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 16,
                              vertical: isMobile ? 10 : 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                act.activityName,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: isMobile ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (act.slab != null &&
                                  act.slab!.name.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                const Divider(
                                    height: 1, color: Color(0xFFF0F0F0)),
                                const SizedBox(height: 6),
                                rowThreeText(
                                  context: context,
                                  title: "Slab",
                                  titleValue: act.slab!.name,
                                ),
                              ],
                              if (act.tower != null &&
                                  act.tower!.name.isNotEmpty)
                                rowThreeText(
                                  context: context,
                                  title: "Tower",
                                  titleValue: act.tower!.name,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 4. Task Completed Header + View Remarks Button
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 16.0 : 24.0),
                          child: Row(
                            children: [
                              Text(
                                'Task Completed',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: isMobile ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RccTaskRemarks(
                                        projectId: widget.projectId,
                                        towarId: widget.towarId ?? '',
                                        projectName: widget.projectName,
                                        towarName: widget.towarName ?? '',
                                        taskTaskId: act.id,
                                        logs: act.logs,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 12 : 16,
                                      vertical: 4),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.black54)),
                                  child: Text(
                                    'View Remarks',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: isMobile ? 12 : 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 5. Vertical History Graph
                        _buildTimelineGraph(act, isMobile),

                        // 6. Completion Details Section (if completed)
                        if (isCompleted && act.completionLog != null)
                          _buildCompletionDetailsSection(act, isMobile),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: isLoading || act == null
          ? null
          : Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: !isCompleted
                  ? Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RccCompleteTaskPage(
                                    dprTaskId: act.id,
                                    projectId: widget.projectId,
                                    towarId: widget.towarId ?? '',
                                    projectName: widget.projectName,
                                    towarName: widget.towarName ?? '',
                                    activity: act,
                                  ),
                                ),
                              ).then((_) => fetchActivityDetails());
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: isMobile ? 10 : 12),
                              margin: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 6 : 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                "COMPLETE TASK",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 13 : 15,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RccExtendDeadlinePage(
                                    dprTaskId: act.id,
                                    projectId: widget.projectId,
                                    towarId: widget.towarId ?? '',
                                    projectName: widget.projectName,
                                    towarName: widget.towarName ?? '',
                                    activity: act,
                                  ),
                                ),
                              ).then((_) => fetchActivityDetails());
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: isMobile ? 10 : 12),
                              margin: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 6 : 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                "EXTEND DEADLINE",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 13 : 15,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
                      margin: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 24, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        "TASK COMPLETED",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: isMobile ? 13 : 15,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
            ),
    );
  }

  Widget _buildTimelineGraph(RccDprActivity act, bool isMobile) {
    List<Map<String, String>> timelineItems = [];

    String formatDisplayDate(DateTime? dt) {
      if (dt == null) return '--';
      return DateFormat('dd/MM/yyyy').format(dt);
    }

    final extensionLogs = act.extensionLogs;
    if (extensionLogs.isNotEmpty) {
      final firstLog = extensionLogs.first;
      String origDate = formatDisplayDate(
          firstLog.previousDeadline ?? act.targetCompletionDate);
      timelineItems.add({
        "date": origDate,
        "info": "Original Deadline by ${act.resolvedAssignor ?? ''}",
      });

      for (final log in extensionLogs) {
        String extDate = formatDisplayDate(log.newDeadline);
        String person = log.createdByUser?.name ?? log.createdBy ?? 'Admin';
        timelineItems.add({
          "date": extDate,
          "info": "Extended Deadline by $person",
        });
      }
    } else {
      timelineItems.add({
        "date": formatDisplayDate(act.targetCompletionDate),
        "info": "Original Deadline by ${act.resolvedAssignor ?? ''}",
      });
    }

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 24, vertical: 8),
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16, vertical: isMobile ? 8 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < timelineItems.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                  child: Column(
                    children: [
                      Container(
                        width: 2,
                        height: i == 0 ? 0 : 4,
                        color: i == 0 ? Colors.transparent : Colors.grey.shade500,
                      ),
                      Container(
                        height: 20,
                        width: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: const Icon(
                          Icons.clear,
                          color: Colors.white,
                          size: 13,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: i == timelineItems.length - 1 ? 0 : 28,
                        color: i == timelineItems.length - 1
                            ? Colors.transparent
                            : Colors.grey.shade500,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      '${timelineItems[i]["date"]}  -  ${timelineItems[i]["info"]}',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletionDetailsSection(RccDprActivity act, bool isMobile) {
    final compLog = act.completionLog;
    final completionDate = act.completedAt ?? compLog?.createdAt;
    final completedBy = act.resolvedCompletedBy;
    final remarks = compLog?.remarks;
    final docs = compLog?.documents ?? [];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 24, vertical: 8),
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16, vertical: isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Task Completion Details',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          rowThreeText(
            context: context,
            title: "Completed By",
            titleValue: completedBy ?? '--',
            titleWidth: isMobile ? 115.0 : 130.0,
          ),
          rowThreeText(
            context: context,
            title: "Completed Date",
            titleValue: completionDate != null
                ? DateFormat('dd-MM-yyyy').format(completionDate)
                : '--',
            titleWidth: isMobile ? 115.0 : 130.0,
          ),
          if (remarks != null && remarks.isNotEmpty)
            rowThreeText(
              context: context,
              title: "Remarks",
              titleValue: remarks,
              titleWidth: isMobile ? 115.0 : 130.0,
            ),
          if (docs.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Completion Attached Documents',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final file = docs[index];
                final isPdf = file.fileName.toLowerCase().endsWith('.pdf') ||
                    (file.mimeType ?? '').contains('pdf');
                final isImage = file.fileName.toLowerCase().endsWith('.png') ||
                    file.fileName.toLowerCase().endsWith('.jpg') ||
                    file.fileName.toLowerCase().endsWith('.jpeg') ||
                    (file.mimeType ?? '').contains('image');

                return InkWell(
                  onTap: () async {
                    if (file.fileUrl.isEmpty) return;
                    if (isPdf) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PdfViewer(
                            isLocalFileUpload: false,
                            fileName: file.fileName,
                            fileUrl: file.fileUrl,
                          ),
                        ),
                      );
                    } else if (isImage) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ImagePreviewViewer(
                            fileName: file.fileName,
                            fileUrl: file.fileUrl,
                          ),
                        ),
                      );
                    } else {
                      final Uri uri = Uri.parse(file.fileUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPdf
                              ? Icons.picture_as_pdf
                              : isImage
                                  ? Icons.image
                                  : Icons.insert_drive_file,
                          color: isPdf
                              ? Colors.red
                              : isImage
                                  ? Colors.blue
                                  : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            file.fileName,
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.open_in_new,
                            size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
