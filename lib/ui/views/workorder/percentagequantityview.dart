import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/workorder/Percentage/requestworkorderconsultant.dart';
import 'package:stallion/ui/views/workorder/quantity/quantitywoconsultantview.dart';
import 'package:stallion/ui/views/workorder/quantity/quantitywoview.dart';

class PercentageQuantityView extends StatefulWidget {
  const PercentageQuantityView(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.consultantMagicLink,
      this.contractorMagicLink,
      this.vendMagicLink,
      this.towarName,
      this.navigationFlag});

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? navigationFlag;
  final String? contractorMagicLink;
  final String? vendMagicLink;
  final String? consultantMagicLink;
  final String? towarName; 

  @override
  _PercentageQuantityViewState createState() => _PercentageQuantityViewState();
}

class _PercentageQuantityViewState extends State<PercentageQuantityView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(5, 10, 5, 10),
              child: Text(
                'REQUEST WORK ORDER',
                style: boldText13,
              ),
            ),
            const Divider(
              height: 1,
              thickness: 0.5,
              indent: 1,
              endIndent: 1,
              color: Colors.black,
            ),
            const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(5, 10, 5, 10),
              child: Text(
                'Create Work Order Via',
                style: boldText,
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(25, 10, 25, 10),
              child: Material(
                color: Colors.transparent,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: 500,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                      )
                    ],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      var projectId = widget.projectId!;
                      var projectName = widget.projectName!;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return RequestWorkOrderConsultant(
                              towarName: widget.towarName,
                              projectId: projectId,
                              towarId: widget.towarId!,
                              projectName: projectName,
                              navigationFlag: widget.navigationFlag!,
                              consultantMagicLink: widget.consultantMagicLink,
                              contractorMagicLink: widget.contractorMagicLink,
                              vendMagicLink: widget.vendMagicLink,
                            );
                          },
                        ),
                      ).then((value) => {checkNavigation()});
                    },
                    child: const Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(25, 10, 25, 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                            child: Text(
                              'PERCENTAGE',
                              textAlign: TextAlign.center,
                              style: boldText,
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(15, 10, 15, 20),
                            child: Text(
                              'Used for long-term contracts which are calculated \nas per percentage of work done.',
                              textAlign: TextAlign.center,
                              style: normalText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(5, 10, 5, 10),
              child: Text(
                'OR',
                style: boldText13,
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(25, 10, 25, 10),
              child: Material(
                color: Colors.transparent,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: 500,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(25, 10, 25, 10),
                    child: InkWell(
                      onTap: () {
                        var projectId = widget.projectId!;
                        var projectName = widget.projectName!;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              if (widget.navigationFlag! == "Consultant") {
                                return QuantityWoConsultantView(
                                  projectId: projectId,
                                  towarName: widget.towarName,
                                  towarId: widget.towarId!,
                                  projectName: projectName,
                                  navigationFlag: widget.navigationFlag!,
                                  consultantMagicLink:
                                      widget.consultantMagicLink,
                                  contractorMagicLink:
                                      widget.contractorMagicLink,
                                  vendMagicLink: widget.vendMagicLink,
                                );
                              } else {
                                return QuantityWoView(
                                  towarName: widget.towarName,
                                  projectId: projectId,
                                  towarId: widget.towarId!,
                                  projectName: projectName,
                                  navigationFlag: widget.navigationFlag!,
                                  consultantMagicLink:
                                      widget.consultantMagicLink,
                                  contractorMagicLink:
                                      widget.contractorMagicLink,
                                  vendMagicLink: widget.vendMagicLink,
                                );
                              }
                            },
                          ),
                        ).then((value) => {checkNavigation()});
                      },
                      child: const Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                            child: Text(
                              'QUANTITY',
                              textAlign: TextAlign.center,
                              style: boldText,
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(15, 10, 15, 20),
                            child: Text(
                              'Used for contracts which are based on\nspecific tasks.',
                              textAlign: TextAlign.center,
                              style: normalText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkNavigation() async {
    final SharedPreferences prefs = await _prefs;
    String? flagRedirect = prefs.getString('flagRedirectToWorkProgress');
    if (flagRedirect == 'true') {
      backToScreen();
    }
  }

  void backToScreen() {
    Navigator.maybePop(context);
  }
}
