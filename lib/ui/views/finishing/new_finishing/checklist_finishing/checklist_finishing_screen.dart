import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_all_check_list.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/finishing/new_finishing/checklist_finishing/create_new_checklisr_finishing_screen.dart';
// import 'package:stallion/ui/views/masonry/create_new_checklisr_masnory_screen.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/ui/widgets/row_three_text.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckListFinishingScreen extends StatefulWidget {
  const CheckListFinishingScreen(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.towarName,
      this.slabId,
      this.title});

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? title;
  final String? slabId;

  @override
  State<CheckListFinishingScreen> createState() => _CheckListScreenState();
}

class _CheckListScreenState extends State<CheckListFinishingScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? webCheckListUrl = '';

  List<CheckList>? checkListResponse;
  Future<GetAllCheckListResponse?> getCheckStatus() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId ?? '',
      "slab_id": '0', // widget.slabId!,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.projectGetFinishingCheckList, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getAllCheckListFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          checkListResponse = dataModel.response?.checkList;
          webCheckListUrl = dataModel.response?.webCheckListUrl;
        });
      } else {}
    }
    return null;
  }

  @override
  void initState() {
    getCheckStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: InkWell(
        onTap: () {
          var projectId = widget.projectId!;
          var projectName = widget.projectName!;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return CreateNewFinishingCheckList(
                  projectId: projectId,
                  towarId: widget.towarId!,
                  projectName: projectName,
                  towarName: widget.towarName!,
                  title: widget.title,
                  slabId: widget.slabId,
                  slabCheckDocument: [],
                );
              },
            ),
          ).then((value) => getCheckStatus());
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          height: 40,
          child: const Center(
            child: Text(
              "CREATE CHECKLIST",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
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
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: const Row(
              children: [
                // const SizedBox(width: 131),
                Spacer(),
                Text(
                  "FINISHING CHECKLIST",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                // InkWell(
                //   onTap: () {
                //     _launchURL();
                //     Navigator.of(context).pop();
                //   },
                //   child: Container(
                //       padding: const EdgeInsets.symmetric(
                //           horizontal: 16, vertical: 4),
                //       decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(8),
                //           border: Border.all(color: Colors.black)),
                //       child: const Text("Detailed Checklist",
                //           style: TextStyle(color: Colors.black))),
                // )
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Divider(),
          const SizedBox(height: 6),
          checkListResponse?.length != 0
              ? Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: checkListResponse?.length ?? 0,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 80),
                        child: Column(
                          children: [
                            // rowThreeText(
                            //   context: context,
                            //   title: "Submitted By",
                            //   titleValue:
                            //       checkListResponse?[index].userName ?? '',
                            // ),
                            Container(
                              padding: const EdgeInsets.only(top: 10, left: 22),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 300,
                                    child: Text(
                                      checkListResponse?[index]
                                                  .projectSlabSaveStatus ==
                                              "0"
                                          ? "Edited By"
                                          : "Submitted By",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  horizontalSpaceMedium,
                                  const Center(
                                      child: Icon(Icons.remove,
                                          color: Colors.black54)),
                                  horizontalSpaceLarge,
                                  Text(
                                    checkListResponse?[index].userName ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    // "(RCC Checklist)",
                                    '(${checkListResponse?[index].checklistType})',
                                    // "(Detailed Checklist)",
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                  )
                                ],
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.only(top: 10, left: 22),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 300,
                                    child: Text(
                                      "Company",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  horizontalSpaceMedium,
                                  const Center(
                                    child: Icon(
                                      Icons.remove,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  horizontalSpaceLarge,
                                  Text(
                                    checkListResponse?[index].companyName ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  OutlinedButton(
                                    onPressed: () async {
                                      if (checkListResponse?[index]
                                              .projectSlabSaveStatus !=
                                          "0") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) {
                                              return PdfViewer(
                                                fileName:
                                                    checkListResponse?[index]
                                                        .salbCheckPdf
                                                        .toString(),
                                                fileUrl:
                                                    '${AppUrl.slabCheckPath}${checkListResponse?[index].salbCheckPdf.toString()}',
                                              );
                                            },
                                          ),
                                        );
                                      } else {
                                        var projectId = widget.projectId!;
                                        var projectName = widget.projectName!;
                                        if (checkListResponse?[index]
                                                .webCheckListUrl !=
                                            "") {
                                          if (checkListResponse?[index]
                                                  .webCheckListUrl !=
                                              "") {
                                            print(checkListResponse?[index]
                                                .webCheckListUrl);
                                            final uri = Uri.parse(
                                                checkListResponse?[index]
                                                        .webCheckListUrl ??
                                                    '');
                                            if (await canLaunchUrl(uri)) {
                                              Navigator.of(context).pop();
                                              await launchUrl(uri);
                                            } else {
                                              throw 'Could not launch';
                                            }
                                          }
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) {
                                                return CreateNewFinishingCheckList(
                                                  projectId: projectId,
                                                  towarId: widget.towarId!,
                                                  projectName: projectName,
                                                  towarName: widget.towarName!,
                                                  title: widget.title,
                                                  slabId: widget.slabId,
                                                  project_slab_check_id:
                                                      checkListResponse?[index]
                                                          .projectSlabCheckId,
                                                  slabCheckDocument:
                                                      checkListResponse?[index]
                                                          .slabCheckDocument,
                                                );
                                              },
                                            ),
                                          ).then((value) => getCheckStatus());
                                        }
                                        // viewDocumentsModal(dataDocs: data);
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      side: const BorderSide(
                                          width: 1.0, color: Colors.black45),
                                    ),
                                    child: Text(
                                      checkListResponse?[index]
                                                  .projectSlabSaveStatus !=
                                              "0"
                                          ? "View Pdf"
                                          : 'Edit',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // rowThreeText(
                            //   context: context,
                            //   title: "Date",
                            //   subTitleValue:
                            //       "(RCC Checklist)", //"(Detailed Checklist)",
                            //   titleSubValueColor: Colors.black87,
                            // titleValue: checkListResponse?[index]
                            //         .projectSlabCheckDate ??
                            //       '',
                            // ),
                            Container(
                              padding: const EdgeInsets.only(top: 10, left: 22),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 300,
                                    child: Text(
                                      "Date",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  horizontalSpaceMedium,
                                  const Center(
                                      child: Icon(Icons.remove,
                                          color: Colors.black54)),
                                  horizontalSpaceLarge,
                                  Text(
                                    checkListResponse?[index]
                                            .projectSlabCheckDate ??
                                        '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (checkListResponse?[index]
                                          .slabCheckDocument
                                          ?.length !=
                                      0)
                                    OutlinedButton(
                                      onPressed: () {
                                        viewDocs(
                                            poDocument:
                                                checkListResponse?[index]
                                                    .slabCheckDocument);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        side: const BorderSide(
                                            width: 1.0, color: Colors.black45),
                                      ),
                                      child: const Text(
                                        "View Docs",
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (checkListResponse?[index].categoryName != '')
                              rowThreeText(
                                  context: context,
                                  title: "Category",
                                  titleValue:
                                      checkListResponse?[index].categoryName ??
                                          ''),
                            Container(
                              padding: const EdgeInsets.only(top: 10, left: 22),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 300,
                                    child: Text(
                                      "Notes",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  horizontalSpaceMedium,
                                  const Center(
                                      child: Icon(Icons.remove,
                                          color: Colors.black54)),
                                  horizontalSpaceLarge,
                                  Expanded(
                                    // width:
                                    //     MediaQuery.of(context).size.width - 600,
                                    child: Text(
                                      checkListResponse?[index]
                                              .projectSlabRemark ??
                                          '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(
                      color: Colors.grey,
                    ),
                  ),
                )
              : const Expanded(
                  // padding: EdgeInsets.only(top: 250),
                  child: Center(
                    child: Text(
                      "No Record Found",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }

  viewDocs({List<SlabCheckDocument>? poDocument}) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 0),
              actionsPadding: EdgeInsets.zero,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              actionsAlignment: MainAxisAlignment.center,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7),
                    )),
                child: const Text(
                  "View Documents",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 500,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(7),
                          bottomRight: Radius.circular(7),
                        )),
                    child: const Text(
                      "OKAY",
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
              content: SizedBox(
                height: 320,
                width: 400,
                child: SingleChildScrollView(
                  child: Wrap(
                    direction: Axis.horizontal, // default
                    alignment: WrapAlignment.start, // default
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      for (int i = 0; i < poDocument!.length; i++)
                        poDocument[i].documentName?.split(".").last == 'pdf'
                            ? InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return PdfViewer(
                                          // here
                                          fileName: poDocument[i].documentName,
                                          fileUrl:
                                              '${AppUrl.slabCheckDoc}${poDocument[i].documentName?.toString()}',
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  width: 140,
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/projectmanagement/pdf.png',
                                        width: 100,
                                        height: 100,
                                      ),
                                      AppText(
                                        title: poDocument[i].documentName ?? '',
                                        fontSize: 14,
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return ImagePreviewViewer(
                                          // here
                                          fileName:
                                              poDocument[i].documentName ?? '',
                                          fileUrl:
                                              '${AppUrl.slabCheckDoc}${poDocument[i].documentName?.toString()}',
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  width: 140,
                                  child: Column(
                                    children: [
                                      Image.network(
                                        '${AppUrl.slabCheckDoc}${poDocument[i].documentName?.toString()}',
                                        width: 100,
                                        height: 100,
                                      ),
                                      AppText(
                                        title: poDocument[i].documentName ?? '',
                                        fontSize: 14,
                                      )
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

  _launchURL() async {
    if (webCheckListUrl != "") {
      final uri = Uri.parse(webCheckListUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch';
      }
    }
  }
}
