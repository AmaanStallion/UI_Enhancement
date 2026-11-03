import 'package:stallion/ui/views/accountmanagement/account_management_preview.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_payment_due_list.dart';
import 'package:stallion/models/get_po_new.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/accountmanagement/paymentdue/paymentcompanylist.dart';
import 'package:stallion/utils/app_url.dart';
import '../../../../utils/api_network_call.dart';
import '../../../shared/ui_helpers.dart';

class PaymentDueList extends StatefulWidget {
  PaymentDueList(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      // this.data1,
      required this.totalDue,
      required this.dueType,
      this.flagRedirect});
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? flagRedirect;
  // List<Vendor>? data1;
  String totalDue;
  String dueType;

  @override
  State<PaymentDueList> createState() => _PaymentDueListState();
}

class _PaymentDueListState extends State<PaymentDueList> {
  List<Vendor>? data1 = [];
  NetworkHandler apiNetworkHandler = AccountManagementPreviewNetwork();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool flagcalled = false;
  bool norecord = false;
  // List<VenderDueList>? venderDueList;
  List<Vendor>? venderDueListOriginal = [];
  // double totalDue = 0.0;

  Future<ResponseGetPaymentDueList?> wsVenderPaymentDuelist() async {
    CustomLoading.progressDialog(isLoading: true, context: context);

    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    // String dueType = '0';
    // if (widget.flagRedirect == 'PaymentDue') {
    //   dueType = '0';
    // } else {
    //   dueType = '1';
    // }

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": widget.projectId ?? '',
      "towar_id": towerId,
      "payment_type": widget.dueType,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.wsvenderpaymentduelist, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getPaymentDueListFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          data1 = dataModel.response?.vendorDueList;
          print(data1);
          // venderDueList = dataModel.response?.venderDueList!;
          venderDueListOriginal = dataModel.response?.vendorDueList;
          // if (venderDueList!.isEmpty) {
          //   norecord = true;
          // } else {
          //   norecord = false;
          // }
          // flagcalled = true;
          // totalDue = double.parse(dataModel.response!.totalDue!);
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      // return null;
    }
    CustomLoading.progressDialog(isLoading: false, context: context);
  }

  String searchTermValue = '';
  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // setState(() {
    //   venderDueListOriginal = data1;
    // });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      wsVenderPaymentDuelist();
    });
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
            widget.flagRedirect! == 'PaymentDue'
                ? '${widget.projectName!.toUpperCase()} - PAYMENTS DUE'
                : '${widget.projectName!.toUpperCase()} - PAYMENTS OVERDUE',
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        actions: [],
      ),
      body: Container(
        height: double.infinity,
        color: Colors.white,
        child: SafeArea(
            child:
                //  flagcalled == true
                //     ?
                Column(
          children: [
            verticalSpaceSmall,
            Padding(
              padding: const EdgeInsets.only(left: 60.0, right: 60),
              child: SizedBox(
                height: 40,
                child: TextField(
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      List<Vendor>? filteredList = [];
                      filteredList = venderDueListOriginal!
                          .where((element) => element.venderName!
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                      setState(() {
                        data1 = filteredList;
                        if (data1!.isEmpty) {
                          norecord = true;
                        } else {
                          norecord = false;
                        }
                        flagcalled = true;
                      });
                    } else {
                      setState(() {
                        data1 = venderDueListOriginal;
                        if (data1!.isEmpty) {
                          norecord = true;
                        } else {
                          norecord = false;
                        }
                        flagcalled = true;
                      });
                    }
                  },
                  style: const TextStyle(fontSize: 13),
                  controller: editingController,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(12.0),
                      labelText: "Search by Vendor Name",
                      hintText: "Search by Vendor Name",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(25.0)))),
                ),
              ),
            ),
            verticalSpaceSmall,
            const Divider(
              height: 0.5,
              thickness: 0.5,
              indent: 1,
              endIndent: 1,
              color: Colors.black,
            ),
            data1?.length == 0
                ? const Expanded(
                    child: Center(
                        child: Text('No Record Found', style: normalText)),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: data1!.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            var projectId = widget.projectId!;
                            var projectName = widget.projectName!;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return PaymentCompanyList(
                                    projectId: projectId,
                                    towarId: widget.towarId ?? '',
                                    projectName: projectName,
                                    vendorId: data1?[index].venderId ?? '',
                                    vendorName: data1?[index].venderName ?? '',
                                  );
                                },
                              ),
                            ).then((_) {
                              // This block runs when you have returned back to the 1st Page from 2nd.
                              setState(() {
                                // Call setState to refresh the page.
                                flagcalled = false;
                                // wsVenderPaymentDuelist();
                              });
                            });
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
                                                child: Text('Vendor Name',
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
                                                  data1![index].venderName ??
                                                      '',
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
                                                child: Text('Order Type',
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
                                              Flexible(
                                                child: Text(
                                                    data1![index].gradeName ??
                                                        '',
                                                    style: const TextStyle(
                                                        backgroundColor:
                                                            Colors.white,
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                              ),
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
                                                child: Text('Amount Due',
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
                                                  data1![index].dueamount! != ""
                                                      ? currencyFormat.format(
                                                          double.parse(
                                                              data1![index]
                                                                  .dueamount!))
                                                      : '\u{20B9} 0',
                                                  style: widget.flagRedirect ==
                                                          'PaymentDue'
                                                      ? boldText
                                                      : const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14.0,
                                                          color: Colors.red)),
                                              const Spacer(),
                                              Text(
                                                // 'Pending Invoice: ${widget.data1![index].pendingInvoice}',
                                                "Pending Invoice : ${data1![index].pendingInvoice} / ${data1![index].totalInvCount}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue,
                                                ),
                                              )
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
                    ),
                  ),
          ],
        )),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 20, top: 10),
        decoration: const BoxDecoration(color: Colors.black),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(
            Icons.account_balance,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            widget.flagRedirect == 'PaymentDue'
                ? 'Payment Due  '
                : 'Payment Overdue  ',
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          const SizedBox(
            width: 10,
          ),
          const Text(' : ',
              style: TextStyle(color: Colors.white, fontSize: 17)),
          const SizedBox(
            width: 10,
          ),
          Text(currencyFormat.format(double.parse(widget.totalDue)),
              style: const TextStyle(color: Colors.white, fontSize: 17)),
        ]),
      ),
    );
  }
}
