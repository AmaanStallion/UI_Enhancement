import 'supply_preview.dart';
import 'supply_style.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_all_sales_lead.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/models/sales_lead_filter.dart';
import 'package:stallion/ui/views/statusofsupply/inventory_management.dart';
import 'package:stallion/ui/views/statusofsupply/suppliesdetails.dart';
import '../../../models/get_status_of_supply_list.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import '../accountmanagement/grnlistingview.dart';

// class StatusOfSupplyView extends StatefulWidget {
//   StatusOfSupplyView(
//       {super.key,
//       this.projectId,
//       this.towarId,
//       this.projectName,
//       this.towarName,
//       this.navigationFlag});

//   final String? projectId;
//   String? towarId;
//   final String? projectName;
//   final String? navigationFlag;
//   final String? towarName;

//   @override
//   State<StatusOfSupplyView> createState() => _StatusOfSupplyViewState();
// }
class StatusOfSupplyView extends StatefulWidget {
  const StatusOfSupplyView({super.key});

  @override
  State<StatusOfSupplyView> createState() => _StatusOfSupplyViewState();
}

class _StatusOfSupplyViewState extends State<StatusOfSupplyView> {
  late NotificationArgs args;
  bool _initialRequestsStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is NotificationArgs) {
      args = routeArgs;
    } else {
      args = NotificationArgs(
        projectId: '',
        projectName: 'ALL PROJECT',
        towarName: '',
        response: NotificationResponseData(
          projectId: '',
          towarId: '',
          navigationFlag: 'SideMenu',
        ),
      );
    }
    if (!_initialRequestsStarted) {
      _initialRequestsStarted = true;
      fetchPoStatusOfSupply();
      getLeadFilter();
    }
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  List<FilterList>? filterListData = [];
  List<FilterList>? filteredList = [];
  int filterListSelected = 0;
  String searchText = '';
  TextEditingController searchController = TextEditingController();
  String? poRawMaterialFlag = '0';

  bool flagcalled = false;
  bool norecord = false;
  bool flagSortBy = true;
  List<RccBookingHistory>? rccBookingHistory = [];
  String? offset = '0';
  String searchTermValue = '';

  TextEditingController editingController = TextEditingController();
  String? strTowarName = "All Tower";
  List<TowarList>? towarLists = [];
  List<Detail>? filteredProjects() {
    if (searchText.isEmpty) {
      return filterListData![filterListSelected].details;
    }
    return filterListData![filterListSelected].details!.where((project) {
      return project.name!.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
  }

  Future<ResponseGetPoStatusOfSupply?> fetchPoStatusOfSupply() async {
    if (useSupplyTestData) {
      var orders = supplyPreviewOrders(
          args.projectId ?? '', args.projectName ?? 'Sample Project');
      final query = searchTermValue.trim().toLowerCase();
      orders = orders
          .where(
              (o) => '${o.poNo} ${o.venderName}'.toLowerCase().contains(query))
          .toList();
      final selected = filteredList
              ?.expand((f) => f.details ?? <Detail>[])
              .map((d) => d.id)
              .toSet() ??
          <String?>{};
      if (selected.isNotEmpty)
        orders = orders.where((o) => selected.contains(o.venderIdFk)).toList();
      if (!flagSortBy) orders.sort((a, b) => a.poNo!.compareTo(b.poNo!));
      setState(() {
        rccBookingHistory = orders;
        norecord = orders.isEmpty;
        flagcalled = true;
        poRawMaterialFlag = '1';
        offset = '0';
        towarLists = [
          TowarList(towarId: '', towarName: 'All Tower'),
          TowarList(towarId: 'sample-a', towarName: 'Tower A')
        ];
      });
      return null;
    }

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    String? loginType = prefs.getString('loginType');

    String towerId = "";
    if (args.response?.towarId != null) {
      towerId = args.response!.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": args.projectId!,
      "towar_id": towerId,
      "limit": "20",
      "offset": offset!,
      "search_data": searchTermValue,
      "login_type": loginType!,
      "fliterlist": jsonEncode(filteredList),
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(
      AppUrl.webSupplierBookingHistory,
      data,
    );
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getPoStatusOfSupplyFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        poRawMaterialFlag = dataModel.response?.poRawMaterialFlag;

        if (searchTermValue.isEmpty) {
          offset = dataModel.response?.offset;
        } else {
          offset = '0';
          rccBookingHistory = [];
        }

        List<RccBookingHistory>? rccBooking = [];
        rccBooking = dataModel.response?.rccBookingHistory!;
        if (rccBookingHistory!.isEmpty) {
          rccBookingHistory = rccBooking;
        } else {
          for (int i = 0; i < rccBooking!.length; i++) {
            rccBookingHistory?.add(rccBooking[i]);
          }
        }

        if (rccBookingHistory!.isEmpty) {
          norecord = true;
        } else {
          norecord = false;
        }

        setState(() {
          if (args.response?.navigationFlag! == 'Project') {
            towarLists = [];
            var arrTowar = dataModel.response?.towarList;
            if (arrTowar!.isNotEmpty) {
              towarLists?.add(TowarList(towarId: "", towarName: "All Tower"));
              if (towarLists!.isNotEmpty) {
                for (int i = 0; i < arrTowar.length; i++) {
                  if (arrTowar[i].towarId! == args.response?.towarId!) {
                    strTowarName = arrTowar[i].towarName!;
                  }
                  towarLists?.add(arrTowar[i]);
                }
              }
            }
          }
          flagcalled = true;
          rccBookingHistory!.length;
        });
      }

      if (flagSortBy == false) {
        rccBookingHistory?.sort((a, b) {
          var adate = a.poNo!; //before -> var adate = a.expiry;
          var bdate = b.poNo!; //var bdate = b.expiry;
          return adate.compareTo(bdate);
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
    return null;
  }

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 500));

    offset = '0';
    searchTermValue = '';
    rccBookingHistory = [];
    fetchPoStatusOfSupply();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 500));
    fetchPoStatusOfSupply();
    _refreshController.loadComplete();
  }

  Future<ResponseGetAllSalesLead?> getLeadFilter() async {
    if (useSupplyTestData) {
      if (filterListData!.isEmpty) {
        filterListData = [
          FilterList(
              id: 'vendor',
              name: 'Vendor',
              details: supplyPreviewOrders('', '')
                  .map((o) => Detail(
                      id: o.venderIdFk, name: o.venderName, isSelected: false))
                  .toList())
        ];
      }
      return null;
    }

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": args.projectId!,
      "towar_id": args.response?.towarId ?? '',
      "status_supply": flagSortBy == true ? "1" : "0",
      "po_status": "2",
    };
    var response = await apiNetworkHandler.post(AppUrl.wsPoFilter, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = salesLeadFilterFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        //inspect(invensterFilter);
        setState(() {
          filterListData = dataModel.response?.filterList;
        });
      }
    }
    return null;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _showVendorContacts(RccBookingHistory order) async {
    final contacts = order.venderPhone ?? <VenderPhone>[];
    await showSupplyDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        key: const ValueKey('supply-vendor-contacts'),
        clipBehavior: Clip.antiAlias,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.all(12),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        actionsAlignment: MainAxisAlignment.center,
        title: Container(
          width: double.infinity,
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Text(order.venderName ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: supplyFontFamily,
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ),
        content: SizedBox(
          width: 360,
          height: (MediaQuery.sizeOf(dialogContext).height * .32)
              .clamp(150.0, 260.0),
          child: contacts.isEmpty
              ? const Center(
                  child: Text('No contact details available',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: supplyFontFamily,
                          fontSize: 13,
                          color: Colors.black54)))
              : ListView.separated(
                  itemCount: contacts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xfff8f9fa),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xffe9ecef))),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                    color: Color(0xffeef0f2),
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.person_outline_rounded,
                                    size: 18, color: Colors.black54)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(contact.venderName ?? '',
                                      style: const TextStyle(
                                          fontFamily: supplyFontFamily,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87)),
                                  const SizedBox(height: 5),
                                  Text(contact.venderPhoneNumber ?? '',
                                      style: const TextStyle(
                                          fontFamily: supplyFontFamily,
                                          fontSize: 13,
                                          color: Colors.black54)),
                                ])),
                          ]),
                    );
                  },
                ),
        ),
        actions: [
          SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                        fontFamily: supplyFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                child: const Text('Close'),
              ))
        ],
      ),
    );
  }

  Future<void> _showTowerSelection() async {
    await showSupplyDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) => Dialog(
        clipBehavior: Clip.antiAlias,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 360,
          height: (MediaQuery.sizeOf(dialogContext).height * .6)
              .clamp(220.0, 400.0),
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: Colors.black,
              child: const Text('SELECT TOWER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: supplyFontFamily,
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
            Expanded(
                child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: towarLists?.length ?? 0,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final tower = towarLists![index];
                final selected = args.response?.towarId == tower.towarId;
                return Material(
                  color: selected ? const Color(0xfff0f2f4) : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                          color: selected
                              ? const Color(0xffd5d9de)
                              : const Color(0xffe9ecef))),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      offset = '0';
                      searchTermValue = '';
                      rccBookingHistory = [];
                      editingController.clear();
                      args.response?.towarId = tower.towarId;
                      setState(() => strTowarName = tower.towarName);
                      fetchPoStatusOfSupply();
                      Navigator.of(dialogContext).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      child: Row(children: [
                        Expanded(
                            child: Text(tower.towarName ?? '',
                                style: TextStyle(
                                    fontFamily: supplyFontFamily,
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400))),
                        const SizedBox(width: 12),
                        Icon(
                            selected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked,
                            size: 22,
                            color: selected
                                ? Colors.black
                                : const Color(0xff9ca3ab)),
                      ]),
                    ),
                  ),
                );
              },
            )),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                            fontFamily: supplyFontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    child: const Text('OK'),
                  )),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _showSupplyFilters() async {
    await showSupplyDialog<void>(
      context: context,
      builder: (dialogContext) =>
          StatefulBuilder(builder: (context, updateDialog) {
        final groups = filterListData ?? <FilterList>[];
        final selectedGroup = groups.isEmpty
            ? null
            : groups[filterListSelected.clamp(0, groups.length - 1)];
        final options = (selectedGroup?.details ?? <Detail>[])
            .where((item) => (item.name ?? '')
                .toLowerCase()
                .contains(searchText.toLowerCase()))
            .toList();
        return AlertDialog(
          clipBehavior: Clip.antiAlias,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsets.all(12),
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            color: Colors.black,
            child: const Text('FILTER',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: supplyFontFamily,
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ),
          content: SizedBox(
            width: 680,
            height:
                (MediaQuery.sizeOf(context).height * .55).clamp(160.0, 420.0),
            child: LayoutBuilder(
                builder: (context, constraints) => Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width:
                              (constraints.maxWidth * .30).clamp(80.0, 180.0),
                          decoration: const BoxDecoration(
                              color: Color(0xfff4f6f8),
                              border: Border(
                                  right: BorderSide(color: Color(0xffe1e5e9)))),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 6),
                            itemCount: groups.length,
                            itemBuilder: (context, i) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Material(
                                color: i == filterListSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () => updateDialog(() {
                                    filterListSelected = i;
                                    searchText = '';
                                    searchController.clear();
                                  }),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 14),
                                    child: Row(children: [
                                      Expanded(
                                          child: Text(groups[i].name ?? '',
                                              style: TextStyle(
                                                  fontFamily: supplyFontFamily,
                                                  fontSize:
                                                      supplyCompact(context)
                                                          ? 12
                                                          : 14,
                                                  fontWeight:
                                                      i == filterListSelected
                                                          ? FontWeight.w600
                                                          : FontWeight.w400,
                                                  color: i == filterListSelected
                                                      ? Colors.black
                                                      : Colors.black54))),
                                      if (groups[i].ct > 0) ...[
                                        const SizedBox(width: 4),
                                        Container(
                                            width: 5,
                                            height: 5,
                                            decoration: const BoxDecoration(
                                                color: Colors.black,
                                                shape: BoxShape.circle)),
                                      ],
                                    ]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                            child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                                height: 36,
                                child: TextFormField(
                                  controller: searchController,
                                  onChanged: (value) =>
                                      updateDialog(() => searchText = value),
                                  style: const TextStyle(
                                      fontFamily: supplyFontFamily,
                                      fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: 'Search',
                                    isDense: true,
                                    hintStyle: const TextStyle(
                                        fontFamily: supplyFontFamily,
                                        fontSize: 13,
                                        color: Color(0xff9ca3ab)),
                                    prefixIcon: const Icon(Icons.search,
                                        size: 18, color: Color(0xff9ca3ab)),
                                    prefixIconConstraints: const BoxConstraints(
                                        minWidth: 32, minHeight: 34),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    filled: true,
                                    fillColor: const Color(0xfff8f9fa),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xffe1e5e9))),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xffb8bec5))),
                                  ),
                                )),
                          ),
                          const Divider(height: 1, color: Color(0xffe9ecef)),
                          Expanded(
                              child: options.isEmpty
                                  ? const Center(
                                      child: Text('No options found',
                                          style: TextStyle(
                                              fontFamily: supplyFontFamily,
                                              fontSize: 13,
                                              color: Colors.black54)))
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 6),
                                      itemCount: options.length,
                                      itemBuilder: (context, k) {
                                        final item = options[k];
                                        final selected =
                                            item.isSelected == true;
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Material(
                                            color: selected
                                                ? const Color(0xfff0f2f4)
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              onTap: () => updateDialog(() {
                                                item.isSelected = !selected;
                                                selectedGroup!.ct +=
                                                    selected ? -1 : 1;
                                              }),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 12),
                                                child: Row(children: [
                                                  Icon(
                                                      selected
                                                          ? Icons
                                                              .check_box_rounded
                                                          : Icons
                                                              .check_box_outline_blank_rounded,
                                                      size: 21,
                                                      color: selected
                                                          ? Colors.black
                                                          : const Color(
                                                              0xff9ca3ab)),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                      child: Text(
                                                          item.name ?? '',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  supplyFontFamily,
                                                              fontSize: 13,
                                                              fontWeight: selected
                                                                  ? FontWeight
                                                                      .w500
                                                                  : FontWeight
                                                                      .w400,
                                                              color: Colors
                                                                  .black87))),
                                                ]),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )),
                        ])),
                      ],
                    )),
          ),
          actions: [
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: const TextStyle(
                        fontFamily: supplyFontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                onPressed: () {
                  for (final group in groups) {
                    group.ct = 0;
                    for (final item in group.details ?? <Detail>[]) {
                      item.isSelected = false;
                    }
                  }
                  searchController.clear();
                  setState(() {
                    searchText = '';
                    flagcalled = false;
                    offset = '0';
                    filteredList = [];
                    searchTermValue = '';
                    rccBookingHistory = [];
                  });
                  Navigator.of(dialogContext).pop();
                  fetchPoStatusOfSupply();
                },
                child: const Text('RESET'),
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: const TextStyle(
                        fontFamily: supplyFontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                onPressed: () {
                  setState(() {
                    flagcalled = false;
                    filteredList = groups
                        .map((group) => FilterList(
                            name: group.name,
                            id: group.id,
                            details: group.details
                                    ?.where((item) => item.isSelected == true)
                                    .toList() ??
                                []))
                        .toList();
                    offset = '0';
                    searchTermValue = '';
                    rccBookingHistory = [];
                  });
                  Navigator.of(dialogContext).pop();
                  fetchPoStatusOfSupply();
                },
                child: const FittedBox(
                    fit: BoxFit.scaleDown, child: Text('APPLY FILTER')),
              )),
            ])
          ],
        );
      }),
    );
  }

  String? _expandedSupplyCard;
  String _supplyCardId(RccBookingHistory order) =>
      '${args.projectId}/${order.orderId ?? order.poNo}';

  Widget _supplyToggle(RccBookingHistory order) {
    final id = _supplyCardId(order);
    final expanded = _expandedSupplyCard == id;
    return SizedBox(
        width: 24,
        height: 32,
        child: IconButton(
          key: ValueKey('supply-card-toggle-${order.orderId ?? order.poNo}'),
          tooltip: expanded
              ? 'Minimise PO ${order.poNo}'
              : 'Expand PO ${order.poNo}',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 24, height: 32),
          onPressed: () =>
              setState(() => _expandedSupplyCard = expanded ? null : id),
          icon: Icon(
              expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 22,
              color: Colors.black54),
        ));
  }

  Widget _supplyGrnButton(RccBookingHistory order) => InkWell(
        onTap: () {
          var projectId = args.projectId!;
          var projectName = args.projectName!;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return GrnListingView(
                  projectId: projectId,
                  towarId: args.response?.towarId ?? '',
                  projectName: projectName,
                  orderId: order.orderId!,
                );
              },
            ),
          );
        },
        child: Container(
          height: 35,
          width: 100,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(
              10,
            ),
            color: Colors.white,
            shape: BoxShape.rectangle,
          ),
          child: const Center(
            child: Text(
              'VIEW GRN',
              style: TextStyle(
                fontFamily: supplyFontFamily,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

  Widget _supplyCard(RccBookingHistory order, {required InkWell child}) {
    return SupplyCard(
        child: AnimatedSize(
      key: ValueKey('supply-card-transition-${_supplyCardId(order)}'),
      alignment: Alignment.topCenter,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: SizedBox(width: double.infinity, child: child),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SupplySurface(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: Text(
            args.towarName == ""
                ? '${args.projectName!.toUpperCase()} - ${args.towarName!.toUpperCase()}'
                : args.projectName!.toUpperCase(),
            style: const TextStyle(
                fontFamily: supplyFontFamily,
                fontStyle: FontStyle.normal,
                fontSize: 17.0),
          ),
          leading: args.response?.navigationFlag == 'SideMenu'
              ? const SizedBox()
              : IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                ),
          actions: [
            SizedBox(width: supplyCompact(context) ? 4 : 80),
            if (poRawMaterialFlag == '1')
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return InventoryManagement(
                          projectId: args.projectId,
                          towarId: args.response?.towarId ?? '',
                          projectName: args.projectName,
                          towarName: args.towarName,
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: supplyCompact(context) ? 6 : 50,
                    vertical: 12,
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: supplyCompact(context) ? 8 : 18),
                  decoration: BoxDecoration(
                    color: const Color(0x18ffffff),
                    border: Border.all(color: const Color(0xb3ffffff)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Text(
                      "Inventory",
                      style: TextStyle(
                        fontFamily: supplyFontFamily,
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            // InkWell(
            // onTap: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (_) {
            //         return InventoryManagement(
            //           projectId: widget.projectId,
            //           towarId: widget.towarId!,
            //           projectName: widget.projectName,
            //           towarName: widget.towarName,
            //         );
            //       },
            //     ),
            //   );
            // },
            //   child: Image.asset(
            //     'images/projectmanagement/inventory-management.png',
            //     height: 40,
            //   ),
            // ),
            const SizedBox(width: 14),
          ],
        ),
        body: Container(
          height: double.infinity,
          color: supplyBackground,
          child: SafeArea(
            child: flagcalled == true
                ? Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        height: 40,
                        child: Row(
                          children: [
                            const Spacer(),
                            const Text(
                              'STATUS OF SUPPLY',
                              style: TextStyle(
                                fontFamily: supplyFontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(),
                            InkWell(
                              key: const ValueKey('supply-filter'),
                              onTap: () {
                                searchController.clear();
                                setState(() {
                                  searchText = "";
                                });

                                _showSupplyFilters();
                              },
                              child: Container(
                                child: filteredList?.length != 0
                                    ? Container(
                                        color: Colors.grey,
                                        padding: const EdgeInsets.all(4),
                                        child: Image.asset(
                                          'images/projectmanagement/filter-sort-icon.png',
                                          height: 20,
                                        ),
                                      )
                                    : Image.asset(
                                        color: Colors.black,
                                        'images/projectmanagement/filter_black.png',
                                        height: 20,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1.0, color: Colors.black),
                      args.response?.navigationFlag != 'SideMenu'
                          ? towarLists!.isNotEmpty
                              ? InkWell(
                                  key: const ValueKey('supply-tower-selector'),
                                  onTap: () {
                                    _showTowerSelection();
                                  },
                                  child: SizedBox(
                                    height: 40,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          strTowarName!.toUpperCase(),
                                          style: const TextStyle(
                                            fontFamily: supplyFontFamily,
                                            fontStyle: FontStyle.normal,
                                            fontSize: 15.0,
                                          ),
                                        ),
                                        horizontalSpaceSmall,
                                        IconButton(
                                          icon: const Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.black,
                                          ),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox()
                          : const SizedBox(),
                      const Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 1,
                        endIndent: 1,
                        color: Colors.black,
                      ),
                      const Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Colors.white,
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xffeef0f2),
                          border: Border.all(color: const Color(0xffe1e5e9)),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (flagSortBy == false) {
                                      flagSortBy = true;
                                      DateFormat format = DateFormat(
                                        "dd-MM-yyyy",
                                      );
                                      rccBookingHistory?.sort((a, b) {
                                        var adate = format.parse(
                                          a.castingDate!,
                                        ); //before -> var adate = a.expiry;
                                        var bdate = format.parse(
                                          b.castingDate!,
                                        ); //var bdate = b.expiry;
                                        return bdate.compareTo(adate);
                                      });
                                    }
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: flagSortBy == true
                                        ? Colors.black
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'Sort By Recent',
                                    style: flagSortBy == true
                                        ? const TextStyle(
                                            fontFamily: supplyFontFamily,
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          )
                                        : const TextStyle(
                                            fontFamily: supplyFontFamily,
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (flagSortBy == true) {
                                      flagSortBy = false;
                                      getLeadFilter();
                                      rccBookingHistory?.sort((a, b) {
                                        var adate = a
                                            .poNo!; //before -> var adate = a.expiry;
                                        var bdate =
                                            b.poNo!; //var bdate = b.expiry;
                                        return adate.compareTo(bdate);
                                      });
                                    }
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: flagSortBy == false
                                        ? Colors.black
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'Sort By P.O. No.',
                                    style: flagSortBy == false
                                        ? const TextStyle(
                                            fontFamily: supplyFontFamily,
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          )
                                        : const TextStyle(
                                            fontFamily: supplyFontFamily,
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: EdgeInsets.only(
                          left: supplyCompact(context) ? 12 : 60,
                          right: supplyCompact(context) ? 12 : 60,
                        ),
                        child: SizedBox(
                          height: 34,
                          child: TextField(
                            onChanged: (value) {
                              Future.delayed(const Duration(seconds: 1), () {
                                if (value.isNotEmpty) {
                                  if (value.length > 2) {
                                    rccBookingHistory = [];
                                    offset = '0';
                                    searchTermValue = value;
                                    searchTermValue =
                                        searchTermValue.replaceAll("  ", " ");
                                    searchTermValue = searchTermValue.trim();
                                    fetchPoStatusOfSupply();
                                  }
                                } else {
                                  offset = '0';
                                  searchTermValue = '';
                                  rccBookingHistory = [];
                                  editingController.clear();
                                  fetchPoStatusOfSupply();
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(FocusNode());
                                }
                              });
                            },
                            style: const TextStyle(
                                fontFamily: supplyFontFamily, fontSize: 11),
                            controller: editingController,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              labelText: "Search by PO.No or Vendor Name",
                              hintText: "Search by PO.No or Vendor Name",
                              labelStyle: TextStyle(
                                  fontFamily: supplyFontFamily,
                                  fontSize: 11,
                                  color: Color(0xffa0a5ab)),
                              hintStyle: TextStyle(
                                  fontFamily: supplyFontFamily,
                                  fontSize: 11,
                                  color: Color(0xffa0a5ab)),
                              floatingLabelStyle: TextStyle(
                                  fontFamily: supplyFontFamily,
                                  fontSize: 11,
                                  color: Color(0xffa0a5ab)),
                              prefixIcon: Icon(Icons.search,
                                  size: 17, color: Color(0xffa0a5ab)),
                              prefixIconConstraints:
                                  BoxConstraints(minWidth: 34, minHeight: 32),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                  borderSide:
                                      BorderSide(color: Color(0xffe1e5e9))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                  borderSide:
                                      BorderSide(color: Color(0xffe1e5e9))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                  borderSide:
                                      BorderSide(color: Color(0xffb8bec5))),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      norecord == true
                          ? const Expanded(
                              child: Center(
                                child: Text(
                                  'No Record Found',
                                  style: normalText,
                                ),
                              ),
                            )
                          : Expanded(
                              child: SmartRefresher(
                                enablePullDown:
                                    searchTermValue.isEmpty ? true : false,
                                enablePullUp:
                                    searchTermValue.isEmpty ? true : false,
                                controller: _refreshController,
                                onRefresh:
                                    searchTermValue.isEmpty ? _onRefresh : null,
                                onLoading:
                                    searchTermValue.isEmpty ? _onLoading : null,
                                footer: const ClassicFooter(
                                  loadStyle: LoadStyle.ShowWhenLoading,
                                ),
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: ListView.builder(
                                  itemCount: rccBookingHistory?.length,
                                  itemBuilder: (context, index) {
                                    // List<OrderDetail>? orderDetails =
                                    //     rccBookingHistory?[index].orderDetails;
                                    if (index >=
                                        (rccBookingHistory?.length ?? 0)) {
                                      return const SizedBox();
                                    }

                                    List<OrderDetail>? orderDetails =
                                        rccBookingHistory?[index].orderDetails;
                                    if (orderDetails == null ||
                                        orderDetails.isEmpty) {
                                      return const SizedBox();
                                    }

                                    double actualQty = 0.0;
                                    double deliveredQty = 0.0;
                                    String units = "";
                                    String deliver = "";
                                    String grades = "";
                                    for (int i = 0;
                                        i < orderDetails!.length;
                                        i++) {
                                      actualQty = double.parse(
                                        orderDetails[i].orderQuantity!,
                                      );
                                      deliveredQty = double.parse(
                                        orderDetails[i].deliveryQuantity!,
                                      );
                                      if (i == 0) {
                                        units =
                                            '${actualQty.toStringAsFixed(3)} ${orderDetails[i].castingUnitName!}';
                                        deliver =
                                            '${deliveredQty.toStringAsFixed(3)} ${orderDetails[i].castingUnitName!}';
                                        grades = orderDetails[i].gradeTypeName!;
                                      } else {
                                        units =
                                            '$units, ${actualQty.toStringAsFixed(3)} ${orderDetails[i].castingUnitName!}';
                                        deliver =
                                            '$deliver, ${deliveredQty.toStringAsFixed(3)} ${orderDetails[i].castingUnitName!}';
                                        grades =
                                            '$grades, ${orderDetails[i].gradeTypeName!}';
                                      }
                                    }
                                    return _supplyCard(
                                      rccBookingHistory![index],
                                      child: InkWell(
                                        onTap: () {
                                          var projectId = args.projectId!;
                                          var projectName = args.projectName!;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) {
                                                return SuppliesPoDetails(
                                                  projectId: projectId,
                                                  towarId:
                                                      args.response?.towarId ??
                                                          '',
                                                  projectName: projectName,
                                                  orderDetails:
                                                      rccBookingHistory![index],
                                                );
                                              },
                                            ),
                                          ).then((_) {
                                            // This block runs when you have returned back to the 1st Page from 2nd.
                                            setState(() {
                                              // Call setState to refresh the page.
                                              flagcalled = false;
                                              offset = '0';
                                              searchTermValue = '';
                                              rccBookingHistory = [];
                                              editingController.clear();
                                              fetchPoStatusOfSupply();
                                            });
                                          });
                                        },
                                        child: ListTile(
                                          contentPadding: supplyCompact(context)
                                              ? const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 8)
                                              : null,
                                          horizontalTitleGap:
                                              supplyCompact(context) ? 4 : null,
                                          titleAlignment:
                                              ListTileTitleAlignment.top,
                                          trailing: _supplyToggle(
                                              rccBookingHistory![index]),
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: supplyCompact(context)
                                                      ? 0
                                                      : 50,
                                                  top: 10,
                                                ),
                                                child: Column(
                                                  key: _expandedSupplyCard ==
                                                          _supplyCardId(
                                                              rccBookingHistory![
                                                                  index])
                                                      ? null
                                                      : ValueKey(
                                                          'supply-minimised-${rccBookingHistory![index].orderId ?? rccBookingHistory![index].poNo}'),
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        bottom: 6.0,
                                                      ),
                                                      child: SupplyDetailRow(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                              'P.O. No.',
                                                              style:
                                                                  supplyCardLabel,
                                                            ),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                            child: Icon(
                                                              Icons.remove,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                          ),
                                                          horizontalSpaceLarge,
                                                          FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text.rich(
                                                              TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                        text: rccBookingHistory![index]
                                                                            .poNo!
                                                                            .trim()),
                                                                    if (rccBookingHistory![index]
                                                                            .isStarMarked ==
                                                                        '1')
                                                                      const WidgetSpan(
                                                                        alignment:
                                                                            PlaceholderAlignment.middle,
                                                                        child: Icon(
                                                                            Icons
                                                                                .star_rounded,
                                                                            color:
                                                                                Colors.red,
                                                                            size: 14),
                                                                      ),
                                                                  ]),
                                                              key: ValueKey(
                                                                  'supply-po-number-${rccBookingHistory![index].orderId ?? rccBookingHistory![index].poNo}'),
                                                              maxLines: 1,
                                                              softWrap: false,
                                                              style: supplyCardEmphasis.copyWith(
                                                                  fontSize:
                                                                      supplyCompact(
                                                                              context)
                                                                          ? 13
                                                                          : 16),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (_expandedSupplyCard ==
                                                        _supplyCardId(
                                                            rccBookingHistory![
                                                                index]))
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          bottom: 6.0,
                                                        ),
                                                        child: SupplyDetailRow(
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                'P.O. Created Date',
                                                                style:
                                                                    supplyCardLabel,
                                                              ),
                                                            ),
                                                            horizontalSpaceMedium,
                                                            const Center(
                                                              child: Icon(
                                                                Icons.remove,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                            ),
                                                            horizontalSpaceLarge,
                                                            Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .poCreatedAt!,
                                                              style:
                                                                  supplyCardValue,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        bottom: 6.0,
                                                      ),
                                                      child: SupplyDetailRow(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          SupplyDetailRow(
                                                            children: [
                                                              const SizedBox(
                                                                width: 200,
                                                                child: Text(
                                                                  'P.O. Status',
                                                                  style:
                                                                      supplyCardLabel,
                                                                ),
                                                              ),
                                                              horizontalSpaceMedium,
                                                              const Center(
                                                                child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                              ),
                                                              horizontalSpaceLarge,
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: rccBookingHistory![index]
                                                                              .poStatus! ==
                                                                          '0'
                                                                      ? const Color
                                                                          .fromRGBO(
                                                                          255,
                                                                          214,
                                                                          51,
                                                                          1.0,
                                                                        )
                                                                      : rccBookingHistory![index].poStatus! ==
                                                                              '1'
                                                                          ? const Color
                                                                              .fromRGBO(
                                                                              255,
                                                                              214,
                                                                              51,
                                                                              1.0,
                                                                            )
                                                                          : rccBookingHistory![index].poStatus! == '2'
                                                                              ? const Color.fromRGBO(
                                                                                  0,
                                                                                  128,
                                                                                  43,
                                                                                  1.0,
                                                                                ) //green
                                                                              : const Color.fromRGBO(
                                                                                  255,
                                                                                  214,
                                                                                  51,
                                                                                  1.0,
                                                                                ), // yellow
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    999,
                                                                  ),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                    left: 15.0,
                                                                    right: 15.0,
                                                                    top: 5.0,
                                                                    bottom: 5.0,
                                                                  ),
                                                                  child:
                                                                      SingleChildScrollView(
                                                                          scrollDirection: Axis
                                                                              .horizontal,
                                                                          child:
                                                                              Text(
                                                                            rccBookingHistory![index].poStatus! == '0'
                                                                                ? 'Pending'
                                                                                : rccBookingHistory![index].poStatus! == '1'
                                                                                    ? 'Assigned'
                                                                                    : rccBookingHistory![index].poStatus! == '2'
                                                                                        ? 'Issued'
                                                                                        : rccBookingHistory![index].poStatus! == '3'
                                                                                            ? 'Dispute'
                                                                                            : '---',
                                                                            maxLines:
                                                                                1,
                                                                            softWrap:
                                                                                false,
                                                                            style:
                                                                                supplyCardValue.copyWith(
                                                                              fontSize: supplyCompact(context) ? 13 : 16,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: rccBookingHistory![index].poStatus == '0' || rccBookingHistory![index].poStatus == '1' ? Colors.black : Colors.white,
                                                                            ),
                                                                          )),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          rccBookingHistory![
                                                                          index]
                                                                      .grn_active ==
                                                                  '1'
                                                              ? _supplyGrnButton(
                                                                  rccBookingHistory![
                                                                      index])
                                                              : const SizedBox(),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        bottom: 6.0,
                                                      ),
                                                      child: SupplyDetailRow(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                              'Booking Type',
                                                              style:
                                                                  supplyCardLabel,
                                                            ),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                            child: Icon(
                                                              Icons.remove,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                          ),
                                                          horizontalSpaceLarge,
                                                          Text(
                                                            rccBookingHistory![
                                                                    index]
                                                                .gradeName!,
                                                            style:
                                                                supplyCardValue,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        bottom: 6.0,
                                                      ),
                                                      child: SupplyDetailRow(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                              'Status Delivery',
                                                              style:
                                                                  supplyCardLabel,
                                                            ),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                            child: Icon(
                                                              Icons.remove,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                          ),
                                                          horizontalSpaceLarge,
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: rccBookingHistory![
                                                                              index]
                                                                          .orderStatus! ==
                                                                      '0'
                                                                  ? const Color
                                                                      .fromRGBO(
                                                                      255,
                                                                      214,
                                                                      51,
                                                                      1.0,
                                                                    ) // yellow
                                                                  : rccBookingHistory![index].orderStatus! ==
                                                                              '1' ||
                                                                          rccBookingHistory![index].orderStatus! ==
                                                                              '4'
                                                                      ? const Color
                                                                          .fromRGBO(
                                                                          255,
                                                                          214,
                                                                          51,
                                                                          1.0,
                                                                        ) //yellow
                                                                      : rccBookingHistory![index].orderStatus! ==
                                                                              '2'
                                                                          ? const Color
                                                                              .fromRGBO(
                                                                              0,
                                                                              128,
                                                                              43,
                                                                              1.0,
                                                                            ) //green
                                                                          : const Color
                                                                              .fromRGBO(
                                                                              255,
                                                                              51,
                                                                              0,
                                                                              1.0,
                                                                            ), //yellow
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                999,
                                                              ),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                8.0,
                                                              ),
                                                              child:
                                                                  SingleChildScrollView(
                                                                      scrollDirection:
                                                                          Axis
                                                                              .horizontal,
                                                                      child:
                                                                          Text(
                                                                        rccBookingHistory![index].orderStatus! ==
                                                                                '0'
                                                                            ? 'Order Pending'
                                                                            : rccBookingHistory![index].orderStatus! == '1'
                                                                                ? 'Order Processed'
                                                                                : rccBookingHistory![index].orderStatus! == '2'
                                                                                    ? 'Order Delivered'
                                                                                    : rccBookingHistory![index].orderStatus! == '4'
                                                                                        ? 'Partially Delivered'
                                                                                        : 'Order Cancelled',
                                                                        maxLines:
                                                                            1,
                                                                        softWrap:
                                                                            false,
                                                                        style: supplyCardValue
                                                                            .copyWith(
                                                                          fontSize: supplyCompact(context)
                                                                              ? 13
                                                                              : 16,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color: rccBookingHistory![index].orderStatus == '0' || rccBookingHistory![index].orderStatus == '1' || rccBookingHistory![index].orderStatus == '4'
                                                                              ? Colors.black
                                                                              : Colors.white,
                                                                        ),
                                                                      )),
                                                            ),
                                                          ),
                                                          if (rccBookingHistory![
                                                                      index]
                                                                  .orderStatus ==
                                                              '2') ...[
                                                            horizontalSpaceSmall,
                                                            Text(
                                                              rccBookingHistory![
                                                                              index]
                                                                          .orderStatus! ==
                                                                      '2'
                                                                  ? '( ${rccBookingHistory![index].orderDeliverDate!} )'
                                                                  : '',
                                                              style:
                                                                  supplyCardValue,
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ),
                                                    if (_expandedSupplyCard ==
                                                        _supplyCardId(
                                                            rccBookingHistory![
                                                                index]))
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          bottom: 6.0,
                                                        ),
                                                        child: SupplyDetailRow(
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                'Vendor Name',
                                                                style:
                                                                    supplyCardLabel,
                                                              ),
                                                            ),
                                                            horizontalSpaceMedium,
                                                            const Center(
                                                              child: Icon(
                                                                Icons.remove,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                            ),
                                                            horizontalSpaceLarge,
                                                            SupplyVendorValue(
                                                                name: rccBookingHistory![
                                                                            index]
                                                                        .venderName ??
                                                                    '',
                                                                action: InkWell(
                                                                  onTap: () {
                                                                    _showVendorContacts(
                                                                        rccBookingHistory![
                                                                            index]);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                      3,
                                                                    ),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .circular(
                                                                        100,
                                                                      ),
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .black54,
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .local_phone_outlined,
                                                                      size: 17,
                                                                    ),
                                                                  ),
                                                                )),
                                                          ],
                                                        ),
                                                      ),
                                                    if (_expandedSupplyCard ==
                                                        _supplyCardId(
                                                            rccBookingHistory![
                                                                index]))
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          bottom: 10.0,
                                                        ),
                                                        child: SupplyDetailRow(
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                'Project Name',
                                                                style:
                                                                    supplyCardLabel,
                                                              ),
                                                            ),
                                                            horizontalSpaceMedium,
                                                            const Center(
                                                              child: Icon(
                                                                Icons.remove,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                            ),
                                                            horizontalSpaceLarge,
                                                            Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .projectName!,
                                                              style:
                                                                  supplyCardValue,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    if (_expandedSupplyCard ==
                                                        _supplyCardId(
                                                            rccBookingHistory![
                                                                index]))
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          bottom: 10.0,
                                                        ),
                                                        child: SupplyDetailRow(
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                'Slab No',
                                                                style:
                                                                    supplyCardLabel,
                                                              ),
                                                            ),
                                                            horizontalSpaceMedium,
                                                            const Center(
                                                              child: Icon(
                                                                Icons.remove,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                            ),
                                                            horizontalSpaceLarge,
                                                            Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .slabName!,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style:
                                                                  supplyCardValue,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    if (_expandedSupplyCard ==
                                                        _supplyCardId(
                                                            rccBookingHistory![
                                                                index]))
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          bottom: 10.0,
                                                        ),
                                                        child: SupplyDetailRow(
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                'Requirement Date',
                                                                style:
                                                                    supplyCardLabel,
                                                              ),
                                                            ),
                                                            horizontalSpaceMedium,
                                                            const Center(
                                                              child: Icon(
                                                                Icons.remove,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                            ),
                                                            horizontalSpaceLarge,
                                                            Text(
                                                              DateFormat(
                                                                'dd MMM yyyy',
                                                              ).format(
                                                                DateFormat(
                                                                  'dd-MM-yyyy',
                                                                ).parse(
                                                                  rccBookingHistory![
                                                                          index]
                                                                      .castingDate!
                                                                      .toString(),
                                                                ),
                                                              ),
                                                              style:
                                                                  supplyCardValue,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    if (_expandedSupplyCard ==
                                                        _supplyCardId(
                                                            rccBookingHistory![
                                                                index]))
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          bottom: 10.0,
                                                        ),
                                                        child: SupplyDetailRow(
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                'Requested By',
                                                                style:
                                                                    supplyCardLabel,
                                                              ),
                                                            ),
                                                            horizontalSpaceMedium,
                                                            const Center(
                                                              child: Icon(
                                                                Icons.remove,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                            ),
                                                            horizontalSpaceLarge,
                                                            Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .raisedBy!,
                                                              style:
                                                                  supplyCardValue,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    if (_expandedSupplyCard ==
                                                        _supplyCardId(
                                                            rccBookingHistory![
                                                                index]))
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          bottom: 10.0,
                                                        ),
                                                        child: SupplyDetailRow(
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                'Verified By',
                                                                style:
                                                                    supplyCardLabel,
                                                              ),
                                                            ),
                                                            horizontalSpaceMedium,
                                                            const Center(
                                                              child: Icon(
                                                                Icons.remove,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                            ),
                                                            horizontalSpaceLarge,
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: rccBookingHistory![index]
                                                                            .poApproveBy! !=
                                                                        ''
                                                                    ? const Color
                                                                        .fromRGBO(
                                                                        0,
                                                                        122,
                                                                        204,
                                                                        1.0,
                                                                      ) //blue
                                                                    : rccBookingHistory![index].poApproveBy! !=
                                                                            '---'
                                                                        ? const Color
                                                                            .fromRGBO(
                                                                            0,
                                                                            122,
                                                                            204,
                                                                            1.0,
                                                                          ) //blue
                                                                        : null,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                  999,
                                                                ),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                  left: 15.0,
                                                                  right: 15.0,
                                                                  top: 5.0,
                                                                  bottom: 5.0,
                                                                ),
                                                                child: Text(
                                                                  rccBookingHistory![
                                                                          index]
                                                                      .poApproveBy!,
                                                                  style: rccBookingHistory![index]
                                                                              .poApproveBy! !=
                                                                          ''
                                                                      ? const TextStyle(
                                                                          fontFamily:
                                                                              supplyFontFamily,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontSize:
                                                                              14.0,
                                                                          color:
                                                                              Colors.white,
                                                                        )
                                                                      : rccBookingHistory![index].poApproveBy! !=
                                                                              '---'
                                                                          ? const TextStyle(
                                                                              fontFamily: supplyFontFamily,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 14.0,
                                                                              color: Colors.white,
                                                                            )
                                                                          : supplyCardValue,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    if (rccBookingHistory![
                                                                index]
                                                            .poCheckedBy !=
                                                        "")
                                                      if (_expandedSupplyCard ==
                                                          _supplyCardId(
                                                              rccBookingHistory![
                                                                  index]))
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            bottom: 10.0,
                                                          ),
                                                          child:
                                                              SupplyDetailRow(
                                                            children: [
                                                              const SizedBox(
                                                                width: 200,
                                                                child: Text(
                                                                  'Checked By',
                                                                  style:
                                                                      supplyCardLabel,
                                                                ),
                                                              ),
                                                              horizontalSpaceMedium,
                                                              const Center(
                                                                child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                              ),
                                                              horizontalSpaceLarge,
                                                              Text(
                                                                rccBookingHistory![
                                                                            index]
                                                                        .poCheckedBy ??
                                                                    '',
                                                                style:
                                                                    const TextStyle(
                                                                  fontFamily:
                                                                      supplyFontFamily,
                                                                  fontSize:
                                                                      16.0,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              if (rccBookingHistory![
                                                                          index]
                                                                      .poCheckedByDate !=
                                                                  '')
                                                                Text(
                                                                  '  (${rccBookingHistory![index].poCheckedByDate})',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontFamily:
                                                                        supplyFontFamily,
                                                                    fontSize:
                                                                        16,
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                    if (_expandedSupplyCard ==
                                                        _supplyCardId(
                                                            rccBookingHistory![
                                                                index]))
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          bottom: 10.0,
                                                        ),
                                                        child: SupplyDetailRow(
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                'Received By',
                                                                style:
                                                                    supplyCardLabel,
                                                              ),
                                                            ),
                                                            horizontalSpaceMedium,
                                                            const Center(
                                                              child: Icon(
                                                                Icons.remove,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                            ),
                                                            horizontalSpaceLarge,
                                                            Text(
                                                              rccBookingHistory![
                                                                      index]
                                                                  .checkedBy!,
                                                              style:
                                                                  supplyCardValue,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        bottom: 10.0,
                                                      ),
                                                      child: SupplyDetailRow(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                              'PO Quantity',
                                                              style:
                                                                  supplyCardLabel,
                                                            ),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                            child: Icon(
                                                              Icons.remove,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                          ),
                                                          horizontalSpaceLarge,
                                                          Flexible(
                                                            child: Text(
                                                              units,
                                                              style:
                                                                  supplyCardValue,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        bottom: 10.0,
                                                      ),
                                                      child: SupplyDetailRow(
                                                        children: [
                                                          const SizedBox(
                                                            width: 200,
                                                            child: Text(
                                                              'Delivered Quantity',
                                                              style:
                                                                  supplyCardLabel,
                                                            ),
                                                          ),
                                                          horizontalSpaceMedium,
                                                          const Center(
                                                            child: Icon(
                                                              Icons.remove,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                          ),
                                                          horizontalSpaceLarge,
                                                          Flexible(
                                                            child: Text(
                                                              deliver,
                                                              style: supplyCardValue.copyWith(
                                                                  color: Colors
                                                                      .blue,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  decorationColor:
                                                                      Colors
                                                                          .blue),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (_expandedSupplyCard ==
                                                        _supplyCardId(
                                                            rccBookingHistory![
                                                                index]))
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          bottom: 10.0,
                                                        ),
                                                        child: SupplyDetailRow(
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                'Grades',
                                                                style:
                                                                    supplyCardLabel,
                                                              ),
                                                            ),
                                                            horizontalSpaceMedium,
                                                            const Center(
                                                              child: Icon(
                                                                Icons.remove,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                            ),
                                                            horizontalSpaceLarge,
                                                            Flexible(
                                                              child: Text(
                                                                grades,
                                                                style:
                                                                    supplyCardValue,
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
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                    ],
                  )
                : Center(
                    child: SizedBox(
                      height: 64,
                      child: OverflowBox(
                        minHeight: 100,
                        maxHeight: 100,
                        child: Lottie.asset(
                          'assets/animation/running2.json',
                          repeat: true,
                        ),
                      ),
                    ),
                  ),
            // const Center(child: CircularProgressIndicator())
          ),
        ),
      ),
    );
  }
}
