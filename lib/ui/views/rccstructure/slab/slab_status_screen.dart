import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/getLabReportOk.dart';
import 'package:stallion/models/get_rcc_slab_issues.dart';
import 'package:stallion/models/get_rccissuereport_data.dart';
import 'package:stallion/models/get_rccissuereport_dropdown.dart';
import 'package:stallion/models/get_rccstructure.dart';
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

class SlabStatusScreen extends StatefulWidget {
  SlabStatusScreen({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    this.title,
    this.plist,
    this.slabId,
    this.estCompletDate,
    required this.isSlabExist,
    this.towerAuthorityMap,
  });
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? title;
  final SlabCheck? plist;
  final String? slabId;
  final String? estCompletDate;
  bool isSlabExist;
  final Map<String, String>? towerAuthorityMap;


  @override
  State<SlabStatusScreen> createState() => _SlabStatusScreenState();
}

class _SlabStatusScreenState extends State<SlabStatusScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final ScrollController _slabScrollController = ScrollController();
  final ScrollController _issueScrollController = ScrollController();
  NetworkHandler apiNetworkHandler = NetworkHandler();


  int selectedTabIndex = 0; // 0 for "SLAB STATUS", 1 for "ISSUES REPORTED"
  bool isLoading = true;

  // Tab 0 (Slab Status) Data
  GetLabReportOkResponse? getLabReportOkResponse;
  List<String>? imageData = [];
  List<String> imageNamesList = [];
  List<dynamic>? reportVedioData = [];
  int? isSelectedComment;
  List<String> commentsList = [
    "Ok Work",
    "Ideal Work",
    "Perfect Work",
    "Add Comments"
  ];
  TextEditingController textControler = TextEditingController();
  var arrayFiles = [];
  var arrayFilesBytes = [];

  // Tab 1 (Issues Reported) Data
  bool isIssueDataLoaded = false;
  bool isIssueLoading = false;
  List<ReportTo>? arrReportTo = [];
  List<SlabIssueReport> issueReportsList = [];
  List<AddIssue> datIssueController = [
    AddIssue(
      issueTextEditingController: TextEditingController(),
      selectReportingToStrings: "",
      selectReportingToController: TextEditingController(),
    ),
  ];

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
    final slabTitle = widget.title?.trim().toUpperCase() ?? 'SLAB';
    return '$slabTitle - SLAB STATUS';
  }

  List<ReportTo> getFixedAuthorityList() {
    final map = widget.towerAuthorityMap ?? {};
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
    arrReportTo = getFixedAuthorityList();
  }

  @override
  void initState() {
    super.initState();
    _initFixedAuthorityList();
    if (widget.isSlabExist) {
      getLabReport();
    } else {
      isLoading = false;
    }
  }

  @override
  void dispose() {
    _slabScrollController.dispose();
    _issueScrollController.dispose();
    super.dispose();
  }


  Future<GetLabReportOkResponse?> getLabReport() async {
    setState(() {
      isLoading = true;
    });

    if (AppUrl.useNewBackend &&
        widget.slabId != null &&
        widget.slabId!.isNotEmpty) {
      try {
        await apiNetworkHandler.ensureProjectContext(widget.projectId);
        var response = await apiNetworkHandler.get(
          AppUrl.getSlabAuthorities(widget.slabId!),
        );

        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          final decoded = json.decode(response.body);
          if (decoded['success'] == true && decoded['data'] != null) {
            var authorities = decoded['data']['authorities'];
            if (authorities is List && authorities.isNotEmpty) {
              Map<String, dynamic>? matchedAuth;
              String checkId = widget.plist?.towerAuthorityId ??
                  widget.plist?.slabCheckId ??
                  '';
              String checkTitle =
                  widget.plist?.slabCheckTitle?.toLowerCase() ?? '';

              for (var auth in authorities) {
                if (auth is! Map) continue;
                String authTowerId =
                    auth['tower_authority_id']?.toString() ?? '';
                String authId = auth['id']?.toString() ?? '';
                String authType = auth['tower_authority']?['type']
                        ?.toString()
                        .toLowerCase() ??
                    '';

                if ((checkId.isNotEmpty &&
                        (authTowerId == checkId || authId == checkId)) ||
                    (checkTitle.isNotEmpty &&
                        authType.contains(
                            checkTitle.replaceAll(' ', '_')))) {
                  matchedAuth = Map<String, dynamic>.from(auth);
                  break;
                }
              }

              if (matchedAuth == null &&
                  authorities.length == 1 &&
                  authorities.first is Map) {
                matchedAuth = Map<String, dynamic>.from(authorities.first);
              }

              if (matchedAuth != null) {
                String completedOnStr =
                    formatDateToDdMmYyyy(matchedAuth['completed_on']?.toString());

                String remarksStr = matchedAuth['remarks']?.toString() ?? '';
                String createdByName =
                    matchedAuth['created_by_user']?['name']?.toString() ?? '';

                List<String> images = [];
                List<String> imageNames = [];
                List<String> videos = [];
                var docs = matchedAuth['documents'];
                if (docs is List) {
                  for (var doc in docs) {
                    if (doc is Map) {
                      String fileUrl = doc['file_url']?.toString() ?? '';
                      String fileName = doc['file_name']?.toString() ??
                          doc['name']?.toString() ??
                          '';
                      if (fileName.isEmpty && fileUrl.isNotEmpty) {
                        try {
                          fileName = Uri.parse(fileUrl).path.split('/').last;
                        } catch (_) {}
                      }
                      String mimeType =
                          doc['mime_type']?.toString().toLowerCase() ?? '';
                      String ext =
                          doc['extension']?.toString().toLowerCase() ?? '';

                      if (fileUrl.isNotEmpty) {
                        if (mimeType.contains('video') ||
                            ext.contains('mp4') ||
                            ext.contains('mov') ||
                            ext.contains('avi') ||
                            ext.contains('mkv')) {
                          videos.add(fileUrl);
                        } else {
                          images.add(fileUrl);
                          imageNames.add(fileName);
                        }
                      }
                    }
                  }
                }

                if (mounted) {
                  setState(() {
                    widget.isSlabExist = true;
                    imageData = images;
                    imageNamesList = imageNames;
                    reportVedioData = videos;
                    getLabReportOkResponse = GetLabReportOkResponse(
                      errorCode: "0",
                      slabReport: [
                        SlabReport(
                          estCompletDate:
                              widget.estCompletDate ?? widget.plist?.completedOn ?? "N/A",
                          submitDate: completedOnStr.isNotEmpty
                              ? completedOnStr
                              : "Completed",
                          imagePath: "",
                          image: images,
                          reportVedio: videos,
                          slabReportReview: remarksStr.isNotEmpty
                              ? remarksStr
                              : (createdByName.isNotEmpty
                                  ? "Approved by $createdByName"
                                  : "Completed"),
                        ),
                      ],
                    );
                    isLoading = false;
                  });
                }
                return getLabReportOkResponse;
              }
            }
          }
        }
      } catch (e) {
        if (kDebugMode) print("Error fetching slab authorities API: $e");
      }
    }

    if (useRccMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final mockData = getMockLabReportOkData();
      if (mounted) {
        setState(() {
          getLabReportOkResponse = mockData;
          imageData = getLabReportOkResponse?.slabReport?[0].image;
          reportVedioData = getLabReportOkResponse?.slabReport?[0].reportVedio;
          isLoading = false;
        });
      }
      return getLabReportOkResponse;
    }

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId ?? '',
      "slab_id": widget.slabId ?? '',
      "slab_check_id": widget.plist?.slabCheckId ?? '',
    };

    try {
      var response = await apiNetworkHandler.post(AppUrl.getslabreportok, data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = getLabReportOkFromJson(response.body);
        if (dataModel.response?.errorCode == "0") {
          if (mounted) {
            setState(() {
              getLabReportOkResponse = dataModel.response;
              imageData = getLabReportOkResponse?.slabReport?[0].image;
              reportVedioData = getLabReportOkResponse?.slabReport?[0].reportVedio;
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching lab report: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
    return getLabReportOkResponse;
  }

  Future<void> fetchIssueReportData() async {
    setState(() {
      isIssueLoading = true;
    });

    if (arrReportTo == null || arrReportTo!.isEmpty) {
      _initFixedAuthorityList();
    }

    await fetchRccStructureDropDownIssueReportRequest();
    await fetchRccStructureIssueReportRequest();

    if (mounted) {
      setState(() {
        if (arrReportTo == null || arrReportTo!.isEmpty) {
          arrReportTo = getFixedAuthorityList();
        }
        isIssueLoading = false;
        isIssueDataLoaded = true;
      });
    }
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

    final String projectId = widget.projectId ?? '';
    final String towerId = widget.towarId ?? '';
    final String slabId = widget.slabId ?? '';

    await apiNetworkHandler.ensureProjectContext(projectId);

    Map<String, String> queryParams = {};
    if (projectId.isNotEmpty) queryParams['project_id'] = projectId;
    if (towerId.isNotEmpty) queryParams['tower_id'] = towerId;
    if (slabId.isNotEmpty) queryParams['slab_id'] = slabId;
    queryParams['target_type'] = 'slab';

    String url = AppUrl.getRccSlabIssues;
    if (queryParams.isNotEmpty) {
      url += "?${Uri(queryParameters: queryParams).query}";
    }

    if (kDebugMode) {
      print("Fetching Slab Issues for SlabStatusScreen: $url");
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
        });
      }
      return arrReportTo;
    }

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": widget.projectId ?? '',
    };

    try {
      var response = await apiNetworkHandler.post(
          AppUrl.getRccStructureDropDownIssueReportRequest, data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = rccIssueReportDropdownDataFromJson(response.body);
        if (dataModel.response.errorCode == "0" &&
            dataModel.response.reportTo.isNotEmpty) {
          if (mounted) {
            setState(() {
              arrReportTo = dataModel.response.reportTo;
            });
          }
          return arrReportTo;
        }
      }
    } catch (e) {
      if (kDebugMode) print("Fetch Dropdown Error: $e");
    }
    if (arrReportTo == null || arrReportTo!.isEmpty) {
      arrReportTo = getFixedAuthorityList();
    }
    return arrReportTo;
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

    final String targetProjectId = (widget.projectId?.isNotEmpty == true)
        ? widget.projectId!
        : '';

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
      if (_issueScrollController.hasClients) {
        _issueScrollController.animateTo(
          _issueScrollController.position.maxScrollExtent,
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
      if (_issueScrollController.hasClients) {
        final targetOffset = (_issueScrollController.offset - 160.0).clamp(0.0, _issueScrollController.position.maxScrollExtent);
        _issueScrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }


  Future<void> setSlabReport() async {
    if (AppUrl.useNewBackend) {
      try {
        await apiNetworkHandler.ensureProjectContext(widget.projectId);
        final SharedPreferences prefs = await _prefs;
        String? projectToken =
            prefs.getString('projectToken') ?? prefs.getString('token');

        var request = http.MultipartRequest(
          'POST',
          Uri.parse(AppUrl.postSlabAuthorities),
        );

        if (projectToken != null && projectToken.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $projectToken';
        }

        String selectedRemark = isSelectedComment == 3
            ? textControler.text
            : (isSelectedComment != null &&
                    isSelectedComment! < commentsList.length
                ? commentsList[isSelectedComment!]
                : textControler.text);

        String completedOnIso = DateTime.now().toIso8601String();

        request.fields['slab_id'] = widget.slabId ?? '';
        request.fields['tower_authority_id'] =
            widget.plist?.towerAuthorityId ?? widget.plist?.slabCheckId ?? '';
        request.fields['remarks'] = selectedRemark;
        request.fields['completed_on'] = completedOnIso;

        for (int i = 0; i < arrayFiles.length; i++) {
          if (arrayFiles[i] != null && arrayFiles[i].path != null) {
            PlatformFile file = arrayFiles[i]!;
            final ext = (file.extension ?? '').toLowerCase();
            String mainType = 'image';
            String subType = ext.isNotEmpty ? ext : 'jpeg';
            if (ext == 'pdf') {
              mainType = 'application';
            } else if (ext == 'mp4' ||
                ext == 'mov' ||
                ext == 'avi' ||
                ext == 'mkv') {
              mainType = 'video';
            }
            if (subType == 'jpg') subType = 'jpeg';

            request.files.add(
              await http.MultipartFile.fromPath(
                "documents",
                file.path!,
                contentType: MediaType(mainType, subType),
              ),
            );
          }
        }

        if (kDebugMode) {
          print("Submitting Slab Authority fields: ${request.fields}");
          print("Submitting Slab Authority file count: ${request.files.length}");
        }

        var response = await request.send();
        var responsed = await http.Response.fromStream(response);
        if (kDebugMode) {
          print(
              "Post Slab Authority response: ${responsed.statusCode} - ${responsed.body}");
        }
        if (responsed.statusCode == 200 || responsed.statusCode == 201) {
          await getLabReport();
          if (mounted) {
            Navigator.maybePop(context, true);
          }
          return;
        }
      } catch (e) {
        if (kDebugMode) print("Error posting slab authority: $e");
      }
    }

    if (useRccMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return;
    }

    var request =
        http.MultipartRequest('POST', Uri.parse(AppUrl.wsSetSlabReportOk));

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
    });

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    request.fields['user_id'] = userId ?? '';
    request.fields['slab_id'] = widget.slabId ?? '';
    request.fields['slab_check_id'] = widget.plist?.slabCheckId ?? '';
    request.fields['message'] = isSelectedComment == 3
        ? textControler.text
        : (isSelectedComment != null ? commentsList[isSelectedComment!] : '');
    request.fields['reason'] = textControler.text;

    for (int i = 0; i < arrayFiles.length; i++) {
      if (arrayFiles[i] != null && arrayFiles[i].extension != "mp4") {
        PlatformFile file = arrayFiles[i]!;
        request.files.add(
          await http.MultipartFile.fromPath(
            "slabimage[]",
            file.path.toString(),
          ),
        );
      } else if (arrayFiles[i] != null && arrayFiles[i].extension == "mp4") {
        PlatformFile file = arrayFiles[i]!;
        request.files.add(
          await http.MultipartFile.fromPath(
            "slab_vedio[]",
            file.path.toString(),
          ),
        );
      }
    }

    var response = await request.send();
    var responsed = await http.Response.fromStream(response);
    if (kDebugMode) {
      print("Set Slab Report response: ${responsed.statusCode}");
    }
  }

  Future<void> setSlabIssueReportSubmit() async {
    if (useRccMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return;
    }

    if (AppUrl.useNewBackend) {
      try {
        await apiNetworkHandler.ensureProjectContext(widget.projectId);
        final SharedPreferences prefs = await _prefs;
        String? token = prefs.getString('projectToken') ?? prefs.getString('token');
        final targetProjectId = widget.projectId ?? prefs.getString('project_id') ?? '';

        for (int i = 0; i < datIssueController.length; i++) {
          final item = datIssueController[i];
          final String remarks = item.issueTextEditingController.text.trim();
          final String authorityIdsStr = item.selectReportingToStrings.trim();

          if (authorityIdsStr.isEmpty || remarks.isEmpty) {
            continue;
          }

          var request = http.MultipartRequest(
            'POST',
            Uri.parse(AppUrl.createSlabIssue),
          );

          if (token != null && token.isNotEmpty) {
            request.headers['Authorization'] = 'Bearer $token';
          }

          request.fields['project_id'] = targetProjectId;
          request.fields['tower_id'] = widget.towarId ?? '';
          request.fields['slab_id'] = widget.slabId ?? '';
          request.fields['target_type'] = 'slab';
          request.fields['title'] = remarks.length > 50 ? remarks.substring(0, 50) : remarks;
          request.fields['message'] = remarks;
          request.fields['priority'] = 'high';

          List<String> authorityIds = authorityIdsStr
              .split(',')
              .where((s) => s.trim().isNotEmpty)
              .toList();
          for (int a = 0; a < authorityIds.length; a++) {
            request.fields['tower_authority_ids[$a]'] = authorityIds[a].trim();
          }
          if (authorityIds.isNotEmpty) {
            request.fields['tower_authority_ids[]'] = authorityIds[0].trim();
          }

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

          var streamedResponse = await request.send();
          var response = await http.Response.fromStream(streamedResponse);
          if (kDebugMode) {
            print("Submit slab issue #$i response [${response.statusCode}]: ${response.body}");
          }
        }
        return;
      } catch (e) {
        if (kDebugMode) print("Error submitting new backend slab issue: $e");
      }
    }

    var request =
        http.MultipartRequest('POST', Uri.parse(AppUrl.wsSetSlabIssueReport));

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
    });

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    request.fields['user_id'] = userId ?? '';
    request.fields['slab_id'] = widget.slabId ?? '';
    request.fields['slab_check_id'] = widget.plist?.slabCheckId ?? '';
    request.fields['extra_comment'] = '';
    request.fields['slab_check_type'] = '1';


    List dict = [];
    for (int k = 0; k < datIssueController.length; k++) {
      var temp = {
        "issue_in": widget.title ?? '',
        "report_to": datIssueController[k].selectReportingToStrings,
        "remarks": datIssueController[k].issueTextEditingController.text,
      };
      dict.add(temp);
    }

    for (int i = 0; i < datIssueController.length; i++) {
      if (datIssueController[i].arrayFiles != null &&
          datIssueController[i].arrayFiles?.extension != "mp4") {
        PlatformFile file = datIssueController[i].arrayFiles!;
        request.files.add(await http.MultipartFile.fromPath(
          "issue_image$i[]",
          file.path.toString(),
          contentType: MediaType('application/pdf', file.extension ?? ""),
        ));
      } else if (datIssueController[i].arrayFiles != null &&
          datIssueController[i].arrayFiles?.extension == "mp4") {
        PlatformFile file = datIssueController[i].arrayFiles!;
        request.files.add(await http.MultipartFile.fromPath(
          "issue_vedio$i[]",
          file.path.toString(),
          contentType: MediaType('application/pdf', file.extension ?? ""),
        ));
      }
    }
    request.fields['report_issue'] = jsonEncode(dict);

    var response = await request.send();
    var responsed = await http.Response.fromStream(response);
    if (kDebugMode) {
      print("Submit issue response: ${responsed.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context1) {
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
        child: Column(
          children: [
            // SubHeader Bar: SLAB NAME - SLAB STATUS
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


            // Sliding Animated Dual Capsule Toggle Bar
            buildSlidingToggleBar(isMobile, baseStyle),
            const Divider(height: 1.0, color: Colors.black12),

            // Main Body Content with Animated Transition
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                child: selectedTabIndex == 0
                    ? (isLoading
                        ? SlabStatusSkeletonScreen(key: const ValueKey('slab_skel'), isMobile: isMobile)
                        : SingleChildScrollView(
                            key: const ValueKey('slab_body'),
                            controller: _slabScrollController,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12.0 : 24.0,
                              vertical: isMobile ? 12.0 : 16.0,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: widget.isSlabExist
                                  ? buildSubmittedStatusView(isMobile, baseStyle)
                                  : buildCreateStatusForm(isMobile, baseStyle),
                            ),
                          ))
                    : (isIssueLoading
                        ? IssueReportSkeletonScreen(key: const ValueKey('issue_skel'), isMobile: isMobile)
                        : RefreshIndicator(
                            onRefresh: fetchRccStructureIssueReportRequest,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              key: const ValueKey('issue_body'),
                              controller: _issueScrollController,
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 12.0 : 24.0,
                                vertical: isMobile ? 12.0 : 16.0,
                              ),
                              child: SizedBox(
                                width: double.infinity,
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
                                          "No prior issues reported for this slab item.",
                                          style: baseStyle.copyWith(
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
                          )),
              ),
            ),



          ],
        ),
      ),

      // Bottom Bar Navigation Actions
      bottomNavigationBar: selectedTabIndex == 0
          ? (!widget.isSlabExist && !isLoading
              ? Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 20,
                    vertical: isMobile ? 10 : 14,
                  ),
                  child: SafeArea(
                    child: InkWell(
                      onTap: () => _handleFormSubmit(context1),
                      child: Container(
                        height: isMobile ? 42 : 48,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            'SUBMIT SLAB REPORT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 13 : 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink())
          : Container(
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
                        onTap: () => _handleIssueFormSubmit(context1),
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

  // ================= SLIDING TOGGLE BAR =================

  Widget buildSlidingToggleBar(bool isMobile, TextStyle baseStyle) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 8 : 10,
      ),
      color: Colors.white,
      child: Container(
        height: isMobile ? 38 : 44,
        decoration: BoxDecoration(
          color: const Color(0xfff1f3f5),
          borderRadius: BorderRadius.circular(22),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double toggleWidth = (constraints.maxWidth - 6) / 2;
            return Stack(
              children: [
                // Sliding Animated Indicator Pill
                AnimatedAlign(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  alignment: selectedTabIndex == 0 ? Alignment.centerLeft : Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Container(
                      width: toggleWidth,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Clickable Tab Labels
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (selectedTabIndex != 0) {
                            setState(() {
                              selectedTabIndex = 0;
                            });
                          }
                        },
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: baseStyle.copyWith(
                              fontSize: isMobile ? 11 : 13,
                              fontWeight: FontWeight.bold,
                              color: selectedTabIndex == 0 ? Colors.white : Colors.black87,
                            ),
                            child: const Text("SLAB STATUS"),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (selectedTabIndex != 1) {
                            setState(() {
                              selectedTabIndex = 1;
                            });
                            if (!isIssueDataLoaded) {
                              fetchIssueReportData();
                            } else {
                              fetchRccStructureIssueReportRequest();
                            }
                          }
                        },
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: baseStyle.copyWith(
                              fontSize: isMobile ? 11 : 13,
                              fontWeight: FontWeight.bold,
                              color: selectedTabIndex == 1 ? Colors.white : Colors.black87,
                            ),
                            child: const Text("ISSUES REPORTED"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }


  // ================= TAB 0: SLAB STATUS VIEWS =================

  Widget buildSubmittedStatusView(bool isMobile, TextStyle baseStyle) {

    final slab = getLabReportOkResponse?.slabReport != null &&
            getLabReportOkResponse!.slabReport!.isNotEmpty
        ? getLabReportOkResponse!.slabReport![0]
        : null;

    final bool hasImages = imageData != null && imageData!.isNotEmpty;
    final bool hasVideos = reportVedioData != null && reportVedioData!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card 1: Overview & Dates
        Container(
          width: double.infinity,
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
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title ?? 'Slab Inspection Status',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 10 : 14,
                      vertical: isMobile ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      "COMPLETED",
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xffe9ecef)),
              const SizedBox(height: 12),
              buildDetailRow("Estimated Completion", formatDateToDdMmYyyy(slab?.estCompletDate) != '' ? formatDateToDdMmYyyy(slab?.estCompletDate) : 'N/A', isMobile, baseStyle),
              buildDetailRow("Actual Completion", formatDateToDdMmYyyy(slab?.submitDate) != '' ? formatDateToDdMmYyyy(slab?.submitDate) : 'N/A', isMobile, baseStyle),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),

        // Card 2: Attached Images & Videos
        Container(
          width: double.infinity,
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
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Slab Inspection Media",
                style: TextStyle(
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              if (hasImages || hasVideos)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (hasImages)
                        for (int k = 0; k < imageData!.length; k++)
                          InkWell(
                            onTap: () {
                              final String targetUrl = imageData![k].startsWith('http')
                                  ? imageData![k]
                                  : '${AppUrl.globalSlabReportPath}${imageData![k]}';

                              String fName = '';
                              if (k < imageNamesList.length &&
                                  imageNamesList[k].isNotEmpty) {
                                fName = imageNamesList[k];
                              } else {
                                try {
                                  final uri = Uri.parse(targetUrl);
                                  fName = uri.path.split('/').last;
                                } catch (_) {}
                              }
                              if (fName.isEmpty) fName = "Slab Image ${k + 1}";

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ImagePreviewViewer(
                                    fileName: fName,
                                    fileUrl: targetUrl,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: isMobile ? 90 : 110,
                              height: isMobile ? 90 : 110,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  imageData![k].startsWith('http')
                                      ? imageData![k]
                                      : '${AppUrl.globalSlabReportPath}${imageData![k]}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.image_outlined, color: Colors.grey.shade500),
                                ),
                              ),
                            ),
                          ),
                      if (hasVideos)
                        for (int k = 0; k < reportVedioData!.length; k++)
                          InkWell(
                            onTap: () {
                              final String vPath = reportVedioData![k].toString();
                              final String videoUrl = vPath.startsWith('http')
                                  ? vPath
                                  : '${AppUrl.globalSlabReportPath}/$vPath';
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StallionVideoPlayer(
                                    fileUrl: videoUrl,
                                    documentName: vPath.startsWith('http')
                                        ? Uri.parse(vPath).path.split('/').last
                                        : vPath,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: isMobile ? 90 : 110,
                              height: isMobile ? 90 : 110,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.video_camera_back, size: isMobile ? 32 : 40, color: Colors.indigo),
                                  const SizedBox(height: 4),
                                  Text("Play Video", style: TextStyle(fontSize: isMobile ? 9 : 11, color: Colors.indigo, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                )
              else
                Text(
                  "No inspection media uploaded.",
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),

        // Card 3: Review & Comments
        Container(
          width: double.infinity,
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
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Slab Review & Remarks",
                style: TextStyle(
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                (slab?.slabReportReview != null && slab!.slabReportReview!.trim().isNotEmpty)
                    ? slab.slabReportReview!
                    : "No review remarks provided.",
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey.shade800,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCreateStatusForm(bool isMobile, TextStyle baseStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Info Card
        Container(
          width: double.infinity,
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
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title ?? 'Slab Inspection',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Status: Pending Completion",
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),

        // Attachment Selector Card
        Container(
          width: double.infinity,
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
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Upload Slab Media (Photos/Videos)",
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "${arrayFiles.length}/4 Attached",
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    InkWell(
                      onTap: _pickMediaFile,
                      child: Container(
                        width: isMobile ? 90 : 110,
                        height: isMobile ? 90 : 110,
                        decoration: BoxDecoration(
                          color: const Color(0xfff8f9fa),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xffced4da)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: isMobile ? 28 : 36, color: Colors.black87),
                            const SizedBox(height: 4),
                            Text(
                              "Attach",
                              style: TextStyle(
                                fontSize: isMobile ? 10 : 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    for (int j = 0; j < arrayFiles.length; j++)
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: isMobile ? 90 : 110,
                        height: isMobile ? 90 : 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: arrayFiles[j].extension != 'mp4'
                                  ? (arrayFiles[j].path != null
                                      ? Image.file(
                                          File(arrayFiles[j].path!),
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : (arrayFilesBytes.length > j && arrayFilesBytes[j] != null
                                          ? Image.memory(
                                              arrayFilesBytes[j]!,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(Icons.error)))
                                  : Container(
                                      color: Colors.grey.shade100,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.video_camera_back, size: 36, color: Colors.indigo),
                                          SizedBox(height: 4),
                                          Text("Video", style: TextStyle(fontSize: 10, color: Colors.indigo)),
                                        ],
                                      ),
                                    ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    arrayFiles.removeAt(j);
                                    if (arrayFilesBytes.length > j) {
                                      arrayFilesBytes.removeAt(j);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),

        // Comment Preset Options Card
        Container(
          width: double.infinity,
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
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Slab Review & Remarks",
                style: TextStyle(
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < commentsList.length; i++)
                    InkWell(
                      onTap: () {
                        setState(() {
                          isSelectedComment = i;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: isMobile ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelectedComment == i ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelectedComment == i ? Colors.black : const Color(0xffced4da),
                          ),
                        ),
                        child: Text(
                          commentsList[i],
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 13,
                            fontWeight: isSelectedComment == i ? FontWeight.bold : FontWeight.w500,
                            color: isSelectedComment == i ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (isSelectedComment == 3) ...[
                const SizedBox(height: 12),
                TextFormField(
                  minLines: 3,
                  maxLines: 5,
                  controller: textControler,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  style: baseStyle.copyWith(color: Colors.black, fontSize: isMobile ? 12 : 14),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12),
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
                    hintText: 'Enter custom slab remarks & feedback...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ================= TAB 1: ISSUES REPORTED VIEWS =================

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
          onTap: () => _pickIssueMediaFile(index),
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
          onTap: () => _pickIssueMediaFile(index),
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
                  "Attach Photo / Video",
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

  Future<void> _pickIssueMediaFile(int index) async {
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
          allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'pdf'],
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
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
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
        Text.rich(
          TextSpan(
            style: baseStyle.copyWith(fontSize: isMobile ? 11 : 13),
            children: [
              const TextSpan(text: "Issue In: ", style: TextStyle(fontWeight: FontWeight.w600)),
              TextSpan(text: widget.title ?? 'Slab Item', style: const TextStyle(color: Colors.black87)),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isMobile ? 6 : 8),

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

        TextFormField(
          minLines: 2,
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
                              allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi', 'mkv'],
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

  // ================= COMMON HELPERS & DIALOGS =================

  Future<void> _pickMediaFile() async {
    if (arrayFiles.length >= 4) return;
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
              arrayFilesBytes.add(bytes);
              arrayFiles.add(file);
            });
          }
        } catch (e) {
          if (kDebugMode) print("Camera picker error: $e");
        }
        return;
      } else if (source == 'gallery') {
        try {
          final ImagePicker picker = ImagePicker();
          final List<XFile> photos = await picker.pickMultiImage(imageQuality: 85);
          if (photos.isNotEmpty) {
            for (var p in photos) {
              if (arrayFiles.length >= 4) break;
              final bytes = await p.readAsBytes();
              final length = await p.length();
              final file = PlatformFile(
                name: p.name,
                path: p.path,
                size: length,
                bytes: bytes,
              );
              setState(() {
                arrayFilesBytes.add(bytes);
                arrayFiles.add(file);
              });
            }
          }
        } catch (e) {
          if (kDebugMode) print("Gallery error in slab status: $e");
        }
        return;
      } else if (source == 'files') {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'pdf'],
        );
        if (result != null) {
          PlatformFile file = result.files.first;
          Uint8List? fileBytes = result.files.first.bytes;
          setState(() {
            arrayFilesBytes.add(fileBytes);
            arrayFiles.add(file);
          });
        }
      }
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
      );
      if (result != null) {
        PlatformFile file = result.files.first;
        Uint8List? fileBytes = result.files.first.bytes;
        setState(() {
          arrayFilesBytes.add(fileBytes);
          arrayFiles.add(file);
        });
      }
    }
  }

  Widget buildDetailRow(String label, String value, bool isMobile, TextStyle baseStyle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text.rich(
        TextSpan(
          style: baseStyle.copyWith(fontSize: isMobile ? 12 : 14, height: 1.3),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
            TextSpan(text: value, style: TextStyle(color: Colors.grey.shade800)),
          ],
        ),
      ),
    );
  }

  void _handleFormSubmit(BuildContext context1) {
    if (arrayFiles.isEmpty ||
        isSelectedComment == null ||
        (isSelectedComment == 3 && textControler.text.trim().isEmpty)) {
      _showNoticeDialog(context, "Please attach media and select or enter slab comments before submitting.");
    } else {
      _showSubmitConfirmationDialog(context1);
    }
  }

  void _handleIssueFormSubmit(BuildContext context1) {
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
      _showIssueSubmitConfirmationDialog(context1);
    }
  }

  void _showNoticeDialog(BuildContext context, String message, {VoidCallback? onDismiss}) {
    final isMobile = context.isMobile;
    bool actionTaken = false;
    showDialog<void>(
      context: context,
      barrierDismissible: onDismiss == null,
      builder: (dialogContext) {
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
              onTap: () {
                actionTaken = true;
                Navigator.of(dialogContext).pop();
                if (onDismiss != null) {
                  onDismiss();
                }
              },
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
    ).then((_) {
      if (!actionTaken && onDismiss != null) {
        onDismiss();
      }
    });
  }

  void _showSubmitConfirmationDialog(BuildContext context1) {
    final isMobile = context1.isMobile;
    showDialog<void>(
      barrierDismissible: true,
      context: context1,
      builder: (context2) {
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
            "Are you sure you want to submit this slab report?",
            style: TextStyle(fontSize: isMobile ? 13 : 15, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          actions: [
            InkWell(
              onTap: () => Navigator.of(context2).pop(),
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
                Navigator.of(context2).pop();
                CustomLoading.progressDialog(isLoading: true, context: context1);
                try {
                  await setSlabReport();
                  await getLabReport();
                } catch (e) {
                  if (kDebugMode) print("Error submitting slab report: $e");
                }
                if (mounted) {
                  setState(() {
                    widget.isSlabExist = true;
                    arrayFiles = [];
                    arrayFilesBytes = [];
                  });
                  CustomLoading.progressDialog(isLoading: false, context: context1);
                  _showNoticeDialog(
                    context1,
                    "You have successfully submitted the slab report.",
                    onDismiss: () {
                      Navigator.of(context1).pop({
                        'submitted': true,
                        'slabId': widget.slabId,
                        'checklistId': widget.plist?.slabCheckId,
                      });
                    },
                  );
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

  void _showIssueSubmitConfirmationDialog(BuildContext context1) {
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
                  await setSlabIssueReportSubmit();
                  await fetchRccStructureIssueReportRequest();
                } catch (e) {
                  if (kDebugMode) print("Error submitting slab issue report: $e");
                }
                if (mounted) {
                  CustomLoading.progressDialog(isLoading: false, context: context1);
                  _showNoticeDialog(
                    context1,
                    "You have successfully submitted the slab issue report.",
                    onDismiss: () {
                      Navigator.of(context1).pop({
                        'submitted': true,
                        'slabId': widget.slabId,
                        'checklistId': widget.plist?.slabCheckId,
                      });
                    },
                  );
                  setState(() {
                    datIssueController = [
                      AddIssue(
                        issueTextEditingController: TextEditingController(),
                        selectReportingToStrings: "",
                        selectReportingToController: TextEditingController(),
                      ),
                    ];
                  });
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
