import 'dart:convert';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/getAllSubLegal.dart';
import 'package:stallion/models/get_all_legal_response.dart';
import 'package:stallion/models/get_project_masonry.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:http/http.dart' as http;

class LegalDocsScreen extends StatefulWidget {
  const LegalDocsScreen(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      required this.legalId,
      this.towarName})
      : super(key: key);
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String legalId;

  @override
  State<LegalDocsScreen> createState() => _LegalDocsScreenState();
}

class _LegalDocsScreenState extends State<LegalDocsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController initiatedDateControler = TextEditingController();
  TextEditingController notifyDateControler = TextEditingController();
  TextEditingController addRemarkControler = TextEditingController();
  DateTime? _selectedInitiatedDate;
  DateTime? _selectedNotifyDate;
  TextEditingController editingController = TextEditingController();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  List<SubLegalDetail>? subLegalDetailsResponse = [];
  PlatformFile? arrayFiles;
  String offset = '0';
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  Uint8List? arrayFilesBytes;
  final Map<String, String> _subLegalRemarks = {};

  bool _isLoading = true;
  int _selectedCardIndex = -1;
  static const bool testWithMockData = false; // Enabled by default for direct offline visual testing

  List<SubLegalDetail> _allMockSubLegalDetails = [];

  void _initMockData() {
    _allMockSubLegalDetails = [
      SubLegalDetail(
        subLegalId: "1",
        subLegalName: "Trust Deed",
        subLegalStartDate: "07/07/2026",
        subLegalEndDate: "21/07/2026",
        isExpring: "0",
        uploadFlag: "1",
        documentPdf: "trust_deed.pdf",
        legalIdFk: widget.legalId,
        status: "active",
      ),
      SubLegalDetail(
        subLegalId: "2",
        subLegalName: "Resolution Copy",
        subLegalStartDate: "07/07/2026",
        subLegalEndDate: "14/07/2026",
        isExpring: "1",
        uploadFlag: "0",
        documentPdf: "",
        legalIdFk: widget.legalId,
        status: "active",
      ),
      SubLegalDetail(
        subLegalId: "3",
        subLegalName: "Consent Letter",
        subLegalStartDate: "",
        subLegalEndDate: "",
        isExpring: "0",
        uploadFlag: "0",
        documentPdf: "",
        legalIdFk: widget.legalId,
        status: "inactive",
      ),
    ];
  }

  List<SubLegalDetail> _sortSubLegalDetailsWithPriority(List<SubLegalDetail> list) {
    if (list.isEmpty) return list;

    int compareNames(SubLegalDetail a, SubLegalDetail b) {
      final nameA = (a.subLegalName ?? '').trim().toLowerCase();
      final nameB = (b.subLegalName ?? '').trim().toLowerCase();
      return nameA.compareTo(nameB);
    }

    final withTick = list.where((e) => e.uploadFlag == "1").toList()..sort(compareNames);
    final withoutTick = list.where((e) => e.uploadFlag != "1").toList()..sort(compareNames);

    return [
      ...withTick,
      ...withoutTick,
    ];
  }

  Future<List<MasonryDetail>?> fetchGetAllLegalDocs({bool isRefresh = false}) async {
    if (testWithMockData) {
      if (!isRefresh) {
        setState(() {
          _isLoading = true;
        });
      }
      await Future.delayed(const Duration(milliseconds: 800));

      List<SubLegalDetail> filtered = _allMockSubLegalDetails.where((e) {
        final String? status = e.status;
        if (status == null) return true;
        final String normalized = status.trim().toLowerCase();
        return normalized == 'active' || normalized == 'true' || normalized == '1';
      }).toList();

      final String query = editingController.text.trim().toLowerCase();
      if (query.isNotEmpty) {
        filtered = filtered.where((e) => (e.subLegalName ?? '').toLowerCase().contains(query)).toList();
      }

      filtered = _sortSubLegalDetailsWithPriority(filtered);

      setState(() {
        subLegalDetailsResponse = filtered;
        _isLoading = false;
      });
      return null;
    }

    try {
      final String? projectId = widget.projectId;
      final String? legalId = widget.legalId;

      if (projectId == null || projectId.isEmpty || legalId == null || legalId.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return null;
      }

      await apiNetworkHandler.ensureProjectContext(projectId);

      if (!isRefresh) {
        setState(() {
          _isLoading = true;
        });
      }

      String requestUrl = "${AppUrl.baseURL}legal-permissions/projects/$projectId/$legalId/files";

      var response = await apiNetworkHandler.get(requestUrl);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          var subDocs = [];
          if (decoded['data']['subDocuments'] is List) {
            subDocs = decoded['data']['subDocuments'];
          }
          List<SubLegalDetail> allSubDetails = [];
          
          for (var sub in subDocs) {
            allSubDetails.add(SubLegalDetail(
              subLegalId: sub['id']?.toString() ?? sub['key'] ?? '',
              subLegalName: sub['name'] ?? '',
              subLegalStartDate: sub['start_date'] ?? '',
              subLegalEndDate: sub['end_date'] ?? '',
              subLegalLastUpdateDate: '',
              uploadFlag: (sub['url'] != null && (sub['url'] as String).isNotEmpty) ? "1" : "0",
              projectIdFk: widget.projectId,
              legalStatus: 'Pending',
              documentPdf: sub['url'] ?? '',
              isExpring: "0",
              legalIdFk: widget.legalId,
              status: (sub['status'] ?? sub['isActive'] ?? sub['is_active'])?.toString(),
            ));
          }

          // Filter out legacy duplicates: if a document has a numeric database ID, 
          // filter out any S3-only document (non-numeric ID) with the same name.
          List<SubLegalDetail> uniqueDetails = [];
          for (var detail in allSubDetails) {
            final bool isNumeric = RegExp(r'^\d+$').hasMatch(detail.subLegalId ?? '');
            if (!isNumeric) {
              bool hasNumericVersion = allSubDetails.any((e) =>
                  e.subLegalName == detail.subLegalName &&
                  RegExp(r'^\d+$').hasMatch(e.subLegalId ?? ''));
              if (hasNumericVersion) {
                continue;
              }
            }
            uniqueDetails.add(detail);
          }

          List<SubLegalDetail> filtered = uniqueDetails.where((e) {
            final String? status = e.status;
            if (status == null) return true; // Default to active if null (regression prevention)
            final String normalized = status.trim().toLowerCase();
            return normalized == 'active' || normalized == 'true' || normalized == '1';
          }).toList();

          final String query = editingController.text.trim().toLowerCase();
          if (query.isNotEmpty) {
            filtered = filtered.where((e) => (e.subLegalName ?? '').toLowerCase().contains(query)).toList();
          }

          filtered = _sortSubLegalDetailsWithPriority(filtered);

          setState(() {
            subLegalDetailsResponse = filtered;
          });
        } else {
        }
      } else {
      }
    } catch (e, stackTrace) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    return null;
  }

  Future<List<MasonryDetail>?> setNotifyDatelLegal(
      {required String projectLegalId}) async {
    if (testWithMockData) {
      String formatDate(DateTime dateTime) {
        return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
      }
      final target = _allMockSubLegalDetails.firstWhere(
        (e) => e.subLegalId == projectLegalId,
        orElse: () => _allMockSubLegalDetails[0],
      );
      target.subLegalStartDate = formatDate(_selectedInitiatedDate!);
      target.subLegalEndDate = formatDate(_selectedNotifyDate!);
      _subLegalRemarks[projectLegalId] = addRemarkControler.text;

      setState(() {
        offset = "0";
      });
      fetchGetAllLegalDocs();
      return null;
    }

    final SharedPreferences prefs = await _prefs;
    // All uploads inside a project MUST use the project token
    String? token = prefs.getString('projectToken') ?? prefs.getString('masterToken') ?? prefs.getString('token');

    final String url = "${AppUrl.baseURL}legal-permissions/projects/${widget.projectId}/documents/$projectLegalId";

    var request = http.MultipartRequest(
      'PUT',
      Uri.parse(url),
    );

    request.headers.addAll({
      if (token != null) 'Authorization': 'Bearer $token',
      'x-project-id': widget.projectId!,
    });

    String formatDate(DateTime dateTime) {
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    }

    final target = subLegalDetailsResponse!.firstWhere(
      (e) => e.subLegalId == projectLegalId,
    );

    request.fields['docname'] = target.subLegalName ?? '';
    request.fields['startDate'] = formatDate(_selectedInitiatedDate!);
    request.fields['endDate'] = formatDate(_selectedNotifyDate!);
    request.fields['isActive'] = "true";

    var response = await request.send();
    var responsed = await http.Response.fromStream(response);

    if (responsed.statusCode == 200 || responsed.statusCode == 201) {
      setState(() {
        offset = "0";
      });
      fetchGetAllLegalDocs();
    } else {
    }
    return null;
  }

  setuploadLegalDoc(
      {required String subLegalId, required BuildContext popContetx}) async {
    if (testWithMockData) {
      CustomLoading.progressDialog(isLoading: true, context: context);
      await Future.delayed(const Duration(milliseconds: 600));
      CustomLoading.progressDialog(isLoading: false, context: popContetx);

      final target = _allMockSubLegalDetails.firstWhere(
        (e) => e.subLegalId == subLegalId,
        orElse: () => _allMockSubLegalDetails[0],
      );
      target.uploadFlag = "1";
      if (arrayFiles != null) {
        target.documentPdf = arrayFiles!.name;
      }

      setState(() {
        offset = "0";
        arrayFiles = null;
        arrayFilesBytes = null;
      });



      fetchGetAllLegalDocs();
      return null;
    }

    final target = subLegalDetailsResponse!.firstWhere(
      (e) => e.subLegalId == subLegalId,
    );

    final String url = "${AppUrl.baseURL}legal-permissions/projects/${widget.projectId}/documents/$subLegalId";

    final SharedPreferences prefs = await _prefs;
    // All uploads inside a project MUST use the project token
    String? token = prefs.getString('projectToken') ?? prefs.getString('masterToken') ?? prefs.getString('token');

    var request = http.MultipartRequest('PUT', Uri.parse(url));

    request.headers.addAll({
      if (token != null) 'Authorization': 'Bearer $token',
      'x-project-id': widget.projectId!,
    });

    PlatformFile file = arrayFiles!;
    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        file.path.toString(),
      ),
    );

    request.fields['docname'] = target.subLegalName ?? '';
    request.fields['startDate'] = target.subLegalStartDate ?? '';
    request.fields['endDate'] = target.subLegalEndDate ?? '';
    request.fields['isActive'] = "true";

    var response = await request.send();
    var responsed = await http.Response.fromStream(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      CustomLoading.progressDialog(isLoading: false, context: popContetx);



      fetchGetAllLegalDocs();
      setState(() {
        arrayFiles = null;
        arrayFilesBytes = null;
      });
    } else {
      CustomLoading.progressDialog(isLoading: false, context: popContetx);
    }
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 100));
    offset = '0';
    fetchGetAllLegalDocs(isRefresh: true);
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 100));
    fetchGetAllLegalDocs(isRefresh: true);
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    if (testWithMockData) {
      _initMockData();
    }
    fetchGetAllLegalDocs();
    super.initState();
  }

  String formatDisplayDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "";
    try {
      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(rawDate)) {
        return rawDate;
      }
      DateTime parsed;
      if (rawDate.contains('-')) {
        parsed = DateTime.parse(rawDate);
      } else {
        var cleanDate = rawDate
            .replaceAll('st', '')
            .replaceAll('nd', '')
            .replaceAll('rd', '')
            .replaceAll('th', '');
        var parts = cleanDate.split('/');
        if (parts.length == 3) {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          parsed = DateTime(year, month, day);
        } else {
          parsed = DateFormat("d MMM yyyy").parse(cleanDate.trim());
        }
      }
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) {
      return rawDate;
    }
  }

  bool isDatePassed(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return false;
    try {
      DateTime parsed;
      if (dateStr.contains('-')) {
        parsed = DateTime.parse(dateStr);
      } else {
        var cleanDate = dateStr
            .replaceAll('st', '')
            .replaceAll('nd', '')
            .replaceAll('rd', '')
            .replaceAll('th', '');
        var parts = cleanDate.split('/');
        if (parts.length == 3) {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          parsed = DateTime(year, month, day);
        } else {
          parsed = DateFormat("d MMM yyyy").parse(cleanDate.trim());
        }
      }
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final compareDate = DateTime(parsed.year, parsed.month, parsed.day);
      return today.isAfter(compareDate);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            widget.towarName != null && widget.towarName!.isNotEmpty
                ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                : widget.projectName!.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'HelveticaNeue',
              fontWeight: FontWeight.w700,
              fontSize: 16.0,
              letterSpacing: 0.2,
            )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.0),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Search box (Pill Input)
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 2),
            child: SizedBox(
              height: 38,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xfff8f9fa),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffe0e0e0)),
                ),
                child: TextField(
                  onChanged: (value) {
                    fetchGetAllLegalDocs();
                  },
                  style: const TextStyle(
                    fontFamily: 'HelveticaNeue',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  controller: editingController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                    hintText: "Search by Name",
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                    suffixIcon: editingController.text.isNotEmpty
                        ? InkWell(
                            onTap: () {
                              editingController.clear();
                              fetchGetAllLegalDocs();
                            },
                            child: const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
                          )
                        : const SizedBox.shrink(),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          const Divider(color: Color(0xfff0f0f0), height: 1.0),
          Expanded(
            child: _isLoading
                ? CustomLoading.buildLegalDocsSkeletonInline(context)
                : subLegalDetailsResponse!.isNotEmpty
                    ? SmartRefresher(
                        enablePullDown: true,
                        enablePullUp: true,
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        onLoading: _onLoading,
                        footer: const ClassicFooter(
                            loadStyle: LoadStyle.ShowWhenLoading),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            shrinkWrap: true,
                            itemCount: subLegalDetailsResponse!.length,
                            itemBuilder: (context, index) {
                              SubLegalDetail tempp =
                                  subLegalDetailsResponse![index];
                               return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedCardIndex = index;
                                  });
                                  if (tempp.documentPdf != null && tempp.documentPdf!.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return PdfViewer(
                                            fileName: tempp.subLegalName ?? "Document.pdf",
                                            fileUrl: tempp.documentPdf!,
                                          );
                                        },
                                      ),
                                    );
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: tempp.uploadFlag == "1" ? Colors.white : const Color(0xfff8f9fa),
                                    borderRadius: BorderRadius.circular(14.0),
                                    border: Border.all(color: _selectedCardIndex == index ? const Color(0xffd6d6d6) : const Color(0xfff0f0f0), width: 1.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.015),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      )
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: AppText(
                                                      title: tempp.subLegalName ?? '',
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w700,
                                                      overflow: TextOverflow.visible,
                                                    ),
                                                  ),
                                                  if (tempp.uploadFlag == "1") ...[
                                                    const SizedBox(width: 8),
                                                    const Icon(Icons.check_circle,
                                                        color: Colors.green, size: 18),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            // Set Notify Date Pill
                                             InkWell(
                                               onTap: () {
                                                 initiatedDateControler.text = formatDisplayDate(tempp.subLegalStartDate);
                                                 notifyDateControler.text = formatDisplayDate(tempp.subLegalEndDate);
                                                 addRemarkControler.text = _subLegalRemarks[tempp.subLegalId] ?? "";

                                                 DateTime? parseDateHelper(String? dateStr) {
                                                   if (dateStr == null || dateStr.isEmpty) return null;
                                                   try {
                                                     if (dateStr.contains('-')) {
                                                       return DateTime.parse(dateStr);
                                                     }
                                                     var cleanDate = dateStr
                                                         .replaceAll('st', '')
                                                         .replaceAll('nd', '')
                                                         .replaceAll('rd', '')
                                                         .replaceAll('th', '');
                                                     var parts = cleanDate.split('/');
                                                     if (parts.length == 3) {
                                                       int day = int.parse(parts[0]);
                                                       int month = int.parse(parts[1]);
                                                       int year = int.parse(parts[2]);
                                                       return DateTime(year, month, day);
                                                     }
                                                     return DateFormat("d MMM yyyy").parse(cleanDate.trim());
                                                   } catch (_) {
                                                     return null;
                                                   }
                                                 }
                                                 _selectedInitiatedDate = parseDateHelper(tempp.subLegalStartDate);
                                                 _selectedNotifyDate = parseDateHelper(tempp.subLegalEndDate);

                                                 setNotifyDateRemarkModal(data: tempp);
                                               },
                                               child: Container(
                                                padding: isMobile
                                                    ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0)
                                                    : const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      color: isDatePassed(tempp.subLegalEndDate)
                                                          ? Colors.red
                                                          : Colors.black),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_month_outlined,
                                                      size: isMobile ? 12 : 14,
                                                      color: isDatePassed(tempp.subLegalEndDate)
                                                          ? Colors.red
                                                          : Colors.black,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      tempp.subLegalEndDate == null || tempp.subLegalEndDate == ""
                                                          ? "Set Notify Date"
                                                          : "Notify On - ${formatDisplayDate(tempp.subLegalEndDate)}",
                                                      style: TextStyle(
                                                          fontFamily: 'HelveticaNeue',
                                                          fontSize: isMobile ? 11 : 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: isDatePassed(tempp.subLegalEndDate)
                                                              ? Colors.red
                                                              : Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            // Upload button Pill
                                            InkWell(
                                              onTap: () async {
                                                FilePickerResult? result =
                                                    await FilePicker.platform
                                                        .pickFiles(
                                                  type: FileType.custom,
                                                  allowedExtensions: ['pdf'],
                                                );
                                                if (result != null) {
                                                  PlatformFile file =
                                                      result.files.first;
                                                  if (!file.name.toLowerCase().endsWith('.pdf')) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text("Only PDF files are allowed"),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  Uint8List? fileBytes =
                                                      result.files.first.bytes;
                                                  setState(() {
                                                    arrayFiles = file;
                                                    arrayFilesBytes = fileBytes;
                                                    CustomLoading.progressDialog(
                                                        isLoading: true,
                                                        context: context);
                                                    setuploadLegalDoc(
                                                        popContetx: context,
                                                        subLegalId:
                                                            tempp.subLegalId ?? '');
                                                  });
                                                }
                                              },
                                              child: Container(
                                                padding: isMobile
                                                    ? const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0)
                                                    : const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(color: Colors.black),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.upload_file_rounded, size: isMobile ? 12 : 14, color: Colors.black),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "Upload",
                                                      style: TextStyle(
                                                        fontFamily: 'HelveticaNeue',
                                                        fontSize: isMobile ? 11 : 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  const TextSpan(
                                                    text: 'Initiated On - ',
                                                    style: TextStyle(
                                                      fontFamily: 'HelveticaNeue',
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: formatDisplayDate(tempp.subLegalStartDate),
                                                    style: const TextStyle(
                                                      fontFamily: 'HelveticaNeue',
                                                      fontWeight: FontWeight.normal,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              style: TextStyle(
                                                fontSize: isMobile ? 11 : 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      )
                    : const Center(
                        child: Text(
                          "No Record Found",
                          style: TextStyle(
                            fontFamily: 'HelveticaNeue',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  setNotifyDateRemarkModal({required SubLegalDetail data}) {
    final bool isMobile = context.isMobile;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (context1, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                child: const Text(
                  "Set Notify Date",
                  style: TextStyle(
                    fontFamily: 'HelveticaNeue',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ModernDialogButton(
                          text: 'Close',
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          onTap: () {
                            Navigator.pop(dialogContext);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ModernDialogButton(
                          text: 'Submit',
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              setNotifyDatelLegal(
                                projectLegalId: data.subLegalId ?? '',
                              );
                              Navigator.pop(dialogContext);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              content: Container(
                height: 180,
                width: 400,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const Text("Initiated Date"),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final now = DateTime.now();
                            final today = DateTime(now.year, now.month, now.day);
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedInitiatedDate != null && !_selectedInitiatedDate!.isAfter(today)
                                  ? _selectedInitiatedDate!
                                  : today,
                              firstDate: DateTime(2000),
                              lastDate: today,
                            );
                            if (picked != null &&
                                picked != _selectedInitiatedDate) {
                              _selectedInitiatedDate = picked;
                              initiatedDateControler.text =
                                  DateFormat('dd/MM/yyyy')
                                      .format(_selectedInitiatedDate!);
                            }
                          },
                          child: TextFormField(
                            enabled: false,
                            readOnly: true,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "(Initiated Date Cannot Be Empty)";
                              }
                              return null;
                            },
                            controller: initiatedDateControler,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 13.0),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(12.0),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              hintText: 'Select Initiated Date',
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 116, 116, 116),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'HelveticaNeue',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text("Notify Date"),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final now = DateTime.now();
                            final today = DateTime(now.year, now.month, now.day);
                            final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedNotifyDate != null && !_selectedNotifyDate!.isBefore(today)
                                    ? _selectedNotifyDate!
                                    : today,
                                firstDate: today,
                                lastDate: DateTime(2101));
                            if (picked != null &&
                                picked != _selectedNotifyDate) {
                              _selectedNotifyDate = picked;
                              notifyDateControler.text =
                                  DateFormat('dd/MM/yyyy')
                                      .format(_selectedNotifyDate!);
                            }
                          },
                          child: TextFormField(
                            enabled: false,
                            readOnly: true,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "(Notify Date Cannot Be Empty)";
                              }
                              return null;
                            },
                            controller: notifyDateControler,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 13.0),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(12.0),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              hintText: 'Select Notify Date',
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 116, 116, 116),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'HelveticaNeue',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }
}

class ModernDialogButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  const ModernDialogButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  _ModernDialogButtonState createState() => _ModernDialogButtonState();
}

class _ModernDialogButtonState extends State<ModernDialogButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 24.0),
            decoration: BoxDecoration(
              color: _isHovered
                  ? (widget.backgroundColor == Colors.black ? const Color(0xff222222) : widget.backgroundColor.withOpacity(0.9))
                  : widget.backgroundColor,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: widget.backgroundColor == Colors.white ? const Color(0xffcccccc) : Colors.transparent,
                width: widget.backgroundColor == Colors.white ? 1.0 : 0.0,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : [],
            ),
            alignment: Alignment.center,
            child: Text(
              widget.text,
              style: TextStyle(
                fontFamily: 'HelveticaNeue',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: widget.textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
