import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stallion/models/dprPreviewHtml.dart';
import 'package:stallion/models/get_edit_dpr.dart';
import 'package:stallion/models/get_project_dpr_contractor.dart';
import 'package:stallion/models/rcc_dpr_api_models.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/views/rccstructure/dpr/preview_dpr.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AddDprScreen extends StatefulWidget {
  AddDprScreen({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    this.title,
    this.slabId,
    this.slabNumber,
    this.project_dpr_id = '',
    this.dprItem,
  });
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? title;
  final String? slabId;
  final String? slabNumber;
  String? project_dpr_id = '';
  final DprItem? dprItem;

  @override
  State<AddDprScreen> createState() => _AddDprScreenState();
}

class _AddDprScreenState extends State<AddDprScreen> {
  int? _editingIndex;
  TextEditingController _editingController = TextEditingController();

  Future<void> _selectInTime(BuildContext context, int controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        dprStaffList?[controller].inTime =
            pickedTime.format(context); // Formatting time
      });
    }
  }

  Future<void> _selectOutTime(BuildContext context, int controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        dprStaffList?[controller].outTime =
            pickedTime.format(context); // Formatting time
      });
    }
  }

  String formatDate(DateTime dateTime) {
    // Format the DateTime as "yyyy-MM-dd" (e.g., "2023-09-01")
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  }

  final TextEditingController _slabNumberController = TextEditingController();
  final TextEditingController _dificultiesNrequirementsController =
      TextEditingController();
  final TextEditingController _visitorsController = TextEditingController();
  final TextEditingController _workTypeController = TextEditingController();
  final TextEditingController _contractorController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _workProgressAddController =
      TextEditingController();
  final TextEditingController _customCategoryController =
      TextEditingController();
  final GlobalKey<FormState> _formKeyCustomCategory = GlobalKey<FormState>();
  // List<WorkProgress>? workProgress = [];
  TextEditingController editingController = TextEditingController();
  TextEditingController activityModalController = TextEditingController();

  String selectedSortBy = "";
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final NetworkHandler _networkHandler = NetworkHandler();
  List<PlatformFile> arrayFiles = [];
  List<Uint8List?> arrayFilesBytes = [];
  List<ContrctorList>? contrctorList = [];
  List<ContrctorList> searchcontrctorList(
      List<ContrctorList> objects, String query) {
    query = query
        .toLowerCase(); // Convert the query to lowercase for case-insensitive search
    return objects
        .where((obj) =>
            obj.companyName!.toLowerCase().contains(query) ||
            obj.companyName.toString().contains(query))
        .toList();
  }

  List<Skill> searchActivitiesList(List<Skill> objects, String query) {
    query = query
        .toLowerCase(); // Convert the query to lowercase for case-insensitive search
    return objects
        .where((obj) =>
            obj.mstWorkName!.toLowerCase().contains(query) ||
            obj.mstWorkName.toString().contains(query))
        .toList();
  }

  List<Skill>? skillResponse;
  List<CustomType>? customType = [];

  List<WorkProgress>? workProgressList = [];
  List<DprStockList>? dprStockList = [];

  ResponseGetProjectDprContractor? responseGetProjectDprContractor;
  bool isLoad = false;
  DateTime? _selectedFormDate;
  TextEditingController fromDateControler = TextEditingController();
  List<OrderDeliveredList>? orderDeliveredListResponse = [];
  List<DprYesterdayActivity>? dprYesterdayActivity = [];
  List<DprStaffList>? dprStaffList = [];
  List<DprYesterdayActivity>? todaysPlanActivitySelected = [];
  List<String>? uploadImage = [];
  List<DprDocument> existingDocuments = [];
  DprItem? originalDpr;
  List<ContractProgress>? contractProgress = [];
  List<OrderDeliveredList>? orderDeliveredList = [];

  Future<String?> _showMediaSourcePickerSheet(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Upload Documents / Media",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
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
                    "Capture a live photo using camera",
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
                    child: const Icon(Icons.videocam_rounded, color: Colors.black87),
                  ),
                  title: const Text(
                    "Record Video (Camera)",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    "Record a video using camera",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop('video_camera'),
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
                    "Select images from photo library",
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
                    "Choose from Files (PDF, Video, Images)",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    "Browse documents, PDFs, videos, and images",
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

  Future<void> _pickMediaDocument() async {
    final bool isMobileDevice = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    if (isMobileDevice) {
      final source = await _showMediaSourcePickerSheet(context);
      if (source == null) return;

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
              arrayFiles.add(file);
              arrayFilesBytes.add(bytes);
            });
          }
        } catch (e) {
          if (kDebugMode) print("Camera picker error: $e");
        }
      } else if (source == 'video_camera') {
        try {
          final ImagePicker picker = ImagePicker();
          final XFile? video = await picker.pickVideo(
            source: ImageSource.camera,
          );
          if (video != null) {
            final bytes = await video.readAsBytes();
            final length = await video.length();
            final file = PlatformFile(
              name: video.name,
              path: video.path,
              size: length,
              bytes: bytes,
            );
            setState(() {
              arrayFiles.add(file);
              arrayFilesBytes.add(bytes);
            });
          }
        } catch (e) {
          if (kDebugMode) print("Video camera picker error: $e");
        }
      } else if (source == 'gallery') {
        try {
          final ImagePicker picker = ImagePicker();
          final List<XFile> photos = await picker.pickMultiImage(imageQuality: 85);
          if (photos.isNotEmpty) {
            for (var p in photos) {
              final bytes = await p.readAsBytes();
              final length = await p.length();
              final file = PlatformFile(
                name: p.name,
                path: p.path,
                size: length,
                bytes: bytes,
              );
              setState(() {
                arrayFiles.add(file);
                arrayFilesBytes.add(bytes);
              });
            }
          }
        } catch (e) {
          if (kDebugMode) print("Gallery picker error: $e");
        }
      } else if (source == 'files') {
        await _pickFromFiles();
      }
    } else {
      await _pickFromFiles();
    }
  }

  Future<void> _pickFromFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'jpg', 'jpeg', 'png', 'gif', 'webp', 'mp4', 'mov', 'pdf',
          'JPG', 'JPEG', 'PNG', 'GIF', 'WEBP', 'MP4', 'MOV', 'PDF',
        ],
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            arrayFiles.add(file);
            arrayFilesBytes.add(file.bytes);
          }
        });
      }
    } catch (e) {
      if (kDebugMode) print("File picker error: $e");
    }
  }

  Future<void> wsSetdprpreview() async {
    if (_workTypeController.text.trim().isEmpty) {
      commonAleertModal(textTitle: "Please enter Work Type.");
      return;
    }
    if (_contractorController.text.trim().isEmpty) {
      commonAleertModal(textTitle: "Please Select Contractor.");
      return;
    }

    CustomLoading.progressDialog(isLoading: true, context: context);

    try {
      final token = await _networkHandler.getToken();
      final bool isUpdating =
          widget.project_dpr_id != null && widget.project_dpr_id!.isNotEmpty;
      final String url = isUpdating
          ? AppUrl.updateDpr(widget.project_dpr_id!)
          : AppUrl.createDpr;

      final request =
          http.MultipartRequest(isUpdating ? 'PUT' : 'POST', Uri.parse(url));

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final slabIdNum = int.tryParse(widget.slabId ?? '0') ?? 0;

      // Contractors
      final List<Map<String, dynamic>> contractorsList = [];
      if (contrctorList != null) {
        for (final c in contrctorList!) {
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
      if (skillResponse != null) {
        for (final s in skillResponse!) {
          if (s.isSelected == true) {
            final sId =
                int.tryParse(s.mstWorkId?.toString() ?? '0') ?? s.mstWorkId;
            if (sId != null && sId != 0) {
              selectedSkillsList.add(sId);
            }
          }
        }
      }

      // Employee Details
      final List<Map<String, dynamic>> employeeDetailsList = [];
      if (customType != null) {
        for (final ct in customType!) {
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
      if (dprStaffList != null) {
        for (final staff in dprStaffList!) {
          if (staff.staffName != null && staff.staffName!.trim().isNotEmpty) {
            teamMembersList.add({
              'name': staff.staffName!.trim(),
              'in_time': staff.inTime != null && staff.inTime!.isNotEmpty
                  ? staff.inTime!
                  : '09:00',
              'out_time': staff.outTime != null && staff.outTime!.isNotEmpty
                  ? staff.outTime!
                  : '18:00',
            });
          }
        }
      }

      // Activities
      final List<Map<String, dynamic>> activitiesList = [];
      if (todaysPlanActivitySelected != null) {
        for (final act in todaysPlanActivitySelected!) {
          final desc = act.descriptionVal.isNotEmpty
              ? act.descriptionVal
              : (act.description ?? '');
          if (desc.trim().isNotEmpty) {
            String targetDate =
                act.targetdate != null && act.targetdate!.isNotEmpty
                    ? act.targetdate!
                    : formatDate(_selectedFormDate ?? DateTime.now());

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
      final List<Map<String, dynamic>> workProgList = [];
      if (workProgressList != null) {
        for (final wp in workProgressList!) {
          if (wp.title != null && wp.title!.trim().isNotEmpty) {
            workProgList.add({
              'progress': wp.title!.trim(),
            });
          }
        }
      }

      final Map<String, dynamic> fullPayload = {
        'is_submitted': false,
        'slab_id': slabIdNum,
        'dpr_date': formatDate(_selectedFormDate ?? DateTime.now()),
        'work_description': _workTypeController.text.trim(),
        'contractors': contractorsList,
        'selected_skills': selectedSkillsList,
        'issue_description': _dificultiesNrequirementsController.text.trim(),
        'visitors': _visitorsController.text.trim(),
        'employee_details': employeeDetailsList,
        'team_members': teamMembersList,
        'activities': activitiesList,
        'work_progress': workProgList,
      };

      final Map<String, dynamic> payloadToSend;
      final baselineDpr = originalDpr ?? widget.dprItem;
      if (isUpdating && baselineDpr != null) {
        payloadToSend = computeDprDiffPayload(
          original: baselineDpr,
          currentPayload: fullPayload,
          isSubmitted: false,
        );
      } else {
        payloadToSend = fullPayload;
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
      for (final file in arrayFiles) {
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
        showDialog<void>(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            final bool isMobile = MediaQuery.of(context).size.width < 768;
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
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                color: Colors.black,
                child: const Text(
                  "Saved Successfully",
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
                      "Your DPR report has been saved as draft successfully.",
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
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
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
      } else {
        String msg = "Failed to save draft (${response.statusCode})";
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
            content: Text("Error saving draft: $e"),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<ResponseGetProjectDprContractor?> fetchGetAllDprlist() async {
    CustomLoading.progressDialog(isLoading: true, context: context);

    try {
      final String projectId = widget.projectId ?? '';

      // 1. Fetch Contractors from API 2: /dev/contractor-management/project/:projectId
      if (projectId.isNotEmpty) {
        final contractorUrl = AppUrl.getProjectContractors(projectId);
        final contractorRes = await apiNetworkHandler.get(contractorUrl);

        if (contractorRes.statusCode == 200 || contractorRes.statusCode == 201) {
          final decoded = json.decode(contractorRes.body);
          final contractorsResponse = ProjectContractorsResponse.fromJson(decoded);

          if (contractorsResponse.success && contractorsResponse.data != null) {
            final List<ContrctorList> mappedContractors = [];
            for (var c in contractorsResponse.data!.contractors) {
              mappedContractors.add(
                ContrctorList(
                  companyId: c.id,
                  companyName: c.companyName,
                  skill: c.assignedSkills.map((s) => Skill(
                    mstWorkId: s.id,
                    mstWorkName: s.name,
                    isSelected: false,
                  )).toList(),
                  isSelected: false,
                  count: '',
                  isTextEditingController: TextEditingController(),
                ),
              );
            }

            setState(() {
              contrctorList = mappedContractors;
            });
          }
        }

        // 2. Fetch DPR Types from API 3: /rcc/dpr-types/project/:projectId
        final typesUrl = AppUrl.getDprTypes(projectId);
        final typesRes = await apiNetworkHandler.get(typesUrl);

        if (typesRes.statusCode == 200 || typesRes.statusCode == 201) {
          final decodedTypes = json.decode(typesRes.body);
          final dprTypesResponse = DprTypesResponse.fromJson(decodedTypes);

          if (dprTypesResponse.success && dprTypesResponse.data != null) {
            final List<CustomType> mappedTypes = [];
            for (var t in dprTypesResponse.data!.dprTypes) {
              if (t.isActive && !t.isDeleted) {
                mappedTypes.add(
                  CustomType(
                    id: t.id,
                    name: t.name,
                    value: '',
                    flag: '',
                    description: '',
                    editingTextController: TextEditingController(),
                  ),
                );
              }
            }

            setState(() {
              customType = mappedTypes;
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print("Fetch Contractors / DPR Types Error: $e");
    } finally {
      CustomLoading.progressDialog(isLoading: false, context: context);
      if (widget.dprItem != null) {
        populateDprData(widget.dprItem!);
      } else if (widget.project_dpr_id != null &&
          widget.project_dpr_id!.isNotEmpty) {
        getProjectSaveDpr();
      }
    }
    return null;
  }

  void populateDprData(DprItem dpr) {
    setState(() {
      originalDpr = dpr;
      // 1. DPR Date
      if (dpr.dprDate != null && dpr.dprDate!.isNotEmpty) {
        try {
          _selectedFormDate = DateTime.parse(dpr.dprDate!);
          fromDateControler.text =
              DateFormat('dd/MM/yyyy').format(_selectedFormDate!);
        } catch (_) {
          fromDateControler.text = dpr.dprDate!;
        }
      }

      // 2. Work Description, Difficulties & Visitors
      _workTypeController.text = dpr.workDescription ?? '';
      _dificultiesNrequirementsController.text = dpr.issueDescription ?? '';
      _visitorsController.text = dpr.visitors ?? '';

      // 3. Contractors & Assigned Skills
      String tempContractorStr = '';
      List<Skill> skillTemp = [];
      List<Skill> uniqueData = [];

      if (contrctorList != null && contrctorList!.isNotEmpty) {
        for (var c in contrctorList!) {
          final matching = dpr.contractors.firstWhere(
            (record) => record.contractorId.toString() == c.companyId.toString(),
            orElse: () => DprContractorRecord(id: '', contractorId: '', labourCount: 0),
          );

          if (matching.contractorId.isNotEmpty) {
            c.isSelected = true;
            c.count = matching.labourCount > 0
                ? matching.labourCount.toString()
                : '';
            c.isTextEditingController =
                TextEditingController(text: c.count ?? '');

            if (c.skill != null) {
              skillTemp.addAll(c.skill!);
            }

            final countStr = (c.count != null && c.count!.trim().isNotEmpty)
                ? ' (${c.count})'
                : '';
            if (tempContractorStr.isNotEmpty) {
              tempContractorStr += ', ${c.companyName}$countStr';
            } else {
              tempContractorStr = '${c.companyName}$countStr';
            }
          }
        }

        // Deduplicate contractor skills
        for (var item in skillTemp) {
          bool isDuplicate = false;
          for (var u in uniqueData) {
            if (item.mstWorkId == u.mstWorkId ||
                item.mstWorkName == u.mstWorkName) {
              isDuplicate = true;
              break;
            }
          }
          if (!isDuplicate) {
            uniqueData.add(item);
          }
        }
        skillResponse = uniqueData;
        _contractorController.text = tempContractorStr;

        // Mark selected skills
        String tempSkillStr = '';
        if (skillResponse != null) {
          for (var s in skillResponse!) {
            final isSelectedSkill = dpr.selectedSkills.any(
              (sel) =>
                  sel.skillId.toString() == s.mstWorkId.toString() ||
                  (sel.skill != null &&
                      (sel.skill!.id.toString() == s.mstWorkId.toString() ||
                          sel.skill!.name.toString().toLowerCase() ==
                              s.mstWorkName.toString().toLowerCase())),
            );
            if (isSelectedSkill) {
              s.isSelected = true;
              if (tempSkillStr.isNotEmpty) {
                tempSkillStr += ', ${s.mstWorkName}';
              } else {
                tempSkillStr = s.mstWorkName ?? '';
              }
            }
          }
        }
        _activityController.text = tempSkillStr;
      }

      // 4. DPR Types / Labour Details
      customType ??= [];

      // Map matching employee details to existing categories
      for (var ct in customType!) {
        final matchingEmp = dpr.employeeDetails.firstWhere(
          (emp) =>
              (emp.dprTypeId != null &&
                  emp.dprTypeId!.isNotEmpty &&
                  emp.dprTypeId.toString() == ct.id.toString()) ||
              (emp.dprType != null &&
                  (emp.dprType!.id.toString() == ct.id.toString() ||
                      emp.dprType!.name.toLowerCase() ==
                          ct.name.toString().toLowerCase())),
          orElse: () => DprEmployeeDetail(id: '', employeeCount: 0),
        );

        final remarks = matchingEmp.remarks;
        if (matchingEmp.id.isNotEmpty ||
            matchingEmp.employeeCount > 0 ||
            (remarks != null && remarks.isNotEmpty)) {
          ct.value = matchingEmp.employeeCount > 0
              ? matchingEmp.employeeCount.toString()
              : '';
          ct.editingTextController =
              TextEditingController(text: ct.value ?? '');
          if (remarks != null && remarks.isNotEmpty) {
            ct.description = remarks;
            ct.flag = "true";
          }
        }
      }

      // Add any employee_details that are not in customType (e.g. custom categories / types)
      for (var emp in dpr.employeeDetails) {
        final alreadyExists = customType!.any((ct) =>
            (emp.dprTypeId != null &&
                emp.dprTypeId!.isNotEmpty &&
                ct.id.toString() == emp.dprTypeId.toString()) ||
            (emp.dprType != null &&
                (ct.id.toString() == emp.dprType!.id.toString() ||
                    ct.name.toString().toLowerCase() ==
                        emp.dprType!.name.toLowerCase())));

        if (!alreadyExists) {
          final typeName = emp.dprType?.name ?? 'Custom Category';
          final countVal =
              emp.employeeCount > 0 ? emp.employeeCount.toString() : '';
          final remarks = emp.remarks;
          customType!.add(
            CustomType(
              id: emp.dprTypeId ?? emp.dprType?.id ?? '',
              name: typeName,
              value: countVal,
              flag: (remarks != null && remarks.isNotEmpty) ? 'true' : '',
              description: remarks ?? '',
              editingTextController: TextEditingController(text: countVal),
            ),
          );
        }
      }

      // 5. Team Members (Staff)
      if (dpr.teamMembers.isNotEmpty) {
        dprStaffList = dpr.teamMembers
            .map((m) => DprStaffList(
                  id: m.id ?? '1',
                  staffName: m.name,
                  inTime: m.inTime,
                  outTime: m.outTime,
                ))
            .toList();
      }

      // 6. Today's Planned Activities
      if (dpr.activitiesDetails.isNotEmpty) {
        todaysPlanActivitySelected = dpr.activitiesDetails.map((act) {
          String formattedDate = '';
          if (act.targetCompletionDate != null &&
              act.targetCompletionDate!.isNotEmpty) {
            try {
              DateTime dt = DateTime.parse(act.targetCompletionDate!);
              formattedDate = DateFormat('dd/MM/yyyy').format(dt);
            } catch (_) {
              formattedDate = act.targetCompletionDate!;
            }
          }
          return DprYesterdayActivity(
            id: act.id,
            description: act.activityName,
            descriptionVal: act.activityName,
            targetdate: formattedDate,
            dprFlag: '1',
            isSelected: act.isCompleted,
            dprActivityController:
                TextEditingController(text: act.activityName),
            dprActivityDateController:
                TextEditingController(text: formattedDate),
          );
        }).toList();
      }

      // 7. Work Progress
      if (dpr.workProgress.isNotEmpty) {
        workProgressList = dpr.workProgress
            .map((w) => WorkProgress(
                  id: w.id ?? '',
                  title: w.progress,
                ))
            .toList();
      }

      // 8. Documents
      if (dpr.documents.isNotEmpty) {
        existingDocuments = List<DprDocument>.from(dpr.documents);
        uploadImage = dpr.documents
            .map((doc) =>
                doc.fileUrl.isNotEmpty ? doc.fileUrl : doc.fileName)
            .toList();
      }
    });
  }

  Future<void> deleteDocUploaded({
    required String document_name,
    required String project_dpr_id,
    DprDocument? doc,
  }) async {
    if (doc != null && doc.id.isNotEmpty) {
      final url = AppUrl.deleteDprDocument(doc.id);
      final response = await apiNetworkHandler.delete(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          existingDocuments.remove(doc);
          uploadImage?.remove(doc.fileUrl);
          uploadImage?.remove(doc.fileName);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to delete document")),
          );
        }
      }
      return;
    }

    Map<String, String> data = {
      "project_dpr_id": project_dpr_id,
      "document_name": document_name,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.wsDprDocumentRemove, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        uploadImage?.remove(document_name);
        existingDocuments.removeWhere((d) =>
            d.fileName == document_name || d.fileUrl == document_name);
      });
    }
  }

  Future<void> getProjectSaveDpr() async {
    if (widget.slabId == null || widget.slabId!.isEmpty) return;
    try {
      final url = AppUrl.getDprsForSlab(widget.slabId!);
      final response = await apiNetworkHandler.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        final dprListRes = DprListResponse.fromJson(decoded);
        if (dprListRes.success && dprListRes.data != null) {
          final matchingDpr = dprListRes.data!.dprs.firstWhere(
            (d) => d.id == widget.project_dpr_id,
            orElse: () => DprItem(id: '', isSubmitted: false),
          );
          if (matchingDpr.id.isNotEmpty) {
            populateDprData(matchingDpr);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print("getProjectSaveDpr error: $e");
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchGetAllDprlist();
    });

    setState(() {
      dprStaffList?.add(DprStaffList(
        id: "1",
        staffName: '',
        inTime: '',
        outTime: '',
      ));
      _slabNumberController.text =
          //  widget.towarName?.length != 0
          // ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
          // :
          widget.title ?? '';

      _selectedFormDate = DateTime.now();
      fromDateControler.text =
          DateFormat('dd/MM/yyyy').format(_selectedFormDate!);

      todaysPlanActivitySelected?.add(DprYesterdayActivity(
          dprFlag: '1',
          dprActivityDateController: TextEditingController(),
          isSelected: false,
          id: "1",
          targetdate: "",
          description: "",
          descriptionVal: '',
          dprActivityController: TextEditingController()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom > 0
          ? Container(
              color: const Color(0xfff1f3f5),
              child: SafeArea(
                top: false,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xfff8f9fa),
                    border: Border(
                      top: BorderSide(color: Color(0xffd1d5db), width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tap Done to dismiss",
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      InkWell(
                        onTap: () => FocusScope.of(context).unfocus(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: const Text(
                            "Done",
                            style: TextStyle(
                              color: Color(0xff007AFF),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12.0 : 20.0,
            vertical: isMobile ? 8.0 : 12.0,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.black12)),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    wsSetdprpreview();
                  },
                  child: Container(
                    height: isMobile ? 42 : 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
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
                        "SAVE",
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
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () {
                    print(jsonEncode(dprYesterdayActivity));
                    inspect(todaysPlanActivitySelected);
                    if ((todaysPlanActivitySelected?[0].descriptionVal != "" ||
                            todaysPlanActivitySelected?[0].targetdate != '') &&
                        _workTypeController.text != "" &&
                        _contractorController.text != '' &&
                        _activityController.text != '') {
                      String formatDate(DateTime dateTime) {
                        return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
                      }

                      for (int i = 0; i < todaysPlanActivitySelected!.length; i++) {
                        setState(() {
                          todaysPlanActivitySelected?[i].id = (i + 1).toString();
                        });
                      }
                      List<DprStaffList>? dprStaffListTemp = [];

                      for (int i = 0; i < dprStaffList!.length; i++) {
                        if (dprStaffList![i].staffName != '') {
                          dprStaffListTemp.add(dprStaffList![i]);
                        }
                      }

                      print(jsonEncode(dprYesterdayActivity));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return PreviewDPRScreen(
                              dprItem: originalDpr ?? widget.dprItem,
                              dprStockList: dprStockList,
                              dprStaffList: dprStaffListTemp,
                              visitors: _visitorsController.text,
                              project_dpr_id: widget.project_dpr_id,
                              dpr_difficulti_requirement:
                                  _dificultiesNrequirementsController.text,
                              arrayFilesBytes: arrayFilesBytes,
                              arrayFiles: arrayFiles,
                              projectId: widget.projectId!,
                              projectName: widget.projectName!,
                              towarName: widget.towarName!,
                              towarId: widget.towarId,
                              contrctorList: contrctorList,
                              customType: customType,
                              workProgressList: workProgressList,
                              slabId: widget.slabId,
                              slabNo: widget.slabNumber,
                              dprDate:
                                  formatDate(_selectedFormDate ?? DateTime.now()),
                              skillResponse: skillResponse,
                              workType: _workTypeController.text,
                              orderDeliveredList: orderDeliveredListResponse,
                              dprYesterdayActivity: dprYesterdayActivity,
                              todaysPlanActivitySelected: todaysPlanActivitySelected,
                              dificultiesNrequirements:
                                  _dificultiesNrequirementsController.text,
                              contractProgress: contractProgress,
                            );
                          },
                        ),
                      ).then((value) => {});
                    } else {
                      if (_workTypeController.text == "") {
                        commonAleertModal(textTitle: "Please enter Work Type.");
                      } else if (_contractorController.text == '') {
                        commonAleertModal(textTitle: "Please Select Contractor.");
                      } else if (_activityController.text == '') {
                        commonAleertModal(textTitle: "Please Select Activity.");
                      } else {
                        commonAleertModal(
                            textTitle: "Please enter Today's Plan Activity.");
                      }
                    }
                  },
                  child: Container(
                    height: isMobile ? 42 : 48,
                    decoration: BoxDecoration(
                      color: Colors.black,
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
                        "PREVIEW D.P.R",
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
            ],
          ),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.towarName!.isNotEmpty
              ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
              : widget.projectName!.toUpperCase(),
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
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // Fixed SubHeader Section with Centered Slab Title
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: isMobile ? 10 : 12,
                ),
                color: Colors.white,
                child: Text(
                  '${widget.title} - D.P.R',
                  style: TextStyle(
                    fontSize: isMobile ? 13.5 : 15.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(height: 1.0, color: Colors.black12),

              // Scrollable Form Content
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10.0 : 24.0,
                  vertical: isMobile ? 10.0 : 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Form inputs in Card Container
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 10.0 : 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffe2e8f0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    slabNo(isMobile),
                    selectDate(isMobile),
                    workType(isMobile),
                    contractor(isMobile),
                    activity(isMobile),
                    dificultiesNrequirements(isMobile),
                    visitorss(isMobile),

                    for (var i = 0; i < customType!.length; i++)
                      dynamicCustomType(
                        data: customType![i],
                        indexx: i,
                        title: customType?[i].name ?? '',
                        hintText: 'Enter ${customType?[i].name}',
                        textEditingController: customType?[i].editingTextController ??
                            TextEditingController(),
                        titleVal: customType?[i].value ?? '',
                        isMobile: isMobile,
                      ),
                    addCustomCategory(isMobile),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Team Members Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 10.0 : 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffe2e8f0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    addStaff(isMobile),
                    const SizedBox(height: 8),
                    addStaffBtn(isMobile),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Yesterday Work Done & Today's Plan Card
              if (dprYesterdayActivity!.isNotEmpty || todaysPlanActivitySelected!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isMobile ? 14.0 : 20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffe2e8f0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (dprYesterdayActivity!.isNotEmpty) ...[
                        yesterdayWorkDone(isMobile),
                        const SizedBox(height: 8),
                        addToTodaysPlan(isMobile),
                        const SizedBox(height: 10),
                        const Divider(color: Color(0xffe2e8f0)),
                        const SizedBox(height: 10),
                      ],
                      todaysPlanActivity(isMobile),
                      const SizedBox(height: 8),
                      addPlannedActivity(isMobile),
                    ],
                  ),
                ),

              if (dprStockList!.isNotEmpty) rawMaterialDelivered(),

              if (orderDeliveredList!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xffe2e8f0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xfff8fafc),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                          border: Border(bottom: BorderSide(color: Color(0xffe2e8f0))),
                        ),
                        child: const Text(
                          "Order Delivered at Site",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xff1a202c)),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowHeight: 40,
                          dataRowMinHeight: 38,
                          dataRowMaxHeight: 48,
                          headingRowColor: WidgetStateProperty.all(const Color(0xfff1f5f9)),
                          columns: const [
                            DataColumn(label: Text('Grade Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                            DataColumn(label: Text('Del. QTY', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                            DataColumn(label: Text('Cons./Issued', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                          ],
                          rows: [
                            for (int t = 0; t < orderDeliveredList!.length; t++)
                              DataRow(
                                cells: [
                                  DataCell(Text(orderDeliveredList?[t].name ?? '', style: const TextStyle(fontSize: 13))),
                                  DataCell(Text('${orderDeliveredList?[t].totalQuantity} ${orderDeliveredList?[t].unit}', style: const TextStyle(fontSize: 13))),
                                  DataCell(Text('${orderDeliveredList?[t].consumeQuantity} ${orderDeliveredList?[t].unit}', style: const TextStyle(fontSize: 13))),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              if (contractProgress!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xffe2e8f0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xfff8fafc),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                          border: Border(bottom: BorderSide(color: Color(0xffe2e8f0))),
                        ),
                        child: const Text(
                          "Contract Progress",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xff1a202c)),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowHeight: 40,
                          dataRowMinHeight: 38,
                          dataRowMaxHeight: 48,
                          headingRowColor: WidgetStateProperty.all(const Color(0xfff1f5f9)),
                          columns: const [
                            DataColumn(label: Text('Company', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                            DataColumn(label: Text('Skills', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                            DataColumn(label: Text('Cert. %', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                            DataColumn(label: Text('Total. %', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                          ],
                          rows: [
                            for (int u = 0; u < contractProgress!.length; u++)
                              DataRow(
                                cells: [
                                  DataCell(Text(contractProgress?[u].mstCompanyName ?? '', style: const TextStyle(fontSize: 13))),
                                  DataCell(Text(contractProgress?[u].skillName ?? '', style: const TextStyle(fontSize: 13))),
                                  DataCell(Text(contractProgress?[u].quantification ?? '', style: const TextStyle(fontSize: 13))),
                                  DataCell(Text('${contractProgress?[u].woTotalQuantification} / ${contractProgress?[u].woTotalPercentage}', style: const TextStyle(fontSize: 13))),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              // Work Progress & Accomplishments Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: EdgeInsets.all(isMobile ? 14.0 : 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffe2e8f0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Work Progress & Accomplishments",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff1a202c),
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (int d = 0; d < workProgressList!.length; d++)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xfff8fafc),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xffe2e8f0)),
                        ),
                        child: Row(
                          children: [
                            _editingIndex == d
                                ? Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: Colors.grey.shade400),
                                        borderRadius: BorderRadius.circular(6.0),
                                      ),
                                      child: TextFormField(
                                        controller: _editingController,
                                        autofocus: true,
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                : Expanded(
                                    child: Text(
                                      '${d + 1}. ${workProgressList?[d].title}',
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                            const SizedBox(width: 8),

                            /// Save / Edit button
                            _editingIndex == d
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      minimumSize: Size.zero,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (_editingController.text.trim().isNotEmpty) {
                                          workProgressList?[d].title = _editingController.text.trim();
                                          _editingIndex = null;
                                          _editingController.clear();
                                        }
                                      });
                                    },
                                    child: const Text("SAVE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.edit, size: 16, color: Colors.blueGrey),
                                    onPressed: () {
                                      setState(() {
                                        _editingIndex = d;
                                        _editingController.text = workProgressList?[d].title ?? '';
                                      });
                                    },
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(6),
                                  ),

                            /// Delete button
                            IconButton(
                              icon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  if (_editingIndex == d) {
                                    _editingIndex = null;
                                    _editingController.clear();
                                  }
                                  workProgressList?.removeAt(d);
                                });
                              },
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    workProgressAdd(isMobile),
                  ],
                ),
              ),

              // Upload Files Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: EdgeInsets.all(isMobile ? 14.0 : 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffe2e8f0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Upload Documents / Media",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff1a202c),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: _pickMediaDocument,
                            child: Image.asset(
                              'images/projectmanagement/img5.png',
                              height: 100,
                              width: 100,
                            ),
                          ),
                          const SizedBox(width: 10),
                          for (int j = 0; j < arrayFiles.length; j++) ...[
                            Builder(
                              builder: (context) {
                                final file = arrayFiles[j];
                                final ext = (file.extension ?? (file.name.contains('.') ? file.name.split('.').last : '')).toLowerCase();
                                final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif'].contains(ext);
                                final isVideo = ['mp4', 'mov', 'm4v', 'avi', 'mkv'].contains(ext);
                                final isPdf = ext == 'pdf';

                                Widget previewWidget;
                                if (isImage) {
                                  previewWidget = ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: file.path != null && File(file.path!).existsSync()
                                        ? Image.file(
                                            File(file.path!),
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          )
                                        : (file.bytes != null
                                            ? Image.memory(
                                                file.bytes!,
                                                height: 100,
                                                width: 100,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                height: 100,
                                                width: 100,
                                                color: Colors.grey.shade200,
                                                child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                              )),
                                  );
                                } else if (isVideo) {
                                  previewWidget = Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade900,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.videocam_rounded,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                        const SizedBox(height: 4),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Text(
                                            file.name,
                                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (isPdf) {
                                  previewWidget = InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) {
                                            return PdfViewer(
                                              isLocalFileUpload: true,
                                              localFiles: file.path,
                                              fileName: file.name,
                                              fileUrl: file.path,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                      ),
                                      child: Image.asset(
                                        'images/projectmanagement/pdf.png',
                                        width: 100,
                                        height: 100,
                                      ),
                                    ),
                                  );
                                } else {
                                  previewWidget = Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.insert_drive_file_outlined,
                                          color: Colors.black54,
                                          size: 38,
                                        ),
                                        const SizedBox(height: 4),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Text(
                                            file.name,
                                            style: const TextStyle(color: Colors.black87, fontSize: 10),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return Container(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      previewWidget,
                                      Positioned(
                                        right: -8,
                                        top: -8,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              arrayFiles.removeAt(j);
                                              if (j < arrayFilesBytes.length) {
                                                arrayFilesBytes.removeAt(j);
                                              }
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],

                  // Existing Documents loaded from API
                  for (int i = 0; i < existingDocuments.length; i++)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        InkWell(
                          onTap: () async {
                            final doc = existingDocuments[i];
                            final fileUrl = doc.fileUrl;
                            final fileName = doc.fileName;
                            final mime = doc.mimeType?.toLowerCase() ?? '';
                            final ext = doc.extension?.toLowerCase() ?? '';

                            if (mime.contains('pdf') ||
                                ext == 'pdf' ||
                                fileName.toLowerCase().endsWith('.pdf') ||
                                fileUrl.toLowerCase().endsWith('.pdf')) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PdfViewer(
                                    fileName: fileName,
                                    fileUrl: fileUrl,
                                  ),
                                ),
                              );
                            } else if (mime.contains('video') ||
                                ext == 'mp4' ||
                                fileName.toLowerCase().endsWith('.mp4') ||
                                fileUrl.toLowerCase().endsWith('.mp4')) {
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
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            width: 140,
                            child: Column(
                              children: [
                                (existingDocuments[i].fileName.toLowerCase().endsWith('.pdf') ||
                                        existingDocuments[i].fileUrl.toLowerCase().endsWith('.pdf'))
                                    ? Image.asset(
                                        'images/projectmanagement/pdf.png',
                                        width: 100,
                                        height: 100,
                                      )
                                    : (existingDocuments[i].fileName.toLowerCase().endsWith('.mp4') ||
                                            existingDocuments[i].fileUrl.toLowerCase().endsWith('.mp4'))
                                        ? const Icon(
                                            Icons.video_camera_back,
                                            size: 80,
                                          )
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(6),
                                            child: Image.network(
                                              existingDocuments[i].fileUrl.startsWith('http')
                                                  ? existingDocuments[i].fileUrl
                                                  : '${AppUrl.dprUploadImg}${existingDocuments[i].fileName}',
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                width: 100,
                                                height: 100,
                                                color: Colors.grey.shade200,
                                                child: const Icon(Icons.broken_image, color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                const SizedBox(height: 4),
                                AppText(
                                  title: existingDocuments[i].fileName,
                                  fontSize: 12,
                                  overflow: TextOverflow.ellipsis,
                                )
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: InkWell(
                            onTap: () {
                              deleteDocUploaded(
                                document_name: existingDocuments[i].fileName,
                                project_dpr_id: widget.project_dpr_id ?? '',
                                doc: existingDocuments[i],
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
          ],
        ),
      ),
      ),
    );
  }

  Widget rawMaterialDelivered() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffe2e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xfff8fafc),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              border: Border(bottom: BorderSide(color: Color(0xffe2e8f0))),
            ),
            child: const Text(
              "Raw Material Inventory",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xff1a202c)),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 40,
              dataRowMinHeight: 38,
              dataRowMaxHeight: 48,
              headingRowColor: WidgetStateProperty.all(const Color(0xfff1f5f9)),
              columns: const [
                DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                DataColumn(label: Text('Stock In', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                DataColumn(label: Text('Consume', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                DataColumn(label: Text('Remaining', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              ],
              rows: [
                for (int s = 0; s < dprStockList!.length; s++)
                  DataRow(
                    cells: [
                      DataCell(Text(dprStockList![s].name ?? '', style: const TextStyle(fontSize: 13))),
                      DataCell(Text(dprStockList![s].stockIn ?? '', style: const TextStyle(fontSize: 13))),
                      DataCell(Text(dprStockList![s].stockConsume ?? '', style: const TextStyle(fontSize: 13))),
                      DataCell(Text(dprStockList![s].stockRemain ?? '', style: const TextStyle(fontSize: 13))),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFormRow({
    required String label,
    required bool isMobile,
    required Widget child,
    bool alignTop = false,
  }) {
    final bool hasAsterisk = label.contains('*');
    final String cleanLabel = label.replaceAll('*', '').trim();

    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 8.0 : 10.0),
      child: Row(
        crossAxisAlignment:
            alignTop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: isMobile ? 90.0 : 150.0,
            child: Padding(
              padding: EdgeInsets.only(top: alignTop ? (isMobile ? 8.0 : 10.0) : 0),
              child: Text.rich(
                TextSpan(
                  text: cleanLabel,
                  style: TextStyle(
                    fontSize: isMobile ? 12.0 : 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  children: [
                    if (hasAsterisk)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 6.0 : 10.0),
          Expanded(child: child),
        ],
      ),
    );
  }

  InputDecoration buildInputDecoration({
    required String hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Colors.black45,
        fontSize: 13.0,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.black87, width: 1.5),
      ),
    );
  }

  Widget slabNo(bool isMobile) {
    return buildFormRow(
      label: "Slab No.",
      isMobile: isMobile,
      child: TextFormField(
        enabled: false,
        controller: _slabNumberController,
        style: const TextStyle(color: Colors.black, fontSize: 13.5, fontWeight: FontWeight.w600),
        decoration: buildInputDecoration(hintText: 'Slab Number'),
      ),
    );
  }

  Widget selectDate(bool isMobile) {
    return buildFormRow(
      label: "Select Date",
      isMobile: isMobile,
      child: InkWell(
        onTap: () {
          _selectFromDate(context);
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: fromDateControler,
            style: const TextStyle(color: Colors.black, fontSize: 13.0),
            decoration: buildInputDecoration(
              hintText: 'Select Date',
              suffixIcon: const Icon(Icons.calendar_month_outlined, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedFormDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedFormDate) {
      setState(() {
        _selectedFormDate = picked;
        fromDateControler.text =
            DateFormat('dd/MM/yyyy').format(_selectedFormDate!);
      });
    }
  }

  Widget workType(bool isMobile) {
    return buildFormRow(
      label: "Work Type *",
      isMobile: isMobile,
      alignTop: true,
      child: TextFormField(
        maxLines: 2,
        controller: _workTypeController,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
        style: const TextStyle(color: Colors.black, fontSize: 13.5),
        decoration: buildInputDecoration(hintText: 'Enter Work Type'),
      ),
    );
  }

  Widget contractor(bool isMobile) {
    return buildFormRow(
      label: "Contractor *",
      isMobile: isMobile,
      child: InkWell(
        onTap: () {
          editingController.clear();
          selectContractorModal();
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: _contractorController,
            style: const TextStyle(color: Colors.black, fontSize: 13.5),
            decoration: buildInputDecoration(
              hintText: 'Select Contractor',
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
          ),
        ),
      ),
    );
  }

  selectContractorModal() {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    final ScrollController scrollController = ScrollController();
    return showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              titlePadding: EdgeInsets.zero,
              title: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                color: Colors.black,
                child: const Text(
                  'SELECT CONTRACTOR',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                if (MediaQuery.of(context).viewInsets.bottom > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xff007AFF).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xff007AFF).withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.keyboard_hide_outlined, size: 18, color: Color(0xff007AFF)),
                            SizedBox(width: 6),
                            Text(
                              "Done (Dismiss Keyboard)",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff007AFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              "CLOSE",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          var castingFor = "";
                          for (int i = 0; i < contrctorList!.length; i++) {
                            if (contrctorList![i].isSelected == true) {
                              if (castingFor.isEmpty) {
                                if (contrctorList![i].count != null &&
                                    contrctorList![i].count?.trim() != "" &&
                                    contrctorList![i].count?.length != 0) {
                                  castingFor =
                                      '${contrctorList![i].companyName} (${contrctorList![i].count})';
                                } else {
                                  castingFor = '${contrctorList![i].companyName}';
                                }
                              } else {
                                if (contrctorList?[i].count != null &&
                                    contrctorList![i].count?.trim() != "" &&
                                    contrctorList![i].count?.length != 0) {
                                  castingFor =
                                      "$castingFor, ${contrctorList?[i].companyName} (${contrctorList?[i].count})";
                                } else {
                                  castingFor =
                                      "$castingFor, ${contrctorList?[i].companyName}";
                                }
                              }
                            }
                          }
                          _contractorController.text = castingFor;
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              "ADD",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              content: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).unfocus(),
                child: SizedBox(
                  width: isMobile ? double.maxFinite : 500,
                  height: 380,
                child: contrctorList == null || contrctorList!.isEmpty
                    ? const Center(
                        child: Text(
                          "No contractors available",
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      )
                    : ScrollbarTheme(
                        data: ScrollbarThemeData(
                          thumbColor: MaterialStateProperty.all(Colors.grey.shade600),
                          trackColor: MaterialStateProperty.all(Colors.grey.shade200),
                          trackBorderColor: MaterialStateProperty.all(Colors.transparent),
                          radius: const Radius.circular(4),
                          thickness: MaterialStateProperty.all(5),
                        ),
                        child: Scrollbar(
                          controller: scrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          child: ListView.builder(
                            controller: scrollController,
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(right: 8),
                            itemCount: contrctorList!.length,
                            itemBuilder: (context, int indexFor) {
                              ContrctorList contrctorListTemp =
                                  contrctorList![indexFor];
                              TextEditingController _noOfLabourController =
                                  TextEditingController(text: contrctorListTemp.count ?? '');
                              return InkWell(
                                onTap: () {
                                  List<Skill> skillTemp = [];
                                  List<Skill> uniqueData = [];

                                  setState(() {
                                    if (contrctorListTemp.isSelected == true) {
                                      contrctorListTemp.isSelected = false;
                                      contrctorListTemp.count = "";
                                    } else {
                                      contrctorListTemp.isSelected = true;
                                    }
                                  });
                                  for (int i = 0; i < contrctorList!.length; i++) {
                                    if (contrctorList?[i].isSelected == true) {
                                      skillTemp = [
                                        ...skillTemp,
                                        ...?contrctorList?[i].skill
                                      ];
                                    }
                                  }
                                  if (skillTemp.isNotEmpty) {
                                    for (var item in skillTemp) {
                                      bool isDuplicate = false;
                                      for (var uniqueItem in uniqueData) {
                                        if (item.mstWorkName == uniqueItem.mstWorkName) {
                                          isDuplicate = true;
                                          break;
                                        }
                                      }
                                      if (!isDuplicate) {
                                        uniqueData.add(item);
                                      }
                                    }
                                    setState(() {
                                      skillResponse = uniqueData;
                                    });
                                  } else {
                                    setState(() {
                                      skillResponse?.clear();
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0, vertical: 8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              contrctorListTemp.companyName ?? '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          contrctorListTemp.isSelected == true
                                              ? const Icon(
                                                  Icons.check_circle,
                                                  size: 24,
                                                  color: Colors.green,
                                                )
                                              : const Icon(
                                                  Icons.circle_outlined,
                                                  size: 24,
                                                  color: Colors.grey,
                                                )
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Text(
                                            "No of Labour :",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          SizedBox(
                                            height: 38.0,
                                            width: 140,
                                            child: TextFormField(
                                              enabled: contrctorListTemp.isSelected == true,
                                              controller: _noOfLabourController,
                                              keyboardType: TextInputType.number,
                                              textInputAction: TextInputAction.done,
                                              onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                                              onChanged: (value) {
                                                contrctorListTemp.count = value;
                                              },
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 13.0,
                                              ),
                                              decoration: InputDecoration(
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                hintText: 'Enter count',
                                                hintStyle: const TextStyle(fontSize: 12, color: Colors.black38),
                                                filled: true,
                                                fillColor: contrctorListTemp.isSelected == true ? Colors.white : const Color(0xfff1f5f9),
                                                suffixIcon: contrctorListTemp.isSelected == true
                                                    ? InkWell(
                                                        onTap: () => FocusScope.of(context).unfocus(),
                                                        child: const Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 6.0),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Icon(Icons.check, size: 16, color: Color(0xff007AFF)),
                                                              SizedBox(width: 2),
                                                              Text(
                                                                "Done",
                                                                style: TextStyle(
                                                                  color: Color(0xff007AFF),
                                                                  fontSize: 11,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : null,
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(6),
                                                  borderSide: const BorderSide(color: Colors.black26),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(6),
                                                  borderSide: const BorderSide(color: Colors.black26),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(6),
                                                  borderSide: const BorderSide(color: Colors.black87),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      const Divider(height: 1.0, color: Color(0xffe2e8f0)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ),
                ),
            );
          });
        }).whenComplete(() => scrollController.dispose());
  }

  selectActivityModal({required BuildContext contextModal}) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    final ScrollController scrollController = ScrollController();
    return showDialog<void>(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              titlePadding: EdgeInsets.zero,
              title: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                color: Colors.black,
                child: const Text(
                  'SELECT ACTIVITY',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              "CLOSE",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          var castingFor = "";
                          if (skillResponse != null) {
                            for (int i = 0; i < skillResponse!.length; i++) {
                              if (skillResponse![i].isSelected == true) {
                                if (castingFor.isEmpty) {
                                  castingFor = skillResponse![i].mstWorkName ?? '';
                                } else {
                                  castingFor = "$castingFor, ${skillResponse![i].mstWorkName ?? ''}";
                                }
                              }
                            }
                          }
                          _activityController.text = castingFor;
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              "ADD",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              content: SizedBox(
                width: isMobile ? double.maxFinite : 500,
                height: 380,
                child: Column(
                  children: [
                    Expanded(
                      child: skillResponse == null || skillResponse!.isEmpty
                          ? Center(
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  addCustomActivityModal();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                  child: const Text(
                                    "+ ADD CUSTOM ACTIVITY",
                                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            )
                          : ScrollbarTheme(
                              data: ScrollbarThemeData(
                                thumbColor: MaterialStateProperty.all(Colors.grey.shade600),
                                trackColor: MaterialStateProperty.all(Colors.grey.shade200),
                                trackBorderColor: MaterialStateProperty.all(Colors.transparent),
                                radius: const Radius.circular(4),
                                thickness: MaterialStateProperty.all(5),
                              ),
                              child: Scrollbar(
                                controller: scrollController,
                                thumbVisibility: true,
                                trackVisibility: true,
                                child: ListView.builder(
                                  controller: scrollController,
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.only(right: 8),
                                  itemCount: skillResponse!.length,
                                  itemBuilder: (contextModal, int indexFor) {
                                    Skill tempSkills = skillResponse![indexFor];
                                    return InkWell(
                                      onTap: () {
                                        var castingFor = "";
                                        setState(() {
                                          tempSkills.isSelected = !(tempSkills.isSelected == true);
                                        });
                                        for (int i = 0; i < skillResponse!.length; i++) {
                                          if (skillResponse![i].isSelected == true) {
                                            if (castingFor.isEmpty) {
                                              castingFor = skillResponse![i].mstWorkName ?? '';
                                            } else {
                                              castingFor = "$castingFor, ${skillResponse![i].mstWorkName ?? ''}";
                                            }
                                          }
                                        }
                                        _activityController.text = castingFor;
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    tempSkills.mstWorkName ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                tempSkills.isSelected == true
                                                    ? const Icon(
                                                        Icons.check_circle,
                                                        size: 24,
                                                        color: Colors.green,
                                                      )
                                                    : const Icon(
                                                        Icons.circle_outlined,
                                                        size: 24,
                                                        color: Colors.grey,
                                                      )
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            const Divider(height: 1.0, color: Color(0xffe2e8f0)),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          });
        }).whenComplete(() => scrollController.dispose());
  }

  addCustomActivityModal() {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    return showDialog<void>(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              titlePadding: EdgeInsets.zero,
              title: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                color: Colors.black,
                child: const Text(
                  'ENTER ACTIVITY',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              "CLOSE",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (activityModalController.text.trim().isNotEmpty) {
                            var castingFor = "";
                            setState(() {
                              skillResponse ??= [];
                              skillResponse?.add(Skill(
                                mstWorkName: activityModalController.text.trim(),
                                mstWorkId: "",
                                isSelected: true,
                              ));
                            });
                            for (int i = 0; i < skillResponse!.length; i++) {
                              if (skillResponse![i].isSelected == true) {
                                if (castingFor.isEmpty) {
                                  castingFor = skillResponse![i].mstWorkName ?? '';
                                } else {
                                  castingFor = "$castingFor, ${skillResponse![i].mstWorkName ?? ''}";
                                }
                              }
                            }
                            _activityController.text = castingFor;
                            activityModalController.clear();
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              "ADD",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              content: SizedBox(
                width: isMobile ? double.maxFinite : 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: activityModalController,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                      style: const TextStyle(fontSize: 13.5),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(12.0),
                        hintText: "Enter Activity Name",
                        hintStyle: const TextStyle(color: Colors.black45, fontSize: 13),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black26),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  enterCustomCategoryModal() {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    return showDialog<void>(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return AlertDialog(
              backgroundColor: Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              titlePadding: EdgeInsets.zero,
              title: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                color: Colors.black,
                child: const Text(
                  'ENTER CUSTOM CATEGORY',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              "CLOSE",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (_formKeyCustomCategory.currentState!.validate()) {
                            setState(() {
                              customType?.add(
                                CustomType(
                                  editingTextController: TextEditingController(),
                                  name: _customCategoryController.text.trim(),
                                ),
                              );
                            });
                            _customCategoryController.clear();
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              "SUBMIT",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              content: SizedBox(
                width: isMobile ? double.maxFinite : 400,
                child: Form(
                  key: _formKeyCustomCategory,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "(Custom Category Cannot Be Empty)";
                          }
                          return null;
                        },
                        style: const TextStyle(fontSize: 13.5),
                        controller: _customCategoryController,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(12.0),
                          hintText: 'Enter Custom Category',
                          hintStyle: const TextStyle(color: Colors.black45, fontSize: 13),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black26),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black26),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
        });
  }

  Widget activity(bool isMobile) {
    return buildFormRow(
      label: "Activity *",
      isMobile: isMobile,
      child: InkWell(
        onTap: () {
          if (skillResponse?.length != 0 && skillResponse != null) {
            selectActivityModal(contextModal: context);
          } else {
            commonAleertModal(textTitle: "Please Select Contractor");
          }
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: _activityController,
            style: const TextStyle(color: Colors.black, fontSize: 13.5),
            decoration: buildInputDecoration(
              hintText: 'Select Activity',
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
          ),
        ),
      ),
    );
  }

  Widget dificultiesNrequirements(bool isMobile) {
    return buildFormRow(
      label: "Difficulties & Requirements",
      isMobile: isMobile,
      alignTop: true,
      child: TextFormField(
        maxLines: 3,
        controller: _dificultiesNrequirementsController,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
        style: const TextStyle(color: Colors.black, fontSize: 13.5),
        decoration: buildInputDecoration(
          hintText: 'Enter Difficulties & Requirements',
        ),
      ),
    );
  }

  Widget visitorss(bool isMobile) {
    return buildFormRow(
      label: "Visitors",
      isMobile: isMobile,
      alignTop: true,
      child: TextFormField(
        maxLines: 3,
        controller: _visitorsController,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
        style: const TextStyle(color: Colors.black, fontSize: 13.5),
        decoration: buildInputDecoration(
          hintText: 'Enter Visitors',
        ),
      ),
    );
  }

  Widget yesterdayWorkDone(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfff8f9fa),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffe9ecef)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yesterday Work Done',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          for (int j = 0; j < dprYesterdayActivity!.length; j++)
            InkWell(
              onTap: () {
                setState(() {
                  dprYesterdayActivity?[j].dprFlag =
                      (dprYesterdayActivity?[j].dprFlag == '1') ? '0' : '1';
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: dprYesterdayActivity?[j].dprFlag == '1'
                        ? Colors.green.shade300
                        : const Color(0xffdee2e6),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${j + 1}. ${dprYesterdayActivity?[j].description}',
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (dprYesterdayActivity?[j].targetdate != null &&
                        dprYesterdayActivity![j].targetdate!.isNotEmpty)
                      Text(
                        '${dprYesterdayActivity?[j].targetdate}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    const SizedBox(width: 6),
                    Icon(
                      dprYesterdayActivity?[j].dprFlag == '1'
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked,
                      color: dprYesterdayActivity?[j].dprFlag == '1'
                          ? Colors.green
                          : Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget addStaff(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Team Members",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        for (int t = 0; t < dprStaffList!.length; t++)
          Padding(
            padding: EdgeInsets.only(bottom: isMobile ? 8 : 10),
            child: Row(
              children: [
                SizedBox(
                  width: isMobile ? 18 : 28,
                  child: Text(
                    '${t + 1}.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 12 : 13.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: isMobile ? 4 : 3,
                  child: TextFormField(
                    onChanged: (value) {
                      dprStaffList?[t].staffName = value;
                    },
                    controller:
                        TextEditingController(text: dprStaffList?[t].staffName),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isMobile ? 11.5 : 13.0,
                    ),
                    decoration: buildInputDecoration(
                      hintText: isMobile ? 'Member Name' : 'Enter Member Name',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 6 : 10,
                        vertical: isMobile ? 8 : 10,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 4 : 8),
                Expanded(
                  flex: isMobile ? 3 : 2,
                  child: InkWell(
                    onTap: () => _selectInTime(context, t),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller:
                            TextEditingController(text: dprStaffList?[t].inTime),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: isMobile ? 11.0 : 13.0,
                        ),
                        decoration: buildInputDecoration(
                          hintText: 'In Time',
                          suffixIcon: Icon(
                            Icons.access_time,
                            size: isMobile ? 14 : 18,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 4 : 8,
                            vertical: isMobile ? 8 : 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 4 : 8),
                Expanded(
                  flex: isMobile ? 3 : 2,
                  child: InkWell(
                    onTap: () => _selectOutTime(context, t),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller:
                            TextEditingController(text: dprStaffList?[t].outTime),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: isMobile ? 11.0 : 13.0,
                        ),
                        decoration: buildInputDecoration(
                          hintText: 'Out Time',
                          suffixIcon: Icon(
                            Icons.access_time,
                            size: isMobile ? 14 : 18,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 4 : 8,
                            vertical: isMobile ? 8 : 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (t != 0)
                  Padding(
                    padding: EdgeInsets.only(left: isMobile ? 3 : 6),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          dprStaffList?.removeAt(t);
                        });
                      },
                      child: Icon(
                        Icons.cancel_outlined,
                        size: isMobile ? 16 : 20,
                        color: Colors.redAccent,
                      ),
                    ),
                  )
                else
                  SizedBox(width: isMobile ? 19 : 26),
              ],
            ),
          ),
      ],
    );
  }

  Widget addStaffBtn(bool isMobile) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xff4a5568)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onPressed: () {
          setState(() {
            dprStaffList?.add(DprStaffList(
              staffName: '',
              inTime: '',
              outTime: '',
              id: (dprStaffList!.length + 1).toString(),
            ));
          });
        },
        icon: const Icon(Icons.add, size: 18, color: Color(0xff4a5568)),
        label: const Text(
          "ADD TEAM MEMBER",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xff4a5568),
          ),
        ),
      ),
    );
  }

  Widget addToTodaysPlan(bool isMobile) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xff2b6cb0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onPressed: () {
          for (int j = 0; j < dprYesterdayActivity!.length; j++) {
            if (dprYesterdayActivity?[j].dprFlag == '1') {
              setState(() {
                if (todaysPlanActivitySelected?.length == 1 &&
                    todaysPlanActivitySelected?[0].description == '' &&
                    todaysPlanActivitySelected?[0].targetdate == '' &&
                    todaysPlanActivitySelected?[0]
                            .dprActivityController
                            .text ==
                        '' &&
                    todaysPlanActivitySelected?[0]
                            .dprActivityDateController
                            .text ==
                        '') {
                  todaysPlanActivitySelected = [
                    DprYesterdayActivity(
                      dprFlag: "0",
                      isSelected: false,
                      descriptionVal: '',
                      dprActivityController: TextEditingController(
                          text: dprYesterdayActivity![j].description),
                      id: '1',
                      targetdate: dprYesterdayActivity![j].targetdate,
                      description: dprYesterdayActivity![j].description,
                      dprActivityDateController: TextEditingController(
                          text: dprYesterdayActivity?[j].targetdate),
                    )
                  ];
                } else {
                  todaysPlanActivitySelected?.add(DprYesterdayActivity(
                    dprFlag: "0",
                    isSelected: false,
                    descriptionVal: '',
                    dprActivityController: TextEditingController(
                        text: dprYesterdayActivity![j].description),
                    id: (j + 1).toString(),
                    targetdate: dprYesterdayActivity![j].targetdate,
                    description: dprYesterdayActivity![j].description,
                    dprActivityDateController: TextEditingController(
                        text: dprYesterdayActivity?[j].targetdate),
                  ));
                }
              });
            }
          }
        },
        icon: const Icon(Icons.playlist_add, size: 18, color: Color(0xff2b6cb0)),
        label: const Text(
          "ADD SELECTED TO TODAY'S PLAN",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xff2b6cb0),
          ),
        ),
      ),
    );
  }

  Widget todaysPlanActivity(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Planned Activity",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        for (int index = 0; index < todaysPlanActivitySelected!.length; index++)
          Padding(
            padding: EdgeInsets.only(bottom: isMobile ? 8 : 10),
            child: Row(
              children: [
                SizedBox(
                  width: isMobile ? 18 : 28,
                  child: Text(
                    '${index + 1}.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 12 : 13.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: isMobile ? 5 : 3,
                  child: TextFormField(
                    enabled: todaysPlanActivitySelected?[index].dprFlag == "1",
                    controller:
                        todaysPlanActivitySelected?[index].dprActivityController,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                    onChanged: (value) {
                      todaysPlanActivitySelected?[index].descriptionVal = value;
                      todaysPlanActivitySelected?[index].description = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "(Title Cannot Be Empty)";
                      }
                      return null;
                    },
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isMobile ? 11.5 : 13.0,
                    ),
                    decoration: buildInputDecoration(
                      hintText: isMobile ? 'Planned Activity' : 'Enter Planned Activity',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 6 : 10,
                        vertical: isMobile ? 8 : 10,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 4 : 8),
                Expanded(
                  flex: isMobile ? 4 : 2,
                  child: InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        setState(() {
                          todaysPlanActivitySelected?[index].targetdate =
                              DateFormat('dd/MM/yyyy').format(picked);
                          todaysPlanActivitySelected?[index]
                              .dprActivityDateController
                              .text = DateFormat('dd/MM/yyyy').format(picked);
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: todaysPlanActivitySelected?[index]
                            .dprActivityDateController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "(Target Date Cannot Be Empty)";
                          }
                          return null;
                        },
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: isMobile ? 11.0 : 13.0,
                        ),
                        decoration: buildInputDecoration(
                          hintText: isMobile ? 'Target Date' : 'Target Completion Date',
                          suffixIcon: Icon(
                            Icons.calendar_month_outlined,
                            size: isMobile ? 14 : 18,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 4 : 8,
                            vertical: isMobile ? 8 : 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (index != 0)
                  Padding(
                    padding: EdgeInsets.only(left: isMobile ? 3 : 6),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          todaysPlanActivitySelected?.removeAt(index);
                        });
                      },
                      child: Icon(
                        Icons.cancel_outlined,
                        size: isMobile ? 16 : 20,
                        color: Colors.redAccent,
                      ),
                    ),
                  )
                else
                  SizedBox(width: isMobile ? 19 : 26),
              ],
            ),
          ),
      ],
    );
  }

  Widget addPlannedActivity(bool isMobile) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xff4a5568)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onPressed: () {
          setState(() {
            todaysPlanActivitySelected?.add(DprYesterdayActivity(
              dprFlag: '1',
              dprActivityDateController: TextEditingController(),
              isSelected: false,
              id: (todaysPlanActivitySelected!.length + 1).toString(),
              targetdate: "",
              description: "",
              descriptionVal: '',
              dprActivityController: TextEditingController(),
            ));
          });
        },
        icon: const Icon(Icons.add, size: 18, color: Color(0xff4a5568)),
        label: const Text(
          "ADD PLANNED ACTIVITY",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xff4a5568),
          ),
        ),
      ),
    );
  }

  Widget addCustomCategory(bool isMobile) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xff4a5568)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onPressed: () {
          enterCustomCategoryModal();
        },
        icon: const Icon(Icons.add, size: 18, color: Color(0xff4a5568)),
        label: const Text(
          "ADD CUSTOM CATEGORY",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xff4a5568),
          ),
        ),
      ),
    );
  }

  Widget dynamicCustomType({
    required CustomType data,
    required int indexx,
    required String title,
    required String titleVal,
    required String hintText,
    required TextEditingController textEditingController,
    required bool isMobile,
  }) {
    textEditingController.text = titleVal;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildFormRow(
            label: title,
            isMobile: isMobile,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      data.value = value;
                    },
                    controller: textEditingController,
                    style: const TextStyle(color: Colors.black, fontSize: 13.5),
                    decoration: buildInputDecoration(
                      hintText: hintText,
                      suffixIcon: InkWell(
                        onTap: () => FocusScope.of(context).unfocus(),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, size: 16, color: Color(0xff007AFF)),
                              SizedBox(width: 2),
                              Text("Done", style: TextStyle(color: Color(0xff007AFF), fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      customType?[indexx].flag = "true";
                    });
                  },
                  child: const Text(
                    'Work Report',
                    style: TextStyle(fontSize: 13, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          if (customType?[indexx].flag == "true") ...[
            const SizedBox(height: 8),
            buildFormRow(
              label: "",
              isMobile: isMobile,
              alignTop: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                      controller: TextEditingController(
                          text: customType?[indexx].description),
                      onChanged: (value) {
                        customType?[indexx].description = value;
                      },
                      style: const TextStyle(color: Colors.black, fontSize: 13.5),
                      decoration: buildInputDecoration(
                        hintText: 'Enter Work Report',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined,
                        size: 20, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        customType?[indexx].flag = "";
                        customType?[indexx].description = "";
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget workProgressAdd(bool isMobile) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextFormField(
              controller: _workProgressAddController,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
              style: const TextStyle(color: Colors.black, fontSize: 13.5),
              decoration: buildInputDecoration(
                hintText: 'Enter Work Progress',
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              setState(() {
                if (_workProgressAddController.text.trim().isNotEmpty) {
                  workProgressList?.add(WorkProgress(
                    title: _workProgressAddController.text.trim(),
                    id: '${workProgressList!.length + 1}',
                  ));
                  _workProgressAddController.clear();
                }
              });
            },
            child: const Text("ADD", style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  commonAleertModal({required String textTitle}) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    return showDialog<void>(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
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
                  "Attention",
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
                        color: Color(0xfffef3c7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xffd97706),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      textTitle,
                      style: const TextStyle(
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
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      "Okay",
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
          });
        });
  }
}
