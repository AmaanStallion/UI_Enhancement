import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_project_masonry.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/masonry/checklist_masonry_screen.dart';
import 'package:stallion/ui/views/masonry/issuemasonryreport_screen.dart';
import 'package:stallion/ui/views/rccstructure/checklist/checklist_screen.dart';
import 'package:stallion/ui/views/rccstructure/dpr/daily_progress_report.dart';
import 'package:stallion/ui/views/rccstructure/supplies/order_supplies_screen.dart';
import 'package:stallion/ui/views/rccstructure/slab/revisionrccstructure.dart';
import 'package:stallion/ui/views/rccstructure/slab/slab_status_screen.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';

// import '../../../models/get_rccstructure.dart';
import '../rccstructure/slab/issuerccreport_screen.dart';
import 'masonry_status_screen.dart';

class MasonryStructure extends StatefulWidget {
  MasonryStructure(
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
  _RccStructureState createState() => _RccStructureState();
}

class _RccStructureState extends State<MasonryStructure> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  bool circular = false;
  List<TowarList>? towarListRes = [];
  TowarList? towarListSelected;
  String? strRccTitle;
  String? strSlabIssueCount;
  int? indexOfSlab = -1;
  String? slabId;
  String? offset = '0';

  List<MasonryDetail>? masonryDetailsResponse = [];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future<List<MasonryDetail>?> fetchGetMasonryDetails(
      {bool isFromModal = false, required BuildContext contextApi}) async {
    setState(() {
      circular = true;
    });
    CustomLoading.progressDialog(isLoading: true, context: contextApi);

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }
    Map<String, String> data = {
      "offset": offset ?? '0',
      "limit": "10",
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": towarListSelected == null
          ? widget.towarId!
          : towarListSelected?.towarId ?? '',
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(AppUrl.getProjectMasonry, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getProjectMasonryFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          towarListRes = dataModel.response?.towarList;

          if (masonryDetailsResponse!.length == 0) {
            masonryDetailsResponse = dataModel.response?.masonryDetails;
          } else {
            masonryDetailsResponse = [
              ...?masonryDetailsResponse,
              ...?dataModel.response?.masonryDetails
            ];
          }
          offset = dataModel.response?.offset;

          // masonryDetailsResponse = dataModel.response?.masonryDetails;
        });

        // List<MasonryDetail>? masonryDetailsResponse =
        //     dataModel.response?.masonryDetails;
        // if (isFromModal && dataModel.response?.masonryDetails?.length != 0) {
        CustomLoading.progressDialog(isLoading: false, context: contextApi);
        // }
        return masonryDetailsResponse; // structurelist;
      } else {
        List<MasonryDetail>? list = [];
        // if (isFromModal) {
        CustomLoading.progressDialog(isLoading: false, context: contextApi);
        // }
        return list;
      }
    } else {
      List<MasonryDetail>? list = [];
      if (isFromModal) {
        CustomLoading.progressDialog(isLoading: false, context: contextApi);
      }
      return list;
    }
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));

    offset = '0';
    // searchTermValue = '';
    masonryDetailsResponse = [];

    fetchGetMasonryDetails(contextApi: context);
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));
    fetchGetMasonryDetails(contextApi: context);
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchGetMasonryDetails(contextApi: context);
    });
    setState(() {
      towarListSelected =
          TowarList(towarId: widget.towarId, towarName: widget.towarName);
    });

    ///whatever you want to run on page build
    strSlabIssueCount = '0';
    strRccTitle = '';
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: Container(
        // padding: const EdgeInsets.symmetric(horizontal: 80),
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(
              height: 40,
              child: Center(
                child: Text('MASONRY',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center),
              ),
            ),
            const Divider(
              height: 1.0,
              color: Colors.black,
            ),
            // if (towarListRes!.length > 0)
            //   InkWell(
            //     onTap: () {
            //       if (towarListRes!.length > 0) {
            //         selectTowerModal(contextModal: context);
            //         Future.delayed(const Duration(seconds: 2), () {
            //           CustomLoading.progressDialog(
            //               isLoading: false, context: context);
            //         });
            //       }
            //     },
            //     child: SizedBox(
            //         height: 40,
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             Text(towarListSelected?.towarName ?? '',
            //                 style: const TextStyle(
            //                   fontSize: 15,
            //                   fontWeight: FontWeight.w500,
            //                 ),
            //                 textAlign: TextAlign.center),
            //             const Icon(Icons.arrow_drop_down)
            //           ],
            //         )),
            //   ),
            // if (towarListRes!.length > 0)
            // const Divider(
            //   height: 1.0,
            //   color: Colors.black,
            // ),
            Expanded(
                child: masonryDetailsResponse?.length != 0
                    ? SmartRefresher(
                        enablePullDown: true,
                        enablePullUp: true,
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        onLoading: _onLoading,
                        footer: const ClassicFooter(
                            loadStyle: LoadStyle.ShowWhenLoading),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ListView.builder(
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 80),
                              decoration: BoxDecoration(
                                color: indexOfSlab == index
                                    ? const Color.fromARGB(255, 233, 233, 233)
                                    : Colors.transparent,
                              ),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (indexOfSlab == index) {
                                          indexOfSlab = -1;
                                        } else {
                                          indexOfSlab = index;
                                          MasonryDetail dict =
                                              masonryDetailsResponse![
                                                  indexOfSlab!];
                                          strSlabIssueCount =
                                              dict.issueMasnoryReport;
                                          strRccTitle =
                                              dict.masonryNo?.toUpperCase();
                                        }

                                        // indexOfSlab = index;

                                        slabId = masonryDetailsResponse?[index]
                                            .masonryId;
                                        strRccTitle =
                                            masonryDetailsResponse?[index]
                                                .masonryNo!;
                                      });
                                    },
                                    child: MyExpandableWidget(
                                      plist: masonryDetailsResponse![index],
                                      ind: index,
                                    ),
                                  ),
                                  if (indexOfSlab == index)
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        _drawingHeaderTitle(),
                                        verticalSpaceSmall,
                                        const Divider(
                                            height: 1.0, color: Colors.black),
                                        verticalSpaceSmall,
                                        Column(
                                          children: List.generate(
                                              masonryDetailsResponse![
                                                      indexOfSlab!]
                                                  .drawings!
                                                  .length, (index) {
                                            return DrawingsList(
                                              afterPopFun: () {
                                                fetchGetMasonryDetails(
                                                    contextApi: context);
                                              },
                                              plist: masonryDetailsResponse![
                                                      indexOfSlab!]
                                                  .drawings![index],
                                              projectId: widget.projectId!,
                                              towarId: widget.towarId!,
                                              projectName: widget.projectName!,
                                              slabNo: strRccTitle,
                                              slabId: masonryDetailsResponse![
                                                          indexOfSlab!]
                                                      .masonryId ??
                                                  '',
                                            );
                                          }),
                                        ),
                                        //   ],
                                        // ),
                                        // verticalSpaceSmall,
                                        // const Divider(
                                        //     color: Colors.black, height: 1.0),
                                        // Column(
                                        //   children: [
                                        // _slabHeaderTitle(),
                                        // verticalSpaceSmall,
                                        // verticalSpaceSmall,
                                        // const Divider(
                                        //     height: 1.0, color: Colors.black),
                                        // verticalSpaceSmall,
                                        Column(
                                          children: List.generate(
                                              masonryDetailsResponse![
                                                      indexOfSlab!]
                                                  .masonryCheck!
                                                  .length, (index) {
                                            return SlabCheckList(
                                                plist: masonryDetailsResponse![
                                                        indexOfSlab!]
                                                    .masonryCheck![index],
                                                masonryId:
                                                    masonryDetailsResponse?[
                                                                indexOfSlab!]
                                                            .masonryId ??
                                                        "");
                                          }),
                                        ),
                                        //   ],
                                        // ),
                                      ],
                                    ),
                                  // ),
                                ],
                              ),
                            );
                          },
                          itemCount: masonryDetailsResponse!.length,
                        ),
                      )
                    : const Center(child: Text("No Record Found")))
            // Expanded(
            //   child:
            //   FutureBuilder<List<MasonryDetail>?>(
            //       future: fetchGetMasonryDetails(contextApi: context),
            //       builder: (BuildContext context, AsyncSnapshot snapshot) {
            //         if (snapshot.hasData) {
            //           if (kDebugMode) {
            //             print("has data");
            //           }
            //           // SlabDetail dict = snapshot.data[indexOfSlab];
            //           // strSlabIssueCount = dict.issueSlabReport;
            //           // strRccTitle = dict.slabNo.toUpperCase();
            //           return
            //               // Row(
            //               //   children: [
            //               snapshot.data.length != 0
            //                   ? ListView.builder(
            //                       itemBuilder:
            //                           (BuildContext context, int index) {
            //                         return Container(
            //                           padding: const EdgeInsets.symmetric(
            //                               horizontal: 80),
            //                           decoration: BoxDecoration(
            //                             color: indexOfSlab == index
            //                                 ? const Color.fromARGB(
            //                                     255, 233, 233, 233)
            //                                 : Colors.transparent,
            //                           ),
            //                           child: Column(
            //                             children: [
            //                               InkWell(
            //                                 onTap: () {
            //                                   setState(() {
            //                                     if (indexOfSlab == index) {
            //                                       indexOfSlab = -1;
            //                                     } else {
            //                                       indexOfSlab = index;
            //                                       MasonryDetail dict = snapshot
            //                                           .data[indexOfSlab];
            //                                       strSlabIssueCount =
            //                                           dict.issueMasnoryReport;
            //                                       strRccTitle = dict.masonryNo
            //                                           ?.toUpperCase();
            //                                     }

            //                                     // indexOfSlab = index;

            //                                     slabId = snapshot
            //                                         .data[index].masonryId;
            //                                     strRccTitle = snapshot
            //                                         .data[index].masonryNo!;
            //                                   });
            //                                 },
            //                                 child: MyExpandableWidget(
            //                                   plist: snapshot.data[index],
            //                                   ind: index,
            //                                 ),
            //                               ),
            //                               if (indexOfSlab == index)
            //                                 Column(
            //                                   mainAxisAlignment:
            //                                       MainAxisAlignment.start,
            //                                   children: [
            //                                     _drawingHeaderTitle(),
            //                                     verticalSpaceSmall,
            //                                     const Divider(
            //                                         height: 1.0,
            //                                         color: Colors.black),
            //                                     verticalSpaceSmall,
            //                                     Column(
            //                                       children: List.generate(
            //                                           snapshot
            //                                               .data[indexOfSlab!]
            //                                               .drawings
            //                                               .length, (index) {
            //                                         return DrawingsList(
            //                                           afterPopFun: () {
            //                                             fetchGetMasonryDetails(
            //                                                 contextApi:
            //                                                     context);
            //                                           },
            //                                           plist: snapshot
            //                                               .data[indexOfSlab!]
            //                                               .drawings[index],
            //                                           projectId:
            //                                               widget.projectId!,
            //                                           towarId: widget.towarId!,
            //                                           projectName:
            //                                               widget.projectName!,
            //                                           slabNo: strRccTitle,
            //                                           slabId: snapshot
            //                                                   .data[
            //                                                       indexOfSlab!]
            //                                                   .masonryId ??
            //                                               '',
            //                                         );
            //                                       }),
            //                                     ),
            //                                     //   ],
            //                                     // ),
            //                                     // verticalSpaceSmall,
            //                                     // const Divider(
            //                                     //     color: Colors.black, height: 1.0),
            //                                     // Column(
            //                                     //   children: [
            //                                     // _slabHeaderTitle(),
            //                                     // verticalSpaceSmall,
            //                                     // verticalSpaceSmall,
            //                                     // const Divider(
            //                                     //     height: 1.0, color: Colors.black),
            //                                     // verticalSpaceSmall,
            //                                     Column(
            //                                       children: List.generate(
            //                                           snapshot
            //                                               .data[indexOfSlab!]
            //                                               .masonryCheck
            //                                               .length, (index) {
            //                                         return SlabCheckList(
            //                                             plist: snapshot
            //                                                     .data[indexOfSlab!]
            //                                                     .masonryCheck[
            //                                                 index],
            //                                             masonryId: snapshot
            //                                                 .data[indexOfSlab!]
            //                                                 .masonryId);
            //                                       }),
            //                                     ),
            //                                     //   ],
            //                                     // ),
            //                                   ],
            //                                 ),
            //                               // ),
            //                             ],
            //                           ),
            //                         );
            //                       },
            //                       itemCount: snapshot.data.length,
            //                     )
            //                   : const Center(child: Text("No Record Found"));
            //           // const VerticalDivider(
            //           //     color: Colors.black, thickness: 1, width: 0.5),
            //           // Expanded(
            //           //   child: SingleChildScrollView(
            //           //     child: Column(
            //           //       mainAxisAlignment: MainAxisAlignment.start,
            //           //       children: [
            //           //         Padding(
            //           //           padding: const EdgeInsets.only(
            //           //               left: 15.0,
            //           //               right: 15.0,
            //           //               top: 10.0,
            //           //               bottom: 5.0),
            //           //           child: Column(
            //           //             children: [
            //           //               _rccTitle(),
            //           //               verticalSpaceSmall,
            //           //               const Divider(
            //           //                   height: 1.0, color: Colors.black),
            //           //               verticalSpaceSmall,
            //           //               _drawingHeaderTitle(),
            //           //               verticalSpaceSmall,
            //           //               const Divider(
            //           //                   height: 1.0, color: Colors.black),
            //           //               verticalSpaceSmall,
            //           //               Column(
            //           //                 children: List.generate(
            //           //                     snapshot.data[indexOfSlab!]
            //           //                         .drawings.length, (index) {
            //           //                   return DrawingsList(
            //           //                     plist: snapshot
            //           //                         .data[indexOfSlab!]
            //           //                         .drawings[index],
            //           //                     projectId: widget.projectId!,
            //           //                     towarId: widget.towarId!,
            //           //                     projectName:
            //           //                         widget.projectName!,
            //           //                     slabNo: strRccTitle,
            //           //                     slabId: snapshot
            //           //                         .data[indexOfSlab!].slabId!,
            //           //                   );
            //           //                 }),
            //           //               ),
            //           //             ],
            //           //           ),
            //           //         ),
            //           //         verticalSpaceSmall,
            //           //         const Divider(
            //           //             color: Colors.black, height: 1.0),
            //           //         Padding(
            //           //           padding: const EdgeInsets.only(
            //           //               left: 15.0,
            //           //               right: 15.0,
            //           //               top: 15.0,
            //           //               bottom: 5.0),
            //           //           child: Column(
            //           //             children: [
            //           //               _slabHeaderTitle(),
            //           //               verticalSpaceSmall,
            //           //               verticalSpaceSmall,
            //           //               const Divider(
            //           //                   height: 1.0, color: Colors.black),
            //           //               verticalSpaceSmall,
            //           //               Column(
            //           //                 children: List.generate(
            //           //                     snapshot.data[indexOfSlab!]
            //           //                         .slabCheck.length, (index) {
            //           //                   return SlabCheckList(
            //           //                       plist: snapshot
            //           //                           .data[indexOfSlab!]
            //           //                           .slabCheck[index]);
            //           //                 }),
            //           //               ),
            //           //             ],
            //           //           ),
            //           //         ),
            //           //       ],
            //           //     ),
            //           //   ),
            //           // ),
            //           //   ],
            //           // );
            //         } else {
            //           return Center(
            //             child: SizedBox(
            //               height: 64,
            //               child: OverflowBox(
            //                 minHeight: 100,
            //                 maxHeight: 100,
            //                 child: Lottie.asset(
            //                   'assets/animation/running2.json',
            //                   repeat: true,
            //                 ),
            //               ),
            //             ),
            //           );
            //         }
            //       }),
            // ),
          ],
        ),
      ),
    );
  }

  selectTowerModal({required BuildContext contextModal}) {
    return showDialog<void>(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 10),
              actionsPadding: const EdgeInsets.only(bottom: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: const Text(
                "SELECT TOWER",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 4),
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
              ],
              content: SizedBox(
                  width: 500,
                  height: 244,
                  child: ListView.separated(
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              towarListSelected = towarListRes?[index];
                              Navigator.of(context).pop();

                              // CustomLoading.progressDialog(
                              //     isLoading: true, context: contextModal);
                              fetchGetMasonryDetails(
                                  isFromModal: true, contextApi: context);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Text(
                                  towarListRes?[index].towarName ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                towarListSelected?.towarId ==
                                        towarListRes?[index].towarId
                                    ? const Icon(Icons.check_circle,
                                        color: Colors.green)
                                    : const Icon(Icons.circle_outlined,
                                        color: Colors.black45),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(
                            color: Colors.grey,
                          ),
                      itemCount: towarListRes!.length)),
            );
          });
        });
  }

  Widget _rccTitle() {
    return Center(
      child: Text(
        strRccTitle!,
        style: boldText,
      ),
    );
  }

  Widget _drawingHeaderTitle() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('VERIFIED', style: boldText),
        // SizedBox(
        //   width: 300,
        // ),

        Text('DRAWINGS', style: boldText),
        SizedBox(
          width: 30,
        ),
        SizedBox(
          width: 70,
        ),
        // OutlinedButton(
        //     onPressed: () {
        //       setReportingToModal();
        //     },
        //     style: OutlinedButton.styleFrom(
        //       side: const BorderSide(width: 1.0, color: Colors.black45),
        //     ),
        //     child: const Row(
        //       children: [
        //         Icon(Icons.print_outlined,
        //             color: Color.fromRGBO(0, 128, 43, 1.0)),
        //         horizontalSpaceSmall,
        //         Text('Print',
        //             style: TextStyle(
        //                 color: Colors.green,
        //                 fontSize: 13.0,
        //                 fontWeight: FontWeight.bold)),
        //       ],
        //     )),
      ],
    );
  }

  // @override
  Widget _slabHeaderTitle() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 50),
        const SizedBox(width: 60),
        const Text('BLOCK WORK', style: boldText),
        _slabIssueReported(),
        OutlinedButton(
            onPressed: () {
              var projectId = widget.projectId!;
              var projectName = widget.projectName!;
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) {
              //       return IssueRccReport(
              //         projectId: projectId,
              //         towarId: widget.towarId,
              //         projectName: projectName,
              //         slabcheckid: 'plist.slabCheckId',
              //         slabchecktype: '0',
              //         slabid: slabId,
              //         drawingTitle: 'plist.drawingTitle--',
              //         drawingId: 'plist.drawingId',
              //       );
              //     },
              //   ),
              // );
              Navigator.of(context).pushNamed(
                '/issueRccReportScreen',
                arguments: NotificationArgs(
                  projectId: widget.projectId ?? '',
                  projectName: widget.projectName ?? '',
                  // towarName: widget.towarName,
                  response: NotificationResponseData(
                    slabCheckId: 'plist.slabCheckId',
                    slabCheckType: '0',
                    slabId: slabId,
                    drawingTitle: 'plist.drawingTitle',
                    towarId: widget.towarId,
                    drawingId: 'plist.drawingId',
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(width: 1.0, color: Colors.black45),
            ),
            child: const Text('Report Issues', style: normalText)),
      ],
    );
  }

  Widget _slabIssueReported() {
    if (int.parse(strSlabIssueCount!) > 0) {
      return OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: const BorderSide(width: 1.0, color: Colors.red),
          ),
          child: Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.report_problem_outlined, color: Colors.red),
                  horizontalSpaceSmall,
                  _issueReportedText(),
                ],
              )
            ],
          ));
    } else {
      return Container();
    }
  }

  Widget _issueReportedText() {
    if (strSlabIssueCount == '1') {
      return Text('${strSlabIssueCount!} Issue Reported',
          style: const TextStyle(
              color: Colors.red,
              fontSize: 13.0,
              fontWeight: FontWeight.normal));
    } else {
      return const Text('Issues Reported',
          style: TextStyle(
              color: Colors.red,
              fontSize: 13.0,
              fontWeight: FontWeight.normal));
    }
  }

  Widget MyExpandableWidget({required MasonryDetail plist, required int ind}) {
    Widget _issueReport() {
      if (plist.issueReport != '0') {
        return Column(
          children: [
            verticalSpaceSmall,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.report_problem_outlined, color: Colors.red),
                horizontalSpaceSmall,
                Text('${plist.issueReport} issues Reported',
                    style: normalTextRedColor),
              ],
            ),
          ],
        );
      } else {
        return Container();
      }
    }

    Widget _slabCompleteIcon() {
      if (plist.completStatus == "1") {
        return const Icon(Icons.check_circle, color: Colors.green);
      } else {
        return const Icon(Icons.circle_outlined, color: Colors.black45);
      }
    }

    Widget _slabPendiing() {
      if (plist.errorTitle != '') {
        return Column(
          children: [
            verticalSpaceSmall,
            Text(plist.errorTitle!, style: normalTextRedColor),
          ],
        );
      } else {
        return Container();
      }
    }

    Widget _slabTitle() {
      if (plist.completTitile != '') {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(plist.masonryNo!, style: boldText),
            Center(
                child: Text(plist.completTitile!, style: normalTextBlueColor)),
            _slabCompleteIcon(),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(plist.masonryNo ?? '', style: boldText),
            plist.completStatus == "0"
                ? const Icon(Icons.circle_outlined, color: Colors.black45)
                : const Icon(Icons.check_circle, color: Colors.green)
          ],
        );
      }
    }

    Widget _checklist({
      required MasonryDetail plist,
    }) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (plist.checkListFlag != "0")
            const Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {
              setState(() {
                slabId = plist.masonryId;
              });
              var projectId = widget.projectId!;
              var projectName = widget.projectName!;
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) {
              //       return CheckListMasonryScreen(
              //         projectId: projectId,
              //         towarId: widget.towarId!,
              //         projectName: projectName,
              //         towarName: widget.towarName!,
              //         title: plist.masonryId,
              //         slabId: slabId,
              //       );
              //     },
              //   ),
              // )
              //
              Navigator.of(context)
                  .pushNamed(
                '/checkListMasonryScreen',
                arguments: NotificationArgs(
                  projectId: projectId,
                  projectName: projectName,
                  towarName: widget.towarName,
                  response: NotificationResponseData(
                    towarId: widget.towarId,
                    // slabNo: plist.slabNo,
                    slabId: plist.masonryId,
                  ),
                ),
              )
                  .then((value) {
                // errorCode = '';
                // offset = '0';
                // slabDetails = [];
                // fetchRccStructureDetails();
              });
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(width: 1.0, color: Colors.black45),
            ),
            child: const Text('         Checklist         ', style: normalText),
          ),
        ],
      );
    }

    Widget _slabComnpletedOn() {
      // if (plist.completedDate != '') {
      return Column(
        children: [
          verticalSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              plist.completedDate != ''
                  ? Text('Completed on - ${plist.completedDate}',
                      style: normalText)
                  : const SizedBox(),
              Column(
                mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        plist.masonryCheck?[0].headTitle ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      plist.masonryCheck?[0].headCheck ==
                              '0' //  plist.completStatus == "0"
                          ? const Icon(
                              Icons.circle_outlined,
                              color: Colors.black45,
                              size: 18,
                            )
                          : const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 18,
                            )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        "Internal Plaster",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      plist.masonryCheck?[1].headCheck ==
                              '0' //  plist.completStatus == "0"
                          ? const Icon(
                              Icons.circle_outlined,
                              color: Colors.black45,
                              size: 18,
                            )
                          : const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 18,
                            )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        "External Plaster",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      plist.masonryCheck?[2].headCheck ==
                              '0' //  plist.completStatus == "0"
                          ? const Icon(
                              Icons.circle_outlined,
                              color: Colors.black45,
                              size: 18,
                            )
                          : const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 18,
                            )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      // } else {
      //   return Column(
      //     children: [
      //       verticalSpaceSmall,
      //       Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           Container(),
      //           OutlinedButton(
      //               onPressed: () {},
      //               style: OutlinedButton.styleFrom(
      //                 side: const BorderSide(width: 1.0, color: Colors.black45),
      //               ),
      //               child: const Text('Order Supplies', style: normalText)),
      //         ],
      //       ),
      //     ],
      //   );
      // }
    }

    return Container(
      // decoration: BoxDecoration(
      //   color: indexOfSlab == ind
      //       ? const Color.fromARGB(255, 233, 233, 233)
      //       : Colors.transparent,
      // ),
      padding:
          const EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0, bottom: 5.0),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _slabTitle(),
            _slabPendiing(),
            verticalSpaceSmall,
            Text('Est Deadline - ${plist.estCompletDate!}', style: normalText),
            _slabComnpletedOn(),
            SizedBox(height: 8),
            _checklist(plist: plist),
            _issueReport(),
            verticalSpaceSmall,
            const Divider(height: 20.0, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  Widget SlabCheckList(
      {required MasonryCheck plist, required String masonryId}) {
    Widget _slabcheckStatusOkIcon(InnerBlock tem) {
      // if (plist.slabCheckStatusOk == "1") {
      if (tem.checkStatusOk == "1") {
        return const Icon(Icons.check_circle, color: Colors.green);
      } else {
        return const Icon(Icons.circle_outlined, color: Colors.black45);
      }
    }

    Widget _slabcheckTitle() {
      return Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(plist.headTitle?.toUpperCase() ?? '',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                    color: Colors.black)),
            for (int k = 0; k < plist.innerBlock!.length; k++)
              InkWell(
                onTap: () {
                  var projectId = widget.projectId!;
                  var projectName = widget.projectName!;
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) {
                  //       return MasonryStatusScreen(
                  //         projectId: projectId,
                  //         towarId: widget.towarId,
                  //         projectName: projectName,
                  //         title: strRccTitle,
                  //         plist: plist.innerBlock?[k],
                  //         headId: plist.headId,
                  //         masonryId: masonryId,
                  //         isSlabExist: plist.innerBlock![k].checkStatusOk ==
                  //             "1", // plist.headCheck == "1",
                  //       );
                  //     },
                  //   ),
                  // )
                  //
                  Navigator.of(context)
                      .pushNamed(
                    '/masonryStatusScreen',
                    arguments: NotificationArgs(
                      projectId: projectId,
                      projectName: projectName,
                      towarName: widget.towarName,
                      response: NotificationResponseData(
                        towarId: widget.towarId,
                        headId: plist.headId,
                        // slabNo: plist.slabNo,
                        masonryId: masonryId,
                        masonryNo: strRccTitle,
                        masonryCheckId: plist.innerBlock?[k].checkId,
                      ),
                    ),
                  )
                      .then((value) {
                    offset = '0';
                    // searchTermValue = '';
                    masonryDetailsResponse = [];
                    fetchGetMasonryDetails(contextApi: context);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: plist.innerBlock!.length - 1 == k
                            ? Colors.transparent
                            : Colors.black12,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.only(
                      bottom: plist.innerBlock!.length - 1 == k ? 0 : 8,
                      top: 8),
                  child: Row(
                    children: [
                      Text(
                        plist.innerBlock?[k].checkTitle ?? '',
                      ),
                      const Spacer(),
                      _slabcheckStatusOkIcon(plist.innerBlock![k]),
                      const Icon(Icons.keyboard_arrow_right,
                          color: Colors.black),
                    ],
                  ),
                ),
              ),
            // Row(
            //   children: [
            // _slabcheckStatusOkIcon(),
            //     const Icon(Icons.keyboard_arrow_right, color: Colors.black),
            //   ],
            // ),
          ],
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
          // border: Border.all(
          //   color: Colors.black,
          // ),
          ),
      padding:
          const EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0, bottom: 5.0),
      child: Column(
        children: [
          _slabcheckTitle(),
          verticalSpaceSmall,
          const Divider(height: 20.0, color: Colors.black45),
        ],
      ),
    );
  }

  setReportingToModal() {
    final isMobile = context.isMobile;
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
                actionsPadding: const EdgeInsets.all(12),
                actionsAlignment: MainAxisAlignment.center,
                title: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    "PRINT DRAWINGS",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
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
                      width: isMobile ? 100 : 130,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "CLOSE",
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: isMobile ? 100 : 130,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "SUBMIT",
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 15,
                          fontWeight: FontWeight.bold,
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
                    height: 220,
                    width: isMobile ? 280 : 380,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // for (int i = 0; i < arrReportTo!.length; i++)
                          // Container(
                          //   decoration: const BoxDecoration(
                          //       border: Border(
                          //           bottom: BorderSide(
                          //     color: Colors.grey,
                          //   ))),
                          //   child: RadioListTile<String>(
                          //     contentPadding: EdgeInsets.zero,
                          //     title: Text(
                          //       arrReportTo?[i].reportToName ?? '',
                          //       style: const TextStyle(
                          //         fontSize: 20,
                          //       ),
                          //     ),
                          //     value: arrReportTo?[i].reportToName ?? '',
                          //     groupValue: datIssueController[index]
                          //         .selectReportingToController
                          //         .text,
                          //     onChanged: (value) {
                          //       inspect(arrReportTo?[i]);
                          //       setState(() {
                          //         datIssueController[index]
                          //                 .selectReportingToStrings =
                          //             arrReportTo?[i].reportToId ?? '';
                          //         datIssueController[index]
                          //             .selectReportingToController
                          //             .text = value ?? '';
                          //       });
                          //       Navigator.pop(context);
                          //     },
                          //     controlAffinity:
                          //         ListTileControlAffinity.trailing,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  );
                }));
          });
        });
  }
}

class DrawingsList extends StatelessWidget {
  DrawingsList(
      {Key? key,
      required this.plist,
      this.projectId,
      this.towarId,
      this.projectName,
      required this.afterPopFun,
      // required this.documentPath,
      this.slabNo,
      this.slabId})
      : super(key: key);
  final Drawing plist;
  final String? slabNo;
  final String? slabId;
  final String? projectId;
  final String? towarId;
  final String? projectName;
  // final String documentPath;
  final Function afterPopFun;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0, bottom: 5.0),
      child: Column(
        children: [
          InkWell(
              onTap: () {
                var projectId = this.projectId!;
                var projectName = this.projectName!;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return RevisionRccStructerView(
                        projectId: projectId,
                        drawingId: plist.drawingId,
                        towarId: towarId!,
                        projectName: projectName,
                        projectSubTitle:
                            '${slabNo!} - ${plist.drawingTitle?.toUpperCase()}',
                        drawingVersion: plist.drawingVersion,
                        documentPath: "MASONRY",
                        slabId: slabId,
                      );
                    },
                  ),
                );
              },
              child: _drawingTitle(context)),
          verticalSpaceSmall,
          const Divider(height: 20.0, color: Colors.black45),
        ],
      ),
    );
  }

  Widget _drawingTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _drawingIssueCompleteIcon(context: context),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Text(
            plist.drawingTitle ?? '',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 16.0,
              color: plist.issuse == "0" ? Colors.grey : Colors.black,
            ),
          ),
        ),
        plist.issuse == "1"
            ? OutlinedButton(
                onPressed: () {
                  // var projectId = this.projectId!;
                  // var projectName = this.projectName!;
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) {
                  //       return IssueMasonryReport(
                  //         projectId: projectId,
                  //         towarId: towarId,
                  //         projectName: projectName,
                  //         slabcheckid: plist.masonryCheckId!,
                  //         slabchecktype: '0',
                  //         slabid: slabId,
                  //         drawingTitle: plist.drawingTitle ?? '',
                  //         drawingId: plist.drawingId ?? '',
                  //         checkId: plist.masonryCheckId, // typemacidfk
                  //         headId: '0', //plist.drawingId, // masonrytypeId
                  //         masonryId: slabId,
                  //         checkType: '0',
                  //         //masonryIdfk
                  //       );
                  //     },
                  //   ),
                  // )

                  Navigator.of(context)
                      .pushNamed(
                    '/issueMasonryReportScreen',
                    arguments: NotificationArgs(
                      projectId: projectId,
                      projectName: projectName,
                      // towarName: widget.towarName,
                      response: NotificationResponseData(
                        checkId: plist.masonryCheckId,
                        slabCheckId: plist.masonryCheckId,
                        slabCheckType: '0',
                        towarId: towarId,
                        // slabNo: plist.slabNo,
                        slabId: slabId,
                        drawingTitle: plist.drawingTitle,
                        drawingId: plist.drawingId,
                        headId: '0',
                        masonryId: slabId,
                        checkType: '0',
                      ),
                    ),
                  )
                      .then((value) {
                    afterPopFun();
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 1.0, color: Colors.black45),
                ),
                child: const Text('Issues', style: normalText))
            : const SizedBox(
                width: 70,
              ),
        Row(
          children: [
            _drawingCheckCompleteStatus(),
            const Icon(Icons.keyboard_arrow_right, color: Colors.black),
          ],
        ),
      ],
    );
  }

  Widget _drawingIssueCompleteIcon({required BuildContext context}) {
    if (plist.submitReport == "1") {
      return InkWell(
          onTap: () {
            // var projectId = this.projectId!;
            // var projectName = this.projectName!;
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) {
            //       return IssueMasonryReport(
            //         projectId: projectId,
            //         towarId: towarId,
            //         projectName: projectName,
            //         slabcheckid: plist.masonryCheckId!,
            //         slabchecktype: '0',
            //         slabid: slabId,
            //         drawingTitle: plist.drawingTitle ?? '',
            //         drawingId: plist.drawingId ?? '',
            //         checkId: plist.masonryCheckId, // typemacidfk
            //         headId: '0', //plist.drawingId, // masonrytypeId
            //         masonryId: slabId,
            //         checkType: '0',
            //         //masonryIdfk
            //       );
            //     },
            //   ),
            // );
            Navigator.of(context).pushNamed(
              '/issueMasonryReportScreen',
              arguments: NotificationArgs(
                projectId: projectId,
                projectName: projectName,
                // towarName: widget.towarName,
                response: NotificationResponseData(
                  slabCheckId: plist.masonryCheckId,
                  slabCheckType: '0',
                  towarId: towarId,
                  // slabNo: plist.slabNo,
                  slabId: slabId,
                  drawingTitle: plist.drawingTitle,
                  drawingId: plist.drawingId,
                  headId: '0',
                  masonryId: slabId,
                  checkType: '0',
                  checkId: plist.masonryCheckId,
                ),
              ),
            );
          },
          child: const Icon(Icons.report_problem_outlined, color: Colors.red));
    } else {
      if (plist.verify == "1") {
        return const Icon(Icons.check_circle, color: Colors.blueAccent);
      } else {
        return const Icon(Icons.circle_outlined, color: Colors.black45);
      }
    }
  }

  Widget _drawingCheckCompleteStatus() {
    if (plist.issuse == "1") {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else {
      return const Icon(Icons.circle_outlined, color: Colors.black45);
    }
  }
}
