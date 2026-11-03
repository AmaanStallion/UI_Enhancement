import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stallion/models/get_excavation_list.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/views/rccstructure/rcc_skeleton_loader.dart';
import 'package:stallion/ui/widgets/row_three_text.dart';
import 'package:stallion/ui/widgets/stallion_video_player.dart';

import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';

class ExcavationDetailPage extends StatefulWidget {
  const ExcavationDetailPage({
    Key? key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.title,
    this.slabId,
    this.dataa,
    this.towarName,
  }) : super(key: key);

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? title;
  final String? slabId;
  final FinalExcavalionList? dataa;

  @override
  State<ExcavationDetailPage> createState() => _ExcavationDetailPageState();
}

class _ExcavationDetailPageState extends State<ExcavationDetailPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  String getAppBarTitle() {
    final pName = widget.projectName?.trim().toUpperCase() ?? '';
    final tName = widget.towarName?.trim().toUpperCase() ?? '';

    if (pName.isNotEmpty && tName.isNotEmpty) {
      return '$pName - $tName';
    } else if (pName.isNotEmpty) {
      return pName;
    } else if (tName.isNotEmpty) {
      return tName;
    }
    return 'EXCAVATION DETAILS';
  }

  String getSubHeaderTitle() {
    final slabTitle = widget.title?.trim().toUpperCase() ?? 'SLAB';
    return '$slabTitle - EXCAVATION DETAILS';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final baseStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

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
            fontSize: isMobile ? 14.0 : 17.0,
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
      body: SafeArea(
        child: Column(
          children: [
            // SubHeader Bar: SLAB NAME - EXCAVATION DETAILS
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 10 : 14,
              ),
              color: Colors.white,
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
            const Divider(height: 1.0, color: Colors.black12),

            // Detail Card Body
            Expanded(
              child: isLoading
                  ? ExcavationDetailSkeletonScreen(isMobile: isMobile)
                  : SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12.0 : 24.0,
                        vertical: isMobile ? 12.0 : 16.0,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: widget.dataa != null
                            ? buildDetailCard(
                                data: widget.dataa!,
                                isMobile: isMobile,
                                baseStyle: baseStyle,
                              )
                            : Center(
                                child: Text(
                                  "No Excavation Details Found",
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String formatShiftDateTime(String? dateVal, String? timeVal) {
    if ((dateVal == null || dateVal.trim().isEmpty) &&
        (timeVal == null || timeVal.trim().isEmpty)) {
      return '';
    }

    String rawDate = dateVal?.trim() ?? '';
    String rawTime = timeVal?.trim() ?? '';

    if (rawDate.isEmpty) {
      return rawTime;
    }

    // Try parsing ISO or standard date-time string
    DateTime? parsedDt = DateTime.tryParse(rawDate);
    if (parsedDt != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDt);
      String extractedTime = '';
      if (parsedDt.hour != 0 || parsedDt.minute != 0 || parsedDt.second != 0) {
        extractedTime = DateFormat('hh:mm a').format(parsedDt);
      }
      String finalTime = rawTime.isNotEmpty ? rawTime : extractedTime;
      return finalTime.isNotEmpty ? '$formattedDate $finalTime' : formattedDate;
    }

    // Match yyyy-MM-dd date patterns (e.g. 2026-09-07 or 2026/09/07)
    final ymdReg = RegExp(r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})');
    final match = ymdReg.firstMatch(rawDate);
    if (match != null) {
      String y = match.group(1)!;
      String m = match.group(2)!.padLeft(2, '0');
      String d = match.group(3)!.padLeft(2, '0');
      String formattedDate = '$d-$m-$y';

      String remainingStr = rawDate.substring(match.end).trim();
      String finalTime = rawTime.isNotEmpty ? rawTime : remainingStr;
      return finalTime.isNotEmpty ? '$formattedDate $finalTime' : formattedDate;
    }

    // Fallback: if already dd-MM-yyyy or arbitrary string
    if (rawTime.isNotEmpty && !rawDate.contains(rawTime)) {
      return '$rawDate $rawTime';
    }
    return rawDate;
  }

  Widget buildDetailCard({
    required FinalExcavalionList data,
    required bool isMobile,
    required TextStyle baseStyle,
  }) {
    final bool isDumper = data.vehicelType == "4" ||
        (data.vehilceTypeName ?? "").toLowerCase().contains("dumper") ||
        data.vehicelType == "3";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe9ecef)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Title & Vehicle Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.vehilceTypeName ?? "Vehicle Entry",
                style: baseStyle.copyWith(
                  fontSize: isMobile ? 15 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              if (!isDumper && data.vehicelNo != null && data.vehicelNo!.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10 : 14,
                    vertical: isMobile ? 3 : 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    data.vehicelNo!,
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xfff1f3f5)),
          const SizedBox(height: 12),

          // Complete List of Detail Rows
          buildDetailRow("Vehicle Type", data.vehilceTypeName, isMobile, baseStyle),

          if (isDumper) ...[
            buildDetailRow("Vehicle Number", data.vehicelNo ?? "--", isMobile, baseStyle),
            buildDetailRow("Truck Size", data.truckSizeName, isMobile, baseStyle),
            buildDetailRow("CUM Loaded", data.cumLoadValue, isMobile, baseStyle),
            buildDetailRow("Type", data.typeRoyalityName, isMobile, baseStyle),
          ],

          if (!isDumper) ...[
            buildDetailRow(
              "Shift Start Date & Time",
              formatShiftDateTime(data.shiftStartDate, data.shiftStartTime),
              isMobile,
              baseStyle,
            ),
            buildDetailRow(
              "Shift End Date & Time",
              formatShiftDateTime(data.shiftEndDate, data.shiftEndTime),
              isMobile,
              baseStyle,
            ),
            buildDetailRow("Shift Required", data.shiftRequired, isMobile, baseStyle),
            buildDetailRow(
              "Hiring Charges",
              data.hiringCharges != null
                  ? currencyFormat.format(double.tryParse(data.hiringCharges!) ?? 0)
                  : null,
              isMobile,
              baseStyle,
            ),
          ],

          buildDetailRow("Royalty Challan No", data.excavationChallanNo, isMobile, baseStyle),
          buildDetailRow("Used For", data.excavationUsedFor ?? data.fromExcavation, isMobile, baseStyle),
          buildDetailRow(
            "Date & Updated By",
            data.excavationUpdatedAt != null
                ? '${DateFormat('dd-MM-yyyy').format(data.excavationUpdatedAt!)} by ${data.userName ?? 'System'}'
                : (data.userName != null ? 'By ${data.userName}' : null),
            isMobile,
            baseStyle,
          ),
          buildDetailRow("Remark", data.excavationRemark, isMobile, baseStyle),

          // Uploaded Challan Documents Section
          if ((data.rawDocuments != null && data.rawDocuments!.isNotEmpty) ||
              (data.chalanDocument != null && data.chalanDocument!.isNotEmpty)) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xfff1f3f5)),
            const SizedBox(height: 12),
            Text(
              "Uploaded Challan Documents",
              style: baseStyle.copyWith(
                fontSize: isMobile ? 13 : 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (data.rawDocuments != null && data.rawDocuments!.isNotEmpty) ...[
                  for (final doc in data.rawDocuments!)
                    buildDocumentPreviewCard(
                      fileString: doc.fileUrl ?? doc.fileKey ?? doc.fileName ?? '',
                      explicitFileName: doc.fileName,
                      isMobile: isMobile,
                    ),
                ] else if (data.chalanDocument != null) ...[
                  for (int k = 0; k < data.chalanDocument!.length; k++)
                    buildDocumentPreviewCard(
                      fileString: data.chalanDocument![k].toString(),
                      isMobile: isMobile,
                    ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget buildDetailRow(String label, String? value, bool isMobile, TextStyle baseStyle) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isMobile ? 140 : 200,
            child: Text(
              label,
              style: baseStyle.copyWith(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: baseStyle.copyWith(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDocumentPreviewCard({
    required String fileString,
    String? explicitFileName,
    required bool isMobile,
  }) {
    // 1. Format full URL
    final String fullUrl = (fileString.startsWith('http://') || fileString.startsWith('https://'))
        ? fileString
        : '${AppUrl.EXCAVATIONpath}$fileString';

    // 2. Extract clean file name (prefer explicit file_name from API, fallback to URL path parsing)
    String fileName = (explicitFileName != null && explicitFileName.trim().isNotEmpty)
        ? explicitFileName.trim()
        : '';

    if (fileName.isEmpty) {
      fileName = fileString;
      try {
        final Uri uri = Uri.parse(fileString);
        final String path = uri.path;
        if (path.isNotEmpty) {
          final segments = path.split('/');
          final lastSegment = segments.lastWhere((s) => s.isNotEmpty, orElse: () => '');
          if (lastSegment.isNotEmpty) {
            fileName = Uri.decodeComponent(lastSegment);
          }
        }
      } catch (_) {}
    }
    if (fileName.isEmpty) fileName = fileString;

    // 3. Determine file type from clean fileName
    final String lowerName = fileName.toLowerCase();
    final bool isPdf = lowerName.endsWith('.pdf');
    final bool isVideo = lowerName.endsWith('.mp4') ||
        lowerName.endsWith('.mov') ||
        lowerName.endsWith('.m4v') ||
        lowerName.endsWith('.avi') ||
        lowerName.endsWith('.mkv') ||
        lowerName.endsWith('.3gp') ||
        lowerName.endsWith('.webm');

    return InkWell(
      onTap: () {
        if (isVideo) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StallionVideoPlayer(
                documentName: fileName,
                fileUrl: fullUrl,
              ),
            ),
          );
        } else if (isPdf) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PdfViewer(
                fileName: fileName,
                fileUrl: fullUrl,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImagePreviewViewer(
                fileName: fileName,
                fileUrl: fullUrl,
              ),
            ),
          );
        }
      },
      child: Container(
        width: isMobile ? 110 : 130,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xfff8f9fa),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xffdee2e6)),
        ),
        child: Column(
          children: [
            if (isPdf)
              Image.asset(
                'images/projectmanagement/pdf.png',
                width: isMobile ? 60 : 80,
                height: isMobile ? 60 : 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: isMobile ? 60 : 80,
                  height: isMobile ? 60 : 80,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red,
                    size: isMobile ? 36 : 44,
                  ),
                ),
              )
            else if (isVideo)
              Container(
                width: isMobile ? 60 : 80,
                height: isMobile ? 60 : 80,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: isMobile ? 32 : 40,
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  fullUrl,
                  width: isMobile ? 60 : 80,
                  height: isMobile ? 60 : 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: isMobile ? 60 : 80,
                    height: isMobile ? 60 : 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              fileName,
              style: TextStyle(
                fontSize: isMobile ? 10 : 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

