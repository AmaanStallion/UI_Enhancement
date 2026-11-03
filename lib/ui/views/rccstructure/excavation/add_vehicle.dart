import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_default_excavation.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/rccstructure/common/rcc_mock_data.dart';
import 'package:stallion/ui/views/rccstructure/rcc_skeleton_loader.dart';
import 'package:stallion/models/excavation_api_models.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';


class AddVehicle extends StatefulWidget {
  AddVehicle({
    Key? key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.title,
    this.truckSizeResponse,
    this.typeRoyalityResponse,
    this.vehicleTypeResponse,
    this.slabId,
    this.slabDetails,
    this.towarName,
  }) : super(key: key);

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? title;
  final String? slabId;
  List<SlabDetail>? slabDetails;
  final List<TruckSize>? vehicleTypeResponse;
  final List<TruckSize>? truckSizeResponse;
  final List<TruckSize>? typeRoyalityResponse;

  @override
  State<AddVehicle> createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _vehicleNumberController = TextEditingController();
  final TextEditingController _truckSizeController = TextEditingController();
  final TextEditingController _cumLoadedController = TextEditingController();
  final TextEditingController _selectTypeController = TextEditingController();
  final TextEditingController _remarkFromController = TextEditingController();
  final TextEditingController _royaltyChalanController = TextEditingController();
  final TextEditingController _shiftRequiredForController = TextEditingController();
  final TextEditingController _hiringChargesController = TextEditingController();
  final TextEditingController _excavationFromController = TextEditingController();
  final TextEditingController _selectDateExcavationController = TextEditingController();
  final TextEditingController _selectShiftFromController = TextEditingController();
  final TextEditingController _selectShiftFromTimeController = TextEditingController();
  final TextEditingController _selectShiftToController = TextEditingController();
  final TextEditingController _selectShiftToTimeController = TextEditingController();

  DateTime? _selectExcavationdate;
  DateTime? _selectShiftFromdate;
  DateTime? _selectShiftTodate;
  TimeOfDay _selectedTime = TimeOfDay.now();
  TimeOfDay _selectedToTime = TimeOfDay.now();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<PlatformFile> arrayFiles = [];
  List<Uint8List?> arrayFilesBytes = [];

  List<TruckSize>? vehicleTypeResponse;
  List<TruckSize>? truckSizeResponse;
  List<TruckSize>? typeRoyalityResponse;
  List<SlabDetail>? towerSlabResponse;

  bool get isDumperSelected =>
      vehicleTypeSelected == '4' ||
      _vehicleTypeController.text.toLowerCase().contains('dumper');

  String vehicleTypeSelected = '';
  String truckSizeSelected = '';
  String typeSelected = '';
  bool isSubmitting = false;
  bool isLoading = true;

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
    return 'ADD VEHICLE';
  }

  String getSubHeaderTitle() {
    final slabTitle = widget.title?.trim().toUpperCase() ?? 'SLAB';
    return '$slabTitle - ADD EXCAVATION VEHICLE';
  }

  @override
  void initState() {
    super.initState();
    _selectDateExcavationController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    vehicleTypeResponse = widget.vehicleTypeResponse;
    truckSizeResponse = widget.truckSizeResponse;
    typeRoyalityResponse = widget.typeRoyalityResponse;
    towerSlabResponse = widget.slabDetails;

    fetchDropdownsIfNeeded();
  }

  Future<void> fetchDropdownsIfNeeded() async {
    setState(() {
      isLoading = true;
    });

    try {
      NetworkHandler networkHandler = NetworkHandler();
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        await networkHandler.ensureProjectContext(widget.projectId);
      }

      if (vehicleTypeResponse == null || vehicleTypeResponse!.isEmpty) {
        var vResponse = await networkHandler.get(AppUrl.getVehicleTypes);
        if (vResponse.statusCode == 200 || vResponse.statusCode == 201) {
          final vtModel = vehicleTypesResponseFromJson(vResponse.body);
          if (vtModel.success) {
            vehicleTypeResponse = vtModel.vehicleTypes
                .where((e) => e.isActive)
                .map<TruckSize>((e) => TruckSize(id: e.id, name: e.name, value: e.description))
                .toList();
          }
        }
      }

      if (truckSizeResponse == null || truckSizeResponse!.isEmpty) {
        var tResponse = await networkHandler.get(AppUrl.getTruckSizes);
        if (tResponse.statusCode == 200 || tResponse.statusCode == 201) {
          final tsModel = truckSizesResponseFromJson(tResponse.body);
          if (tsModel.success) {
            truckSizeResponse = tsModel.truckSizes
                .where((e) => e.isActive)
                .map<TruckSize>((e) => TruckSize(id: e.id, name: e.name, value: e.description))
                .toList();
          }
        }
      }

      if (typeRoyalityResponse == null || typeRoyalityResponse!.isEmpty) {
        var rResponse = await networkHandler.get(AppUrl.getRoyaltyTypes);
        if (rResponse.statusCode == 200 || rResponse.statusCode == 201) {
          final rtModel = royaltyTypesResponseFromJson(rResponse.body);
          if (rtModel.success) {
            typeRoyalityResponse = rtModel.royaltyTypes
                .where((e) => e.isActive)
                .map<TruckSize>((e) => TruckSize(id: e.id, name: e.name, value: e.description))
                .toList();
          }
        }
      }

      // Fetch Tower Slabs from GET /rcc/towers/:towerId/slabs
      if (widget.towarId != null && widget.towarId!.isNotEmpty) {
        var sResponse = await networkHandler.get(AppUrl.getTowerSlabs(widget.towarId!));
        if (sResponse.statusCode == 200 || sResponse.statusCode == 201) {
          final tsModel = towerSlabsResponseFromJson(sResponse.body);
          if (tsModel.success && tsModel.slabs.isNotEmpty) {
            towerSlabResponse = tsModel.slabs
                .map<SlabDetail>((e) => SlabDetail(id: e.id, name: e.name))
                .toList();
          }
        }
      }

      if (vehicleTypeResponse != null && vehicleTypeResponse!.isNotEmpty) {
        final dumperItem = vehicleTypeResponse!.firstWhere(
          (element) => element.id == '4' || (element.name ?? '').toLowerCase().contains('dumper'),
          orElse: () => vehicleTypeResponse!.first,
        );
        vehicleTypeSelected = dumperItem.id ?? '4';
        _vehicleTypeController.text = dumperItem.name ?? 'Dumper';
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching excavation dropdowns: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  Future<void> _selectExcavationDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final minDate = today.subtract(const Duration(days: 2));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (_selectExcavationdate != null &&
              !_selectExcavationdate!.isBefore(minDate) &&
              !_selectExcavationdate!.isAfter(today))
          ? _selectExcavationdate!
          : today,
      firstDate: minDate,
      lastDate: today,
    );
    if (picked != null) {
      setState(() {
        _selectExcavationdate = picked;
        _selectDateExcavationController.text = DateFormat('dd-MM-yyyy').format(_selectExcavationdate!);
      });
    }
  }

  Future<void> _selectShiftFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectShiftFromdate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 2)),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectShiftFromdate = picked;
        _selectShiftFromController.text = DateFormat('dd-MM-yyyy').format(_selectShiftFromdate!);
      });
    }
  }

  Future<void> _selectShiftToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectShiftTodate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 2)),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectShiftTodate = picked;
        _selectShiftToController.text = DateFormat('dd-MM-yyyy').format(_selectShiftTodate!);
      });
    }
  }

  Future<void> _selectShiftFromTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _selectShiftFromTimeController.text = _selectedTime.format(context);
      });
    }
  }

  Future<void> _selectShiftToTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedToTime,
    );
    if (picked != null) {
      setState(() {
        _selectedToTime = picked;
        _selectShiftToTimeController.text = _selectedToTime.format(context);
      });
    }
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
                  "Attach Photo / Document",
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
                    "Capture a live photo using your camera",
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
                    "Choose from Files (Images Only)",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    "Browse image files on your device",
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

  Future<void> _pickFile() async {
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
        return;
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
        return;
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
        type: FileType.image,
      );

      if (result != null) {
        bool rejectedNonImage = false;
        const validImageExtensions = [
          'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic', 'heif', 'tiff', 'tif', 'svg', 'ico'
        ];

        setState(() {
          for (var file in result.files) {
            final ext = (file.extension ?? (file.name.contains('.') ? file.name.split('.').last : '')).toLowerCase();
            // Disallow pdf or any non-image type
            if (ext == 'pdf' || (ext.isNotEmpty && !validImageExtensions.contains(ext))) {
              rejectedNonImage = true;
              continue;
            }
            arrayFiles.add(file);
            if (file.bytes != null) {
              arrayFilesBytes.add(file.bytes);
            }
          }
        });

        if (rejectedNonImage && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Only image documents are allowed (no PDF or other file types)."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print("Error picking files: $e");
    }
  }

  void _showSuccessDialog() {
    final isMobile = context.isMobile;
    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 18 : 22,
          ),
          actionsPadding: EdgeInsets.only(
            bottom: isMobile ? 14 : 18,
            left: 16,
            right: 16,
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
              "SUCCESS",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: Text(
            "Vehicle Added Successfully",
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: isMobile ? 140 : 180,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Okay",
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  dynamic _parseId(String? idStr) {
    if (idStr == null || idStr.isEmpty) return null;
    final parsedInt = int.tryParse(idStr);
    return parsedInt ?? idStr;
  }

  Future<void> addVehicle() async {
    if (isSubmitting) return;
    setState(() {
      isSubmitting = true;
    });

    if (useRccMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
        _showSuccessDialog();
      }
      return;
    }

    try {
      NetworkHandler networkHandler = NetworkHandler();
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        await networkHandler.ensureProjectContext(widget.projectId);
      }

      final prefs = await _prefs;
      final String? projectToken = prefs.getString('projectToken');

      var request = http.MultipartRequest('POST', Uri.parse(AppUrl.createExcavationEntry));
      if (projectToken != null && projectToken.isNotEmpty) {
        request.headers["Authorization"] = "Bearer $projectToken";
      }

      String formattedEntryDate = _selectDateExcavationController.text;
      try {
        if (_selectExcavationdate != null) {
          formattedEntryDate = DateFormat('yyyy-MM-dd').format(_selectExcavationdate!);
        } else if (_selectDateExcavationController.text.isNotEmpty) {
          final parts = _selectDateExcavationController.text.split('-');
          if (parts.length == 3 && parts[0].length == 2) {
            formattedEntryDate = "${parts[2]}-${parts[1]}-${parts[0]}";
          }
        }
      } catch (_) {}

      // Common fields
      request.fields["tower_id"] = widget.towarId ?? '';

      // Determine selected slab IDs from modal or current text input
      List<dynamic> slabIdsToSend = [];
      final currentSlabList = (towerSlabResponse != null && towerSlabResponse!.isNotEmpty)
          ? towerSlabResponse!
          : (widget.slabDetails ?? []);
      final enteredNames = _excavationFromController.text
          .split(',')
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toList();

      for (var slab in currentSlabList) {
        if (slab.name != null && enteredNames.contains(slab.name!.trim().toLowerCase())) {
          final pid = _parseId(slab.id);
          if (pid != null && !slabIdsToSend.contains(pid)) {
            slabIdsToSend.add(pid);
          }
        }
      }

      request.fields["slab_ids"] = jsonEncode(slabIdsToSend);
      request.fields["vehicle_type_id"] = vehicleTypeSelected;
      request.fields["challan_no"] = _royaltyChalanController.text;
      request.fields["excavation_from"] = _excavationFromController.text.isEmpty
          ? (widget.title ?? "Basement")
          : _excavationFromController.text;
      request.fields["entry_date"] = formattedEntryDate;
      request.fields["remarks"] = _remarkFromController.text;

      if (isDumperSelected) {
        // Dumper specific fields
        if (truckSizeSelected.isNotEmpty) {
          request.fields["truck_size_id"] = truckSizeSelected;
        }
        if (typeSelected.isNotEmpty) {
          request.fields["royalty_type_id"] = typeSelected;
        }
        if (_vehicleNumberController.text.isNotEmpty) {
          request.fields["vehicle_no"] = _vehicleNumberController.text;
        }
        if (_cumLoadedController.text.isNotEmpty) {
          request.fields["cum_loaded"] = _cumLoadedController.text;
        }
      } else {
        // Heavy Machine (JCB/Poclain) specific fields
        String shiftFromStr = "";
        if (_selectShiftFromController.text.isNotEmpty) {
          shiftFromStr = _selectShiftFromController.text;
          if (_selectShiftFromTimeController.text.isNotEmpty) {
            shiftFromStr += " ${_selectShiftFromTimeController.text}";
          }
        }

        String shiftToStr = "";
        if (_selectShiftToController.text.isNotEmpty) {
          shiftToStr = _selectShiftToController.text;
          if (_selectShiftToTimeController.text.isNotEmpty) {
            shiftToStr += " ${_selectShiftToTimeController.text}";
          }
        }

        if (shiftFromStr.isNotEmpty) {
          request.fields["shift_from"] = shiftFromStr;
        }
        if (shiftToStr.isNotEmpty) {
          request.fields["shift_to"] = shiftToStr;
        }
        if (_shiftRequiredForController.text.isNotEmpty) {
          request.fields["shift_required"] = _shiftRequiredForController.text;
        }
        if (_hiringChargesController.text.isNotEmpty) {
          request.fields["hiring_charges"] = _hiringChargesController.text;
        }
      }

      for (int i = 0; i < arrayFiles.length; i++) {
        PlatformFile file = arrayFiles[i];
        if (file.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              "documents",
              file.path!,
            ),
          );
        } else if (file.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              "documents",
              file.bytes!,
              filename: file.name,
            ),
          );
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        if (kDebugMode) {
          print("Add Vehicle failed (${response.statusCode}): ${response.body}");
        }
      }
    } catch (e) {
      if (kDebugMode) print("Add Vehicle error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
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
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
          children: [
            // SubHeader Bar
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

            // Form Area inside Scrollable Card
            Expanded(
              child: isLoading
                  ? AddVehicleSkeletonScreen(isMobile: isMobile)
                  : SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12.0 : 24.0,
                        vertical: isMobile ? 12.0 : 16.0,
                      ),
                      child: Container(
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                        // 1. Vehicle Type
                        buildFormRow(
                          label: "Vehicle Type *",
                          isMobile: isMobile,
                          baseStyle: baseStyle,
                          child: InkWell(
                            onTap: () => selectVehicleTypeModal(context: context),
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: _vehicleTypeController,
                                style: baseStyle.copyWith(fontSize: isMobile ? 13 : 15),
                                decoration: const InputDecoration(
                                  hintText: "Select Vehicle Type",
                                  suffixIcon: Icon(Icons.arrow_drop_down),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                validator: (value) => value!.isEmpty ? "Select Vehicle Type" : null,
                              ),
                            ),
                          ),
                        ),

                        // Inputs specific to Dumper
                        if (isDumperSelected) ...[
                          // 2. Vehicle Number
                          buildFormRow(
                            label: "Vehicle Number *",
                            isMobile: isMobile,
                            baseStyle: baseStyle,
                            child: TextFormField(
                              controller: _vehicleNumberController,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                              style: baseStyle.copyWith(fontSize: isMobile ? 13 : 15),
                              decoration: const InputDecoration(
                                hintText: "Enter Vehicle Number (e.g. MH-04-AB-1234)",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              validator: (value) => value!.isEmpty ? "Vehicle Number required" : null,
                            ),
                          ),
                          // 3. Truck Size
                          buildFormRow(
                            label: "Truck Size *",
                            isMobile: isMobile,
                            baseStyle: baseStyle,
                            child: InkWell(
                              onTap: () => selectTruckSizeModal(context: context),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: _truckSizeController,
                                  style: baseStyle.copyWith(fontSize: isMobile ? 13 : 15),
                                  decoration: const InputDecoration(
                                    hintText: "Select Truck Size",
                                    suffixIcon: Icon(Icons.arrow_drop_down),
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  validator: (value) => value!.isEmpty ? "Truck Size required" : null,
                                ),
                              ),
                            ),
                          ),
                          // 4. CUM Loaded
                          buildFormRow(
                            label: "CUM Loaded *",
                            isMobile: isMobile,
                            baseStyle: baseStyle,
                            child: TextFormField(
                              controller: _cumLoadedController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                              style: baseStyle.copyWith(fontSize: isMobile ? 13 : 15),
                              decoration: InputDecoration(
                                hintText: "Enter CUM Loaded",
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                suffixIcon: InkWell(
                                  onTap: () => FocusScope.of(context).unfocus(),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check, size: 16, color: Color(0xff007AFF)),
                                        SizedBox(width: 2),
                                        Text(
                                          "Done",
                                          style: TextStyle(
                                            color: Color(0xff007AFF),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              validator: (value) => value!.isEmpty ? "CUM Loaded required" : null,
                            ),
                          ),
                          // 5. Royalty Type
                          buildFormRow(
                            label: "Royalty Type *",
                            isMobile: isMobile,
                            baseStyle: baseStyle,
                            child: InkWell(
                              onTap: () => selectRoyalityModal(context: context),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: _selectTypeController,
                                  style: baseStyle.copyWith(fontSize: isMobile ? 13 : 15),
                                  decoration: const InputDecoration(
                                    hintText: "Select Royalty Type",
                                    suffixIcon: Icon(Icons.arrow_drop_down),
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  validator: (value) => value!.isEmpty ? "Royalty Type required" : null,
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Inputs specific to Heavy Machine (JCB/Poclain/etc.)
                        if (!isDumperSelected) ...[
                          // 7. Shift Start Date & Time
                          buildFormRow(
                            label: "Shift Start (Date & Time) *",
                            isMobile: isMobile,
                            baseStyle: baseStyle,
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectShiftFromDate(context),
                                    child: AbsorbPointer(
                                      child: TextFormField(
                                        controller: _selectShiftFromController,
                                        style: baseStyle.copyWith(fontSize: isMobile ? 12 : 14),
                                        decoration: const InputDecoration(
                                          hintText: "Start Date",
                                          suffixIcon: Icon(Icons.calendar_today, size: 18),
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        ),
                                        validator: (value) => value!.isEmpty ? "Start Date required" : null,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectShiftFromTime(context),
                                    child: AbsorbPointer(
                                      child: TextFormField(
                                        controller: _selectShiftFromTimeController,
                                        style: baseStyle.copyWith(fontSize: isMobile ? 12 : 14),
                                        decoration: const InputDecoration(
                                          hintText: "Start Time",
                                          suffixIcon: Icon(Icons.access_time, size: 18),
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        ),
                                        validator: (value) => value!.isEmpty ? "Start Time required" : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 8. Shift End Date & Time
                          buildFormRow(
                            label: "Shift End (Date & Time) *",
                            isMobile: isMobile,
                            baseStyle: baseStyle,
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectShiftToDate(context),
                                    child: AbsorbPointer(
                                      child: TextFormField(
                                        controller: _selectShiftToController,
                                        style: baseStyle.copyWith(fontSize: isMobile ? 12 : 14),
                                        decoration: const InputDecoration(
                                          hintText: "End Date",
                                          suffixIcon: Icon(Icons.calendar_today, size: 18),
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        ),
                                        validator: (value) => value!.isEmpty ? "End Date required" : null,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectShiftToTime(context),
                                    child: AbsorbPointer(
                                      child: TextFormField(
                                        controller: _selectShiftToTimeController,
                                        style: baseStyle.copyWith(fontSize: isMobile ? 12 : 14),
                                        decoration: const InputDecoration(
                                          hintText: "End Time",
                                          suffixIcon: Icon(Icons.access_time, size: 18),
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        ),
                                        validator: (value) => value!.isEmpty ? "End Time required" : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 9. Shift Required
                          buildFormRow(
                            label: "Shift Required *",
                            isMobile: isMobile,
                            baseStyle: baseStyle,
                            child: TextFormField(
                              controller: _shiftRequiredForController,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                              style: baseStyle.copyWith(fontSize: isMobile ? 13 : 15),
                              decoration: const InputDecoration(
                                hintText: "e.g. 1 Shift (8 Hours)",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              validator: (value) => value!.isEmpty ? "Shift Required required" : null,
                            ),
                          ),
                          // 10. Hiring Charges
                          buildFormRow(
                            label: "Hiring Charges *",
                            isMobile: isMobile,
                            baseStyle: baseStyle,
                            child: TextFormField(
                              controller: _hiringChargesController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                              style: baseStyle.copyWith(fontSize: isMobile ? 13 : 15),
                              decoration: InputDecoration(
                                hintText: "Enter Hiring Charges (₹)",
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                suffixIcon: InkWell(
                                  onTap: () => FocusScope.of(context).unfocus(),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check, size: 16, color: Color(0xff007AFF)),
                                        SizedBox(width: 2),
                                        Text(
                                          "Done",
                                          style: TextStyle(
                                            color: Color(0xff007AFF),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              validator: (value) => value!.isEmpty ? "Hiring Charges required" : null,
                            ),
                          ),
                        ],

                        // 6. Royalty Challan No (For all vehicle types - after Hiring Charges for JCB)
                        buildFormRow(
                          label: "Royalty Challan No *",
                          isMobile: isMobile,
                          baseStyle: baseStyle,
                          child: TextFormField(
                            controller: _royaltyChalanController,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                            style: baseStyle.copyWith(fontSize: isMobile ? 13 : 15),
                            decoration: const InputDecoration(
                              hintText: "Enter Royalty Challan No",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            validator: (value) => value!.isEmpty ? "Royalty Challan No required" : null,
                          ),
                        ),

                        // Upload Challan Documents Section (Right below Challan No)
                        buildFormRow(
                          label: "Upload Documents",
                          isMobile: isMobile,
                          baseStyle: baseStyle,
                          alignTop: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: _pickFile,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xfff1f3f5),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xffced4da)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.add_a_photo_outlined, color: Colors.black87, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        "ATTACH IMAGE / TAKE PHOTO",
                                        style: TextStyle(
                                          fontSize: isMobile ? 11 : 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (arrayFiles.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (int i = 0; i < arrayFiles.length; i++)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.image,
                                              size: 16,
                                              color: Colors.grey.shade700,
                                            ),
                                            const SizedBox(width: 4),
                                            ConstrainedBox(
                                              constraints: const BoxConstraints(maxWidth: 120),
                                              child: Text(
                                                arrayFiles[i].name,
                                                style: TextStyle(fontSize: isMobile ? 10 : 12),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  arrayFiles.removeAt(i);
                                                  if (arrayFilesBytes.length > i) {
                                                    arrayFilesBytes.removeAt(i);
                                                  }
                                                });
                                              },
                                              child: const Icon(Icons.close, size: 14, color: Colors.red),
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

                        // 11. Excavation From / Select Slab
                        buildFormRow(
                          label: "Excavation From / Used For *",
                          isMobile: isMobile,
                          baseStyle: baseStyle,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _excavationFromController,
                                  style: baseStyle.copyWith(fontSize: isMobile ? 13 : 15),
                                  decoration: const InputDecoration(
                                    hintText: "Enter location or select slab",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  validator: (value) => value!.isEmpty ? "Location / Slab required" : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => selectSlabModal(context: context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 10 : 14,
                                    vertical: isMobile ? 10 : 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: Text(
                                    "Select Slab",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: isMobile ? 11 : 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 12. Date
                        buildFormRow(
                          label: "Date *",
                          isMobile: isMobile,
                          baseStyle: baseStyle,
                          child: InkWell(
                            onTap: () => _selectExcavationDate(context),
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: _selectDateExcavationController,
                                style: baseStyle.copyWith(fontSize: isMobile ? 13 : 15),
                                decoration: const InputDecoration(
                                  hintText: "Select Date",
                                  suffixIcon: Icon(Icons.calendar_month_outlined),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                validator: (value) => value!.isEmpty ? "Date required" : null,
                              ),
                            ),
                          ),
                        ),

                        // 13. Remark
                        buildFormRow(
                          label: "Remark",
                          isMobile: isMobile,
                          baseStyle: baseStyle,
                          alignTop: true,
                          child: TextFormField(
                            controller: _remarkFromController,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                            onEditingComplete: () => FocusScope.of(context).unfocus(),
                            style: baseStyle.copyWith(fontSize: isMobile ? 13 : 15),
                            decoration: const InputDecoration(
                              hintText: "Enter Remark (Optional)",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),

      // Bottom Capsule Submit Action Bar / iOS Keyboard Done Accessory Bar
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
          : Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 10 : 12,
              ),
              child: SafeArea(
                child: InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      addVehicle();
                    }
                  },
                  child: Container(
                    height: isMobile ? 44 : 48,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              "SUBMIT VEHICLE DETAILS",
                              style: TextStyle(
                                fontSize: isMobile ? 13 : 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildFormRow({
    required String label,
    required bool isMobile,
    required TextStyle baseStyle,
    required Widget child,
    bool alignTop = false,
  }) {
    final bool hasAsterisk = label.contains('*');
    final String cleanLabel = label.replaceAll('*', '').trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: alignTop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: isMobile ? 96 : 160,
            child: Text.rich(
              TextSpan(
                text: cleanLabel,
                style: baseStyle.copyWith(
                  fontSize: isMobile ? 12 : 14,
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
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  void selectVehicleTypeModal({required BuildContext context}) {
    final isMobile = context.isMobile;
    final list = (vehicleTypeResponse != null && vehicleTypeResponse!.isNotEmpty)
        ? vehicleTypeResponse!
        : (widget.vehicleTypeResponse ?? []);

    final ScrollController scrollController = ScrollController();

    showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              titlePadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 18, vertical: 12),
              actionsPadding: EdgeInsets.only(bottom: isMobile ? 14 : 18, left: 16, right: 16),
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                ),
                child: Text(
                  'SELECT VEHICLE TYPE',
                  style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              content: SizedBox(
                width: isMobile ? 280 : 380,
                height: 220,
                child: ScrollbarTheme(
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
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.only(right: 8),
                      shrinkWrap: true,
                      itemCount: list.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
                      itemBuilder: (context, index) {
                        final item = list[index];
                        final isSelected = vehicleTypeSelected == item.id;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              vehicleTypeSelected = item.id ?? '';
                              _vehicleTypeController.text = item.name ?? '';
                            });
                            Navigator.of(context).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item.name ?? '', style: TextStyle(fontSize: isMobile ? 13 : 15)),
                                Icon(
                                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                                  color: isSelected ? Colors.green : Colors.grey,
                                  size: isMobile ? 20 : 24,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              actions: [
                Row(
                  children: [
                    const Spacer(flex: 1),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 8 : 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
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
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() => scrollController.dispose());
  }

  void selectTruckSizeModal({required BuildContext context}) {
    final isMobile = context.isMobile;
    final list = (truckSizeResponse != null && truckSizeResponse!.isNotEmpty)
        ? truckSizeResponse!
        : (widget.truckSizeResponse ?? []);

    final ScrollController scrollController = ScrollController();

    showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              titlePadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 18, vertical: 12),
              actionsPadding: EdgeInsets.only(bottom: isMobile ? 14 : 18, left: 16, right: 16),
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                ),
                child: Text(
                  'SELECT TRUCK SIZE',
                  style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              content: SizedBox(
                width: isMobile ? 280 : 380,
                height: 220,
                child: ScrollbarTheme(
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
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.only(right: 8),
                      shrinkWrap: true,
                      itemCount: list.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
                      itemBuilder: (context, index) {
                        final item = list[index];
                        final isSelected = truckSizeSelected == item.id;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              truckSizeSelected = item.id ?? '';
                              _truckSizeController.text = item.name ?? '';
                            });
                            Navigator.of(context).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item.name ?? '', style: TextStyle(fontSize: isMobile ? 13 : 15)),
                                Icon(
                                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                                  color: isSelected ? Colors.green : Colors.grey,
                                  size: isMobile ? 20 : 24,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              actions: [
                Row(
                  children: [
                    const Spacer(flex: 1),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 8 : 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
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
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() => scrollController.dispose());
  }

  void selectRoyalityModal({required BuildContext context}) {
    final isMobile = context.isMobile;
    final list = (typeRoyalityResponse != null && typeRoyalityResponse!.isNotEmpty)
        ? typeRoyalityResponse!
        : (widget.typeRoyalityResponse ?? []);

    final ScrollController scrollController = ScrollController();

    showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              titlePadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 18, vertical: 12),
              actionsPadding: EdgeInsets.only(bottom: isMobile ? 14 : 18, left: 16, right: 16),
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                ),
                child: Text(
                  'SELECT ROYALTY TYPE',
                  style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              content: SizedBox(
                width: isMobile ? 280 : 380,
                height: 220,
                child: ScrollbarTheme(
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
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.only(right: 8),
                      shrinkWrap: true,
                      itemCount: list.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
                      itemBuilder: (context, index) {
                        final item = list[index];
                        final isSelected = typeSelected == item.id;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              typeSelected = item.id ?? '';
                              _selectTypeController.text = item.name ?? '';
                            });
                            Navigator.of(context).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item.name ?? '', style: TextStyle(fontSize: isMobile ? 13 : 15)),
                                Icon(
                                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                                  color: isSelected ? Colors.green : Colors.grey,
                                  size: isMobile ? 20 : 24,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              actions: [
                Row(
                  children: [
                    const Spacer(flex: 1),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 8 : 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
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
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() => scrollController.dispose());
  }

  void selectSlabModal({required BuildContext context}) {
    final isMobile = context.isMobile;
    final list = (towerSlabResponse != null && towerSlabResponse!.isNotEmpty)
        ? towerSlabResponse!
        : (widget.slabDetails ?? []);

    final selectedSlabs = _excavationFromController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final ScrollController scrollController = ScrollController();

    showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              titlePadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 18, vertical: 12),
              actionsPadding: EdgeInsets.only(bottom: isMobile ? 14 : 18, left: 16, right: 16),
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                ),
                child: Text(
                  'SELECT SLAB',
                  style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              content: SizedBox(
                width: isMobile ? 280 : 380,
                height: list.isEmpty ? 120 : 280,
                child: list.isEmpty
                    ? Center(
                        child: Text(
                          "No Slabs Available",
                          style: TextStyle(
                            fontSize: isMobile ? 13 : 15,
                            color: Colors.grey.shade600,
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
                          child: ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.only(right: 8),
                            shrinkWrap: true,
                            itemCount: list.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
                            itemBuilder: (context, indexFor) {
                              final item = list[indexFor];
                              final itemName = (item.name ?? '').trim();
                              final isSelected = selectedSlabs.any((s) => s.toLowerCase() == itemName.toLowerCase());
                              return InkWell(
                                onTap: () {
                                  setModalState(() {
                                    if (isSelected) {
                                      selectedSlabs.removeWhere((s) => s.toLowerCase() == itemName.toLowerCase());
                                    } else {
                                      selectedSlabs.add(itemName);
                                    }
                                    setState(() {
                                      _excavationFromController.text = selectedSlabs.join(', ');
                                    });
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          itemName,
                                          style: TextStyle(
                                            fontSize: isMobile ? 13 : 15,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: isSelected ? Colors.black : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                                        color: isSelected ? Colors.black : Colors.grey,
                                        size: isMobile ? 20 : 24,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ),
              actions: [
                Row(
                  children: [
                    const Spacer(flex: 1),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 8 : 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
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
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() => scrollController.dispose());
  }
}
