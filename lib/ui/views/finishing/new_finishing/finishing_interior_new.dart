import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_finishing_interior_new.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/finishing/add_finishing_work.dart';
import 'package:stallion/ui/views/finishing/new_finishing/certify_finishing.dart';
import 'package:stallion/utils/app_url.dart';

class FinishingInteriorNew extends StatefulWidget {
  const FinishingInteriorNew(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.towarName,
      this.headerPart,
      required this.isInterior,
      required this.onTap,
      required this.onTapOpenDropDown,
      required this.selectedDropdownOpen,
      required this.index,
      this.bodyPart})
      : super(key: key);
  final List<HeaderPart>? headerPart;
  final List<List<BodyPart>>? bodyPart;
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String isInterior;
  final int selectedDropdownOpen;
  final VoidCallback onTap;
  final VoidCallback onTapOpenDropDown;

  final int index;

  @override
  State<FinishingInteriorNew> createState() => _FinishingInteriorNewState();
}

class _FinishingInteriorNewState extends State<FinishingInteriorNew> {
  void showCustomConfirmationDialog({
    required BuildContext context,
    required String message,
    required VoidCallback onYesPressed,
    required VoidCallback onNoPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context1, setState2) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              titlePadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: <Widget>[
                Row(
                  children: [
                    InkWell(
                      onTap: onNoPressed,
                      child: Container(
                        width: 220,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'NO',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 1),
                    InkWell(
                      onTap: onYesPressed,
                      child: Container(
                        width: 220,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'YES',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        );
      },
    );
  }

  // bool isDropDownOpen = false;
  // int isDropDownOpenInt = 0;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<List<dynamic>?> setFinishingTypeFlag({
    required String floorId,
    required String id,
    required String ischecked,
  }) async {
    try {
      CustomLoading.progressDialog(isLoading: true, context: context);
      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "floor_id": floorId,
        "id": id,
        "is_checked": ischecked
        // "project_id": widget.projectId ?? '',
        // "towar_id": widget.towarId ?? '',
      };

      if (kDebugMode) {
        print(data);
      }

      var response =
          await apiNetworkHandler.post(AppUrl.setFinishingTypeFlag, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // final dataModel = getFinishingExteriorListNewFromJson(response.body);
        // if (dataModel.response?.errorCode == "0") {
        //   setState(() {});
        // }
      } else {}
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
    } finally {
      // ignore: use_build_context_synchronously
      CustomLoading.progressDialog(isLoading: false, context: context);
    }
    return null;
  }

  Future<List<dynamic>?> setFinishingReadyForPossesion({
    required String floorId,
    required String ischecked,
  }) async {
    try {
      CustomLoading.progressDialog(isLoading: true, context: context);
      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "floor_id": floorId,
        "is_checked": ischecked,
        "project_id": widget.projectId ?? '',
        // "towar_id": widget.towarId ?? '',
      };

      if (kDebugMode) {
        print(data);
      }

      var response =
          await apiNetworkHandler.post(AppUrl.setFinishingReadyPosition, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // final dataModel = getFinishingExteriorListNewFromJson(response.body);
        // if (dataModel.response?.errorCode == "0") {
        //   setState(() {});
        // }
      } else {}
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
    } finally {
      // ignore: use_build_context_synchronously
      CustomLoading.progressDialog(isLoading: false, context: context);
      // showDialog<String>(
      //     barrierDismissible: false,
      //     context: context,
      //     builder: (BuildContext context) => AlertDialog(
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(8), // Set radius to zero
      //           ),
      //           titlePadding: const EdgeInsets.symmetric(vertical: 0),
      //           actionsPadding: const EdgeInsets.symmetric(horizontal: 0),
      //           contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      //           actionsAlignment: MainAxisAlignment.center,
      //           // title: const Text(''),
      //           // content: Text(
      //           //     'Successfully ${isCheck == '1' ? "checked" : "unchecked"} this PO.',
      //           //     style:
      //           //         TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
      //           title: Container(
      //             padding: const EdgeInsets.symmetric(vertical: 20),
      //             decoration: const BoxDecoration(
      //               color: Colors.white,
      //               borderRadius: BorderRadius.only(
      //                 topLeft: Radius.circular(8),
      //                 topRight: Radius.circular(8),
      //               ),
      //             ),
      //             child: Text(
      //               'You have successfully submitted.',
      //               // "Are you sure, You want to ${isChecked ? 'uncheck' : 'check'} this PO?",
      //               style: TextStyle(
      //                 fontSize: 18,
      //                 fontWeight: FontWeight.w600,
      //                 color: Colors.black,
      //               ),
      //               textAlign: TextAlign.center,
      //             ),
      //           ),
      //           actions: <Widget>[
      //             // ElevatedButton(
      //             //   style: ElevatedButton.styleFrom(
      //             //       backgroundColor: Colors.black,
      //             //       fixedSize: const Size.fromWidth(100),
      //             //       padding: const EdgeInsets.all(10),
      //             //       textStyle: const TextStyle(color: Colors.white)),
      //             //   child: const Text('CLOSE',
      //             //       style: TextStyle(
      //             //           fontWeight: FontWeight.normal,
      //             //           fontSize: 14.0,
      //             //           color: Colors.white)),
      //             //   onPressed: () {
      //             //     setState(() {
      //             //       Navigator.pop(context);
      //             //       // Navigator.maybePop(context, true);
      //             //     });
      //             //   },
      //             // ),
      //             InkWell(
      //               onTap: () {
      //                 Navigator.pop(context);
      //               },
      //               child: Container(
      //                 width: 300,
      //                 padding: const EdgeInsets.symmetric(vertical: 8),
      //                 decoration: const BoxDecoration(
      //                   color: Colors.black,
      //                   borderRadius: BorderRadius.only(
      //                     bottomRight: Radius.circular(8),
      //                     bottomLeft: Radius.circular(8),
      //                   ),
      //                 ),
      //                 child: const Text(
      //                   'OK',
      //                   textAlign: TextAlign.center,
      //                   style: TextStyle(
      //                     fontSize: 18,
      //                     fontWeight: FontWeight.w600,
      //                     color: Colors.white,
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // return Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 24),
    //   child: Column(
    //     children: [
    //       const SizedBox(height: 20),
    //       Container(
    //         decoration: BoxDecoration(
    //           border: Border.all(color: Colors.black45),
    //           borderRadius: BorderRadius.circular(8),
    //         ),
    //         child: Column(
    //           children: [
    //             Row(
    //               children: [
    //                 Expanded(
    //                   child: SingleChildScrollView(
    //                     scrollDirection: Axis.horizontal,
    //                     child: Row(
    //                       children: [
    //                         for (int d = 0; d < widget.headerPart!.length; d++)
    //                           Container(
    //                             decoration: const BoxDecoration(
    //                               // color: Colors.black12,
    //                               border: Border(
    //                                 right: BorderSide(color: Colors.black12),
    //                                 bottom: BorderSide(color: Colors.black12),
    //                               ),
    //                             ),
    //                             width: 100,
    //                             height: 60,
    //                             child: Column(
    //                               crossAxisAlignment: CrossAxisAlignment.center,
    //                               mainAxisAlignment: MainAxisAlignment.center,
    //                               children: [
    //                                 Text(
    //                                   widget.headerPart?[d].name ?? '',
    //                                   textAlign: TextAlign.center,
    //                                   style: TextStyle(
    //                                     fontSize: 15,
    //                                     fontWeight: FontWeight.w500,
    //                                     color: Colors.black,
    //                                   ),
    //                                 ),
    //                                 Text(
    //                                   '10 / 100',
    //                                   textAlign: TextAlign.center,
    //                                   style: TextStyle(
    //                                     fontSize: 15,
    //                                     fontWeight: FontWeight.w500,
    //                                     color: Colors.black,
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //                       ],
    //                     ),
    //                   ),
    //                 ),
    //                 InkWell(
    //                   onTap: () {
    //                     setState(() {
    //                       isDropDownOpen = !isDropDownOpen;
    //                     });
    //                   },
    //                   child: Container(
    //                     padding: const EdgeInsets.symmetric(horizontal: 20),
    //                     child: const Icon(Icons.keyboard_arrow_down_rounded),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             if (isDropDownOpen)
    //               Row(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 mainAxisAlignment: MainAxisAlignment.start,
    //                 children: [
    //                   Column(
    //                     children: [
    //                       for (int p = 0; p < widget.bodyPart!.length; p++)
    //                         titleCard(title: widget.bodyPart?[p][0].name ?? ''),
    //                       // titleCard(title: "Door"),
    //                       // titleCard(title: "Door"),
    //                     ],
    //                   ),
    //                   Expanded(
    //                     child: SingleChildScrollView(
    //                       scrollDirection: Axis.horizontal,
    //                       child: Column(
    //                         children: [
    //                           // Row(
    //                           //   children: [
    //                           //     for (int k = 0; k < 13; k++)
    //                           //       titleCard(title: "Title"),
    //                           //   ],
    //                           // ),
    //                           for (int i = 0; i < widget.bodyPart!.length; i++)
    //                             Row(
    //                               children: [
    //                                 for (int k = 0;
    //                                     k < widget.bodyPart![i].length;
    //                                     k++)
    //                                   finishingCard(
    //                                       usedValue: widget
    //                                               .bodyPart![i][k].consumeQty ??
    //                                           '',
    //                                       totalValue: widget.bodyPart![i][k]
    //                                               .finishingQty ??
    //                                           '',
    //                                       onTap: () {}),
    //                               ],
    //                             ),
    //                         ],
    //                       ),
    //                     ),
    //                   )
    //                 ],
    //               ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Text(
                  // '${widget.headerPart?[0].name} ${double.parse(widget.headerPart?[0].consumeQty ?? '0')}  ${double.parse(widget.headerPart?[0].finishingQty ?? '0')}',
                  double.parse(widget.headerPart?[0].consumeQty ?? '0') <= 0.0
                      ? "${widget.headerPart?[0].name}"
                      : '${widget.headerPart?[0].name} (${((double.parse(widget.headerPart?[0].consumeQty ?? '0') * 100) / double.parse(widget.headerPart?[0].finishingQty ?? '0')).toStringAsFixed(2)} %)',
                  // '${widget.headerPart?[0].name} (${((double.parse(widget.headerPart?[0].consumeQty ?? '0') * 100) / double.parse(widget.headerPart?[0].finishingQty ?? '0')).toStringAsFixed(2)} %)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                  // decoration: BoxDecoration(
                  //     border: Border.all(color: Colors.black),
                  //     borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '(Ready For Possession)' ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          showCustomConfirmationDialog(
                            context: context,
                            message:
                                "Are you sure, You want to mark it as a ready for possession?",
                            onYesPressed: () {
                              setState(() {
                                // if (widget.headerPart?[0].readyPosition == "1") {
                                //   widget.headerPart?[0].readyPosition = "0";
                                //   for (int i = 0;
                                //       i < widget.bodyPart!.length - 1;
                                //       i++) {
                                //     widget.bodyPart?[i][0].readyPosition = "0";
                                //     print(
                                //         '${widget.bodyPart?[i][0].name}==============');
                                //   }
                                // } else {
                                //   widget.headerPart?[0].readyPosition = "1";
                                //   for (int i = 0;
                                //       i < widget.bodyPart!.length - 1;
                                //       i++) {
                                //     widget.bodyPart?[i][0].readyPosition = "1";
                                //     print(
                                //         '${widget.bodyPart?[i][0].name}==============');
                                //   }
                                // }
                                String allFloorIds = "";

                                if (widget.headerPart?[0].readyPosition ==
                                    "1") {
                                  widget.headerPart?[0].readyPosition = "0";
                                  for (int i = 0;
                                      i < widget.bodyPart!.length - 1;
                                      i++) {
                                    widget.bodyPart?[i][0].readyPosition = "0";
                                    allFloorIds +=
                                        '${widget.bodyPart?[i][0].floorId},';
                                  }
// Remove trailing comma, if needed
                                  if (allFloorIds.endsWith(',')) {
                                    allFloorIds = allFloorIds.substring(
                                        0, allFloorIds.length - 1);
                                  }

                                  print("All floorIds: $allFloorIds");
                                  setFinishingReadyForPossesion(
                                      floorId: allFloorIds, ischecked: '0');
                                } else {
                                  widget.headerPart?[0].readyPosition = "1";
                                  for (int i = 0;
                                      i < widget.bodyPart!.length - 1;
                                      i++) {
                                    widget.bodyPart?[i][0].readyPosition = "1";
                                    allFloorIds +=
                                        '${widget.bodyPart?[i][0].floorId},';
                                  }
// Remove trailing comma, if needed
                                  if (allFloorIds.endsWith(',')) {
                                    allFloorIds = allFloorIds.substring(
                                        0, allFloorIds.length - 1);
                                  }
                                  Navigator.pop(context);
                                  print("All floorIds: $allFloorIds");
                                  // Close the dialog after action
                                  setFinishingReadyForPossesion(
                                      floorId: allFloorIds, ischecked: '1');
                                }
                              });
                            },
                            onNoPressed: () {
                              Navigator.pop(context); // Just close dialog
                            },
                          );
                        },
                        child: Icon(
                          // filteredAssignTo()?[i].isSelected == true
                          widget.headerPart?[0].readyPosition == "1"
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 22,
                          color: widget.headerPart?[0].readyPosition == "1"
                              ? Colors.green
                              : Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black45),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Row(
                //   children: [
                //     Expanded(
                //       child: SingleChildScrollView(
                //         scrollDirection: Axis.horizontal,
                //         child: Row(
                //           children: [
                //             for (int d = 0; d < widget.headerPart!.length; d++)
                //               Container(
                //                 decoration: const BoxDecoration(
                //                   // color: Colors.black12,
                //                   border: Border(
                //                     right: BorderSide(color: Colors.black12),
                //                     bottom: BorderSide(color: Colors.black12),
                //                   ),
                //                 ),
                //                 width: 100,
                //                 height: 60,
                //                 child: Column(
                //                   crossAxisAlignment: CrossAxisAlignment.center,
                //                   mainAxisAlignment: MainAxisAlignment.center,
                //                   children: [
                //                     Text(
                //                       'widget' ?? '',
                //                       textAlign: TextAlign.center,
                //                       style: TextStyle(
                //                         fontSize: 15,
                //                         fontWeight: FontWeight.w500,
                //                         color: Colors.black,
                //                       ),
                //                     ),
                //                     Text(
                //                       '10 / 100',
                //                       textAlign: TextAlign.center,
                //                       style: TextStyle(
                //                         fontSize: 15,
                //                         fontWeight: FontWeight.w500,
                //                         color: Colors.black,
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //           ],
                //         ),
                //       ),
                //     ),
                //     InkWell(
                //       onTap: () {
                //         setState(() {
                //           isDropDownOpen = !isDropDownOpen;
                //         });
                //       },
                //       child: Container(
                //         padding: const EdgeInsets.symmetric(horizontal: 20),
                //         child: const Icon(Icons.keyboard_arrow_down_rounded),
                //       ),
                //     ),
                //   ],
                // ),
                // if (isDropDownOpen)
                InkWell(
                  onTap: widget.onTapOpenDropDown,
                  // onTap: () {
                  //   setState(() {
                  //     // isDropDownOpen = !isDropDownOpen;
                  //     if (widget.index == widget.selectedDropdownOpen) {
                  //       isDropDownOpenInt = -1;
                  //     } else {
                  //       isDropDownOpenInt = widget.index;
                  //     }
                  //   });
                  // },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          for (int p = 0;
                              p <
                                  (
                                      // !isDropDownOpen
                                      widget.bodyPart!.length - 1);
                              p++)
                            //  for (int d = 0; d < widget.headerPart!.length; d++)
                            Column(
                              children: [
                                if (p == 0)
                                  Container(
                                    height: 92,
                                    child: titleCard(
                                        isCertify: false,
                                        onTapCertify: () {},
                                        title: 'Unit No.',
                                        onTapSwitch: (value) {},
                                        isTapSwitch: false,
                                        isNotVisible: false),
                                  ),
                                if (widget.index == widget.selectedDropdownOpen

                                    // isDropDownOpen
                                    )
                                  titleCard(
                                      isCertify: widget.bodyPart?[p][0]
                                                  .readyPosition ==
                                              "1"
                                          ? true
                                          : false,
                                      onTapCertify: () {
                                        showCustomConfirmationDialog(
                                          context: context,
                                          message:
                                              "Are you sure, You want to mark it as a ready for possession?",
                                          onYesPressed: () {
                                            setState(() {
                                              if (widget.bodyPart?[p][0]
                                                      .readyPosition ==
                                                  "1") {
                                                widget.bodyPart?[p][0]
                                                    .readyPosition = '0';
                                                setFinishingReadyForPossesion(
                                                    floorId: widget
                                                            .bodyPart?[p][0]
                                                            .floorId ??
                                                        '',
                                                    ischecked: '0');
                                              } else {
                                                widget.bodyPart?[p][0]
                                                    .readyPosition = '1';
                                                setFinishingReadyForPossesion(
                                                    floorId: widget
                                                            .bodyPart?[p][0]
                                                            .floorId ??
                                                        '',
                                                    ischecked: '1');
                                              }
                                            });
                                            Navigator.pop(
                                                context); // Close the dialog after action
                                          },
                                          onNoPressed: () {
                                            Navigator.pop(
                                                context); // Just close dialog
                                          },
                                        );
                                      },
                                      title:
                                          '${widget.bodyPart?[p][0].name} \n${widget.bodyPart?[p][0].floorArea}',
                                      isTapSwitch:
                                          widget.bodyPart?[p][0].flatType == '1'
                                              ? true
                                              : false,
                                      onTapSwitch: (value) {
                                        setState(() {
                                          widget.bodyPart?[p][0].flatType =
                                              value == true ? '1' : '0';
                                        });
                                        for (int i = 1;
                                            i < widget.bodyPart![p].length;
                                            i++) {
                                          print(widget
                                              .bodyPart![p][i].finishingQty);
                                          print(
                                              '------------${widget.bodyPart![widget.bodyPart!.length - 1][i].finishingQty}');
                                          setState(() {
                                            if (value == true) {
                                              if (widget.bodyPart![p][i]
                                                      .flatType !=
                                                  '1') {
                                                widget
                                                    .bodyPart![widget.bodyPart!.length - 1]
                                                        [i]
                                                    .finishingQty = (double.parse(widget
                                                                .bodyPart![widget.bodyPart!.length - 1]
                                                                    [i]
                                                                .finishingQty ??
                                                            '0') +
                                                        double.parse(widget
                                                                    .bodyPart![p]
                                                                        [i]
                                                                    .finishingQty
                                                                    ?.trim() !=
                                                                ""
                                                            ? widget.bodyPart![p][i].finishingQty ??
                                                                ''
                                                            : "0"))
                                                    .toStringAsFixed(0);
                                              }
                                            } else {
                                              if (widget.bodyPart![p][i]
                                                      .flatType !=
                                                  '0') {
                                                widget
                                                    .bodyPart![widget.bodyPart!.length - 1]
                                                        [i]
                                                    .finishingQty = (double.parse(widget
                                                                .bodyPart![widget.bodyPart!.length - 1]
                                                                    [i]
                                                                .finishingQty ??
                                                            '0') -
                                                        double.parse(widget
                                                                    .bodyPart![p]
                                                                        [i]
                                                                    .finishingQty
                                                                    ?.trim() !=
                                                                ""
                                                            ? widget.bodyPart![p][i].finishingQty ??
                                                                ''
                                                            : "0"))
                                                    .toStringAsFixed(0);
                                              }
                                            }
                                            widget.bodyPart![p][i].flatType =
                                                value == true ? '1' : '0';
                                          });
                                        }

                                        setFinishingTypeFlag(
                                            floorId: widget
                                                    .bodyPart![p][0].floorId ??
                                                '',
                                            id: '',
                                            ischecked:
                                                value == true ? '1' : '0');
                                      },
                                      isNotVisible: true),
                              ],
                            )
                          // titleCard(title: "Door"),
                          // titleCard(title: "Door"),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            children: [
                              // Row(
                              //   children: [
                              //     for (int k = 0; k < 13; k++)
                              //       titleCard(title: "Title"),
                              //   ],
                              // ),

                              // for (int i = 0;
                              //     i <
                              //         (!isDropDownOpen
                              //             ? 1
                              //             : widget.bodyPart!.length);
                              //     i++)
                              //   Row(
                              //     children: [
                              //       for (int k = 1;
                              //           k < widget.bodyPart![i].length;
                              //           k++)
                              for (int i = 0;
                                  i <
                                      (
                                          // !isDropDownOpen //
                                          widget.bodyPart!.length - 1);
                                  i++)
                                Row(
                                  children: [
                                    for (int k = 1;
                                        k < widget.bodyPart![i].length;
                                        k++)

                                      // widget.headerPart
                                      Column(
                                        children: [
                                          if (i == 0)
                                            // Column(
                                            //   children: [
                                            titleCardHead(
                                              title:
                                                  widget.headerPart?[k].name ??
                                                      '',
                                              certi: widget
                                                      .bodyPart![widget
                                                              .bodyPart!
                                                              .length -
                                                          1][k]
                                                      .consumeQty ??
                                                  '',
                                              qty: widget
                                                      .bodyPart![widget
                                                              .bodyPart!
                                                              .length -
                                                          1][k]
                                                      .finishingQty ??
                                                  '',

                                              // certi:
                                              //     (widget.bodyPart!.length - 1)
                                              //             .toString() ??
                                              //         '',
                                              // qty: (widget
                                              //             .bodyPart![widget
                                              //                     .bodyPart!
                                              //                     .length -
                                              //                 1]
                                              //             .length -
                                              //         1)
                                              //     .toString(),
                                            ),
                                          // Text(
                                          //   '100 / 100',
                                          //   // textAlign: TextAlign.center,
                                          //   style: const TextStyle(
                                          //     fontSize: 15,
                                          //     fontWeight: FontWeight.w400,
                                          //     color: Colors.black,
                                          //   ),
                                          // ),
                                          //   ],
                                          // ),
                                          if (widget.index ==
                                                  widget.selectedDropdownOpen
                                              // isDropDownOpen
                                              )
                                            finishingCard(
                                                isCertify: i ==
                                                        widget.bodyPart!
                                                                .length -
                                                            1
                                                    ? false
                                                    : true,
                                                usedValue: widget
                                                        .bodyPart![i][k]
                                                        .consumeQty ??
                                                    '0',
                                                totalValue: widget
                                                            .bodyPart![i][k]
                                                            .finishingQty
                                                            ?.trim() !=
                                                        ""
                                                    ? widget.bodyPart![i][k]
                                                            .finishingQty ??
                                                        ''
                                                    : "0",
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) {
                                                        return CertifyFinishingScreen(
                                                          certifiedQty: double
                                                              .parse(widget
                                                                      .bodyPart![
                                                                          i][k]
                                                                      .consumeQty ??
                                                                  '0'),
                                                          totalQty: double
                                                              .parse(widget
                                                                      .bodyPart![
                                                                          i][k]
                                                                      .finishingQty ??
                                                                  '0'),
                                                          floorName:
                                                              '${widget.bodyPart?[i][0].name} - ${widget.headerPart?[0].name}',
                                                          finishingMaterial:
                                                              widget.headerPart?[k]
                                                                      .name ??
                                                                  '',
                                                          projectId:
                                                              widget.projectId,
                                                          towarId:
                                                              widget.towarId!,
                                                          projectName: widget
                                                              .projectName,
                                                          towarName:
                                                              widget.towarName!,
                                                          isInterior: "2",
                                                          finishingId: widget
                                                                  .bodyPart![i]
                                                                      [k]
                                                                  .id ??
                                                              '',
                                                          floorId: widget
                                                                  .bodyPart![i]
                                                                      [k]
                                                                  .floorId ??
                                                              '',
                                                        );
                                                        // return AddFinishingWork(
                                                        //   title:
                                                        //       '${widget.bodyPart![i][0].name} (${widget.headerPart![k].name})',
                                                        //   isInterior:
                                                        //       widget.isInterior,
                                                        //   // ? "2"
                                                        //   // : "1",
                                                        //   finishingDetails:
                                                        //       widget.bodyPart![
                                                        //           i][k],
                                                        //   floorName: widget
                                                        //       .bodyPart![i][0]
                                                        //       .name,
                                                        //   floorId: widget
                                                        //       .bodyPart![i][k]
                                                        //       .floorId,
                                                        //   // flatDetailsListSelected:
                                                        //   //     widget.flatDetailsListSelected,
                                                        //   // finishingListData:
                                                        //   //     finishingListData?[index],
                                                        //   projectId:
                                                        //       widget.projectId,
                                                        //   towarId:
                                                        //       widget.towarId!,
                                                        //   projectName: widget
                                                        //       .projectName,
                                                        //   towarName:
                                                        //       widget.towarName!,
                                                        //   // slabName: "Internal Paint (R-101)",
                                                        // );
                                                      },
                                                    ),
                                                  ).then((value) {
                                                    widget.onTap();
                                                  });
                                                },
                                                isTapSwitch: widget
                                                            .bodyPart![i][k]
                                                            .flatType ==
                                                        '1'
                                                    ? true
                                                    : false,
                                                onTapSwitch: (value) {
                                                  print(
                                                      "${value}------------------vallllll");
                                                  setState(() {
                                                    widget.bodyPart![i][k]
                                                            .flatType =
                                                        value == true
                                                            ? '1'
                                                            : '0';
                                                    if (value == true) {
                                                      widget
                                                          .bodyPart![widget.bodyPart!.length - 1]
                                                              [k]
                                                          .finishingQty = (double.parse(widget
                                                                      .bodyPart![widget.bodyPart!.length - 1]
                                                                          [k]
                                                                      .finishingQty ??
                                                                  '0') +
                                                              double.parse(widget
                                                                          .bodyPart![i]
                                                                              [k]
                                                                          .finishingQty
                                                                          ?.trim() !=
                                                                      ""
                                                                  ? widget.bodyPart![i][k].finishingQty ?? ''
                                                                  : "0"))
                                                          .toStringAsFixed(0);
                                                    } else {
                                                      widget
                                                          .bodyPart![widget.bodyPart!.length - 1]
                                                              [k]
                                                          .finishingQty = (double.parse(widget
                                                                      .bodyPart![widget.bodyPart!.length - 1]
                                                                          [k]
                                                                      .finishingQty ??
                                                                  '0') -
                                                              double.parse(widget
                                                                          .bodyPart![i]
                                                                              [k]
                                                                          .finishingQty
                                                                          ?.trim() !=
                                                                      ""
                                                                  ? widget.bodyPart![i][k].finishingQty ?? ''
                                                                  : "0"))
                                                          .toStringAsFixed(0);
                                                    }
                                                  });
                                                  print(widget.bodyPart![i][k]
                                                      .flatType);
                                                  setFinishingTypeFlag(
                                                      floorId: widget
                                                              .bodyPart![i][k]
                                                              .floorId ??
                                                          '',
                                                      id: widget.bodyPart![i][k]
                                                              .id ??
                                                          '',
                                                      ischecked: value == true
                                                          ? '1'
                                                          : '0');
                                                  // setState(() {});

                                                  //            usedValue: widget
                                                  //         .bodyPart![i][k]
                                                  //         .consumeQty ??
                                                  //     '0',
                                                  // totalValue: widget
                                                  //             .bodyPart![i][k]
                                                  //             .finishingQty
                                                  //             ?.trim() !=
                                                  //         ""
                                                  //     ? widget.bodyPart![i][k]
                                                  //             .finishingQty ??
                                                  //         ''
                                                  //     : "0",
                                                }),
                                        ],
                                      )
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 92,
                        color: Colors.black12,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 23),
                        child: Center(
                            child: widget.index == widget.selectedDropdownOpen
                                //  isDropDownOpen
                                ? const Icon(Icons.keyboard_arrow_up_rounded)
                                : const Icon(
                                    Icons.keyboard_arrow_down_rounded)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color getColorCode({required double quantity, required double certifyQty}) {
  if (certifyQty == 0.00 && quantity > 0.0) {
    // return const Color.fromRGBO(244, 67, 54, 1);
    return Colors.transparent;
  } else if (quantity == certifyQty && certifyQty != 0.00 && quantity != 0.00) {
    return Colors.green;
  } else if (certifyQty == 0.00 && quantity == 0.00) {
    return Colors.transparent;
  } else {
    return const Color.fromRGBO(255, 235, 59, 1);
  }
}

Widget finishingCard(
    {required String usedValue,
    required String totalValue,
    required VoidCallback onTap,
    required bool isCertify,
    required ValueChanged onTapSwitch,
    required bool isTapSwitch}) {
  print(totalValue);
  return InkWell(
    onTap: isCertify ? onTap : () {},
    child: Container(
      decoration: BoxDecoration(
          color: isCertify ? Colors.transparent : Colors.black12,
          border: const Border(
            right: BorderSide(color: Colors.black12),
            bottom: BorderSide(color: Colors.black12),
          )),
      width: 100,
      height: 86,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // if (isTapSwitch) Text("Raw Flat"),
          // if (isTapSwitch)
          Center(
            child: Text(
              '(${double.parse(usedValue).toStringAsFixed(2)} / ${double.parse(totalValue).toStringAsFixed(2)})',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 0),
          Container(
            width: 50,
            height: 3,
            decoration: BoxDecoration(
              color: getColorCode(
                quantity: double.parse(totalValue),
                certifyQty: double.parse(usedValue),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 0),
          if (isCertify && isTapSwitch)
            const Center(
              child: Text(
                'Certify',
                textAlign: TextAlign.center,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  decorationColor: Color.fromRGBO(26, 35, 126, 1),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(26, 35, 126, 1),
                ),
              ),
            ),
          // Icon(Icons.switch)
          // Switch(

          //   // This bool value toggles the switch.
          //   value: isTapSwitch,
          //   activeColor: Colors.red,
          //   onChanged: onTapSwitch,
          //   // (bool value) {
          //   // This is called when the user toggles the switch.
          //   // setState(() {
          //   //   light = value;
          //   // });
          //   // },
          // ),
          Container(
            width: 30, // Smaller than default
            height: 20,
            child: FittedBox(
              child: Switch(
                value: isTapSwitch,
                activeColor: Colors.green,
                onChanged: onTapSwitch,
              ),
            ),
          )
        ],
      ),
    ),
  );
}

Widget titleCard(
    {required String title,
    required ValueChanged onTapSwitch,
    required VoidCallback onTapCertify,
    required bool isTapSwitch,
    required bool isNotVisible,
    required bool isCertify}) {
  return Container(
    decoration: const BoxDecoration(
        color: Color.fromARGB(31, 0, 0, 0),
        border: Border(
          right: BorderSide(color: Colors.black12),
          bottom: BorderSide(color: Colors.black12),
        )),
    width: 100,
    height: 86,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${title}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        if (isNotVisible == true)
          Container(
            width: 30, // Smaller than default
            height: 20,
            child: FittedBox(
              child: Switch(
                value: isTapSwitch,
                activeColor: Colors.green,
                onChanged: onTapSwitch,
              ),
            ),
          ),
        if (isNotVisible == true)
          InkWell(
            onTap: onTapCertify,
            child: Icon(
              // filteredAssignTo()?[i].isSelected == true
              isCertify == true
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              size: 22,
              color: isCertify == true ? Colors.green : Colors.black,
            ),
          )
      ],
    ),
  );
}

Widget titleCardHead(
    {required String title, required String qty, required String certi}) {
  return Container(
    decoration: const BoxDecoration(
        color: Colors.black12,
        border: Border(
          right: BorderSide(color: Colors.black12),
          bottom: BorderSide(color: Colors.black12),
        )),
    width: 100,
    height: 92,
    child: Column(
      children: [
        Container(
          height: 70,
          width: 100,
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.fade,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
        Row(
          // crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '($certi / $qty)',
              textAlign: TextAlign.center,
              overflow: TextOverflow.fade,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            if (certi == qty && certi != "0" && qty != "0")
              const Icon(
                Icons.check_circle_outline_sharp,
                color: Colors.green,
                size: 20,
              )
          ],
        ),
      ],
    ),
  );
}
