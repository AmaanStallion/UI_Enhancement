import 'package:stallion/ui/views/accountmanagement/account_management_preview.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_document.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../models/get_po_viewchallan.dart';
import '../../../../utils/api_network_call.dart';
import '../../../../utils/app_url.dart';
import '../../../shared/ui_helpers.dart';
import '../../mycontracts/imagepreviewview.dart';
import '../../rccstructure/pdfviewer.dart';

class ViewChallanList extends StatefulWidget {
  const ViewChallanList(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.orderId});
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? orderId;

  @override
  State<ViewChallanList> createState() => _ViewChallanListState();
}

class _ViewChallanListState extends State<ViewChallanList> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = AccountManagementPreviewNetwork();

  bool flagcalled = false;
  List<ChallanReportList>? challanReportList;

  Future<ResponseGetPoViewChallan?> wspochallanlist() async {
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

    var response = await apiNetworkHandler.post(AppUrl.webgetpochallan, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getPoViewChallanFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          flagcalled = true;
          challanReportList = dataModel.response?.challanReportList!;
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
    wspochallanlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('${widget.projectName!.toUpperCase()} - VIEW CHALLAN',
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
                ? Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height - 106,
                        child: ListView.builder(
                            itemCount: challanReportList!.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  challanReportList![index]
                                              .poChallanReport!
                                              .split(".")
                                              .last ==
                                          'pdf'
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) {
                                              return (useAccountManagementTestData
                                                  ? const AccountManagementPreviewDocumentScreen()
                                                  : PdfViewer(
                                                      fileName:
                                                          challanReportList![
                                                                  index]
                                                              .poChallanReport!,
                                                      fileUrl: AppUrl
                                                              .globalPoChallanUrl +
                                                          challanReportList![
                                                                  index]
                                                              .poChallanReport!,
                                                    ));
                                            },
                                          ),
                                        )
                                      : Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) {
                                              return (useAccountManagementTestData
                                                  ? const AccountManagementPreviewDocumentScreen()
                                                  : ImagePreviewViewer(
                                                      fileName:
                                                          challanReportList![
                                                                  index]
                                                              .poChallanReport!,
                                                      fileUrl:
                                                          '${AppUrl.globalPoChallanUrl}${challanReportList![index].poChallanReport!}',
                                                    ));
                                            },
                                          ),
                                        );
                                },
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 60.0),
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              challanReportList![index]
                                                      .poChallanReport!
                                                      .contains('.pdf')
                                                  ? Image.asset(
                                                      'images/projectmanagement/pdf.png',
                                                      width: 100,
                                                      height: 100,
                                                    )
                                                  : (useAccountManagementTestData
                                                      ? const Icon(
                                                          Icons
                                                              .description_outlined,
                                                          size: 48,
                                                          color: Colors.black54)
                                                      : Image.network(
                                                          '${AppUrl.globalPoChallanUrl}${challanReportList![index].poChallanReport!}',
                                                          width: 100,
                                                          height: 100,
                                                        ))
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 50.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      width: 150,
                                                      child: Text('Remarks',
                                                          style: boldText),
                                                    ),
                                                    horizontalSpaceLarge,
                                                    Text(
                                                        DateFormat(
                                                                'dd MMM yyyy')
                                                            .format(challanReportList![
                                                                    index]
                                                                .poChallanCretatedAt!),
                                                        style: normalText),
                                                  ],
                                                ),
                                                verticalSpaceSmall,
                                                Text(
                                                    challanReportList![index]
                                                        .poChallanRemarks!,
                                                    style: normalText),
                                                verticalSpaceSmall,
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(),
                                  ],
                                ),
                              );
                            }),
                      )
                    ],
                  )
                : const Center(child: CircularProgressIndicator())),
      ),
    );
  }
}
