import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/getCaseFlowList.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/utils/app_url.dart';

class AutoRecon extends StatefulWidget {
  const AutoRecon(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.towarName})
      : super(key: key);

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;

  @override
  State<AutoRecon> createState() => _AutoReconState();
}

class _AutoReconState extends State<AutoRecon> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<BankDetail>? bankDetails = [];
  List<CaseflowList>? caseflowList = [];

  String? totalCredit;
  String? totalDebit;
  String? totalCount;

  String? selectedBankId;
  String? selectedBankName;

  DateTime? startDate;
  DateTime? endDate;

  int offset = 0;
  final int limit = 25;

  bool isLoading = false;

  // Future<void> getCaseFlowList() async {
  //   final SharedPreferences prefs = await _prefs;
  //   String? userId = prefs.getString('mobileNo');

  //   Map<String, String> data = {
  //     "user_id": userId ?? '',
  //     "project_id": widget.projectId ?? '',
  //     "towar_id": widget.towarId ?? '',
  //     'bank_id': '',
  //     'limit': '10',
  //     'offest': '0',
  //     'start_date': '',
  //     'end_date': '',
  //   };

  //   var response = await apiNetworkHandler.post(AppUrl.caseFlowList, data);
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     final dataModel = getCaseFlowListFromJson(response.body);
  //     if (dataModel.response?.errorCode == "0") {
  //       setState(() {
  //         bankDetails = dataModel.response?.bankDetails ?? [];
  //         caseflowList = dataModel.response?.caseflowList ?? [];
  //       });
  //     }
  //   }
  // }
  String _formatApiDate(DateTime? date) {
    if (date == null) return '';
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> getCaseFlowList({bool isPagination = false}) async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    if (!isPagination) {
      offset = 0; // reset on filter
    }

    setState(() {
      isLoading = true;
    });

    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
      "bank_id": selectedBankId ?? '',
      "limit": limit.toString(),
      "offest": offset.toString(),
      "start_date": _formatApiDate(startDate),
      "end_date": _formatApiDate(endDate),
    };

    var response = await apiNetworkHandler.post(AppUrl.caseFlowList, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getCaseFlowListFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          bankDetails = dataModel.response?.bankDetails ?? [];
          totalCredit = dataModel.response?.totalCredit ?? '';
          totalDebit = dataModel.response?.totalDebit ?? '';
          totalCount = dataModel.response?.totalCount ?? '';

          if (isPagination) {
            caseflowList!.addAll(dataModel.response?.caseflowList ?? []);
          } else {
            caseflowList = dataModel.response?.caseflowList ?? [];
          }

          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  selectBankModal() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context1, setState2) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 0),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 0),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  "Select Bank",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 450,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
              content: SizedBox(
                height: 300,
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // for (int i = 0; i < bankDetails!.length; i++)
                      //   Container(
                      //     decoration: const BoxDecoration(
                      //         border: Border(
                      //             bottom: BorderSide(
                      //       color: Colors.grey,
                      //     ))),
                      //     child: Row(
                      //       children: [
                      //         Text(
                      //           bankDetails?[i].bankName ?? '',
                      //           style: const TextStyle(
                      //             fontSize: 20,
                      //           ),
                      //         ),
                      //         Icon(
                      //           Icons.check_box_outline_blank_rounded,
                      //           color: Colors.green,
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      for (int i = 0; i < bankDetails!.length; i++)
                        InkWell(
                          onTap: () {
                            setState(() {
                              selectedBankId = bankDetails![i].projectBankId;
                              selectedBankName = bankDetails![i].bankName;
                            });

                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  bankDetails![i].bankName ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                selectedBankId == bankDetails![i].projectBankId
                                    ? const Icon(Icons.check,
                                        color: Colors.green)
                                    : const Icon(Icons.circle_outlined,
                                        color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  @override
  void initState() {
    getCaseFlowList();
    // TODO: implement initState
    super.initState();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return "${date.day}-${date.month}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.projectName!.toUpperCase(),
            // '-',
            // widget.towarName?.isNotEmpty
            //     ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
            //     : widget.projectName!.toUpperCase(),
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 46),
        color: Colors.grey.shade200,
        height: 80,
        child: Column(
          children: [
            Row(
              children: [
                Text('Balance asper Company Books:'),
                Spacer(),
                // Text(totalCredit ?? '-'),
                Text(currencyFormat.format(double.parse(totalCredit ?? '0'))),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text('Ammount not reflected in Bank:'),
                Spacer(),
                Text(currencyFormat.format(double.parse(totalDebit ?? '0'))),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Balance as per Bank:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Spacer(),
                // currencyFormat.format(
                //                         double.parse(strPaymentDue ?? '')),
                Text(
                  double.tryParse(totalCredit ?? '0') != null &&
                          double.tryParse(totalDebit ?? '0') != null
                      ? currencyFormat.format(double.parse(totalCredit ?? '0') -
                          double.parse(totalDebit ?? '0'))
                      // .toStringAsFixed(2)
                      : '-',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Center(
            child: Column(
              children: [
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    'AUTO RECO',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                Divider(),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: InkWell(
              onTap: () {
                selectBankModal();
              },
              // child: Text("data"),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        selectedBankName ?? "Select Bank",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          // Filters Row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: Row(
              children: [
                // From Date
                Expanded(
                  child: _dateField(
                    startDate != null ? _formatDate(startDate) : 'Start Date',
                    (date) {
                      setState(() {
                        startDate = date;
                      });
                    },
                  ),
                  // _dateField('3 Mar 26'),
                ),

                const SizedBox(width: 10),

                // To Date
                Expanded(
                  child:
                      // _dateField('3 Apr 26'),
                      _dateField(
                    endDate != null ? _formatDate(endDate) : 'End Date',
                    (date) {
                      setState(() {
                        endDate = date;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 10),

                // Apply Button
                ElevatedButton( 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                  ),
                  // onPressed: () {},
                  onPressed: () {
                    getCaseFlowList(); // filters applied
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Table
          // Container(
          //   width: double.infinity, // 👈 IMPORTANT
          //   child: DataTable(
          //     columnSpacing: 20,
          //     headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
          //     columns: const [
          //       DataColumn(label: Text('Date')),
          //       DataColumn(label: Text('Particulars')),
          //       DataColumn(label: Text('Transaction Type')),
          //       DataColumn(label: Text('Bank Date')),
          //       DataColumn(label: Text('Debit')),
          //       DataColumn(label: Text('Credit')),
          //     ],
          //     rows: caseflowList!.map((item) {
          //       return DataRow(cells: [
          //         DataCell(Text(_formatDate(item.createdAt))),
          //         DataCell(Text(item.transationName ?? '')),
          //         DataCell(Text(item.paymentType ?? '')),
          //         DataCell(Text(_formatDate(item.bankDate))),
          //         DataCell(Text(
          //           item.debitAmount ?? '',
          //           style: const TextStyle(color: Colors.green),
          //         )),
          //         DataCell(Text(
          //           item.creditAmount ?? '',
          //           style: const TextStyle(color: Colors.red),
          //         )),
          //       ]);
          //     }).toList(),
          //   ),
          // ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : caseflowList == null || caseflowList!.isEmpty
                    ? const Center(child: Text("No Data Found"))
                    : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width,
                            ),
                            child: DataTable(
                              columnSpacing: 20,
                              headingRowColor: MaterialStateProperty.all(
                                  Colors.grey.shade200),
                              columns: const [
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Particulars')),
                                DataColumn(label: Text('Transaction Type')),
                                DataColumn(label: Text('Bank Date')),
                                DataColumn(label: Text('Debit')),
                                DataColumn(label: Text('Credit')),
                              ],
                              rows: caseflowList!.map((item) {
                                return DataRow(cells: [
                                  DataCell(Text(_formatDate(item.createdAt))),
                                  DataCell(Text(item.transationName ?? '')),
                                  DataCell(Text(item.paymentType ?? '')),
                                  DataCell(Text(_formatDate(item.bankDate))),
                                  DataCell(Text(
                                    item.debitAmount == '0'
                                        ? '-'
                                        : item.debitAmount ?? '',
                                    style: const TextStyle(color: Colors.green),
                                  )),
                                  DataCell(Text(
                                    item.creditAmount == '0'
                                        ? '-'
                                        : item.creditAmount ?? '',
                                    style: const TextStyle(color: Colors.red),
                                  )),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
          )
        ],
      ),
    );
  }

  Widget _dateField(String hint, Function(DateTime) onSelect) {
    return InkWell(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );

        if (picked != null) {
          onSelect(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 10),
            Text(hint),
          ],
        ),
      ),
    );
  }
}

// Widget _dateField(String text) {
//   return TextFormField(
//     readOnly: true,
//     decoration: InputDecoration(
//       prefixIcon: const Icon(Icons.calendar_today),
//       hintText: text,
//       border: const OutlineInputBorder(),
//     ),
//   );
// }

DataRow _row(
  String date,
  String particulars,
  String type,
  String bankDate,
  String debit,
  String credit,
) {
  return DataRow(cells: [
    DataCell(Text(date)),
    DataCell(Text(particulars)),
    DataCell(Text(type)),
    DataCell(Text(bankDate)),
    DataCell(Text(
      debit,
      style: const TextStyle(color: Colors.green),
    )),
    DataCell(Text(
      credit,
      style: const TextStyle(color: Colors.red),
    )),
  ]);
}
