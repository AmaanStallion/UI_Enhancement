import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
// import 'package:basic_utils/basic_utils.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/views/PurchaseOrder/purchase_order_preview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/views/rccstructure/rcc_skeleton_loader.dart';
import 'package:stallion/ui/widgets/border_button.dart';
import 'package:stallion/utils/remove_temp_file.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/add_custom_po_unit.dart';
import '../../../models/get_purchase_order_default_request.dart';
import '../../../models/grade_description.dart';
import '../../../models/po_api_models.dart';
import '../../../models/excavation_api_models.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../../websocket/socket_service.dart';
import '../../shared/ui_helpers.dart';
import '../../widgets/simple_button.dart';

class RequestPurchaseOrderView extends StatefulWidget {
  const RequestPurchaseOrderView({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    this.requirementFor,
    this.requirementType,
    this.requirementTypeId,
    this.consultantMagicLink,
    this.contractorMagicLink,
    this.vendMagicLink,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? requirementFor;
  final String? requirementType;
  final String? requirementTypeId;
  final String? contractorMagicLink;
  final String? vendMagicLink;
  final String? consultantMagicLink;

  @override
  State<RequestPurchaseOrderView> createState() =>
      _RequestPurchaseOrderViewState();
}

class _RequestPurchaseOrderViewState extends State<RequestPurchaseOrderView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final ScrollController _scrollController = ScrollController();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  List<PlatformFile> arrayFiles = [];
  List<Uint8List?> arrayFilesBytes = [];
  bool flagcalled = false;
  FinishingTypeList? isSelectedFromWo;
  String? selectedRequirementDate = "";
  String? castingRequirementFor = "";
  String? selectedUnitType;
  String? selectedUnitId;
  var selectedRow = 0;
  String? selectedRequirementType = "";
  String? selectedRequirementTypeId = "";
  TextEditingController texteditingControllerRequiredFor =
      TextEditingController();
  List<OrderList>? orderList = [];
  List<FinishingTypeList>? finishingTypeList = [];
  List<FinishingTypeList>? finishingTypeListOriginal = [];
  List<FinishingUnit>? finishingUnit = [];
  List<SimilarDescription>? descriptionList = [];
  List<SlabDetail>? slabDetails = [];
  List<SlabDetail>? slabDetailsSelectedArray = [];
  List<SlabDetail>? slabDetailsOriginal = [];
  String? customeBtnActive = '';
  List<PoVendorType> poVendorTypesList = [];
  List<PoMeasuringUnit> poMeasuringUnitsList = [];

  List<POformDataArrayList> arrayList = [];
  List<DropdownMenuItem> unitItems = [];
  List<DropdownMenuItem> requirementTypeitems = [];

  POformDataArrayList dataList = POformDataArrayList(
    grade_id: "",
    grade_type_name: "",
    casting_date: "",
    casting_for: "",
    casting_unit_name: "",
    casting_unit: "",
    quantity: "",
    unit_price: "",
    total_amount: "0",
    description: "",
    brand_supplier_name: '',
    id: "0",
    editingControllerGradeTypeName: TextEditingController(),
    editingControllerDescription: TextEditingController(),
    editingControllerCastingFor: TextEditingController(),
    editingControllerCastingDate: TextEditingController(),
    editingControllerQuantity: TextEditingController(),
    editingControllerCastingUnitName: TextEditingController(),
    editingControllerUnitPrice: TextEditingController(),
    editingControllerTotalAmount: TextEditingController(),
    editingControllerBrandName: TextEditingController(),
  );

  GlobalKey formkey = GlobalKey<FormState>();
  GlobalKey formkeySlab = GlobalKey<FormState>();
  String? _selectedReqTypeIndex;

  String? strRemark = '';
  String? strSlabID = '';

  final List<TextEditingController> _txtControllerRequirmentType = [];
  final List<TextEditingController> _txtControllerUnitType = [];
  final TextEditingController editingController = TextEditingController();
  final TextEditingController _txtCustomRequirementType = TextEditingController();
  final TextEditingController _txtSearchSlab = TextEditingController();
  String? _draftRequestId;
  String? _resolvedTowerId;

  @override
  void initState() {
    selectedUnitType = '';
    super.initState();
    arrayList.add(dataList);
    fetchDefaultPurchaseOrderCreate();
  }

  var reqTypeIndex = 0;

  Future<ResponsePurchaseDefaultOrderRequest?>
      fetchDefaultPurchaseOrderCreate() async {
    // Ensure active workspace token is scoped for project and tower
    final String effectiveTower = (widget.towarId != null &&
            widget.towarId!.isNotEmpty &&
            widget.towarId != '0')
        ? widget.towarId!
        : (SocketService.currentActiveTowerId ?? '');
    _resolvedTowerId = effectiveTower;

    if (widget.projectId != null && widget.projectId!.isNotEmpty && effectiveTower.isNotEmpty) {
      await apiNetworkHandler.ensureTowerContext(widget.projectId, effectiveTower);
    } else if (widget.projectId != null && widget.projectId!.isNotEmpty) {
      await apiNetworkHandler.ensureProjectContext(widget.projectId);
    }

    try {
      // 1. Fetch Vendor Types & Grades (GET /vendor/po-vendor-types)
      final vtRes = await apiNetworkHandler.get(AppUrl.poVendorTypes);
      if (vtRes.statusCode == 200 || vtRes.statusCode == 201) {
        poVendorTypesList = poVendorTypesFromJson(vtRes.body);
        if (poVendorTypesList.isNotEmpty) {
          finishingTypeList = poVendorTypesList.map((t) => FinishingTypeList(
            finishingId: t.id,
            finishingName: t.name,
            count: t.vendorCount.toString(),
            finishingUnit: [],
          )).toList();
          finishingTypeListOriginal = List.from(finishingTypeList ?? []);
        }
      }
    } catch (_) {}

    try {
      // 2. Fetch Measuring Units (GET /vendor/po-measuring-units)
      final muRes = await apiNetworkHandler.get(AppUrl.poMeasuringUnits);
      if (muRes.statusCode == 200 || muRes.statusCode == 201) {
        poMeasuringUnitsList = poMeasuringUnitsFromJson(muRes.body);
        if (poMeasuringUnitsList.isNotEmpty) {
          finishingUnit = poMeasuringUnitsList.map((u) => FinishingUnit(
            unitId: u.id,
            unitName: u.symbol.isNotEmpty ? u.symbol : u.name,
            flag: '0',
          )).toList();
        }
      }
    } catch (_) {}

    try {
      // 3. Fetch Tower Slabs (GET /rcc/towers/:towerId/slabs)
      if (effectiveTower.isNotEmpty && effectiveTower != '0') {
        final slabRes =
            await apiNetworkHandler.get(AppUrl.getTowerSlabs(effectiveTower));
        if (slabRes.statusCode == 200 || slabRes.statusCode == 201) {
          final tsModel = towerSlabsResponseFromJson(slabRes.body);
          if (tsModel.success && tsModel.slabs.isNotEmpty) {
            slabDetails = tsModel.slabs
                .map((s) => SlabDetail(
                      slab_id: s.id,
                      slab_name: s.name,
                      selected: '0',
                    ))
                .toList();
            slabDetailsOriginal = List.from(slabDetails ?? []);
          }
        }
      }
    } catch (_) {}

    customeBtnActive = "1";

    if (widget.requirementFor != null && widget.requirementFor!.isNotEmpty) {
      texteditingControllerRequiredFor.text = widget.requirementFor!;
      arrayList[0].editingControllerCastingFor?.text = widget.requirementFor!;
      arrayList[0].casting_for = widget.requirementFor!;

      if (slabDetailsOriginal != null && slabDetailsOriginal!.isNotEmpty) {
        final match = slabDetailsOriginal!.firstWhere(
          (s) => (s.slab_name ?? '').toLowerCase() == widget.requirementFor!.trim().toLowerCase(),
          orElse: () => SlabDetail(),
        );
        if (match.slab_id != null && match.slab_id!.isNotEmpty) {
          match.selected = '1';
          arrayList[0].slab_ids = [match.slab_id!];
        }
      }
    }

    if (widget.requirementType != null && widget.requirementType!.isNotEmpty) {
      PoVendorType? matchedType;
      for (final vt in poVendorTypesList) {
        if (vt.name.toLowerCase() == widget.requirementType!.toLowerCase() ||
            vt.id == widget.requirementTypeId) {
          matchedType = vt;
          break;
        }
      }
      final resolvedId = matchedType?.id ?? widget.requirementTypeId ?? finishingTypeList!.first.finishingId!;
      final resolvedName = matchedType?.name ?? widget.requirementType!;

      arrayList[0].editingControllerGradeTypeName?.text = resolvedName;
      arrayList[0].grade_type_name = resolvedName;
      arrayList[0].grade_id = resolvedId;
      _selectedReqTypeIndex = resolvedId;
      selectedRequirementTypeId = resolvedId;
      fetchGradeDescription(selectedRequirementTypeIds: resolvedId, index: 0);
    } else if (finishingTypeList?.isNotEmpty == true) {
      final firstType = finishingTypeList!.first;
      arrayList[0].editingControllerGradeTypeName?.text = firstType.finishingName ?? '';
      arrayList[0].grade_type_name = firstType.finishingName ?? '';
      arrayList[0].grade_id = firstType.finishingId ?? '1';
      _selectedReqTypeIndex = firstType.finishingId;
      selectedRequirementTypeId = firstType.finishingId;
      fetchGradeDescription(selectedRequirementTypeIds: firstType.finishingId, index: 0);
    }

    setState(() {
      flagcalled = true;
    });
    return null;
  }

  String? valueText;

  final TextEditingController _textFieldController = TextEditingController();
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Custom Unit'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: "Enter custom unit"),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    fixedSize: const Size.fromWidth(100),
                    padding: const EdgeInsets.all(10),
                    textStyle: const TextStyle(color: Colors.white)),
                child:
                    const Text('CANCEL', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    fixedSize: const Size.fromWidth(100),
                    padding: const EdgeInsets.all(10),
                    textStyle: const TextStyle(color: Colors.white)),
                child: const Text('ADD UNIT',
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0,
                        color: Colors.white)),
                onPressed: () {
                  setState(() {
                    Timer(const Duration(seconds: 1), () {
                      if (valueText! != "") {
                        var flag = false;
                        for (int i = 0; i < finishingUnit!.length; i++) {
                          var unit = finishingUnit![i].unitName;
                          if (unit == valueText!) {
                            Alert(
                                closeIcon: const SizedBox(),
                                padding: const EdgeInsets.only(
                                    top: 0.0, left: 18, right: 18),
                                image: Image.asset('images/Icon-512.png',
                                    height: 80, fit: BoxFit.fitWidth),
                                style: const AlertStyle(
                                    titleTextAlign: TextAlign.center,
                                    descTextAlign: TextAlign.center,
                                    descStyle: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16),
                                    isCloseButton: true),
                                context: context,
                                desc:
                                    "Entered unit has already exists. Please enter new unit or select from a unit list.",
                                alertAnimation: fadeAlertAnimation,
                                buttons: [
                                  DialogButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    color: Colors.black,
                                    child: const Text(
                                      "CLOSE",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  ),
                                ]).show();
                            flag = true;
                            break;
                          }
                        }
                        if (flag == false) {
                          submitAddCustomUnit();
                        }
                      } else {
                        Alert(
                            closeIcon: const SizedBox(),
                            padding: const EdgeInsets.only(
                                top: 0.0, left: 18, right: 18),
                            image: Image.asset('images/Icon-512.png',
                                height: 80, fit: BoxFit.fitWidth),
                            style: const AlertStyle(
                                titleTextAlign: TextAlign.center,
                                descTextAlign: TextAlign.center,
                                descStyle: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16),
                                isCloseButton: true),
                            context: context,
                            desc: "Please enter unit",
                            alertAnimation: fadeAlertAnimation,
                            buttons: [
                              DialogButton(
                                onPressed: () => Navigator.of(context).pop(),
                                color: Colors.black,
                                child: const Text(
                                  "CLOSE",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ),
                            ]).show();
                      }
                    });
                    Navigator.of(context).pop();
                  });
                },
              ),
            ],
          );
        });
  }

  Future<GetFinishingUnit?> submitAddCustomUnit() async {
    if (valueText == null || valueText!.trim().isEmpty) return null;
    final trimmedText = valueText!.trim();

    String newUnitId = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final res = await apiNetworkHandler.post1(AppUrl.poMeasuringUnits, {
        "name": trimmedText,
        "symbol": trimmedText,
      });
      if (res.statusCode == 200 || res.statusCode == 201) {
        final decoded = jsonDecode(res.body);
        final data = decoded['data'] ?? decoded;
        if (data is Map && data['id'] != null) {
          newUnitId = data['id'].toString();
        }
      }
    } catch (_) {}

    final newUnit = FinishingUnit(
      unitId: newUnitId,
      unitName: trimmedText,
      flag: "0",
    );

    setState(() {
      finishingUnit ??= [];
      finishingUnit!.add(newUnit);
      poMeasuringUnitsList.add(PoMeasuringUnit(id: newUnitId, name: trimmedText, symbol: trimmedText));
      unitItems.add(DropdownMenuItem(
        value: newUnit.unitName!,
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(StringUtils.capitalize(newUnit.unitName!.toLowerCase())),
        ),
      ));
    });

    _textFieldController.clear();
    Alert(
      closeIcon: const SizedBox(),
      padding: const EdgeInsets.only(top: 0.0, left: 18, right: 18),
      image: Image.asset('images/Icon-512.png', height: 80, fit: BoxFit.fitWidth),
      style: const AlertStyle(
        titleTextAlign: TextAlign.center,
        descTextAlign: TextAlign.center,
        descStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        isCloseButton: true,
      ),
      context: context,
      desc: "Unit added successfully",
      alertAnimation: fadeAlertAnimation,
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
          child: const Text("CLOSE", style: TextStyle(color: Colors.white, fontSize: 15)),
        ),
      ],
    ).show();

    return null;
  }

  Future<ResponsePurchaseDefaultOrderRequest?> submitAddCustomRequirementType(
      int indexRow) async {
    final customName = _txtCustomRequirementType.text.trim();
    if (customName.isEmpty) return null;

    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newType = FinishingTypeList(
      finishingId: newId,
      finishingName: customName,
      count: "0",
      finishingUnit: [
        FinishingUnit(unitId: "1", unitName: "Nos", flag: "1"),
        FinishingUnit(unitId: "2", unitName: "Kg", flag: "0"),
        FinishingUnit(unitId: "3", unitName: "Ton", flag: "0"),
        FinishingUnit(unitId: "4", unitName: "Cu.M", flag: "0"),
        FinishingUnit(unitId: "5", unitName: "Sq.Ft", flag: "0"),
        FinishingUnit(unitId: "6", unitName: "R.Ft", flag: "0"),
      ],
    );

    setState(() {
      finishingTypeList ??= [];
      finishingTypeList!.add(newType);
      finishingTypeListOriginal = List.from(finishingTypeList ?? []);

      _selectedReqTypeIndex = newId;
      selectedRequirementTypeId = newId;
      arrayList[indexRow].grade_id = newId;
      arrayList[indexRow].grade_type_name = customName;
      arrayList[indexRow].editingControllerGradeTypeName?.text = customName;
      _txtControllerRequirmentType[indexRow].text = customName;
      _txtCustomRequirementType.clear();

      arrayList[indexRow].casting_unit_name = '';
      arrayList[indexRow].casting_unit = '';
      arrayList[indexRow].description = '';

      fetchGradeDescription(selectedRequirementTypeIds: newId, index: indexRow);
    });

    return null;
  }

  Future<ResponseGradeDescription?> fetchGradeDescription(
      {int? index = 0, String? selectedRequirementTypeIds = ""}) async {
    PoVendorType? selectedType;
    if (selectedRequirementTypeIds != null && selectedRequirementTypeIds.isNotEmpty) {
      try {
        selectedType = poVendorTypesList.firstWhere(
          (element) => element.id == selectedRequirementTypeIds,
        );
      } catch (_) {
        selectedType = null;
      }
    }

    List<FinishingUnit> units = List.from(finishingUnit ?? []);
    if (units.isEmpty) {
      units = [
        FinishingUnit(unitId: "1", unitName: "Nos", flag: "1"),
        FinishingUnit(unitId: "2", unitName: "Kg", flag: "0"),
        FinishingUnit(unitId: "3", unitName: "Ton", flag: "0"),
        FinishingUnit(unitId: "4", unitName: "Bags", flag: "0"),
        FinishingUnit(unitId: "5", unitName: "Cu.M", flag: "0"),
        FinishingUnit(unitId: "6", unitName: "Brass", flag: "0"),
        FinishingUnit(unitId: "7", unitName: "Sq.Ft", flag: "0"),
        FinishingUnit(unitId: "8", unitName: "Sq.M", flag: "0"),
        FinishingUnit(unitId: "9", unitName: "R.Ft", flag: "0"),
        FinishingUnit(unitId: "10", unitName: "Ltr", flag: "0"),
      ];
    }

    setState(() {
      finishingUnit = units;
      if (selectedType != null && selectedType.grades.isNotEmpty) {
        descriptionList = selectedType.grades
            .where((g) => g.isActive)
            .map<SimilarDescription>(
                (g) => SimilarDescription(transGradeTypeName: g.name))
            .toList();
      } else {
        descriptionList = [];
      }
    });

    unitItems = [];
    for (var i = 0; i < units.length; i++) {
      if (units[i].flag == '1' && (arrayList[index ?? 0].casting_unit.isEmpty)) {
        arrayList[index ?? 0].casting_unit = units[i].unitId ?? '';
        selectedUnitId = units[i].unitId;
        arrayList[index ?? 0].editingControllerCastingUnitName?.text = units[i].unitName ?? '';
      }
      unitItems.add(DropdownMenuItem(
        value: units[i].unitName!,
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(StringUtils.capitalize(units[i].unitName!.toLowerCase())),
        ),
      ));
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;

    return LoaderOverlay(
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
            (widget.towarName != null && widget.towarName!.isNotEmpty)
                ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                : (widget.projectName?.toUpperCase() ?? 'PURCHASE ORDER'),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 15.0 : 17.0,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        body: !flagcalled
            ? PurchaseOrderSkeletonScreen(isMobile: isMobile)
            : SafeArea(
                child: Column(
                  children: [
                    // Top action header banner (centered subheader)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 24,
                        vertical: isMobile ? 8 : 12,
                      ),
                      color: Colors.white,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 110.0 : 150.0,
                              ),
                              child: Text(
                                'REQUEST PURCHASE ORDER',
                                style: TextStyle(
                                  fontSize: isMobile ? 13.0 : 16.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () async {
                                if (widget.vendMagicLink != null &&
                                    widget.vendMagicLink!.trim().isNotEmpty) {
                                  final uri =
                                      Uri.parse(widget.vendMagicLink!);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                    return;
                                  }
                                }
                                _showModernAlert(
                                  title: "Invite Vendor",
                                  message:
                                      "Vendor invite link is currently unavailable for this project.",
                                  isError: false,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 9 : 14,
                                    vertical: isMobile ? 5 : 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.black87),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.person_add_alt,
                                        size: isMobile ? 13 : 15,
                                        color: Colors.black87),
                                    const SizedBox(width: 4),
                                    Text(
                                      "INVITE VENDOR",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: isMobile ? 10.5 : 12.0,
                                        fontWeight: FontWeight.w600,
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
                    const Divider(height: 1.0, color: Color(0xFFE5E7EB)),

                    // Scrollable Form content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12.0 : 24.0,
                          vertical: isMobile ? 12.0 : 20.0,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Item Cards
                              for (int index = 0;
                                  index < arrayList.length;
                                  index++)
                                _buildItemCard(index, isMobile),

                              // Attachments Card
                              uploadDocImg(isMobile),

                              // Remarks Card
                              _remark(isMobile),

                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Fixed Bottom Bar with side-by-side buttons
                    _buildBottomActionBar(isMobile),
                  ],
                ),
              ),
      ),
    );
  }

  // Card for each requested item
  Widget _buildItemCard(int index, bool isMobile) {
    if (_txtControllerRequirmentType.length <= index) {
      _txtControllerRequirmentType.add(TextEditingController(
          text: arrayList[index].grade_type_name.toString()));
    } else {
      _txtControllerRequirmentType[index].text =
          arrayList[index].grade_type_name.toString();
    }

    if (_txtControllerUnitType.length <= index) {
      _txtControllerUnitType.add(TextEditingController(
          text: arrayList[index].casting_unit_name.toString()));
    } else {
      _txtControllerUnitType[index].text =
          arrayList[index].casting_unit_name.toString();
    }

    return Card(
      color: Colors.white,
      elevation: 1.5,
      margin: EdgeInsets.only(bottom: isMobile ? 14 : 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Header: Badge, Add As Previous, and Delete
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "ITEM #${index + 1}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (index > 0) ...[
                      InkWell(
                        onTap: () => _copyPreviousItem(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.copy_rounded,
                                  size: 13, color: Color(0xFF2563EB)),
                              SizedBox(width: 4),
                              Text(
                                "Add as Previous",
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (arrayList.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 20),
                        tooltip: "Remove Item",
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          _deleteItem(index);
                        },
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 14),

            // 1. Requirement Type
            _buildFieldContainer(
              isMobile: isMobile,
              label: "Requirement Type *",
              input: InkWell(
                onTap: () => _showRequirementTypeDialog(index),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          (arrayList[index].grade_type_name != null &&
                                  arrayList[index]
                                      .grade_type_name!
                                      .isNotEmpty)
                              ? arrayList[index].grade_type_name!
                              : "Select Requirement Type",
                          style: TextStyle(
                            fontSize: 13.5,
                            color: (arrayList[index].grade_type_name != null &&
                                    arrayList[index]
                                        .grade_type_name!
                                        .isNotEmpty)
                                ? Colors.black87
                                : const Color(0xFF9CA3AF),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down,
                          color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 2. Description / Sub-type
            _buildFieldContainer(
              isMobile: isMobile,
              label: "Description / Sub type *",
              input: TypeAheadFormField<String>(
                getImmediateSuggestions: true,
                textFieldConfiguration: TextFieldConfiguration(
                  controller: arrayList[index].editingControllerDescription,
                  style: const TextStyle(fontSize: 13.5, color: Colors.black87),
                  decoration: _buildInputDecoration(hintText: 'Enter Description'),
                  onChanged: (str) {
                    arrayList[index].description = str;
                    final currentTypeId = arrayList[index].grade_id;
                    PoVendorType? vt;
                    try {
                      vt = poVendorTypesList.firstWhere((t) => t.id == currentTypeId);
                    } catch (_) {}
                    if (vt != null) {
                      final grade = vt.grades.firstWhere(
                        (g) => g.name.toLowerCase() == str.trim().toLowerCase(),
                        orElse: () => PoVendorGrade(id: '', name: ''),
                      );
                      arrayList[index].vendor_type_grade_id =
                          grade.id.isNotEmpty ? grade.id : null;
                    }
                  },
                ),
                suggestionsCallback: (pattern) async {
                  final currentTypeId = arrayList[index].grade_id;
                  PoVendorType? vt;
                  try {
                    vt = poVendorTypesList.firstWhere((t) => t.id == currentTypeId);
                  } catch (_) {}

                  if (vt != null && vt.grades.isNotEmpty) {
                    return vt.grades
                        .where((g) =>
                            g.isActive &&
                            (pattern.isEmpty ||
                                g.name
                                    .toLowerCase()
                                    .contains(pattern.toLowerCase())))
                        .map<String>((g) => g.name)
                        .toList();
                  }
                  if (descriptionList != null && descriptionList!.isNotEmpty) {
                    return descriptionList!
                        .where((d) => (d.transGradeTypeName ?? '')
                            .toLowerCase()
                            .contains(pattern.toLowerCase()))
                        .map<String>((d) => d.transGradeTypeName ?? '')
                        .toList();
                  }
                  return CitiesService.getSuggestions(pattern);
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    dense: true,
                    title: Text(suggestion, style: const TextStyle(fontSize: 13)),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    arrayList[index].editingControllerDescription?.text =
                        suggestion;
                    arrayList[index].description = suggestion;

                    final currentTypeId = arrayList[index].grade_id;
                    PoVendorType? vt;
                    try {
                      vt = poVendorTypesList.firstWhere((t) => t.id == currentTypeId);
                    } catch (_) {}
                    if (vt != null) {
                      final grade = vt.grades.firstWhere(
                        (g) => g.name.toLowerCase() == suggestion.toLowerCase(),
                        orElse: () => PoVendorGrade(id: '', name: suggestion),
                      );
                      if (grade.id.isNotEmpty) {
                        arrayList[index].vendor_type_grade_id = grade.id;
                      }
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 12),

            // 3. Brand (Optional)
            _buildFieldContainer(
              isMobile: isMobile,
              label: "Brand",
              input: TextFormField(
                controller: arrayList[index].editingControllerBrandName,
                style: const TextStyle(fontSize: 13.5, color: Colors.black87),
                decoration: _buildInputDecoration(
                    hintText: 'Enter Brand Name (Optional)'),
                onChanged: (value) {
                  arrayList[index].brand_supplier_name = value;
                },
              ),
            ),
            const SizedBox(height: 12),

            // 4. Requirement For
            _buildFieldContainer(
              isMobile: isMobile,
              label: "Requirement For *",
              input: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          arrayList[index].editingControllerCastingFor,
                      style: const TextStyle(
                          fontSize: 13.5, color: Colors.black87),
                      decoration: _buildInputDecoration(
                          hintText: isMobile
                              ? 'Requirement for'
                              : 'Enter requirement for'),
                      onChanged: (str) {
                        arrayList[index].casting_for = str;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showSlabDialog(index),
                    child: Container(
                      height: isMobile ? 32 : 44,
                      padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                        border: Border.all(color: Colors.black87),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        isMobile ? 'SLAB' : 'SELECT SLAB',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 10.5 : 11.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 5. Requirement Date
            _buildFieldContainer(
              isMobile: isMobile,
              label: "Requirement Date *",
              input: InkWell(
                onTap: () async {
                  DateTime? newDateTime = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime(DateTime.now().year + 20),
                  );
                  if (newDateTime != null) {
                    setState(() {
                      selectedRequirementDate =
                          DateFormat('yyyy-MM-dd').format(newDateTime);
                      String displayDate =
                          DateFormat('dd MMM yyyy').format(newDateTime);
                      for (var i = 0; i < arrayList.length; i++) {
                        arrayList[i].casting_date = selectedRequirementDate!;
                        arrayList[i]
                            .editingControllerCastingDate
                            ?.text = displayDate;
                      }
                    });
                  }
                },
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (arrayList[index].casting_date != null &&
                                arrayList[index].casting_date!.isNotEmpty)
                            ? (arrayList[index]
                                    .editingControllerCastingDate
                                    ?.text
                                    .isNotEmpty ==
                                true
                                ? arrayList[index]
                                    .editingControllerCastingDate!
                                    .text
                                : arrayList[index].casting_date!)
                            : (selectedRequirementDate ??
                                'Select Requirement Date'),
                        style: TextStyle(
                          fontSize: 13.5,
                          color: (arrayList[index].casting_date != null &&
                                  arrayList[index].casting_date!.isNotEmpty)
                              ? Colors.black87
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                      const Icon(Icons.calendar_today_outlined,
                          size: 18, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 6. Quantity & Unit
            isMobile
                ? Column(
                    children: [
                      _buildFieldContainer(
                        isMobile: true,
                        label: "Quantity *",
                        input: TextField(
                          controller:
                              arrayList[index].editingControllerQuantity,
                          style: const TextStyle(
                              fontSize: 13.5, color: Colors.black87),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            DecimalTextInputFormatter(decimalPlaces: 3)
                          ],
                          decoration: _buildInputDecoration(
                              hintText: 'Enter Quantity'),
                          onChanged: (str) {
                            arrayList[index].quantity = str;
                            _recalculateAmount(index);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFieldContainer(
                        isMobile: true,
                        label: "Unit *",
                        input: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _showUnitTypeDialog(index),
                                child: Container(
                                  height: 44,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: const Color(0xFFD1D5DB)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          (arrayList[index].casting_unit_name !=
                                                      null &&
                                                  arrayList[index]
                                                      .casting_unit_name!
                                                      .isNotEmpty)
                                              ? arrayList[index]
                                                  .casting_unit_name!
                                              : 'Select Unit',
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            color: (arrayList[index]
                                                            .casting_unit_name !=
                                                        null &&
                                                    arrayList[index]
                                                        .casting_unit_name!
                                                        .isNotEmpty)
                                                ? Colors.black87
                                                : const Color(0xFF9CA3AF),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.black54),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () =>
                                  _showAddCustomUnitDialog(context),
                              child: Container(
                                height: isMobile ? 32 : 44,
                                padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 8 : 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(isMobile ? 16 : 20),
                                  border: Border.all(color: Colors.black87),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'ADD UNIT',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isMobile ? 10.5 : 11.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : _buildFieldContainer(
                    isMobile: false,
                    label: "Quantity & Unit *",
                    input: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller:
                                arrayList[index].editingControllerQuantity,
                            style: const TextStyle(
                                fontSize: 13.5, color: Colors.black87),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            inputFormatters: [
                              DecimalTextInputFormatter(decimalPlaces: 3)
                            ],
                            decoration: _buildInputDecoration(
                                hintText: 'Quantity'),
                            onChanged: (str) {
                              arrayList[index].quantity = str;
                              _recalculateAmount(index);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: () => _showUnitTypeDialog(index),
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFFD1D5DB)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      (arrayList[index].casting_unit_name !=
                                                  null &&
                                              arrayList[index]
                                                  .casting_unit_name!
                                                  .isNotEmpty)
                                          ? arrayList[index]
                                              .casting_unit_name!
                                          : 'Select Unit',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        color: (arrayList[index]
                                                        .casting_unit_name !=
                                                    null &&
                                                arrayList[index]
                                                    .casting_unit_name!
                                                    .isNotEmpty)
                                            ? Colors.black87
                                            : const Color(0xFF9CA3AF),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down,
                                      color: Colors.black54),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _showAddCustomUnitDialog(context),
                          child: Container(
                            height: 44,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.black87),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'ADD CUSTOM UNIT',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 11.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 12),

            // 7. Unit Price
            _buildFieldContainer(
              isMobile: isMobile,
              label: "Unit Price (Optional)",
              input: TextField(
                controller: arrayList[index].editingControllerUnitPrice,
                style: const TextStyle(fontSize: 13.5, color: Colors.black87),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  DecimalTextInputFormatter(decimalPlaces: 3)
                ],
                decoration: _buildInputDecoration(
                    hintText: 'Enter Unit Price (Optional)'),
                onChanged: (str) {
                  arrayList[index].unit_price = str;
                  _recalculateAmount(index);
                },
              ),
            ),
            const SizedBox(height: 12),

            // 8. Total Price
            _buildFieldContainer(
              isMobile: isMobile,
              label: "Total Price",
              input: TextField(
                controller:
                    arrayList[index].editingControllerTotalAmount,
                readOnly: true,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                decoration: _buildInputDecoration(
                  hintText: 'Total Price',
                  readOnly: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '₹',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
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

  // Common input decoration builder
  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool readOnly = false,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: prefixIcon,
      prefixIconConstraints:
          const BoxConstraints(minWidth: 0, minHeight: 0),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: readOnly ? const Color(0xFFF3F4F6) : Colors.white,
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(horizontal: 12.0, vertical: 11.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.black87, width: 1.5),
      ),
    );
  }

  // Common responsive container for fields
  Widget _buildFieldContainer({
    required bool isMobile,
    required String label,
    required Widget input,
    String? helperText,
  }) {
    final double labelWidth = isMobile ? 110.0 : 170.0;
    final double gap = isMobile ? 10.0 : 16.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isMobile ? 12.5 : 14.0,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
              height: 1.25,
            ),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              input,
              if (helperText != null) ...[
                const SizedBox(height: 3),
                Text(
                  helperText,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _recalculateAmount(int index) {
    final qtyStr = arrayList[index].quantity ?? '';
    final priceStr = arrayList[index].unit_price ?? '';
    final qty = double.tryParse(qtyStr);
    final price = double.tryParse(priceStr);
    setState(() {
      if (qty != null && price != null) {
        final amt = (qty * price).toStringAsFixed(2);
        arrayList[index].total_amount = amt;
        arrayList[index].editingControllerTotalAmount?.text = amt;
      } else {
        arrayList[index].total_amount = '0';
        arrayList[index].editingControllerTotalAmount?.text = '0';
      }
    });
  }

  void _copyPreviousItem(int index) {
    if (index <= 0) return;
    final prev = arrayList[index - 1];
    setState(() {
      arrayList[index].grade_id = prev.grade_id;
      arrayList[index].grade_type_name = prev.grade_type_name;
      arrayList[index].vendor_type_grade_id = prev.vendor_type_grade_id;
      arrayList[index].editingControllerGradeTypeName?.text =
          prev.grade_type_name ?? '';
      _txtControllerRequirmentType[index].text =
          prev.grade_type_name ?? '';

      arrayList[index].description = prev.description;
      arrayList[index].editingControllerDescription?.text =
          prev.description ?? '';

      arrayList[index].casting_for = prev.casting_for;
      arrayList[index].editingControllerCastingFor?.text =
          prev.casting_for ?? '';
      arrayList[index].slab_ids =
          prev.slab_ids != null ? List<String>.from(prev.slab_ids!) : null;

      arrayList[index].casting_date = prev.casting_date;
      arrayList[index].editingControllerCastingDate?.text =
          prev.editingControllerCastingDate?.text ?? '';

      arrayList[index].casting_unit = prev.casting_unit;
      arrayList[index].casting_unit_name = prev.casting_unit_name;
      arrayList[index].editingControllerCastingUnitName?.text =
          prev.casting_unit_name ?? '';
      _txtControllerUnitType[index].text =
          prev.casting_unit_name ?? '';

      arrayList[index].unit_price = prev.unit_price;
      arrayList[index].editingControllerUnitPrice?.text =
          prev.unit_price ?? '';

      arrayList[index].brand_supplier_name = prev.brand_supplier_name;
      arrayList[index].editingControllerBrandName?.text =
          prev.brand_supplier_name ?? '';

      _recalculateAmount(index);
    });
  }

  void _addMoreRequest() {
    bool isSame = false;
    for (var i = 0; i < arrayList.length; i++) {
      for (int k = i + 1; k < arrayList.length; k++) {
        if (arrayList[i].grade_type_name == arrayList[k].grade_type_name &&
            arrayList[i].description == arrayList[k].description) {
          isSame = true;
          break;
        }
      }
    }

    if (isSame) {
      _showModernAlert(
        title: "Duplicate Item",
        message:
            "An item with the same Requirement Type and Description is already added.",
        isError: true,
      );
      return;
    }

    selectedRow++;
    final prevSlabIds = arrayList.isNotEmpty ? arrayList.last.slab_ids : null;
    setState(() {
      arrayList.add(POformDataArrayList(
        brand_supplier_name: "",
        grade_id: '',
        grade_type_name: '',
        casting_date: selectedRequirementDate ?? '',
        casting_for: texteditingControllerRequiredFor.text,
        casting_unit_name: '',
        casting_unit: '',
        quantity: '',
        unit_price: '',
        total_amount: '0',
        description: '',
        id: selectedRow.toString(),
        slab_ids: prevSlabIds != null ? List<String>.from(prevSlabIds) : null,
        editingControllerGradeTypeName: TextEditingController(),
        editingControllerDescription: TextEditingController(),
        editingControllerCastingFor: TextEditingController(
            text: texteditingControllerRequiredFor.text),
        editingControllerCastingDate:
            TextEditingController(text: arrayList.isNotEmpty ? arrayList[0].editingControllerCastingDate?.text ?? '' : ''),
        editingControllerQuantity: TextEditingController(),
        editingControllerCastingUnitName: TextEditingController(),
        editingControllerUnitPrice: TextEditingController(),
        editingControllerTotalAmount: TextEditingController(text: '0'),
        editingControllerBrandName: TextEditingController(),
      ));
    });

    // Automatically scroll down to the newly added request card
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _deleteItem(int index) {
    if (arrayList.length <= 1) return;

    final currentOffset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;

    setState(() {
      arrayList.removeAt(index);
      if (_txtControllerRequirmentType.length > index) {
        _txtControllerRequirmentType.removeAt(index);
      }
      if (_txtControllerUnitType.length > index) {
        _txtControllerUnitType.removeAt(index);
      }
    });

    // Automatically scroll up to reflect the deleted item
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final targetOffset = (currentOffset - 180.0).clamp(0.0, maxScroll);
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  // Fixed Bottom Action Bar with side-by-side buttons
  Widget _buildBottomActionBar(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12.0 : 24.0,
        vertical: isMobile ? 10.0 : 14.0,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // 1. ADD MORE REQUEST
            Expanded(
              child: InkWell(
                onTap: _addMoreRequest,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.black87, width: 1.3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_circle_outline,
                          size: 18, color: Colors.black87),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          isMobile ? "ADD MORE REQUEST" : "ADD MORE REQUEST",
                          style: TextStyle(
                            fontSize: isMobile ? 11.5 : 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 2. PREVIEW PURCHASE ORDER
            Expanded(
              child: InkWell(
                onTap: _onPreviewPurchaseOrder,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.20),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.visibility_outlined,
                          size: 18, color: Colors.white),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          isMobile ? "PREVIEW PO" : "PREVIEW PURCHASE ORDER",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 12.0 : 13.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  void _onPreviewPurchaseOrder() {
    var flag = true;
    String msg = "";
    for (var i = 0; i < arrayList.length; i++) {
      final item = arrayList[i];
      if (item.grade_id.toString().trim().isEmpty) {
        msg = 'Please select Requirement type for Item #${i + 1}.';
        flag = false;
        break;
      }

      // Check if vendor type has active grades, in which case vendor_type_grade_id is required
      PoVendorType? vt;
      try {
        vt = poVendorTypesList.firstWhere((t) => t.id == item.grade_id);
      } catch (_) {}

      if (vt != null && vt.grades.any((g) => g.isActive)) {
        if (item.vendor_type_grade_id == null || item.vendor_type_grade_id!.isEmpty) {
          final matched = vt.grades.firstWhere(
            (g) => g.isActive && g.name.toLowerCase() == item.description.trim().toLowerCase(),
            orElse: () => PoVendorGrade(id: '', name: ''),
          );
          if (matched.id.isNotEmpty) {
            item.vendor_type_grade_id = matched.id;
          } else {
            msg = 'Please select a valid Subtype / Grade for Item #${i + 1} (${vt.name}).';
            flag = false;
            break;
          }
        }
      }

      if (item.description.toString().trim().isEmpty) {
        msg = 'Please enter Description / Sub-type for Item #${i + 1}.';
        flag = false;
        break;
      }

      // Slabs validation: item must target at least one slab
      if (item.slab_ids == null || item.slab_ids!.isEmpty) {
        final candidateNames = (item.casting_for.isNotEmpty ? item.casting_for : (item.editingControllerCastingFor?.text ?? ''))
            .split(',')
            .map((s) => s.trim().toLowerCase())
            .toList();
        final matchedSlabIds = (slabDetailsOriginal ?? [])
            .where((s) => candidateNames.contains((s.slab_name ?? '').toLowerCase()))
            .map((s) => s.slab_id ?? '')
            .where((id) => id.isNotEmpty)
            .toList();
        if (matchedSlabIds.isNotEmpty) {
          item.slab_ids = matchedSlabIds;
        } else {
          msg = 'Please select at least one slab for Item #${i + 1}.';
          flag = false;
          break;
        }
      }

      if (item.casting_date.toString().trim().isEmpty) {
        msg = 'Please select Requirement Date for Item #${i + 1}.';
        flag = false;
        break;
      }

      final qtyVal = double.tryParse(item.quantity.toString().trim());
      if (item.quantity.toString().trim().isEmpty || qtyVal == null || qtyVal <= 0) {
        msg = 'Please enter a valid quantity for Item #${i + 1}.';
        flag = false;
        break;
      }

      if (item.casting_unit.toString().trim().isEmpty) {
        msg = 'Please select Unit for Item #${i + 1}.';
        flag = false;
        break;
      }
    }

    if (!flag) {
      _showModernAlert(title: "Incomplete Details", message: msg, isError: true);
      return;
    }

    double totalAmt = 0.0;
    bool isSame = false;
    for (var i = 0; i < arrayList.length; i++) {
      totalAmt +=
          double.tryParse(arrayList[i].total_amount.toString()) ?? 0.0;
      for (int k = i + 1; k < arrayList.length; k++) {
        if (arrayList[i].grade_type_name == arrayList[k].grade_type_name &&
            arrayList[i].description == arrayList[k].description) {
          isSame = true;
          break;
        }
      }
    }

    if (isSame) {
      _showModernAlert(
        title: "Duplicate Item",
        message:
            "An item with the same Requirement Type and Description already exists. Please modify the item description.",
        isError: true,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return PurchaseOrderPreview(
            projectId: widget.projectId ?? '',
            towarId: (widget.towarId != null &&
                    widget.towarId!.isNotEmpty &&
                    widget.towarId != '0')
                ? widget.towarId!
                : (_resolvedTowerId ?? ''),
            towarName: widget.towarName ?? '',
            projectName: widget.projectName ?? '',
            arrBookingDetailsJSON: jsonEncode(arrayList),
            strRemark: strRemark ?? '',
            strSlabID: strSlabID ?? '',
            totalAmount: totalAmt,
            requestId: _draftRequestId,
            slabDetailsSelectedArray: slabDetailsSelectedArray,
            arrayFiles: arrayFiles,
            arrayFilesBytes: arrayFilesBytes,
          );
        },
      ),
    ).then((result) {
      if (result is String && result.isNotEmpty) {
        _draftRequestId = result;
      }
      checkNavigation();
    });
  }

  // Enhanced Modern Popups (RCC DPR standard)
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
              Icon(
                isError ? Icons.warning_amber_rounded : Icons.info_outline,
                size: 48,
                color: isError ? Colors.amber[800] : Colors.blueGrey,
              ),
              const SizedBox(height: 14),
              Text(
                message,
                style: TextStyle(
                  fontSize: isMobile ? 13.5 : 14.5,
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
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "CLOSE",
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

  void _showRequirementTypeDialog(int indexRow) {
    final isMobile = context.isMobile;
    editingController.text = "";
    finishingTypeList = List.from(finishingTypeListOriginal ?? []);

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: EdgeInsets.zero,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: Colors.black,
                child: Text(
                  "SELECT REQUIREMENT TYPE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              content: SizedBox(
                width: isMobile ? 320 : 460,
                height: isMobile ? 420 : 480,
                child: Column(
                  children: [
                    TextField(
                      controller: editingController,
                      style: const TextStyle(fontSize: 13.5),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        hintText: "Search requirement type...",
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: editingController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  setDialogState(() {
                                    editingController.clear();
                                    finishingTypeList = List.from(
                                        finishingTypeListOriginal ?? []);
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.black87),
                        ),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          if (value.trim().isEmpty) {
                            finishingTypeList =
                                List.from(finishingTypeListOriginal ?? []);
                          } else {
                            finishingTypeList = finishingTypeListOriginal
                                ?.where((element) => (element.finishingName ??
                                        '')
                                    .toLowerCase()
                                    .contains(value.toLowerCase().trim()))
                                .toList();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: (finishingTypeList == null ||
                              finishingTypeList!.isEmpty)
                          ? const Center(
                              child: Text(
                                "No requirement types found",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 13),
                              ),
                            )
                          : ListView.separated(
                              itemCount: finishingTypeList!.length,
                              separatorBuilder: (_, __) => const Divider(
                                  height: 1, color: Color(0xFFF3F4F6)),
                              itemBuilder: (context, index) {
                                final item = finishingTypeList![index];
                                final isSelected = _selectedReqTypeIndex ==
                                    item.finishingId;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedReqTypeIndex =
                                          item.finishingId;
                                      selectedRequirementTypeId =
                                          item.finishingId;
                                      arrayList[indexRow].grade_type_name =
                                          item.finishingName ?? '';
                                      arrayList[indexRow].grade_id =
                                          item.finishingId ?? '';
                                      arrayList[indexRow]
                                          .editingControllerGradeTypeName
                                          ?.text = item.finishingName ?? '';
                                      _txtControllerRequirmentType[indexRow]
                                          .text = item.finishingName ?? '';
                                      arrayList[indexRow]
                                          .casting_unit_name = '';
                                      arrayList[indexRow].casting_unit = '';
                                      arrayList[indexRow]
                                          .editingControllerCastingUnitName
                                          ?.clear();
                                      arrayList[indexRow].description = '';
                                      fetchGradeDescription(
                                        index: indexRow,
                                        selectedRequirementTypeIds:
                                            item.finishingId,
                                      );
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 12),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          size: 20,
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            item.finishingName ?? '',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _showAddCustomRequirementTypeDialog(indexRow);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFD1D5DB)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.add, size: 16, color: Colors.black87),
                            SizedBox(width: 6),
                            Text(
                              "Add Custom Requirement Type",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actionsPadding: const EdgeInsets.only(bottom: 14, top: 4),
              actions: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "CLOSE",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
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

  void _showSlabDialog(int index) {
    final isMobile = context.isMobile;
    _txtSearchSlab.clear();
    List<SlabDetail> localSlabList = List.from(slabDetailsOriginal ?? []);

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: EdgeInsets.zero,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: Colors.black,
                child: Text(
                  "SELECT SLAB",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              content: SizedBox(
                width: isMobile ? 320 : 460,
                height: isMobile ? 420 : 480,
                child: Column(
                  children: [
                    TextField(
                      controller: _txtSearchSlab,
                      style: const TextStyle(fontSize: 13.5),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        hintText: "Search slab...",
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _txtSearchSlab.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  setDialogState(() {
                                    _txtSearchSlab.clear();
                                    localSlabList = List.from(
                                        slabDetailsOriginal ?? []);
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.black87),
                        ),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          if (value.trim().isEmpty) {
                            localSlabList =
                                List.from(slabDetailsOriginal ?? []);
                          } else {
                            localSlabList = slabDetailsOriginal
                                    ?.where((element) => (element.slab_name ??
                                            '')
                                        .toLowerCase()
                                        .contains(value.toLowerCase().trim()))
                                    .toList() ??
                                [];
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: localSlabList.isEmpty
                          ? const Center(
                              child: Text(
                                "No slabs available. You can type directly in the field.",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.separated(
                              itemCount: localSlabList.length,
                              separatorBuilder: (_, __) => const Divider(
                                  height: 1, color: Color(0xFFF3F4F6)),
                              itemBuilder: (context, indexFor) {
                                final slab = localSlabList[indexFor];
                                final isSelected = slab.selected == '1';
                                return InkWell(
                                  onTap: () {
                                    setDialogState(() {
                                      slab.selected = isSelected ? '0' : '1';
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 12),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected
                                              ? Icons.check_box
                                              : Icons.check_box_outline_blank,
                                          size: 20,
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            slab.slab_name ?? '',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actionsPadding: const EdgeInsets.only(bottom: 14, top: 4),
              actions: [
                InkWell(
                  onTap: () {
                    final selectedSlabObjects = (slabDetailsOriginal ?? [])
                        .where((s) => s.selected == '1')
                        .toList();
                    final selectedSlabs = selectedSlabObjects
                        .map((s) => s.slab_name ?? '')
                        .where((name) => name.isNotEmpty)
                        .join(', ');
                    final selectedSlabIds = selectedSlabObjects
                        .map((s) => s.slab_id ?? '')
                        .where((id) => id.isNotEmpty)
                        .toList();
                    setState(() {
                      if (selectedSlabs.isNotEmpty) {
                        arrayList[index].casting_for = selectedSlabs;
                        arrayList[index]
                            .editingControllerCastingFor
                            ?.text = selectedSlabs;
                        arrayList[index].slab_ids = selectedSlabIds;
                        texteditingControllerRequiredFor.text = selectedSlabs;
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "DONE",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
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

  void _showUnitTypeDialog(int indexRow) {
    final isMobile = context.isMobile;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final units = finishingUnit ?? [];
            return AlertDialog(
              backgroundColor: Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: EdgeInsets.zero,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: Colors.black,
                child: Text(
                  "SELECT UNIT TYPE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              content: SizedBox(
                width: isMobile ? 300 : 400,
                height: isMobile ? 360 : 420,
                child: Column(
                  children: [
                    Expanded(
                      child: units.isEmpty
                          ? const Center(
                              child: Text("No units available",
                                  style: TextStyle(color: Colors.grey)),
                            )
                          : ListView.separated(
                              itemCount: units.length,
                              separatorBuilder: (_, __) => const Divider(
                                  height: 1, color: Color(0xFFF3F4F6)),
                              itemBuilder: (context, index) {
                                final u = units[index];
                                final isSelected =
                                    arrayList[indexRow].casting_unit ==
                                        u.unitId;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedUnitId = u.unitId;
                                      selectedUnitType = u.unitName;
                                      arrayList[indexRow].casting_unit_name =
                                          u.unitName ?? '';
                                      arrayList[indexRow].casting_unit =
                                          u.unitId ?? '';
                                      arrayList[indexRow]
                                          .editingControllerCastingUnitName
                                          ?.text = u.unitName ?? '';
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 12),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          size: 20,
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            u.unitName ?? '',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _showAddCustomUnitDialog(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFD1D5DB)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.add, size: 16, color: Colors.black87),
                            SizedBox(width: 6),
                            Text(
                              "Add Custom Unit",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actionsPadding: const EdgeInsets.only(bottom: 14, top: 4),
              actions: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "CLOSE",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
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

  void _showAddCustomUnitDialog(BuildContext context) {
    final isMobile = context.isMobile;
    _textFieldController.clear();
    showDialog<void>(
      context: context,
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
              "ADD CUSTOM UNIT",
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter Unit Name",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _textFieldController,
                decoration: _buildInputDecoration(
                    hintText: "e.g., Bundles, Pallets"),
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
                        horizontal: 20, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black54),
                    ),
                    child: const Text(
                      "CANCEL",
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    final text = _textFieldController.text.trim();
                    if (text.isEmpty) {
                      _showModernAlert(
                          title: "Warning",
                          message: "Please enter a unit name.",
                          isError: true);
                      return;
                    }
                    valueText = text;
                    Navigator.pop(context);
                    submitAddCustomUnit();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "ADD UNIT",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5),
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

  void _showAddCustomRequirementTypeDialog(int indexRow) {
    final isMobile = context.isMobile;
    _txtCustomRequirementType.clear();
    showDialog<void>(
      context: context,
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
              "ADD REQUIREMENT TYPE",
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Requirement Type Name",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _txtCustomRequirementType,
                decoration: _buildInputDecoration(
                    hintText: "Enter requirement type"),
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
                        horizontal: 20, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black54),
                    ),
                    child: const Text(
                      "CANCEL",
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    final text = _txtCustomRequirementType.text.trim();
                    if (text.isEmpty) {
                      _showModernAlert(
                          title: "Warning",
                          message: "Please enter requirement type.",
                          isError: true);
                      return;
                    }
                    Navigator.pop(context);
                    submitAddCustomRequirementType(indexRow);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "SUBMIT",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5),
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

  // Uploaded documents gallery card
  Widget uploadDocImg(bool isMobile) {
    return Card(
      color: Colors.white,
      elevation: 1.5,
      margin: EdgeInsets.only(bottom: isMobile ? 14 : 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 14 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.attach_file, size: 20, color: Colors.black87),
                    SizedBox(width: 6),
                    Text(
                      "ATTACHMENTS",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                if (arrayFiles.isNotEmpty)
                  Text(
                    "${arrayFiles.length} file(s)",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                InkWell(
                  onTap: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                    );
                    if (result != null) {
                      setState(() {
                        arrayFilesBytes.add(result.files.first.bytes);
                        arrayFiles.add(result.files.first);
                      });
                    }
                  },
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFD1D5DB),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.cloud_upload_outlined,
                            size: 30, color: Colors.black54),
                        SizedBox(height: 4),
                        Text(
                          "Upload",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                for (int j = 0; j < arrayFiles.length; j++)
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: (arrayFiles[j].extension == 'jpg' ||
                                  arrayFiles[j].extension == 'jpeg' ||
                                  arrayFiles[j].extension == 'png')
                              ? (kIsWeb && arrayFilesBytes[j] != null)
                                  ? Image.memory(arrayFilesBytes[j]!,
                                      fit: BoxFit.cover)
                                  : Image.file(
                                      File(arrayFiles[j].path ?? ''),
                                      fit: BoxFit.cover)
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.picture_as_pdf,
                                        color: Colors.red, size: 36),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: Text(
                                        arrayFiles[j].name,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black87),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              arrayFiles.removeAt(j);
                              arrayFilesBytes.removeAt(j);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Remarks card
  Widget _remark(bool isMobile) {
    return Card(
      color: Colors.white,
      elevation: 1.5,
      margin: EdgeInsets.only(bottom: isMobile ? 14 : 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 14 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.notes, size: 20, color: Colors.black87),
                SizedBox(width: 6),
                Text(
                  "OTHER REMARKS",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              maxLines: 3,
              style: const TextStyle(color: Colors.black87, fontSize: 13.5),
              decoration: _buildInputDecoration(
                hintText:
                    'Enter any additional remarks or instructions (Optional)',
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: (String str) {
                strRemark = str;
              },
            ),
          ],
        ),
      ),
    );
  }

  void checkNavigation() async {
    final SharedPreferences prefs = await _prefs;
    String? flagRedirect = prefs.getString('flagRedirectToWorkProgress');
    if (flagRedirect == 'true') {
      backToScreen();
    }
  }

  void backToScreen() {
    Navigator.maybePop(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class PurchaseOrderSkeletonScreen extends StatelessWidget {
  final bool isMobile;
  const PurchaseOrderSkeletonScreen({Key? key, required this.isMobile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14.0 : 24.0,
        vertical: 16.0,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header bar skeleton (centered)
            Center(
              child: SkeletonBox(
                  width: isMobile ? 200 : 260,
                  height: 24,
                  borderRadius: 6),
            ),
            const SizedBox(height: 16),
            // Card skeletons
            for (int i = 0; i < 2; i++)
              Card(
                color: Colors.white,
                elevation: 1.5,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 12 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SkeletonBox(
                              width: 80, height: 24, borderRadius: 12),
                          SkeletonBox(
                              width: 110, height: 20, borderRadius: 10),
                        ],
                      ),
                      const SizedBox(height: 16),
                      for (int k = 0; k < 5; k++) ...[
                        SkeletonBox(
                            width: double.infinity,
                            height: 44,
                            borderRadius: 8),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SkeletonBox(
                      width: double.infinity, height: 48, borderRadius: 25),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SkeletonBox(
                      width: double.infinity, height: 48, borderRadius: 25),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CitiesService {
  static List<String> cities = [];

  static List<String> getSuggestions(String query) {
    List<String> matches = <String>[];
    matches.addAll(cities);

    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalPlaces;

  DecimalTextInputFormatter({this.decimalPlaces = 2});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final regExp = RegExp(r'^\d*\.?\d{0,' + decimalPlaces.toString() + r'}$');
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    } else {
      return oldValue;
    }
  }
}
