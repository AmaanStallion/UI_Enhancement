import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/tenant_payment_list.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/widgets/row_three_text.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';

class RentREceiptScreen extends StatefulWidget {
  const RentREceiptScreen({
    super.key,
    this.towarId,
    this.projectId,
    this.projectName,
    this.towarName,
    this.tenantId,
  });
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? tenantId;
  @override
  State<RentREceiptScreen> createState() => _RentREceiptScreenState();
}

class _RentREceiptScreenState extends State<RentREceiptScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  List<TenantPaymentListElement>? tenantPaymentListResponse = [];
  String? invoicePath = '';
  Future<List<TenantPaymentListElement>?> fetchTenantPaymentList() async {
    String formatDate(DateTime dateTime) {
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    }

    try {
      CustomLoading.progressDialog(isLoading: true, context: context);

      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "tenant_id": widget.tenantId ?? '',
        "project_id": widget.projectId ?? '',
        "towar_id": widget.towarId ?? '',
      };

      if (kDebugMode) {
        print(data);
      }

      var response =
          await apiNetworkHandler.post(AppUrl.getTenantPaymentList, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = tenantPaymentListFromJson(response.body);

        if (kDebugMode) {
          print(dataModel.response?.errorCode);
        }

        if (dataModel.response?.errorCode == "0") {
          setState(() {
            tenantPaymentListResponse = dataModel.response?.tenantPaymentList;
            invoicePath = dataModel.response?.invoicePath;
          });
        } else {
          // Handle error when errorCode is not "0"
        }
      } else {
        // Handle error for non-200/201 status codes
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
      // Handle exceptions here if needed
      // throw SomeCustomException('Exception occurred: $e');
    } finally {
      // ignore: use_build_context_synchronously
      CustomLoading.progressDialog(isLoading: false, context: context);
    }
    return null;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchTenantPaymentList();
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
                : '${widget.projectName!.toUpperCase()}',
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 40,
            child: Center(
              child: Text('RENT RECEIPT',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center),
            ),
          ),
          const Divider(height: 1.0, color: Colors.black),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: tenantPaymentListResponse?.length ?? 0,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          return PdfViewer(
                              fileName: 'Receipt',
                              fileUrl: tenantPaymentListResponse?[index]
                                  .paymentReceipt!);
                        },
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.only(left: 60),
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Column(
                      children: [
                        rowThreeText(
                            context: context,
                            title: "Flat No.",
                            titleValue: tenantPaymentListResponse?[index]
                                    .tenantInvoiceSrNo ??
                                ''),
                        rowThreeText(
                          context: context,
                          title: "Payment On",
                          titleValue: tenantPaymentListResponse?[index]
                                  .tenantDatePunch ??
                              '',
                        ),
                        rowThreeText(
                            context: context,
                            title: "Amount",
                            titleValue:
                                tenantPaymentListResponse?[index].paidAmount ??
                                    ''),
                        rowThreeText(
                          context: context,
                          title: "Payment Mode",
                          titleValue:
                              tenantPaymentListResponse?[index].tenantPayMode ??
                                  '',
                        ),
                        rowThreeText(
                          context: context,
                          title: "Remarks",
                          titleValue:
                              tenantPaymentListResponse?[index].remark ?? '',
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
