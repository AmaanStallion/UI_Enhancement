import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:stallion/models/get_project_dpr_contractor.dart';
import 'package:stallion/models/rcc_dpr_api_models.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PreviewDPRScreen extends StatefulWidget {
  final String? projectId;
  final String? towarName;
  final String? projectName;
  final String? towarId;
  final List<CustomType>? customType;
  final List<WorkProgress>? workProgressList;
  final String? slabId;
  final String? slabNo;
  final String? dprDate;
  final String? workType;
  final List<Skill>? skillResponse;
  final String visitors;
  final List<ContrctorList>? contrctorList;
  final String? worktype;
  final List<DprStockList>? dprStockList;

  final List<PlatformFile> arrayFiles;
  final List<Uint8List?> arrayFilesBytes;
  final List<OrderDeliveredList>? orderDeliveredList;
  final List<DprYesterdayActivity>? dprYesterdayActivity;
  final List<DprYesterdayActivity>? todaysPlanActivitySelected;
  final String? dificultiesNrequirements;
  final String? dpr_difficulti_requirement;
  final String? project_dpr_id;
  final DprItem? dprItem;
  final List<ContractProgress>? contractProgress;
  final List<DprStaffList>? dprStaffList;

  const PreviewDPRScreen({
    super.key,
    this.projectId,
    this.towarName,
    this.projectName,
    this.towarId,
    this.contrctorList,
    this.customType,
    this.workProgressList,
    this.slabId,
    this.slabNo,
    this.dprDate,
    this.workType,
    this.skillResponse,
    this.worktype,
    this.arrayFiles = const [],
    this.arrayFilesBytes = const [],
    this.orderDeliveredList,
    this.dpr_difficulti_requirement,
    this.dprYesterdayActivity,
    this.todaysPlanActivitySelected,
    this.dificultiesNrequirements,
    this.project_dpr_id = '',
    this.dprItem,
    this.contractProgress,
    this.visitors = '',
    this.dprStaffList,
    this.dprStockList,
  });

  @override
  State<PreviewDPRScreen> createState() => _PreviewDPRScreenState();
}

class _PreviewDPRScreenState extends State<PreviewDPRScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late PdfViewerController _pdfViewerController;

  Uint8List? _pdfBytes;
  bool _isLoadingPdf = true;
  String? _errorMessage;
  final NetworkHandler _networkHandler = NetworkHandler();

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _fetchPreviewPdf();
  }

  Map<String, dynamic> _compileDprPayload() {
    final slabIdNum = int.tryParse(widget.slabId ?? '0') ?? 0;

    // Contractors
    final List<Map<String, dynamic>> contractorsList = [];
    if (widget.contrctorList != null) {
      for (final c in widget.contrctorList!) {
        if (c.isSelected == true) {
          final cId = int.tryParse(c.companyId ?? '0') ?? c.companyId;
          final labourCount = int.tryParse(c.count?.toString() ?? '0') ?? 0;
          contractorsList.add({
            'contractor_id': cId,
            'labour_count': labourCount,
          });
        }
      }
    }

    // Selected Skills
    final List<dynamic> selectedSkillsList = [];
    if (widget.skillResponse != null) {
      for (final s in widget.skillResponse!) {
        if (s.isSelected == true) {
          final sId = int.tryParse(s.mstWorkId?.toString() ?? '0') ?? s.mstWorkId;
          if (sId != null && sId != 0) {
            selectedSkillsList.add(sId);
          }
        }
      }
    }

    // Employee Details / Categories
    final List<Map<String, dynamic>> employeeDetailsList = [];
    if (widget.customType != null) {
      for (final ct in widget.customType!) {
        final count = int.tryParse(ct.value.trim()) ?? 0;
        final typeId = int.tryParse(ct.id.trim());
        if (count > 0 || ct.description.trim().isNotEmpty) {
          if (typeId != null && typeId > 0) {
            employeeDetailsList.add({
              'dpr_type_id': typeId,
              'employee_count': count,
              'remarks': ct.description.trim(),
            });
          } else if (ct.name.trim().isNotEmpty) {
            employeeDetailsList.add({
              'name': ct.name.trim(),
              'employee_count': count,
              'remarks': ct.description.trim(),
            });
          }
        }
      }
    }

    // Team Members
    final List<Map<String, dynamic>> teamMembersList = [];
    if (widget.dprStaffList != null) {
      for (final staff in widget.dprStaffList!) {
        if (staff.staffName != null && staff.staffName!.trim().isNotEmpty) {
          teamMembersList.add({
            'name': staff.staffName!.trim(),
            'in_time': staff.inTime != null && staff.inTime!.isNotEmpty ? staff.inTime! : '09:00',
            'out_time': staff.outTime != null && staff.outTime!.isNotEmpty ? staff.outTime! : '18:00',
          });
        }
      }
    }

    // Activities
    final List<Map<String, dynamic>> activitiesList = [];
    if (widget.todaysPlanActivitySelected != null) {
      for (final act in widget.todaysPlanActivitySelected!) {
        final desc = act.descriptionVal.isNotEmpty
            ? act.descriptionVal
            : (act.description ?? '');
        if (desc.trim().isNotEmpty) {
          String targetDate = act.targetdate != null && act.targetdate!.isNotEmpty
              ? act.targetdate!
              : (widget.dprDate ?? '');

          if (targetDate.contains('/')) {
            final parts = targetDate.split('/');
            if (parts.length == 3) {
              final d = parts[0].padLeft(2, '0');
              final m = parts[1].padLeft(2, '0');
              final y = parts[2];
              targetDate = '$y-$m-$d';
            }
          }

          activitiesList.add({
            'activity_name': desc.trim(),
            'parent_activity_id': null,
            'target_completion_date': targetDate,
            'is_completed': false,
          });
        }
      }
    }

    // Work Progress
    final List<Map<String, dynamic>> workProgressList = [];
    if (widget.workProgressList != null) {
      for (final wp in widget.workProgressList!) {
        if (wp.title != null && wp.title!.trim().isNotEmpty) {
          workProgressList.add({
            'progress': wp.title!.trim(),
          });
        }
      }
    }

    return {
      'slab_id': slabIdNum,
      'dpr_date': widget.dprDate ?? '',
      'work_description': widget.workType ?? widget.worktype ?? '',
      'contractors': contractorsList,
      'selected_skills': selectedSkillsList,
      'issue_description': widget.dpr_difficulti_requirement ?? widget.dificultiesNrequirements ?? '',
      'visitors': widget.visitors,
      'employee_details': employeeDetailsList,
      'team_members': teamMembersList,
      'activities': activitiesList,
      'work_progress': workProgressList,
    };
  }

  Future<void> _fetchPreviewPdf() async {
    setState(() {
      _isLoadingPdf = true;
      _errorMessage = null;
    });

    try {
      final token = await _networkHandler.getToken();
      final payload = _compileDprPayload();

      final response = await http.post(
        Uri.parse(AppUrl.dprPreviewPdf),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _pdfBytes = response.bodyBytes;
          _isLoadingPdf = false;
        });
      } else {
        String err = "Failed to generate preview PDF (HTTP ${response.statusCode})";
        try {
          final decoded = json.decode(response.body);
          if (decoded['message'] != null) {
            err = decoded['message'];
          }
        } catch (_) {}
        setState(() {
          _errorMessage = err;
          _isLoadingPdf = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching preview PDF: $e");
      setState(() {
        _errorMessage = "Network error while generating preview: $e";
        _isLoadingPdf = false;
      });
    }
  }

  Future<void> _submitDpr() async {
    CustomLoading.progressDialog(isLoading: true, context: context);

    try {
      final token = await _networkHandler.getToken();
      final bool isUpdating = widget.project_dpr_id != null && widget.project_dpr_id!.isNotEmpty;
      final String url = isUpdating
          ? AppUrl.updateDpr(widget.project_dpr_id!)
          : AppUrl.createDpr;

      final request = http.MultipartRequest(isUpdating ? 'PUT' : 'POST', Uri.parse(url));

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final fullPayload = _compileDprPayload();
      final Map<String, dynamic> payloadToSend;

      if (isUpdating && widget.dprItem != null) {
        payloadToSend = computeDprDiffPayload(
          original: widget.dprItem!,
          currentPayload: fullPayload,
          isSubmitted: true,
        );
      } else {
        payloadToSend = Map<String, dynamic>.from(fullPayload);
        payloadToSend['is_submitted'] = true;
      }

      payloadToSend.forEach((key, value) {
        if (value is String) {
          request.fields[key] = value;
        } else if (value is num || value is bool) {
          request.fields[key] = value.toString();
        } else if (value != null) {
          request.fields[key] = jsonEncode(value);
        }
      });

      // Attach document files
      for (final file in widget.arrayFiles) {
        final ext = (file.extension ?? (file.name.contains('.') ? file.name.split('.').last : '')).toLowerCase();
        MediaType? mediaType;
        if (ext == 'pdf') {
          mediaType = MediaType('application', 'pdf');
        } else if (ext == 'png' || ext == 'jpg' || ext == 'jpeg' || ext == 'webp' || ext == 'gif') {
          mediaType = MediaType('image', ext == 'jpg' ? 'jpeg' : ext);
        } else if (ext == 'mp4') {
          mediaType = MediaType('video', 'mp4');
        } else if (ext == 'mov') {
          mediaType = MediaType('video', 'quicktime');
        }

        if (file.path != null && file.path!.isNotEmpty) {
          request.files.add(await http.MultipartFile.fromPath(
            'documents',
            file.path!,
            contentType: mediaType,
          ));
        } else if (file.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'documents',
            file.bytes!,
            filename: file.name,
            contentType: mediaType,
          ));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (mounted) {
        CustomLoading.progressDialog(isLoading: false, context: context);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        _showSuccessDialog();
      } else {
        String msg = "Failed to submit DPR (${response.statusCode})";
        try {
          final decoded = json.decode(response.body);
          if (decoded['message'] != null) {
            msg = decoded['message'];
          }
        } catch (_) {}

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        CustomLoading.progressDialog(isLoading: false, context: context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error submitting DPR: $e"),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 40,
            vertical: 24,
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            color: Colors.black,
            child: const Text(
              "DPR Submitted",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xffdcfce7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Color(0xff16a34a),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Your Daily Progress Report has been submitted successfully and the official PDF report is generated.",
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Color(0xff64748b),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(true); // Close preview screen
                  Navigator.of(context).pop(true); // Close add dpr screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmSubmitDialog() {
    showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            color: Colors.black,
            child: const Text(
              "Submit D.P.R",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          content: const Text(
            "Are you sure you want to submit this Daily Progress Report? Once submitted, the official PDF report will be published.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Color(0xff475569),
              height: 1.4,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: Color(0xffcbd5e1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      _submitDpr();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    final String title = widget.towarName != null && widget.towarName!.isNotEmpty
        ? '${widget.projectName?.toUpperCase() ?? ''} - ${widget.towarName?.toUpperCase() ?? ''}'
        : widget.projectName?.toUpperCase() ?? 'DPR PREVIEW';

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Colors.white, size: 28),
            onPressed: () {
              _pdfViewerController.zoomLevel = (_pdfViewerController.zoomLevel + 0.5).clamp(1.0, 3.0);
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out, color: Colors.white, size: 28),
            onPressed: () {
              _pdfViewerController.zoomLevel = (_pdfViewerController.zoomLevel - 0.5).clamp(1.0, 3.0);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16.0 : 24.0,
            vertical: isMobile ? 10.0 : 14.0,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.black12)),
          ),
          child: InkWell(
            onTap: _isLoadingPdf || _pdfBytes == null ? null : _confirmSubmitDialog,
            child: Container(
              height: isMobile ? 44 : 48,
              decoration: BoxDecoration(
                color: _isLoadingPdf || _pdfBytes == null ? Colors.grey.shade400 : Colors.black,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "SUBMIT D.P.R",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoadingPdf
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.black),
                  SizedBox(height: 16),
                  Text(
                    "Generating PDF Preview...",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff64748b),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xff334155),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchPreviewPdf,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text("Retry", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: SfPdfViewer.memory(
                    _pdfBytes!,
                    key: _pdfViewerKey,
                    controller: _pdfViewerController,
                    enableDoubleTapZooming: true,
                  ),
                ),
    );
  }
}
