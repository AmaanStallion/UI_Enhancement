import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart' show Lottie;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/master_dashboard_model.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/accountmanagement/accountmanagement.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/mycontracts/mycontract_list_view.dart';
import 'package:stallion/ui/views/mycontracts/mycontracts.dart';
import 'package:stallion/ui/views/permission/permissions.dart';
import 'package:stallion/ui/views/rccstructure/dpr/daily_progress_report.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/views/salesmanagement/salesmainview.dart';
import 'package:stallion/utils/app_url.dart';

class MasterDashboard extends StatefulWidget {
  const MasterDashboard({super.key});

  @override
  State<MasterDashboard> createState() => _MasterDashboardState();
}

class _MasterDashboardState extends State<MasterDashboard> {
  final horizontalController = ScrollController();
  final verticalController = ScrollController();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  // List<MasterDashboardElement>? masterDashboard = [];
  List<MasterDashboardElement>? masterDashboard = [];
  bool isLoading = true;

  final formatter = NumberFormat.currency(
    locale: 'en_IN', // Indian locale
    symbol: '',
    decimalDigits: 2,
  );

  Future<dynamic?> getMasterDashboardList() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId ?? '',
    };
    var response =
        await apiNetworkHandler.post(AppUrl.getAppMasterDashboard, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = masterDashboardFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          isLoading = false;
          masterDashboard = dataModel.response?.masterDashboard;
        });
      }
    }
    return null;
  }

  @override
  void initState() {
    getMasterDashboardList();
    // TODO: implement initState
    super.initState();
  }

  List<DataColumn> _buildColumns() {
    return [
      // DataColumn( label: Text("Project")),
      DataColumn(
        label: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            // borderRadius: BorderRadius.circular(5),
          ),
          constraints: const BoxConstraints(minWidth: 150),
          child: const Text("Project"),
        ),
      ),
      DataColumn(
          label: Column(
        children: [
          const Text("Permission"),
          Row(
            children: [
              Container(
                width: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  // borderRadius: BorderRadius.circular(5),
                ),
                child: const Text("Total"),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  // borderRadius: BorderRadius.circular(5),
                ),
                child: const Text("Pending"),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  // borderRadius: BorderRadius.circular(5),
                ),
                child: const Text("Issued"),
              ),
              // Text("Total/Pending/Issued"),
            ],
          ),
        ],
      )),
      const DataColumn(label: Text("PO\nOpen/Issued")),
      const DataColumn(label: Text("WO\nOpen/Issued")),
      const DataColumn(label: Text("Invoice (PO)\nPaid/Unpaid")),
      const DataColumn(label: Text("Invoice (WO)\nPaid/Unpaid")),
      const DataColumn(label: Text("Payments\nPO Due/Overdue")),
      const DataColumn(label: Text("WO Due")),
      const DataColumn(label: Text("Sales\nAvailable/Sold")),
      const DataColumn(label: Text("DPR")),
    ];
  }

  List<DataRow> _buildRows() {
    return masterDashboard!.map((project) {
      return DataRow(cells: [
        // DataCell(Text(project.projectDisplayName ?? "-")),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 150),
            child: Text(project.projectDisplayName ?? ""),
          ),
        ),
        DataCell(
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  // borderRadius: BorderRadius.circular(5),
                ),
                constraints: const BoxConstraints(minWidth: 60),
                child: Text("${project.totalPerm ?? "0"}"),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  // borderRadius: BorderRadius.circular(5),
                ),
                constraints: const BoxConstraints(minWidth: 60),
                child: Text("${project.pendPerm ?? "0"}"),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  // borderRadius: BorderRadius.circular(5),
                ),
                constraints: const BoxConstraints(minWidth: 60),
                child: Text("${project.issuePerm ?? "0"}"),
              ),
              // Text("Total/Pending/Issued"),
            ],
          ),
          // Text(
          //   "${project.totalPerm}/${project.pendPerm}/${project.issuePerm}")
        ),
        DataCell(Text("${project.totalOpenPo}/${project.poIssued}")),
        DataCell(Text("${project.totalOpenWo}/${project.woIssued}")),
        DataCell(Text("${project.poInvoicePaid}/${project.poInvoiceUnpaid}")),
        DataCell(Text("${project.woInvoicePaid}/${project.woInvoiceUnpaid}")),
        DataCell(Text(
            "${project.poDueAmount ?? "0.0"}/${project.poOverDueAmount ?? "0.0"}")),
        DataCell(Text(project.woDueAmount ?? "0.0")),
        DataCell(Text("${project.totalUnsold}/${project.totalSold}")),
        DataCell(project.dprUrl != null && project.dprUrl!.isNotEmpty
            ? InkWell(
                child: const Text("View DPR",
                    style: TextStyle(color: Colors.blue)),
                onTap: () {
                  // Open PDF URL in browser
                  // launchUrl(Uri.parse(project.dprUrl!));
                },
              )
            : Text(project.dpr ?? "-")),
      ]);
    }).toList();
  }

  final double _columnWidth = 100;

  Widget _buildColumnsCustom() {
    return Row(
      children: [
        Container(
          width: 200,
          height: 80,
          padding: const EdgeInsets.only(top: 45),
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: const Text('Projects/Tower',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              )),
        ),
        const CustomColumnHeader(
          title: "Permission",
          headers: ["Total", "Pending", "Issued"],
        ),
        const CustomColumnHeader(
          title: "Purchase/Work Orders",
          // headers: ["Pending", "Issued"],
          headers: ["Total", "Pending", "Issued"],
        ),
        const CustomColumnHeader(
          title: "Paid/Unpaid Invoices",
          headers: ["PO", "WO"],
        ),
        const CustomColumnHeader(
          title: "Invoice Amount (Paid/Unpaid)",
          headers: ["PO", "WO"],
        ),
        const CustomColumnHeader(
          title: "Payments",
          headers: ["PO(Due/Overdue)", "WO(Work Done/Due)"],
        ),
        const CustomColumnHeader(
          title: "Sales Management",
          headers: ["Available/Sold", "Collectable/Collected", "Balance"],
        ),
        const CustomColumnHeader(
          title: "DPR",
          headers: ["Latest"],
        ),
      ],
    );
  }

  Widget _buildColumnsBodyCustom() {
    return Column(
      children: masterDashboard!.map((project) {
        return Row(
          children: [
            Container(
              width: 200,
              height: 73,
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey),
                ),
              ),
              child: Center(
                child: Text(project.projectDisplayName ?? '',
                    // 'Vaibhav JewelsWING A',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    )),
              ),
            ),
            CustomColumnHeaderBody(
              onTap: () {
                // Handle tap if needed
                // var projectId = widget.projectId!;
                // var projectName = widget.projectName!;
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) {
                //       return Permissions(
                //         projectId: project.projectId,
                //         towarId: project.projectTowerId,
                //         projectName: project.projectDisplayName ?? '',
                //         towarName: project.towerName,
                //       );
                //     },
                //   ),
                // );
                Navigator.of(context).pushNamed(
                  '/permissions',
                  arguments: NotificationArgs(
                    projectId: project.projectId,
                    projectName: project.projectDisplayName ?? '',
                    towarName: project.towerName,
                    response: NotificationResponseData(
                      towarId: project.projectTowerId,
                    ),
                  ),
                );
              },
              headers: [
                "${project.totalPerm ?? "0"}",
                "${project.pendPerm ?? "0"}",
                "${project.issuePerm ?? "0"}"
              ],
            ),
            CustomColumnHeaderBody(
              onTap: () {
                // Handle tap if needed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return AccountManagementView(
                          // projectId: tempp.projectId,
                          // towarId: tempp.response?.towarId,
                          // projectName: tempp.projectName,
                          // towarName: tempp.projectLocation ?? '',
                          projectId: project.projectId,
                          towarId: project.projectTowerId,
                          projectName: project.projectDisplayName ?? '',
                          towarName: project.towerName,
                          navigationFlag: 'Project');
                    },
                  ),
                );
              },
              headers: [
                "${project.totalPoRaise}/${project.totalWoRaise}",

                "${project.totalOpenPo}/${project.totalOpenWo}",

                // "${project.totalOpenPo ?? "0"}",
                "${project.poIssued}/${project.woIssued}",
              ],
            ),
            // CustomColumnHeaderBody(
            //   onTap: () {
            //     // Handle tap if needed
            //   },
            //   headers: [
            //     "${project.poInvoicePaid}/${project.poInvoiceUnpaid}",
            //     "${project.woInvoicePaid}/${project.woInvoiceUnpaid}",
            //   ],
            // ),
            Container(
              // width: (columnWidth * headers.length) + 2,
              width: 300,
              height: 73,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              return AccountManagementView(
                                  // projectId: tempp.projectId,
                                  // towarId: tempp.response?.towarId,
                                  // projectName: tempp.projectName,
                                  // towarName: tempp.projectLocation ?? '',
                                  projectId: project.projectId,
                                  towarId: project.projectTowerId,
                                  projectName: project.projectDisplayName ?? '',
                                  towarName: project.towerName,
                                  navigationFlag: 'Project');
                            },
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: Text(
                          '${project.poInvoicePaid}/${project.poInvoiceUnpaid}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (_) {
                        //       return MycontractListView(
                        //           // projectId: projectId,
                        //           // towarId: widget.towarId!,
                        //           // projectName: projectName,
                        //           // towarName: widget.towarName!,
                        //           projectId: project.projectId,
                        //           towarId: project.projectId,
                        //           projectName: project.projectDisplayName ?? '',
                        //           towarName: 'widget.towarName',
                        //           navigationFlag: 'Project');
                        //     },
                        //   ),
                        // );
                        if (project.groupFlag == '1') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) {
                                return MycontractListView(
                                    // projectId: projectId,
                                    // towarId: widget.towarId!,
                                    // projectName: projectName,
                                    // towarName: widget.towarName!,
                                    projectId: project.projectId,
                                    towarId: project.projectTowerId,
                                    projectName:
                                        project.projectDisplayName ?? '',
                                    towarName: project.towerName,
                                    navigationFlag: 'Project');
                              },
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) {
                                return MyContractsView(
                                    categoryId: '',
                                    developerId: '',
                                    // projectId: projectId,
                                    // towarId: widget.towarId!,
                                    // projectName: projectName,
                                    // towarName: widget.towarName!,
                                    // navigationFlag: 'Project');

                                    projectId: project.projectId,
                                    towarId: project.projectTowerId,
                                    projectName:
                                        project.projectDisplayName ?? '',
                                    towarName: project.towerName,
                                    navigationFlag: 'Project');
                              },
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: Text(
                          "${project.woInvoicePaid}/${project.woInvoiceUnpaid}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            CustomColumnHeaderBody(
              onTap: () {
                // Handle tap if needed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return AccountManagementView(
                          // projectId: tempp.projectId,
                          // towarId: tempp.response?.towarId,
                          // projectName: tempp.projectName,
                          // towarName: tempp.projectLocation ?? '',
                          projectId: project.projectId,
                          towarId: project.projectTowerId,
                          projectName: project.projectDisplayName ?? '',
                          towarName: project.towerName,
                          navigationFlag: 'Project');
                    },
                  ),
                );
              },
              headers: [
                "${formatter.format(project.poInvoicePaidAmount)}/${formatter.format(project.poInvoiceTotalUnpaid)}",

                "${project.woInvoicePaidAmount}/${project.woInvoiceTotalUnpaid}",

                // "${project.totalOpenPo ?? "0"}",
                // "${project.poIssued}/${project.woIssued}",
              ],
            ),
            // CustomColumnHeaderBody(
            //   headers: [
            //     "${project.poDueAmount}/${project.poDueAmount}",
            //     "${project.woDueAmount}",
            //   ],
            // ),
            Container(
              // width: (columnWidth * headers.length) + 2,
              width: 300,
              height: 73,
              // padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey),
                ),
              ),
              child: Row(children:
                      // headers.map((header) {
                      //   return
                      [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return AccountManagementView(
                                // projectId: tempp.projectId,
                                // towarId: tempp.response?.towarId,
                                // projectName: tempp.projectName,
                                // towarName: tempp.projectLocation ?? '',
                                projectId: project.projectId,
                                towarId: project.projectTowerId,
                                projectName: project.projectDisplayName ?? '',
                                towarName: project.towerName,
                                navigationFlag: 'Project');
                          },
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey))),
                            child: Text(
                              formatter.format(
                                  double.parse(project.poDueAmount ?? '0')),
                              // "${project.poDueAmount}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          // Divider(
                          //   endIndent: 40,
                          //   indent: 40,
                          // ),
                          Text(
                            // '--',
                            // "${project.poOverDueAmount}",
                            formatter.format(
                                double.parse(project.poOverDueAmount ?? '0')),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) {
                      //       return MycontractListView(
                      //           // projectId: projectId,
                      //           // towarId: widget.towarId!,
                      //           // projectName: projectName,
                      //           // towarName: widget.towarName!,
                      //           projectId: project.projectId,
                      //           towarId: project.projectId,
                      //           projectName: project.projectDisplayName ?? '',
                      //           towarName: 'widget.towarName',
                      //           navigationFlag: 'Project');
                      //     },
                      //   ),
                      // );
                      if (project.groupFlag == '1') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              return MycontractListView(
                                  // projectId: projectId,
                                  // towarId: widget.towarId!,
                                  // projectName: projectName,
                                  // towarName: widget.towarName!,
                                  projectId: project.projectId,
                                  towarId: project.projectTowerId,
                                  projectName: project.projectDisplayName ?? '',
                                  towarName: project.towerName,
                                  navigationFlag: 'Project');
                            },
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              return MyContractsView(
                                  categoryId: '',
                                  developerId: '',
                                  // projectId: projectId,
                                  // towarId: widget.towarId!,
                                  // projectName: projectName,
                                  // towarName: widget.towarName!,
                                  // navigationFlag: 'Project');

                                  projectId: project.projectId,
                                  towarId: project.projectTowerId,
                                  projectName: project.projectDisplayName ?? '',
                                  towarName: project.towerName,
                                  navigationFlag: 'Project');
                            },
                          ),
                        );
                      }
                    },
                    child:
                        // Container(
                        //   decoration: BoxDecoration(
                        //     border: Border.all(color: Colors.black),
                        //   ),
                        //   child: Text(
                        //     // "${project.woDueAmount}",
                        //     formatter
                        //         .format(double.parse(project.woDueAmount ?? '0')),
                        //     textAlign: TextAlign.center,
                        //     style: const TextStyle(
                        //       color: Colors.white,
                        //       fontWeight: FontWeight.w400,
                        //       fontSize: 14,
                        //     ),
                        //   ),
                        // ),
                        Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey))),
                            child: Text(
                              // '--',
                              formatter.format(double.parse(
                                  project.woWorkDoneAmount ?? '0')),
                              // "${project.poDueAmount}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          // Divider(
                          //   endIndent: 40,
                          //   indent: 40,
                          // ),
                          Text(
                            // '++',
                            // "${project.poOverDueAmount}",
                            formatter.format(
                                double.parse(project.woDueAmount ?? '0')),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]
                  // }).toList(),
                  ),
            ),
            CustomColumnHeaderBody(
              onTap: () {
                // Handle tap if needed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return SalesManagementView(
                          // projectId: projectId,
                          // towarId: widget.towarId!,
                          // projectName: projectName,
                          // towarName: widget.towarName!,
                          projectId: project.projectId,
                          towarId: project.projectTowerId,
                          projectName: project.projectDisplayName ?? '',
                          towarName: project.towerName,
                          navigationFlag: 'Project');
                    },
                  ),
                );
              },
              headers: [
                "${project.totalSold}/${project.totalUnsold ?? "0"}",
                "${project.collectable}/${project.collected ?? "0"}",
                project.salesBalance ?? "0"
              ],
            ),
            // CustomColumnHeaderBody(
            //   headers: [
            //     "${project.dpr ?? "0"}",
            //   ],
            // ),

            GestureDetector(
              onTap: () {
                if (project.dpr != '') {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) {
                  //       return DailyProgressReport(
                  //         // projectId: tempp.projectId,
                  //         // towarId: tempp.response?.towarId,
                  //         // projectName: tempp.projectName,
                  //         // towarName: tempp.projectLocation,
                  //         projectId: project.projectId,
                  //         towarId: project.projectTowerId,
                  //         projectName: project.projectDisplayName ?? '',
                  //         towarName: project.towerName,

                  //         title: project.slabName, //'tempp.response?.slabNo',
                  //         slabId: project.slabId, //'tempp.response?.slabId',
                  //       );
                  //     },
                  //   ),
                  // );
                  Navigator.of(context).pushNamed(
                    '/dailyProgressReportScreen',
                    arguments: NotificationArgs(
                      projectId: project.projectId,
                      projectName: project.projectDisplayName,
                      towarName: project.towerName,
                      response: NotificationResponseData(
                        towarId: project.projectTowerId,
                        slabNo: project.slabName,
                        slabId: project.slabId,
                      ),
                    ),
                  );
                }
              },
              child: Container(
                // width: (columnWidth * headers.length) + 2,
                width: 300,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                      // right: BorderSide(color: Colors.grey),
                      ),
                ),
                child:
                    //  Row(
                    //   children:
                    //  headers.map((header) {
                    // return
                    //   Expanded(
                    // child:
                    Container(
                  decoration: const BoxDecoration(
                      // border: Border.all(color: Colors.black),
                      ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        project.dpr ?? "-",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                      if (project.dprUrl != '') const SizedBox(width: 10),
                      if (project.dprUrl != '')
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return PdfViewer(
                                    fileName: Uri.parse(project.dprUrl ?? '')
                                        .pathSegments
                                        .last,
                                    fileUrl: project.dprUrl,
                                  );
                                },
                              ),
                            );
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.blue))),
                            child: Text(
                              Uri.parse(project.dprUrl ?? '').pathSegments.last,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // ),
                  // );
                  // }).toList(),
                ),
              ),
            )
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      // appBar: AppBar(
      //   centerTitle: true,
      //   backgroundColor: Colors.black,
      //   foregroundColor: Colors.white,
      //   elevation: 0,
      //   title: const Text('Master Dashboard',
      //       style: TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
      // ),
      // body: masterDashboard == null || isLoading == true
      //     ? Center(
      //         child: SizedBox(
      //           height: 64,
      //           child: OverflowBox(
      //             minHeight: 100,
      //             maxHeight: 100,
      //             child: Lottie.asset(
      //               'assets/animation/running3.json',
      //               // 'assets/animation/chatbotfinallotiie.json',
      //               repeat: true,
      //             ),
      //           ),
      //         ),
      //       )
      //     // : SingleChildScrollView(
      //     //     scrollDirection: Axis.horizontal,
      //     //     child: SingleChildScrollView(
      //     //       scrollDirection: Axis.vertical,
      //     //       child:

      //     //        DataTable(
      //     //         columnSpacing: 20,
      //     //         columns: _buildColumns(),
      //     //         rows: _buildRows(),
      //     //       ),
      //     //     ),
      //     //   ),

      //     : SingleChildScrollView(
      //         scrollDirection: Axis.horizontal,
      //         child: Column(
      //           children: [
      //             _buildColumnsCustom(),
      //             Expanded(
      //               child: SingleChildScrollView(
      //                 scrollDirection: Axis.vertical,
      //                 child: _buildColumnsBodyCustom(),
      //               ),
      //             ),
      //           ],
      //         ),
      //       )

      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "MASTER DASHBOARD",
          style: TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0),
        ),
      ),
      body: masterDashboard == null || isLoading
          ? Center(
              child: SizedBox(
                height: 64,
                child: OverflowBox(
                  minHeight: 100,
                  maxHeight: 100,
                  child: Lottie.asset(
                    'assets/animation/running3.json',
                    repeat: true,
                  ),
                ),
              ),
            )
          : ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbColor:
                    MaterialStateProperty.all(Colors.blue), // change as needed
                trackColor: MaterialStateProperty.all(Colors.grey.shade700),
                trackBorderColor: MaterialStateProperty.all(Colors.transparent),
                radius: const Radius.circular(8),
                thickness: MaterialStateProperty.all(3),
              ),
              child: Scrollbar(
                controller: horizontalController,
                thumbVisibility: true, // Always show scrollbar on desktop
                trackVisibility: true,
                notificationPredicate: (notification) =>
                    notification.depth == 0,
                child: SingleChildScrollView(
                  controller: horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      _buildColumnsCustom(),
                      Expanded(
                        child: Scrollbar(
                          controller: verticalController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          child: SingleChildScrollView(
                            controller: verticalController,
                            scrollDirection: Axis.vertical,
                            child: _buildColumnsBodyCustom(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class CustomColumnHeader extends StatelessWidget {
  final String title;
  final List<String> headers;

  const CustomColumnHeader({
    Key? key,
    required this.title,
    required this.headers,
  }) : super(key: key);

  TextStyle _headerTextStyle() {
    return const TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.w400,
      fontSize: 15,
    );
  }

  TextStyle _headerHeadTextStyle() {
    return const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w400,
      fontSize: 15,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: (columnWidth * headers.length) + 2,
      // padding: EdgeInsets.symmetric(vertical: 12),
      width: 300,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey),
        ),
      ),
      child: Column(
        children: [
          Text(title, style: _headerHeadTextStyle()),
          const SizedBox(height: 20),
          Row(
            children: headers.map((header) {
              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  // width: columnWidth,
                  child: Text(
                    header,
                    textAlign: TextAlign.center,
                    style: _headerTextStyle(),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class CustomColumnHeaderBody extends StatelessWidget {
  final List<String> headers;
  final VoidCallback? onTap;

  const CustomColumnHeaderBody({
    Key? key,
    required this.headers,
    required this.onTap,
  }) : super(key: key);

  TextStyle _headerHeadTextStyle() {
    return const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w400,
      fontSize: 14,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        // width: (columnWidth * headers.length) + 2,
        width: 300,
        height: 73,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Row(
          children: headers.map((header) {
            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                    // border: Border.all(color: Colors.black),
                    ),
                child: Text(
                  header,
                  textAlign: TextAlign.center,
                  style: _headerHeadTextStyle(),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
