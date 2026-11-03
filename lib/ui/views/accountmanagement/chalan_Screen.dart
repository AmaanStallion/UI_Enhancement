import 'package:stallion/ui/views/accountmanagement/account_management_preview.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_document.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_chalan_list.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/utils/app_url.dart';

class ChalanScreen extends StatefulWidget {
  const ChalanScreen({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    this.orderId,
  });
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? orderId;

  @override
  State<ChalanScreen> createState() => _ChalanScreenState();
}

class _ChalanScreenState extends State<ChalanScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<ChallanReportList>? challanReportList = [];

  Future<ChallanReportList?> fetchChallanList() async {
    CustomLoading.progressDialog(isLoading: true, context: context);

    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    Map<String, String> data = {
      "user_id": userId ?? '',
      "order_id": widget.orderId ?? '',
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await AccountManagementPreviewNetwork()
        .post(AppUrl.getGetPoChallan, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      CustomLoading.progressDialog(isLoading: false, context: context);

      final dataModel = getChalanListFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          challanReportList = dataModel.response?.challanReportList;
        });
      }
    } else {
      CustomLoading.progressDialog(isLoading: false, context: context);

      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
    return null;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchChallanList();
    });
    super.initState();
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
            widget.towarName!.isNotEmpty
                ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                : widget.projectName!.toUpperCase(),
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Center(
              child: Text(
                "VIEW CHALLAN",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Divider(),
          for (int i = 0; i < challanReportList!.length; i++)
            Container(
              padding: const EdgeInsets.only(
                  left: 100, right: 100, bottom: 20, top: 10),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black12))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      challanReportList![i].poChallanReport!.split(".").last ==
                              'pdf'
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return (useAccountManagementTestData
                                      ? const AccountManagementPreviewDocumentScreen()
                                      : PdfViewer(
                                          fileName: challanReportList![i]
                                              .poChallanReport!,
                                          fileUrl: AppUrl.globalPoChallanUrl +
                                              challanReportList![i]
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
                                          fileName: challanReportList![i]
                                              .poChallanReport!,
                                          fileUrl:
                                              '${AppUrl.globalPoChallanUrl}${challanReportList![i].poChallanReport!}',
                                        ));
                                },
                              ),
                            );
                    },
                    child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          // color: Colors.amber,
                          border: Border.all(
                            color: Colors.black45,
                          ),
                        ),
                        child: challanReportList![i]
                                .poChallanReport!
                                .contains('.pdf')
                            ? Image.asset(
                                'images/projectmanagement/pdf.png',
                                width: 100,
                                height: 100,
                              )
                            : (useAccountManagementTestData
                                ? const Icon(Icons.description_outlined,
                                    size: 48, color: Colors.black54)
                                : Image.network(
                                    '${AppUrl.globalPoChallanUrl}${challanReportList![i].poChallanReport!}',
                                    width: 100,
                                    height: 100,
                                  ))
                        // child: Image.network(
                        //   '${AppUrl.globalFinishingPath}${isFinishingConsumeDetailEdit!.documentList?[i].documentName}',
                        //   width: 80,
                        //   height: 80,
                        // ),
                        ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "Remarks",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        challanReportList?[i].poChallanRemarks ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('dd MMM yyyy').format(
                        challanReportList?[i].poChallanCretatedAt ??
                            DateTime.now()),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  )
                ],
              ),
            ),
          if (challanReportList!.length == 0)
            const Expanded(
                child: Center(
              child: Text(
                "No Record Found",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ))
        ],
      ),
    );
  }
}
