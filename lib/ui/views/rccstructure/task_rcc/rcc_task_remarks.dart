import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stallion/models/rcc_dpr_activity_model.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/ui/widgets/row_three_text.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:url_launcher/url_launcher.dart';

class RccTaskRemarks extends StatefulWidget {
  const RccTaskRemarks({
    super.key,
    this.towarId,
    this.projectId,
    this.projectName,
    this.towarName,
    required this.taskTaskId,
    this.logs,
  });
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? taskTaskId;
  final List<DprActivityLog>? logs;

  @override
  State<RccTaskRemarks> createState() => _RccTaskRemarksState();
}

class _RccTaskRemarksState extends State<RccTaskRemarks> {
  List<DprActivityLog> _logs = [];
  bool isLoading = false;

  String _formatDisplayDate(dynamic raw) {
    if (raw == null) return '';
    if (raw is DateTime) {
      return DateFormat('dd/MM/yyyy').format(raw);
    }
    String s = raw.toString().trim();
    try {
      DateTime? dt = DateTime.tryParse(s);
      if (dt != null) return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {}
    if (s.contains('-')) {
      List<String> p = s.split('T')[0].split('-');
      if (p.length == 3 && p[0].length == 4) return '${p[2]}/${p[1]}/${p[0]}';
    }
    return s;
  }

  Future<void> fetchTaskLogs() async {
    if (widget.towarId == null || widget.towarId!.isEmpty) return;
    setState(() => isLoading = true);
    try {
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        await apiNetworkHandler.ensureProjectContext(widget.projectId);
      }

      final url = AppUrl.getDprActivities(widget.towarId!);
      final response = await apiNetworkHandler.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          final dataModel = RccDprActivityResponse.fromJson(decoded);
          final act = dataModel.data.firstWhere(
            (a) => a.id == widget.taskTaskId,
            orElse: () => dataModel.data.first,
          );
          setState(() {
            _logs = act.logs;
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
    if (widget.logs != null) {
      _logs = widget.logs!;
    } else {
      fetchTaskLogs();
    }
  }

  viewTaskDetailFilesModal(List<DprActivityDocument> files) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          contentPadding: const EdgeInsets.all(16),
          actionsAlignment: MainAxisAlignment.center,
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Text(
              "ATTACHED DOCUMENTS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Text(
                  "CLOSE",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
          content: SizedBox(
            height: 280,
            width: 440,
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (int i = 0; i < files.length; i++)
                    InkWell(
                      onTap: () async {
                        final file = files[i];
                        if (file.fileUrl.isEmpty) return;
                        final isPdf = file.fileName.toLowerCase().endsWith('.pdf') ||
                            (file.mimeType ?? '').contains('pdf');
                        final isMp4 = file.fileName.toLowerCase().endsWith('.mp4') ||
                            (file.mimeType ?? '').contains('video');
                        final isImage = file.fileName.toLowerCase().endsWith('.png') ||
                            file.fileName.toLowerCase().endsWith('.jpg') ||
                            file.fileName.toLowerCase().endsWith('.jpeg') ||
                            (file.mimeType ?? '').contains('image');
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
                        } else if (isMp4) {
                          final uri = Uri.parse(file.fileUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        } else {
                          final uri = Uri.parse(file.fileUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        }
                      },
                      child: Container(
                        width: 120,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 70,
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: (files[i].fileName.toLowerCase().endsWith('.pdf') ||
                                      (files[i].mimeType ?? '').contains('pdf'))
                                  ? const Icon(Icons.picture_as_pdf, color: Colors.red, size: 48)
                                  : (files[i].fileName.toLowerCase().endsWith('.mp4') ||
                                          (files[i].mimeType ?? '').contains('video'))
                                      ? const Icon(Icons.video_collection, color: Colors.purple, size: 48)
                                      : Image.network(
                                          files[i].fileUrl,
                                          height: 65,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.insert_drive_file, size: 45, color: Colors.blue),
                                        ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              files[i].fileName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          (widget.towarName ?? '').isNotEmpty
              ? '${(widget.projectName ?? '').toUpperCase()} - ${(widget.towarName ?? '').toUpperCase()}'
              : (widget.projectName ?? '').toUpperCase(),
          style: TextStyle(
              fontStyle: FontStyle.normal,
              fontSize: isMobile ? 14.0 : 17.0),
        ),
      ),
      body: _buildBodyContent(context, isMobile),
    );
  }

  Widget _buildBodyContent(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed Subheader under the header
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "TASK REMARKS & HISTORY",
            style: TextStyle(
              fontSize: isMobile ? 15 : 17,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
        const SizedBox(height: 6),
        Expanded(
          child: isLoading
              ? CustomLoading.buildRccTaskRemarksSkeletonInline(context)
              : _logs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notes_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            "No Remarks Found",
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _logs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 2),
                      itemBuilder: (context, index) {
                        final item = _logs[index];
                        final hasDocs = item.documents.isNotEmpty;
                        final isExtension = item.logType == "DEADLINE_EXTENDED";

                        return Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 24,
                              vertical: isMobile ? 2 : 3),
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
                              rowThreeText(
                                context: context,
                                title: isExtension ? "New Deadline" : "Completed Date",
                                titleValue: _formatDisplayDate(isExtension ? item.newDeadline : item.createdAt),
                                buttonText: hasDocs ? "View Docs" : null,
                                onTapButton: () {
                                  if (hasDocs) {
                                    viewTaskDetailFilesModal(item.documents);
                                  }
                                },
                              ),
                              if (isExtension && item.previousDeadline != null)
                                rowThreeText(
                                  context: context,
                                  title: "Old Deadline",
                                  titleValue: _formatDisplayDate(item.previousDeadline),
                                ),
                              rowThreeText(
                                context: context,
                                title: isExtension ? "Extended By" : "Completed By",
                                titleValue: item.createdByUser?.name ?? item.createdBy ?? '--',
                              ),
                              rowThreeText(
                                context: context,
                                title: "Remarks",
                                titleValue: item.remarks?.trim().isNotEmpty == true ? item.remarks! : '--',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
