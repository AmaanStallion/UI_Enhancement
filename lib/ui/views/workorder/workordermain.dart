import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/workorder/percentagequantityview.dart';

class WorkOrderWidget extends StatefulWidget {
  const WorkOrderWidget(
      {Key? key,
      this.projectId,
      this.towarId,
      this.consultantMagicLink,
      this.contractorMagicLink,
      this.vendMagicLink,
      this.projectName,
      this.towarName});

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? contractorMagicLink;
  final String? vendMagicLink;
  final String? consultantMagicLink; 

  @override
  _WorkOrderWidgetState createState() => _WorkOrderWidgetState();
}

class _WorkOrderWidgetState extends State<WorkOrderWidget> {
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
                'Create Work Order For',
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
                            return PercentageQuantityView(
                                towarName: widget.towarName,
                                consultantMagicLink: widget.consultantMagicLink,
                                contractorMagicLink: widget.contractorMagicLink,
                                vendMagicLink: widget.vendMagicLink,
                                projectId: projectId,
                                towarId: widget.towarId!,
                                projectName: projectName,
                                navigationFlag: 'Consultant');
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
                              'CONSULTANT',
                              textAlign: TextAlign.center,
                              style: boldText,
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(15, 10, 15, 20),
                            child: Text(
                              'Consultant is a company/person who offers \nservices of professional and technical advice.',
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
                              return PercentageQuantityView(
                                  towarName: widget.towarName,
                                  consultantMagicLink:
                                      widget.consultantMagicLink,
                                  contractorMagicLink:
                                      widget.contractorMagicLink,
                                  vendMagicLink: widget.vendMagicLink,
                                  projectId: projectId,
                                  towarId: widget.towarId!,
                                  projectName: projectName,
                                  navigationFlag: 'Contractor');
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
                              'CONTRACTOR',
                              textAlign: TextAlign.center,
                              style: boldText,
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(15, 10, 15, 20),
                            child: Text(
                              'Contractor is a company/person who takes a\ncontract as per scope of work.',
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
