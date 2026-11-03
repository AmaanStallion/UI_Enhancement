import 'package:stallion/ui/views/accountmanagement/account_management_preview_network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_po_new.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/ui/views/accountmanagement/account_dashboard/account_dashboard.dart';
import 'package:stallion/ui/views/accountmanagement/payment_request.dart';
import 'package:stallion/ui/views/accountmanagement/paymentdue/paymentduelist.dart';
import 'package:stallion/ui/views/accountmanagement/paymentdue/track_account_management.dart';
import 'package:stallion/ui/views/accountmanagement/porequested.dart';
import 'package:stallion/ui/views/accountmanagement/worequested.dart';
import '../../../models/get_project_account_management.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../../utils/responsive.dart';
import '../../shared/ui_helpers.dart';
import 'account_management_preview.dart';

class AccountManagementView extends StatefulWidget {
  AccountManagementView(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.towarName,
      this.navigationFlag});

  final String? projectId;
  String? towarId;
  String? projectName;
  String? navigationFlag;
  String? towarName;
  @override
  State<AccountManagementView> createState() => _AccountManagementViewState();
}

class _AccountManagementViewState extends State<AccountManagementView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = AccountManagementPreviewNetwork();
  bool flagcalled = false;
  String? strPoVerified = '';
  String? strPoAssigned = '';
  String? strPoIssued = '';
  String? strWoVerified = '';
  String? strWoAssigned = '';
  String? strWoIssued = '';
  String? strPaymentRequested = '';
  String? strPaymentApproved = '';
  String? strPaymentDue = '';
  String? strPaymentOverdue = '';
  String? showAccounts = '';
  String? strTowarName = "All Tower";
  List<TowarList>? towarLists = [];
  List<Vendor>? vendorDueList = [];
  List<Vendor>? vendorOverDue = [];

  void _loadTestData() {
    setState(() {
      strPoVerified = accountManagementTestData['poRequested'];
      strPoAssigned = accountManagementTestData['poAssigned'];
      strPoIssued = accountManagementTestData['poIssued'];
      strWoVerified = accountManagementTestData['woRequested'];
      strWoAssigned = accountManagementTestData['woAssigned'];
      strWoIssued = accountManagementTestData['woIssued'];
      strPaymentRequested = accountManagementTestData['paymentRequested'];
      strPaymentApproved = accountManagementTestData['paymentApproved'];
      strPaymentDue = accountManagementTestData['paymentDue'];
      strPaymentOverdue = accountManagementTestData['paymentOverdue'];
      showAccounts = '1';
      towarLists = [
        TowarList(towarId: '', towarName: 'All Tower'),
        if (widget.towarId?.isNotEmpty == true)
          TowarList(
            towarId: widget.towarId,
            towarName: widget.towarName?.isNotEmpty == true
                ? widget.towarName
                : 'Current Tower',
          ),
      ];
      strTowarName = towarLists!
          .firstWhere((tower) => tower.towarId == (widget.towarId ?? ''),
              orElse: () => towarLists!.first)
          .towarName;
      flagcalled = true;
    });
  }

  Future<ResponseGetProjectAccountManagement?>
      fetchProjectAccountManagment() async {
    if (useAccountManagementTestData) {
      _loadTestData();
      return null;
    }
    // fetchProjectAccountManagmentDueOverdue();
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    // String towerId = "";
    // if (widget.towarId != null) {
    //   towerId = widget.towarId ?? '';
    // }

    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.getprojectaccountmanagment, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getProjectAccountManagementFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        //return dataModel.response;
        setState(() {
          flagcalled = true;
          strPoVerified = '${dataModel.response?.poPending}';
          strPoAssigned = '${dataModel.response?.poAssing}';
          strPoIssued = '${dataModel.response?.poIssued}';
          strWoVerified = '${dataModel.response?.woRaise}';
          strWoAssigned = '${dataModel.response?.woGenerated}';
          strWoIssued = '${dataModel.response?.woIssued}';
          strPaymentRequested = '${dataModel.response?.paymentRequest}';
          strPaymentApproved = '${dataModel.response?.paymentApproved}';
          showAccounts = '${dataModel.response?.showAccounts}';
          if (widget.navigationFlag == 'Project') {
            towarLists = [];
            var arrTowar = dataModel.response?.towarList;
            if (arrTowar?.length != 0) {
              towarLists?.add(TowarList(towarId: "", towarName: "All Tower"));
              if (towarLists?.length != 0) {
                for (int i = 0; i < arrTowar!.length; i++) {
                  if (arrTowar[i].towarId == widget.towarId) {
                    strTowarName = arrTowar[i].towarName;
                  }
                  towarLists?.add(arrTowar[i]);
                }
              }
            }
          }
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

  Future<ResponseGetProjectAccountManagement?>
      fetchProjectAccountManagmentDueOverdue() async {
    if (useAccountManagementTestData) {
      _loadTestData();
      return null;
    }
    final SharedPreferences prefs = await _prefs;
    String? userId = (prefs.getString('mobileNo') ??
        (useAccountManagementTestData ? '1' : null));

    // String towerId = "";
    // if (widget.towarId != null) {
    //   towerId = widget.towarId ?? '';
    // }

    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(
        AppUrl.getprojectaccountmanagmentdueoverdue, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getProjectAccountManagementNewFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        //return dataModel.response;
        setState(() {
          flagcalled = true;
          strPaymentDue = '${dataModel.response?.paymentDue}';
          strPaymentOverdue = '${dataModel.response?.paymentOverdue}';
          vendorDueList = dataModel.response?.vendorDueList;
          vendorOverDue = dataModel.response?.vendorOverDue;
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
    fetchProjectAccountManagment();
    fetchProjectAccountManagmentDueOverdue();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            widget.towarName == ""
                ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                : widget.projectName!.toUpperCase(),
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: widget.navigationFlag! == 'SideMenu'
            ? const SizedBox()
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.maybePop(context);
                },
              ),
        actions: [
          if (widget.navigationFlag == 'Project')
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) {
                    return AccountDashboard(
                      projectId: widget.projectId,
                      projectName: widget.projectName,
                      towarId: widget.towarId,
                      towarName: widget.towarName,
                    );
                  },
                ));
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: isMobile ? 4 : 0, vertical: 12),
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 18),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    "Overview",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          if (widget.navigationFlag! != 'SideMenu')
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) {
                    return TrackAccountManagement(
                      projectId: widget.projectId,
                      projectName: widget.projectName,
                      towarId: widget.towarId,
                      towarName: widget.towarName,
                    );
                  },
                ));
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 20, vertical: 12),
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 18),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    "Track",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: showAccounts == '1'
          ? Container(
              color: Colors.white,
              height: 102,
              child: Column(
                children: [
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 1,
                    endIndent: 1,
                    color: Color(0xffe9ecef),
                  ),
                  SizedBox(
                    height: 50,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: isMobile ? 12.0 : 40.0,
                          right: isMobile ? 12.0 : 40.0),
                      child: InkWell(
                        onTap: () {
                          var projectId = widget.projectId!;
                          var projectName = widget.projectName!;
                          // if (vendorDueList?.length != 0) {
                          if (strPaymentDue != "") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return PaymentDueList(
                                      projectId: projectId,
                                      towarId: widget.towarId!,
                                      projectName: projectName,
                                      flagRedirect: 'PaymentDue',
                                      // data1: vendorDueList,
                                      totalDue: strPaymentDue ?? '0',
                                      dueType: '0');
                                },
                              ),
                            ).then((_) {
                              setState(() {
                                flagcalled == false;
                              });
                              fetchProjectAccountManagment();
                            });
                          }
                          // }
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              iconSize: isMobile ? 24 : 30,
                              icon: const Icon(
                                Icons.account_balance_outlined,
                              ),
                              color: Colors.black,
                              onPressed: () {},
                            ),
                            isMobile
                                ? horizontalSpaceSmall
                                : horizontalSpaceMedium,
                            Text('Payment Due :',
                                style: TextStyle(
                                    backgroundColor: Colors.white,
                                    fontSize: isMobile ? 13 : 15,
                                    color: Colors.black)),
                            const Spacer(),
                            strPaymentDue == ''
                                ? Row(
                                    children: [
                                      Text('Calculating',
                                          style: TextStyle(
                                              backgroundColor: Colors.white,
                                              fontSize: isMobile ? 13 : 15,
                                              color: Colors.black)),
                                      horizontalSpaceSmall,
                                      LoadingAnimationWidget.progressiveDots(
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                    ],
                                  )
                                : Flexible(
                                    fit: FlexFit.tight,
                                    child: Text(
                                        currencyFormat.format(
                                            double.parse(strPaymentDue ?? '')),
                                        textAlign: TextAlign.right,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                            backgroundColor: Colors.white,
                                            fontSize: isMobile ? 13 : 15,
                                            color: Colors.black)),
                                  ),
                            IconButton(
                              iconSize: isMobile ? 24 : 30,
                              icon: const Icon(
                                Icons.keyboard_arrow_right_rounded,
                              ),
                              color: Colors.black,
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 1,
                    endIndent: 1,
                    color: Color(0xffe9ecef),
                  ),
                  SizedBox(
                    height: 50,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: isMobile ? 12.0 : 40.0,
                          right: isMobile ? 12.0 : 40.0),
                      child: InkWell(
                        onTap: () {
                          var projectId = widget.projectId!;
                          var projectName = widget.projectName!;
                          // if (vendorOverDue?.length != 0) {
                          if (strPaymentOverdue != "") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return PaymentDueList(
                                      projectId: projectId,
                                      towarId: widget.towarId!,
                                      projectName: projectName,
                                      flagRedirect: 'PaymentOverDue',
                                      // data1: vendorOverDue,
                                      totalDue: strPaymentOverdue ?? '0',
                                      dueType: '1');
                                },
                              ),
                            ).then((_) {
                              setState(() {
                                flagcalled == false;
                              });
                              fetchProjectAccountManagment();
                            });
                            // }
                          }
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              iconSize: isMobile ? 24 : 30,
                              icon: const Icon(
                                Icons.gpp_maybe_outlined,
                              ),
                              color: Colors.black,
                              onPressed: () {},
                            ),
                            isMobile
                                ? horizontalSpaceSmall
                                : horizontalSpaceMedium,
                            Text('Payment Overdue :',
                                style: TextStyle(
                                    backgroundColor: Colors.white,
                                    fontSize: isMobile ? 13 : 15,
                                    color: Colors.black)),
                            const Spacer(),
                            strPaymentOverdue == ''
                                ? Row(
                                    children: [
                                      Text('Calculating',
                                          style: TextStyle(
                                              backgroundColor: Colors.white,
                                              fontSize: isMobile ? 13 : 15,
                                              color: Colors.black)),
                                      horizontalSpaceSmall,
                                      LoadingAnimationWidget.progressiveDots(
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                    ],
                                  )
                                : Flexible(
                                    fit: FlexFit.tight,
                                    child: Text(
                                        currencyFormat.format(double.parse(
                                            strPaymentOverdue ?? '')),
                                        textAlign: TextAlign.right,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                            backgroundColor: Colors.white,
                                            fontSize: isMobile ? 13 : 15,
                                            color: Colors.black)),
                                  ),
                            IconButton(
                              iconSize: isMobile ? 24 : 30,
                              icon: const Icon(
                                Icons.keyboard_arrow_right_rounded,
                              ),
                              color: Colors.black,
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox(),
      body: Container(
        child: flagcalled == true
            ? Builder(builder: (context) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                          height: 40,
                          child: Center(
                              child: Text('ACCOUNT MANAGEMENT',
                                  style: TextStyle(
                                      fontSize: 14,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center))),
                      const Divider(height: 1.0, color: Color(0xffe9ecef)),
                      widget.navigationFlag != 'SideMenu'
                          ? towarLists?.length != 0
                              ? InkWell(
                                  onTap: _showTowerSelector,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(strTowarName?.toUpperCase() ?? '',
                                          style: const TextStyle(
                                              fontStyle: FontStyle.normal,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13.0)),
                                      horizontalSpaceSmall,
                                      IconButton(
                                        icon: const Icon(Icons.arrow_drop_down,
                                            color: Colors.black),
                                        onPressed: _showTowerSelector,
                                        tooltip: 'Select tower',
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox()
                          : const SizedBox(),
                      const Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 1,
                        endIndent: 1,
                        color: Color(0xffe9ecef),
                      ),
                      _statusSection(
                          isMobile,
                          'PURCHASE ORDER STATUS',
                          Icons.receipt_long_outlined,
                          _poorderstatus(isMobile)),
                      _statusSection(
                          isMobile,
                          'WORK ORDER STATUS',
                          Icons.assignment_outlined,
                          _workorderstatus(isMobile)),
                      _statusSection(
                          isMobile,
                          'PAYMENT STATUS',
                          Icons.account_balance_wallet_outlined,
                          _paymentstatus(isMobile)),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              })
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
      ),
    );
  }

  void _showTowerSelector() {
    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 400,
          height: (MediaQuery.of(dialogContext).size.height * 0.7)
              .clamp(220.0, 420.0)
              .toDouble(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: const Text(
                  'SELECT TOWER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'HelveticaNeue',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: towarLists?.length ?? 0,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final tower = towarLists![index];
                    final selected = widget.towarId == tower.towarId;
                    return Material(
                      color: selected ? const Color(0xfff8f9fa) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: selected
                              ? const Color(0xffd6d6d6)
                              : const Color(0xffe9ecef),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          widget.towarId = tower.towarId!;
                          setState(() {
                            strTowarName = tower.towarName!;
                          });
                          fetchProjectAccountManagment();
                          Navigator.of(dialogContext).pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  tower.towarName ?? '',
                                  style: TextStyle(
                                    fontFamily: 'HelveticaNeue',
                                    fontSize: 14,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                  selected
                                      ? Icons.check_circle_rounded
                                      : Icons.circle_outlined,
                                  color: selected ? Colors.green : Colors.grey,
                                  size: 22),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('OK',
                        style: TextStyle(
                            fontFamily: 'HelveticaNeue',
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusSection(
      bool isMobile, String title, IconData icon, Widget content) {
    return Container(
      width: double.infinity,
      margin:
          EdgeInsets.fromLTRB(isMobile ? 12 : 40, 16, isMobile ? 12 : 40, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffe9ecef)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x04000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xffe9ecef),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.black),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'HelveticaNeue',
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xfff0f0f0)),
          content,
        ],
      ),
    );
  }

  Widget _statusTile(bool isMobile, String label, String count) {
    return _StatusTileHover(
      child: Container(
        width: isMobile ? (MediaQuery.of(context).size.width - 72) / 3 : 180,
        constraints: const BoxConstraints(minHeight: 96),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xfff8f9fa),
          border: Border.all(color: const Color(0xffe9ecef)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count,
              style: TextStyle(
                fontFamily: 'HelveticaNeue',
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'HelveticaNeue',
                fontSize: isMobile ? 11 : 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _poorderstatus(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding:
              EdgeInsets.only(left: 12.0, right: 12.0, top: 14.0, bottom: 16.0),
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.0,
            runSpacing: 12.0,
            children: [
              InkWell(
                onTap: () {
                  var projectId =
                      widget.projectId! == '' ? "" : widget.projectId!;
                  var projectName =
                      widget.projectName! == '' ? "" : widget.projectName!;
                  // Navigator.push(context, MaterialPageRoute(builder: (_) {
                  //   return PoRequestedView(
                  //       towarName: widget.towarName,
                  //       assignToId: '',
                  //       projectId: projectId,
                  //       towarId: widget.towarId!,
                  //       projectName: projectName,
                  //       flagRedirect: 'Verified');
                  // }))
                  Navigator.of(context)
                      .pushNamed(
                    '/poRequestedViewScreen',
                    arguments: NotificationArgs(
                      projectId: projectId,
                      projectName: projectName,
                      towarName: widget.towarName,
                      response: NotificationResponseData(
                        assignToId: '',
                        flagRedirect: 'Verified',
                        towarId: widget.towarId,
                      ),
                    ),
                  )
                      .then((_) {
                    setState(() {
                      flagcalled == false;
                    });
                    fetchProjectAccountManagment();
                  });
                },
                child: _statusTile(isMobile, 'Verified', '$strPoVerified'),
              ),
              InkWell(
                onTap: () {
                  var projectId =
                      widget.projectId! == '' ? "" : widget.projectId!;
                  var projectName =
                      widget.projectName! == '' ? "" : widget.projectName!;
                  // Navigator.push(context, MaterialPageRoute(builder: (_) {
                  //   return PoRequestedView(
                  //       towarName: widget.towarName,
                  //       assignToId: '',
                  //       projectId: projectId,
                  //       towarId: widget.towarId!,
                  //       projectName: projectName,
                  //       flagRedirect: 'Assigned');
                  // }))
                  Navigator.of(context)
                      .pushNamed(
                    '/poRequestedViewScreen',
                    arguments: NotificationArgs(
                      projectId: projectId,
                      projectName: projectName,
                      towarName: widget.towarName,
                      response: NotificationResponseData(
                        assignToId: '',
                        flagRedirect: 'Assigned',
                        towarId: widget.towarId,
                      ),
                    ),
                  )
                      .then((_) {
                    setState(() {
                      flagcalled == false;
                    });
                    fetchProjectAccountManagment();
                  });
                },
                child: _statusTile(isMobile, 'Assigned', '$strPoAssigned'),
              ),
              InkWell(
                onTap: () {
                  var projectId =
                      widget.projectId! == '' ? "" : widget.projectId!;
                  var projectName =
                      widget.projectName! == '' ? "" : widget.projectName!;
                  // Navigator.push(context, MaterialPageRoute(builder: (_) {
                  //   return PoRequestedView(
                  //       towarName: widget.towarName,
                  //       projectId: projectId,
                  //       towarId: widget.towarId!,
                  //       projectName: projectName,
                  //       assignToId: '',
                  //       flagRedirect: 'Issued');
                  // }))
                  Navigator.of(context)
                      .pushNamed(
                    '/poRequestedViewScreen',
                    arguments: NotificationArgs(
                      projectId: projectId,
                      projectName: projectName,
                      towarName: widget.towarName,
                      response: NotificationResponseData(
                        assignToId: '',
                        flagRedirect: 'Issued',
                        towarId: widget.towarId,
                      ),
                    ),
                  )
                      .then((_) {
                    setState(() {
                      flagcalled == false;
                    });
                    fetchProjectAccountManagment();
                  });
                },
                child: _statusTile(isMobile, 'Issued', '$strPoIssued'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _workorderstatus(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding:
              EdgeInsets.only(left: 12.0, right: 12.0, top: 14.0, bottom: 16.0),
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.0,
            runSpacing: 12.0,
            children: [
              InkWell(
                onTap: () {
                  // var projectId = widget.projectId!;
                  // var projectName = widget.projectName!;
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) {
                  //       return WoRequestedView(
                  //           assignToId: '',
                  //           projectId: projectId,
                  //           towarId: widget.towarId!,
                  //           projectName: projectName,
                  //           flagRedirect: 'Requested');
                  //     },
                  //   ),
                  // )
                  Navigator.of(context)
                      .pushNamed(
                    '/woRequestedViewScreen',
                    arguments: NotificationArgs(
                      projectId: widget.projectId,
                      projectName: widget.projectName,
                      towarName: widget.towarName,
                      response: NotificationResponseData(
                        assignToId: '',
                        flagRedirect: 'Requested',
                        towarId: widget.towarId,
                      ),
                    ),
                  )
                      .then((_) {
                    setState(() {
                      flagcalled == false;
                    });
                    fetchProjectAccountManagment();
                  });
                },
                child: _statusTile(isMobile, 'Requested', '$strWoVerified'),
              ),
              InkWell(
                onTap: () {
                  // var projectId = widget.projectId!;
                  // var projectName = widget.projectName!;
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) {
                  //       return WoRequestedView(
                  //           assignToId: '',
                  //           projectId: projectId,
                  //           towarId: widget.towarId!,
                  //           projectName: projectName,
                  //           flagRedirect: 'Assigned');
                  //     },
                  //   ),
                  // )
                  Navigator.of(context)
                      .pushNamed(
                    '/woRequestedViewScreen',
                    arguments: NotificationArgs(
                      projectId: widget.projectId,
                      projectName: widget.projectName,
                      towarName: widget.towarName,
                      response: NotificationResponseData(
                        assignToId: '',
                        flagRedirect: 'Assigned',
                        towarId: widget.towarId,
                      ),
                    ),
                  )
                      .then((_) {
                    setState(() {
                      flagcalled == false;
                    });
                    fetchProjectAccountManagment();
                  });
                },
                child: _statusTile(isMobile, 'Assigned', '$strWoAssigned'),
              ),
              InkWell(
                onTap: () {
                  // var projectId = widget.projectId!;
                  // var projectName = widget.projectName!;
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) {
                  //       return WoRequestedView(
                  //           assignToId: '',
                  //           projectId: projectId,
                  //           towarId: widget.towarId!,
                  //           projectName: projectName,
                  //           flagRedirect: 'Issued');
                  //     },
                  //   ),
                  // )
                  Navigator.of(context)
                      .pushNamed(
                    '/woRequestedViewScreen',
                    arguments: NotificationArgs(
                      projectId: widget.projectId,
                      projectName: widget.projectName,
                      towarName: widget.towarName,
                      response: NotificationResponseData(
                        assignToId: '',
                        flagRedirect: 'Issued',
                        towarId: widget.towarId,
                      ),
                    ),
                  )
                      .then((_) {
                    setState(() {
                      flagcalled == false;
                    });
                    fetchProjectAccountManagment();
                  });
                },
                child: _statusTile(isMobile, 'Issued', '$strWoIssued'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _paymentstatus(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding:
              EdgeInsets.only(left: 12.0, right: 12.0, top: 14.0, bottom: 16.0),
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.0,
            runSpacing: 12.0,
            children: [
              InkWell(
                onTap: () {
                  var projectId = widget.projectId!;
                  var projectName = widget.projectName!;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return PaymentRequestedView(
                            projectId: projectId,
                            towarId: widget.towarId!,
                            projectName: projectName,
                            flagRedirect: 'Requested');
                      },
                    ),
                  ).then((_) {
                    setState(() {
                      flagcalled == false;
                    });
                    fetchProjectAccountManagment();
                  });
                },
                child:
                    _statusTile(isMobile, 'Requested', '$strPaymentRequested'),
              ),
              InkWell(
                onTap: () {
                  var projectId = widget.projectId!;
                  var projectName = widget.projectName!;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return PaymentRequestedView(
                            projectId: projectId,
                            towarId: widget.towarId!,
                            projectName: projectName,
                            flagRedirect: 'Approved');
                      },
                    ),
                  ).then((_) {
                    setState(() {
                      flagcalled == false;
                    });
                    fetchProjectAccountManagment();
                  });
                },
                child: _statusTile(isMobile, 'Approved', '$strPaymentApproved'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Presentation-only wrapper: taps continue to reach the existing InkWell.
class _StatusTileHover extends StatefulWidget {
  const _StatusTileHover({required this.child});

  final Widget child;

  @override
  State<_StatusTileHover> createState() => _StatusTileHoverState();
}

class _StatusTileHoverState extends State<_StatusTileHover> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final raised = _hovered && !reduceMotion;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration:
            reduceMotion ? Duration.zero : const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transformAlignment: Alignment.center,
        transform: raised
            ? (Matrix4.translationValues(0, -4, 0)
              ..setEntry(3, 2, 0.001)
              ..rotateX(0.035)
              ..rotateY(-0.02))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color:
                  _hovered ? const Color(0x26000000) : const Color(0x12000000),
              blurRadius: _hovered ? 18 : 8,
              offset: Offset(0, _hovered ? 9 : 3),
            ),
            const BoxShadow(
              color: Color(0x08000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
