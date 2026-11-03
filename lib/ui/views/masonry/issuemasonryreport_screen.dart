import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_masonry_issue_report.dart';
import 'package:stallion/models/get_project_management.dart';
import 'package:stallion/models/get_project_masonry.dart';
import 'package:stallion/models/get_rccissuereport_data.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../models/get_rccissuereport_dropdown.dart';
import '../../widgets/simple_button.dart';

// class IssueMasonryReport extends StatefulWidget {
//   const IssueMasonryReport(
//       {Key? key,
//       required this.drawingTitle,
//       required this.drawingId,
//       this.projectId,
//       this.towarId,
//       this.projectName,
//       this.slabcheckid,
//       this.slabchecktype,
//       this.masonryId,
//       this.headId,
//       // this.plist,
//       this.checkId,
//       this.checkType,
//       this.slabid})
//       : super(key: key);
//   final String? projectId;
//   final String? towarId;
//   final String? projectName;
//   final String? slabcheckid;
//   final String? slabchecktype;
//   final String? slabid;
//   final String drawingTitle;
//   final String drawingId;
//   // final InnerBlock? plist;
//   final String? headId;
//   final String? checkId;
//   final String? masonryId;
//   final String? checkType;
//   @override
//   _IssueRccReportState createState() => _IssueRccReportState();
// }
class IssueMasonryReport extends StatefulWidget {
  const IssueMasonryReport({super.key});

  @override
  State<IssueMasonryReport> createState() => _IssueRccReportState();
}

class _IssueRccReportState extends State<IssueMasonryReport> {
  late NotificationArgs args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context)!.settings.arguments as NotificationArgs;
  }

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool circular = false;
  bool dropdownFlag = false;
  List<IssueIn>? arrIssueIn;
  List<ReportTo>? arrReportTo;
  List<AddIssue> datIssueController = [
    AddIssue(
      issueTextEditingController: TextEditingController(),
      selectReportingToStrings: "",
      selectReportingToController: TextEditingController(),
    ),
  ];

  @override
  void initState() {
    super.initState();

    arrIssueIn = [];
    arrReportTo = [];
    fetchRccStructureDropDownIssueReportRequest();
  }

  Future<List<SlabIssueReport>?> setIssueResolved({
    required String slab_issue_id,
    required MasonryIssueReport plistData,
  }) async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId!,
      "slab_issue_id": slab_issue_id,
      "change_type": "1",
      // "slab_check_id": widget.slabcheckid!,
      // "slab_check_type": widget.slabchecktype!,
      // "slab_id": widget.slabid!
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(AppUrl.setSlabIssueSolve, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      fetchRccStructureDropDownIssueReportRequest();
      Navigator.of(context).pop();
    } else {}
  }

  Future<List<MasonryIssueReport>?>
      fetchRccStructureIssueReportRequest() async {
    setState(() {
      circular = true;
    });

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      // "user_id": userId!,
      // "slab_check_id": widget.slabcheckid!,
      // "slab_check_type": widget.slabchecktype!,
      // "slab_id": widget.slabid!
      "user_id": userId ?? '',
      "head_id": args.response?.headId?.trim() == null ||
              args.response?.headId?.trim() == ''
          ? '0'
          : args.response?.headId?.trim() ?? '',
      "masonry_id": args.response?.masonryId ?? '',
      "check_id": args.response?.drawingId ?? '',
      "check_type": args.response?.checkType ?? '',
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.getMasonryIssueReportRequest, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getMasonryIssueReportFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        List<MasonryIssueReport>? list =
            dataModel.response?.masonryIssueReport!;
        return list;
      } else {
        List<MasonryIssueReport>? list = [];
        return list;
      }
    } else {
      List<MasonryIssueReport>? list = [];
      return list;
    }
  }

  Future<List<ReportTo>?> fetchRccStructureDropDownIssueReportRequest() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": args.projectId ?? '',
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(
        AppUrl.getRccStructureDropDownIssueReportRequest, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = rccIssueReportDropdownDataFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response.errorCode == "0") {
        setState(() {
          arrReportTo = dataModel.response.reportTo;
          dropdownFlag = true;
        });
        return arrReportTo;
      } else {
        arrReportTo = [];
        return arrReportTo;
      }
    } else {
      arrReportTo = [];
      return arrReportTo;
    }
  }

  setSlabReport() async {
    var request = http.MultipartRequest(
        'POST', Uri.parse(AppUrl.wsMasonrySlabIssueReport));

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
    });

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    request.fields['user_id'] = userId!;
    request.fields['masonry_id'] = args.response?.masonryId ?? '';
    request.fields['check_id'] = args.response?.drawingId ?? '';
    request.fields['head_id'] = args.response?.headId ?? '';
    request.fields['extra_comment'] = '';
    request.fields['check_type'] = args.response?.checkType ?? '';
    List dict = [];
    for (int k = 0; k < datIssueController.length; k++) {
      var temp = {
        "issue_in": args.response?.drawingId,
        "report_to": datIssueController[k].selectReportingToStrings,
        "remarks": datIssueController[k].issueTextEditingController.text,
      };
      dict.add(temp);
    }

    for (int i = 0; i < datIssueController.length; i++) {
      if (datIssueController[i].arrayFiles != null &&
          datIssueController[i].arrayFiles?.extension != "mp4") {
        PlatformFile file = datIssueController[i].arrayFiles!;
        request.files.add(await http.MultipartFile.fromPath(
          "issue_image$i[]",
          file.path.toString(),
          contentType: MediaType('application/pdf', file.extension ?? ""),
        ));
      } else if (datIssueController[i].arrayFiles != null &&
          datIssueController[i].arrayFiles?.extension == "mp4") {
        PlatformFile file = datIssueController[i].arrayFiles!;
        request.files.add(await http.MultipartFile.fromPath(
          "issue_vedio$i[]",
          file.path.toString(),
          contentType: MediaType('application/pdf', file.extension ?? ""),
        ));
      }
    }
    request.fields['report_issue'] = jsonEncode(dict);
    var response = await request.send();

    var responsed = await http.Response.fromStream(response);
    final responseData = json.decode(responsed.body);

    if (response.statusCode == 200) {
      return null;
    } else {
      print("ERROR");
    }
  }

  @override
  Widget build(BuildContext context1) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('${args.projectName!.toUpperCase()}',
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
        color: Colors.white,
        child: FutureBuilder<List<MasonryIssueReport>?>(
            future: fetchRccStructureIssueReportRequest(),
            builder: (BuildContext context1, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (kDebugMode) {
                  print("has data");
                }
                return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Container(
                      //   padding: const EdgeInsets.symmetric(vertical: 10),
                      //   width: double.maxFinite,
                      //   decoration: const BoxDecoration(
                      //     color: Colors.black,
                      //   ),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       const SizedBox(width: 200),
                      //       const AppText(
                      //         title: "ISSUE REPORTED",
                      //         fontSize: 16,
                      //         titleColor: Colors.white,
                      //         titleTextAlign: TextAlign.center,
                      //       ),
                      //       InkWell(
                      //         onTap: () {
                      //           setState(() {
                      //             datIssueController.add(
                      //               AddIssue(
                      //                 issueTextEditingController:
                      //                     TextEditingController(),
                      //                 selectReportingToStrings: "",
                      //                 selectReportingToController:
                      //                     TextEditingController(),
                      //               ),
                      //             );
                      //           });
                      //         },
                      //         child: Container(
                      //           margin: const EdgeInsets.only(right: 100),
                      //           decoration: BoxDecoration(
                      //             color: Colors.grey,
                      //             borderRadius: BorderRadius.circular(4),
                      //           ),
                      //           padding: const EdgeInsets.symmetric(
                      //               horizontal: 18, vertical: 4),
                      //           child: const AppText(
                      //             title: "ADD ISSUE",
                      //             fontSize: 16,
                      //             titleColor: Colors.white,
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        width: double.maxFinite,
                        decoration: const BoxDecoration(
                            // color: Colors.black,
                            ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 200),
                            AppText(
                              title: args.response?.drawingTitle ?? '',
                              fontSize: 16,
                              // titleColor: Colors.white,
                              titleTextAlign: TextAlign.center,
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  datIssueController.add(
                                    // AddIssue(
                                    //   issueTextEditingController:
                                    //       TextEditingController(),
                                    //   selectReportingToStrings: "",
                                    //   selectReportingToController:
                                    //       TextEditingController(),
                                    // ),
                                    AddIssue(
                                      issueTextEditingController:
                                          TextEditingController(),
                                      selectReportingToStrings: "",
                                      selectReportingToController:
                                          TextEditingController(),
                                    ),
                                  );
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 100),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 4),
                                child: const AppText(
                                  title: "ADD ISSUE",
                                  fontSize: 16,
                                  titleColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        width: double.maxFinite,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppText(
                              title: "ISSUE REPORTED",
                              fontSize: 16,
                              titleColor: Colors.white,
                              titleTextAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context1, int index) {
                              return RccIssueReportList(
                                  plist: snapshot.data[index]);
                            },
                            itemCount: snapshot.data.length,
                          ),
                          for (int l = 0; l < datIssueController.length; l++)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 5.0,
                                  right: 5.0,
                                  top: 10.0,
                                  bottom: 10.0),
                              child: _returnWidget(
                                ind: l,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                return Center(
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
                );
              }
            }),
      ),
      bottomNavigationBar: InkWell(
        // onTap: () {
        //   // if (_formKey.currentState!.validate()) {
        //   //   setSlabReport();
        //   // }
        // },
        onTap: () {
          // if (_formKey.currentState!.validate()) {
          //   setSlabReport();
          // }
          bool isEmopty = false;
          for (int i = 0; i < datIssueController.length; i++) {
            if (datIssueController[i].selectReportingToController.text == '') {
              setState(() {
                isEmopty = true;
              });
              showDialog<void>(
                  barrierDismissible: true,
                  context: context1,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Set radius to zero
                      ),
                      titlePadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      actionsPadding: const EdgeInsets.only(
                          bottom: 10, left: 10, right: 10),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      actionsAlignment: MainAxisAlignment.center,
                      title: const Text(
                        "Please select Reported to field.",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        InkWell(
                          onTap: () {
                            // Navigator.of(context).pop();

                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 250,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(7)),
                            child: const Text(
                              "Okay",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    );
                  });
              break;
            }
            // else{
            //   setState(() {
            //     isEmopty = false;
            //   });
            // }
          }
          if (!isEmopty) {
            showDialog<void>(
                barrierDismissible: true,
                context: context1,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // Set radius to zero
                    ),
                    titlePadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    actionsPadding:
                        const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    actionsAlignment: MainAxisAlignment.center,
                    title: const Text(
                      "Are you sure you want to submit this issue?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      InkWell(
                        onTap: () {
                          // Navigator.of(context).pop();

                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 150,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(7)),
                          child: const Text(
                            "NO",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          // Navigator.of(context).pop();
                          Future.delayed(Duration(milliseconds: 100), () {
                            CustomLoading.progressDialog(
                                isLoading: true, context: context1);
                          });
                          setSlabReport().then((_) {
                            fetchRccStructureIssueReportRequest();
                            fetchRccStructureDropDownIssueReportRequest();
                            CustomLoading.progressDialog(
                                isLoading: false, context: context1);

                            Future.delayed(Duration(milliseconds: 100), () {
                              showDialog<void>(
                                  barrierDismissible: true,
                                  context: context1,
                                  builder: (context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8), // Set radius to zero
                                      ),
                                      titlePadding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      actionsPadding: const EdgeInsets.only(
                                          bottom: 10, left: 10, right: 10),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      title: const Text(
                                        "You have successfully submitted slab issue report.",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      actions: [
                                        InkWell(
                                          onTap: () {
                                            // Navigator.of(context).pop();

                                            Navigator.of(context).pop();
                                            Navigator.of(context1).pop();
                                          },
                                          child: Container(
                                            width: 250,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            child: const Text(
                                              "Okay",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  });
                            });

                            setState(() {
                              datIssueController = [
                                AddIssue(
                                  issueTextEditingController:
                                      TextEditingController(),
                                  selectReportingToStrings: "",
                                  selectReportingToController:
                                      TextEditingController(),
                                ),
                              ];
                            });
                            if (kDebugMode) {
                              print("SUCCESS");
                            }
                            if (kDebugMode) {}
                          });
                          // Navigator.of(context).pop();
                          // Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 150,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(7)),
                          child: const Text(
                            "YES",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  );
                });
            // setSlabReport();
          }
        },
        child: Container(
            padding: const EdgeInsets.only(top: 7),
            height: 40,
            color: Colors.black,
            child: const Text(
              'SUBMIT',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            )),
      ),
    );
  }

  Widget _returnWidget({
    required int ind,
  }) {
    if (dropdownFlag == true) {
      return AddRccIssueReport(
        arrReport: arrReportTo!,
        index: ind,
      );
    } else {
      return Container();
    }
  }

  Widget _remarks() {
    return const Row(
      children: [
        SizedBox(width: 130, child: Text('Remarks : ', style: boldText13)),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 22.0),
            child: TextField(
              keyboardType: TextInputType.multiline,
              minLines: 1, //Normal textInputField will be displayed
              maxLines: 5, // when user presses enter it will adapt to it
            ),
          ),
        ),
      ],
    );
  }

  Widget RccIssueReportList({required MasonryIssueReport plist}) {
    Widget _imageReport() {
      if (plist.image?.length != 0) {
        return Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // if (plist.issueResolve != "1")
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return ImagePreviewViewer(
                        fileName: '${plist.image?[0]}',
                        fileUrl:
                            '${AppUrl.globalMasonryReportIssuePath}/${plist.image?[0]}',
                      );
                    },
                  ),
                );
              },
              child: SizedBox(
                width: 140,
                height: 140,
                child: Card(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    child: Image(
                      image: NetworkImage(
                        AppUrl.globalMasonryReportIssuePath +
                            (plist.image?[0] ?? ''),
                      ),
                      fit: BoxFit.cover,
                    )),
              ),
            ),
            verticalSpaceMedium,
            if (plist.issueResolve != "1")
              OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(width: 1.0, color: Colors.black45),
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Issue Pending',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 13.0,
                        color: Colors.white,
                      ))),
            const SizedBox(height: 10),
            OutlinedButton(
                onPressed: () {
                  if (plist.issueResolve != "0") {
                  } else {
                    showDialog<void>(
                        barrierDismissible: true,
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8), // Set radius to zero
                            ),
                            titlePadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            actionsPadding: const EdgeInsets.only(
                                bottom: 10, left: 10, right: 10),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            actionsAlignment: MainAxisAlignment.center,
                            title: const Text(
                              "Are you sure you want to update issue status as Resolved?",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            actions: [
                              InkWell(
                                onTap: () {
                                  // Navigator.of(context).pop();

                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  width: 250,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(7)),
                                  child: const Text(
                                    "No",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  setIssueResolved(
                                    slab_issue_id:
                                        plist.mstMasonryIssueReportId ??
                                            '', //mstSlabIssuerReportId ?? '',
                                    plistData: plist,
                                  );
                                  // Navigator.of(context).pop();
                                  // deleteProjectPms(
                                  //     projectPmsId: projectPmsDetailsResponse?[k]
                                  //             .mstProjectPmsId ??
                                  //         '');
                                  // getProjectPms(
                                  //     projectId:
                                  //         widget.projectId,
                                  //     towarId: widget.towarId);
                                },
                                child: Container(
                                  width: 250,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(7)),
                                  child: const Text(
                                    'Yes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          );
                        });
                  }
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: plist.issueResolve != "0"
                      ? Colors.green
                      : Colors.transparent,
                  side: const BorderSide(width: 1.0, color: Colors.black45),
                ),
                child: const Text('Issue Resolved', style: normalText12)),
          ],
        );
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () async {
                print('-----------------------');
                if (plist.reportVedio?.length != 0) {
                  final uri = Uri.parse(
                      '${AppUrl.globalMasonryReportIssuePath}/${plist.reportVedio?[0]}');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    throw 'Could not launch';
                  }
                }

                // VideoItem(
                //   file: '${plist.imagePath}/${plist.slabVedio?[0]}',
                //   index: 0,
                //   navigationFlag: 'fullscreen',
                //   callbackVideo: () {},
                //   urll: '${plist.imagePath}/${plist.slabVedio?[0]}',
                // );
              },
              child: SizedBox(
                width: 100,
                height: 100,
                child: plist.reportVedio?.length != 0
                    ? const Icon(
                        Icons.video_camera_back,
                      )
                    : const Card(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0))),
                        child: Image(
                            image: AssetImage(
                                'images/projectmanagement/noimage.png'))),
              ),
            ),
            verticalSpaceMedium,
            if (plist.issueResolve != "1")
              OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(width: 1.0, color: Colors.black45),
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Issue Pending',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 13.0,
                        color: Colors.white,
                      ))),
            const SizedBox(height: 10),
            OutlinedButton(
                onPressed: () {
                  showDialog<void>(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Set radius to zero
                          ),
                          titlePadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          actionsPadding: const EdgeInsets.only(
                              bottom: 10, left: 10, right: 10),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          actionsAlignment: MainAxisAlignment.center,
                          title: const Text(
                            "Are you sure you want to update issue status as Resolved?",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            InkWell(
                              onTap: () {
                                // Navigator.of(context).pop();

                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: 250,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(7)),
                                child: const Text(
                                  "No",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                setIssueResolved(
                                  slab_issue_id:
                                      plist.mstMasonryIssueReportId ?? '',
                                  plistData: plist,
                                );
                                // Navigator.of(context).pop();
                                // deleteProjectPms(
                                //     projectPmsId: projectPmsDetailsResponse?[k]
                                //             .mstProjectPmsId ??
                                //         '');
                                // getProjectPms(
                                //     projectId:
                                //         widget.projectId,
                                //     towarId: widget.towarId);
                              },
                              child: Container(
                                width: 250,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(7)),
                                child: const Text(
                                  'Yes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        );
                      });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 1.0, color: Colors.black45),
                  backgroundColor: plist.issueResolve != "0"
                      ? Colors.green
                      : Colors.transparent,
                ),
                child: const Text('Issue Resolved', style: normalText12)),
          ],
        );
      }
    }

    Widget _reportedBy() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
              width: 130, child: Text('Reported By : ', style: boldText13)),
          SizedBox(width: 550, child: Text(plist.reportBy!, style: normalText)),
        ],
      );
    }

    Widget _issueIn() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
              width: 130, child: Text('Issue In : ', style: boldText13)),
          SizedBox(
              width: 550, child: Text(plist.issusInName!, style: normalText)),
        ],
      );
    }

    Widget _resolvedBy() {
      return Container(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
                width: 130, child: Text('Resolved By : ', style: boldText13)),
            SizedBox(
                width: 550,
                child: Text(plist.empname ?? '', style: normalText)),
          ],
        ),
      );
    }

    Widget _reportedTo() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
              width: 130, child: Text('Reported To : ', style: boldText13)),
          SizedBox(
              width: 550, child: Text(plist.reportToName!, style: normalText)),
        ],
      );
    }

    Widget _reportedOn() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
              width: 130, child: Text('Reported On : ', style: boldText13)),
          SizedBox(
              width: 550, child: Text(plist.submitdate!, style: normalText)),
        ],
      );
    }

    Widget _resolvedOn() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
              width: 130, child: Text('Resolved On : ', style: boldText13)),
          SizedBox(
              width: 550, child: Text(plist.resolvedDate!, style: normalText)),
        ],
      );
    }

    Widget _remarks() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
              width: 130, child: Text('Remarks : ', style: boldText13)),
          SizedBox(width: 550, child: Text(plist.reports!, style: normalText)),
        ],
      );
    }

    return Padding(
      padding:
          const EdgeInsets.only(left: 2.0, right: 2.0, top: 2.0, bottom: 2.0),
      child: ListTile(
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _imageReport(),
                // horizontalSpaceSmall,
                const SizedBox(width: 100),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _reportedBy(),
                    verticalSpaceSmall,
                    _issueIn(),
                    verticalSpaceSmall,
                    _reportedTo(),
                    verticalSpaceSmall,
                    _reportedOn(),
                    verticalSpaceSmall,
                    if (plist.issueResolve != "0") _resolvedOn(),
                    if (plist.issueResolve != "0") _resolvedBy(),
                    verticalSpaceSmall,
                    _remarks(),
                    verticalSpaceSmall,
                  ],
                ),
              ],
            ),
            horizontalSpaceSmall,
            const Divider(height: 20.0, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  Widget AddRccIssueReport(
      {required List<ReportTo> arrReport, required int index}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['jpg', 'jpeg', 'png', "mp4"],
                );
                if (result != null) {
                  PlatformFile file = result.files.first;
                  print("FILE SELECTED");
                  print(file.name);
                  print(file.bytes);
                  print(file.size);
                  print(file.extension);
                  print(file.path);
                  Uint8List? fileBytes = result.files.first.bytes;
                  String fileName = result.files.first.name;
                  setState(() {
                    datIssueController[index].arrayFilesBytes?.add(fileBytes);
                    datIssueController[index].arrayFiles = file;
                  });
                } else {}
              },
              child: SizedBox(
                width: 140,
                height: 140,
                child:
                    // datIssueController[index].arrayFiles != null

                    datIssueController[index].arrayFiles != null &&
                            datIssueController[index].arrayFiles?.extension ==
                                'mp4'
                        ? const Icon(
                            Icons.video_camera_back,
                            size: 40,
                          )
                        : datIssueController[index].arrayFiles == null
                            ? Image.asset(
                                'images/projectmanagement/img5.png',
                                height: 140,
                                width: 140,
                              )
                            : Image.file(
                                File(datIssueController[index]
                                        .arrayFiles
                                        ?.path ??
                                    ''),
                                height: 140,
                                width: 140,
                              ),
              ),
            ),
            verticalSpaceMedium,
            OutlinedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'jpeg', 'png', "mp4"],
                  );
                  if (result != null) {
                    PlatformFile file = result.files.first;
                    print("FILE SELECTED");
                    print(file.name);
                    print(file.bytes);
                    print(file.size);
                    print(file.extension);
                    print(file.path);
                    Uint8List? fileBytes = result.files.first.bytes;
                    String fileName = result.files.first.name;
                    setState(() {
                      datIssueController[index].arrayFilesBytes?.add(fileBytes);
                      datIssueController[index].arrayFiles = file;
                    });
                  } else {}
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 1.0, color: Colors.black45),
                ),
                child: const Text('Attach Photo', style: normalText12)),
          ],
        ),
        const SizedBox(width: 100),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                    width: 130, child: Text('Issue In :', style: boldText13)),
                Text(args.response?.drawingTitle ?? '', style: normalText),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(
                    width: 130,
                    child: Text('Reported To : ', style: boldText13)),
                InkWell(
                  onTap: () {
                    setReportingToModal(index: index);
                  },
                  child: SizedBox(
                    width: 550,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "(Reported Cannot Be Empty)";
                        }
                      },
                      enabled: false,
                      readOnly: true,
                      controller:
                          datIssueController[index].selectReportingToController,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 13.0),
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          hintText: 'Enter Reported',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 116, 116, 116),
                            fontSize: 13.0,
                            fontWeight: FontWeight.w200,
                            fontFamily: 'HelveticaNeue',
                          ),
                          suffixIcon: Icon(
                            Icons.arrow_drop_down,
                          )),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(
                    width: 130, child: Text('Remarks : ', style: boldText13)),
                SizedBox(
                  width: 550,
                  child: TextFormField(
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "(Slab Review/Comments Cannot Be Empty)";
                      }
                    },
                    maxLines: 6,
                    controller:
                        datIssueController[index].issueTextEditingController,
                    style: const TextStyle(color: Colors.black, fontSize: 13.0),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(12.0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      hintText: 'Add Slab Review/Comments',
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 116, 116, 116),
                        fontSize: 13.0,
                        fontWeight: FontWeight.w200,
                        fontFamily: 'HelveticaNeue',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (index != 0)
          InkWell(
            onTap: () {
              setState(() {
                datIssueController.removeAt(index);
              });
            },
            child: Container(
              child: const Icon(
                Icons.close,
              ),
            ),
          )
      ],
    );
  }

  setReportingToModal({required int index}) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Set radius to zero
                ),
                titlePadding: EdgeInsets.zero,
                actionsPadding: EdgeInsets.zero,
                title: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: const Text(
                    "SET REPORTING TO",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                actions: <Widget>[
                  InkWell(
                    onTap: () {
                      datIssueController[index]
                          .selectReportingToController
                          .clear();
                      datIssueController[index].selectReportingToStrings = "";
                      for (int k = 0; k < arrReportTo!.length; k++) {
                        if (arrReportTo?[k].isSelected == true) {
                          setState(() {
                            datIssueController[index]
                                .selectReportingToController
                                .text = datIssueController[index]
                                    .selectReportingToController
                                    .text +
                                (datIssueController[index]
                                            .selectReportingToController
                                            .text
                                            .length >
                                        0
                                    ? ", "
                                    : "") +
                                (arrReportTo?[k].reportToName ?? '');

                            datIssueController[index].selectReportingToStrings =
                                datIssueController[index]
                                        .selectReportingToStrings +
                                    (datIssueController[index]
                                                .selectReportingToStrings
                                                .length >
                                            0
                                        ? ","
                                        : "") +
                                    (arrReportTo?[k].reportToId ?? '');
                          });
                        }
                      }

                      // setState(() {
                      //   datIssueController[index].selectReportingToStrings =
                      //       datIssueController[index]
                      //           .selectReportingToController
                      //           .text;
                      // });
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 250,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(7)),
                      child: const Text(
                        "CLOSE",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      datIssueController[index]
                          .selectReportingToController
                          .clear();
                      datIssueController[index].selectReportingToStrings = '';
                      for (int k = 0; k < arrReportTo!.length; k++) {
                        if (arrReportTo?[k].isSelected == true) {
                          setState(() {
                            datIssueController[index]
                                .selectReportingToController
                                .text = datIssueController[index]
                                    .selectReportingToController
                                    .text +
                                (datIssueController[index]
                                            .selectReportingToController
                                            .text
                                            .length >
                                        0
                                    ? ", "
                                    : "") +
                                (arrReportTo?[k].reportToName ?? '');

                            datIssueController[index].selectReportingToStrings =
                                datIssueController[index]
                                        .selectReportingToStrings +
                                    (datIssueController[index]
                                                .selectReportingToStrings
                                                .length >
                                            0
                                        ? ","
                                        : "") +
                                    (arrReportTo?[k].reportToId ?? '');
                          });
                        }
                      }
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 250,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(7)),
                      child: const Text(
                        "SUBMIT",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
                content: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return SizedBox(
                    height: 240,
                    width: 400,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < arrReportTo!.length; i++)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (arrReportTo?[i].isSelected == true) {
                                    arrReportTo?[i].isSelected = false;
                                  } else {
                                    arrReportTo?[i].isSelected = true;
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color: Colors.grey,
                                ))),
                                child: Row(
                                  children: [
                                    Text(
                                      arrReportTo?[i].reportToName ?? '',
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    Spacer(),
                                    if (arrReportTo?[i].isSelected == true)
                                      Icon(Icons.check_circle,
                                          color: Colors.green),
                                    if (arrReportTo?[i].isSelected == false)
                                      Icon(Icons.circle_outlined,
                                          color: Colors.black45),
                                  ],
                                ),
                                // RadioListTile<String>(
                                //   contentPadding: EdgeInsets.zero,
                                //   title: Text(
                                //     arrReportTo?[i].reportToName ?? '',
                                //     style: const TextStyle(
                                //       fontSize: 20,
                                //     ),
                                //   ),
                                //   value: arrReportTo?[i].reportToName ?? '',
                                //   groupValue: datIssueController[index]
                                //       .selectReportingToController
                                //       .text,
                                //   onChanged: (value) {
                                //     inspect(arrReportTo?[i]);
                                //     setState(() {
                                //       datIssueController[index]
                                //               .selectReportingToStrings =
                                //           arrReportTo?[i].reportToId ?? '';
                                //       datIssueController[index]
                                //           .selectReportingToController
                                //           .text = value ?? '';
                                //     });
                                //     Navigator.pop(context);
                                //   },
                                //   controlAffinity:
                                //       ListTileControlAffinity.trailing,
                                // ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }));
          });
        });
  }
}
