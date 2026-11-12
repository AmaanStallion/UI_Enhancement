import 'package:stallion/ui/views/accountmanagement/account_management_loading.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_style.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_layout.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_document.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/get_grn_list.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../shared/ui_helpers.dart';
import '../rccstructure/pdfviewer.dart';

class GrnListingView extends StatefulWidget {
  GrnListingView(
      {Key? key, this.projectId, this.towarId, this.projectName, this.orderId})
      : super(key: key);

  final String? projectId;
  String? towarId;
  String? orderId;
  final String? projectName;

  @override
  State<GrnListingView> createState() => _GrnListingViewState();
}

class _GrnListingViewState extends State<GrnListingView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = AccountManagementPreviewNetwork();

  bool flagcalled = false;
  String _searchQuery = '';

  String? paymentStatus;
  String? paymentVenderId;

  List<GrnDetail>? grnDetails;

  Future<ResponseGetGrnList?> fetchGRNList() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": towerId,
      "order_id": widget.orderId!,
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(AppUrl.wsgetgrnlist, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getGrnListFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        //return dataModel.response;
        setState(() {
          flagcalled = true;
          grnDetails = dataModel.response?.grnDetails!;
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

  @override
  void initState() {
    super.initState();
    fetchGRNList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleGrns = (grnDetails ?? <GrnDetail>[]).where((item) => [
      item.grnSrNo, item.bookingType, item.challan_no,
      item.gradeName, item.grnCreatedDate,
    ].any((value) => (value?.toString() ?? '').toLowerCase().contains(_searchQuery))).toList();
    return AccountManagementSurface(
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              title: Text(
                  '${widget.projectName!.toUpperCase()} - GOODS RECEIVED NOTE',
                  style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontSize: context.accountFont(17.0, mobile: 14))),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.maybePop(context);
                },
              ),
            ),
            body: Container(
              height: double.infinity,
              color: Colors.white,
              child: SafeArea(
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        key: const ValueKey('grn-search'),
                        onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
                        decoration: InputDecoration(
                          hintText: 'Search GRN, booking type, challan or grade',
                          prefixIcon: const Icon(Icons.search, color: Colors.black54),
                          filled: true, fillColor: Colors.white, isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xffd0d4d8))),
                        ),
                      ),
                    ),
                    Expanded(child: flagcalled == true
                      ? visibleGrns.isEmpty
                        ? const Center(child: Text('No matching GRNs'))
                        : ListView.builder(
                          itemCount: visibleGrns.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return (useAccountManagementTestData
                                          ? const AccountManagementPreviewDocumentScreen()
                                          : PdfViewer(
                                              fileName: visibleGrns[index]
                                                  .grnFileName!
                                                  .toString(),
                                              fileUrl:
                                                  '${AppUrl.globalGrnPath}${visibleGrns[index].grnFileName!.toString()}',
                                            ));
                                    },
                                  ),
                                );
                              },
                              child: AccountCard(
                                  child: ListTile(
                                titleAlignment: ListTileTitleAlignment.center,
                                trailing: const Icon(Icons.keyboard_arrow_right),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(
                                            left: (context.accountCompact
                                                ? 12.0
                                                : 50),
                                            top: 10),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10.0),
                                              child: AccountDetailRow(
                                                valueStart: 4,
                                                children: [
                                                  SizedBox(
                                                    width: 200,
                                                    child: Text('GRN. No.',
                                                        style: TextStyle(
                                                            backgroundColor:
                                                                Colors.white,
                                                            fontSize: context
                                                                .accountFont(15,
                                                                    mobile: 14),
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                  horizontalSpaceMedium,
                                                  const Center(
                                                      child: Icon(Icons.remove,
                                                          color:
                                                              Colors.black54)),
                                                  horizontalSpaceLarge,
                                                  Text(
                                                      visibleGrns[index]
                                                          .grnSrNo!,
                                                      style: TextStyle(
                                                          backgroundColor:
                                                              Colors.white,
                                                          fontSize: context
                                                              .accountFont(15,
                                                                  mobile: 14),
                                                          color: Colors.black)),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10.0),
                                              child: AccountDetailRow(
                                                valueStart: 4,
                                                children: [
                                                  SizedBox(
                                                    width: 200,
                                                    child: Text('Booking Type',
                                                        style: TextStyle(
                                                            backgroundColor:
                                                                Colors.white,
                                                            fontSize: context
                                                                .accountFont(15,
                                                                    mobile: 14),
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                  horizontalSpaceMedium,
                                                  const Center(
                                                      child: Icon(Icons.remove,
                                                          color:
                                                              Colors.black54)),
                                                  horizontalSpaceLarge,
                                                  Text(
                                                      visibleGrns[index]
                                                          .bookingType!,
                                                      style: TextStyle(
                                                          backgroundColor:
                                                              Colors.white,
                                                          fontSize: context
                                                              .accountFont(15,
                                                                  mobile: 14),
                                                          color: Colors.black)),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10.0),
                                              child: AccountDetailRow(
                                                valueStart: 4,
                                                children: [
                                                  SizedBox(
                                                    width: 200,
                                                    child: Text('Challan No.',
                                                        style: TextStyle(
                                                            backgroundColor:
                                                                Colors.white,
                                                            fontSize: context
                                                                .accountFont(15,
                                                                    mobile: 14),
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                  horizontalSpaceMedium,
                                                  const Center(
                                                      child: Icon(Icons.remove,
                                                          color:
                                                              Colors.black54)),
                                                  horizontalSpaceLarge,
                                                  Text(
                                                      visibleGrns[index]
                                                          .challan_no!,
                                                      style: TextStyle(
                                                          backgroundColor:
                                                              Colors.white,
                                                          fontSize: context
                                                              .accountFont(15,
                                                                  mobile: 14),
                                                          color: Colors.black)),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10.0),
                                              child: AccountDetailRow(
                                                valueStart: 4,
                                                children: [
                                                  SizedBox(
                                                    width: 200,
                                                    child: Text('Grades',
                                                        style: TextStyle(
                                                            backgroundColor:
                                                                Colors.white,
                                                            fontSize: context
                                                                .accountFont(15,
                                                                    mobile: 14),
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                  horizontalSpaceMedium,
                                                  const Center(
                                                      child: Icon(Icons.remove,
                                                          color:
                                                              Colors.black54)),
                                                  horizontalSpaceLarge,
                                                  Text(
                                                      visibleGrns[index]
                                                          .gradeName!,
                                                      style: TextStyle(
                                                          backgroundColor:
                                                              Colors.white,
                                                          fontSize: context
                                                              .accountFont(15,
                                                                  mobile: 14),
                                                          color: Colors.black)),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10.0),
                                              child: AccountDetailRow(
                                                valueStart: 4,
                                                children: [
                                                  SizedBox(
                                                    width: 200,
                                                    child: Text('Generated On',
                                                        style: TextStyle(
                                                            backgroundColor:
                                                                Colors.white,
                                                            fontSize: context
                                                                .accountFont(15,
                                                                    mobile: 14),
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                  horizontalSpaceMedium,
                                                  const Center(
                                                      child: Icon(Icons.remove,
                                                          color:
                                                              Colors.black54)),
                                                  horizontalSpaceLarge,
                                                  Text(
                                                      '${visibleGrns[index].grnCreatedDate!}',
                                                      style: TextStyle(
                                                          backgroundColor:
                                                              Colors.white,
                                                          fontSize: context
                                                              .accountFont(15,
                                                                  mobile: 14),
                                                          color: Colors.black)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                              )),
                            );
                          },
                        )
                      : const AccountSkeleton()),
                  ])),
            )));
  }
}
