import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/excavation_api_models.dart';
import 'package:stallion/models/get_default_excavation.dart';
import 'package:stallion/models/get_excavation_list.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/rccstructure/excavation/add_vehicle.dart';
import 'package:stallion/ui/views/rccstructure/excavation/excavation_detail_page.dart';
import 'package:stallion/ui/views/rccstructure/common/rcc_mock_data.dart';
import 'package:stallion/ui/views/rccstructure/rcc_skeleton_loader.dart';
import 'package:stallion/ui/widgets/row_three_text.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';

class ExcavationScreen extends StatefulWidget {
  const ExcavationScreen({
    Key? key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.title,
    this.slabId,
    this.towarName,
  }) : super(key: key);

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? title;
  final String? slabId;

  @override
  State<ExcavationScreen> createState() => _ExcavationScreenState();
}

class _ExcavationScreenState extends State<ExcavationScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  List<BottomBar>? bottomBarResponse = [];
  List<TruckSize>? vehicleTypeResponse = [];
  List<TruckSize>? truckSizeResponse = [];
  List<TruckSize>? typeRoyalityResponse = [];
  List<BottomBar>? filterBar = [];
  BottomBar filterBottomBarSelected = BottomBar(id: "", value: "", name: "All");
  String bottomSelected = '';
  String truckSizeSelected = '';
  List<SlabDetail>? slabDetails;
  String? offset = '0';
  GetExcavationListResponse? responsee;
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
    return 'EXCAVATION & DEBRIS';
  }

  String getSubHeaderTitle() {
    final slabTitle = widget.title?.trim().toUpperCase() ?? 'SLAB';
    return '$slabTitle - EXCAVATION';
  }

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    setState(() {
      isLoading = true;
    });
    await getDefaultList();
    await getExcavationList();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<SlabDetail>?> getDefaultList() async {
    if (useRccMockData) {
      final mockData = getMockDefaultExcavationData();
      if (mounted) {
        setState(() {
          slabDetails = mockData.slabDetails;
          vehicleTypeResponse = mockData.vehicleType;
          truckSizeResponse = mockData.truckSize;
          typeRoyalityResponse = mockData.typeRoyality;
        });
      }
      return slabDetails;
    }

    try {
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        await apiNetworkHandler.ensureProjectContext(widget.projectId);
      }

      // Fetch Vehicle Types
      var vResponse = await apiNetworkHandler.get(AppUrl.getVehicleTypes);
      if (vResponse.statusCode == 200 || vResponse.statusCode == 201) {
        final vtModel = vehicleTypesResponseFromJson(vResponse.body);
        if (vtModel.success) {
          vehicleTypeResponse = vtModel.vehicleTypes
              .where((e) => e.isActive)
              .map<TruckSize>((e) => TruckSize(id: e.id, name: e.name, value: e.description))
              .toList();
        }
      }

      // Fetch Truck Sizes
      var tResponse = await apiNetworkHandler.get(AppUrl.getTruckSizes);
      if (tResponse.statusCode == 200 || tResponse.statusCode == 201) {
        final tsModel = truckSizesResponseFromJson(tResponse.body);
        if (tsModel.success) {
          truckSizeResponse = tsModel.truckSizes
              .where((e) => e.isActive)
              .map<TruckSize>((e) => TruckSize(id: e.id, name: e.name, value: e.description))
              .toList();
        }
      }

      // Fetch Royalty Types
      var rResponse = await apiNetworkHandler.get(AppUrl.getRoyaltyTypes);
      if (rResponse.statusCode == 200 || rResponse.statusCode == 201) {
        final rtModel = royaltyTypesResponseFromJson(rResponse.body);
        if (rtModel.success) {
          typeRoyalityResponse = rtModel.royaltyTypes
              .where((e) => e.isActive)
              .map<TruckSize>((e) => TruckSize(id: e.id, name: e.name, value: e.description))
              .toList();
        }
      }
    } catch (e) {
      if (kDebugMode) print("Get Default Excavation Error: $e");
    }
    return slabDetails;
  }

  Future<List<SlabDetail>?> getExcavationList() async {
    if (useRccMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final mockData = getMockExcavationListData();
      if (mounted) {
        setState(() {
          offset = mockData.offset;
          responsee = mockData;
          bottomBarResponse = mockData.bottomBar;
          filterBar = mockData.filterBar;

          if (filterBar != null && filterBar!.isNotEmpty) {
            final match = filterBar!.firstWhere(
              (item) => item.id == truckSizeSelected,
              orElse: () => filterBar![0],
            );
            filterBottomBarSelected = match;
          }
        });
      }
      return null;
    }

    try {
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        await apiNetworkHandler.ensureProjectContext(widget.projectId);
      }

      final String towerId = widget.towarId ?? '';
      if (towerId.isEmpty) {
        if (kDebugMode) print("No towerId provided for getTowerExcavations");
        return null;
      }

      String url = AppUrl.getTowerExcavations(towerId);
      List<String> queryParams = [];
      if (bottomSelected.isNotEmpty && bottomSelected != 'all') {
        queryParams.add("royalty_type_id=$bottomSelected");
      }
      if (truckSizeSelected.isNotEmpty) {
        queryParams.add("truck_size_id=$truckSizeSelected");
      }
      if (queryParams.isNotEmpty) {
        url += "?${queryParams.join('&')}";
      }

      var response = await apiNetworkHandler.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final historyRes = excavationHistoryResponseFromJson(response.body);
        if (historyRes.success && historyRes.data != null) {
          final hData = historyRes.data!;

          List<BottomBar> newFilterBar = hData.royaltyFilters.map((f) {
            return BottomBar(
              id: f.id ?? '',
              name: f.name,
              value: f.cumLoaded,
              truckValue: f.entriesCount.toString(),
            );
          }).toList();

          List<BottomBar> updatedFilterBar = newFilterBar.isNotEmpty
              ? newFilterBar
              : (filterBar ?? []);

          List<FinalExcavalionList> newList = hData.data
              .map((entry) => FinalExcavalionList.fromApiEntry(entry))
              .toList();

          GetExcavationListResponse mappedResponse = GetExcavationListResponse(
            errorCode: "0",
            msg: historyRes.message,
            finalExcavalionList: newList,
            totalValue: hData.royaltyFilters.isNotEmpty
                ? hData.royaltyFilters.first.cumLoaded
                : "0",
            bottomBar: updatedFilterBar,
            filterBar: updatedFilterBar,
            offset: hData.pagination?.page.toString() ?? '1',
          );

          if (mounted) {
            setState(() {
              responsee = mappedResponse;
              if (newFilterBar.isNotEmpty || bottomBarResponse == null || bottomBarResponse!.isEmpty) {
                bottomBarResponse = updatedFilterBar;
                filterBar = updatedFilterBar;
              }
              if (filterBar != null && filterBar!.isNotEmpty) {
                final match = filterBar!.firstWhere(
                  (item) =>
                      item.id == bottomSelected ||
                      (bottomSelected.isEmpty &&
                          (item.id == null || item.id == '' || item.name?.toLowerCase() == 'all')),
                  orElse: () => filterBar![0],
                );
                filterBottomBarSelected = match;
              }
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print("Get Excavation List Error: $e");
    }
    return null;
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      offset = '0';
      truckSizeSelected = '';
      bottomBarResponse = [];
      responsee = null;
    });
    await getExcavationList();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 100));
    await getExcavationList();
    _refreshController.loadComplete();
  }

  void _navigateToAddVehicle() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddVehicle(
          truckSizeResponse: truckSizeResponse,
          typeRoyalityResponse: typeRoyalityResponse,
          vehicleTypeResponse: vehicleTypeResponse,
          title: widget.title,
          projectId: widget.projectId,
          towarId: widget.towarId ?? '',
          projectName: widget.projectName,
          towarName: widget.towarName ?? '',
          slabId: widget.slabId,
          slabDetails: slabDetails,
        ),
      ),
    ).then((value) {
      setState(() {
        offset = '0';
        truckSizeSelected = '';
      });
      getExcavationList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final baseStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

    final bool hasData = responsee?.finalExcavalionList != null &&
        responsee!.finalExcavalionList!.isNotEmpty;

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: InkWell(
                onTap: _navigateToAddVehicle,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 5 : 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -0.5),
                        child: Icon(Icons.add, color: Colors.black, size: isMobile ? 14 : 16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "ADD VEHICLE",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: isMobile ? 12 : 14,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
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
      body: SafeArea(
        child: Column(
          children: [
            // SubHeader Bar: SLAB NAME - EXCAVATION & Filter Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 20,
                vertical: isMobile ? 5 : 6,
              ),
              color: Colors.white,
              child: Row(
                children: [
                  SizedBox(width: isMobile ? 34 : 36), // Balance for filter icon width on right
                  Expanded(
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
                  InkWell(
                    onTap: () => selectTruckSizeModal(contextModal: context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xfff8f9fa),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xffe0e0e0)),
                      ),
                      child: Image.asset(
                        'images/projectmanagement/filter-sort-icon.png',
                        height: isMobile ? 18 : 20,
                        width: isMobile ? 18 : 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1.0, color: Colors.black12),

            // Body Area
            Expanded(
              child: isLoading
                  ? ExcavationSkeletonScreen(isMobile: isMobile)
                  : (hasData
                      ? SmartRefresher(
                          enablePullDown: true,
                          enablePullUp: true,
                          controller: _refreshController,
                          onRefresh: _onRefresh,
                          onLoading: _onLoading,
                          footer: const ClassicFooter(loadStyle: LoadStyle.ShowWhenLoading),
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12.0 : 20.0,
                              vertical: isMobile ? 12.0 : 16.0,
                            ),
                            itemCount: responsee!.finalExcavalionList!.length,
                            itemBuilder: (context, index) {
                              return excavationCard(
                                data: responsee!.finalExcavalionList![index],
                                isMobile: isMobile,
                                baseStyle: baseStyle,
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_shipping_outlined,
                                  size: isMobile ? 56 : 72,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "No Excavation Vehicles Added Yet",
                                  style: TextStyle(
                                    fontSize: isMobile ? 15 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Tap below to add excavation trip or hiring details.",
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                InkWell(
                                  onTap: _navigateToAddVehicle,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 24 : 32,
                                      vertical: isMobile ? 10 : 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Transform.translate(
                                          offset: const Offset(0, -0.5),
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: isMobile ? 18 : 20,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "ADD VEHICLE",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isMobile ? 14 : 16,
                                            fontWeight: FontWeight.bold,
                                            height: 1.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
            ),
          ],
        ),
      ),

      // Bottom Summary Action Bar
      bottomNavigationBar: (!isLoading && bottomBarResponse != null && bottomBarResponse!.isNotEmpty)
          ? Container(
              color: Colors.white,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Summary Banner Label
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 6 : 8,
                        horizontal: 16,
                      ),
                      color: Colors.black,
                      child: Text(
                        "Total Number of Trucks (${filterBottomBarSelected.name ?? 'All'}) : ${filterBottomBarSelected.truckValue ?? '0'}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 13 : 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Royalty Filter Tabs (Pill Segmented Control like legal_screen.dart)
                    if (bottomBarResponse != null && bottomBarResponse!.isNotEmpty)
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 20,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xfff8f9fa),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(color: const Color(0xffe9ecef), width: 1.0),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              for (int i = 0; i < bottomBarResponse!.length; i++) ...[
                                if (i > 0)
                                  Container(
                                    height: 24,
                                    width: 1.0,
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        offset = '0';
                                        bottomSelected = bottomBarResponse![i].id ?? '';
                                      });
                                      getExcavationList();
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      constraints: BoxConstraints(
                                        minWidth: isMobile ? 0.0 : 150.0,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 12 : 20,
                                        vertical: isMobile ? 6 : 8,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12.0),
                                        color: bottomSelected == bottomBarResponse![i].id
                                            ? Colors.black
                                            : Colors.transparent,
                                      ),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            bottomBarResponse![i].name ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: isMobile ? 11 : 13,
                                              color: bottomSelected == bottomBarResponse![i].id
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: isMobile ? 1 : 2),
                                          Text(
                                            '${double.parse(bottomBarResponse![i].value ?? '0').toStringAsFixed(2)} CUM',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: isMobile ? 10 : 12,
                                              color: bottomSelected == bottomBarResponse![i].id
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: isMobile ? 1 : 2),
                                          Text(
                                            '(${bottomBarResponse![i].truckValue ?? '0'} Trucks)',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: isMobile ? 10 : 12,
                                              color: bottomSelected == bottomBarResponse![i].id
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget excavationCard({
    required FinalExcavalionList data,
    required bool isMobile,
    required TextStyle baseStyle,
  }) {
    bool isDumper = data.vehicelType == "4" ||
        (data.vehilceTypeName ?? "").toLowerCase().contains("dumper") ||
        data.vehicelType == "3";

    String headerTitle = isDumper
        ? "Dumper"
        : ((data.vehilceTypeName != null && data.vehilceTypeName!.isNotEmpty)
            ? data.vehilceTypeName!
            : "Vehicle Entry");

    String formattedDateUser = '';
    if (data.excavationUpdatedAt != null) {
      formattedDateUser =
          '${DateFormat('dd-MM-yyyy').format(data.excavationUpdatedAt!)} by ${data.userName ?? 'System'}';
    } else if (data.userName != null && data.userName!.isNotEmpty) {
      formattedDateUser = 'By ${data.userName}';
    } else {
      formattedDateUser = 'System';
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExcavationDetailPage(
                  slabId: widget.slabId,
                  title: widget.title,
                  projectId: widget.projectId,
                  towarId: widget.towarId ?? '',
                  projectName: widget.projectName,
                  towarName: widget.towarName ?? '',
                  dataa: data,
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        headerTitle,
                        style: baseStyle.copyWith(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1, color: Color(0xfff1f3f5)),
                      const SizedBox(height: 8),

                      if (isDumper) ...[
                        // Row 1 - Vehicle Number
                        buildInfoRow("Vehicle Number", data.vehicelNo ?? "--", isMobile, baseStyle),
                        // Row 2 - Truck Size
                        buildInfoRow("Truck Size", data.truckSizeName, isMobile, baseStyle),
                        // Row 3 - Challan No
                        buildInfoRow("Challan No", data.excavationChallanNo, isMobile, baseStyle),
                        // Row 4 - CUM. Loaded
                        buildInfoRow("CUM Loaded", data.cumLoadValue, isMobile, baseStyle),
                        // Row 5 - Type
                        buildInfoRow("Type", data.typeRoyalityName, isMobile, baseStyle),
                        // Row 6 - Date and User Name
                        buildInfoRow("Date & User", formattedDateUser, isMobile, baseStyle),
                      ] else ...[
                        // Row 1 - Hiring Charges
                        buildInfoRow(
                          "Hiring Charges",
                          data.hiringCharges != null
                              ? currencyFormat.format(double.tryParse(data.hiringCharges!) ?? 0)
                              : null,
                          isMobile,
                          baseStyle,
                        ),
                        // Row 2 - Challan No
                        buildInfoRow("Challan No", data.excavationChallanNo, isMobile, baseStyle),
                        // Row 3 - Shift Required
                        buildInfoRow("Shift Required", data.shiftRequired, isMobile, baseStyle),
                        // Row 4 - Used For
                        buildInfoRow("Used For", data.excavationUsedFor ?? data.fromExcavation, isMobile, baseStyle),
                        // Row 5 - Date and User Name
                        buildInfoRow("Date & User", formattedDateUser, isMobile, baseStyle),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: isMobile ? 20 : 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String? value, bool isMobile, TextStyle baseStyle) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text.rich(
        TextSpan(
          style: baseStyle.copyWith(fontSize: isMobile ? 11 : 13, height: 1.3),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ],
        ),
      ),
    );
  }

  void selectTruckSizeModal({required BuildContext contextModal}) {
    final isMobile = contextModal.isMobile;
    final baseStyle = Theme.of(contextModal).textTheme.bodyMedium ?? const TextStyle();
    final list = truckSizeResponse ?? [];

    final displayList = [
      TruckSize(id: "", name: "All Truck Sizes"),
      ...list,
    ];

    final ScrollController scrollController = ScrollController();

    showDialog<void>(
      barrierDismissible: false,
      context: contextModal,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              titlePadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 18,
                vertical: 12,
              ),
              actionsPadding: EdgeInsets.only(
                bottom: isMobile ? 14 : 18,
                left: 16,
                right: 16,
              ),
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
                  'FILTER TRUCK SIZE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              content: SizedBox(
                width: isMobile ? 280 : 380,
                height: 280,
                child: displayList.isEmpty
                    ? const Center(child: Text("No Truck Sizes Available"))
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
                            itemCount: displayList.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1, color: Colors.black12),
                            itemBuilder: (contextModal, int indexFor) {
                              final item = displayList[indexFor];
                              final isSelected = truckSizeSelected == (item.id ?? '');
                              return InkWell(
                                onTap: () {
                                  setModalState(() {
                                    truckSizeSelected = item.id ?? '';
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.name ?? '',
                                        style: baseStyle.copyWith(
                                          fontSize: isMobile ? 13 : 15,
                                        ),
                                      ),
                                      Icon(
                                        isSelected
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
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
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(contextModal).pop();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 8 : 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "CLOSE",
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            offset = '0';
                          });
                          getExcavationList();
                          Navigator.of(contextModal).pop();
                        },
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
                            "FILTER",
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
      },
    ).whenComplete(() => scrollController.dispose());
  }
}
