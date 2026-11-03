import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_purchase_order_default_request.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:stallion/utils/remove_temp_file.dart';
import 'package:stallion/ui/views/rccstructure/rcc_skeleton_loader.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../utils/api_network_call.dart';
import '../../../../utils/app_url.dart';
import '../../../models/get_purchase_order_preview.dart';
import '../../../models/po_api_models.dart';
import '../workprogess/workprogess_list.dart';
import '../../../websocket/socket_service.dart';

class PurchaseOrderPreview extends StatefulWidget {
  PurchaseOrderPreview({
    Key? key,
    this.projectId,
    this.towarId,
    this.towarName,
    this.projectName,
    this.arrBookingDetailsJSON,
    this.strRemark,
    this.strSlabID,
    this.totalAmount,
    this.requestId,
    required this.slabDetailsSelectedArray,
    required this.arrayFiles,
    required this.arrayFilesBytes,
  });

  final String? projectId;
  final String? towarId;
  final String? towarName;
  final String? projectName;
  final String? arrBookingDetailsJSON;
  final String? requestId;
  String? strRemark;
  String? strSlabID;
  double? totalAmount;
  List<SlabDetail>? slabDetailsSelectedArray;
  List<PlatformFile> arrayFiles = [];
  List<Uint8List?> arrayFilesBytes = [];

  @override
  State<PurchaseOrderPreview> createState() => _PurchaseOrderPreviewState();
}

class _PurchaseOrderPreviewState extends State<PurchaseOrderPreview> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool isZoomed = false;
  bool isPdfLoading = true;
  String? createdRequestId;
  String? pdfErrorNotice;
  bool isSubmitting = false;
  NetworkHandler apiNetworkHandler = NetworkHandler();

  late PdfViewerController _pdfViewerController;

  String? filePath = '';
  String? fileName = '';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<dynamic> itemsList = [];

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();

    try {
      if (widget.arrBookingDetailsJSON != null &&
          widget.arrBookingDetailsJSON!.isNotEmpty) {
        itemsList = jsonDecode(widget.arrBookingDetailsJSON!);
      }
    } catch (_) {}

    if (widget.requestId != null && widget.requestId!.isNotEmpty) {
      createdRequestId = widget.requestId;
      _fetchPreviewPdf(widget.requestId!);
    } else {
      _autoCreateOrUpdateDraftAndFetchPreview();
    }
  }

  void _handleBackNavigation() {
    Navigator.pop(context, createdRequestId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showConfirmationDialog() {
    final bool isMobile = context.isMobile;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          title: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.black,
            child: Text(
              "CONFIRM PURCHASE ORDER",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 14 : 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  size: 32,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Are you sure you want to submit this purchase order request?",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 16, top: 8),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black54),
                    ),
                    child: const Text(
                      "NO, CANCEL",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    if (createdRequestId != null &&
                        createdRequestId!.isNotEmpty) {
                      _showSuccessDialog(createdRequestId);
                    } else {
                      _submitPurchaseOrder();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "YES, SUBMIT",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
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

  List<Map<String, dynamic>> _buildPayloadItems() {
    List<Map<String, dynamic>> payloadItems = [];
    for (final item in itemsList) {
      final Map<String, dynamic> itemMap = {};

      final vTypeId = item['vendor_type_id']?.toString() ??
          item['grade_id']?.toString() ??
          '';
      itemMap['vendor_type_id'] = vTypeId;

      final vGradeId = item['vendor_type_grade_id']?.toString();
      if (vGradeId != null && vGradeId.isNotEmpty) {
        itemMap['vendor_type_grade_id'] = vGradeId;
      }

      final brand = item['brand_name']?.toString() ??
          item['brand_supplier_name']?.toString();
      if (brand != null && brand.trim().isNotEmpty) {
        itemMap['brand_name'] = brand.trim();
      }

      List<String> slabs = [];
      if (item['slab_ids'] is List) {
        slabs = (item['slab_ids'] as List)
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      itemMap['slab_ids'] = slabs;

      // requirement_date normalized to YYYY-MM-DD
      String reqDate = item['requirement_date']?.toString() ??
          item['casting_date']?.toString() ??
          '';
      if (reqDate.contains('-')) {
        final parts = reqDate.split('-');
        if (parts.length == 3 && parts[0].length == 2 && parts[2].length == 4) {
          // dd-MM-yyyy -> yyyy-MM-dd
          reqDate = "${parts[2]}-${parts[1]}-${parts[0]}";
        }
      }
      itemMap['requirement_date'] = reqDate;

      itemMap['quantity'] = item['quantity']?.toString() ?? '0';

      final unitId = item['po_unit_id']?.toString() ??
          item['casting_unit']?.toString() ??
          '';
      itemMap['po_unit_id'] = unitId;

      final price = item['unit_price']?.toString();
      if (price != null &&
          price.trim().isNotEmpty &&
          (double.tryParse(price) ?? 0) > 0) {
        itemMap['unit_price'] = price.trim();
      }

      payloadItems.add(itemMap);
    }
    return payloadItems;
  }

  Future<String> _getEffectiveProjectId() async {
    if (widget.projectId != null &&
        widget.projectId!.trim().isNotEmpty &&
        widget.projectId != '0') {
      return widget.projectId!.trim();
    }
    if (NetworkHandler.activeProjectIdCache != null &&
        NetworkHandler.activeProjectIdCache!.isNotEmpty &&
        NetworkHandler.activeProjectIdCache != '0') {
      return NetworkHandler.activeProjectIdCache!;
    }
    try {
      final prefs = await _prefs;
      final savedId = prefs.getString('activeProjectId');
      if (savedId != null && savedId.isNotEmpty && savedId != '0') {
        return savedId;
      }
    } catch (_) {}
    return '';
  }

  String _getEffectiveTowerId() {
    if (widget.towarId != null &&
        widget.towarId!.trim().isNotEmpty &&
        widget.towarId != '0') {
      return widget.towarId!.trim();
    }
    final activeTower = SocketService.currentActiveTowerId;
    if (activeTower != null &&
        activeTower.trim().isNotEmpty &&
        activeTower != '0') {
      return activeTower.trim();
    }
    return '';
  }

  Future<http.Response> _executeCreatePoRequest({
    required String effectiveProjectId,
    required String effectiveTowerId,
    required List<Map<String, dynamic>> payloadItems,
    required String? remarks,
    required String? token,
    required List<PlatformFile> files,
  }) async {
    final baseUrl = AppUrl.purchaseOrderRequests;
    final activeToken = token ?? await apiNetworkHandler.getToken() ?? '';

    if (files.isNotEmpty) {
      final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.headers['Authorization'] = 'Bearer $activeToken';
      if (effectiveProjectId.isNotEmpty) {
        request.headers['x-project-id'] = effectiveProjectId;
      }

      request.fields['tower_id'] = effectiveTowerId;
      if (remarks != null && remarks.trim().isNotEmpty) {
        request.fields['remarks'] = remarks.trim();
      }
      request.fields['items'] = jsonEncode(payloadItems);

      for (final file in files.take(10)) {
        if (file.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'attachments',
            file.bytes!,
            filename: file.name,
          ));
        } else if (file.path != null && file.path!.isNotEmpty) {
          request.files.add(await http.MultipartFile.fromPath(
            'attachments',
            file.path!,
            filename: file.name,
          ));
        }
      }
      final streamed = await request.send();
      return await http.Response.fromStream(streamed);
    } else {
      final Map<String, dynamic> body = {
        'tower_id': effectiveTowerId,
        'items': payloadItems,
      };
      if (remarks != null && remarks.trim().isNotEmpty) {
        body['remarks'] = remarks.trim();
      }

      final Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $activeToken',
      };
      if (effectiveProjectId.isNotEmpty) {
        headers['x-project-id'] = effectiveProjectId;
      }

      return await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(body),
      );
    }
  }

  Future<http.Response> _executeUpdatePoRequest({
    required String reqId,
    required String effectiveProjectId,
    required List<Map<String, dynamic>> payloadItems,
    required String? remarks,
    required String? token,
    required List<PlatformFile> files,
  }) async {
    final url = AppUrl.purchaseOrderRequestById(reqId);
    if (files.isNotEmpty) {
      final request = http.MultipartRequest('PUT', Uri.parse(url));
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      if (effectiveProjectId.isNotEmpty) {
        request.headers['x-project-id'] = effectiveProjectId;
      }
      if (remarks != null && remarks.trim().isNotEmpty) {
        request.fields['remarks'] = remarks.trim();
      }
      request.fields['items'] = jsonEncode(payloadItems);

      for (final file in files.take(10)) {
        if (file.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'attachments',
            file.bytes!,
            filename: file.name,
          ));
        } else if (file.path != null && file.path!.isNotEmpty) {
          request.files.add(await http.MultipartFile.fromPath(
            'attachments',
            file.path!,
            filename: file.name,
          ));
        }
      }
      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } else {
      final Map<String, dynamic> body = {
        'items': payloadItems,
      };
      if (remarks != null && remarks.trim().isNotEmpty) {
        body['remarks'] = remarks.trim();
      }
      return await apiNetworkHandler.put(url, body);
    }
  }

  Future<void> _autoCreateOrUpdateDraftAndFetchPreview() async {
    setState(() {
      isPdfLoading = true;
      pdfErrorNotice = null;
    });

    final effectiveProjectId = await _getEffectiveProjectId();
    final String effectiveTowerId = _getEffectiveTowerId();

    if (effectiveProjectId.isNotEmpty && effectiveTowerId.isNotEmpty) {
      await apiNetworkHandler.ensureTowerContext(effectiveProjectId, effectiveTowerId);
    } else if (effectiveProjectId.isNotEmpty) {
      await apiNetworkHandler.ensureProjectContext(effectiveProjectId);
    }

    try {
      final payloadItems = _buildPayloadItems();
      final hasExisting =
          createdRequestId != null && createdRequestId!.isNotEmpty;
      final token = await apiNetworkHandler.getToken();

      http.Response response;
      if (hasExisting) {
        response = await _executeUpdatePoRequest(
          reqId: createdRequestId!,
          effectiveProjectId: effectiveProjectId,
          payloadItems: payloadItems,
          remarks: widget.strRemark,
          token: token,
          files: widget.arrayFiles,
        );
      } else {
        response = await _executeCreatePoRequest(
          effectiveProjectId: effectiveProjectId,
          effectiveTowerId: effectiveTowerId,
          payloadItems: payloadItems,
          remarks: widget.strRemark,
          token: token,
          files: widget.arrayFiles,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final createResp = PoRequestCreateResponse.fromJson(decoded);
        if (createResp.requestId != null && createResp.requestId!.isNotEmpty) {
          createdRequestId = createResp.requestId;
        }

        final pdfUrl = createResp.previewUrl ??
            decoded['data']?['preview_pdf_signed_url']?.toString() ??
            decoded['data']?['preview_pdf_url']?.toString() ??
            decoded['data']?['preview_url']?.toString();

        if (pdfUrl != null && pdfUrl.isNotEmpty) {
          setState(() {
            filePath = pdfUrl;
            pdfErrorNotice = null;
            isPdfLoading = false;
          });
        } else if (createdRequestId != null && createdRequestId!.isNotEmpty) {
          await _fetchPreviewPdf(createdRequestId!);
        } else {
          setState(() {
            isPdfLoading = false;
          });
        }
      } else {
        String errMsg =
            "Failed to prepare order preview (HTTP ${response.statusCode})";
        try {
          final decoded = jsonDecode(response.body);
          if (decoded['message'] != null) {
            errMsg = decoded['message'].toString();
          }
        } catch (_) {}
        setState(() {
          pdfErrorNotice = errMsg;
          isPdfLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        pdfErrorNotice = "Error generating preview: $e";
        isPdfLoading = false;
      });
    }
  }

  Future<void> _submitPurchaseOrder() async {
    // If order was already created in preview step, complete directly
    if (createdRequestId != null && createdRequestId!.isNotEmpty) {
      _showSuccessDialog(createdRequestId);
      return;
    }

    setState(() {
      isSubmitting = true;
    });
    CustomLoading.progressDialog(isLoading: true, context: context);

    final effectiveProjectId = await _getEffectiveProjectId();
    final String effectiveTowerId = _getEffectiveTowerId();

    if (effectiveProjectId.isNotEmpty && effectiveTowerId.isNotEmpty) {
      await apiNetworkHandler.ensureTowerContext(effectiveProjectId, effectiveTowerId);
    } else if (effectiveProjectId.isNotEmpty) {
      await apiNetworkHandler.ensureProjectContext(effectiveProjectId);
    }

    try {
      final payloadItems = _buildPayloadItems();
      final token = await apiNetworkHandler.getToken();

      final response = await _executeCreatePoRequest(
        effectiveProjectId: effectiveProjectId,
        effectiveTowerId: effectiveTowerId,
        payloadItems: payloadItems,
        remarks: widget.strRemark,
        token: token,
        files: widget.arrayFiles,
      );

      CustomLoading.progressDialog(isLoading: false, context: context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final createResp = PoRequestCreateResponse.fromJson(decoded);
        createdRequestId = createResp.requestId;

        _showSuccessDialog(createdRequestId);
      } else {
        String errMsg =
            "Failed to submit purchase order (${response.statusCode})";
        try {
          final decoded = jsonDecode(response.body);
          if (decoded['message'] != null) {
            errMsg = decoded['message'].toString();
          } else if (decoded['error'] != null) {
            errMsg = decoded['error'].toString();
          }
        } catch (_) {}
        _showModernAlert(
            title: "Submission Failed", message: errMsg, isError: true);
      }
    } catch (e) {
      CustomLoading.progressDialog(isLoading: false, context: context);
      _showModernAlert(
          title: "Error",
          message: "An unexpected error occurred: $e",
          isError: true);
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  Future<void> _fetchPreviewPdf(String reqId) async {
    try {
      final effectiveProjectId = await _getEffectiveProjectId();
      final String effectiveTowerId = _getEffectiveTowerId();

      if (effectiveProjectId.isNotEmpty && effectiveTowerId.isNotEmpty) {
        await apiNetworkHandler.ensureTowerContext(effectiveProjectId, effectiveTowerId);
      }

      final url = AppUrl.purchaseOrderPreviewPdf(reqId);
      final body = <String, dynamic>{};

      final res = await apiNetworkHandler.post1(url, body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        final decoded = jsonDecode(res.body);
        final prevResp = PoPreviewResponse.fromJson(decoded);
        final pdfUrl = prevResp.previewUrl ??
            decoded['data']?['preview_pdf_signed_url']?.toString() ??
            decoded['data']?['preview_pdf_url']?.toString() ??
            decoded['data']?['preview_url']?.toString();

        if (pdfUrl != null && pdfUrl.isNotEmpty) {
          setState(() {
            filePath = pdfUrl;
            pdfErrorNotice = null;
            isPdfLoading = false;
          });
        } else {
          setState(() {
            pdfErrorNotice = "No preview URL returned from server.";
            isPdfLoading = false;
          });
        }
      } else if (res.statusCode == 422) {
        setState(() {
          pdfErrorNotice =
              "No PO template is configured for this tower (HTTP 422).";
          isPdfLoading = false;
        });
      } else if (res.statusCode == 502) {
        setState(() {
          pdfErrorNotice =
              "PDF generation failed on Lambda service (HTTP 502).";
          isPdfLoading = false;
        });
      } else {
        String serverErr =
            "PDF preview generation failed (HTTP ${res.statusCode}).";
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['message'] != null) {
            serverErr = decoded['message'].toString();
          }
        } catch (_) {}
        setState(() {
          pdfErrorNotice = serverErr;
          isPdfLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        pdfErrorNotice = "Error loading PDF: $e";
        isPdfLoading = false;
      });
    }
  }

  void _showModernAlert(
      {required String title, required String message, bool isError = false}) {
    final isMobile = context.isMobile;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          title: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.black,
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 14 : 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isError
                      ? const Color(0xFFFEE2E2)
                      : const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isError ? Icons.error_outline : Icons.info_outline,
                  size: 32,
                  color: isError ? const Color(0xFFDC2626) : Colors.black87,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 16, top: 8),
          actions: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog([String? reqId]) {
    final bool isMobile = context.isMobile;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          title: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.black,
            child: Text(
              "ORDER SUBMITTED",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 14 : 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 36,
                  color: Color(0xFF16A34A),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                (reqId != null && reqId.isNotEmpty)
                    ? "Purchase order request #$reqId submitted successfully!"
                    : "Purchase order request submitted successfully!",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 16, top: 8),
          actions: [
            InkWell(
              onTap: () async {
                Navigator.pop(context);
                final SharedPreferences prefs = await _prefs;
                await prefs.setString('flagRedirectToWorkProgress', 'true');
                Navigator.maybePop(context);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "DONE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;
    final bool hasPdf = filePath != null && filePath!.isNotEmpty;

    return WillPopScope(
      onWillPop: () async {
        _handleBackNavigation();
        return false;
      },
      child: LoaderOverlay(
        useDefaultLoading: false,
        overlayWidgetBuilder: (_) => const Center(
          child: SpinKitRing(
            lineWidth: 5.0,
            color: Colors.black,
            size: 50.0,
          ),
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              isMobile
                  ? '${widget.projectName?.toUpperCase() ?? "PROJECT"} - PREVIEW'
                  : '${widget.projectName?.toUpperCase() ?? "PROJECT"} - PURCHASE ORDER PREVIEW',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 14.5 : 17.0,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _handleBackNavigation,
            ),
            actions: hasPdf
                ? <Widget>[
                    IconButton(
                      icon: const Icon(Icons.zoom_in, color: Colors.white, size: 28),
                      tooltip: "Zoom In",
                      onPressed: () {
                        setState(() {
                          isZoomed = true;
                        });
                        try {
                          _pdfViewerController.zoomLevel =
                              (_pdfViewerController.zoomLevel + 0.25).clamp(0.5, 3.5);
                        } catch (_) {}
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_out, color: Colors.white, size: 28),
                      tooltip: "Zoom Out",
                      onPressed: () {
                        setState(() {
                          isZoomed = false;
                        });
                        try {
                          _pdfViewerController.zoomLevel =
                              (_pdfViewerController.zoomLevel - 0.25).clamp(0.5, 3.5);
                        } catch (_) {}
                      },
                    ),
                    const SizedBox(width: 8),
                  ]
                : null,
          ),
          body: isPdfLoading
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SpinKitRing(
                        lineWidth: 4.0,
                        color: Colors.black,
                        size: 46.0,
                      ),
                      SizedBox(height: 18),
                      Text(
                        "Generating Purchase Order PDF...",
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Rendering template via backend service",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                )
              : hasPdf
                  ? Center(
                      child: Container(
                        width: isMobile ? double.infinity : (isZoomed ? 940 : 700),
                        child: SfPdfViewer.network(
                          onDocumentLoaded: (details) {
                            setState(() {
                              isPdfLoading = false;
                            });
                            if (fileName?.trim() != '') {
                              RemoveTempFile().removeRecentTempFile(fileName: fileName ?? '');
                            }
                          },
                          onDocumentLoadFailed: (details) {
                            setState(() {
                              pdfErrorNotice = "Failed to load PDF preview: ${details.description}";
                              filePath = '';
                              isPdfLoading = false;
                            });
                          },
                          initialZoomLevel: 0.8,
                          enableDoubleTapZooming: true,
                          filePath ?? '',
                          key: _pdfViewerKey,
                          controller: _pdfViewerController,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 14 : 32,
                        vertical: isMobile ? 14 : 20,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 880),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (pdfErrorNotice != null)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: const Color(0xFFFCD34D)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info_outline,
                                          size: 20, color: Color(0xFFB45309)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          pdfErrorNotice!,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: Color(0xFF92400E),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () {
                                          if (createdRequestId != null &&
                                              createdRequestId!.isNotEmpty) {
                                            setState(() {
                                              isPdfLoading = true;
                                              pdfErrorNotice = null;
                                            });
                                            _fetchPreviewPdf(createdRequestId!);
                                          } else {
                                            _autoCreateOrUpdateDraftAndFetchPreview();
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFB45309),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            "Retry",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                        // Order Summary Card
                        _buildSummaryCard(isMobile),

                        const SizedBox(height: 20),

                        // Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'REQUESTED ITEMS (${itemsList.length})',
                              style: TextStyle(
                                fontSize: isMobile ? 13.5 : 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${itemsList.length} Total',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // List of Items
                        if (itemsList.isEmpty)
                          Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(
                                child: Text(
                                  'No item details available.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          )
                        else
                          for (int i = 0; i < itemsList.length; i++)
                            _buildItemCard(itemsList[i], i, isMobile),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),

        // Bottom Bar with Dual Capsule Buttons
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 32,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Edit Order Button
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: _handleBackNavigation,
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.black87, width: 1.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.edit_outlined, size: 16, color: Colors.black87),
                          SizedBox(width: 6),
                          Text(
                            "EDIT ORDER",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Submit Button
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: isPdfLoading ? null : _showConfirmationDialog,
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: isPdfLoading ? Colors.grey.shade400 : Colors.black,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: isPdfLoading
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle_outline,
                              size: 17, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            "SUBMIT ORDER",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  // Summary Card
  Widget _buildSummaryCard(bool isMobile) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.projectName?.toUpperCase() ?? 'PROJECT',
                        style: TextStyle(
                          fontSize: isMobile ? 15 : 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (widget.towarName != null &&
                          widget.towarName!.trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          widget.towarName!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "PURCHASE ORDER",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 12),

            // Total Estimated Amount Highlight
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Estimated Amount',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF166534),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '₹ ${widget.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ],
              ),
            ),

            if (widget.strRemark != null &&
                widget.strRemark!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes, size: 16, color: Colors.black54),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Remarks: ${widget.strRemark!}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (widget.arrayFiles.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final file in widget.arrayFiles)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            file.extension == 'pdf'
                                ? Icons.picture_as_pdf
                                : Icons.image,
                            size: 13,
                            color: file.extension == 'pdf'
                                ? Colors.red
                                : Colors.blueGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            file.name,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Item Card
  Widget _buildItemCard(dynamic item, int index, bool isMobile) {
    final gradeName = item['grade_type_name'] ?? 'Item #${index + 1}';
    final desc = item['description']?.toString() ?? '';
    final qty = item['quantity']?.toString() ?? '0';
    final unit = item['casting_unit_name']?.toString() ?? '';
    final price = item['unit_price']?.toString() ?? '';
    final total = item['total_amount']?.toString() ?? '0';
    final forLocation = item['casting_for']?.toString() ?? '';
    final reqDate = item['casting_date']?.toString() ?? '';
    final brand = item['brand_supplier_name']?.toString() ?? '';

    return Card(
      color: Colors.white,
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Title & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      gradeName,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹ $total',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            if (desc.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4B5563),
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Chips Row: Qty, Rate, Location, Date, Brand
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildPill(
                  icon: Icons.inventory_2_outlined,
                  text: '$qty $unit',
                  bg: const Color(0xFFF9FAFB),
                ),
                if (price.isNotEmpty)
                  _buildPill(
                    icon: Icons.currency_rupee,
                    text: '₹$price / $unit',
                    bg: const Color(0xFFF9FAFB),
                  ),
                if (forLocation.isNotEmpty)
                  _buildPill(
                    icon: Icons.apartment_outlined,
                    text: forLocation,
                    bg: const Color(0xFFEFF6FF),
                    fg: const Color(0xFF1E40AF),
                  ),
                if (reqDate.isNotEmpty)
                  _buildPill(
                    icon: Icons.calendar_today_outlined,
                    text: reqDate,
                    bg: const Color(0xFFFEF3C7),
                    fg: const Color(0xFF92400E),
                  ),
                if (brand.isNotEmpty)
                  _buildPill(
                    icon: Icons.branding_watermark_outlined,
                    text: brand,
                    bg: const Color(0xFFF3F4F6),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String text,
    Color bg = const Color(0xFFF3F4F6),
    Color fg = const Color(0xFF374151),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.5, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
