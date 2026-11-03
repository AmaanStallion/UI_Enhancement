import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_rcc_slab_issues.dart';
import 'package:stallion/models/get_rccissuereport_data.dart';
import 'package:stallion/models/get_rccissuereport_dropdown.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/common/rcc_mock_data.dart';
import 'package:stallion/ui/views/rccstructure/rcc_skeleton_loader.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:stallion/ui/widgets/stallion_video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class IssueRccReport extends StatefulWidget {
  const IssueRccReport({super.key});

  @override
  State<IssueRccReport> createState() => _IssueRccReportState();
}

class _IssueRccReportState extends State<IssueRccReport> {
  late NotificationArgs args;
  final ScrollController _scrollController = ScrollController();

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      args = ModalRoute.of(context)!.settings.arguments as NotificationArgs;
      _isInitialized = true;
      fetchInitialData();
    }
  }

  @override
  void initState() {
    super.initState();
    arrIssueIn = [];
    arrReportTo = [];
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  bool circular = false;
  bool dropdownFlag = false;
  bool isLoading = true;
  List<IssueIn>? arrIssueIn;
  List<ReportTo>? arrReportTo;
  List<SlabIssueReport> issueReportsList = [];

  List<AddIssue> datIssueController = [
    AddIssue(
      issueTextEditingController: TextEditingController(),
      selectReportingToStrings: "",
      selectReportingToController: TextEditingController(),
    ),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchInitialData() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      _initFixedAuthorityList();
      await fetchRccStructureIssueReportRequest();
    } catch (e) {
      if (kDebugMode) print("fetchInitialData Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _addNewIssueForm() {
    setState(() {
      datIssueController.add(
        AddIssue(
          issueTextEditingController: TextEditingController(),
          selectReportingToStrings: "",
          selectReportingToController: TextEditingController(),
        ),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _removeIssueForm(int index) {
    setState(() {
      datIssueController.removeAt(index);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final targetOffset = (_scrollController.offset - 160.0).clamp(0.0, _scrollController.position.maxScrollExtent);
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }


  Future<bool> setIssueResolved({
    required String issueId,
    required String remarks,
    List<PlatformFile>? attachedFiles,
  }) async {
    if (useRccMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    }

    final String targetProjectId = (args.projectId?.isNotEmpty == true)
        ? args.projectId!
        : (args.response?.projectId ?? '');

    if (targetProjectId.isNotEmpty) {
      await apiNetworkHandler.ensureProjectContext(targetProjectId);
    }

    final SharedPreferences prefs = await _prefs;
    String? token = prefs.getString('projectToken') ??
        prefs.getString('masterToken') ??
        prefs.getString('token') ??
        prefs.getString('userToken');

    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse(AppUrl.updateIssueStatus),
      );

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['issue_id'] = issueId;
      request.fields['status'] = 'resolved';
      request.fields['remarks'] = remarks;

      if (attachedFiles != null && attachedFiles.isNotEmpty) {
        for (var file in attachedFiles) {
          if (file.path != null) {
            final ext = (file.extension ?? '').toLowerCase();
            MediaType mediaType;
            if (ext == 'mp4' || ext == 'mov' || ext == 'avi' || ext == 'mkv') {
              mediaType = MediaType('video', ext.isEmpty ? 'mp4' : ext);
            } else {
              mediaType = MediaType('image', ext.isEmpty ? 'jpeg' : ext);
            }
            request.files.add(await http.MultipartFile.fromPath(
              'files',
              file.path!,
              contentType: mediaType,
            ));
          }
        }
      }

      if (kDebugMode) {
        print("Resolving Issue #$issueId: fields=${request.fields}, filesCount=${request.files.length}");
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print("Resolve Issue response [${response.statusCode}]: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchRccStructureIssueReportRequest();
        return true;
      }
    } catch (e) {
      if (kDebugMode) print("Error setIssueResolved: $e");
    }
    return false;
  }

  Future<List<SlabIssueReport>?> fetchRccStructureIssueReportRequest() async {
    if (useRccMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      final mockData = getMockIssueReportData();
      if (mounted) {
        setState(() {
          issueReportsList = mockData.response.slabIssueReport;
        });
      }
      return issueReportsList;
    }

    final String projectId = (args.projectId?.isNotEmpty == true)
        ? args.projectId!
        : (args.response?.projectId ?? '');
    final String towerId = (args.towarIdFk?.isNotEmpty == true)
        ? args.towarIdFk!
        : (args.response?.towarId ?? '');
    final String slabId = args.response?.slabId ?? '';
    final String targetType = args.response?.targetType ?? '';
    final String slabDrawingTypeId =
        args.response?.slabDrawingTypeId ?? args.response?.drawingId ?? '';

    await apiNetworkHandler.ensureProjectContext(projectId);

    Map<String, String> queryParams = {};
    if (projectId.isNotEmpty) queryParams['project_id'] = projectId;
    if (towerId.isNotEmpty) queryParams['tower_id'] = towerId;
    if (slabId.isNotEmpty) queryParams['slab_id'] = slabId;
    if (targetType.isNotEmpty) queryParams['target_type'] = targetType;
    if (slabDrawingTypeId.isNotEmpty && targetType == 'drawing') {
      queryParams['slab_drawing_type_id'] = slabDrawingTypeId;
    }

    String url = AppUrl.getRccSlabIssues;
    if (queryParams.isNotEmpty) {
      url += "?${Uri(queryParameters: queryParams).query}";
    }

    if (kDebugMode) {
      print("Fetching RCC Slab Issues: $url");
    }

    try {
      var response = await apiNetworkHandler.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = getRccSlabIssuesResponseFromJson(response.body);
        if (parsed.success && parsed.data != null) {
          final mappedIssues = parsed.data!.issues
              .map((item) => item.toSlabIssueReport())
              .toList();
          if (mounted) {
            setState(() {
              issueReportsList = mappedIssues;
            });
          }
          return issueReportsList;
        }
      }
    } catch (e) {
      if (kDebugMode) print("Fetch Issue Report Error: $e");
    }
    return issueReportsList;
  }

  Future<List<ReportTo>?> fetchRccStructureDropDownIssueReportRequest() async {
    if (useRccMockData) {
      final mockDropdown = getMockIssueReportDropdownData();
      if (mounted) {
        setState(() {
          arrReportTo = mockDropdown.response.reportTo;
          dropdownFlag = true;
        });
      }
      return arrReportTo;
    }

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": args.projectId ?? '',
    };

    try {
      var response = await apiNetworkHandler.post(
          AppUrl.getRccStructureDropDownIssueReportRequest, data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = rccIssueReportDropdownDataFromJson(response.body);
        if (dataModel.response.errorCode == "0") {
          if (mounted) {
            setState(() {
              arrReportTo = dataModel.response.reportTo;
              dropdownFlag = true;
            });
          }
          return arrReportTo;
        }
      }
    } catch (e) {
      if (kDebugMode) print("Fetch Dropdown Error: $e");
    }
    return arrReportTo;
  }

  Future<int> setSlabReport() async {
    if (useRccMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return 1;
    }

    final String targetProjectId = (args.projectId?.isNotEmpty == true)
        ? args.projectId!
        : (args.response?.projectId ?? '');

    if (targetProjectId.isNotEmpty) {
      await apiNetworkHandler.ensureProjectContext(targetProjectId);
    }

    final SharedPreferences prefs = await _prefs;
    String? token = prefs.getString('projectToken') ??
        prefs.getString('masterToken') ??
        prefs.getString('token') ??
        prefs.getString('userToken');

    List<int> submittedIndices = [];
    int successCount = 0;
    int totalCount = datIssueController.length;

    for (int i = 0; i < datIssueController.length; i++) {
      final item = datIssueController[i];
      final String remarks = item.issueTextEditingController.text.trim();
      final String authorityIdsStr = item.selectReportingToStrings.trim();

      // Check completeness: must have at least 1 reported authority selected AND remarks
      if (authorityIdsStr.isEmpty || remarks.isEmpty) {
        if (kDebugMode) {
          print("Skipping issue form entry #$i: incomplete (authorityIds: '$authorityIdsStr', remarks: '$remarks')");
        }
        continue;
      }

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(AppUrl.createSlabIssue),
        );

        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }

        final String targetType = args.response?.targetType?.isNotEmpty == true
            ? args.response!.targetType!
            : (args.response?.drawingId?.isNotEmpty == true ? 'drawing' : 'slab');

        final String resolvedTowerId = (args.towarIdFk?.isNotEmpty == true)
            ? args.towarIdFk!
            : (args.response?.towarId ?? '');

        request.fields['project_id'] = targetProjectId;
        request.fields['tower_id'] = resolvedTowerId;
        request.fields['slab_id'] = args.response?.slabId ?? '';
        request.fields['target_type'] = targetType;

        if (targetType == 'drawing') {
          final drawingTypeId = args.response?.slabDrawingTypeId ?? args.response?.drawingId ?? '';
          if (drawingTypeId.isNotEmpty) {
            request.fields['slab_drawing_type_id'] = drawingTypeId;
          }
        }

        request.fields['title'] = remarks.length > 50 ? remarks.substring(0, 50) : remarks;
        request.fields['message'] = remarks;
        request.fields['priority'] = 'high';

        // Add array form-data fields for tower_authority_ids
        List<String> authorityIds = authorityIdsStr.split(',').where((s) => s.trim().isNotEmpty).toList();
        for (int a = 0; a < authorityIds.length; a++) {
          request.fields['tower_authority_ids[$a]'] = authorityIds[a].trim();
        }
        if (authorityIds.isNotEmpty) {
          request.fields['tower_authority_ids[]'] = authorityIds[0].trim();
        }

        // Attach single file if provided
        if (item.arrayFiles != null && item.arrayFiles?.path != null) {
          final filePath = item.arrayFiles!.path!;
          final ext = (item.arrayFiles?.extension ?? '').toLowerCase();
          MediaType mediaType;
          if (ext == 'mp4' || ext == 'mov' || ext == 'avi' || ext == 'mkv') {
            mediaType = MediaType('video', ext.isEmpty ? 'mp4' : ext);
          } else {
            mediaType = MediaType('image', ext.isEmpty ? 'jpeg' : ext);
          }

          request.files.add(await http.MultipartFile.fromPath(
            'files',
            filePath,
            contentType: mediaType,
          ));
        }

        if (kDebugMode) {
          print("Submitting issue form #$i: fields=${request.fields}, filesCount=${request.files.length}");
        }

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (kDebugMode) {
          print("Issue form #$i response [${response.statusCode}]: ${response.body}");
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          successCount++;
          submittedIndices.add(i);
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error submitting issue form #$i: $e");
        }
      }
    }

    // Remove successfully submitted form entries in reverse order
    for (int i = submittedIndices.length - 1; i >= 0; i--) {
      int idxToRemove = submittedIndices[i];
      if (idxToRemove < datIssueController.length) {
        datIssueController.removeAt(idxToRemove);
      }
    }

    if (mounted) {
      setState(() {});
    }

    // Refresh live list
    await fetchRccStructureIssueReportRequest();

    return successCount;
  }

  String getAppBarTitle() {
    final pName = args.projectName?.trim().toUpperCase() ?? '';
    final tName = args.towarName?.trim().toUpperCase() ?? '';

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
    final slabName = args.response?.slabNo?.trim().toUpperCase() ?? '';
    final drawingTitle = args.response?.drawingTitle?.trim().toUpperCase() ?? '';

    if (slabName.isNotEmpty && drawingTitle.isNotEmpty) {
      if (slabName == drawingTitle) {
        return '$slabName - SLAB STATUS';
      }
      return '$slabName - $drawingTitle';
    } else if (drawingTitle.isNotEmpty) {
      return drawingTitle;
    } else if (slabName.isNotEmpty) {
      return '$slabName - SLAB STATUS';
    }
    return 'R.C.C STRUCTURE DRAWING';
  }

  @override
  Widget build(BuildContext context1) {
    final isMobile = context.isMobile;

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
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? IssueReportSkeletonScreen(isMobile: isMobile)
            : Column(
                children: [
                  // SubHeader Bar with Centered Slab - Drawing Title
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

                  // Section Banner
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 6 : 8,
                    ),
                    color: Colors.black,
                    child: Text(
                      "ISSUES REPORTED",
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Scrollable Content
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: fetchRccStructureIssueReportRequest,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12.0 : 24.0,
                          vertical: isMobile ? 10.0 : 16.0,
                        ),
                      child: Column(
                        children: [
                          if (issueReportsList.isNotEmpty)
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: issueReportsList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return buildIssueReportCard(
                                  plist: issueReportsList[index],
                                  isMobile: isMobile,
                                );
                              },
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                "No prior issues reported for this item.",
                                style: TextStyle(
                                  fontSize: isMobile ? 13 : 15,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),

                          // Dynamic New Issue Forms
                          if (datIssueController.isNotEmpty) ...[
                            SizedBox(height: isMobile ? 12 : 20),
                            for (int l = 0; l < datIssueController.length; l++)
                              buildAddIssueCard(ind: l, isMobile: isMobile),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                ],
              ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 20,
          vertical: isMobile ? 10 : 14,
        ),
        child: SafeArea(
          child: Row(
            children: [
              // ADD ISSUE Capsule Button
              Expanded(
                child: InkWell(
                  onTap: _addNewIssueForm,
                  child: Container(
                    height: isMobile ? 42 : 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: Colors.black,
                          size: isMobile ? 16 : 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ADD ISSUE',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: isMobile ? 12 : 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 10 : 12),

              // SUBMIT REPORT Capsule Button
              Expanded(
                child: InkWell(
                  onTap: () => _handleSubmit(context1),
                  child: Container(
                    height: isMobile ? 42 : 48,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        'SUBMIT REPORT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 12 : 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit(BuildContext context1) {
    FocusScope.of(context).unfocus();
    bool isEmpty = false;
    for (int i = 0; i < datIssueController.length; i++) {
      if (datIssueController[i].selectReportingToController.text.trim() == '') {
        isEmpty = true;
        _showNoticeDialog(context, "Please select the 'Reported To' field before submitting.");
        break;
      }
    }
    if (!isEmpty) {
      _showSubmitConfirmationDialog(context1);
    }
  }

  Widget buildIssueReportCard({
    required SlabIssueReport plist,
    required bool isMobile,
  }) {
    final bool isResolved = plist.issueResolve == "1";
    final baseStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

    Widget buildMediaWidget() {
      final bool hasImage = plist.image != null && plist.image!.isNotEmpty;
      final bool hasVideo = plist.slabVedio != null && plist.slabVedio!.isNotEmpty;

      if (hasImage) {
        final rawImg = plist.image![0];
        final imageUrl = rawImg.startsWith('http')
            ? rawImg
            : ((plist.imagePath != null && plist.imagePath!.isNotEmpty)
                ? '${plist.imagePath}/$rawImg'
                : '${AppUrl.globalProfileImgURLThumbs}$rawImg');
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ImagePreviewViewer(
                  fileName: rawImg.startsWith('http')
                      ? Uri.parse(rawImg).path.split('/').last
                      : rawImg,
                  fileUrl: imageUrl,
                ),
              ),
            );
          },
          child: Container(
            width: isMobile ? 90 : 130,
            height: isMobile ? 90 : 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade500, size: isMobile ? 24 : 32),
                        const SizedBox(height: 4),
                        Text(
                          "NO IMAGE\nAVAILABLE",
                          style: TextStyle(fontSize: isMobile ? 9 : 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      } else if (hasVideo) {
        final rawVid = plist.slabVedio![0];
        final videoUrl = rawVid.startsWith('http')
            ? rawVid
            : ((plist.imagePath != null && plist.imagePath!.isNotEmpty)
                ? '${plist.imagePath}/$rawVid'
                : '${AppUrl.globalProfileImgURLThumbs}$rawVid');
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StallionVideoPlayer(
                  fileUrl: videoUrl,
                  documentName: rawVid.startsWith('http')
                      ? Uri.parse(rawVid).path.split('/').last
                      : rawVid,
                ),
              ),
            );
          },
          child: Container(
            width: isMobile ? 90 : 130,
            height: isMobile ? 90 : 130,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_camera_back, size: isMobile ? 32 : 44, color: Colors.indigo),
                const SizedBox(height: 4),
                Text("PLAY VIDEO", style: TextStyle(fontSize: isMobile ? 9 : 11, color: Colors.indigo, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      } else {
        return Container(
          width: isMobile ? 90 : 130,
          height: isMobile ? 90 : 130,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400, size: isMobile ? 24 : 32),
              const SizedBox(height: 4),
              Text(
                "NO IMAGE\nAVAILABLE",
                style: TextStyle(fontSize: isMobile ? 9 : 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
    }

    Widget buildInfoRow(String label, String? value) {
      if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
      final String cleanLabel = label.endsWith(':') ? label.substring(0, label.length - 1).trim() : label;
      final double labelWidth = isMobile ? 95.0 : 115.0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: labelWidth,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      cleanLabel,
                      style: baseStyle.copyWith(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.3,
                      ),
                    ),
                  ),
                  Text(
                    ":",
                    style: baseStyle.copyWith(
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                value,
                style: baseStyle.copyWith(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey.shade800,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final double capsuleWidth = isMobile ? 125.0 : 145.0;

    Widget buildStatusBadge() {
      return Container(
        width: capsuleWidth,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 10, vertical: isMobile ? 5 : 7),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isResolved ? Colors.green : Colors.red, width: 1.2),
        ),
        child: Text(
          isResolved ? "Issue Resolved" : "Issue Pending",
          style: TextStyle(
            fontSize: isMobile ? 11 : 13,
            fontWeight: FontWeight.bold,
            color: isResolved ? Colors.green : Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    Widget buildActionButton() {
      if (!isResolved) {
        return InkWell(
          onTap: () => _showResolveConfirmationDialog(plist),
          child: Container(
            width: capsuleWidth,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 10, vertical: isMobile ? 5 : 7),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.black, size: isMobile ? 13 : 16),
                const SizedBox(width: 4),
                Text(
                  "Mark as Resolved",
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return InkWell(
          onTap: () => _showViewDocsModal(plist),
          child: Container(
            width: capsuleWidth,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 10, vertical: isMobile ? 5 : 7),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.description_outlined, color: Colors.black, size: isMobile ? 13 : 16),
                const SizedBox(width: 4),
                Text(
                  "View Docs",
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 10.0 : 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe9ecef)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Image on left, Status & Action button column on right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildMediaWidget(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          buildStatusBadge(),
                          const SizedBox(height: 8),
                          buildActionButton(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xffe9ecef)),
                const SizedBox(height: 10),

                // Bottom Section: Left-aligned details
                buildInfoRow("Reported By", plist.reportBy),
                buildInfoRow("Reported On", plist.submitdate),
                buildInfoRow("Issue In", plist.issusInName),
                buildInfoRow("Reported To", plist.reportToName),
                if (isResolved) ...[
                  buildInfoRow("Resolved On", plist.resolvedDate),
                  buildInfoRow("Resolved By", plist.empname),
                ],
                buildInfoRow("Remarks", plist.reports),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildMediaWidget(),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildInfoRow("Reported By", plist.reportBy),
                      buildInfoRow("Issue In", plist.issusInName),
                      buildInfoRow("Reported To", plist.reportToName),
                      buildInfoRow("Reported On", plist.submitdate),
                      if (isResolved) ...[
                        buildInfoRow("Resolved On", plist.resolvedDate),
                        buildInfoRow("Resolved By", plist.empname),
                      ],
                      buildInfoRow("Remarks", plist.reports),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    buildStatusBadge(),
                    const SizedBox(height: 10),
                    buildActionButton(),
                  ],
                ),
              ],
            ),
    );
  }

  void _showViewDocsModal(SlabIssueReport plist) {
    final isMobile = context.isMobile;

    List<Widget> gridItems = [];

    final resImgs = (plist.resolutionImages != null && plist.resolutionImages!.isNotEmpty)
        ? plist.resolutionImages!
        : (plist.image ?? []);
    final resVids = (plist.resolutionVideos != null && plist.resolutionVideos!.isNotEmpty)
        ? plist.resolutionVideos!
        : (plist.slabVedio ?? []);

    if (resImgs.isNotEmpty) {
      for (var rawImg in resImgs) {
        final imageUrl = rawImg.startsWith('http')
            ? rawImg
            : ((plist.imagePath != null && plist.imagePath!.isNotEmpty)
                ? '${plist.imagePath}/$rawImg'
                : '${AppUrl.globalProfileImgURLThumbs}$rawImg');

        gridItems.add(
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ImagePreviewViewer(
                    fileName: rawImg.startsWith('http')
                        ? Uri.parse(rawImg).path.split('/').last
                        : rawImg,
                    fileUrl: imageUrl,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade100,
                    child: Center(
                      child: Icon(Icons.broken_image_outlined, size: isMobile ? 28 : 36, color: Colors.grey.shade500),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    if (resVids.isNotEmpty) {
      for (var rawVid in resVids) {
        final videoUrl = rawVid.startsWith('http')
            ? rawVid
            : ((plist.imagePath != null && plist.imagePath!.isNotEmpty)
                ? '${plist.imagePath}/$rawVid'
                : '${AppUrl.globalProfileImgURLThumbs}$rawVid');

        gridItems.add(
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StallionVideoPlayer(
                    fileUrl: videoUrl,
                    documentName: rawVid.startsWith('http')
                        ? Uri.parse(rawVid).path.split('/').last
                        : rawVid,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_fill, size: isMobile ? 36 : 44, color: Colors.indigo),
                  const SizedBox(height: 4),
                  Text(
                    "Play Video",
                    style: TextStyle(fontSize: isMobile ? 10 : 11, color: Colors.indigo, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
          actionsPadding: const EdgeInsets.all(12),
          actionsAlignment: MainAxisAlignment.center,
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              "RESOLUTION PROOFS",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 13 : 15,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: SizedBox(
            height: 220,
            width: isMobile ? 280 : 380,
            child: gridItems.isEmpty
                ? Center(
                    child: Text(
                      "No Resolution Proof Documents Available",
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                : GridView.count(
                    crossAxisCount: isMobile ? 2 : 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: gridItems,
                  ),
          ),
          actions: [
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "CLOSE",
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.bold,
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

  Widget buildAddIssueCard({required int ind, required bool isMobile}) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xfff8f9fa),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe9ecef)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "NEW ISSUE ENTRY #${ind + 1}",
                style: baseStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.black87,
                ),
              ),
              if (ind != 0)
                InkWell(
                  onTap: () => _removeIssueForm(ind),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18, color: Colors.red),
                  ),
                ),

            ],
          ),
          SizedBox(height: isMobile ? 10 : 14),

          // Horizontal Row Layout for both mobile and desktop (as shown in flutter_02.png)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildAttachmentSelector(ind, isMobile),
              SizedBox(width: isMobile ? 10 : 16),
              Expanded(child: buildFormFields(ind, isMobile, baseStyle)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildAttachmentSelector(int index, bool isMobile) {
    final item = datIssueController[index];
    final bool isMp4 = item.arrayFiles != null && item.arrayFiles?.extension?.toLowerCase() == 'mp4';

    final double boxWidth = isMobile ? 95.0 : 120.0;
    final double boxHeight = isMobile ? 85.0 : 105.0;

    return Column(
      children: [
        InkWell(
          onTap: () => _pickMediaFile(index),
          child: Container(
            width: boxWidth,
            height: boxHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: isMp4
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_camera_back, size: isMobile ? 28 : 36, color: Colors.indigo),
                        const SizedBox(height: 2),
                        Text("Video Selected", style: TextStyle(fontSize: isMobile ? 9 : 10, color: Colors.indigo)),
                      ],
                    )
                  : item.arrayFiles == null
                      ? Image.asset(
                          'images/projectmanagement/img5.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.add_a_photo_outlined, size: isMobile ? 28 : 36, color: Colors.grey.shade400),
                        )
                      : Image.file(
                          File(item.arrayFiles?.path ?? ''),
                          fit: BoxFit.cover,
                        ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _pickMediaFile(index),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 6 : 10,
              vertical: isMobile ? 4 : 5,
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.attach_file, color: Colors.white, size: isMobile ? 10 : 12),
                const SizedBox(width: 3),
                Text(
                  "Attach Photo/Video",
                  style: TextStyle(
                    fontSize: isMobile ? 9 : 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<String?> _showMediaSourcePickerSheet(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext sheetContext) {
        final isMobile = context.isMobile;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  "Attach Media / Document",
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.black87),
                  ),
                  title: const Text(
                    "Take Photo (Camera)",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    "Capture a new photo using your camera",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop('camera'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: Colors.black87),
                  ),
                  title: const Text(
                    "Choose from Photos / Gallery",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    "Select photos from your device photo library",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop('gallery'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.folder_open_rounded, color: Colors.black87),
                  ),
                  title: const Text(
                    "Choose from Files (Videos / Documents)",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    "Browse documents and files on your device",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop('files'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickMediaFile(int index) async {
    final bool isMobileDevice = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    if (isMobileDevice) {
      final source = await _showMediaSourcePickerSheet(context);
      if (source == 'camera') {
        try {
          final ImagePicker picker = ImagePicker();
          final XFile? photo = await picker.pickImage(
            source: ImageSource.camera,
            imageQuality: 85,
          );
          if (photo != null) {
            final bytes = await photo.readAsBytes();
            final length = await photo.length();
            final file = PlatformFile(
              name: photo.name,
              path: photo.path,
              size: length,
              bytes: bytes,
            );
            setState(() {
              datIssueController[index].arrayFilesBytes?.add(bytes);
              datIssueController[index].arrayFiles = file;
            });
          }
        } catch (e) {
          if (kDebugMode) print("Camera picker error: $e");
        }
        return;
      } else if (source == 'gallery') {
        try {
          final ImagePicker picker = ImagePicker();
          final XFile? photo = await picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
          );
          if (photo != null) {
            final bytes = await photo.readAsBytes();
            final length = await photo.length();
            final file = PlatformFile(
              name: photo.name,
              path: photo.path,
              size: length,
              bytes: bytes,
            );
            setState(() {
              datIssueController[index].arrayFilesBytes?.add(bytes);
              datIssueController[index].arrayFiles = file;
            });
          }
        } catch (e) {
          if (kDebugMode) print("Gallery picker error: $e");
        }
        return;
      } else if (source == 'files') {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'pdf', 'MP4'],
        );
        if (result != null) {
          PlatformFile file = result.files.first;
          Uint8List? fileBytes = result.files.first.bytes;
          setState(() {
            datIssueController[index].arrayFilesBytes?.add(fileBytes);
            datIssueController[index].arrayFiles = file;
          });
        }
      }
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'pdf', 'MP4'],
      );
      if (result != null) {
        PlatformFile file = result.files.first;
        Uint8List? fileBytes = result.files.first.bytes;
        setState(() {
          datIssueController[index].arrayFilesBytes?.add(fileBytes);
          datIssueController[index].arrayFiles = file;
        });
      }
    }
  }

  Widget buildFormFields(int index, bool isMobile, TextStyle baseStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Issue In
        Text.rich(
          TextSpan(
            style: baseStyle.copyWith(fontSize: isMobile ? 11 : 13),
            children: [
              const TextSpan(text: "Issue In: ", style: TextStyle(fontWeight: FontWeight.w600)),
              TextSpan(text: getSubHeaderTitle(), style: const TextStyle(color: Colors.black87)),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isMobile ? 6 : 8),

        // Reported To
        InkWell(
          onTap: () => _showSetReportingToModal(index: index, isMobile: isMobile),
          child: TextFormField(
            enabled: false,
            readOnly: true,
            controller: datIssueController[index].selectReportingToController,
            style: baseStyle.copyWith(color: Colors.black, fontSize: isMobile ? 11 : 13),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: isMobile ? 8 : 10),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xffced4da)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xffced4da)),
              ),
              hintText: 'Select Reported To Person(s)',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: isMobile ? 11 : 13,
              ),
              suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.black87, size: isMobile ? 20 : 24),
            ),
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),

        // Remarks
        TextFormField(
          minLines: isMobile ? 2 : 2,
          maxLines: 4,
          controller: datIssueController[index].issueTextEditingController,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
          style: baseStyle.copyWith(color: Colors.black, fontSize: isMobile ? 11 : 13),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.all(isMobile ? 8 : 10),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xffced4da)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xffced4da)),
            ),
            hintText: 'Add Slab Issue Remarks & Comments',
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: isMobile ? 11 : 13,
            ),
          ),
        ),
      ],
    );
  }

  List<ReportTo> getFixedAuthorityList() {
    final map = args.response?.towerAuthorityMap ?? {};
    return [
      ReportTo(
        reportToId: (map['structural_consultant']?.isNotEmpty == true)
            ? map['structural_consultant']!
            : '9',
        reportToName: 'Structural Consultant',
        isSelected: false,
      ),
      ReportTo(
        reportToId: (map['developer']?.isNotEmpty == true)
            ? map['developer']!
            : '10',
        reportToName: 'Developer',
        isSelected: false,
      ),
      ReportTo(
        reportToId: (map['municipal_architect']?.isNotEmpty == true)
            ? map['municipal_architect']!
            : '12',
        reportToName: 'Municipal Architect',
        isSelected: false,
      ),
      ReportTo(
        reportToId: (map['rcc_contractor']?.isNotEmpty == true)
            ? map['rcc_contractor']!
            : '11',
        reportToName: 'RCC Contractor',
        isSelected: false,
      ),
    ];
  }

  void _initFixedAuthorityList() {
    setState(() {
      arrReportTo = getFixedAuthorityList();
      dropdownFlag = true;
    });
  }

  void _showSetReportingToModal({required int index, required bool isMobile}) {
    if (arrReportTo == null || arrReportTo!.isEmpty) {
      arrReportTo = getFixedAuthorityList();
    }

    final selectedIds = datIssueController[index]
        .selectReportingToStrings
        .split(',')
        .map((s) => s.trim())
        .toList();

    for (var item in arrReportTo!) {
      item.isSelected = selectedIds.contains(item.reportToId);
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final baseStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

            final displayList = (arrReportTo != null && arrReportTo!.isNotEmpty)
                ? arrReportTo!
                : getFixedAuthorityList();

            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              titlePadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 18,
                vertical: 12,
              ),
              actionsPadding: EdgeInsets.only(
                bottom: isMobile ? 12 : 16,
                left: 12,
                right: 12,
              ),
              actionsAlignment: MainAxisAlignment.center,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  "SELECT REPORTED TO",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              content: SizedBox(
                height: 220,
                width: isMobile ? 280 : 380,
                child: ListView.separated(
                  itemCount: displayList.length,
                  separatorBuilder: (context, idx) => const Divider(height: 1, color: Colors.black12),
                  itemBuilder: (context, i) {
                    final isSelected = displayList[i].isSelected == true;
                    return InkWell(
                      onTap: () {
                        setModalState(() {
                          displayList[i].isSelected = !isSelected;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayList[i].reportToName ?? '',
                                style: baseStyle.copyWith(
                                  fontSize: isMobile ? 13 : 15,
                                ),
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.check_circle : Icons.circle_outlined,
                              color: isSelected ? Colors.green : Colors.grey,
                              size: isMobile ? 18 : 22,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 22,
                      vertical: isMobile ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "CANCEL",
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    datIssueController[index].selectReportingToController.clear();
                    datIssueController[index].selectReportingToStrings = '';
                    for (int k = 0; k < displayList.length; k++) {
                      if (displayList[k].isSelected == true) {
                        setState(() {
                          final currentText = datIssueController[index].selectReportingToController.text;
                          datIssueController[index].selectReportingToController.text =
                              currentText + (currentText.isNotEmpty ? ", " : "") + (displayList[k].reportToName ?? '');

                          final currentStrings = datIssueController[index].selectReportingToStrings;
                          datIssueController[index].selectReportingToStrings =
                              currentStrings + (currentStrings.isNotEmpty ? "," : "") + (displayList[k].reportToId ?? '');
                        });
                      }
                    }
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 18 : 24,
                      vertical: isMobile ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "DONE",
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showNoticeDialog(BuildContext context, String message) {
    final isMobile = context.isMobile;
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.all(isMobile ? 14 : 18),
          actionsPadding: const EdgeInsets.all(12),
          actionsAlignment: MainAxisAlignment.center,
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              "Notice",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(fontSize: isMobile ? 13 : 15, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          actions: [
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: isMobile ? 140 : 180,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  "Okay",
                  style: TextStyle(fontSize: isMobile ? 13 : 15, fontWeight: FontWeight.w600, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSubmitConfirmationDialog(BuildContext context1) {
    final isMobile = context1.isMobile;
    showDialog<void>(
      barrierDismissible: true,
      context: context1,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.all(isMobile ? 14 : 18),
          actionsPadding: const EdgeInsets.all(12),
          actionsAlignment: MainAxisAlignment.center,
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              "CONFIRM SUBMISSION",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: Text(
            "Are you sure you want to submit this issue report?",
            style: TextStyle(fontSize: isMobile ? 13 : 15, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          actions: [
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: isMobile ? 100 : 130,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  "NO",
                  style: TextStyle(fontSize: isMobile ? 13 : 15, fontWeight: FontWeight.w600, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () async {
                Navigator.of(context).pop();
                CustomLoading.progressDialog(isLoading: true, context: context1);
                try {
                  int count = await setSlabReport();
                  await fetchRccStructureIssueReportRequest();
                  if (mounted) {
                    CustomLoading.progressDialog(isLoading: false, context: context1);
                    if (count > 0 && datIssueController.isEmpty) {
                      _showNoticeDialog(context1, "You have successfully submitted the slab issue report.");
                      setState(() {
                        datIssueController = [
                          AddIssue(
                            issueTextEditingController: TextEditingController(),
                            selectReportingToStrings: "",
                            selectReportingToController: TextEditingController(),
                          ),
                        ];
                      });
                    } else if (count > 0 && datIssueController.isNotEmpty) {
                      _showNoticeDialog(
                        context1,
                        "Successfully created $count issue(s). ${datIssueController.length} incomplete form(s) remain on screen.",
                      );
                    } else {
                      _showNoticeDialog(
                        context1,
                        "Please select 'Reported To' and enter remarks for incomplete issue forms.",
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    CustomLoading.progressDialog(isLoading: false, context: context1);
                  }
                }
              },
              child: Container(
                width: isMobile ? 100 : 130,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  "YES",
                  style: TextStyle(fontSize: isMobile ? 13 : 15, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showResolveConfirmationDialog(SlabIssueReport plist) {
    final parentContext = context;
    final isMobile = context.isMobile;
    final TextEditingController resolveRemarksController = TextEditingController();
    List<PlatformFile> resolveFiles = [];

    showDialog<void>(
      barrierDismissible: false,
      context: parentContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              titlePadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
              actionsPadding: const EdgeInsets.all(12),
              actionsAlignment: MainAxisAlignment.center,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  "RESOLVE ISSUE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              content: SizedBox(
                width: isMobile ? 290 : 420,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Enter Resolution Remarks / Comments:",
                        style: TextStyle(fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: resolveRemarksController,
                        minLines: 2,
                        maxLines: 4,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                        style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.black),
                        decoration: InputDecoration(
                          hintText: "Enter resolution remarks...",
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Attach Resolution Photos / Videos:",
                        style: TextStyle(fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final bool isMobileDevice = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
                          if (isMobileDevice) {
                            final source = await _showMediaSourcePickerSheet(context);
                            if (source == 'camera') {
                              try {
                                final ImagePicker picker = ImagePicker();
                                final XFile? photo = await picker.pickImage(
                                  source: ImageSource.camera,
                                  imageQuality: 85,
                                );
                                if (photo != null) {
                                  final bytes = await photo.readAsBytes();
                                  final length = await photo.length();
                                  final file = PlatformFile(
                                    name: photo.name,
                                    path: photo.path,
                                    size: length,
                                    bytes: bytes,
                                  );
                                  setDialogState(() {
                                    resolveFiles.add(file);
                                  });
                                }
                              } catch (e) {
                                if (kDebugMode) print("Camera error in resolve dialog: $e");
                              }
                              return;
                            } else if (source == 'gallery') {
                              try {
                                final ImagePicker picker = ImagePicker();
                                final List<XFile> photos = await picker.pickMultiImage(imageQuality: 85);
                                if (photos.isNotEmpty) {
                                  for (var p in photos) {
                                    final bytes = await p.readAsBytes();
                                    final length = await p.length();
                                    resolveFiles.add(PlatformFile(
                                      name: p.name,
                                      path: p.path,
                                      size: length,
                                      bytes: bytes,
                                    ));
                                  }
                                  setDialogState(() {});
                                }
                              } catch (e) {
                                if (kDebugMode) print("Gallery error in resolve dialog: $e");
                              }
                              return;
                            } else if (source == 'files') {
                              final result = await FilePicker.platform.pickFiles(
                                allowMultiple: true,
                                type: FileType.custom,
                                allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi', 'mkv', 'pdf'],
                              );
                              if (result != null && result.files.isNotEmpty) {
                                setDialogState(() {
                                  resolveFiles.addAll(result.files);
                                });
                              }
                            }
                          } else {
                            final result = await FilePicker.platform.pickFiles(
                              allowMultiple: true,
                              type: FileType.custom,
                              allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi', 'mkv', 'pdf'],
                            );
                            if (result != null && result.files.isNotEmpty) {
                              setDialogState(() {
                                resolveFiles.addAll(result.files);
                              });
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.attach_file, size: 18, color: Colors.black87),
                              SizedBox(width: 6),
                              Text("Pick Files (Images / Videos)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      if (resolveFiles.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: resolveFiles.map((f) {
                            return Chip(
                              label: Text(f.name, style: const TextStyle(fontSize: 11)),
                              onDeleted: () {
                                setDialogState(() {
                                  resolveFiles.remove(f);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                InkWell(
                  onTap: () => Navigator.of(dialogContext).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(20)),
                    child: Text("CANCEL", style: TextStyle(fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () async {
                    final remarks = resolveRemarksController.text.trim();
                    if (remarks.isEmpty) {
                      _showNoticeDialog(parentContext, "Please enter resolution remarks.");
                      return;
                    }

                    Navigator.of(dialogContext).pop();
                    CustomLoading.progressDialog(isLoading: true, context: parentContext);
                    bool success = false;
                    try {
                      success = await setIssueResolved(
                        issueId: plist.mstSlabIssuerReportId.toString(),
                        remarks: remarks,
                        attachedFiles: resolveFiles,
                      );
                    } catch (e) {
                      if (kDebugMode) print("Error in setIssueResolved: $e");
                    } finally {
                      if (mounted) {
                        try {
                          CustomLoading.progressDialog(isLoading: false, context: parentContext);
                        } catch (_) {}
                        if (success) {
                          _showNoticeDialog(parentContext, "Issue resolved successfully!");
                        } else {
                          _showNoticeDialog(parentContext, "Failed to update issue status. Please try again.");
                        }
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                    child: Text("RESOLVE", style: TextStyle(fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
