import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/drawing_details.dart';
import 'package:stallion/models/get_project_masonry.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/views/rccstructure/common/rcc_mock_data.dart';
import 'package:stallion/ui/views/rccstructure/rcc_skeleton_loader.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';

class RevisionRccStructerView extends StatefulWidget {
  const RevisionRccStructerView({
    Key? key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    this.projectSubTitle,
    required this.documentPath,
    this.drawingId,
    this.slabId,
    this.drawingVersion,
  }) : super(key: key);

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? projectSubTitle;
  final List<DrawingVersion>? drawingVersion;
  final String documentPath;
  final String? drawingId;
  final String? slabId;

  @override
  State<RevisionRccStructerView> createState() =>
      _RevisionRccStructerViewState();
}

class _RevisionRccStructerViewState extends State<RevisionRccStructerView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  List<DrawingVersion>? drawings = [];
  String? documentPath = '';
  String? drawingFlag = '';
  bool isLoading = true;
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    if (widget.drawingVersion != null && widget.drawingVersion!.isNotEmpty) {
      drawings = widget.drawingVersion;
      documentPath = widget.documentPath;
      isLoading = false;
    } else {
      fetchDrawingsDetails();
    }
  }

  bool _hasVersionData(DrawingVersion v) {
    final bool hasPdf = v.pdf != null && v.pdf!.isNotEmpty;
    final bool hasDwg = v.dwg != null && v.dwg!.isNotEmpty;
    final bool hasPdfRemark =
        v.pdfRemark != null && v.pdfRemark!.trim().isNotEmpty;
    final bool hasDwgRemark =
        v.dwgRemark != null && v.dwgRemark!.trim().isNotEmpty;
    return hasPdf || hasDwg || hasPdfRemark || hasDwgRemark;
  }

  List<DrawingVersion> _getFilteredDrawings(List<DrawingVersion>? rawDrawings) {
    if (rawDrawings == null || rawDrawings.isEmpty) return [];
    final list = List<DrawingVersion>.from(rawDrawings);
    while (list.isNotEmpty && !_hasVersionData(list.last)) {
      list.removeLast();
    }
    return list;
  }

  Future<List<DrawingVersion>?> fetchDrawingsDetails() async {
    if (!mounted) return null;
    setState(() {
      isLoading = true;
    });

    if (useRccMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return null;
      final mockRes = getMockRevisionData(
        drawingId: widget.drawingId,
        slabId: widget.slabId,
        documentPath: widget.documentPath,
      );
      setState(() {
        drawings = mockRes.drawings;
        documentPath = mockRes.documentPath;
        drawingFlag = mockRes.drawingFlag;
        isLoading = false;
      });
      return drawings;
    }

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "slab_id": widget.slabId ?? '',
      "drawing_id": widget.drawingId ?? '',
      "user_id": userId ?? '',
      "towar_id": widget.towarId ?? '',
      "project_id": widget.projectId ?? '',
    };
    Map<String, String> masonryData = {
      "masnory_id": widget.slabId ?? '',
      "drawing_id": widget.drawingId ?? '',
      "user_id": userId ?? '',
      "towar_id": widget.towarId ?? '',
      "project_id": widget.projectId ?? '',
    };

    if (kDebugMode) {
      print("Fetching Revision Details Data: ${widget.documentPath == "RCC" ? data : masonryData}");
    }

    try {
      var response = await apiNetworkHandler.post(
          widget.documentPath == "RCC"
              ? AppUrl.wsProjectRccSlabDetailsNew
              : AppUrl.wsProjectMasonrySlabDetailsNew,
          widget.documentPath == "RCC" ? data : masonryData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = drawingDetailsFromJson(response.body);

        if (dataModel.response?.errorCode == "0") {
          if (mounted) {
            setState(() {
              drawings = dataModel.response?.drawings;
              documentPath = dataModel.response?.documentPath;
              drawingFlag = dataModel.response?.drawingFlag;
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print("Fetch Revision Details Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
    return drawings;
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
    return 'R.C.C STRUCTURE';
  }

  String getSubHeaderTitle() {
    if (widget.projectSubTitle != null && widget.projectSubTitle!.trim().isNotEmpty) {
      return widget.projectSubTitle!.trim().toUpperCase();
    }
    return 'REVISION DETAILS';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final displayDrawings = _getFilteredDrawings(drawings);

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
            fontStyle: FontStyle.normal,
            fontSize: isMobile ? 14.0 : 17.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header bar showing Slab Name and Drawing Name
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 40, vertical: 8),
              color: Colors.white,
              width: double.infinity,
              child: Center(
                child: Text(
                  getSubHeaderTitle(),
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Divider(height: 1.0, color: Colors.black),

            // Content List or Skeleton Loader
            Expanded(
              child: isLoading
                  ? RevisionSkeletonScreen(isMobile: isMobile)
                  : displayDrawings.isNotEmpty
                      ? ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12.0 : 24.0,
                            vertical: isMobile ? 8.0 : 16.0,
                          ),
                          itemCount: displayDrawings.length,
                          itemBuilder: (BuildContext context, int index) {
                            final isExpanded = _expandedIndex == index;
                            return MyExpandableWidget(
                              key: ValueKey('tile_${index}_$isExpanded'),
                              details: displayDrawings[index],
                              documentPath: widget.documentPath,
                              drawingFlag: drawingFlag,
                              index: index,
                              drawings: displayDrawings,
                              isMobile: isMobile,
                              isExpanded: isExpanded,
                              onExpansionChanged: (expanded) {
                                setState(() {
                                  _expandedIndex = expanded ? index : null;
                                });
                              },
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            "No Revision Details Found",
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyExpandableWidget extends StatelessWidget {
  final DrawingVersion details;
  final String? documentPath;
  final String? drawingFlag;
  final int index;
  final List<DrawingVersion> drawings;
  final bool isMobile;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  const MyExpandableWidget({
    Key? key,
    required this.details,
    this.documentPath,
    this.drawingFlag,
    required this.index,
    required this.drawings,
    required this.isMobile,
    required this.isExpanded,
    required this.onExpansionChanged,
  }) : super(key: key);

  String _formatVersionName(String? name, int index) {
    final raw = name?.trim() ?? '';
    final match = RegExp(r'(\d+)').firstMatch(raw);
    if (match != null) {
      final num = int.tryParse(match.group(1)!);
      if (num == 0) {
        return 'Original Drawing';
      }
      if (num != null) {
        return 'Revision $num';
      }
    }

    if (raw.toLowerCase().contains('version 0') ||
        raw == '0' ||
        (raw.isEmpty && index == 0)) {
      return 'Original Drawing';
    }

    if (raw.toLowerCase().startsWith('version')) {
      return raw.replaceFirst(RegExp(r'^[Vv]ersion\s*'), 'Revision ');
    }

    if (raw.isNotEmpty) {
      return raw;
    }

    return index == 0 ? 'Original Drawing' : 'Revision $index';
  }

  @override
  Widget build(BuildContext context) {
    List<PdfElement> arrFiles = [];

    if (details.pdf != null) {
      for (int i = 0; i < details.pdf!.length; i++) {
        arrFiles.add(details.pdf![i]);
      }
    }

    if (details.dwg != null) {
      for (int i = 0; i < details.dwg!.length; i++) {
        arrFiles.add(details.dwg![i]);
      }
    }

    double opacityCalculate() {
      if (drawings.length - 1 == index) {
        return 1.0;
      } else {
        if (drawingFlag == "0") {
          return 0.5;
        } else {
          return 1.0;
        }
      }
    }

    final double calculatedOpacity = opacityCalculate();
    final baseTextStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 10.0 : 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xffe9ecef),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: Key('expansion_tile_${index}_$isExpanded'),
          initiallyExpanded: isExpanded,
          onExpansionChanged: onExpansionChanged,
          tilePadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12.0 : 18.0,
            vertical: isMobile ? 4.0 : 8.0,
          ),
          childrenPadding: EdgeInsets.only(
            left: isMobile ? 8.0 : 14.0,
            right: isMobile ? 8.0 : 14.0,
            bottom: isMobile ? 10.0 : 14.0,
          ),
          title: Opacity(
            opacity: calculatedOpacity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 10 : 14,
                        vertical: isMobile ? 3 : 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatVersionName(details.name, index),
                        style: baseTextStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 12 : 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 6 : 8),
                Text.rich(
                  TextSpan(
                    style: baseTextStyle.copyWith(
                      fontSize: isMobile ? 13 : 15,
                      height: 1.3,
                    ),
                    children: <TextSpan>[
                      const TextSpan(
                        text: 'Pdf Remark : ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: details.pdfRemark?.trim() ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 4 : 6),
                Text.rich(
                  TextSpan(
                    style: baseTextStyle.copyWith(
                      fontSize: isMobile ? 13 : 15,
                      height: 1.3,
                    ),
                    children: <TextSpan>[
                      const TextSpan(
                        text: 'Dwg Remark : ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: details.dwgRemark?.trim() ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          children: calculatedOpacity >= 0.5
              ? arrFiles
                  .map<Widget>((club) => showClubs(club, context, isMobile))
                  .toList()
              : [],
        ),
      ),
    );
  }

  Widget showClubs(PdfElement details, BuildContext context, bool isMobile) {
    final String rawName = details.documentName?.isNotEmpty == true
        ? details.documentName!
        : (details.slabDrawingImgName ?? '');
    final String displayName = rawName.startsWith('http')
        ? Uri.parse(rawName).path.split('/').last
        : (rawName.isNotEmpty ? rawName : 'Drawing File');

    final bool isPdf = displayName.toLowerCase().endsWith('.pdf') ||
        (details.fileUrl?.toLowerCase().contains('.pdf') ?? false);
    final baseTextStyle =
        Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

    final String targetUrl = details.fileUrl?.isNotEmpty == true
        ? details.fileUrl!
        : (details.slabDrawingImgName?.startsWith('http') == true
            ? details.slabDrawingImgName!
            : (isPdf
                ? ((documentPath == 'MASONRY'
                        ? AppUrl.getProjectMasnoryRevisionFileUrl
                        : AppUrl.getProjectRccRevisionFileUrl) +
                    (details.slabDrawingImgName ?? ''))
                : '${AppUrl.globalDwg}${details.slabDrawingImgName}'));

    return Container(
      margin: EdgeInsets.only(top: isMobile ? 6.0 : 8.0),
      decoration: BoxDecoration(
        color: const Color(0xfff8f9fa),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffe9ecef)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            if (isPdf) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return PdfViewer(
                      fileName: displayName,
                      fileUrl: targetUrl,
                    );
                  },
                ),
              );
            } else {
              final uri = Uri.parse(targetUrl);
              try {
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  _showErrorDialog(
                      context, isMobile, "Could not download DWG file.");
                }
              } catch (e) {
                _showErrorDialog(
                    context, isMobile, "Could not launch file: $e");
              }
            }
          },
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 10.0 : 14.0),
            child: Row(
              children: [
                // File Icon / Badge
                Container(
                  width: isMobile ? 38.0 : 46.0,
                  height: isMobile ? 38.0 : 46.0,
                  decoration: BoxDecoration(
                    color: isPdf ? Colors.red.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Image.asset(
                      isPdf
                          ? 'images/projectmanagement/pdf.png'
                          : 'images/projectmanagement/dwg.png',
                      width: isMobile ? 28.0 : 34.0,
                      height: isMobile ? 28.0 : 34.0,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          isPdf
                              ? Icons.picture_as_pdf_rounded
                              : Icons.architecture_rounded,
                          color: isPdf ? Colors.red : Colors.blue,
                          size: isMobile ? 22 : 26,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 10.0 : 14.0),
                // File Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: baseTextStyle.copyWith(
                          fontSize: isMobile ? 13 : 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (details.drawingDate != null &&
                          details.drawingDate!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          formatDateToDdMmYyyy(details.drawingDate!),
                          style: baseTextStyle.copyWith(
                            fontSize: isMobile ? 11 : 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: isMobile ? 8.0 : 12.0),
                // Capsule Button Action
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: isPdf ? Colors.black : const Color(0xff1d2d50),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPdf
                            ? Icons.visibility_outlined
                            : Icons.download_rounded,
                        color: Colors.white,
                        size: isMobile ? 13 : 16,
                      ),
                      SizedBox(width: isMobile ? 4 : 6),
                      Text(
                        isPdf ? "View PDF" : "Download",
                        style: baseTextStyle.copyWith(
                          fontSize: isMobile ? 11 : 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, bool isMobile, String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final baseStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          titlePadding: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: isMobile ? 16 : 24,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: 8,
          ),
          actionsPadding: const EdgeInsets.all(12),
          actionsAlignment: MainAxisAlignment.center,
          title: Text(
            "Notice",
            style: baseStyle.copyWith(
              fontSize: isMobile ? 15 : 17,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            style: baseStyle.copyWith(
              fontSize: isMobile ? 13 : 15,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: isMobile ? 160 : 220,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Okay",
                  style: baseStyle.copyWith(
                    fontSize: isMobile ? 13 : 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

String formatDateToDdMmYyyy(String? dateStr) {
  if (dateStr == null || dateStr.trim().isEmpty) return '';
  final cleaned = dateStr.trim();
  try {
    final dt = DateTime.parse(cleaned);
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month/${dt.year}';
  } catch (_) {}

  try {
    final rawDate = cleaned.contains('T') ? cleaned.split('T')[0] : cleaned;
    final parts = rawDate.split('-');
    if (parts.length == 3 && parts[0].length == 4) {
      return '${parts[2].padLeft(2, '0')}/${parts[1].padLeft(2, '0')}/${parts[0]}';
    }
  } catch (_) {}

  return cleaned;
}
