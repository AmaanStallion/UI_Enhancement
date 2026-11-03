import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' show Random;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/nodee.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/src/drag_and_drop.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/src/tree_controller.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/src/tree_indentation.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/src/tree_view.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/models/ws_get_pms_structure.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/provider/home_provider/fetch_api_provider.dart';
import '../../../../utils/api_network_call.dart';
import '../provider/provider_registration.dart';
import 'gantt_chart.dart';
import 'pms_view/drag_and_drop_tree_tile.dart';
import 'shared.dart' show watchAnimationDurationSetting;
import 'package:pdf/widgets.dart' as pdfLib;

typedef IsExtraHolidayFunc = bool Function(BuildContext context, DateTime date);

extension on TreeDragAndDropDetails<Node> {
  T mapDropPosition<T>({
    required T Function() whenAbove,
    required T Function() whenInside,
    required T Function() whenBelow,
  }) {
    final double oneThirdOfTotalHeight = targetBounds.height * 0.3;
    final double pointerVerticalOffset = dropPosition.dy;

    if (pointerVerticalOffset < oneThirdOfTotalHeight) {
      return whenAbove();
    } else if (pointerVerticalOffset < oneThirdOfTotalHeight * 2) {
      return whenInside();
    } else {
      return whenBelow();
    }
  }
}

class DragAndDropTreeView extends ConsumerStatefulWidget {
  const DragAndDropTreeView({
    super.key,
    this.scroll,
    this.controller,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
  });
  final String? projectId;
  final String? towarId;
  final ScrollPhysics? scroll;
  final ScrollController? controller;
  final String? projectName;
  final String? towarName;
  @override
  ConsumerState<DragAndDropTreeView> createState() =>
      _DragAndDropTreeViewState();
}

class _DragAndDropTreeViewState extends ConsumerState<DragAndDropTreeView> {
  NetworkHandler apiNetworkHandler = NetworkHandler();

  ScrollController scrollLeftRightController = ScrollController();
  ScrollController scrollRightTopBottomController = ScrollController();
  ScrollController scrollLeftTopBottomController = ScrollController();
  GlobalKey yourKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // ref.read(fetchApiProvider).fetchRecords(
    //       projectId: widget.projectId ?? '',
    //       towarId: widget.towarId ?? '',
    //     );
  }

  @override
  void dispose() {
    // scrollLeftTopBottomController.dispose();
    // scrollRightTopBottomController.dispose();
    // scrollLeftTopBottomController.dispose();
    super.dispose();
  }

  void onNodeAccepted(TreeDragAndDropDetails<Node> details) {
    Node? newParent;
    int newIndex = 0;

    details.mapDropPosition(
      whenAbove: () {
        // Insert the dragged node as the previous sibling of the target node.
        newParent = details.targetNode.parent;
        newIndex = details.targetNode.index;
      },
      whenInside: () {
        // Insert the dragged node as the last child of the target node.
        newParent = details.targetNode;
        newIndex = details.targetNode.children.length;

        // Ensure that the dragged node is visible after reordering.
        ref
            .watch(fetchApiProvider)
            .treeController
            .setExpansionState(details.targetNode, true);
      },
      whenBelow: () {
        // Insert the dragged node as the next sibling of the target node.
        newParent = details.targetNode.parent;
        newIndex = details.targetNode.index + 1;
      },
    );

    (newParent ?? ref.watch(fetchApiProvider).root)
        .insertChild(newIndex, details.draggedNode);
  }

  late final DateTime? startDate12; // = DateTime(2023, 9, 1); // year month day
  late final DateTime endDate12; //= DateTime(2023, 11, 27);
  String getDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  Future<void> captureAndSaveAsPdf() async {
    // Create a PDF document
    final pdf = pdfLib.Document();

    // Generate an image of the screen content (you can use a GlobalKey to capture your screen)
    final image = await captureScreenAsImage();

    // Add the image to the PDF
    pdf.addPage(pdfLib.Page(
      build: (context) {
        return pdfLib.Center(
          child: pdfLib.Image(pdfLib.MemoryImage(image)),
        );
      },
    ));

    // Save the PDF to a file
    final output = await getTemporaryDirectory();
    final pdfFile = File("${output.path}/screen.pdf");
    await pdfFile.writeAsBytes(await pdf.save());

    // print('PDF saved to: ${pdfFile.path}');
  }

  Future<Uint8List> captureScreenAsImage() async {
    final boundary =
        yourKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    return Uint8List.view(bytes.buffer);
  }

  double xOffset = 0.0;
  String hoverID = '';

  @override
  Widget build(BuildContext context) {
    ref.read(fetchApiProvider).arrWidget.clear();
    scrollRightTopBottomController.addListener(() {
      scrollLeftTopBottomController
          .jumpTo(scrollRightTopBottomController.offset);
    });
    scrollLeftTopBottomController.addListener(() {
      scrollRightTopBottomController
          .jumpTo(scrollLeftTopBottomController.offset);
    });

    /*scrollLeftRightController.addListener(() {
      //print('Called');
      setState(() {
        xOffset =  (element.dict?.pmsTotalDays - 20) < scrollLeftRightController.offset ? MediaQuery.of(context).size.width - 120 : scrollLeftRightController.offset + 20;
      });
    });*/

    final IndentGuide indentGuide = DefaultIndentGuide.of(context);
    final BorderSide borderSide = BorderSide(
      color: Theme.of(context).colorScheme.outline,
      width: indentGuide is AbstractLineGuide ? indentGuide.thickness : 2.0,
    );

    List<DateTime> dateList = [];
    List<DateTime> mondayDates = [];
    List<int> daysBetweenMondays = [];
    List<MonthInfo> monthInfoList = [];
    List<MonthInfoForMonth> monthInfoForMonthList = [];
    List<YearInfo> yearInfoList = [];

    double getDayWidth() {
      if (ref.watch(homeProvider).isSelectedFilterView == 'DAYS') {
        return 40;
      } else if (ref.watch(homeProvider).isSelectedFilterView == 'WEEK') {
        return 11.428;
      } else if (ref.watch(homeProvider).isSelectedFilterView == 'MONTH') {
        return 4;
      } else if (ref.watch(homeProvider).isSelectedFilterView == 'YEAR') {
        return 2;
      } else {
        return 0;
      }
    }

    if (ref.watch(fetchApiProvider).pmsStartDateFromResponse != null &&
        ref.watch(fetchApiProvider).pmsEndDateFromResponse != null) {
      for (var i = ref.watch(fetchApiProvider).pmsStartDateFromResponse;
          i!.isBefore(ref.watch(fetchApiProvider).pmsEndDateFromResponse!) ||
              i.isAtSameMomentAs(
                  ref.watch(fetchApiProvider).pmsEndDateFromResponse!);
          i = i.add(const Duration(days: 1))) {
        dateList.add(i);
      }

      int daysCount = 0;

      for (int i = 0; i < dateList.length; i++) {
        if (dateList[i].weekday == DateTime.monday) {
          if (daysCount > 0) {
            daysBetweenMondays.add(daysCount);
          }
          daysCount = 1; // Reset to 1 to count the current Monday
          mondayDates.add(dateList[i]);
        } else {
          if (i == 0) {
            mondayDates.add(dateList[i]);
          }
          daysCount++;
        }
      }

      if (daysCount > 0) {
        daysBetweenMondays.add(daysCount);
      }

      DateTime startDate =
          ref.watch(fetchApiProvider).pmsStartDateFromResponse!;
      DateTime endDate = ref.watch(fetchApiProvider).pmsEndDateFromResponse!;

      String _getMonthName(int month) {
        final monthNames = [
          "January",
          "February",
          "March",
          "April",
          "May",
          "June",
          "July",
          "August",
          "September",
          "October",
          "November",
          "December"
        ];
        return monthNames[month - 1];
      }

      while (
          startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate)) {
        final int daysInMonth =
            DateTime(startDate.year, startDate.month + 1, 0).day;
        final int daysUntilEndOfMonth = daysInMonth - startDate.day + 1;

        if (startDate.month == endDate.month &&
            startDate.year == endDate.year) {
          monthInfoList.add(MonthInfo(
            _getMonthName(startDate.month),
            endDate.day - startDate.day + 1,
            startDate.year,
          ));
          break;
        } else {
          monthInfoList.add(MonthInfo(
            _getMonthName(startDate.month),
            daysUntilEndOfMonth,
            startDate.year,
          ));
        }

        startDate = DateTime(startDate.year, startDate.month + 1, 1);
      }

      DateTime startDate1 =
          ref.watch(fetchApiProvider).pmsStartDateFromResponse!; // Start date
      DateTime endDate1 =
          ref.watch(fetchApiProvider).pmsEndDateFromResponse!; // End date

      while (startDate1.isBefore(endDate1) ||
          startDate1.isAtSameMomentAs(endDate1)) {
        final int daysInMonth =
            DateTime(startDate1.year, startDate1.month + 1, 0).day;

        if (startDate1.month == endDate1.month &&
            startDate1.year == endDate1.year) {
          // final int daysBetween = endDate.day - startDate.day + 1;
          final int daysBetween = endDate1.day - startDate1.day + 1;
          monthInfoForMonthList.add(MonthInfoForMonth(
            _getMonthName(startDate1.month),
            startDate1,
            endDate1,
            daysBetween,
          ));
          break;
        } else {
          final DateTime lastDayOfMonth =
              DateTime(startDate1.year, startDate1.month, daysInMonth);
          final int daysBetween = lastDayOfMonth.day - startDate1.day + 1;

          monthInfoForMonthList.add(MonthInfoForMonth(
            _getMonthName(startDate1.month),
            startDate1,
            lastDayOfMonth,
            daysBetween,
          ));
        }

        startDate1 = DateTime(startDate1.year, startDate1.month + 1, 1);
      }

      DateTime startDate2 =
          ref.watch(fetchApiProvider).pmsStartDateFromResponse!; // Start date
      DateTime endDate2 =
          ref.watch(fetchApiProvider).pmsEndDateFromResponse!; // End date

      while (startDate2.isBefore(endDate2) ||
          startDate2.isAtSameMomentAs(endDate2)) {
        // final int daysInYear = DateTime(startDate2.year + 1, 1, 0)
        //     .difference(DateTime(startDate2.year, 1, 1))
        //     .inDays;

        if (startDate2.year == endDate2.year) {
          final int daysBetween = endDate2.difference(startDate2).inDays + 1;
          yearInfoList.add(YearInfo(
            startDate2.year,
            startDate2,
            endDate2,
            daysBetween,
          ));
          break;
        } else {
          final DateTime lastDayOfYear = DateTime(startDate2.year, 12, 31);
          final int daysBetween =
              lastDayOfYear.difference(startDate2).inDays + 1;
          yearInfoList.add(YearInfo(
            startDate2.year,
            startDate2,
            lastDayOfYear,
            daysBetween,
          ));
        }

        startDate2 = DateTime(startDate2.year + 1, 1, 1);
      }
    }

    double getScrollPosition(DateTime startDate, Duration difference) {
      double temp = 0;
      if (difference.inDays == 0 || difference.inDays < 4) {
        temp = 0;
      } else {
        temp = (difference.inDays * getDayWidth()) -
            (ref
                        .watch(fetchApiProvider)
                        .pmsStartDateFromResponse!
                        .difference(startDate)
                        .inDays >
                    4
                ? 0
                : getDayWidth() * 4);
      }
      return temp;
    }

    List<Widget> findRecursiveList(
        Iterable<Node> list, List<DateTime>? dateList) {
      for (var element in list) {
        // String hexColor = element.dict!.pms_color_code!;
        // Color color = darken(
        //     Color(int.parse(hexColor.substring(1, 7), radix: 16) + 0xFF000000));
        // Color initialcolor = lighten(
        //     Color(int.parse(hexColor.substring(1, 7), radix: 16) + 0xFF000000),
        //     0.1);

        if (element.dict!.expand == true) {
          ref.read(fetchApiProvider).arrWidget.add(Container(
                decoration: BoxDecoration(
                  color: ref.watch(homeProvider).dictDrawerData == element.dict!
                      ? const Color.fromARGB(255, 240, 240, 240)
                      : Colors.transparent,
                ),
                key: ValueKey(element.dict?.mstPmsId),
                height: element.dict!.mstPmsId == "0"
                    ? weekHeaderHeight + dayHeaderHeight
                    : 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  controller: widget.controller,
                  itemCount: dateList?.length ?? 0,
                  itemBuilder: (context, index) {
                    Widget checkDateIsBetweenWidget({
                      required Key key,
                      required DateTime providedDateStr,
                      DateTime? currentStartDate,
                      DateTime? currentEndDate,
                    }) {
                      if (currentStartDate!.isAfter(providedDateStr)) {
                        return SizedBox(
                          // color: Colors.amber,
                          key: key,
                          width: getDayWidth(),
                          height: 10,
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }

                    int isWorkTotalComplete(String dat) {
                      if (dat.trim() != '') {
                        double doubleValue = double.parse(dat);
                        int intValue = doubleValue.toInt();
                        return intValue;
                      } else {
                        return 0;
                      }
                    }

                    return
                        // element.dict?.pmsStartDate ==
                        //             element.dict?.pmsEndDate
                        //              ||
                        element.dict?.pmsStartDate == "" ||
                                element.dict?.pmsEndDate == '' ||
                                element.dict?.pmsStartDate == null ||
                                element.dict?.pmsEndDate == null ||
                                element.dict?.pmsStartDate == DateTime(2000) ||
                                element.dict?.pmsStartDate == DateTime(2101)
                            // element.dict?.pmsTotalDays == "0"
                            ? const SizedBox()
                            : dateList!.length - 1 != index
                                ? checkDateIsBetweenWidget(
                                    key:
                                        ValueKey(element.dict?.pmsCategoryName),
                                    providedDateStr: dateList[index],
                                    currentEndDate: element.dict?.pmsEndDate,
                                    currentStartDate:
                                        element.dict?.pmsStartDate,
                                  )
                                : Row(
                                    // mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Stack(
                                        children: [
                                          Center(
                                            child: Tooltip(
                                              message:
                                                  '${element.dict!.pmsCategoryName!} (${(element.dict!.pmsEndDate?.difference(element.dict!.pmsStartDate!).inDays)! + 1}Days) (${element.dict?.consumePercentage}%)'
                                                  '\n${(element.dict!.workOrderDetails != null && element.dict!.workOrderDetails!.length > 0 ? 'Work Order No.: ${element.dict!.workOrderDetails?[0].workOrderNumber!}' : 'Work Order No.: - ')}'
                                                  '\nStart : ${DateFormat('dd/MM/yyyy').format(element.dict!.pmsStartDate!)}'
                                                  '\nEnd : ${DateFormat('dd/MM/yyyy').format(element.dict!.pmsEndDate!)}'
                                                  // '${element.dict!.cmsOriginalStartDate != null ? '${'\nExtended Start Date :  ${DateFormat('dd/MM/yyyy').format(element.dict!.cmsOriginalStartDate ?? DateTime.now())}'}' : ''}'
                                                  '${element.dict!.cmsOriginalStartDate != null ? (element.dict!.cmsOriginalStartDate)!.isBefore(element.dict!.pmsStartDate!) ? '${'\nExtended Start Date :  ${DateFormat('dd/MM/yyyy').format(element.dict!.cmsOriginalStartDate ?? DateTime.now())}'}' : '' : ""}'
                                                  // '${element.dict!.cmsOriginalEndDate != null ? '${'\nExtended End Date :  ${DateFormat('dd/MM/yyyy').format(element.dict!.cmsOriginalEndDate ?? DateTime.now())}'}' : ''}'
                                                  '${element.dict!.cmsOriginalEndDate != null ? (element.dict!.cmsOriginalEndDate)!.isBefore(element.dict!.pmsEndDate!) ? '${'\nExtended End Date :  ${DateFormat('dd/MM/yyyy').format(element.dict!.cmsOriginalEndDate ?? DateTime.now())} Days :(${double.parse((element.dict!.pmsEndDate!.difference(element.dict!.cmsOriginalEndDate!).inDays).toString()) + 1})'}' : '' : ""}', // '\n${element.dict!.pmsEndDate!.difference(element.dict!.cmsOriginalEndDate!).inDays}',
                                              child: GestureDetector(
                                                /*onHover: (val){
                                              if(val == true){
                                                  setState(() {
                                                    hoverID =  element.dict!.mstPmsId!;
                                                    xOffset =  scrollLeftRightController.offset;
                                                  });
                                              }else{
                                                setState(() {
                                                  hoverID = '';
                                                });
                                              }
                                            },*/
                                                onTap: () {
                                                  if (element.parent1?.dict
                                                              ?.details !=
                                                          null
                                                      //     ||
                                                      // widget.entry.node.parent1?.dict
                                                      //     ?.details?.isNotEmpty
                                                      ) {
                                                    int ctIndex = 0;
                                                    for (int i = 0;
                                                        i <
                                                            element
                                                                .parent1!
                                                                .dict!
                                                                .details!
                                                                .length;
                                                        i++) {
                                                      if (element
                                                              .parent1!
                                                              .dict!
                                                              .details![i]
                                                              .mstPmsId ==
                                                          element
                                                              .dict!.mstPmsId) {
                                                        ctIndex = i;
                                                      }
                                                    }

                                                    print(
                                                        '++++ ${element.parent1?.dict?.details?.length} -> ${ctIndex}');

                                                    List<PmsStructure>?
                                                        tempppp = [];
                                                    for (int i = ctIndex;
                                                        i <
                                                            element
                                                                .parent1!
                                                                .dict!
                                                                .details!
                                                                .length;
                                                        i++) {
                                                      if (i != ctIndex) {
                                                        tempppp.add(element
                                                            .parent1!
                                                            .dict!
                                                            .details![i]);
                                                      }
                                                    }
                                                    ref
                                                            .read(fetchApiProvider)
                                                            .pmsStructureForUpdateExistingDrawer =
                                                        tempppp;
                                                    // widget.entry.node.parent1?.dict
                                                    //     ?.details;
                                                    inspect(element.parent1);
                                                  }
                                                  ref
                                                      .read(fetchApiProvider)
                                                      .pmsStructureForDuplicating
                                                      ?.clear();
                                                  ref
                                                      .read(fetchApiProvider)
                                                      .pmsStructureForDuplicating = [
                                                    ...ref
                                                            .read(
                                                                fetchApiProvider)
                                                            .pmsStructureForDuplicating ??
                                                        [],
                                                    DupliacateDataPms(
                                                      pms_color_code: element
                                                          .dict?.pms_color_code,
                                                      mstPmsId: element
                                                          .dict!.mstPmsId,
                                                      pmsCategoryName: element
                                                          .dict!
                                                          .pmsCategoryName,
                                                      parentIdFk: element
                                                          .dict!.parentIdFk,
                                                      pmsOrderNo: element
                                                          .dict!.pmsOrderNo,
                                                      pmsColorCode: element
                                                          .dict!.pms_color_code,
                                                      pmsStartDate: element
                                                          .dict!.pmsStartDate!,
                                                      pmsEndDate: element
                                                          .dict!.pmsEndDate,
                                                      totalDays: element
                                                          .dict!.pmsTotalDays,
                                                      maxDate:
                                                          element.dict!.maxDate,
                                                      minDate:
                                                          element.dict!.minDate,
                                                      projectPmsIdFk: element
                                                          .dict!.projectPmsIdFk,
                                                      parentStartDate: element
                                                          .dict
                                                          ?.parentStartDate,
                                                    )
                                                  ];

                                                  ref
                                                      .read(fetchApiProvider)
                                                      .findRecToGetSingleDimensionArray(
                                                        list11:
                                                            element.children,
                                                        currSelectedNode:
                                                            element.dict!,
                                                      );

                                                  Scaffold.of(context)
                                                      .openEndDrawer();
                                                  // captureAndSaveAsPdf();
                                                  ref
                                                      .read(homeProvider)
                                                      .setSelectedStartDateDrawer(
                                                        data: element.dict!,
                                                        startdata: element.dict!
                                                            .pmsStartDate!,
                                                        enddata: element
                                                            .dict!.pmsEndDate!,
                                                        drawerTitle1: element
                                                                .dict
                                                                ?.pmsCategoryName ??
                                                            '',
                                                        isClickedStartDate:
                                                            element.dict!
                                                                .pmsStartDate!,
                                                        isClickedEndDate:
                                                            element.dict!
                                                                .pmsEndDate!,
                                                        curNode: element,
                                                      );
                                                },
                                                child: Stack(
                                                  children: [
                                                    SizedBox(
                                                      // color: Colors.cyan,
                                                      key: ValueKey(element.dict
                                                          ?.pmsCategoryName),
                                                      height: 20,
                                                      width: (double.parse(element
                                                                      .dict
                                                                      ?.pmsTotalDays ??
                                                                  '0') +
                                                              1) *
                                                          getDayWidth(),

                                                      // 40,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            width: 2,
                                                            color: Color(int.parse(
                                                                    '0xFF${(element.dict!.pms_color_code)?.replaceAll(RegExp('[^A-Za-z0-9]'), '')}'))
                                                                .withOpacity(
                                                                    1.0),
                                                            // isWorkTotalComplete(
                                                            //             element.dict
                                                            //                     ?.consumePercentage ??
                                                            //                 '') ==
                                                            //         100
                                                            //     ? Colors.red
                                                            //     : Color(int.parse(
                                                            //             '0xFF${(element.dict!.pms_color_code)?.replaceAll(RegExp('[^A-Za-z0-9]'), '')}'))
                                                            //         .withOpacity(
                                                            //             1.0),
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          /*boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black12,
                                                            blurRadius: 3.0,
                                                          ),
                                                        ]*/
                                                        ),
                                                        child:
                                                            AnimatedProgressBar(
                                                          height: 6,
                                                          value: double.parse(
                                                                  element.dict
                                                                          ?.consumePercentage ??
                                                                      '0') /
                                                              100,
                                                          duration:
                                                              const Duration(
                                                                  seconds: 2),
                                                          color: Color(int.parse(
                                                                  '0xFF${(element.dict!.pms_color_code)?.replaceAll(RegExp('[^A-Za-z0-9]'), '')}'))
                                                              .withOpacity(0.8),
                                                          //  isWorkTotalComplete(
                                                          //             element.dict
                                                          //                     ?.consumePercentage ??
                                                          //                 '') ==
                                                          //         100
                                                          //     ? Colors.red
                                                          //     : Color(int.parse(
                                                          //             '0xFF${(element.dict!.pms_color_code)?.replaceAll(RegExp('[^A-Za-z0-9]'), '')}'))
                                                          //         .withOpacity(0.8),
                                                          /*gradient: LinearGradient(
                                                    colors: [
                                                  // element.dict?.consumePercentage ==
                                                  isWorkTotalComplete(element.dict
                                                                  ?.consumePercentage ??
                                                              '') ==
                                                          100
                                                      ? Colors.red
                                                      : initialcolor,
                                                  // element.dict?.consumePercentage ==
                                                  //         '100.0'
                                                  isWorkTotalComplete(element.dict
                                                                  ?.consumePercentage ??
                                                              '') ==
                                                          100
                                                      ? Colors.red
                                                      : color,
                                                    ],
                                                ),*/
                                                          backgroundColor:
                                                              const Color(
                                                                  0xFFF0F0F0),
                                                        ),
                                                      ),
                                                    ),
                                                    if (element.dict!
                                                                .cmsOriginalEndDate !=
                                                            null &&
                                                        (element.dict!
                                                                .cmsOriginalEndDate)!
                                                            .isBefore(element
                                                                .dict!
                                                                .pmsEndDate!))
                                                      Positioned(
                                                        right:
                                                            0, // ✅ starts from end

                                                        child: SizedBox(
                                                          key: ValueKey(element
                                                              .dict?.mstPmsId),
                                                          height: 20,
                                                          width: (double.parse((element
                                                                          .dict!
                                                                          .pmsEndDate!
                                                                          .difference(element
                                                                              .dict!
                                                                              .cmsOriginalEndDate!)
                                                                          .inDays)
                                                                      .toString()) +
                                                                  1) *
                                                              getDayWidth(),
                                                          child:
                                                              const AnimatedProgressBar(
                                                            height: 6,
                                                            value: 100,
                                                            duration: Duration(
                                                                seconds: 2),
                                                            color: Colors.red,
                                                            backgroundColor:
                                                                Color(
                                                                    0xFFF0F0F0),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),

                                          /*Positioned(
                                        top:3,
                                        child: Transform(
                                          //transform: Matrix4.translationValues((int.parse('${element.dict?.pmsTotalDays!}')/2), 15, 0),
                                          transform: Matrix4.translationValues( hoverID == element.dict?.mstPmsId ? (MediaQuery.of(context).size.width) < (int.parse('${element.dict?.pmsTotalDays!}')/2) ? (int.parse('${element.dict?.pmsTotalDays!}')/2) : xOffset : (int.parse('${element.dict?.pmsTotalDays!}')/2) , 15, 0),
                                          child: Container(
                                            //color: Colors.yellowAccent,
                                            child:  Text( //KRISHNA
                                              (element.dict!.pmsCategoryName!.length * 11) < (int.parse('${element.dict?.pmsTotalDays!}') * getDayWidth()) ? element.dict!.pmsCategoryName! : '' ,
                                              style: const TextStyle(fontSize: 11, color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),*/ //
                                        ],
                                      ),
                                      Container(
                                        height: element.dict!.mstPmsId == "0"
                                            ? weekHeaderHeight + dayHeaderHeight
                                            : 50,
                                        decoration: const BoxDecoration(
                                            color: Colors.white),
                                        child: Row(
                                          children: [
                                            const SizedBox(width: 4),
                                            if (isWorkTotalComplete(element.dict
                                                        ?.consumePercentage ??
                                                    '') >
                                                0)
                                              Text(
                                                '${(double.parse(element.dict?.consumePercentage ?? '')).toStringAsFixed(2)}%',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                  },
                ),
              ));
          if (element.children1.isNotEmpty) {
            findRecursiveList(element.children1, dateList);
          }
        }
      }
      return ref.read(fetchApiProvider).arrWidget;
    }

    Widget filterViewSelection({required DateTime data, required int index}) {
      if (ref.watch(homeProvider).isSelectedFilterView == "WEEK" &&
          index % 7 == 0) {
        return Container(
          key: ValueKey(dateList[index]),
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.black),
              bottom: BorderSide(
                color: Colors.black,
              ),
              top: BorderSide(
                color: Colors.black,
              ),
            ),
          ),
          width: 80,
          child: Column(
            children: [
              Text(
                '${dateList[index].day}  -  ${dateList.length > index + 6 ? dateList[index + 6].day : dateList[dateList.length - 1].day}',
              ),
              Text(
                '${getDayOfWeek(dateList[index])}  -  ${dateList.length > index + 6 ? getDayOfWeek(dateList[index + 6]) : getDayOfWeek(dateList[dateList.length - 1])}',
              ),
            ],
          ),
        );
      } else if (ref.watch(homeProvider).isSelectedFilterView == "DAYS") {
        return Container(
          key: ValueKey(dateList[index]),
          decoration: BoxDecoration(
            color: ref.watch(homeProvider).isClickedEndDate != null &&
                    ref.watch(homeProvider).isClickedEndDate != null &&
                    (ref.watch(homeProvider).isClickedStartDate!)
                        .subtract(const Duration(days: 1))
                        .isBefore(dateList[index]) &&
                    (ref.watch(homeProvider).isClickedEndDate!)
                        .add(const Duration(days: 1))
                        .isAfter(dateList[index])
                ? Colors.grey
                : Colors.transparent,
            border: Border(
                right: BorderSide(
                  // color: Colors.black,
                  color: getDayOfWeek(dateList[index]) == "Sun" ||
                          index == dateList.length - 1
                      ? Colors.black
                      : Colors.transparent,
                ),
                left: BorderSide(
                  color: dateList[index].day == 1
                      ? Colors.black
                      : Colors.transparent,
                  width: 2,
                ),
                bottom: const BorderSide(
                  color: Colors.black,
                )),
          ),
          width: 40,
          child: Column(
            children: [
              Text(
                '${dateList[index].day}',
              ),
              Text(
                getDayOfWeek(dateList[index]),
              ),
            ],
          ),
        );
      } else if (ref.watch(homeProvider).isSelectedFilterView == "MONTH") {
        return Container(
          key: ValueKey(dateList[index]),
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.black),
              bottom: BorderSide(color: Colors.black),
              top: BorderSide(color: Colors.black),
            ),
          ),
          width: double.parse(
              (monthInfoForMonthList[index].daysBetween * 4).toString()),
          child: Center(
            child: Text(
                '${monthInfoForMonthList[index].startDate.day} - ${DateFormat('d MMM').format(monthInfoForMonthList[index].endDate)}'),
          ),
        );
      } else if (ref.watch(homeProvider).isSelectedFilterView == "YEAR") {
        return Container(
          key: ValueKey(dateList[index]),
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.black),
              bottom: BorderSide(color: Colors.black),
              top: BorderSide(color: Colors.black),
            ),
          ),
          width: double.parse((yearInfoList[index].daysBetween * 2).toString()),
          child: Center(
            child: Text(
                '${DateFormat('d MMM').format(yearInfoList[index].startDate)} - ${DateFormat('d MMM').format(yearInfoList[index].endDate)}'),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    }

    double getMarginSelected() {
      if (ref.watch(homeProvider).dictDrawerData?.pmsStartDate != null &&
          ref.watch(fetchApiProvider).pmsStartDateFromResponse != null &&
          ref.watch(homeProvider).dictDrawerData != null) {
        double temp = (double.parse(
                    ((ref.watch(homeProvider).dictDrawerData?.pmsStartDate)!
                                .difference(ref
                                    .watch(fetchApiProvider)
                                    .pmsStartDateFromResponse!) -
                            const Duration(days: 1))
                        .inDays
                        .toString()) +
                1) *
            getDayWidth();
        return temp > 0 ? temp : 0;
      }
      return 0;
    }

    print('Called');

    return
        // ref.watch(fetchApiProvider).flagcalled == true &&
        //         ref.watch(fetchApiProvider).pmsStructure?.length != 0
        //     ?
        ref.watch(fetchApiProvider).isLoadingFetchShimer == true
            ? Row(
                children: [
                  SizedBox(
                    width: 400,
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: ListView.builder(
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return Container(
                            margin:
                                EdgeInsets.only(bottom: index != 0 ? 18 : 2),
                            child: Card(
                              elevation: 1.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Container(
                                height: index == 0 ? 70 : 24,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const VerticalDivider(
                    width: 5,
                    thickness: 5,
                    color: Colors.black,
                  ),
                  Expanded(
                    child: Container(
                      // width: 400,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return Container(
                              margin:
                                  EdgeInsets.only(bottom: index != 0 ? 18 : 2),
                              child: Card(
                                elevation: 1.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Container(
                                  height: index == 0 ? 70 : 24,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  )
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ref.watch(fetchApiProvider).isLoadingFetchShimer == true
                  //     ? Container(
                  //         width: 400,
                  //         child: Shimmer.fromColors(
                  //           baseColor: Colors.grey[300]!,
                  //           highlightColor: Colors.grey[100]!,
                  //           child: ListView.builder(
                  //             itemCount: 10,
                  //             itemBuilder: (context, index) {
                  //               return Container(
                  //                 margin: EdgeInsets.only(
                  //                     bottom: index != 0 ? 18 : 2),
                  //                 child: Card(

                  //                   elevation: 1.0,
                  //                   shape: RoundedRectangleBorder(
                  //                     borderRadius: BorderRadius.circular(6),
                  //                   ),
                  //                   child: Container(
                  //                     height: index == 0 ? 70 : 24,
                  //                   ),
                  //                 ),
                  //               );
                  //             },
                  //           ),
                  //         ),
                  //       )
                  //     :
                  SizedBox(
                    width: 400,
                    child: Column(
                      children: [
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            height: 70,
                            decoration: const BoxDecoration(
                                border: Border(
                              bottom: BorderSide(color: Colors.black),
                            )),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(width: 10),
                                if (ref
                                            .read(fetchApiProvider)
                                            .projectPmsInfoResponse !=
                                        null &&
                                    ref
                                        .read(fetchApiProvider)
                                        .projectPmsInfoResponse!
                                        .isNotEmpty)
                                  Text(
                                    ref
                                            .read(fetchApiProvider)
                                            .projectPmsInfoResponse?[0]
                                            .projectPmsName ??
                                        '',
                                    // widget.towarName!.isNotEmpty
                                    //     ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                                    //     : widget.projectName!.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                const SizedBox(width: 10),
                                InkWell(
                                  onTap: () {
                                    ref
                                        .read(fetchApiProvider)
                                        .updatePmsInfoModal(
                                          context: context,
                                          projectId: widget.projectId ?? '',
                                          towarId: widget.towarId ?? '',
                                        );
                                  },
                                  child: const Icon(
                                    Icons.edit,
                                    size: 22,
                                    color: Colors.black,
                                  ),
                                ),
                                const Spacer(),
                                InkWell(
                                  onTap: () {
                                    ref.read(fetchApiProvider).addNewPmsModal(
                                          context: context,
                                          projectId: widget.projectId ?? '',
                                          towarId: widget.towarId ?? '',
                                        );
                                    // Future.delayed(const Duration(seconds: 5),
                                    //     () {
                                    //   print(
                                    //       'One second has passed.'); // Prints after 1 second.
                                    //   // inspect(treeController);
                                    //   for (int k = 0;
                                    //       k <
                                    //           ref
                                    //               .read(fetchApiProvider)
                                    //               .openDropDown
                                    //               .length;
                                    //       k++) {
                                    //     print(
                                    //         '++++++++++++${ref.read(fetchApiProvider).openDropDown[k].dict?.pmsCategoryName}');
                                    //     // treeController.toggleExpansion(openDropDown[k]);
                                    //     ref
                                    //         .read(fetchApiProvider)
                                    //         .treeController
                                    //         .toggleExpansion(ref
                                    //             .read(fetchApiProvider)
                                    //             .openDropDown[k]);
                                    //   }
                                    // });
                                    // for (int k = 0;
                                    //     k <
                                    //         ref
                                    //             .read(fetchApiProvider)
                                    //             .openDropDown
                                    //             .length;
                                    //     k++) {
                                    //   inspect(ref
                                    //       .read(fetchApiProvider)
                                    //       .openDropDown[k]);
                                    //   print(ref
                                    //       .read(fetchApiProvider)
                                    //       .openDropDown[k]
                                    //       .dict
                                    //       ?.pmsCategoryName);
                                    //   ref
                                    //       .read(fetchApiProvider)
                                    //       .openDropDown[k]
                                    //       .dict
                                    //       ?.pmsCategoryName = "testing";
                                    //   bool isyyyyy = ref
                                    //       .read(fetchApiProvider)
                                    //       .treeController
                                    //       .toggleExpansion(ref
                                    //           .read(fetchApiProvider)
                                    //           .openDropDown[k]);
                                    //   ref
                                    //       .read(fetchApiProvider)
                                    //       .treeController
                                    //       .rebuild();
                                    //   print('---------------${isyyyyy}');
                                    // }
                                    // });
                                  },
                                  child: const Icon(
                                    Icons.add,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )),
                        Expanded(
                          child: CustomScrollView(
                              scrollDirection: Axis.horizontal,
                              // physics: NeverScrollableScrollPhysics(),
                              slivers: [
                                SliverList(
                                  delegate: SliverChildListDelegate([
                                    Container(
                                      constraints: const BoxConstraints(
                                          minWidth: 400, maxWidth: 1000),
                                      child: AnimatedTreeView<Node>(
                                        controller:
                                            scrollLeftTopBottomController,
                                        treeController: ref
                                            .read(fetchApiProvider)
                                            .treeController,
                                        nodeBuilder: (BuildContext context,
                                            TreeEntry<Node> entry) {
                                          return Container(
                                            color: ref
                                                        .read(homeProvider)
                                                        .dictDrawerData ==
                                                    entry.node.dict!
                                                ? const Color.fromARGB(
                                                    255, 240, 240, 240)
                                                : Colors.transparent,
                                            child: DragAndDropTreeTile(
                                              // fetchRecords: ref.read(fetchApiProvider).fetchRecords,
                                              entry: entry,
                                              borderSide: borderSide,
                                              onNodeAccepted: onNodeAccepted,
                                              onFilePressed: () {
                                                // Scaffold.of(context).openEndDrawer();
                                                ref
                                                    .read(homeProvider)
                                                    .setSelectedStartDateDrawer(
                                                      data: entry.node.dict!,
                                                      startdata: entry.node
                                                          .dict!.pmsStartDate!,
                                                      enddata: entry.node.dict!
                                                          .pmsEndDate!,
                                                      drawerTitle1: entry
                                                              .node
                                                              .dict
                                                              ?.pmsCategoryName ??
                                                          '',
                                                      isClickedStartDate: entry
                                                          .node
                                                          .dict!
                                                          .pmsStartDate!,
                                                      isClickedEndDate: entry
                                                          .node
                                                          .dict!
                                                          .pmsEndDate!,
                                                      curNode: entry.node,
                                                    );

                                                if (ref
                                                            .watch(homeProvider)
                                                            .isSelectedFilterView !=
                                                        'YEAR' &&
                                                    entry.node.dict
                                                            ?.pmsTotalDays !=
                                                        "0") {
                                                  Duration difference = (entry
                                                          .node
                                                          .dict!
                                                          .pmsStartDate)!
                                                      .difference(ref
                                                          .watch(
                                                              fetchApiProvider)
                                                          .pmsStartDateFromResponse!);

                                                  scrollLeftRightController
                                                      .jumpTo(getScrollPosition(
                                                          entry.node.dict!
                                                              .pmsStartDate!,
                                                          difference));
                                                  //(entry.node.dict?.pmsStartDate == ref.watch(fetchApiProvider).pmsStartDateFromResponse ? 0 : 150));
                                                }
                                              },
                                              onFolderPressed: () {
                                                ref
                                                    .read(fetchApiProvider)
                                                    .pmsStructureForDuplicating
                                                    ?.clear();
                                                ref
                                                    .read(fetchApiProvider)
                                                    .pmsStructureForDuplicating = [
                                                  ...ref
                                                          .read(
                                                              fetchApiProvider)
                                                          .pmsStructureForDuplicating ??
                                                      [],
                                                  // element.dict!
                                                  DupliacateDataPms(
                                                    pms_color_code: entry.node
                                                        .dict?.pms_color_code,
                                                    mstPmsId: entry
                                                        .node.dict!.mstPmsId,
                                                    pmsCategoryName: entry.node
                                                        .dict!.pmsCategoryName,
                                                    parentIdFk: entry
                                                        .node.dict!.parentIdFk,
                                                    pmsOrderNo: entry
                                                        .node.dict!.pmsOrderNo,
                                                    pmsColorCode: entry.node
                                                        .dict!.pms_color_code,
                                                    pmsStartDate: entry.node
                                                        .dict!.pmsStartDate!,
                                                    pmsEndDate: entry
                                                        .node.dict!.pmsEndDate,
                                                    totalDays: entry.node.dict!
                                                        .pmsTotalDays,
                                                    maxDate: entry
                                                        .node.dict!.maxDate,
                                                    minDate: entry
                                                        .node.dict!.minDate,
                                                    projectPmsIdFk: entry.node
                                                        .dict!.projectPmsIdFk,
                                                    parentStartDate: entry.node
                                                        .dict!.parentStartDate,
                                                  )
                                                ];

                                                ref
                                                    .read(fetchApiProvider)
                                                    .findRecToGetSingleDimensionArray(
                                                      list11:
                                                          entry.node.children,
                                                      currSelectedNode:
                                                          entry.node.dict!,
                                                    );

                                                String temmmm = json.encode(ref
                                                    .watch(fetchApiProvider)
                                                    .pmsStructureForDuplicating);
                                                print(temmmm);
                                                // Scaffold.of(context).openEndDrawer();
                                                // print(
                                                //     'length = ${entry.node.children.length}');
                                                ref
                                                    .read(homeProvider)
                                                    .setSelectedStartDateDrawer(
                                                      data: entry.node.dict!,
                                                      startdata: entry.node
                                                          .dict!.pmsStartDate!,
                                                      enddata: entry.node.dict!
                                                          .pmsEndDate!,
                                                      drawerTitle1: entry
                                                              .node
                                                              .dict
                                                              ?.pmsCategoryName ??
                                                          '',
                                                      isClickedStartDate: entry
                                                          .node
                                                          .dict!
                                                          .pmsStartDate!,
                                                      isClickedEndDate: entry
                                                          .node
                                                          .dict!
                                                          .pmsEndDate!,
                                                      curNode: entry.node,
                                                    );

                                                if (ref
                                                            .watch(homeProvider)
                                                            .isSelectedFilterView != //DAYS  WEEK  MONTH  YEAR
                                                        'YEAR' &&
                                                    entry.node.dict
                                                            ?.pmsTotalDays !=
                                                        "0") {
                                                  Duration difference = (entry
                                                          .node
                                                          .dict!
                                                          .pmsStartDate)!
                                                      .difference(ref
                                                          .watch(
                                                              fetchApiProvider)
                                                          .pmsStartDateFromResponse!);
                                                  scrollLeftRightController
                                                      .jumpTo(getScrollPosition(
                                                          entry.node.dict!
                                                              .pmsStartDate!,
                                                          difference));

                                                  //(difference.inDays *
                                                  // getDayWidth()) - (ref.watch(fetchApiProvider).pmsStartDateFromResponse!.difference(entry.node.dict!.pmsStartDate!).inDays > 4 ? 0 : 150 ));
                                                  //(entry.node.dict?.pmsStartDate == ref.watch(fetchApiProvider).pmsStartDateFromResponse ? 0 : 150));
                                                }
                                                // ref
                                                //     .read(fetchApiProvider)
                                                //     .setOpenDropDown(entry.node);
                                                bool temp = ref
                                                    .watch(fetchApiProvider)
                                                    .treeController
                                                    .toggleExpansion(
                                                        entry.node);
                                                ref
                                                    .read(fetchApiProvider)
                                                    .arrWidget = [];
                                                // setState(() {
                                                if (temp) {
                                                  ref
                                                      .read(fetchApiProvider)
                                                      .setOpenDropDown(
                                                          entry.node);
                                                  ref
                                                      .read(fetchApiProvider)
                                                      .findRecursiveTrueFalse(
                                                          entry.node, true);
                                                } else {
                                                  ref
                                                      .read(fetchApiProvider)
                                                      .removeOpenDropDown(
                                                          entry.node);
                                                  ref
                                                      .read(fetchApiProvider)
                                                      .findRecursiveTrueFalse(
                                                          entry.node, false);
                                                }
                                                // ref
                                                //     .watch(fetchApiProvider)
                                                //     .root
                                                //     .children1
                                                //     .length;
                                                // });
                                              },
                                              projectId: widget.projectId ?? '',
                                              towarId: widget.towarId ?? '',
                                            ),
                                          );
                                        },
                                        duration: watchAnimationDurationSetting(
                                            context),
                                      ),
                                    ),
                                  ]),
                                )
                              ]),
                        ),
                      ],
                    ),
                  ),

                  /*SizedBox(
                    width: 410,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Project ttile left side and add icon
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            height: 70,
                            decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.black),
                                )),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  widget.towarName!.isNotEmpty
                                      ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                                      : widget.projectName!.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    ref.read(fetchApiProvider).addNewPmsModal(
                                      context: context,
                                      projectId: widget.projectId ?? '',
                                      towarId: widget.towarId ?? '',
                                    );
                                  },
                                  child: const Icon(
                                    Icons.add,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )),
                        Expanded(
                          child: AnimatedTreeView<Node>(
                            controller: scrollLeftTopBottomController,
                            treeController:
                            ref.read(fetchApiProvider).treeController,
                            nodeBuilder:
                                (BuildContext context, TreeEntry<Node> entry) {
                              return Container(
                                color: ref.read(homeProvider).dictDrawerData ==
                                    entry.node.dict!
                                    ? const Color.fromARGB(255, 240, 240, 240)
                                    : Colors.transparent,
                                child: DragAndDropTreeTile(
                                  // fetchRecords: ref.read(fetchApiProvider).fetchRecords,
                                  entry: entry,
                                  borderSide: borderSide,
                                  onNodeAccepted: onNodeAccepted,
                                  onFilePressed: () {
                                    // Scaffold.of(context).openEndDrawer();
                                    ref
                                        .read(homeProvider)
                                        .setSelectedStartDateDrawer(
                                      data: entry.node.dict!,
                                      startdata: entry.node.dict!.pmsStartDate!,
                                      enddata: entry.node.dict!.pmsEndDate!,
                                      drawerTitle1:
                                      entry.node.dict?.pmsCategoryName ??
                                          '',
                                      isClickedStartDate:
                                      entry.node.dict!.pmsStartDate!,
                                      isClickedEndDate:
                                      entry.node.dict!.pmsEndDate!,
                                    );

                                    if (ref
                                        .watch(homeProvider)
                                        .isSelectedFilterView !=
                                        'YEAR') {
                                      Duration difference =
                                      (entry.node.dict!.pmsStartDate)!
                                          .difference(ref
                                          .watch(fetchApiProvider)
                                          .pmsStartDateFromResponse!);
                                      scrollLeftRightController.jumpTo(
                                          difference.inDays * getDayWidth());
                                    }
                                  },
                                  onFolderPressed: () {
                                    // Scaffold.of(context).openEndDrawer();
                                    print('length = ${entry.node.children.length}');
                                    ref
                                        .read(homeProvider)
                                        .setSelectedStartDateDrawer(
                                      data: entry.node.dict!,
                                      startdata: entry.node.dict!.pmsStartDate!,
                                      enddata: entry.node.dict!.pmsEndDate!,
                                      drawerTitle1:
                                      entry.node.dict?.pmsCategoryName ??
                                          '',
                                      isClickedStartDate:
                                      entry.node.dict!.pmsStartDate!,
                                      isClickedEndDate:
                                      entry.node.dict!.pmsEndDate!,
                                    );

                                    if (ref
                                        .watch(homeProvider)
                                        .isSelectedFilterView != //DAYS  WEEK  MONTH  YEAR
                                        'YEAR') {
                                      Duration difference =
                                      (entry.node.dict!.pmsStartDate)!
                                          .difference(ref
                                          .watch(fetchApiProvider)
                                          .pmsStartDateFromResponse!);
                                      scrollLeftRightController.jumpTo(
                                          difference.inDays * getDayWidth());
                                    }

                                    bool temp = ref
                                        .watch(fetchApiProvider)
                                        .treeController
                                        .toggleExpansion(entry.node);
                                    ref.read(fetchApiProvider).arrWidget = [];
                                    // setState(() {
                                    if (temp) {
                                      ref
                                          .read(fetchApiProvider)
                                          .setOpenDropDown(entry.node);
                                      findRecursiveTrueFalse(entry.node, true);
                                    } else {
                                      findRecursiveTrueFalse(entry.node, false);
                                    }
                                    ref
                                        .watch(fetchApiProvider)
                                        .root
                                        .children1
                                        .length;
                                    // });
                                  },
                                  projectId: widget.projectId ?? '',
                                  towarId: widget.towarId ?? '',
                                ),
                              );
                            },
                            duration: watchAnimationDurationSetting(context),
                          ),
                        ),
                      ],
                    ),
                  ),*/

                  /*for(int i = 0; i < ref.read(fetchApiProvider).root.children1.length; i++)
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: PopupMenuButton(
                        onSelected: (value) {
                          // your logic
                        },
                        itemBuilder: (BuildContext bc) {
                          return [
                            PopupMenuItem(
                              onTap: () {
                                /*addNewPmsModal().then((value) {
                              startDateControler.clear();
                              endDateControler.clear();
                              titleControler.clear();
                              remarkControler.clear();
                            });*/
                              },
                              value: '/hello',
                              child: const Text("ADD"),
                            ),
                            PopupMenuItem(
                              value: '/about',
                              onTap: () {
                                /*editExistingPmsModal(
                                    currentPmsStructure: widget.entry.node.dict!)
                                .then((value) {
                              startDateControler.clear();
                              endDateControler.clear();
                              titleControler.clear();
                            });*/
                              },
                              child: const Text("EDIT"),
                            ),
                            PopupMenuItem(
                              value: '/contact',
                              child: const Text("DELETE"),
                              onTap: () {
                                /*deleteExistingPmsModal(
                                currentPmsStructure: widget.entry.node.dict!);*/
                              },
                            )
                          ];
                        },
                      ),
                    ),*/

                  const VerticalDivider(
                    width: 5,
                    thickness: 5,
                    color: Colors.black,
                  ),
                  // ref.watch(fetchApiProvider).isLoadingFetchShimer == true
                  //     ? Expanded(
                  //         child: Container(
                  //           // width: 400,
                  //           child: Shimmer.fromColors(
                  //             baseColor: Colors.grey[300]!,
                  //             highlightColor: Colors.grey[100]!,
                  //             child: ListView.builder(
                  //               itemCount: 10,
                  //               itemBuilder: (context, index) {
                  //                 return Container(
                  //                   margin: EdgeInsets.only(
                  //                       bottom: index != 0 ? 18 : 2),
                  //                   child: Card(
                  //                     elevation: 1.0,
                  //                     shape: RoundedRectangleBorder(
                  //                       borderRadius: BorderRadius.circular(6),
                  //                     ),
                  //                     child: Container(
                  //                       height: index == 0 ? 70 : 24,
                  //                     ),
                  //                   ),
                  //                 );
                  //               },
                  //             ),
                  //           ),
                  //         ),
                  //       )
                  //     :
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: scrollLeftRightController,
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (ref
                                            .watch(homeProvider)
                                            .isSelectedFilterView ==
                                        'DAYS')
                                      for (int k = 0;
                                          k < daysBetweenMondays.length;
                                          k++)
                                        Container(
                                          decoration: const BoxDecoration(
                                            border: Border(
                                                // right: BorderSide(
                                                //   color: Colors.black,
                                                // ),
                                                bottom: BorderSide(
                                              color: Colors.black,
                                            )
                                                // color: Colors.black,
                                                ),
                                          ),
                                          height: 30,
                                          width: double.parse(
                                              (daysBetweenMondays[k] * 40)
                                                  .toString()),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Text(
                                              DateFormat('EEEE, d MMMM y')
                                                  .format(mondayDates[k]),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.clip,
                                            ),
                                          ),
                                        ),
                                    if (ref
                                            .watch(homeProvider)
                                            .isSelectedFilterView ==
                                        "WEEK")
                                      for (int k = 0;
                                          k < monthInfoList.length;
                                          k++)
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                color: k ==
                                                        monthInfoList.length - 1
                                                    ? Colors.transparent
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                          height: 26,
                                          width: double.parse(
                                              (monthInfoList[k].daysInMonth *
                                                      11.428)
                                                  .toString()),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Text(
                                              '${monthInfoList[k].month} ${monthInfoList[k].year}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.clip,
                                            ),
                                          ),
                                        ),

                                    // monthInfoForMonthList
                                    if (ref
                                            .watch(homeProvider)
                                            .isSelectedFilterView ==
                                        "MONTH")
                                      for (int k = 0;
                                          k < monthInfoForMonthList.length;
                                          k++)
                                        Container(
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                color: Colors.black,
                                                // k ==
                                                //         monthInfoForMonthList.length -
                                                //             1
                                                //     ? Colors.transparent
                                                //     : Colors.black,
                                              ),
                                            ),
                                          ),
                                          height: 26,
                                          width: double.parse(
                                              (monthInfoForMonthList[k]
                                                          .daysBetween *
                                                      4)
                                                  .toString()),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Text(
                                              '${monthInfoForMonthList[k].monthName} ${monthInfoForMonthList[k].startDate.year}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.clip,
                                            ),
                                          ),
                                        ),

                                    //yearInfoList
                                    if (ref
                                            .watch(homeProvider)
                                            .isSelectedFilterView ==
                                        "YEAR")
                                      for (int k = 0;
                                          k < yearInfoList.length;
                                          k++)
                                        Container(
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                color: Colors.black,
                                                // k ==
                                                //         monthInfoForMonthList.length -
                                                //             1
                                                //     ? Colors.transparent
                                                //     : Colors.black,
                                              ),
                                            ),
                                          ),
                                          height: 26,
                                          width: double.parse(
                                              (yearInfoList[k].daysBetween * 2)
                                                  .toString()),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Text(
                                              '${yearInfoList[k].year}',
                                              //  ${yearInfoList[k].startDate.year}
                                              //  ',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.clip,
                                            ),
                                          ),
                                        ),
                                  ],
                                ),
                                Stack(
                                  children: [
                                    Container(
                                      // margin: EdgeInsets.only(
                                      //   left: ref
                                      //               .watch(homeProvider)
                                      //               .dictDrawerData !=
                                      //           null
                                      //       ? ((double.parse(((ref
                                      //                               .watch(
                                      //                                   homeProvider)
                                      //                               .dictDrawerData
                                      //                               ?.pmsStartDate)!
                                      //                           .difference(ref
                                      //                               .watch(
                                      //                                   fetchApiProvider)
                                      //                               .pmsStartDateFromResponse!) -
                                      //                       const Duration(days: 1))
                                      //                   .inDays
                                      //                   .toString()) +
                                      //               1) *
                                      //           getDayWidth())
                                      //       : 0,
                                      // ),

                                      margin: EdgeInsets.only(
                                          left: getMarginSelected()),
                                      height: 44,
                                      width: ref
                                                  .watch(homeProvider)
                                                  .dictDrawerData !=
                                              null
                                          ? ((double.parse(ref
                                                          .watch(homeProvider)
                                                          .dictDrawerData!
                                                          .pmsTotalDays ??
                                                      "") +
                                                  1) *
                                              getDayWidth())
                                          : 0,
                                      color: ref
                                                  .watch(homeProvider)
                                                  .dictDrawerData
                                                  ?.pmsTotalDays ==
                                              "0"
                                          ? Colors.transparent
                                          : const Color.fromARGB(
                                              255, 214, 214, 214),
                                    ),
                                    SizedBox(
                                      height: 44,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        controller: widget
                                            .controller, //DAYS  WEEK  MONTH  YEAR
                                        itemCount: ref
                                                    .watch(homeProvider)
                                                    .isSelectedFilterView ==
                                                'YEAR'
                                            ? yearInfoList.length
                                            : ref
                                                        .watch(homeProvider)
                                                        .isSelectedFilterView ==
                                                    'MONTH'
                                                ? monthInfoForMonthList.length
                                                : dateList.length,
                                        itemBuilder: (context, index) {
                                          return filterViewSelection(
                                              data: dateList[index],
                                              index: index);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Expanded(
                                child: SingleChildScrollView(
                              controller: scrollRightTopBottomController,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...findRecursiveList(
                                      ref
                                          .watch(fetchApiProvider)
                                          .treeController
                                          .roots,
                                      // ref.watch(fetchApiProvider).root.children1,
                                      dateList)
                                ],
                              ),
                            ))
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              );
    // ? RepaintBoundary(
    //     key: yourKey,
    //     child: SingleChildScrollView(
    //       scrollDirection: Axis.horizontal,
    //       child: Row(
    //         children: [
    //           for (int i = 0; i < 100; i++)
    //             InkWell(
    //               onTap: () {
    //                 captureAndSaveAsPdf();
    //               },
    //               child: Container(
    //                 margin: EdgeInsets.only(right: 10),
    //                 padding: EdgeInsets.all(10),
    //                 decoration: BoxDecoration(
    //                     // color: Colors.cyanAccent,
    //                     border: Border.all(
    //                   color: Colors.black,
    //                 )),
    //                 child: Text(
    //                   '${i}',
    //                   style: TextStyle(fontSize: 18),
    //                 ),
    //               ),
    //             ),
    //         ],
    //       ),
    //     ))
    // : ref.watch(fetchApiProvider).flagcalled == false
    //     ? const Center(child: CircularProgressIndicator())
    //     : ref.watch(fetchApiProvider).pmsStructure?.length == 0
    //         ? Center(
    //             child: InkWell(
    //               onTap: () {
    //                 ref.read(fetchApiProvider).addNewPmsModal(
    //                       context: context,
    //                       projectId: widget.projectId ?? '',
    //                       towarId: widget.towarId ?? '',
    //                     );
    //               },
    //               child: Container(
    //                 padding: const EdgeInsets.symmetric(
    //                   vertical: 12,
    //                   horizontal: 40,
    //                 ),
    //                 decoration: BoxDecoration(
    //                   color: Colors.black,
    //                   borderRadius: BorderRadius.circular(6),
    //                 ),
    //                 child: const Text(
    //                   "CREATE NEW SCHEDULE MANAGEMENT", //
    //                   style: TextStyle(
    //                     color: Colors.white,
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           )
    //         : const SizedBox.shrink();
  }

  Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  // void findRecursiveTrueFalseList(List<Node> list, bool flag) {
  //   for (int i = 0; i < list.length; i++) {
  //     list[i].dict!.expand = flag;
  //     if (list[i].children1.isNotEmpty) {
  //       findRecursiveTrueFalseList(list[i].children1, flag);
  //     }
  //   }
  // }

  // void findRecursiveTrueFalse(Node list, bool flag) {
  //   for (int i = 0; i < list.children1.length; i++) {
  //     list.children1[i].dict!.expand = flag;
  //     // ref.read(fetchApiProvider).removeOpenDropDown(list.children1[i]);
  //     ref.read(fetchApiProvider).treeController.collapse(list.children1[i]);

  //     if (flag == false) {
  //       if (list.children1[i].children1.isNotEmpty) {
  //         // ref.read(fetchApiProvider).setOpenDropDown(list.children1[i]);
  //         findRecursiveTrueFalseList(list.children1[i].children1, flag);
  //       }
  //     }
  //   }
  // }
}

int _uniqueId = 0;
void populateExampleTree(
  Node node, [
  int level = 0,
  Random? rng,
  int minChildCount = 3,
]) {
  if (level >= 3) return;

  rng ??= Random();

  for (int index = 0; index <= minChildCount + rng.nextInt(3); ++index) {
    final child = Node(id: _uniqueId++)..parent1 = node;
    node.children1.add(child);
    populateExampleTree(child, level + 1, rng, 1);
  }
}

class MonthInfo {
  final String month;
  final int daysInMonth;
  final int year;

  MonthInfo(this.month, this.daysInMonth, this.year);
}

class MonthInfoForMonth {
  final String monthName;
  final DateTime startDate;
  final DateTime endDate;
  final int daysBetween;

  MonthInfoForMonth(
      this.monthName, this.startDate, this.endDate, this.daysBetween);
}

class YearInfo {
  final int year;
  final DateTime startDate;
  final DateTime endDate;
  final int daysBetween;

  YearInfo(this.year, this.startDate, this.endDate, this.daysBetween);
}
