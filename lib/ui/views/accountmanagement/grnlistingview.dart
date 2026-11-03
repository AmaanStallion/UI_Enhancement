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
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
              '${widget.projectName!.toUpperCase()} - GOODS RECEIVED NOTE',
              style:
                  const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
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
              child: flagcalled == true
                  ? ListView.builder(
                      itemCount: grnDetails!.length,
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
                                          fileName: grnDetails![index]
                                              .grnFileName!
                                              .toString(),
                                          fileUrl:
                                              '${AppUrl.globalGrnPath}${grnDetails![index].grnFileName!.toString()}',
                                        ));
                                },
                              ),
                            );
                          },
                          child: ListTile(
                            trailing: const Padding(
                              padding: EdgeInsets.only(top: 70.0),
                              child: Icon(Icons.keyboard_arrow_right),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 50, top: 10),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 200,
                                                child: Text('GRN. No.',
                                                    style: TextStyle(
                                                        backgroundColor:
                                                            Colors.white,
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                              ),
                                              horizontalSpaceMedium,
                                              const Center(
                                                  child: Icon(Icons.remove,
                                                      color: Colors.black54)),
                                              horizontalSpaceLarge,
                                              Text(grnDetails![index].grnSrNo!,
                                                  style: const TextStyle(
                                                      backgroundColor:
                                                          Colors.white,
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 200,
                                                child: Text('Booking Type',
                                                    style: TextStyle(
                                                        backgroundColor:
                                                            Colors.white,
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                              ),
                                              horizontalSpaceMedium,
                                              const Center(
                                                  child: Icon(Icons.remove,
                                                      color: Colors.black54)),
                                              horizontalSpaceLarge,
                                              Text(
                                                  grnDetails![index]
                                                      .bookingType!,
                                                  style: const TextStyle(
                                                      backgroundColor:
                                                          Colors.white,
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 200,
                                                child: Text('Challan No.',
                                                    style: TextStyle(
                                                        backgroundColor:
                                                            Colors.white,
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                              ),
                                              horizontalSpaceMedium,
                                              const Center(
                                                  child: Icon(Icons.remove,
                                                      color: Colors.black54)),
                                              horizontalSpaceLarge,
                                              Text(
                                                  grnDetails![index]
                                                      .challan_no!,
                                                  style: const TextStyle(
                                                      backgroundColor:
                                                          Colors.white,
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 200,
                                                child: Text('Grades',
                                                    style: TextStyle(
                                                        backgroundColor:
                                                            Colors.white,
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                              ),
                                              horizontalSpaceMedium,
                                              const Center(
                                                  child: Icon(Icons.remove,
                                                      color: Colors.black54)),
                                              horizontalSpaceLarge,
                                              Text(
                                                  grnDetails![index].gradeName!,
                                                  style: const TextStyle(
                                                      backgroundColor:
                                                          Colors.white,
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 200,
                                                child: Text('Generated On',
                                                    style: TextStyle(
                                                        backgroundColor:
                                                            Colors.white,
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                              ),
                                              horizontalSpaceMedium,
                                              const Center(
                                                  child: Icon(Icons.remove,
                                                      color: Colors.black54)),
                                              horizontalSpaceLarge,
                                              Text(
                                                  '${grnDetails![index].grnCreatedDate!}',
                                                  style: const TextStyle(
                                                      backgroundColor:
                                                          Colors.white,
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )),
                                verticalSpaceSmall15,
                                const Divider(
                                  height: 1,
                                  thickness: 0.5,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(child: CircularProgressIndicator())),
        ));
  }
}
